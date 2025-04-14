DROP PROCEDURE IF EXISTS "informix".sp_cs_pago_anticipado(					CHAR(3),
																	CHAR(20),
																	CHAR(4),
															DECIMAL(18,2),
													DECIMAL(18,2),
																	CHAR(8),
																	CHAR(4),
																		CHAR(16),
																CHAR(4));



CREATE PROCEDURE "informix".sp_cs_pago_anticipado(pEmpresa					CHAR(3),
												pNumCredito					CHAR(20),
												pProducto					CHAR(4),
												pMontoOperacionEfec			DECIMAL(18,2),
												pMontoOperacionCargCuenta	DECIMAL(18,2),
												pUsuario					CHAR(8),
												pSucursal					CHAR(4),
												pFolio						CHAR(16),
												pTransaccion				CHAR(4))
RETURNING CHAR(5)		AS CodRet,
		CHAR(80)		AS Mensaje,
		CHAR(20)		AS Num_Credito,
		CHAR(20)		AS Cuenta_eje,
		CHAR(40)		AS Producto,
		CHAR(20)		AS Num_Cliente,
		CHAR(150)		AS Nom_Cliente,
		DECIMAL(18,2)	AS Pago_Efectivo,
		DECIMAL(18,2)	AS Pago_Cuenta,
		DECIMAL(18,2)	AS Monto_Operacion,
		DECIMAL(18,2)	AS Saldo_Actual,
		CHAR(60)		AS Status_Actual,
		DATE			AS fecha_prox_pago

DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			CHAR(100);
DEFINE cCodRet				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE cNumCreditocrd		CHAR(20);
DEFINE cNumCreditocrdsol	CHAR(20);
DEFINE cCredito_promo		CHAR(20);
DEFINE dtFechaProxPago		DATE;
DEFINE dtFechaApertura		DATE;
DEFINE Cuenta_eje			CHAR(20);
DEFINE Producto				CHAR(40);
DEFINE Num_Cliente			CHAR(20);
DEFINE Nom_Cliente			CHAR(80);
DEFINE Pago_Efectivo		DECIMAL(18,2);
DEFINE Pago_Cuenta			DECIMAL(18,2);
DEFINE Monto_Operacion		DECIMAL(18,2);
DEFINE Saldo_Actual			DECIMAL(18,2);
DEFINE Status_Actual		CHAR(60);
DEFINE iIntAux				INTEGER;
DEFINE cCharAux				CHAR(80);
DEFINE dDecAux				DECIMAL(18,2);
DEFINE dtDateAux			DATE;
DEFINE dPagoMinAct			DECIMAL(18,2);
DEFINE dSdoCapInsolutoPP	DECIMAL(18,2);
DEFINE dSdoAdeudTotalAct	DECIMAL(18,2);
DEFINE cFolio				INTEGER;

define cMensaje3 char(50);
DEFINE scont INT8;

LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= "";
LET cCodRet				= "00000";
LET cMensaje			= "Se realiza el proceso exitosamente";
LET cNumCreditocrd		= pNumCredito;
LET cCredito_promo		= "";
LET cCredito_promo		= "";
LET dtFechaProxPago		= mdy(1, 1, 1900);
LET dtFechaApertura		= mdy(1, 1, 1900);
LET Cuenta_eje			= "";
LET Producto			= "";
LET Num_Cliente			= "";
LET Nom_Cliente			= "";
LET Pago_Efectivo		= 0;
LET Pago_Cuenta			= 0;
LET Monto_Operacion		= 0;
LET Saldo_Actual		= 0;
LET Status_Actual		= "";
LET iIntAux				= 0;
LET cCharAux			= "";
LET dDecAux				= 0;
LET dtDateAux			= DATE(1);
LET dPagoMinAct			= 0;
LET dSdoCapInsolutoPP	= 0;
LET dSdoAdeudTotalAct	= 0;
LET cNumCreditocrdsol   = pNumCredito;
LET cFolio				= 0;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr in (-255) THEN
            SET DEBUG FILE TO "/RESPALDOSNEW/sp_cs_pago_anticipado.out";
            TRACE ON;
        else	
--		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensaje = cErrorInfo;
			RETURN cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual,dtFechaProxPago;
		END IF;
	END EXCEPTION;



IF NVL(pEmpresa,"")= "" OR  NVL(pNumCredito,"") = "" OR NVL(pProducto,"") = "" OR NVL(pMontoOperacionEfec,"") = "" OR NVL(pMontoOperacionCargCuenta,"")  = "" OR NVL(pUsuario,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pFolio,"") = "" OR NVL(pTransaccion,"") = "" THEN

	LET cCodRet      = "00411";
     LET cMensaje  = "NO HAY ARGUMENTOS (PARAMETROS)";

		RETURN cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual,dtFechaProxPago;
END IF;

