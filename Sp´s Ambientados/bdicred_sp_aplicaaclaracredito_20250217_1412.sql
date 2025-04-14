DROP PROCEDURE IF EXISTS "informix".sp_aplicaaclaracredito(CHAR(3), CHAR(10), CHAR(2), CHAR(1), CHAR (8));


CREATE PROCEDURE "informix".sp_aplicaaclaracredito(pEmpresa CHAR(3), pFolioSuac CHAR(10), pDictamen CHAR(2), pCalculaInteres CHAR(1), pEmpleadoAut CHAR (8))
RETURNING CHAR(3);

    DEFINE cCodRet              CHAR(3);
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;

    DEFINE CnumCredito          CHAR(20);
    DEFINE CnumTarjeta          CHAR(20);
    DEFINE CmontoAcla           DECIMAL(18,2);
    DEFINE Csucursal            CHAR(4);
    DEFINE pfecha               DATE;
    DEFINE pfechaAux            DATE;
    DEFINE pfechaMov            DATE;
    DEFINE pfechaAcl            DATE;
    DEFINE pIntDev              DECIMAL(18,2);
    DEFINE pIntVig              DECIMAL(18,2);
    DEFINE pIntVenc             DECIMAL(18,2);
    DEFINE pIntCalc             DECIMAL(18,2);
    DEFINE pTasaInt             DECIMAL(18,2);
    DEFINE pIntBoni             DECIMAL(18,2);
    DEFINE pIvaBoni             DECIMAL(18,2);
    DEFINE DiasCalc             SMALLINT;
    DEFINE DiasPeri             SMALLINT;
    DEFINE pIntCap              DECIMAL(18,2);
    DEFINE pIvaCap              DECIMAL(18,2);
    DEFINE CCodret_c            CHAR(5);
    DEFINE CMensaje             CHAR(80);
    DEFINE CSecuencia           INTEGER;
    DEFINE Ctrannopro           CHAR(04);
    DEFINE Ctransinauto         CHAR(04);
    DEFINE Ctranpro             CHAR(04);
    DEFINE Ctranauto            CHAR(04);
    DEFINE Ccargo               SMALLINT;
    DEFINE ptranaplica          CHAR(04);
    DEFINE Ctrans_no_procede    CHAR(04);
    DEFINE Mcosto               DECIMAL(18,2);
    DEFINE Ifky_aclaracion      INTEGER;
    DEFINE Ifky_producto        INTEGER;
    DEFINE Ipky_tipo_movimiento INTEGER;
    DEFINE wBegin               CHAR(1);
    DEFINE Ipky_movimiento      INTEGER;
    DEFINE v_contador           SMALLINT;
    DEFINE pFolioSuacSUC        CHAR(16);
    DEFINE v_fecha_folio        CHAR(10);
	DEFINE CSecuencia_acl_mov   INTEGER;
	DEFINE fecha_captura		DATE;

    DEFINE v_numero_transaccion CHAR(04);
	DEFINE Es_Nacional			CHAR(1);
	DEFINE v_nombre_origen 		CHAR(50);
	DEFINE v_OrigenEvento		CHAR(2);
	DEFINE v_NumTarjeta			CHAR(20);
	DEFINE v_FolioSuc			CHAR(20);

--> Variables para duplicidad de movimientos
	DEFINE v_fky_padre          INTEGER;
	DEFINE v_monto				DECIMAL(18,2);
	DEFINE v_montoprocedente    DECIMAL(18,2);
	DEFINE v_fky_tipo_evento    INTEGER;
	DEFINE v_duplicado          SMALLINT;

--> Variable para control de movimientos a afectar
	DEFINE v_tipo_fky_padre     INTEGER;

	DEFINE v_contador_1			INTEGER;
	DEFINE v_contador_2			INTEGER;
	DEFINE v_contador_total		INTEGER;
	
--> Variables tabla de control
	DEFINE max_control_afect_cred INTEGER;
	
--> Variable para almacenar nombre de un SP || JLM - 02/06/2022	
	DEFINE v_nombre_sp            CHAR(20);
	DEFINE horaActual             DATETIME YEAR TO FRACTION(5);
	
	---VARIABLES TDC
	DEFINE v_tipo_producto   CHAR(4);
    DEFINE v_descripcion_pro VARCHAR(255);
	
	--VARIABLES PARA EL RQM 06 919 ABONO INMEDIATO
	DEFINE abono_inmediato				CHAR(2);
	DEFINE dfa						    CHAR(1);
	DEFINE devolucion					CHAR(1);
	

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,CMensaje
      LET cCodRet = sql_err;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;

      RETURN cCodRet;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      --ROLLBACK WORK;
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

   --	SET DEBUG FILE TO "/resplogifx/Rey_David/extra/sp_aplicacredito.out";
   --TRACE ON;
   LET cCodRet      		= '000';
   LET pfechaMov    		= DATE(1);
   LET pfechaAcl    		= DATE(1);
   LET pfechaAux    		= DATE(1);
   LET pfecha       		= DATE(1);
   LET CnumCredito  		= '';
   LET CnumTarjeta  		= '';
   LET CmontoAcla   		= 0;
   LET Csucursal    		= '';
   LET pIntVig      		= 0;
   LET pIntVenc     		= 0;
   LET DiasPeri     		= 0;
   LET pIntBoni     		= 0;
   LET pIntCap      		= 0;
   LET pIvaCap      		= 0;
   LET CCodret_c    		= '';
   LET CMensaje     		= '';
   LET CSecuencia   		= 0;
   LET Ctrannopro   		= '';
   LET Ctransinauto 		= '';
   LET Ctranpro     		= '';
   LET Ctranauto    		= '';
   LET Ccargo       		= 0;
   LET ptranaplica  		= '0000';
   LET Ctrans_no_procede 	= '';
   LET Mcosto       		= 0;
   LET Ifky_aclaracion 		= 0;
   LET Ifky_producto 		= 0;
   LET Ipky_tipo_movimiento = 0;
   LET wBegin 				= 'N';
   LET Ipky_movimiento 		= 0;
   LET v_contador 			= 0;
   LET pFolioSuacSUC 		= '';
   LET v_fecha_folio 		= "";
   LET CSecuencia_acl_mov   = 0;
   LET fecha_captura		=DATE(1);

   LET v_numero_transaccion = '';
   LET Es_Nacional			= '';
   LET v_nombre_origen 		= '';
   LET v_OrigenEvento		= '';
   LET v_NumTarjeta			= '';
   LET v_FolioSuc			= '';

