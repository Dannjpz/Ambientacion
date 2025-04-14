DROP PROCEDURE IF EXISTS "informix".cargo_cred(   CHAR(3),
			        CHAR(20),
			       CHAR(4),
			        CHAR(8),
			           CHAR(4),
			          DECIMAL(14,2),
			          CHAR(16),
			        CHAR(20),
			       DECIMAL(14,2),
			        DECIMAL(14,6),
			           DATE,
			      CHAR(40),
			        VARCHAR(20),
			           VARCHAR(23));

CREATE PROCEDURE "informix".cargo_cred(pEmpresa    CHAR(3),
			     pCredito    CHAR(20),
			     pSucursal   CHAR(4),
			     pUsuario    CHAR(8),
			     pTran       CHAR(4),
			     pMonto      DECIMAL(14,2),
			     pFolio      CHAR(16),
			     pTarjeta    CHAR(20),
			     pMontoDls   DECIMAL(14,2),
			     pTpCambio   DECIMAL(14,6),
			     pFecha      DATE,
			     pReferencia CHAR(40),
			     pRfcComer   VARCHAR(20),
			     pRef23      VARCHAR(23))

   RETURNING CHAR(5);

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vSucCred	      CHAR(4);
   DEFINE vIvaSuc	      DECIMAL(5,3);
   DEFINE vIvaBase	      DECIMAL(5,3);
   DEFINE vTpTran             CHAR(2);
   DEFINE vTpTranRel          CHAR(2);
   DEFINE vTranRelac          CHAR(4);
   DEFINE vTranParalela       CHAR(4);
   DEFINE vTranNro	      SMALLINT;
   DEFINE vDiasRet	      SMALLINT;
   
   DEFINE vTpTranFavor 	   CHAR(2); 
   DEFINE vTranRelacFavor CHAR(4);
   DEFINE vTranParalelaFavor CHAR(4); 
   DEFINE vDiasRetFavor	SMALLINT;
   DEFINE vTpTranRelFavor CHAR(2); 
   
   DEFINE MtoIVA		DECIMAL(14,2);
   DEFINE MtoIVAFavor	DECIMAL(14,2);
   DEFINE MtoIVA2		DECIMAL(14,2);
   DEFINE MtoFavor		DECIMAL(14,2);
   DEFINE SaldoIVAFavor	DECIMAL(14,2);
   
   DEFINE vMensaje	      CHAR(1);
   DEFINE vProducto	      CHAR(4);
   DEFINE vTranRetuvo	      CHAR(4);
   DEFINE vDivisa             CHAR(2);
   DEFINE vNat		      CHAR(1);
   DEFINE MtoRel	      DECIMAL(14,2);
   DEFINE wbegin     CHAR(1);
--   DEFINE vCantReg            INTEGER;
   --Indicadores
   DEFINE  cod_ret3     CHAR(5);
   DEFINE  vlIndicador	CHAR(1);

   DEFINE pMonto_libera  DECIMAL(14,2);
   DEFINE dSaldoFavor  DECIMAL(14,2);
   DEFINE pNumTranFavor	      CHAR(4);
   DEFINE pTran2	      CHAR(4);
   DEFINE cStatus	      CHAR(2);
   DEFINE pMonto2	      DECIMAL(14,2);

   DEFINE vcDisponCred CHAR(1);
 
   DEFINE mMonto            DECIMAL(14,2);    
   DEFINE cNombreCom        CHAR(4); 
   DEFINE fApertura         DATE;
   DEFINE cCampo_trab4      CHAR(10);
   DEFINE cCobro_Apertu     CHAR(1);
   DEFINE cCodComis_Apert   CHAR(4);
   DEFINE sCountExists		SMALLINT;
   DEFINE dValorMinPfSms	DECIMAL(18,6);
   DEFINE cCod_ret_sms		CHAR(5); 
   DEFINE cParamContSmsPf	CHAR(1);
   DEFINE vACT				INTEGER;
   DEFINE iBanUpgrade		INTEGER;
   DEFINE cNumCredUpgrade	CHAR(20);

   LET wbegin     			= "N";
   LET iBanUpgrade   		= 0;
   LET cNumCredUpgrade 	 	= "";

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info

       IF sql_err != 0 THEN
          LET cod_ret = sql_err;

          IF wbegin = "S" THEN
            ROLLBACK WORK;
            BEGIN WORK;
          ELSE
            ROLLBACK WORK;
          END IF

          RETURN cod_ret;
       END IF;

