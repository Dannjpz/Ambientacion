DROP PROCEDURE IF EXISTS "informix".sp_graba_indicador(	  	CHAR(3), 
                                                       	CHAR(20),
													   		DECIMAL(18,2),
                                                       	VARCHAR(4),
													   CHAR(3),
													   INTEGER,
                                                       DATE, 
													   	CHAR(16),
													   	INTEGER,													   
													   	DECIMAL (18,2),
													   SMALLINT
													   );  

CREATE PROCEDURE "informix".sp_graba_indicador(		   pempresa 	CHAR(3), 
                                                       pNumcredito	CHAR(20),
													   pMonto		DECIMAL(18,2),
                                                       pTransacc	VARCHAR(4),
													   pCodigoFun	CHAR(3),
													   pCodigoRef	INTEGER,
                                                       pFecha DATE, 
													   pFolio 	CHAR(16),
													   pVencido		INTEGER,													   
													   Monto2		DECIMAL (18,2),
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
DEFINE	vPagoCliente	CHAR(1);
DEFINE	vcantReg		SMALLINT;
------------------------------------------------
------------------------------------------------
DEFINE	vtipotrans			char(1);
DEFINE	vlSentido		    char(1);
DEFINE  vlTransaccion		CHAR(4);
DEFINE vMtoReversion			DECIMAL(16,2);

DEFINE vFecPrimerCompra		DATE; 
DEFINE vMtoPrimerCompra 	DECIMAL(16,2);
DEFINE vTransPrimerCompra 	CHAR(4);
DEFINE vfecPrimerDisp		DATE; 
DEFINE vMontoPrimerDisp		DECIMAL(16,2); 
DEFINE vTransPrimerDisp		CHAR(4);
DEFINE vFolioPosDisp		CHAR(16);  
DEFINE vFolioAtmDisp		CHAR(16);  
DEFINE vFolioVntDisp		CHAR(16); 		  			  
DEFINE vFecUltPago			DATE; 
DEFINE vMtoUltPago			DECIMAL(16,2);
DEFINE vTransUltPago		CHAR(4);	
DEFINE vFolioUltPago		CHAR(16); 
DEFINE vAtmDispMto			DECIMAL(16,2);
DEFINE vAtmDispFec			DATE;
DEFINE vAtmDispTransacc		CHAR(4);
DEFINE vPosDispMto			DECIMAL(16,2);
DEFINE vPosDispFecha		DATE;
DEFINE vPosDispTransacc		CHAR(4);
DEFINE vvntDispMto			DECIMAL(16,2);
DEFINE vvntDispFec			DATE; 
DEFINE vFecUltPagoRev		DATE; 
DEFINE vMtoUltPagoRev		DECIMAL(16,2);      
DEFINE vTransUltPagoRev		CHAR(4);
DEFINE UltPagoRev		CHAR(16); 
DEFINE vatmDispMtoRev		DECIMAL(16,2);
DEFINE vAtmDispFecRev		DATE;
DEFINE vAtmDispTransaccRev	CHAR(4);
DEFINE vFolioAtmDispRev		CHAR(16); 
DEFINE vPosDispMtoRev		DECIMAL(16,2);
DEFINE vPosDispFecRev		DATE;
DEFINE vPosDispTransaccRev	CHAR(4); 
DEFINE vFolioPosDispRev		CHAR(16); 	    
DEFINE vvntDispMtoRev		DECIMAL(16,2);
DEFINE vvntDispFecRev		DATE; 
DEFINE vFolioVntDispRev		CHAR(16);
DEFINE vfolioultpagorev		CHAR(16);
DEFINE vRevPAGO				CHAR(1);
DEFINE vRevATM				CHAR(1);
DEFINE vRevPOS				CHAR(1);
DEFINE vRevVTN				CHAR(1);
DEFINE vlnum_avisos         CHAR(1);
DEFINE vlSaldoMaximo		DECIMAL (16,2);

DEFINE  vMtoAcumulado	DECIMAL(18,2);
DEFINE	vNumTrans	INTEGER;
DEFINE	bContinua	Char(1);
DEFINE	vlNumVencidos		SMALLINT;
DEFINE  vIndFico    CHAR(1);

--vPagoCliente|| '-Indicador-'||pIndicador||'-vtipotrans-'|| vtipotrans  

------------------------------------------------

--SET DEBUG FILE TO '/temp/sp_graba_indicador.out';
--SET DEBUG FILE TO '/informix/macf/sp_graba_indicador.out';
--TRACE ON;

--SET DEBUG FILE TO "/resplogifx/repaclaraciones/sp_graba_indicador_versionPrincipal.out";
--TRACE ON;

    LET cCod_ret      = '000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'PROCESO EXITOSO';	
	
	LET vPagoCliente  = '';
	LET vMtoPrimerCompra  = NULL;
	LET vFecPrimerCompra	= NULL;		
	LET vtipotrans = '';	
	
	LET vFecPrimerCompra	=DATE(1);
	LET vMtoPrimerCompra 	=0;
	LET vTransPrimerCompra 	='';
	LET vfecPrimerDisp		=NULL;
	LET vMontoPrimerDisp	=NULL;
	LET vTransPrimerDisp	='';
	LET vFolioUltPago		='';
	LET vFolioPosDisp		='';
	LET vFolioAtmDisp		='';
	LET vFolioVntDisp		='';
	LET vFecUltPago			=DATE(1);
	LET vMtoUltPago			=0;
	LET vTransUltPago		='';
	LET vFolioUltPago		='';
	LET vAtmDispMto			=0;
	LET vAtmDispFec			=DATE(1);
	LET vAtmDispTransacc	='';
	LET vFolioAtmDisp		='';
	LET vPosDispMto			=0;
	LET vPosDispFecha		=DATE(1);
	LET vPosDispTransacc	='';
	LET vvntDispMto			=0;
	LET vvntDispFec			=DATE(1);	
	LET vFecUltPagoRev		=DATE(1);
	LET vMtoUltPagoRev		=0;
	LET vTransUltPagoRev	='';
	LET vFolioUltPagoRev	='';
	    
	LET vatmDispMtoRev		=0;
	LET vAtmDispFecRev		=DATE(1);
	LET vAtmDispTransaccRev	='';
	LET vFolioAtmDispRev	='';
	LET vPosDispMtoRev		=0;
	LET vPosDispFecRev		=DATE(1);
	LET vPosDispTransaccRev	='';
	LET vFolioPosDispRev	='';
	LET vvntDispMtoRev		=0;
	LET vvntDispFecRev		=DATE(1);
	LET vFolioVntDispRev	='';	
	LET bContinua = 'V';		
	LET vlSentido = '';
	LET vMtoReversion = 0;  
	LET	vlNumVencidos = 0;
	LET vRevPAGO = '';
	LET vRevATM = '';
	LET vRevPOS = '';
	LET vRevVTN = '';
    LET vlnum_avisos = 0;
	LET vlSaldoMaximo = 0.0;
    LET vIndFico = '';
	
BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			insert into bdicobranza:cb_bitacora (mensaje) values  (error_info);		
            RETURN cCod_ret;
        END EXCEPTION;		
    SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		--insert into bdicobranza:cb_bitacora (mensaje) values  (pCodigoFun||'-Primer Compra-'||pTransacc);		
		---Consulta indicadores que pueden tener reversión
		select ---monto_primer_compra, f_primer_compra, pos_disp_fecha, atm_disp_fecha,  vnt_disp_fecha		
			  f_primer_compra, monto_primer_compra, trans_primer_compra,  	
			  f_primer_disp, monto_primer_disp, trans_primer_disp,    		
			  nvl(folio_ultimo_pago,''), nvl(folio_pos_disp,''), nvl(folio_atm_disp,''), --folio_vnt_disp,       	
			  fecha_ultimo_pago,monto_ultimo_pago,trans_ultimo_pago,nvl(folio_ultimo_pago,''),
			  atm_disp_monto,atm_disp_fecha,atm_disp_transacc,--folio_atm_disp,
		       pos_disp_monto,pos_disp_fecha,pos_disp_transacc, --folio_pos_disp,
               vnt_disp_monto,vnt_disp_fecha, nvl(folio_vnt_disp,''),
			   fecha_ultimo_pago_rev, monto_ultimo_pago_rev, trans_ultimo_pago_rev,nvl(folio_ultimo_pago_rev,''),	    	    
			   atm_disp_monto_rev,atm_disp_fecha_rev,atm_disp_transacc_rev,nvl(folio_atm_disp_rev,''),
		       pos_disp_monto_rev,pos_disp_fecha_rev,pos_disp_transacc_rev, nvl(folio_pos_disp_rev,''),	    
			   vnt_disp_monto_rev,vnt_disp_fecha_rev, nvl(folio_vnt_disp_rev,'')

			   
		  into vFecPrimerCompra, vMtoPrimerCompra, vTransPrimerCompra,  	
			   vfecPrimerDisp, vMontoPrimerDisp, vTransPrimerDisp ,   					   
			   vFolioultPago, vFolioPosDisp, vFolioAtmDisp, --vFolioVntDisp,		  			  
			   vFecUltPago, vMtoUltPago,vTransUltPago,vFolioUltPago,
			   vAtmDispMto,vAtmDispFec,vAtmDispTransacc,--vFolioAtmDisp,
		       vPosDispMto,vPosDispFecha,vPosDispTransacc, --vFolioPosDisp,
               vvntDispMto,vvntDispFec, vFolioVntDisp,			   
			   vFecUltPagoRev, vMtoUltPagoRev, vTransUltPagoRev,vFolioUltPagoRev,
			   vatmDispMtoRev,vAtmDispFecRev,vAtmDispTransaccRev,vFolioAtmDispRev,
		       vPosDispMtoRev,vPosDispFecRev,vPosDispTransaccRev, vFolioPosDispRev,	    
			   vvntDispMtoRev,vvntDispFecRev, vFolioVntDispRev
		 from bdicred:sd_indicador_cred
		WHERE empresa = pEmpresa
          and num_credito = pNumcredito;  
		  
		
		LET vCantReg = DBINFO("sqlca.sqlerrd2");
        --- Inserta el indicador en Caso de que no exista
        IF vCantReg = 0 THEN
            insert into bdicred:"informix".sd_indicador_cred (empresa,num_credito, fecha_alta)
            values(pempresa,pNumcredito, pFecha );
        END IF;  
        
		  SELECT indicador, canal, sentido, indicador_fico
            INTO vPagoCliente, vtipotrans, vlSentido, vIndFico
		    FROM bdicred:sd_transfun		  
		    WHERE (transacc =pTransacc and transacc <>'') or  
			( codigo_fun = pCodigoFun
		      and codigo_ref = pCodigoRef );
			  				  
			--insert into bdicobranza:cb_bitacora (mensaje) values  (pFolio||'?Es Pago?'||vlSentido|| '--'||vFolioVntDisp||'--'||vfolioatmdisp ||'--'||vfolioposdisp);				  
		-- Valida si la operacion es de cargo o abono.
		IF vlSentido = 'C' THEN	
		  select sdo_cap_insoluto   into vlSaldoMaximo
		   from bdicred:sd_maesdos  
           where empresa ='001'
             and num_credito = pNumcredito;
		END IF;
		---Si es un cargo o tiene reverso de cargo		
		IF vlSentido = 'C' THEN
		  if (pIndicador =3) and ( ( pFolio =vFolioVntDisp  or pFolio = vfolioatmdisp or pFolio =vfolioposdisp ) ) then
		  --Hay Reverso del ultimo Folio, se regresan ultimos valores guardados
		    
			if vtipotrans ='V' then				---Canal es Ventanilla  
			  let pFecha    = vvntDispFecRev ;
			  let pMonto    = vvntDispMtoRev ;              
			  let pFolio    = vFolioVntDispRev;						   			  
			  
			  if nvl(vFolioVntDispRev,'') =''  then let vRevVTN ='V'; end if;
			  
			  let vvntDispFecRev = null ;
			  let vvntDispMtoRev= null;
			  let vfoliovntDispRev= null;			   			  
			  LET vMtoReversion = vvntDispMto;  			  			  
			
			elif  vtipotrans ='P' then			---Si es canal POS  
			  let pFecha    = vPosDispFecRev;
			  let pMonto    = vPosDispMtoRev ;
              let pTransacc = vPosDispTransaccRev;
			  let pFolio    = vFolioPosDispRev;						  
			  
			  if nvl(vFolioPosDispRev,'')='' then let vRevPOS ='V'; end if;

			  let vposDispFecRev = null ;
			  let vposDispMtoRev= null;
              let vposDispTransaccRev= null;			  
			  let vfolioPosDisp= null;		  
			  LET vMtoReversion = vPosDispMto;  			  
			
			elif  vtipotrans ='A' then			---Si es canal ATM
			  let pFecha    = vAtmDispFecRev ;
			  let pMonto    = vatmDispMtoRev ;
              let pTransacc = vAtmDispTransaccRev;
			  let pFolio    = vFolioAtmDispRev;						  
			  
			  if nvl(vFolioAtmDispRev,'')=''  then let vRevATM ='V'; end if;
			  
			  let vatmDispFecRev = null ;
			  let vatmDispMtoRev= null;
              let vatmDispTransaccRev= null;
			  let vfolioatmDispRev= null;			  
			  LET vMtoReversion = vAtmDispMto;  
			end if;
		  elif (pIndicador =3) and ( ( pFolio =Nvl(vFolioVntDispRev,'')  or pFolio = Nvl(vFolioAtmDispRev,'') or 
		                               pFolio =Nvl(vFolioPosDispRev,'') ) ) then
		     -- Si el que se va a reversar es el folio de respaldo se limpian los valores de Respaldo
		    if vtipotrans ='V' then
			  let vvntDispFecRev = null;
			  let vvntDispMtoRev= null;
			  let vfoliovntDispRev= null;
			  
			elif  vtipotrans ='P' then
			  let vposDispFecRev = null;
			  let vposDispMtoRev= null;
			  let vposDispTransaccRev= null;
			  let vfolioPosDisp= null;
			  
			elif  vtipotrans ='A' then			  
			  let vatmDispFecRev = null;
			  let vatmDispMtoRev= null;
			  let vatmDispTransaccRev= null;
			  let vfolioatmDispRev= null;
			  
			end if;		  
		  elif (pIndicador =3) and ( pFolio <>vFolioVntDisp  AND pFolio <> vfolioatmdisp AND pFolio <> vfolioposdisp )then
		    --Si es Reversión de un  folio distinto no se realiza ningun accion .
            let bContinua = 'F'; 
          end if;			
		  if (pIndicador =1) then
		    /* Si es el indicador de Pago sin reversa, se asignan a los campos de reversa los
			 datos del registro anterior.    */			
	        if vtipotrans ='V' then
			  let vvntDispFecRev = vvntDispFec ;
			  let vvntDispMtoRev= vvntDispMto;
			  let vfoliovntDispRev= vFolioVntDisp;			  
			  
            elif  vtipotrans ='P' then
			  let vposDispFecRev = vPosDispFecha ;
			  let vposDispMtoRev= vPosDispMto;
              let vposDispTransaccRev= vPosDispTransacc;			  
			  let vfolioPosDisp= vfolioPosDisp;		  
			  
	        elif  vtipotrans ='A' then			
			  let vatmDispFecRev = vAtmDispFec ;
			  let vatmDispMtoRev= vAtmDispMto;
              let vatmDispTransaccRev= vAtmDispTransacc;
			  let vfolioatmDispRev= vFolioAtmDisp;			  
			  
		    end if;
		  end if;	---Indicador de Cargo
		ELIF  vlSentido = 'A' THEN  ---- Si es pago o Reverso de Pago		   		  
		  if (pIndicador =3) and ( pFolio = vFolioultPago ) then --- Verifica Reverso de Ultimo Pago		  
		    --Si es el mismo Folio se regresan los valores anteriores.
			let pFecha    = vFecUltPagoRev ;
			let pMonto    = vMtoUltPagoRev ;
            let pCodigoFun = vTransUltPagoRev;
			let pFolio    = vFolioUltPagoRev;						
			if (nvl(vFolioUltPagoRev,'')  ='')  then let vRevPAGO ='V'; end if;			
			let vfecultpagoRev = null;
			let vmtoUltpagoRev= null;
            let vtransUltpagoRev= null;
			let vfolioultpagoRev= null;						
			LET vMtoReversion = vMtoUltPago;  
	  
		  elif (pIndicador =3) and ( pFolio = vFolioUltPagoRev ) then	
		    let vfecultpagoRev = null;
			let vmtoUltpagoRev= null;
            let vtransUltpagoRev= null;
			let vfolioultpagoRev= null;
			
		  elif (pIndicador =3) and ( pFolio <> vFolioultPago ) then 
            let bContinua = 'F'; 	
		  end if;		  
		  if (pIndicador =2) then
		    --En los campos de reverso se guardan los valores anteriores
		    let vfecultpagoRev = vFecUltPago ;
			let vmtoUltpagoRev= vMtoUltPago;
            let vtransUltpagoRev= vTransUltPago;
			let vfolioultpagoRev= vFolioUltPago;
						
			SELECT COUNT(num_credito)		  
			  INTO vlNumVencidos
		      FROM "informix".sd_amortiza_credito
		     WHERE empresa     = pempresa
		       AND num_credito = pNumcredito
		       AND capital_status IN ('2','7','6');			   			   
		  end if;	
		END IF;
		---Monto Acumulado es igual al Monto de la transaccion y el Numero de transacción es 1
		LET vMtoAcumulado =pMonto;
		LET vNumTrans =1;
		---Monto Acumulado es igual al Monto de la transaccion y el Numero de transacción es 1
		IF (pIndicador =3) and (bContinua ='V') THEN  
		  LET vMtoAcumulado = (Nvl(vMtoReversion,0)) * -1;		
		  LET vNumTrans =-1; 
		END IF;
--insert into bdicobranza:cb_bitacora (mensaje) values  ('Vencidos'||vlNumVencidos||'bContinua'||bContinua||'pindicador'||pindicador);				  		
		------ Convenios
		IF ( pindicador =5)  then let bContinua ='V'; end if;   
		IF (bContinua ='V' ) then 		
			if ( pindicador =5) then 		    		  
				update bdicred:"informix".sd_indicador_cred
				set monto_ult_convenio = pmonto,
			       fecha_ult_convenio = pfecha 				   
				where empresa = pempresa
				  and num_credito = pnumcredito;	   			   
			elif vpagocliente = 'V' then 		  				
			  if (vlSentido = 'C' ) then
				-- identifica primer compra					
				 if ( vMtoPrimerCompra is null)  then
				   let vMtoPrimerCompra = pmonto;
				   let vFecPrimerCompra = pfecha;
                   let vTransPrimerCompra = pTransacc;
                 end if;
                 if ( vMontoPrimerDisp is null)  then
				   let vMontoPrimerDisp = pmonto;
				   let vfecPrimerDisp = pfecha;
                   let vTransPrimerDisp = pTransacc;
                 end if;
				 --actualiza primer compra   
				  -- update bdicred:"informix".sd_indicador_cred
		         -- --    set f_primer_compra = vFecPrimerCompra,
			          --    monto_primer_compra = vMtoPrimerCompra				
			        ---where empresa = pempresa
                     -- and num_credito = pnumcredito;  
			      
			  -- actualiza cargo por pos
              if (vtipotrans = 'P') then			     
			     update bdicred:"informix".sd_indicador_cred
		            set pos_disp_monto 		= pmonto,
						pos_disp_fecha 		= pfecha,
						pos_disp_transacc 	= ptransacc,
						folio_pos_disp 		= pfolio,
						pos_disp_fecha_rev 	= vPosDispFecRev,
						pos_disp_monto_rev	= vPosDispMtoRev,
						pos_disp_transacc_rev= vPosDispTransaccRev,
						folio_pos_disp_rev	= vFolioPosDispRev,							
						num_pos				=   nvl(num_pos,0) +vnumtrans,
						monto_pos 			= nvl(monto_pos,0) +vmtoacumulado,
                        num_posc				=   nvl(num_posc,0) +vnumtrans,
						monto_posc			= nvl(monto_posc,0) +vmtoacumulado,
						pos_reverso			= vRevPOS,
                        f_primer_compra = vFecPrimerCompra,
                        monto_primer_compra = vMtoPrimerCompra,
                        trans_primer_compra= vTransPrimerCompra,
                        fecha_ultima_compra = pfecha,
                        monto_ultima_compra = pmonto,
						saldo_maximo = (case when saldo_maximo >= vlSaldoMaximo then saldo_maximo else vlSaldoMaximo end),
						fecha_sdo_maximo = (case when saldo_maximo >= vlSaldoMaximo then fecha_sdo_maximo else pfecha end),
                        fechaultimocambio = current
				  where empresa = pempresa
					and num_credito = pnumcredito;
			  -- actualiza cargo por atm
		      elif (vtipotrans = 'A') then 									  
		        update bdicred:"informix".sd_indicador_cred
		         set atm_disp_monto 	= pmonto,
					 atm_disp_fecha 	=	pfecha,
					 atm_disp_transacc 	= ptransacc ,					 
					 folio_atm_disp		= pFolio,					 
					 atm_disp_fecha_rev = vAtmDispFecRev ,
					 atm_disp_monto_rev	= vatmDispMtoRev,
					 atm_disp_transacc_rev	= vAtmDispTransaccRev,
					 folio_atm_disp_rev		= vFolioAtmDispRev,					 
					 num_atm				=   nvl(num_atm,0) +vnumtrans,
					 monto_atm 				= nvl(monto_atm,0) +vmtoacumulado,
					 atm_reverso			= vRevATM,
                     num_atmc				=   nvl(num_atmc,0) +vnumtrans,
					 monto_atmc				= nvl(monto_atmc,0) +vmtoacumulado,
                     f_primer_disp  = vfecPrimerDisp,
                     monto_primer_disp = vMontoPrimerDisp,
                     trans_primer_disp = vTransPrimerDisp,
                     fecha_ultima_compra = pfecha,
                     monto_ultima_compra = pmonto,
					 saldo_maximo = (case when saldo_maximo >= vlSaldoMaximo then saldo_maximo else vlSaldoMaximo end),
					 fecha_sdo_maximo = (case when saldo_maximo >= vlSaldoMaximo then fecha_sdo_maximo else pfecha end),
                     fechaultimocambio = current,
					 -- RQM 09 473 Triad MACF
					 comision_disp_efectivo = (case when vIndFico = '1' then nvl(comision_disp_efectivo,0) + pmonto else nvl(comision_disp_efectivo,0) end),
					 monto_otras_trnx = (case when vIndFico = '4' then nvl(monto_otras_trnx,0) + pmonto else nvl(monto_otras_trnx,0) end),  --6893,6894,6895
					 comision_anualidad = (case when vIndFico = '5' then nvl(comision_anualidad,0) + pmonto else nvl(comision_anualidad,0) end) -- 8244 y 8246
					 -- RQM 09 473 Triad MACF
			   where empresa = pempresa
                 and num_credito = pnumcredito;				 
			-- actualiza cargo por ventanilla	 
              elif  (vtipotrans = 'V') then                 
		        update bdicred:"informix".sd_indicador_cred
		         set vnt_disp_monto 	= pmonto,
					 vnt_disp_fecha 	=	pfecha ,
					 num_vtn			=   nvl(num_vtn,0) +vnumtrans,
					 monto_vtn 			= nvl(monto_vtn,0) +vmtoacumulado,
                     num_vtnc			=   nvl(num_vtnc,0) +vnumtrans,
					 monto_vtnc 			= nvl(monto_vtnc,0) +vmtoacumulado,
					 folio_vnt_disp 	= pFolio,
	                 vnt_disp_fecha_rev = vvntDispFecRev ,
					 vnt_disp_monto_rev	= vvntDispMtoRev,
					 folio_vnt_disp_rev	= vFolioVntDispRev,
					 vnt_reverso			= vRevATM,
                     f_primer_disp  = vfecPrimerDisp,
                     monto_primer_disp = vMontoPrimerDisp,
                     trans_primer_disp = vTransPrimerDisp,
                     fecha_ultima_compra = pfecha,
                     monto_ultima_compra = pmonto,
					 saldo_maximo = (case when saldo_maximo >= vlSaldoMaximo then saldo_maximo else vlSaldoMaximo end),
					 fecha_sdo_maximo = (case when saldo_maximo >= vlSaldoMaximo then fecha_sdo_maximo else pfecha end),
                     fechaultimocambio = current,
					 -- RQM 09 473 Triad MACF
					 num_pagos_hist = nvl(num_pagos_hist,0) + 1,
					 comision_disp_efectivo = (case when vIndFico = '1' then nvl(comision_disp_efectivo,0) + pMonto else nvl(comision_disp_efectivo,0) end),
					 comision_apertura = (case when vIndFico = '2' then nvl(comision_apertura,0) + pmonto else 0 end), 
					 fecha_comision_apertura = (case when vIndFico = '2' then pfecha else date(1) end),
					 monto_otras_trnx = (case when vIndFico = '4' then nvl(monto_otras_trnx,0) + pMonto else nvl(monto_otras_trnx,0) end) --7577,7578
					 -- RQM 09 473 Triad MACF
					 
			   where empresa = pempresa
                 and num_credito = pnumcredito;								
			  end if;	 
            --elif ( pindicador =2) then -- abonos			     		        
			elif (vlSentido = 'A' ) then
			--insert into bdicobranza:cb_bitacora (mensaje) values  ('Aplica Pago'||pnumcredito);				  
		          update bdicred:"informix".sd_indicador_cred		           
				   set fecha_ultimo_pago 	= pfecha,
			       monto_ultimo_pago 		= pmonto,
                   trans_ultimo_pago 		= pCodigoFun, --vltransaccion,
				   folio_ultimo_pago 		= pfolio,				   
				   --folio_ultimo_pago = vFolioUltPago,			
				   fecha_ultimo_pago_rev 	= vFecUltPagoRev ,
				   monto_ultimo_pago_rev	= vMtoUltPagoRev ,
				   trans_ultimo_pago_rev	= vTransUltPagoRev,
				   folio_ultimo_pago_rev	= vFolioUltPagoRev,			
				   num_pagos   = nvl(num_pagos,0) +vnumtrans,
				   monto_pagos = nvl(monto_pagos,0) +vmtoacumulado,
                   num_pagosc   = nvl(num_pagosc,0) +vnumtrans,
				   monto_pagosc = nvl(monto_pagosc,0) +vmtoacumulado,
                   num_vencidos = vlNumVencidos,
				   reverso_ultimo_pago = vRevPago ,   
                   fechaultimocambio = current,
				   -- RQM 09 473 Triad MACF
				   monto_devoluciones = (case when vIndFico = '3' then nvl(monto_devoluciones,0) + pMonto else nvl(monto_devoluciones,0) end), -- 6813
				   monto_otras_trnx = (case when vIndFico = '4' then nvl(monto_otras_trnx,0) + pMonto else nvl(monto_otras_trnx,0) end)  --7041,8249,8251
				   -- RQM 09 473 Triad MACF
				   
			    where empresa = pempresa
                 and num_credito = pnumcredito;		  				 
			--insert into bdicobranza:cb_bitacora (mensaje) values  ('Aplica Pago'||pnumcredito);				  	 
		    end if;    		
		  end if;	
		End if;  
    RETURN cCod_ret;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se inserta o actualiza el indicador de Crédito',
'AUTOR : Faviola Martínez Juárez',
'FECHA : 01/Agosto/2011',
'BD: BDICRED',
'VERSION:201108.1805';