--> Variables para duplicidad de movimientos
   LET v_fky_padre       = 0;
   LET v_monto           = 0;
   LET v_montoprocedente = 0;
   LEt v_fky_tipo_evento = 0;
   LET v_duplicado 	     = 0;
   LET v_contador_1		 = 0;
   LET v_contador_2		 = 0;
   LET v_contador_total	 = 0;

--> Variable para control de movimientos a afectar
   LET v_tipo_fky_padre  = 0;
--> Variables tabla de control
   LET max_control_afect_cred = 0;
   
--> Variable para almacenar nombre de un SP || JLM - 02/06/2022   
   LET v_nombre_sp       = '';
   LET horaActual        = NULL;
   LET v_tipo_producto   = NULL;
   LET v_descripcion_pro = '';
   
   --VARIABLES PARA EL RQM 06 919 ABONO INMEDIATO
	LET abono_inmediato					='';
	LET dfa						   	 	='';
	LET devolucion						='';
   
   
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Actualizaciones
   -- 15/01/2013 sp_aplicaaclaracredito V6 	-> Modificación afectaciones lógica movimientos duplicados
   --										-> Flujos adicionales a seguir
   -- 										-> Validaciones para que no cargue movimientos sin previamente abonados
   -- 										-> Validación de flujo AA para cargo de comisión, iva de comisión y si es el caso el monto previamente abonado.
   -- 										-> Agregar validación para cargos
-- 03/04/2013 sp_aplicaaclaracredito V7 	-> Modificación envío de num_empleado que autoriza las afectaciones Entrega III, CNBV

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar debug
   --SET DEBUG FILE TO "/resplogifx/repaclaraciones/sp_aplicaaclaracredito"||"_"||""||pFolioSuac||""||"_v13_"||""||pDictamen||".out";
    --SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_aplicaaclaracredito_usr"||pFolioSuac||pDictamen||"_35"||".out";
    --TRACE ON;

	SET DEBUG FILE TO "/resplogifx/Dann/sp_aplicaaclaracredito.out";
	TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   BEGIN WORK;

   
   -- APLICA VALIDACI�N DE COPPEL TDC
	
		SELECT tp.producto, tp.descripcion INTO v_tipo_producto, v_descripcion_pro FROM bdiaclaracion:acl_aclaracion acl
		inner join bdiaclaracion:acl_producto p on acl.fky_producto = p.pky_producto
		inner join bdiaclaracion:acl_tipo_producto tp on p.fky_tipo_producto = tp.pky_tipo_producto
		where acl.folio_csuac = pFolioSuac;
   
			
		IF pFolioSuac IS NULL OR pFolioSuac='' THEN
			LET cCodRet='001';
			RETURN cCodRet;
		END IF;
		
-- 		  IF pNaturaleza IS NULL OR pNaturaleza='' THEN
-- 		     LET cCodRet='006';
-- 		     RETURN cCodRet;
-- 		  END IF;
		
		IF pDictamen IS NULL OR pDictamen='' THEN
			LET cCodRet='007';
			RETURN cCodRet;
		END IF;
		
		IF pCalculaInteres IS NULL OR pCalculaInteres='' THEN
			LET cCodRet='008';
			RETURN cCodRet;
		END IF;
		
			SELECT valor INTO DiasCalc
			FROM sd_param
			WHERE empresa = pEmpresa
			AND cod_param = "24"; -- Dias Para Calculo de Intereses
		
			SELECT fecha_hoy
			INTO pfecha
			FROM bdicred:sd_fechas
			WHERE empresa = pEmpresa;
		
		----SE INTEGRA VALIDACIÓN PARA EL RQM 06 919 ABONO INMEDIATO-----
		--Se obtiene banderas para validar si es un flujo de abono inmediato
		SELECT ev.acepta_dfa, ev.acepta_devolucion  
		INTO dfa, devolucion
		FROM bdiaclaracion:acl_aclaracion acl 
		INNER JOIN bdiaclaracion:acl_tipo_evento ev ON acl.fky_tipo_evento = ev.pky_tipo_evento
		WHERE acl.folio_csuac = pFolioSuac;
		
		--Valida que los campos de DFA o Devolución se encuentren encendidos
		IF (dfa = 1) THEN 
			LET abono_inmediato = 1;
		ELIF (devolucion = 1) THEN 
			LET abono_inmediato = 1;
		END IF; --fin de validación banderas DFA y Devolución
		
		-- APLICA VALIDACIÓN DE COPPEL TDC
			
		IF v_tipo_producto <> '6500' THEN
		
			IF (pDictamen = 'NP') THEN
		