--      LET cod_ret = sql_err;
--      RETURN cod_ret;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wbegin = "S";
   END EXCEPTION WITH RESUME;

	--SET DEBUG FILE TO "/ifxsif01/roman/ambientacion/TDC_INFINITE/Ambientacion/marcos/cargocred.out";
	--TRACE ON;
	--SET DEBUG FILE TO '/ifxsif01/aldo/etapas/PagosTDC/cargo_cred_'||p_NumCredito||'.out';
   --TRACE ON;

   --SET DEBUG FILE TO "/resplogifx/repaclaraciones/cargo_cred.out";
   --TRACE ON;
 
   IF wbegin = "S" THEN
      COMMIT WORK;
      BEGIN WORK;
   ELSE
      BEGIN WORK;
   END IF;


--  BEGIN WORK;

  SET LOCK MODE TO WAIT 3;
  SET ISOLATION TO DIRTY READ;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************



   LET cod_ret    = "000";
   LET vTranNro   = pTran;
   LET pTran   = vTranNro;
   LET pNumTranFavor ="";
   LET pTran2 ="";
   LET dSaldoFavor = 0 ;
   LET cStatus = "" ;

   LET vcDisponCred = "";

   LET pMonto2 = pMonto;
   
   IF LENGTH(pTran) < 4 THEN
       LET pTran = LPAD(TRIM(pTran),4,"6");
   END IF
   LET MtoRel = 0;
--   LET vCantReg = 0;
   LET pMonto_libera = 0;

   LET mMonto  = 0; 
   LET cNombreCom  = "";
   LET fApertura = DATE(1); 
   LET cCampo_trab4 = ""; 
   LET cCobro_Apertu = '0';
   LET cCodComis_Apert = '';
   LET sCountExists   = 0;
   LET dValorMinPfSms = 0;
   LET cCod_ret_sms	  = '';
   LET cParamContSmsPf = '';
   
   LET vTpTranFavor 	  =''; 
   LET vTranRelacFavor ='';
   LET vTranParalelaFavor ='';
   LET vDiasRetFavor	=0;
   LET vTpTranRelFavor ='';
   
   LET MtoIVA		=0;
   LET MtoIVAFavor	=0;
   LET MtoIVA2		=0;
   LET MtoFavor		=0;
   LET SaldoIVAFavor	=0;
   LET vACT			=0;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
   -- **************************************************
   -- Valida que la transaccion a aplicar sea de cargo *
   -- **************************************************

   -- Valida disponibilidad del sistema de credito JOM INI

   SELECT NVL(ind_disponible, '0')
     INTO vcDisponCred
     FROM bdicred:sd_fechas
    WHERE empresa = pEmpresa;

   IF (vcDisponCred = '0') THEN
       LET cod_ret = "040";

       IF (wbegin = "S") THEN
            ROLLBACK WORK;
            BEGIN WORK;
       ELSE
            ROLLBACK WORK;
       END IF;

       RETURN cod_ret;
   END IF;

   -- Valida disponibilidad del sistema de credito JOM FIN

