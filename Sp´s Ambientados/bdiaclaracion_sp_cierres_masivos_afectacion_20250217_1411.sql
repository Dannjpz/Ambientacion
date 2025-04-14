DROP PROCEDURE IF EXISTS "informix".sp_cierres_masivos_afectacion();


CREATE PROCEDURE "informix".sp_cierres_masivos_afectacion()
						
	RETURNING	CHAR(5) AS codigo_ret;
	--	VARCHAR(150)		AS Mensaje;

	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(6);
	DEFINE cCodRet              		CHAR(6);
	DEFINE vFolioCsuac					varchar(11);
	--DEFINE c_ruta_archivo				VARCHAR(50);
	DEFINE c_nombre_archivo				VARCHAR(50);
	DEFINE c_ext_archivo				VARCHAR(50);
	DEFINE v_nombre_archivo				VARCHAR(50);
	DEFINE c_fecha_actual				DATE;
	DEFINE v_nombre            	 		VARCHAR(11) ;
	DEFINE v_descripcion        		VARCHAR(100);
	Define cCadena 						CHAR(1000);
	DEFINE vsql	        				char(3000);
	DEFINE v_folio_csuac 				varchar(16);
	DEFINE v_dictamen   				LVARCHAR;
	DEFINE v_bitacora   				LVARCHAR;
	DEFINE v_importeprocedente			MONEY;
	DEFINE v_dias_conclucion 			integer;
	DEFINE v_pky_aclaracion 			integer;
	DEFINE iContador  					INTEGER;
	DEFINE v_temp_table        			INTEGER;
	DEFINE v_mensaje 					varchar(150);
	DEFINE v_procede  					varchar(2);
	DEFINE vcodresolucion      		 	varchar(2);
	DEFINE vResultado					CHAR(50);
	DEFINE v_resolucion      			INTEGER;
	DEFINE v_procedente					CHAR(2);
	--DEFINE v_mensaje 					varchar(150);
	DEFINE v_num_proceso				INTEGER;
	DEFINE v_estatus_aclaracion			INTEGER;
	DEFINE v_estatus_general			INTEGER;
	DEFINE v_afectacion					CHAR(1);
	
	LET v_cod_ret 						= "00000";
	--LET c_ruta_archivo 					= "DISK:/resplogifx/repaclaraciones/";
	LET c_nombre_archivo				= "ACL_CIERRE_MASIVOS_AFEC";
	LET c_ext_archivo					= ".csv";
	LET v_nombre_archivo				= NULL;
	LET v_folio_csuac					= '';
	LET v_dictamen 						= '';
	LET v_bitacora  					= '';
	LET v_importeprocedente 			= '';
	LET v_dias_conclucion 				= '';
	LET v_pky_aclaracion 				= '';
	LET iContador 						= 0;
	LET v_temp_table 					= '';
	LET v_mensaje 						= 'Procesado Correctamente';
	LET v_procede  						= '';
	LET vcodresolucion  				= '';
	LET v_procedente 					= NULL;
	LET v_num_proceso 					= NULL;
	LET v_afectacion  					= '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SET DEBUG FILE TO "/resplogifx/Dann/sp_cierre masivos_afectacion.out";
	TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret;
				
			END IF;
		END EXCEPTION;
	on exception in (-668)
        LET v_cod_ret = '00001';
		RETURN v_cod_ret;
    end exception with resume;	
	--ON EXCEPTION IN (-535)
	--		  --ROLLBACK WORK;
	--COMMIT WORK;
	--			--SET ISOLATION TO DIRTY READ;
	--		  --BEGIN WORK;
	--END EXCEPTION WITH RESUME;

		
		
		SELECT tabid
		INTO v_temp_table
		FROM systables WHERE tabname ='tabla_cierre_preventivo_afectac';
		
		IF v_temp_table IS NOT NULL THEN
			DROP TABLE "informix".tabla_cierre_preventivo_afectac;
		END IF;
		
		SELECT fecha_hoy 
			INTO c_fecha_actual
		FROM bdinteg:si_fechas;
		
		LET v_nombre_archivo = c_nombre_archivo||'_'|| LPAD(day(c_fecha_actual), 2, '0')|| LPAD(month(c_fecha_actual), 2, '0') || year(c_fecha_actual)|| c_ext_archivo;
		
		
		--CREATE TEMP TABLE tabla_pbas(
		CREATE TABLE "informix".tabla_cierre_preventivo_afectac( 
			folio_csuac            	VARCHAR(11) ,
			bitacora				LVARCHAR,
			procedente				VARCHAR(2),
			codigo_resolucion		varchar(2),
			dictamen        		LVARCHAR,
			afectacion 			CHAR(1)
		);
		
		-- Se crea cadana con la ruta donde se encuentra el archivo
		LET cCadena = '';
		LET cCadena = ' echo "FILE /resplogifx/repaclaraciones/'||v_nombre_archivo||' DELIMITER '|| "'" || ',' || "'" || ' 6;' || '">/resplogifx/repaclaraciones/aclaracion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = ' echo "INSERT INTO "informix".tabla_cierre_preventivo_afectac;' || '">> /resplogifx/repaclaraciones/aclaracion.sql';
		SYSTEM cCadena;
		
		LET cCadena = '';
		LET cCadena = 'chmod 777 /resplogifx/repaclaraciones/aclaracion.sql';
		SYSTEM cCadena;
		
		--Cargamos la informacion en la tabla de control
		LET cCadena = "";
		LET cCadena = 'dbload -d bdiaclaracion -c /resplogifx/repaclaraciones/aclaracion.sql -l /resplogifx/repaclaraciones/aclaracion.log -n 1000 -k';
		SYSTEM cCadena;
		-----Se elimina script de ruta
		LET vsql = "";
		system vsql; 
		let vsql ='rm  /resplogifx/repaclaraciones/aclaracion.sql';
		system vsql; 
		---Se elimina archivo procedado de Ruta
		LET vsql = "";
		system vsql; 
		let vsql ='rm  /resplogifx/repaclaraciones/'||v_nombre_archivo||'';
		system vsql; 

	--------------------------------------------------
    -------------------------------------------------	
	--BEGIN WORK;	
	
		SELECT MAX(num_proceso)
			INTO v_num_proceso
		FROM acl_cierre_masivo;
		
		IF v_num_proceso IS NULL THEN
			LET v_num_proceso = 1;
		ELSE
			LET v_num_proceso = v_num_proceso + 1;
		END IF;
		

	
	FOREACH WITH HOLD
			
		SELECT folio_csuac, dictamen, bitacora,procedente,codigo_resolucion , afectacion
			INTO v_folio_csuac, v_dictamen,v_bitacora, v_procede, vcodresolucion, v_afectacion
		FROM "informix".tabla_cierre_preventivo_afectac
		
			ON EXCEPTION IN (-255)
			
			
					--ROLLBACK WORK;
				CONTINUE FOREACH;
						--SET ISOLATION TO DIRTY READ;
					--BEGIN WORK;
			END EXCEPTION WITH RESUME;
		
		
		IF v_procede = '1' THEN
				LET v_procedente = 1;
			ELIF v_procede = '0' THEN
				LET v_procedente = 0;
			END IF;
		
		SELECT pky_tipo_codigo_resolucion 
			INTO v_resolucion
		FROM acl_tipo_codigo_resolucion 
			WHERE  pky_tipo_codigo_resolucion = trim(vcodresolucion) AND tipo_procedente = v_procedente;
		
		IF (v_folio_csuac IS NULL OR v_folio_csuac = '') THEN
			CONTINUE FOREACH;
		ELIF (v_dictamen IS NULL OR v_dictamen = '') THEN 
			CONTINUE FOREACH;
		ELIF (v_bitacora IS NULL OR v_bitacora = '') THEN
			CONTINUE FOREACH;
		ELIF (v_procedente IS NULL OR v_procedente = '') THEN
			CONTINUE FOREACH;
		ELIF (v_resolucion IS NULL OR v_resolucion = '') THEN
			CONTINUE FOREACH;
		ELSE 
	----para aclaraciones procedentes
			IF v_folio_csuac is not null THEN
					CALL "informix".sp_aplica_cierre_masivo(v_folio_csuac,v_procedente,  vcodresolucion, 1, '330646', v_dictamen, v_num_proceso, v_afectacion )
					RETURNING v_cod_ret, vFolioCsuac, vResultado;
			END IF;
   
	
    ----- se inserta en bitacora el comentario correspondiente al cierre masivo
			select pky_aclaracion, fky_estatus_aclaracion, fky_estatus_corp_general into v_pky_aclaracion, v_estatus_aclaracion, v_estatus_general
			from "informix".acl_aclaracion where folio_csuac = v_folio_csuac;
	--	
			IF v_pky_aclaracion IS NOT NULL THEN
	
				INSERT INTO "informix".acl_entrada_bitacora(pky_entrada_bitacora, descripcion, fechahora, folio_csuac, fky_accion, fky_aclaracion, fky_area, fky_estatus_aclaracion, fky_estatus_corp_analisis, fky_estatus_corp_general, fky_usuario) 
					VALUES(ENTRADA_BITACORA_SEQ.nextval, v_bitacora, CURRENT,v_folio_csuac, 26,v_pky_aclaracion, null,v_estatus_aclaracion, null, v_estatus_general, 1);
			END IF;
		
				IF (v_cod_ret is not null) THEN
					COMMIT WORK;
					
				END IF;
		
	END IF;
	END FOREACH;
	
	LET v_cod_ret = '00000';
	
----------------------------
----------------------------	
	RETURN v_cod_ret;
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'Analista    	:	Rey David Zavala Garcia',
'FECHA			: 	21/05/2020',
'Requerimiento	:	RQI 65 335',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';


