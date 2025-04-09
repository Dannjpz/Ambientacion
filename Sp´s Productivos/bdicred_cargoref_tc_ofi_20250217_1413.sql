






CREATE PROCEDURE "informix".cargoref_tc_ofi(o_empresa  CHAR(3),
				 o_sucursal CHAR(4),
				 o_usuario  CHAR(8),
				 o_tarjeta  CHAR(20),
				 o_monto    DECIMAL(14,2),
				 o_folio    CHAR(16),
				 o_transuc  CHAR(4))

RETURNING CHAR(5),       -- Codigo Retorno
	  DECIMAL(14,2), -- Saldo Disponible 
          DECIMAL(14,2), -- Importe Cargado
	  DECIMAL(14,2), -- Importe Comision
          DECIMAL(14,2); -- Iva de Comisiones

-- **************************************************************************
-- *                      DEFINICION DE VARIABLES                           *
-- **************************************************************************
DEFINE cod_ret            CHAR(5);
DEFINE cod_ret2           CHAR(5);
DEFINE sql_err            SMALLINT;
DEFINE isam_err           SMALLINT;
DEFINE error_info         CHAR(40);
DEFINE Saldo              MONEY(14,2);
DEFINE SaldoCom           MONEY(14,2);
DEFINE v_monto		      MONEY(14,2);
DEFINE v_codparam	   	  CHAR(4);
DEFINE v_fecha            DATE;
DEFINE v_num_credito      CHAR(20);
DEFINE v_divisa		  	  CHAR(2);
DEFINE MtoCgo		  	  MONEY(14,2);
DEFINE MtoCom		   	  MONEY(12,2);
DEFINE v_faplica          CHAR(1);
DEFINE v_factor		 	  DECIMAL(9,6);
DEFINE v_rangos		 	  CHAR(1);
DEFINE v_rmax	          MONEY(14,2);
DEFINE vIva		  		  MONEY(14,2);
DEFINE dMonto		 	  DECIMAL(18,2);
DEFINE cFolioPromo		  CHAR(16);
DEFINE cCodRetGenMov	  CHAR(10);
DEFINE cMsjeGenMov		  CHAR(80);
DEFINE v_dv               CHAR(2);
DEFINE v_tipocambio       DECIMAL(14,6);
DEFINE vsucorig           CHAR(4);
DEFINE vBloqueo           INTEGER;
DEFINE dfh_pre_devol_an   DATE;
DEFINE dfh_devol_an       DATE;
DEFINE dSdoCapInsol       DECIMAL(18,2);
DEFINE cCodRetDevol		  CHAR(5);
DEFINE cMen_retDevol      CHAR(80);
DEFINE dMntoDevol         DECIMAL(16,2);

-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

ON EXCEPTION SET sql_err, isam_err, error_info
   SET DEBUG FILE TO "CargoLineaCredito.err";
--   TRACE sql_err||" * "||isam_err||" * "||error_info;
   LET cod_ret = sql_err;
   LET Saldo = 0;
   RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;
END EXCEPTION;



-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************

LET cod_ret             = "000";
LET Saldo               = 0;
LET cod_ret2            = "000";
LET SaldoCom            = 0;
LET MtoCgo              = 0;
LET MtoCom              = 0;
LET vIva                = 0;
LET dMonto              = 0;
LET cFolioPromo         = "";
LET cCodRetGenMov		= "";
LET cMsjeGenMov		    = "";
LET v_dv                = "00";
LET v_tipocambio        = 0;
LET vsucorig            ="";
LET vBloqueo            = 0;
LET dfh_pre_devol_an    = date(1);
LET dfh_devol_an        = date(1);
LET dSdoCapInsol = 0;
LET cCodRetDevol		= "";
LET cMen_retDevol       = ""; 
LET dMntoDevol          = 0;