---		---------------------------------------------- >> Validación para creación de movimientos duplicados.
				SELECT fky_padre
				INTO v_fky_padre
				FROM bdiaclaracion:acl_movimiento
				WHERE duplicado = 1
				AND folio_csuac = pFolioSuac;
		
				IF (v_fky_padre IS NULL) THEN
		
				IF (pCalculaInteres='0') THEN
					FOREACH WITH hold
						-- >> Insertar movimientos duplicados.
						SELECT a.folio_csuac, a.monto, a.montoprocedente, b.trans_no_procede, a.fky_padre, a.fky_producto, a.fky_tipo_evento, a.fky_tipo_movimiento
						INTO
						pFolioSuac,          -- folio_csuac,  	   			--> Mismo que el padre -- ok
						v_monto,             -- monto, 						--> Mismo que el padre -- para afectación contable
						v_montoprocedente,   -- montoprocedente, 			--> Mismo que el padre -- Breviario cultural
						Ctrans_no_procede,   -- numero_transaccion, 		--> null -- Tran_no_procede para que haga la afectación con esa transacción.
						Ipky_movimiento,     -- fky_padre,	 				--> pky del movimiento padre
						Ifky_producto,       -- fky_producto, 				--> Mismo que el padre
						v_fky_tipo_evento,   -- fky_tipo_evento, 			--> Mismo que el padre
						Ipky_tipo_movimiento -- fky_tipo_movimiento, 		--> Mismo que el padre
						FROM bdiaclaracion:acl_movimiento a, bdiaclaracion:acl_tipo_movimiento b
						WHERE b.pky_tipo_movimiento = a.fky_tipo_movimiento
						AND a.folio_csuac = pFolioSuac
						AND a.cargo = 0
						AND a.exitoso = 1
						-- AND a.procede = 1
						AND a.fecha_afectacion IS NOT NULL
						AND a.duplicado = 0
					--	AND a.fky_tipo_movimiento <> 340 --> Validaci�??�?³n no duplicar intereses abonados
		
						SELECT MAX (secuencia)
						INTO CSecuencia_acl_mov
						FROM bdiaclaracion:acl_movimiento
						WHERE folio_csuac = pFolioSuac;
		
						SELECT duplicado
						INTO v_duplicado
						FROM bdiaclaracion:acl_movimiento a
						WHERE folio_csuac = pFolioSuac
						AND a.duplicado = 1
						AND monto = v_monto;
		
						IF (v_duplicado IS NULL) THEN
		
						INSERT INTO bdiaclaracion:acl_movimiento VALUES (
						-- pky_movimiento                             calculado     cargo  	cargo_ajuste   exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia        referencia23             reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio                              num_sucursal , recuperacion, montorecuperacion
						bdiaclaracion:MOVIMIENTO_SEQ.nextval,     0,            1,        	null,		0,          null,                    null,                  current,                pFolioSuac,     null,             null,                         null,      null,      v_monto,  v_montoprocedente,  1,            Ctrans_no_procede,     1,          '',               '',                      0,            CSecuencia_acl_mov, null,              Ipky_movimiento, Ifky_producto,   null,                      v_fky_tipo_evento,  Ipky_tipo_movimiento,   null,                             null,                                     "9250", null, 0, 0);
						-- VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0, 1, 0, null, null, current, pFolioSuac, null, null, null, null, Mcosto, Mcosto, 0,Ctrans_no_procede, 1, '', '', 0, CSecuencia_acl_mov, null, Ipky_movimiento, Ifky_producto, null, 1, Ipky_tipo_movimiento, null, null, "9250");
		
						END IF;
		
					END FOREACH;
		
				END IF; -- Calculo de interes = 0
		
				IF (pCalculaInteres='1') THEN
							FOREACH WITH hold
						-- >> Insertar movimientos duplicados.
						SELECT a.folio_csuac, a.monto, a.montoprocedente, b.trans_no_procede, a.fky_padre, a.fky_producto, a.fky_tipo_evento, a.fky_tipo_movimiento
		
						INTO
						pFolioSuac,          -- folio_csuac,  	   			--> Mismo que el padre -- ok
						v_monto,             -- monto, 						--> Mismo que el padre -- para afectaci�??�?³n contable
						v_montoprocedente,   -- montoprocedente, 			--> Mismo que el padre -- Breviario cultural
						Ctrans_no_procede,   -- numero_transaccion, 		--> null -- Tran_no_procede para que haga la afectaci�??�?³n con esa transacci�??�?³n.
						Ipky_movimiento,     -- fky_padre,	 				--> pky del movimiento padre
						Ifky_producto,       -- fky_producto, 				--> Mismo que el padre
						v_fky_tipo_evento,   -- fky_tipo_evento, 			--> Mismo que el padre
						Ipky_tipo_movimiento -- fky_tipo_movimiento, 		--> Mismo que el padre
		
						FROM bdiaclaracion:acl_movimiento a, bdiaclaracion:acl_tipo_movimiento b
						WHERE b.pky_tipo_movimiento = a.fky_tipo_movimiento
						AND a.folio_csuac = pFolioSuac
						AND a.cargo = 0
						AND a.exitoso = 1
						-- AND a.procede = 1
						AND a.fecha_afectacion IS NOT NULL
						AND a.duplicado = 0
						--AND a.fky_tipo_movimiento <> 340 --> Validaci�??�?³n no duplicar intereses abonados
		
						SELECT MAX (secuencia)
						INTO CSecuencia_acl_mov
						FROM bdiaclaracion:acl_movimiento
						WHERE folio_csuac = pFolioSuac;
		
						SELECT duplicado
						INTO v_duplicado
						FROM bdiaclaracion:acl_movimiento a
		
						WHERE folio_csuac = pFolioSuac
						AND a.duplicado = 1
						AND monto = v_monto;
		
						IF (v_duplicado IS NULL) THEN
		
							INSERT INTO bdiaclaracion:acl_movimiento VALUES (
							-- pky_movimiento                         calculado     cargo     cargo_ajuste	exitoso     fecha_afectacion     fecha_hora_e_global     fechahora     folio_csuac     folio_suc     identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia        referencia23             reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio     num_sucursal
							bdiaclaracion:MOVIMIENTO_SEQ.nextval,     0,            1,        null,			0,          null,                null,                   current,      pFolioSuac,     null,         null,                         null,      null,      v_monto,  v_montoprocedente,  1,            Ctrans_no_procede,     1,          '',               '',                      0,            CSecuencia_acl_mov, null,              Ipky_movimiento, Ifky_producto,   null,                      v_fky_tipo_evento,  Ipky_tipo_movimiento,   null,                             null,            "9250", null,0,0);
		
						END IF;
		
					END FOREACH;
				END IF; -- Calculo de interes 1
		
				END IF;
		
				--------- >> Determina si el movimiento es Nacional o Internacional
		
				SELECT tipo_movimiento INTO Es_Nacional
				FROM bdiaclaracion:acl_aclaracion WHERE folio_csuac = pFolioSuac;
				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional ='N') THEN --Deshabilitar cuando se utilice completamente el campo tipo_movimiento de acl_aclaracion
					SELECT te.fky_origen_evento, p.numero_tarjeta
						INTO v_OrigenEvento, v_NumTarjeta
						FROM bdiaclaracion:acl_aclaracion acl
						INNER JOIN bdiaclaracion:acl_tipo_evento te on te.pky_tipo_evento = acl.fky_tipo_evento
						INNER JOIN bdiaclaracion:acl_producto p on p.pky_producto = acl.fky_producto
						WHERE acl.folio_csuac = pFolioSuac;
		
					SELECT LIMIT 1 SUBSTR(bdiaclaracion:acl_movimiento.folio_suc,2)
						INTO v_FolioSuc
						FROM bdiaclaracion:acl_movimiento
						WHERE bdiaclaracion:acl_movimiento.folio_csuac=pFolioSuac;
		
					SELECT nombre INTO v_nombre_origen
						FROM bdiaclaracion:acl_origen_evento WHERE pky_origen_evento = v_OrigenEvento;
		
					--IF v_OrigenEvento = '2' or v_OrigenEvento = '3' or v_OrigenEvento = '6' or v_OrigenEvento = '7' Then
					IF v_nombre_origen = 'POS' or v_nombre_origen = 'ATMS' Then
						SELECT intercard:movimiento.esnacional
							INTO Es_Nacional
							FROM intercard:movimiento
							WHERE intercard:movimiento.secuenciaextendida=v_FolioSuc
							AND intercard:movimiento.numtarjeta=v_NumTarjeta;
		
						IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
							SELECT intercard:movimientohistorico.esnacional
								INTO Es_Nacional
								FROM intercard:movimientohistorico
								WHERE intercard:movimientohistorico.secuenciaextendida=v_FolioSuc
								AND intercard:movimientohistorico.numtarjeta=v_NumTarjeta;
		
								IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
									UPDATE bdiaclaracion:acl_aclaracion SET tipo_movimiento = 'V' WHERE folio_csuac=pFolioSuac;
								ELSE
									UPDATE bdiaclaracion:acl_aclaracion SET tipo_movimiento = Es_Nacional WHERE folio_csuac=pFolioSuac;
								END IF;
						END IF;
					ELSE
						LET Es_Nacional = 'V';
					END IF;
				END IF;
		
				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
					LET Es_Nacional = 'V';
				END IF;
		
				-------------- >> Inserta movimiento de comisión por Aclaacion no procedente
				-- >> Se inactiva para evitar el cobro de comisión e iva en créditos 09/09/2011
				-- >> Se activa para realizar el cobro de comisión e iva en créditos 13/02/2011
			--SET ISOLATION TO DIRTY READ;
			SELECT d.trans_no_procede,
					CASE
						WHEN Es_Nacional = 'F' THEN 0
						WHEN Es_Nacional = 'V' THEN nvl(e.costo,0)
					END AS costo, a.fky_aclaracion, a.fky_producto, d.pky_tipo_movimiento, a.pky_movimiento
				INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
				FROM bdiaclaracion:acl_movimiento a,
					bdiaclaracion:acl_tipo_evento b,
					bdiaclaracion:acl_origen_evento c,
					bdiaclaracion:acl_tipo_movimiento d,
					bdiaclaracion:acl_costo_aclaracion e
				WHERE b.pky_tipo_evento = a.fky_tipo_evento
				AND c.pky_origen_evento = b.fky_origen_evento
				AND c.pky_origen_evento = d.fky_origen_evento
				AND c.pky_origen_evento = e.fky_origen_evento
				AND a.fky_padre IS NULL
				AND d.fky_tipo_transaccion = 12
				-- AND a.cargo IS NOT NULL
				AND NVL(cargo,0) = CASE WHEN (exitoso is null) THEN 0 ELSE cargo END
				AND duplicado = 0
				AND folio_csuac = pFolioSuac;
		
				IF	(Ipky_tipo_movimiento is null OR Ipky_tipo_movimiento='') THEN  -- Determinar la comisión desde tabla acl_tipo_Evento
				/* Se elimina referencia a tabla acl_tipo_movimiento, transacción de no procedencia es fija y se define una trasacción fija para comisiones de
				no procedencia, esto para no tener que repetir por cada uno de los Eventos creados, ya que las comisiones ahora son por evento RQM 06 315*/
				SELECT '5212',
					CASE
						WHEN Es_Nacional = 'F' THEN 0
						WHEN Es_Nacional = 'V' THEN nvl(b.costo,0)
					END AS costo,
					a.fky_aclaracion, a.fky_producto, '143', a.pky_movimiento
				INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
				FROM bdiaclaracion:acl_movimiento a,
					bdiaclaracion:acl_tipo_evento b,
					bdiaclaracion:acl_origen_evento c
				WHERE b.pky_tipo_evento = a.fky_tipo_evento
				AND c.pky_origen_evento = b.fky_origen_evento
				AND a.fky_padre IS NULL
				AND NVL(cargo,0) = CASE WHEN (exitoso is null) THEN 0 ELSE cargo END
				AND duplicado = 0
				AND folio_csuac = pFolioSuac;
		
				END IF;  -- comisión desde acl_tipo_evento
		
				--SET ISOLATION TO DIRTY READ;
				SELECT MAX (numero_transaccion)
				INTO v_numero_transaccion
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac
				AND numero_transaccion = Ctrans_no_procede;
		
				--SET ISOLATION TO DIRTY READ;
				SELECT MAX (secuencia)
				INTO CSecuencia_acl_mov
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac;
		
				UPDATE bdiaclaracion:acl_movimiento -->> Valida que no existan movimientos como procedentes de forma erronea para que no sean cargados al cliente.
				SET procede = 0
				WHERE folio_csuac = pFolioSuac
				AND cargo = 0
				AND (exitoso = 0 OR exitoso IS NULL);
		
				IF ( v_numero_transaccion IS NULL) THEN  -->> Valida si ya se ingreso la comisi�??�?³n de cr�??�?©dito, para no duplicarla 24/04/2012
					If Mcosto = '0' Then
						INSERT INTO bdiaclaracion:acl_movimiento
						-- pky_movimiento                            calculado     cargo     cargo_ajuste	exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia    referencia23    reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio   num_sucursal  , recuperaciom, monto_recuperacion
						VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0,            1,        null,			0,          null,                   null,                   current,                pFolioSuac,     null,             null,                         null,      null,      Mcosto,   Mcosto,             0,            Ctrans_no_procede,     0,          '',           '',             0,            CSecuencia_acl_mov,  null,             Ipky_movimiento, Ifky_producto,   null,                      1,                  Ipky_tipo_movimiento,   null,                             null,          "9250", null,0, 0);
					Else
						INSERT INTO bdiaclaracion:acl_movimiento
																		--cargo por ajuste
						VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0, 1, null, 0, null, null, current, pFolioSuac, null, null, null, null, Mcosto, Mcosto, 0,Ctrans_no_procede, 1, '', '', 0, CSecuencia_acl_mov, null, Ipky_movimiento, Ifky_producto, null, 1, Ipky_tipo_movimiento, null, null, "9250", null, 0, 0);
					End If;
				END IF;
		
		
			END IF;