SELECT naturaleza INTO vNat
     FROM bdinteg:si_transacc
    WHERE empresa = pEmpresa
      AND numero = pTran
      AND sistema = "06";

   IF  vNat IS NULL OR vNat <> "C" THEN
      LET cod_ret = "120";
      RETURN cod_ret;
   END IF

   -- ******************************
   -- Extrae Parametro de IVA Base *
   -- ******************************
   SELECT valor INTO vIvaBase
     FROM bdinteg:si_param
    WHERE empresa = pEmpresa
      AND cod_param = 47;

   IF vIvaBase IS NULL THEN
	LET vIvaBase = 0;
   END IF

   -- **************************************************
   -- Extrae informacion de Sucursal e Iva del Credito *
   -- **************************************************
   SELECT b.sucursal, a.iva, b.num_producto, b.divisa,status_cred, fecha_apertura,TRIM(campo_trab4)
     INTO vSucCred, vIvaSuc, vProducto, vDivisa , cStatus, fApertura,cCampo_trab4
     FROM bdinteg:si_sucursales a, bdicred:sd_maecred b
    WHERE b.empresa = pEmpresa
      AND b.num_credito = pCredito
      AND a.empresa = b.empresa
      AND a.sucursal = pSucursal;

   -- ************************************
   -- Extrae Parametro Comision Apertura *
   -- ************************************
   SELECT nvl(cobro_comis_apertura,'0'), nvl(cod_comision_apertura,'') INTO cCobro_Apertu, cCodComis_Apert
     FROM bdicred:sd_definicion WHERE num_producto = vProducto;

   -- ***************************************
   -- Extrae informacion de la Transaccion  *
   -- ***************************************

   SELECT tipo_tran, NVL(tran_relac,"0000"), NVL(trancivaesp,"0000"),
	  NVL(dias_ret,0)
     INTO vTpTran, vTranRelac, vTranParalela, vDiasRet
     FROM bdinteg:si_transacc
    WHERE empresa = pEmpresa
      AND sistema = "06"
      AND numero = pTran;

   IF LENGTH(vTranRelac) = 0 THEN
	LET vTranRelac = "0000";
   END IF

   IF LENGTH(vTranParalela) = 0 THEN
	LET vTranParalela = "0000";
   END IF   
   
   -- **************************************************************
   -- Determina la transaccion a utilizar por clasificacion de IVA *
   -- **************************************************************
   IF vIvaSuc <> vIvaBase AND vTranParalela <> "0000" THEN
	LET pTran = vTranParalela;
   END IF

   --INI Saldo a Favor JMAH
	 
	IF pTran IN ("6830","6887","8244","8246","4200","4201","4202","4254","4255","4256","4262") THEN   -- 8244, 8246 Comision por anualidad
	--se valida si se tiene saldo a favor
		SELECT CASE WHEN sdo_capital < 0 THEN  sdo_capital * -1 ELSE 0 END
         INTO  dSaldoFavor
         FROM  "informix".sd_maesdos 
        WHERE num_credito = pCredito
          AND empresa = "001";
		
		IF  dSaldoFavor > 0  THEN 
		--se obtiene la transaccion a favor de acuerdo a la transaccion recibida   
			SELECT transacc_favor
				INTO pNumTranFavor
			FROM "informix".sd_conceptoscargoscredito
			WHERE transacc = pTran;			
			
			IF dSaldoFavor > 0 AND dSaldoFavor < pMonto THEN
				LET pMonto2 = pMonto - dSaldoFavor;				
			ELIF dSaldoFavor > 0 AND dSaldoFavor >= pMonto THEN
				LET dSaldoFavor =pMonto;
				LET pMonto2 = 0;			
			END IF		
			
		END IF;
	END IF;	
	
	IF pTran IN ("6212","6218","6219","6220","6221") THEN  
	--se valida si se tiene saldo a favor
		SELECT CASE WHEN sdo_capital < 0 THEN  sdo_capital * -1 ELSE 0 END
         INTO  dSaldoFavor
         FROM  "informix".sd_maesdos 
        WHERE num_credito = pCredito
          AND empresa = "001";
		
		IF  dSaldoFavor > 0  THEN 
		--se obtiene la transaccion a favor de acuerdo a la transaccion recibida   
			SELECT transacc_favor
				INTO pNumTranFavor
			FROM "informix".sd_conceptoscargoscredito
			WHERE transacc = pTran;			
			
			SELECT tipo_tran, NVL(tran_relac,"0000"), NVL(trancivaesp,"0000"),
			  NVL(dias_ret,0)
			 INTO vTpTranFavor, vTranRelacFavor, vTranParalelaFavor, vDiasRetFavor
			 FROM bdinteg:si_transacc
			WHERE empresa = pEmpresa
			  AND sistema = "06"
			  AND numero = pNumTranFavor;
			
			LET MtoIVA = pMonto * vIvaSuc;
			--LET MtoTotalRepo= pMonto+ MtoIVA
			
					
			IF dSaldoFavor > 0 AND dSaldoFavor < pMonto THEN
				LET MtoFavor = dSaldoFavor;	
				LET MtoIVAFavor=0;
				LET pMonto2 = pMonto - dSaldoFavor;	
				LET MtoIVA2= MtoIVA;				
			ELIF dSaldoFavor > 0 AND dSaldoFavor > pMonto THEN
				LET MtoFavor=pMonto;
				LET pMonto2 =0;
				LET SaldoIVAFavor =dSaldoFavor-pMonto;
				IF SaldoIVAFavor>0 AND SaldoIVAFavor<MtoIVA THEN
					LET MtoIVA2=MtoIVA-SaldoIVAFavor;
					LET MtoIVAFavor=SaldoIVAFavor;
				ELIF SaldoIVAFavor>0 AND SaldoIVAFavor>=MtoIVA THEN
					LET MtoIVA2=0;
					LET MtoIVAFavor=MtoIVA;
				END IF
			ELIF dSaldoFavor > 0 AND dSaldoFavor = pMonto THEN
				LET MtoFavor =pMonto;
				LET MtoIVAFavor=0;
				LET pMonto2 = 0;
				LET MtoIVA2= MtoIVA;				
			END IF		
		ELSE
			LET MtoFavor =0;
			LET MtoIVAFavor=0;
			LET pMonto2 = pMonto;
			LET MtoIVA2= pMonto * vIvaSuc;
		END IF;
		LET dSaldoFavor = MtoFavor;
	END IF;	
	--FIN Saldo a Favor JMAH
   

   
   IF vTpTran >= "20" AND vTpTran <= "29" THEN -- Retension de Saldo			
	UPDATE bdicred:sd_maesdos SET sdo_retenido = sdo_retenido + pMonto
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito;

	INSERT INTO bdicred:sd_maeretenido
	 (empresa, num_credito, folio_suc, fecha, hora, transacc, dias_ret,
	  monto, usuario, estatus, referencia, sucursal, dias_ori)
	VALUES
	 (pEmpresa, pCredito, pFolio, pFecha, CURRENT HOUR TO FRACTION(3),
	  pTran, vDiasRet, pMonto, pUsuario, "P", pReferencia, pSucursal,
	  vDiasRet);
	  
	-- Parametros para Pagos Fijos SMS: Valor minimo de contratacion. Parametro para contratar Pagos Fijos SMS (funcionalidad)
	SELECT valor::DECIMAL(18,2) INTO dValorMinPfSms FROM bdicred:"informix".sd_param WHERE cod_param  = '029';
	IF dValorMinPfSms IS NULL THEN LET dValorMinPfSms = 0; END IF;

	SELECT NVL(valor_alfabetico,'0') INTO cParamContSmsPf 
	  FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 2 AND grupo_parametro = 'PAGOSFIJOS' AND num_parametro = 13;	

	SELECT nvl(act,0) INTO vACT
         FROM  "informix".sd_maesdos 
        WHERE num_credito = pCredito
          AND empresa = "001";
	
	IF pMonto >= dValorMinPfSms AND ( (cStatus = 'AA') OR ((cStatus = 'E1') AND (vACT = 0)) ) AND cParamContSmsPf = '1' THEN -- Ejecuta la invitacion a Pagos Fijos por SMS, si el cliente es candidato.
        
		INSERT INTO bdicred:sd_promocion_credito_sms(empresa, num_credito, mnto_compra, folio_compra_sms, fecha_invitacion, tipo_sms, fecha_insert)
				VALUES (pEmpresa, pCredito, pMonto, pFolio, pFecha, '0', CURRENT);
	END IF;


   ELIF vTpTran >= "30" AND vTpTran <= "39" THEN -- Liberacion Retension Sdo
	SELECT numero INTO vTranRetuvo
	  FROM bdinteg:si_transacc
	 WHERE empresa = pEmpresa
	   AND sistema = "06"
	   AND tranlibprot = pTran;