--SET DEBUG FILE TO "/tmp/sp_cs_pago_anticipado.out";
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		SELECT a.num_credito
			INTO cCredito_promo
		FROM bdicred: "informix".sd_promocion_credito a, bdicred: "informix".sd_maecredcrd b, bdicred: "informix".sd_maecredanexocrd c
		WHERE a.empresa = pempresa
			AND a.empresa = b.empresa
			AND a.empresa = c.empresa
			and a.num_sol_prestamo = cNumCreditocrd
			AND a.num_sol_prestamo = b.num_credito
			AND a.num_sol_prestamo = c.num_credito
			AND num_pro_prestamo = pproducto
			AND a.status = 2
			AND b.status_cred IN ('AA','E1');

		IF ( cCredito_promo IS NOT NULL ) THEN

				CALL "informix".sp_principal_suc_rr(pempresa,cNumCreditocrd, pproducto,pMontoOperacionEfec,pMontoOperacionCargCuenta,pUsuario,pSucursal,pFolio,pTransaccion)
				RETURNING cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual;

				--AAME INC 27 108 Se castea la variable de retorno para que cuando el codigoret sea "000" exito o "00000" los tome igual
				IF (cCodRet::INTEGER <> 0) THEN
					IF cCodRet = "00044" THEN
						LET cCodRet = "01088";
						LET cMensaje = "Cliente no tiene cuenta efectiva";
					ELIF cCodRet = "00195" THEN
						LET cCodRet = "01094";
						LET cMensaje = "Cuenta del cliente no esta activa";
					ELIF cCodRet = "00199" THEN
						LET cCodRet = "001093";
						LET cMensaje = "Cuenta del cliente bloqueada";
					ELIF cCodRet = "00194" THEN
						LET cCodRet = "001095";
						LET cMensaje = "Cuenta sin saldo";
					END IF;

					RETURN cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual,dtFechaProxPago;
				ELSE


					EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pempresa,cNumCreditocrd)
						INTO cCodRet,cMensaje,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinAct,dtDateAux,
					iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
					dsdocapinsolutopp,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
					dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotalAct,dDecAux,dDecAux,
					dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
					cCharAux,cCharAux,iIntAux,cCharAux;

					IF  pTransaccion = '623' THEN

					   LET pMontoOperacionEfec = pMontoOperacionCargCuenta;
					END IF;
					--EM 24/03/2017
					--AAME INC 27 108 Se elimina IF NOT EXITS a peticiÃ³n de Base de Datos
					SELECT count(folio_suc) INTO cFolio
					FROM bdicred: "informix".sd_pago_anticipado_cs WHERE folio_suc = pFolio;
					
					IF cFolio = 0 THEN
					  INSERT INTO bdicred: "informix".sd_pago_anticipado_cs(empresa,folio_suc,fecha_mov,producto,num_credito,tarjeta,monto_pago,saldo_actual,fechaproximopago,transaccion)
                      VALUES (pempresa,pFolio,TODAY,pproducto,cNumCreditocrd,'',pMontoOperacionEfec,dSdoAdeudTotalAct,dtFechaProxPago,pTransaccion);
					ELSE
						UPDATE bdicred: "informix".sd_pago_anticipado_cs
						SET  fecha_mov= TODAY, producto= pproducto, num_credito= cNumCreditocrd, tarjeta= '', monto_pago= pMontoOperacionEfec, saldo_actual= dSdoAdeudTotalAct, fechaproximopago= dtFechaProxPago, transaccion= pTransaccion
						WHERE folio_suc= pFolio and empresa= pempresa;
					END IF;

					LET cMensaje   = "Se realiza el proceso exitosamente";

				   -- DSB - TH - 16-02-2015
					LET Saldo_Actual = dSdoAdeudTotalAct;

					--UPDATE bdicred: "informix".sd_promocion_credito
					--	SET monto_actual = dSdoAdeudTotalAct, folio_suc_mov_crd = pFolio
					--WHERE empresa = pempresa and num_sol_prestamo = cNumCreditocrdsol;
				END IF;

		ELSE
			LET cCodRet = "00002";
			LET cMensaje   = "La credisolucion no existe";
		END IF;
	RETURN cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual,dtFechaProxPago;
END
END PROCEDURE
DOCUMENT

'DESCRIPCIÃ?N: PROCEDURE QUE PARA INVOCAR EL PAGO ANTICIPADO DE CREDISOLUCIONES',
'FECHA DE MODIFICACIÃ?N: 28-11-2015',
'BASE DE DATOS: BDICRED',
'MODIFICÃ?: YADIRA MORALES ZAZUETA',
'----------------------------------------------------------------------------',
'Descripcion : se agrega consulta de credito en sd_promocion_credito de credisoluciones para respaldar',
'Modifico    : 95992243 - Trinidad Hernandez',
'Fecha       : 07/02/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : se agrega modifica para que imprima en ticket sd_pago_anticipado_cs.saldo_actual ',
'Modifico    : 95992243 - Trinidad Hernandez',
'Fecha       : 16/02/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para actualizar folio suc en la tabla sd_promocion_credito cuando se hace un pago, se filtra para que inserte en sd_pago_anticipado_cs ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 08/003/2017,--EM 24/03/2017',
'BD          : bdicred';