---		----------*******************************************************************************************************************************************
		
-->		> Flujo de aclaraciones: Analizar, No Procede = Sin Afectaci�??�?³n  --> Solo cobro de comision
		
			IF (pDictamen = 'CM') THEN
				--SET ISOLATION TO DIRTY READ;
		
				--------- >> Determina si el movimiento es Nacional o Internacional
				SELECT tipo_movimiento INTO Es_Nacional
				FROM bdiaclaracion:acl_aclaracion WHERE folio_csuac = pFolioSuac;
				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN --Deshabilitar cuando se utilice completamente el campo tipo_movimiento de acl_aclaracion
					SELECT te.fky_origen_evento, p.numero_tarjeta
						INTO v_OrigenEvento, v_NumTarjeta
						FROM bdiaclaracion:acl_aclaracion acl
						INNER JOIN bdiaclaracion:acl_tipo_evento te on te.pky_tipo_evento = acl.fky_tipo_evento
						INNER JOIN bdiaclaracion:acl_producto p on p.pky_producto = acl.fky_producto
						WHERE acl.folio_csuac = pFolioSuac;
		
					SELECT LIMIT 1 SUBSTR(bdiaclaracion:acl_movimiento.folio_suc,2)
						INTO v_FolioSuc
						FROM bdiaclaracion:acl_movimiento
						WHERE bdiaclaracion:acl_movimiento.folio_csuac=pFolioSuac;
		
					SELECT nombre INTO v_nombre_origen
						FROM bdiaclaracion:acl_origen_evento WHERE pky_origen_evento = v_OrigenEvento;
		
					--IF v_OrigenEvento = '2' or v_OrigenEvento = '3' or v_OrigenEvento = '6' or v_OrigenEvento = '7' Then
					IF v_nombre_origen = 'POS' or v_nombre_origen = 'ATMS' Then
						SELECT intercard:movimiento.esnacional
							INTO Es_Nacional
							FROM intercard:movimiento
							WHERE intercard:movimiento.secuenciaextendida=v_FolioSuc
							AND intercard:movimiento.numtarjeta=v_NumTarjeta;
		
						IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
							SELECT intercard:movimientohistorico.esnacional
								INTO Es_Nacional
								FROM intercard:movimientohistorico
								WHERE intercard:movimientohistorico.secuenciaextendida=v_FolioSuc
								AND intercard:movimientohistorico.numtarjeta=v_NumTarjeta;
		
								IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
									UPDATE bdiaclaracion:acl_aclaracion SET tipo_movimiento = 'V' WHERE folio_csuac=pFolioSuac;
									LET Es_Nacional = 'V';
								ELSE
									UPDATE bdiaclaracion:acl_aclaracion SET tipo_movimiento = Es_Nacional WHERE folio_csuac=pFolioSuac;
								END IF;
						END IF;
					ELSE
						LET Es_Nacional = 'V';
					END IF;
				END IF;
		
		
				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
					LET Es_Nacional = 'V';
				END IF;
		
			SELECT d.trans_no_procede,
					CASE
						WHEN Es_Nacional = 'F' THEN 0
						WHEN Es_Nacional = 'V' THEN nvl(e.costo,0)
					END AS costo, a.fky_aclaracion, a.fky_producto, d.pky_tipo_movimiento, a.pky_movimiento
				INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
				FROM bdiaclaracion:acl_movimiento a,
					bdiaclaracion:acl_tipo_evento b,
					bdiaclaracion:acl_origen_evento c,
					bdiaclaracion:acl_tipo_movimiento d,
					bdiaclaracion:acl_costo_aclaracion e
				WHERE b.pky_tipo_evento = a.fky_tipo_evento
				AND c.pky_origen_evento = b.fky_origen_evento
				AND c.pky_origen_evento = d.fky_origen_evento
				AND c.pky_origen_evento = e.fky_origen_evento
				AND a.fky_padre is null
				AND d.fky_tipo_transaccion = 12
				AND a.cargo is  null  -- is not null
				AND folio_csuac = pFolioSuac;
		
				IF	(Ipky_tipo_movimiento is null OR Ipky_tipo_movimiento='') THEN  -- Determinar la comisión desde tabla acl_tipo_Evento
				/* Se elimina referencia a tabla acl_tipo_movimiento, transacción de no procedencia es fija y se define una trasacción fija para comisiones de
				no procedencia, esto para no tener que repetir por cada uno de los Eventos creados, ya que las comisiones ahora son por evento RQM 06 315*/
				SELECT '5212',
					CASE
						WHEN Es_Nacional = 'F' THEN 0
						WHEN Es_Nacional = 'V' THEN nvl(b.costo,0)
					END AS costo,
					a.fky_aclaracion, a.fky_producto, '143', a.pky_movimiento
				INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
				FROM bdiaclaracion:acl_movimiento a,
					bdiaclaracion:acl_tipo_evento b,
					bdiaclaracion:acl_origen_evento c
				WHERE b.pky_tipo_evento = a.fky_tipo_evento
				AND c.pky_origen_evento = b.fky_origen_evento
				AND a.fky_padre IS NULL
				AND NVL(cargo,0) = CASE WHEN (exitoso is null) THEN 0 ELSE cargo END
				AND duplicado = 0
				AND folio_csuac = pFolioSuac;
		
				END IF;  -- comisi�??�?³n desde acl_tipo_evento
		
		
				--SET ISOLATION TO DIRTY READ;
				SELECT MAX (numero_transaccion)
				INTO v_numero_transaccion
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac
				AND numero_transaccion = Ctrans_no_procede;
		
				--SET ISOLATION TO DIRTY READ;
				SELECT MAX (secuencia)
				INTO CSecuencia_acl_mov
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac;
		
				UPDATE bdiaclaracion:acl_movimiento -->> Valida que no existan movimientos como procedentes de forma erronea para que no sean cargados al cliente.
				SET procede = 0
				WHERE folio_csuac = pFolioSuac
				AND numero_transaccion IS NULL;
		
				IF ( v_numero_transaccion IS NULL) THEN  -->> Valida si ya se ingreso la comision de credito, para no duplicarla 24/04/2012
					If Mcosto = '0' Then
						INSERT INTO bdiaclaracion:acl_movimiento
						-- pky_movimiento                            calculado     cargo     cargo_ajuste	exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia    referencia23    reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio   num_sucursal, recuperacion, monto_recuperacion
						VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0,            1,        null,			0,          null,                   null,                   current,                pFolioSuac,     null,             null,                         null,      null,      Mcosto,   Mcosto,             0,            Ctrans_no_procede,     0,          '',           '',             0,            CSecuencia_acl_mov,  null,             Ipky_movimiento, Ifky_producto,   null,                      1,                  Ipky_tipo_movimiento,   null,                             null,          "9250", null, 0, 0);
					Else
						INSERT INTO bdiaclaracion:acl_movimiento
																		--cargo por ajuste
						VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0, 1, null, 0, null, null, current, pFolioSuac, null, null, null, null, Mcosto, Mcosto, 0,Ctrans_no_procede, 1, '', '', 0, CSecuencia_acl_mov, null, Ipky_movimiento, Ifky_producto, null, 1, Ipky_tipo_movimiento, null, null, "9250", null, 0, 0);
					End If;
				END IF;
		
				-- Redireccionar la BD para la secuencia
				-- UPDATE bdiaclaracion:acl_movimiento SET exitoso = 1, procede = 1 WHERE folio_csuac = pFolioSuac and numero_transaccion is null;
			END IF;
		
			IF (pDictamen = 'NP') THEN
		
				UPDATE bdiaclaracion:acl_movimiento
				SET procede = 0
				WHERE (
				(folio_csuac = pFolioSuac
				AND procede = 1
				AND cargo IS NULL
				AND fecha_afectacion IS NULL) 
				--Se anexa validación para abono inmediato
				OR (folio_csuac = pFolioSuac AND abono_inmediato = 1 AND procede IS NULL)
				);
		
			END IF;
			LET v_contador = 0;
		
			--SET ISOLATION TO DIRTY READ;
			SELECT fechacaptura
			into fecha_captura
			FROM bdiaclaracion:acl_aclaracion
			WHERE folio_csuac=pFolioSuac;
		
			FOREACH WITH hold
		
				SELECT pky_movimiento, numero_cuenta, numero_tarjeta, montoprocedente, trans_no_procede, trans_procede, trans_procede_automatico, trans_procede_sin_autorizacion, nvl(cargo,0)
				INTO CSecuencia, CnumCredito, CnumTarjeta, CmontoAcla, Ctrannopro, Ctranpro, Ctranauto, Ctransinauto,Ccargo
				FROM bdiaclaracion:acl_movimiento a
				LEFT OUTER JOIN bdiaclaracion:acl_producto b on (a.fky_producto = b.pky_producto)
				LEFT OUTER JOIN bdiaclaracion:acl_tipo_movimiento c on (a.fky_tipo_movimiento = c.pky_tipo_movimiento)
				WHERE folio_csuac = pFolioSuac
				AND (procede IS NULL OR procede = 1)
				AND (exitoso IS NULL OR exitoso <> '1')
				AND NVL(fky_padre,0) = CASE WHEN ( pDictamen IN ('AA','AS')) THEN 0 ELSE NVL(fky_padre,0) END
		
				IF CnumCredito IS NULL THEN
					LET cCodRet='003';
					ROLLBACK WORK;
					IF (wBegin = "S") THEN
						BEGIN WORK;
					END IF;
					RETURN cCodRet;
				END IF;
		
				IF CmontoAcla IS NULL or CmontoAcla = 0 THEN
					LET cCodRet='004';
					ROLLBACK WORK;
					IF (wBegin = "S") THEN
						BEGIN WORK;
					END IF;
					RETURN cCodRet;
				END IF;
		
				IF (CnumTarjeta is null) then
					let CnumTarjeta = '';
				END IF;
		
		
		
