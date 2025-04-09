-- NO SE OCUPA ESTE SP, TENIA DOS PARTES.






CREATE PROCEDURE "informix".sp_graba_indicador(pempresa CHAR(3), 
                                                       pNumcredito CHAR(20),
													   pMonto DECIMAL(18,2),
                                                       p_transacc  VARCHAR(4),
                                                       pFecha DATE, 
													   pIndicador SMALLINT
													   )  
       RETURNING char(5);
   


--declaracion de variables
------------------------------------------------------------
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info		CHAR(150);
DEFINE	cMensaje		CHAR(80);
DEFINE	cCod_ret		CHAR(6);
--DEFINE	vIndicador		LIKE bdicred:sd_indicador_cred.row;
DEFINE	vCodFun         CHAR(3);
DEFINE	vCodRef         SMALLINT;
DEFINE	vPagoCliente	CHAR(1);

------------------------------------------------
DEFINE vlMontoPrimCompra	LIKE	bdicred:sd_indicador_cred.monto_primer_compra; 
DEFINE vlFechaPrimCompra	LIKE	bdicred:sd_indicador_cred.f_primer_compra;  
DEFINE	vtipotrans			char(1);
DEFINE  vlTransaccion		CHAR(4);

DEFINE vlpos_disp_fecha	DATE; 
DEFINE vlatm_disp_fecha DATE; 
DEFINE vlvnt_disp_fecha DATE; 
DEFINE vlfec_ultimo_pago DATE; 

DEFINE	vlpos_reverso	CHAR(1);
DEFINE	vlatm_reverso	CHAR(1);
DEFINE	vlvtn_reverso	CHAR(1);
DEFINE	vlpag_reverso	CHAR(1);
DEFINE  vMontoAcumulado	DECIMAL(18,2);
DEFINE	vNumTrans	INTEGER;


--vPagoCliente|| '-Indicador-'||pIndicador||'-vtipotrans-'|| vtipotrans  

------------------------------------------------

--SET DEBUG FILE TO '/temp/sp_graba_indicador.out';
--TRACE ON;

    LET cCod_ret      = '000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'PROCESO EXITOSO';
	LET vCodFun       = '';
	LET vCodRef       = '';
	LET vPagoCliente  = '';
	LET vlMontoPrimCompra  = NULL;
	LET vlFechaPrimCompra	= NULL;	
	LET vtipotrans = '';	
	LET vlpos_disp_fecha = DATE(1); 
	LET vlatm_disp_fecha = DATE(1); 
	LET vlvnt_disp_fecha = DATE(1); 
	LET vlfec_ultimo_pago =DATE(1); 
	
	LET	vlpos_reverso	='';
	LET	vlatm_reverso	='';
	LET	vlvtn_reverso	='';
	LET	vlpag_reverso	='';
    
BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            RETURN cCod_ret;
        END EXCEPTION;
		--insert into bdicobranza:cb_bitacora (mensaje) values  ('Primer Compra');		
		SET LOCK MODE TO WAIT 3;		
		---Consulta indicadores que pueden tener reversi�n
		select monto_primer_compra, f_primer_compra, pos_disp_fecha, atm_disp_fecha,  vnt_disp_fecha
		  into vlMontoPrimCompra,  vlFechaPrimCompra, vlpos_disp_fecha, vlatm_disp_fecha, vlvnt_disp_fecha
		 from bdicred:sd_indicador_cred
		WHERE empresa = pEmpresa
          and num_credito = pNumcredito;  
		
		IF (pIndicador =1) OR  (pIndicador =3) THEN 
		  SELECT pago_cliente, tipotrans
          INTO vPagoCliente, vtipotrans
		  FROM bdicred:sd_conceptoscargoscredito
		  WHERE transacc = p_transacc;		  
		ELIF (pIndicador =2) OR  (pIndicador =3) THEN 
		  SELECT pago_cliente, transacc
          INTO vPagoCliente,vlTransaccion
		  FROM sd_conceptospagomanual
		  WHERE cod_fun = p_transacc;
		ELIF (pIndicador =5) or (pIndicador =0) THEN 
		  LET vPagoCliente ='V';
		END IF;
		
		IF vlpos_disp_fecha = date(1)  THEN LET vlpos_reverso = 'R';  END IF;
		IF vlatm_disp_fecha = date(1)  THEN LET vlatm_reverso = 'R';  END IF;
		IF vlvnt_disp_fecha = date(1)  THEN LET vlvtn_reverso = 'R';  END IF;
		IF vlfec_ultimo_pago = date(1) THEN LET vlpag_reverso = 'R';  END IF;		
		--insert into bdicobranza:cb_bitacora (mensaje) values  ('-Indicador'|| pIndicador  );		
		
		LET vMontoAcumulado =pMonto;
		LET vNumTrans =1;
		
		IF (pIndicador =3) THEN  
		  LET vMontoAcumulado =0;		
		  LET vNumTrans =0; 
		END IF;
		
		IF (pIndicador =0) THEN
		    INSERT INTO bdicred:"informix".sd_indicador_cred
		        (empresa,num_credito, fecha_alta)
            VALUES(pempresa,pNumcredito, pFecha );		
		ELIF ( pIndicador =5) THEN -- Convenios		    		  
		    UPDATE bdicred:"informix".sd_indicador_cred
		       SET monto_ult_convenio = pMonto,
			       fecha_ult_convenio = pFecha 				   
			 WHERE empresa = pEmpresa
               AND num_credito = pNumCredito;	   			   
		ELIF vPagoCliente = 'V' THEN 		  
		    IF ( pIndicador =1) THEN --Cargo
		     -- Identifica Primer Compra	
		      IF ( vlMontoPrimCompra IS NULL) THEN
		        LET vlMontoPrimCompra = pMonto;
			    LET vlFechaPrimCompra = pFecha;
				--Actualiza Primer Compra   
				UPDATE bdicred:"informix".sd_indicador_cred
		         SET f_primer_compra = vlFechaPrimCompra,
			         monto_primer_compra = vlMontoPrimCompra				
			   WHERE empresa = pEmpresa
                 and num_credito = pNumCredito;  
			  END IF;	 
			  -- Actualiza Cargo por POS
              IF (vtipotrans = 'P') THEN
			     --IF pIndicador =3 THEN  let vlpos_reverso ='R';  END IF;
			     UPDATE bdicred:"informix".sd_indicador_cred
		            SET pos_disp_monto = pMonto,
						pos_disp_fecha =	pFecha,
						pos_disp_transacc = p_Transacc ,/*
						pos_reverso = vlpos_reverso,
						atm_reverso = vlatm_reverso,					 
						vnt_reverso = vlvtn_reverso,
						pag_reverso = vlpag_reverso,*/						
						num_pos	=   nvl(num_pos,0) +vNumTrans,
						monto_pos = nvl(monto_pos,0) +vMontoAcumulado	
				  WHERE empresa = pEmpresa
					and num_credito = pNumCredito;
			  -- Actualiza Cargo por ATM
		      ELIF (vtipotrans = 'A') THEN 		
				insert into bdicobranza:cb_bitacora (mensaje) values  (vtipotrans );		
			    --IF pIndicador =3 THEN  let vlatm_reverso ='R'; END IF;
		        UPDATE bdicred:"informix".sd_indicador_cred
		         SET atm_disp_monto = pMonto,
					 atm_disp_fecha =	pFecha,
					 atm_disp_transacc = p_transacc ,/*
					 pos_reverso = vlpos_reverso,
					 atm_reverso = vlatm_reverso,					 
					 vnt_reverso = vlvtn_reverso,
					 pag_reverso = vlpag_reverso,*/
					 num_atm	=   nvl(num_atm,0) +vNumTrans,
					 monto_atm = nvl(monto_atm,0) +vMontoAcumulado	
			   WHERE empresa = pEmpresa
                 and num_credito = pNumCredito;
				 
			-- Actualiza Cargo por Ventanilla	 
              ELIF  (vtipotrans = 'V') THEN 
                IF pIndicador =3 THEN  let vlvtn_reverso ='R'; END IF;
		        UPDATE bdicred:"informix".sd_indicador_cred
		         SET vnt_disp_monto = pMonto,
					 vnt_disp_fecha =	pFecha ,/*
					 pos_reverso = vlpos_reverso,
					 atm_reverso = vlatm_reverso,					 
					 vnt_reverso = vlvtn_reverso,
					 pag_reverso = vlpag_reverso,*/
					 num_vtn	=   nvl(num_vtn,0) +vNumTrans,
					 monto_vtn = nvl(monto_vtn,0) +vMontoAcumulado	
			   WHERE empresa = pEmpresa
                 and num_credito = pNumCredito;				
			  END IF;	 
            ELIF ( pIndicador =2) THEN -- Abonos			     
		        ---IF pIndicador =3 THEN  let vlpag_reverso ='R'; END IF;
		          UPDATE bdicred:"informix".sd_indicador_cred
		           SET fecha_ultimo_pago = pFecha,
			       monto_ultimo_pago = pMonto,
                   trans_ultimo_pago = vlTransaccion ,/*
				   pos_reverso = vlpos_reverso,
				   atm_reverso = vlatm_reverso,				   
				   vnt_reverso = vlvtn_reverso,
				   pag_reverso = vlpag_reverso,*/
				   num_pagos   = nvl(num_pagos,0) +vNumTrans,
				   monto_pagos = nvl(monto_pagos,0) +vMontoAcumulado	
			    WHERE empresa = pEmpresa
                 AND num_credito = pNumCredito;		  				 
		    END IF;    		
		  END IF;	
    RETURN cCod_ret;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se inserta o actualiza el indicador de Cr�dito',
'AUTOR : Faviola Mart�nez Ju�rez',
'FECHA : 01/Agosto/2011',
'BD: BDICRED',
'VERSION:201108.1805';

