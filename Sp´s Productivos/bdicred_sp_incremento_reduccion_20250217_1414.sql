






CREATE PROCEDURE "informix".sp_incremento_reduccion (pEmpresa CHAR(3),pCredito CHAR(20),p_meses INTEGER,pTotalMovimiento DECIMAL(10,2),tipo CHAR(1),pbc_score DECIMAL(14,2),pNumTran CHAR(4))
   RETURNING CHAR(6),CHAR (100),DECIMAL(10,2);
   
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE vcod_ret				CHAR(10);
DEFINE v_cod_ret			CHAR(6);
DEFINE vsqlerr				INTEGER;
DEFINE v_Mensaje			CHAR(100);
DEFINE v_Mensaje2			CHAR(100);

DEFINE dFechaHoy			DATE;
DEFINE p_fecha_consulta_inc	DATE;
DEFINE v_bcscore			DECIMAL (8,2);
DEFINE v_tipo				CHAR(1);
DEFINE v_numcte				CHAR(20);
DEFINE v_monto				DECIMAL(10,2);
DEFINE VNuevaLinea			DECIMAL(10,2);
DEFINE vlin_anterior		DECIMAL(10,2);
DEFINE v_rango				CHAR(50);
DEFINE v_ajuste_monto		DECIMAL(10,2);
DEFINE p_folio				CHAR(16);
DEFINE v_producto			CHAR(4);
DEFINE v_divisa				CHAR(2);
DEFINE v_sucursal			CHAR(4);
DEFINE v_marca_cincuenta	INTEGER;
DEFINE p_referencia			INTEGER;
DEFINE p_transaccion		CHAR(4);
DEFINE v_descripcion		CHAR(50);
DEFINE v_descripcion2		CHAR(100);
DEFINE no_movimiento		INTEGER;
DEFINE vmax_fecha			DATE;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET vcod_ret				= "000";
LET v_cod_ret				= "000000";
LET vsqlerr					= 0;
LET v_Mensaje 				= "Proceso Exitoso";
LET v_Mensaje2				= "";

LET dFechaHoy				= DATE (1);
LET p_fecha_consulta_inc	= DATE (1);
LET v_bcscore				= 0;
LET v_tipo					= "";
LET v_numcte				= "";
LET v_monto					= 0;
LET VNuevaLinea				= 0;
LET vlin_anterior			= 0;
LET v_rango					= "";
LET v_ajuste_monto			= 0;
LET p_folio					= "";
LET v_producto				= "";
LET v_divisa				= "";
LET v_sucursal				= "";
LET v_marca_cincuenta 		= 0;

LET p_referencia			= 0;
LET p_transaccion			= 0;
LET v_descripcion 			= "";
LET v_descripcion2			= "Transaccion exitosa";
LET no_movimiento			= 0;
LET vmax_fecha				= DATE(1);

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
	ON EXCEPTION SET vsqlerr
	IF vsqlerr != 0 THEN
		LET v_cod_ret=vsqlerr;
		LET v_Mensaje = "";
		LET VNuevaLinea = 0;
		RETURN v_cod_ret,v_Mensaje,VNuevaLinea;	
	END IF;
	END EXCEPTION;   
	