--f		alta definir la transaccion
--f		alta definir el centro de costos (sucursal)
		
				IF (pDictamen = 'PR') THEN --> transaccion procedente
					let ptranaplica = Ctranpro;
				elif (pDictamen = 'NP') THEN --> transaccion no procedente
					let ptranaplica = Ctrannopro;
				elif (pDictamen = 'CM') THEN --> transaccion no procedente sin afectación, soló comisión
					let ptranaplica = Ctrannopro;
				elif (pDictamen = 'AA') THEN --> transaccion abono automatico
					let ptranaplica = Ctranauto;
				elif (pDictamen = 'AS') THEN --> transaccion abono automatico sin autorizacion
					let ptranaplica = Ctransinauto;
				END IF;
		
				SELECT substr((current HOUR TO SECOND),1,2)||substr((current HOUR TO SECOND),4,2)|| LPAD(v_contador,2,0)
				INTO v_fecha_folio FROM bdicred:sd_fechas;
		
-- 		     let pFolioSuacSUC = pFolioSuacSUC||lpad(pFolioSuac,10,0);
				let pFolioSuacSUC = trim(v_fecha_folio)||lpad(pFolioSuac,10,0);
		
		
			--Validaci�??�?³n para no permitir abonos/cargos dobles del mismo folio a las cuentas 13/01/2015
		
				--SET ISOLATION TO DIRTY READ;
				SELECT count(*)
					INTO v_contador_1
				FROM bdicred:sd_movdia
				WHERE empresa=pEmpresa
					AND num_credito=CnumCredito
					AND monto=CmontoAcla
					AND substr(folio_suc,7)=pFolioSuac
					AND transacc_suc=ptranaplica;
		
				--SET ISOLATION TO DIRTY READ;
				SELECT fechacaptura
					into fecha_captura
				FROM bdiaclaracion:acl_aclaracion
				WHERE folio_csuac=pFolioSuac;
		
				--SET ISOLATION TO DIRTY READ;
				SELECT count(*)
					INTO v_contador_2
				FROM bdicred:sd_movhis
				WHERE  num_credito=CnumCredito
					AND fecha_mov>=fecha_captura
					AND empresa=pEmpresa
					AND monto=CmontoAcla
					AND substr(folio_suc,7)=pFolioSuac
					AND transacc_suc=ptranaplica;
		
					LET v_contador_total = v_contador_1 + v_contador_2;
					
					
				--> Asignamos valor a "v_nombre_sp" y obtenemos dateTime del sistema JLM - 02/06/2022
				LET v_nombre_sp ='sp_cargo_abono_aclara';
				SELECT DBINFO("utc_to_datetime", sh_curtime)
					INTO horaActual
				FROM sysmaster:sysshmvals;
				-->
		
					IF (v_contador_total = 0 ) THEN
		
						call sp_cargo_abono_aclara(pEmpresa, CnumCredito, CnumTarjeta, CmontoAcla, user, '9250',ptranaplica,Ccargo ,pFolioSuacSUC)
						RETURNING CCodret_c, CMensaje;
						
						
						--> Validamos el codigo de retorno del sp_calculaintaclaraciones, si es difernete de "0", guardamos el error en bitacora. JLM - 02/06/2022
						IF( CCodret_c <> '000' ) THEN
							INSERT INTO informix.aplicaaclaracredito_control_errores(cod_retorno, nombre_sp, num_credito, num_tarjeta, folio_csuac, fecha_insert) 
								VALUES(CCodret_c, v_nombre_sp, CnumCredito, CnumTarjeta, pFolioSuac, horaActual);
						END IF;
						-->
						
		
					END IF; -- aplicaci�??�?³n cargo/abono
						IF (CCodret_c = "005") THEN
							LET cCodRet='005'; -- Intento de cargo con crédito vencido "BT" y bloqueado y sin saldo suficiente
							ROLLBACK WORK;
							IF (wBegin = "S") THEN
								BEGIN WORK;
							END IF;
							RETURN cCodRet;
						END IF;
		
						IF (CCodret_c = "207") THEN
							LET cCodRet='207'; -- Intento de cargo con crédito vencido "BT" y bloqueado
							ROLLBACK WORK;
							IF (wBegin = "S") THEN
								BEGIN WORK;
							END IF;
							RETURN cCodRet;
						END IF;
		
						IF (CCodret_c <> "000") THEN
							--Tabla de control de código de retorno
							LET CMensaje = TRIM(CMensaje)||'|'||v_contador_total;
							
							SELECT MAX(id_registro) + 1 
							INTO max_control_afect_cred
							FROM bdiaclaracion:"informix".acl_control_afectacion_cred;
							
							IF max_control_afect_cred IS NULL THEN
								LET max_control_afect_cred = 1;
							END IF;
							
							INSERT INTO bdiaclaracion:"informix".acl_control_afectacion_cred 
							VALUES (max_control_afect_cred, pFolioSuac, CURRENT, pDictamen, CCodret_c,TRIM(CMensaje),'bdicred:sp_aplicaaclaracredito');
							LET cCodRet='009'; --definir codigo en caso de falla en el cargo o abono
							--ROLLBACK WORK;
							IF (wBegin = "S") THEN
								BEGIN WORK;
							END IF;
		
							RETURN cCodRet;
							
						END IF;
		
		