/*
	SELECT count(num_credito),numero_credito_upgrade INTO iBanUpgrade, cNumCredUpgrade 
	FROM bdicred:sd_credito_upgrade 
	WHERE resultado = 1 
	AND num_credito = pCredito
	GROUP BY numero_credito_upgrade;

	IF iBanUpgrade > 0 THEN
		LET pCredito = cNumCredUpgrade;
	END IF;		
*/	
     select sum(monto) 
       into pMonto_libera
       from bdicred:sd_maeretenido
	  WHERE empresa = pEmpresa
	    AND num_credito = pCredito
	    AND folio_suc = pFolio
        AND estatus = 'P'
	    AND transacc = vTranRetuvo;
	
     IF pMonto_libera is null THEN
        let pMonto_libera = 0; 
	 END IF;
	 
	 IF pMonto_libera > 0 THEN
         UPDATE bdicred:sd_maeretenido SET estatus = "L"
          WHERE empresa = pEmpresa
            AND num_credito = pCredito
            AND folio_suc = pFolio
            AND estatus = 'P'
            AND transacc = vTranRetuvo;
			
			-- SE VALIDA QUE HAYA RETENIDOS PARA LA AFECTACION DE SALDOS CORRESPONDIENTE -- PIQV
			IF DBINFO("sqlca.sqlerrd2") > 0 THEN
			    
				UPDATE bdicred:sd_maesdos
				   SET sdo_capital = CASE WHEN  cStatus = "BT"  THEN  sdo_capital ELSE sdo_capital + pMonto END, --JMAH sdo_capital + pMonto,
					   sdo_cap_insoluto = sdo_cap_insoluto + pMonto,
					   mto_ministra_cap = mto_ministra_cap + pMonto,
					   cargos_mes_cap   = cargos_mes_cap + pMonto,
					   sdo_retenido = sdo_retenido - pMonto_libera,
					   cap_tras_no_venci = CASE WHEN  cStatus = "BT"  THEN  cap_tras_no_venci + pMonto ELSE cap_tras_no_venci END --JMAH
				 WHERE empresa = pEmpresa
				   AND num_credito = pCredito;

				-- Si el cliente tiene invitacion de Pagos Fijos SMS. Actualiza liberacion de retenido  (1 Enviada / 2 Espera conciliacion).
				SELECT COUNT(num_credito) INTO sCountExists FROM bdicred:sd_promocion_credito_sms 
			  	 WHERE num_credito = pCredito AND folio_compra_sms = pFolio AND tipo_sms in('1','2');
				IF sCountExists > 0 THEN
					UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '3' WHERE num_credito = pCredito AND folio_compra_sms = pFolio;
				END IF;
			   
		    ELSE 
		        UPDATE bdicred:sd_maesdos
				   SET sdo_capital = CASE WHEN  cStatus = "BT"  THEN  sdo_capital ELSE sdo_capital + pMonto END, --JMAH sdo_capital + pMonto,
					   sdo_cap_insoluto = sdo_cap_insoluto + pMonto,
					   mto_ministra_cap = mto_ministra_cap + pMonto,
					   cargos_mes_cap   = cargos_mes_cap + pMonto,
					   cap_tras_no_venci = CASE WHEN  cStatus = "BT"  THEN  cap_tras_no_venci + pMonto ELSE cap_tras_no_venci END --JMAH
				 WHERE empresa = pEmpresa
				   AND num_credito = pCredito;
		
			END IF;
	 ELSE
           UPDATE bdicred:sd_maesdos
              SET sdo_capital = CASE WHEN  cStatus = "BT"  THEN  sdo_capital ELSE sdo_capital + pMonto END,-- sdo_capital + pMonto,
                  sdo_cap_insoluto = sdo_cap_insoluto + pMonto,
                  mto_ministra_cap = mto_ministra_cap + pMonto,
                  cargos_mes_cap   = cargos_mes_cap + pMonto,
				  cap_tras_no_venci = CASE WHEN  cStatus = "BT" THEN  cap_tras_no_venci + pMonto ELSE cap_tras_no_venci END --JMAH
            WHERE empresa = pEmpresa
              AND num_credito = pCredito;

	 END IF;