--SET DEBUG FILE TO "/informix/Israel/sp_reduccion_linea_ina.out";
--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************		
	
		-- OBTIENE LA FECHA DEL DIA
		SELECT fecha_hoy
			INTO dFechaHoy
		FROM "informix".sd_fechas
			WHERE empresa = pEmpresa;			

		--- Se obtiene datos para grabar el movimiento y Se obtiene el monto			
		SELECT 	b.numcte,b.num_producto, b.divisa, b.sucursal,a.monto_otorgado 
			INTO v_numcte,v_producto, v_divisa, v_sucursal,v_monto
		FROM 	bdicred:sd_maecred b, bdicred:sd_maesdos a
		WHERE b.empresa = pEmpresa
			AND a.empresa = b.empresa
			AND b.num_credito = a.num_credito 
			AND b.num_credito = pCredito;
		
			
		IF tipo = 'I' THEN
			
			--- Consulta el credito con el registro mas reciente de la tabla estatus de incrementos y decrementos
			SELECT bc_score,tp_proceso,meses_ina,marca_cincuenta
				INTO v_bcscore,v_tipo,p_meses,v_marca_cincuenta
			FROM "informix".sd_status_incremento_reduccion 
					WHERE empresa = pEmpresa AND num_credito = pCredito;
	
			--- Para casos donde exista un incremento ya no se aplica.
			IF v_tipo = tipo  THEN
				LET v_Mensaje = 'Se aplico Incremento anteriormente';
				RETURN v_cod_ret, v_Mensaje,VNuevaLinea;
			END IF;
	
			--- Se obtiene la nueva linea y transacciÃ³n en base a tabla de parametros.
			SELECT linea,descripcion,codigo_ref,transaccion,folio
				INTO VNuevaLinea,v_rango,p_referencia,p_transaccion,p_folio
			FROM "informix".sd_param_reduccion_linea
				WHERE tp_solicitud  = "T"			 
					AND v_bcscore BETWEEN bc_scoremin AND bc_scoremax			 
					AND tp_parametrico = tipo; 	

			--- Se obtiene la descripciÃ³n de transacciÃ³n que se manda por el sp cargo_ref_cel
			SELECT descripcion
				INTO v_descripcion
			FROM bdinteg:"informix".si_transacc
				WHERE empresa = pEmpresa
					AND sistema = "06"
					AND numero = pNumTran;				
	
			
			--- Obtiene la diferencia del incremento para realizar la transacciÃ³n de incremento
			LET v_ajuste_monto = VNuevaLinea - v_monto;
			
			IF VNuevaLinea < pTotalMovimiento THEN 
				LET v_descripcion2 = "Rechazo, monto insuficiente";
			END IF;
				
			UPDATE "informix".sd_status_incremento_reduccion 
				SET tp_proceso = tipo, linea_anterior = v_monto, linea_actual = VNuevaLinea, monto_facturacion = pTotalMovimiento, describe_mov = v_descripcion, fecha_actualiza = dFechaHoy,fecha_facturacion = dFechaHoy, descripcion = v_descripcion2
			WHERE empresa = pEmpresa AND num_credito = pCredito;			
						
			
		ELIF tipo = "R" THEN
		
			--- Se obtiene la nueva linea y transacciÃ³n en base a tabla de parametros.
			SELECT linea,descripcion,codigo_ref,transaccion,folio
				INTO VNuevaLinea,v_rango,p_referencia,p_transaccion,p_folio
			FROM "informix".sd_param_reduccion_linea
				WHERE tp_solicitud  = "T"			 
					AND pbc_score BETWEEN bc_scoremin AND bc_scoremax			 
					AND tp_parametrico = tipo;

			--- El bc_score original de la reducciÃ³n se obtiene de la sd_adviser, se envia parametro del sp_reduccion_linea_ina
			LET v_bcscore = pbc_score;
			
			IF VNuevaLinea >= v_monto THEN
				LET v_Mensaje = 'La nueva linea es mayor al monto actual';
				RETURN v_cod_ret, v_Mensaje,VNuevaLinea;		
			END IF;
			
			--- Se obtiene la descripciÃ³n de transacciÃ³n para reducciÃ³n			
			SELECT descripcion
				INTO v_descripcion
			FROM bdinteg:"informix".si_transacc
				WHERE empresa = pEmpresa
					AND sistema = "06"
					AND numero = p_transaccion;
			
			--- Se asigna la nueva transacciÃ³n.
			LET pNumTran = p_transaccion;	
			
			--- Obtiene la diferencia de reducciÃ³n para realizar la transacciÃ³n
			LET v_ajuste_monto = v_monto - VNuevaLinea;
			LET pTotalMovimiento = v_ajuste_monto;		

			IF NOT EXISTS (SELECT * FROM "informix".sd_status_incremento_reduccion WHERE empresa = pEmpresa AND num_credito = pCredito) THEN
				INSERT INTO "informix".sd_status_incremento_reduccion (empresa,numcte,num_credito,tp_proceso,meses_ina,bc_score,linea_original,linea_anterior,linea_actual,fecha_insert,monto_facturacion,fecha_facturacion,describe_mov,marca_cincuenta,fecha_actualiza,descripcion)
					VALUES (pEmpresa,v_numcte,pCredito,tipo,p_meses,pbc_score,v_monto,v_monto,VNuevaLinea,dFechaHoy,0,dFechaHoy,v_descripcion,v_marca_cincuenta,dFechaHoy,v_descripcion2);
			ELSE
				UPDATE "informix".sd_status_incremento_reduccion SET tp_proceso = tipo, fecha_actualiza = dFechaHoy,linea_anterior = v_monto,linea_actual = VNuevaLinea
					WHERE empresa = pEmpresa AND num_credito = pCredito;
			END IF;
			
		
		ELIF tipo = "3" THEN

			--- Se obtiene la nueva linea y transacciÃ³n en base a tabla de parametros.
			SELECT linea,descripcion,codigo_ref,transaccion,folio
				INTO VNuevaLinea,v_rango,p_referencia,p_transaccion,p_folio
			FROM "informix".sd_param_reduccion_linea
				WHERE tp_solicitud  = "T"			 			 
					AND tp_parametrico = tipo; 	
					
			--- El bc_score original de la reducciÃ³n se obtiene de la sd_adviser, se envia parametro del sp_reduccion_linea_ina					
			LET v_bcscore = pbc_score;					

			--- pTotalMovimiento es la linea original del credito el cual lo manda el sp_reduccion_linea_ina
			LET VNuevaLinea = pTotalMovimiento;		
			
			IF VNuevaLinea <= v_monto THEN
				LET VNuevaLinea = v_monto;
				LET no_movimiento = 1; --- En caso de que la linea sea menor o igual, no se hace movimiento y solo se marca en la bitacora.		
			END IF;
			
			LET v_marca_cincuenta = 1;
			LET v_descripcion = 'REACTIVACION POR '||TRIM (v_rango);
			LET v_ajuste_monto = VNuevaLinea - v_monto;		
			LET pTotalMovimiento = v_ajuste_monto;
				
			UPDATE "informix".sd_status_incremento_reduccion 
				SET tp_proceso = tipo, linea_anterior =  v_monto,linea_actual = VNuevaLinea, describe_mov = v_descripcion, marca_cincuenta = 1, fecha_actualiza = dFechaHoy
			WHERE empresa = pEmpresa AND num_credito = pCredito;				
											
			LET v_Mensaje = v_descripcion;	
			
		
		END IF;
		
		IF VNuevaLinea > 0 THEN
		
			IF no_movimiento = 0 THEN
				--- Actualiza la linea con incremento o decremento.
				UPDATE bdicred:sd_maesdos 
					SET monto_otorgado = VNuevaLinea
				WHERE empresa = pEmpresa
					AND num_credito = pCredito;	

				---  Graba movimiento sd_movdia
				EXECUTE PROCEDURE GENMOV( pEmpresa, pCredito,v_producto,p_referencia,'008', dFechaHoy,v_ajuste_monto, p_folio,v_sucursal,v_divisa,p_transaccion)
					INTO vcod_ret,
						v_Mensaje2;
								
				IF vcod_ret::INTEGER <> 0 THEN
				
					--- Actualiza la linea anterior.
					UPDATE bdicred:sd_maesdos 
						SET monto_otorgado = v_monto
					WHERE empresa = pEmpresa
						AND num_credito = pCredito;					
				
					LET tipo = 'E'; -- Error en el proceso
					LET v_descripcion2="Ocurrio un error al guardar los movimientos del credito en el SP bdicred:genmov";	
					LET VNuevaLinea = 0;
					
					UPDATE "informix".sd_status_incremento_reduccion SET tp_proceso = tipo
						WHERE empresa = pEmpresa AND num_credito = pCredito;					 
				END IF;	
			END IF;
						
			--- Guarda un registro nuevo con el incremento tipo I o reducciÃ³n tipo R o si existe un error en E (para identificar el credito)
			INSERT INTO bdicred:sd_incremento_reduccion (empresa,tp_parametrico,numcte,num_credito,meses_ina,bc_score,rango,linea_original,linea_nueva,total_mov,fecha_insert,marca_cincuenta,transaccion_mov,describe_mov,descripcion)		
				VALUES (pEmpresa,tipo,v_numcte,pCredito,p_meses,v_bcscore,v_rango,v_monto,VNuevaLinea,pTotalMovimiento,dFechaHoy,v_marca_cincuenta,pNumTran,v_descripcion,v_descripcion2);

		END IF;
			
	RETURN v_cod_ret,v_Mensaje,VNuevaLinea;
END; 			

END PROCEDURE
DOCUMENT
'REALIZA LA REDUCCION E INCREMENTO DE LINEA - RQM 09 499',
'AUTOR : ISRAEL TRAVIESO DIAZ',
'FECHA : OCT/2018',
'BD    : BDICRED',
'MODIFICACION: SE AGREGA VALIDACION PARA QUE LA LINEA NUEVA NO SEA MAYOR A LA LINEA ANTERIOR0',
'AUTOR : CINTHIA AGUILAR',
'FECHA : JUNIO/2024',
'BD    : BDICRED';


