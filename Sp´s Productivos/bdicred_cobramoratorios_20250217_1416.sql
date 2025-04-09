






CREATE PROCEDURE "informix".cobramoratorios(e_fcuota DATE)
   RETURNING CHAR(5);

   DEFINE CodRet              CHAR(5);
   DEFINE Mensaje             CHAR(80);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nRows               SMALLINT;

   DEFINE GLOBAL g_Empresa      CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito   CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto  CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente    MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha        DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa       CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun    CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio        CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_TpPago       SMALLINT    DEFAULT 0;
   DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL g_Moratorio    MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntMoraCob   MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_ManejaLinea  CHAR(1)     DEFAULT ' ';
   DEFINE GLOBAL g_SdoMoratorio MONEY(14,2) DEFAULT 0;
   DEFINE dSdoMoraOrdi          MONEY(14,2);
   DEFINE dSdoMoraCope          MONEY(14,2);

   DEFINE vPerContMora          CHAR(1);
   DEFINE vFechaCuota           DATE;
   DEFINE vProviMoraOrdi        LIKE sd_detmora.provi_mora_ordi;
   DEFINE vProviMoraCope        LIKE sd_detmora.provi_mora_cope;
   DEFINE vSdoMoraOrdi          LIKE sd_detmora.sdo_mora_ordi;
   DEFINE vSdoMoraCope          LIKE sd_detmora.sdo_mora_cope;
   DEFINE vMontoMora            LIKE sd_detmora.sdo_acum_mes_mora;
   DEFINE vCodigoRef            SMALLINT;
   
   
	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "CobraMoratorios.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET CodRet = sql_err;
		RETURN CodRet;
	END EXCEPTION;

   --SET DEBUG FILE TO "/home/tmp/MireyaR/cobramoratorios.out";
   --TRACE ON;
   
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT valor
	INTO vPerContMora
	FROM "informix".sd_param
	WHERE empresa = g_Empresa
	AND cod_param = '17';

	LET CodRet      = "000";
	LET vCodigoRef  = 2;
	LET vMontoMora  = 0;
	LET g_Moratorio = 0;
	LET g_Remanente = g_Remanente;


	FOREACH
		SELECT fecha_cuota, mora_sdo_ordi - mora_sdo_ordi_pag, 
		mora_sdo_cope - mora_sdo_cope_pag
		INTO vFechaCuota, vSdoMoraOrdi, vSdoMoraCope
		FROM "informix".sd_amortiza_credito
		WHERE empresa = g_Empresa
		AND num_credito = g_NumCredito
		--AND capital_status in ('2','7')
		AND capital_status in ('2','7','6') --Se agrega nuevo estatus para IFRS
		AND (mora_sdo_ordi - mora_sdo_ordi_pag) + 
		(mora_sdo_cope - mora_sdo_cope_pag) > 0
		ORDER BY 1

		IF g_TpPago = "2" AND vFechaCuota <> e_fcuota THEN
			CONTINUE FOREACH;
		END IF

		LET dSdoMoraOrdi = vSdoMoraOrdi;
		LET dSdoMoraCope = vSdoMoraCope;

		IF(g_Remanente > 0) THEN
			IF(g_Remanente >= vSdoMoraCope) THEN
				LET g_Remanente   = g_Remanente - vSdoMoraCope;
				LET vMontoMora    = vMontoMora + vSdoMoraCope;
			ELSE
				LET vSdoMoraCope  = g_Remanente;
				LET vMontoMora    = vMontoMora + g_Remanente;
				LET g_Remanente   = 0;
			END IF;
			IF(g_Remanente >= vSdoMoraOrdi) THEN
				LET g_Remanente   = g_Remanente - vSdoMoraOrdi;
				LET vMontoMora    = vMontoMora + vSdoMoraOrdi;
			ELSE
				LET vSdoMoraOrdi  = g_Remanente;
				LET vMontoMora    = vMontoMora + g_Remanente;
				LET g_Remanente   = 0;
			END IF;


			UPDATE "informix".sd_amortiza_credito
			SET mora_sdo_ordi_pag = mora_sdo_ordi_pag + vSdoMoraOrdi,
			mora_sdo_cope_pag = mora_sdo_cope_pag + vSdoMoraCope
			WHERE empresa = g_Empresa
			AND num_credito = g_NumCredito
			AND fecha_cuota = vFechaCuota;
			
			LET g_Moratorio = g_Moratorio + vMontoMora;
			LET vSdoMoraOrdi = 0;
			LET vSdoMoraCope = 0;

			--MRV
			IF g_Transacc IN ('7795','7796')  THEN--GENERA MOVIMIENTO DE CONDONACION/CONDONACION POR FALLECIMIENTO DE INTERESES MORA BASE E INTERESES MORA COPETE

				--GENERA MOVIMIENTO POR EL COBRO DE INTERES MORATORIOS BASE
			 
			   IF g_NumProducto = '6001' THEN
			   
				   LET vCodigoref  = '2'; --INTERESES MORATORIOS BASE
			   
			   END IF;
			   
			   CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,
					   g_CodigoFun, g_Fecha, dSdoMoraOrdi, g_Folio,
					   g_Sucursal, g_Divisa, g_Transacc) RETURNING
					   CodRet, Mensaje;
					   
			  --GENERA MOVIMIENTO POR EL COBRO DE INTERES MORATORIOS COPETE
			  
				IF g_NumProducto = '6001' THEN
			   
				   LET vCodigoref  = '3'; --INTERESES MORATORIOS COPETE
			   
				END IF;
				
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,
					   g_CodigoFun, g_Fecha, dSdoMoraCope, g_Folio,
					   g_Sucursal, g_Divisa, g_Transacc) RETURNING
					   CodRet, Mensaje;


			ELSE
				-- Genera Movimiento de Recuperacion de Mora
				IF g_Transacc = '9854' THEN
					LET vCodigoref = 43;
				ELIF g_Transacc = '4356' THEN
					LET vCodigoref = 100;
				END IF;
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,vCodigoref,
				g_CodigoFun, g_Fecha, vMontoMora, g_Folio,
				g_Sucursal, g_Divisa, g_Transacc) RETURNING
				CodRet, Mensaje;
				
                -- Genera Movmiento de Provision Mora
				IF g_Transacc = '9854' THEN --PAGO ATM CGO CUENTA
					CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,45,
					"059", g_Fecha, vMontoMora, g_Folio,
					g_Sucursal, g_Divisa, g_Transacc) RETURNING
					CodRet, Mensaje;
				ELIF g_Transacc = '4356' THEN --PAGO ATM EFECTIVO
					CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,102,
					"059", g_Fecha, vMontoMora, g_Folio,
					g_Sucursal, g_Divisa, g_Transacc) RETURNING
					CodRet, Mensaje;
                ELIF g_TRansacc <> '8638' AND g_TRansacc <> '9854' AND g_TRansacc <> '4356' THEN				  
					CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,1,
					"607", g_Fecha, vMontoMora, g_Folio,
					g_Sucursal, g_Divisa, g_Transacc) RETURNING
					CodRet, Mensaje;
				END IF;
				LET vMontoMora  = 0;
			END IF;
		END IF;
	END FOREACH;

	-- Actualiza sd_maesdos
	LET g_Moratorio = g_Moratorio;
	UPDATE "informix".sd_maesdos
	SET sdo_moratorio = sdo_moratorio - g_Moratorio
	WHERE empresa = g_Empresa
	AND num_credito = g_NumCredito;

	LET g_IntMoraCob = g_IntMoraCob + g_Moratorio;
	LET g_Moratorio = 0;

	IF (CodRet <> "00000") THEN
		RETURN CodRet;
	ELSE
		LET CodRet = "000";
	END IF;

RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de intereses moratorios, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED',
'MODIFICACION: Se contemplan las transacciones 7795 y 7796 para condonacion de intereses moratorios para la TDC.',
'AUTOR : Mireya Gpe Reyes Vargas',
'FECHA : 3/enero/2014',
'FOLIO: 1395 - Condonacion de intereses para TDC,PP y CREDINOMINA .',
'BD    : BDICRED';