--        LET vCantReg = DBINFO("sqlca.sqlerrd2");
		
	--CALL afecta_amortizacion(pEmpresa, pCredito, pMonto, "1")
	--RETURNING cod_ret;
   	--IF cod_ret <> "000" THEN
	--	RETURN cod_ret;
   	--END IF

   ELIF vTpTran >= "00" AND vTpTran <= "19" THEN
	UPDATE bdicred:sd_maesdos SET sdo_capital = CASE WHEN  cStatus = "BT"  THEN  sdo_capital ELSE sdo_capital + pMonto END, --sdo_capital + pMonto,
			      sdo_cap_insoluto = sdo_cap_insoluto + pMonto,
		              mto_ministra_cap = mto_ministra_cap + pMonto,
          		      cargos_mes_cap   = cargos_mes_cap + pMonto,
					  cap_tras_no_venci = CASE WHEN  cStatus = "BT"  THEN  cap_tras_no_venci + pMonto ELSE cap_tras_no_venci END --JMAH
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito;

	--CALL afecta_amortizacion(pEmpresa, pCredito, pMonto, "1")
	--RETURNING cod_ret;
   	--IF cod_ret <> "000" THEN
	--	RETURN cod_ret;
   	--END IF

   END IF

	IF  dSaldoFavor > 0  THEN 
	   -- **************************
	   -- Aplica Movimiento Diario saldo a favor *
	   -- **************************

	   EXECUTE PROCEDURE genmov_tc(pEmpresa, pCredito, vProducto,
								   pFecha, dSaldoFavor, pFolio, pSucursal,
								   vDivisa, pNumTranFavor, pTarjeta, pReferencia,
					   pTpCambio, pMontoDls, pUsuario, vSucCred,
					   pRfcComer, pRef23)
	   INTO cod_ret, vMensaje;
	END IF;
   -- **************************
   -- Aplica Movimiento Diario *
   -- **************************
	IF  pMonto2 > 0  THEN 
	
		LET pTran2 = pTran;
	 
		IF cStatus = "BT" OR cStatus = "E3" OR cStatus = "E2" THEN --JMAH se registra el movimiento a la transaccion de vencido no exigible
			
			SELECT transacc_vencido
				INTO pTran2
			FROM "informix".sd_conceptoscargoscredito
			WHERE transacc = pTran;	
			
			IF NVL(pTran2,"") = "" THEN
				LET pTran2 = pTran;
			END IF;

			IF cStatus ='E3' AND (pTran2='4314' or pTran2='9133') THEN 
				LET pTran2 = '9460';
			END IF;
		END IF;
	
	
	
	   EXECUTE PROCEDURE genmov_tc(pEmpresa, pCredito, vProducto,
								   pFecha, pMonto2, pFolio, pSucursal,
								   vDivisa, pTran2, pTarjeta, pReferencia,
					   pTpCambio, pMontoDls, pUsuario, vSucCred,
					   pRfcComer, pRef23)
	   INTO cod_ret, vMensaje;
	END IF;