--SET DEBUG FILE TO "/tmp/cargofi.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	-- **************************
	-- **************************
	SELECT a.num_credito, b.divisa, b.sucursal, b.id_unidad_prod
	  INTO v_num_credito, v_divisa, vsucorig,   vBloqueo
	  FROM bdicred:"informix".sd_tarjeta a, bdicred:"informix".sd_maecred b
	 WHERE a.empresa = o_empresa
	   AND a.num_tarjeta = o_tarjeta
	   AND b.empresa = a.empresa
	   AND b.num_credito = a.num_credito;

	IF v_num_credito IS NULL THEN
		LET cod_ret = "008";
	        RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;
	END IF

	EXECUTE PROCEDURE bdicred:"informix".cargo_ref_cel(o_tarjeta, o_sucursal, o_usuario,
					o_transuc, o_transuc,  o_folio,
					v_num_credito, 1, o_monto, 0,
					" ", " ", v_divisa, "",  
					o_sucursal, o_usuario, "",
					"", "", v_num_credito,
					1, 0, v_divisa, " ", "2",
					"F"," ", " ", " ", 0, 0, " ", " ")
	INTO cod_ret, v_codparam, v_fecha, Saldo, MtoCgo, 
	     cod_ret2, v_codparam, v_fecha, SaldoCom, MtoCom;

	SELECT SUM(monto_com) INTO vIva 
          FROM bdicred:"informix".sd_detcomi
	 WHERE num_credito = v_num_credito
           AND cod_comis IN ("6260","6261")
	   AND num_solicitud = o_folio
           AND empresa = o_empresa
	   AND num_credito=v_num_credito;

	SELECT SUM(monto_com) INTO MtoCom 
          FROM bdicred:"informix".sd_detcomi
	 WHERE num_credito = v_num_credito
           AND cod_comis IN ("6902","6901")
	   AND num_solicitud = o_folio
           AND empresa = o_empresa
	   AND num_credito=v_num_credito;

       SELECT sdo_cap_insoluto + sdo_retenido    
         INTO SaldoCom                        
         FROM bdicred:"informix".sd_maesdos                         
        WHERE empresa = o_empresa
          AND num_credito=v_num_credito;

	IF MtoCom IS NULL THEN
		LET MtoCom = 0;
		LET vIva   = 0;
	END IF
	
	--JMAH 
	-- OBTIENE EL FOLIO DE LA PROMOCION Y EL MONTO DE LOS INTERESES DE CREDISOLUCIONES
	SELECT folio_movto, monto_int_iva
	INTO cFolioPromo, dMonto
	FROM bdicred:"informix".sd_promocion_credito
	WHERE num_credito = v_num_credito 
	AND folio_movto = o_folio 
	AND status = 6;
	-- VALIDA SI EL CARGO TUVO UNA CREDISOLUCION DE EFECTIVO LIGADA
	IF NVL(cFolioPromo,"") <> "" THEN

        SELECT valor INTO v_dv FROM bdinteg:si_param WHERE cod_param = 17;

		SELECT precio_venta INTO v_tipocambio
	          FROM bdinteg:si_tpcambio
		 WHERE empresa = "001"
		   AND divisa = v_dv
		   AND clase_tpcambio = "O"
		   AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
					   FROM bdinteg:si_tpcambio
					  WHERE empresa = "001"
					    AND divisa = v_dv);

		UPDATE bdicred:"informix".sd_maesdos SET sdo_retenido = sdo_retenido + dMonto
		WHERE empresa = o_empresa
		AND num_credito = v_num_credito;

		INSERT INTO bdicred:"informix".sd_maeretenido
		(empresa, num_credito, folio_suc, fecha, hora, transacc, dias_ret,monto, usuario, estatus, referencia, sucursal, dias_ori)
		VALUES(o_empresa, v_num_credito, o_folio, CURRENT, CURRENT HOUR TO FRACTION(3),"6837", 0, dMonto, o_usuario, "R", trim(cFolioPromo) || ' RET. CREDISOLUCIONES', o_sucursal, 0);	
		
		UPDATE bdicred:"informix".sd_promocion_credito
			SET status = 0
		WHERE num_credito = v_num_credito
		AND folio_movto = o_folio;		

--     GENERAMOS EL MOVIMIENTO DEL RETENIDO DE LOS INTERESES
		EXECUTE PROCEDURE bdicred:"informix".genmov_tc('001',v_num_credito,'6001',TODAY,dMonto,o_folio,o_sucursal,v_divisa,'6837',o_tarjeta,'RET. CREDISOLUCIONES',v_tipocambio,0,o_usuario,vsucorig,'','')
		INTO cCodRetGenMov, cMsjeGenMov;

	END IF;

	-- Devolucion anualidad RQM 10 850 INI
	-- Obtiene marcas de creditos pre-cancelados por devolucion de anualidad
	SELECT nvl(date(ind.fecha_pre_devol_anual),date(1)), nvl(date(ind.fecha_devol_anual),date(1)), dos.sdo_cap_insoluto 
      INTO dfh_pre_devol_an,                       dfh_devol_an,                       dSdoCapInsol
      FROM bdicred:sd_indicador_cred ind JOIN bdicred:sd_maesdos dos ON (ind.empresa = dos.empresa and ind.num_credito = dos.num_credito )
     WHERE ind.empresa = '001' AND ind.num_credito = v_num_credito;
	 
	-- Si el credito tiene devolucion de anualidad, y el retiro termino correctamente, que proceda a marcar el credito como devolucion realizada.
	IF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) = date(1) AND dSdoCapInsol = 0 THEN
		-- Reinicia fecha para validaciones correctas en caso de retiro despues de un reverso del 1er retiro.
        EXECUTE PROCEDURE "informix".sp_comision_anual_devolucion(o_empresa, v_num_credito, o_usuario) INTO cCodRetDevol, cMen_retDevol, dMntoDevol;
		IF (cCodRetDevol = '00000' OR cCodRetDevol = '1208') AND dMntoDevol = 0 THEN
            LET cod_ret = '1208'; -- Retiro de devolucion correcto. Credito se cancelara.
			--LET cod_ret = '0000'; -- Retiro de devolucion correcto. Credito se cancelara.
		END IF

	END IF;
	-- Devolucion anualidad RQM 10 850 FIN

   RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica para contemplar movimientos diferidos, en el proceso de realizar el cargo al crédito', 
'AUTOR: Jesús Aguilar ',
'FECHA: 08 FEBRERO 2012',
'BD: BDICRED',
'DESCRIPCION MODIFICACION: Se cambia el proceso para que guarde la transaccion 6837 en los retenidos de los intereses en lugar de la transaccion de disposición',
'MODIFICO: Mohamed Carreón',
'VERSION: 20120607.0919';