---		----------- >> Actualiza tabla de movimientos (acl_movimiento) relacionados a la aclaración para indicar que se aplicarón
		
				LET CSecuencia_acl_mov = 0;
		
				SELECT MAX (secuencia)--, folio_csuac
				INTO CSecuencia_acl_mov
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac;
		
				-------------- >> Validación de secuencia
		
				IF (CSecuencia_acl_mov is null) THEN
						LET CSecuencia_acl_mov = 1;
					ELSE
						LET CSecuencia_acl_mov = (CSecuencia_acl_mov) + 1;
				END IF;
		
				IF (pDictamen NOT IN ('NP', 'CM')) THEN --> Considerar CM y NP para actualizaciones correctas 14/01/2013
		
					IF (v_contador_total = 0 ) THEN
		
						UPDATE bdiaclaracion:acl_movimiento
						SET cargo = 0,
							exitoso = '1',
							fecha_afectacion = CURRENT,
							numero_transaccion = ptranaplica,
							secuencia = CSecuencia_acl_mov
						WHERE pky_movimiento = CSecuencia
						AND folio_csuac = pFolioSuac;
		
					ELSE
		
						UPDATE bdiaclaracion:acl_movimiento
						SET cargo = 0,
							fecha_afectacion = CURRENT,
							secuencia = CSecuencia_acl_mov
						WHERE pky_movimiento = CSecuencia
						AND folio_csuac = pFolioSuac;
		
					END IF;
					-- let v_contador = v_contador + 1;
		
				ELSE
		
					UPDATE bdiaclaracion:acl_movimiento
					SET cargo = 1,
						exitoso = '1',
						fecha_afectacion = CURRENT,
						numero_transaccion = ptranaplica,
						secuencia = CSecuencia_acl_mov
					WHERE pky_movimiento = CSecuencia
					AND folio_csuac = pFolioSuac;
		
					-- let v_contador = v_contador + 1;
				END IF;
		
		
			let v_contador = v_contador + 1;
		
		
		
			END FOREACH;
		END IF; -- Fin de validaci�n de TADC
-- Actualiza tabla de acl_aclaracion con la fecha en que se dictamino

    COMMIT WORK;

    IF (wBegin = "S") THEN
        BEGIN WORK;
    END IF;

 END;

 RETURN cCodRet;

END PROCEDURE
DOCUMENT
'Sp sp_aplicaaclaracredito',
'Se incluye validacion para evitar se dupliquen abonos',
'Sistema: Aclaraciones',
'AUTOR : Bancoppel',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte II',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 13/Enero/2014',
'FECHA MOD: 31/Octubre/2018',
'VERSION: 1.0.0',
'BD    :  bdicred'

;