/*
   IF cod_ret <> "000" THEN
	RETURN cod_ret;
   END IF
*/

IF cod_ret <> "000" THEN
  IF wbegin = "S" THEN
        ROLLBACK WORK;
         BEGIN WORK;
  ELSE
        ROLLBACK WORK;
  END IF
  RETURN cod_ret;
END IF


   IF vTpTran = "01" THEN -- Pregunta para guardar sd_detcomi
        INSERT INTO bdicred:sd_detcomi
         (empresa, cod_comis, num_credito, fecha_alta, secuencia,
          fecha_pago, monto_com, monto_pag, apli_factor, estado_com,
          num_solicitud, user_insert, fecha_insert)
        VALUES
         (pEmpresa, pTran, pCredito, pFecha, 0, pFecha,
          pMonto, pMonto, 0, "P", pFolio, USER, TODAY);
   END IF


   -- ************************************************
   -- Ejecuta Aplicacion de Transaccion Relacionada  *
   -- ************************************************
	IF pTran IN ("6212","6218","6219","6220","6221") THEN
		IF MtoIVAFavor>0 THEN
			IF vTranRelacFavor IS NULL THEN
			LET vTranRelacFavor = "0000";
			END IF

			IF vTranRelacFavor <> "0000" THEN
				SELECT tipo_tran INTO vTpTranRelFavor
				  FROM bdinteg:si_transacc
				 WHERE empresa = pEmpresa
				   AND sistema = "06"
				   AND numero = vTranRelacFavor;

				IF vTpTranRelFavor = "22"  OR vTpTranRelFavor = "02" THEN
					--LET MtoRel = pMonto * vIvaSuc;
					
					
					-- Guarda Registro de iva para efectos de recuperacion
					INSERT INTO sd_detcomi
						 (empresa, cod_comis, num_credito, fecha_alta, secuencia,
						  fecha_pago, monto_com, monto_pag, apli_factor, estado_com,
						  num_solicitud, user_insert, fecha_insert)
						VALUES
						 (pEmpresa, vTranRelacFavor, pCredito, pFecha, 0, pFecha,
						  MtoRel, MtoIVAFavor, 0, "P", pFolio, USER, TODAY);
				END IF


				EXECUTE PROCEDURE cargo_cred(pEmpresa, pCredito, pSucursal,
											 pUsuario,vTranRelacFavor, MtoIVAFavor,
											 pFolio, pTarjeta, pMontoDls,
											 pTpCambio, pFecha, pReferencia,
							 "","")

				INTO cod_ret;			
			END IF
		END IF;
	END IF;	
	
	IF vTranRelac IS NULL THEN
		LET vTranRelac = "0000";
	END IF

	IF vTranRelac <> "0000" THEN
		SELECT tipo_tran INTO vTpTranRel
		  FROM bdinteg:si_transacc
		 WHERE empresa = pEmpresa
		   AND sistema = "06"
		   AND numero = vTranRelac;

		IF vTpTranRel = "22"  OR vTpTranRel = "02" THEN
			IF pTran IN ("6212","6218","6219","6220","6221") THEN
				LET MtoRel = MtoIVA2;
			ELSE
				LET MtoRel = pMonto * vIvaSuc;
			END IF;
			
			IF MtoRel >0 THEN
				-- Guarda Registro de iva para efectos de recuperacion
				INSERT INTO sd_detcomi
				 (empresa, cod_comis, num_credito, fecha_alta, secuencia,
				  fecha_pago, monto_com, monto_pag, apli_factor, estado_com,
				  num_solicitud, user_insert, fecha_insert)
				VALUES
				 (pEmpresa, vTranRelac, pCredito, pFecha, 0, pFecha,
				  MtoRel, MtoRel, 0, "P", pFolio, USER, TODAY);
			END IF;
		END IF

		IF MtoRel >0 THEN
			EXECUTE PROCEDURE cargo_cred(pEmpresa, pCredito, pSucursal,
										 pUsuario,vTranRelac, MtoRel,
										 pFolio, pTarjeta, pMontoDls,
										 pTpCambio, pFecha, pReferencia,
						 "","")

			INTO cod_ret;
		END IF;
	END IF
END

IF cod_ret = '000' THEN

    select indicador into vlIndicador
      from bdicred:sd_transfun
     where transacc = pTran;
	if vlIndicador ='V' then
		
	
		   EXECUTE PROCEDURE sp_graba_indicador(pEmpresa, pCredito,pMonto, pTran,'',0,pFecha,pFolio,0,0,1)
			  INTO cod_ret3;
			--Cobro de comision por apertura.
			--IF ( fApertura >= mdy('02','03','2015')) AND TRIM(cCampo_trab4) <>'1' THEN	  
			--AAME RQM 10 679 Se modifica para que solo se cobre comision por apertura al producto '6001'
			--IF ( fApertura >= mdy('02','03','2015')) AND TRIM(cCampo_trab4) <>'1' AND vProducto='6001' THEN	  				 		
            IF ( fApertura >= mdy('02','03','2015')) AND TRIM(cCampo_trab4) <>'1' AND cCobro_Apertu = '1' THEN -- Valida si el producto cobra comision apertura

						/*SELECT monto, nombre_com INTO mMonto , cNombreCom FROM  "informix".sd_tpcomis WHERE empresa = pEmpresa AND cod_comis = '8071';*/
                        SELECT monto, nombre_com INTO mMonto , cNombreCom
                          FROM  "informix".sd_tpcomis WHERE empresa = '001' AND cod_comis = cCodComis_Apert;

						IF mMonto > 0  THEN	  
						
							--Se registra en la tabla de comision para la afectacion contable
							INSERT INTO "informix".sd_comision_x_apertura_contable
							(empresa ,num_credito ,sucursal   ,monto_afectacion,monto_aplicado ,aplica_cobro ,afec_pendientes , proceso_comision, user_insert ,fecha_insert)
							VALUES(pEmpresa, pCredito,pSucursal, mMonto,0,'0',12,'APERTURA',USER,TODAY);			
							
							UPDATE "informix".sd_maecred
							SET campo_trab4 ='1' --se actualiza para indicar que ya se realizo el cobro de la comision por apertura
							WHERE empresa =pEmpresa
							AND num_credito = pCredito;
							
							--Se genera movimiento de la comision por apertura
							EXECUTE PROCEDURE cargo_cred(pEmpresa, pCredito, pSucursal,
														pUsuario,'8071', mMonto,
														pFolio, pTarjeta, 0,
														0, pFecha, cNombreCom, "","")INTO cod_ret;
						END IF;
			END IF;
 
	 end if;
  END IF;
  


IF cod_ret <> "000" THEN
  IF wbegin = "S" THEN
        ROLLBACK WORK;
         BEGIN WORK;
  ELSE
        ROLLBACK WORK;
  END IF
ELSE
  IF wbegin = "N" THEN
        COMMIT WORK;
--         BEGIN WORK;
--  ELSE
--        COMMIT WORK;
  END IF
END IF

   RETURN cod_ret;

END PROCEDURE
DOCUMENT
'Esta funcion se encarga de realizar los movmientos de cargo relacionados a ',
'a la tarjeta de credito',
'AUTOR : Antonio Ruiz Mtz ',
'FECHA : 18/01/2007',
'BD : bdicred ',
'CLIENTE : COPPEL',
'Se Agrega Folio Extendido, se contuinua sin usar afecta_amortizacion 01/03/2010';


