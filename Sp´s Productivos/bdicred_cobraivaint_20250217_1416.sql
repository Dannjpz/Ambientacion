






CREATE PROCEDURE "informix".cobraivaint(e_fcuota DATE)
   RETURNING CHAR(5);

   DEFINE CodRet              CHAR(5);
   DEFINE Mensaje             CHAR(80);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nRows               SMALLINT;

   DEFINE GLOBAL g_Empresa          CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito       CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Impuesto         MONEY(14,2) DEFAULT 0;
--   DEFINE GLOBAL g_Seguro           MONEY(14,2) DEFAULT 0;
--   DEFINE GLOBAL g_Comision         MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha            DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal         CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa           CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc         CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_TpPago           SMALLINT    DEFAULT 0;
--   DEFINE GLOBAL g_MontoFinanciado  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_StCred           CHAR(2)     DEFAULT ' ';

   DEFINE GLOBAL g_CodigoFun        CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio            CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_Iva              MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MoraIva          MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IvaCte	    DECIMAL(9,6) DEFAULT 0;

   DEFINE wCodRefMora               SMALLINT;
   DEFINE wCodComis                 CHAR(4);
   DEFINE wNumCredito               CHAR(20);
   DEFINE wMontoCom                 MONEY(14,2);
   DEFINE wFechaPago                DATE;
   DEFINE wmCom                     MONEY(14,2);
   DEFINE wmPag                     MONEY(14,2);
   DEFINE wEstadoCom                CHAR(1);
   DEFINE wTpCom                    CHAR(1);

   DEFINE vFechaCuota            LIKE sd_amortiza_credito.fecha_cuota;
   DEFINE vCuotaRec              LIKE sd_pagocapit.cuota_rec;
   DEFINE vIvadebe               LIKE sd_amortiza_credito.iva_debe;
   DEFINE vIvaPagado             LIKE sd_amortiza_credito.iva_pagado;
   DEFINE vIvaAdeudo             LIKE sd_amortiza_credito.iva_debe;
   DEFINE vIvaStatus             LIKE sd_amortiza_credito.iva_status;
   DEFINE vMoraIvaDebe           LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaPagado         LIKE sd_amortiza_credito.mora_iva_pagado;
   DEFINE vMoraIvaAdeudo         LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaStatus         LIKE sd_amortiza_credito.mora_iva_status;
   DEFINE vIvaBase		         DECIMAL(9,6);

   DEFINE vCodFunIva             CHAR(3);

	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "CobraIva.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET CodRet = sql_err;
		RETURN CodRet;
	END EXCEPTION;

		--SET DEBUG FILE TO "CobraIva.out";
		--TRACE ON;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		LET CodRet     = "000";
		--   LET vCodFunIva = "340";

		-- *****************************
		-- Extrae Iva Base del Sistema *
		-- *****************************
		SELECT valor INTO vIvaBase 
		FROM bdinteg:"informix".si_param
		WHERE empresa = g_Empresa
		AND cod_param = 47;


		IF g_Transacc NOT IN ('7795', '7796') THEN

--			IF g_CodigoFun = '337' THEN          --- BC.HEMI.170908 SE IDENTIFICA EL CANAL DE INTERNET
--				LET vCodFunIva = "337";
--				IF vIvaBase <> g_IvaCte THEN
--					LET wCodRefMora = 12;
--				ELSE
--					LET wCodRefMora = 11;
--				END IF

--			ELSE
				LET vCodFunIva = g_CodigoFun;
				IF vIvaBase <> g_IvaCte THEN
					LET wCodRefMora = 6617;
				ELSE
					LET wCodRefMora = 6616;
				END IF;
--			END IF;
		ELSE

			LET vCodFunIva = g_CodigoFun;
		-- 21062018 AAME RQM 06590 y RQM 06 591 Se contemplan los productos oro y Platino, se agrega TDC GP
			IF g_NumProducto IN ('6001','7000','8100','8500') THEN --TDC

				LET wCodrefMora  = '4'; --IVA DE INTERESES MORATORIOS 

			END IF; 	

		END IF;

		-- *************************************
		-- Calcula Iva de Intereses Moratorios *
		-- *************************************
		FOREACH
			SELECT fecha_cuota, mora_provi_ordi + mora_provi_cope
			INTO vFechaCuota, vMoraIvaDebe
			FROM "informix".sd_amortiza_credito
			WHERE num_credito = g_NumCredito
			AND empresa =  g_empresa
			--AND capital_status IN ("2","7")
			AND capital_status in ('2','7','6') --Se agrega nuevo estatus para IFRS
			AND (mora_provi_ordi + mora_provi_cope) > 0
			ORDER BY 1

			IF g_TpPago = "2" THEN
				IF e_fcuota <> vFechaCuota THEN
					CONTINUE FOREACH;
				END IF
			END IF;

			LET vMoraIvaDebe = vMoraIvaDebe * g_IvaCte;

			UPDATE "informix".sd_amortiza_credito
			SET mora_sdo_ordi = mora_sdo_ordi + mora_provi_ordi,
			mora_sdo_cope = mora_sdo_cope + mora_provi_cope,
			mora_provi_cope = 0,
			mora_provi_ordi = 0,
			mora_iva_debe = mora_iva_debe + vMoraIvaDebe
			WHERE num_credito = g_NumCredito
			AND empresa =  g_empresa
			AND fecha_cuota = vFechaCuota;

		END FOREACH
		--CAS INI
		UPDATE "informix".sd_maesdos SET sdo_contab_mora = 0,
		sdo_moratorio = sdo_moratorio + sdo_contab_mora 
		WHERE num_credito = g_NumCredito
		AND empresa =  g_empresa;
		--CAS FIN
		FOREACH
			SELECT fecha_cuota, (mora_iva_debe - mora_iva_pagado)
			INTO vFechaCuota, vMoraIvaDebe
			FROM "informix".sd_amortiza_credito a
			WHERE a.empresa   = g_empresa
			AND a.num_credito = g_NumCredito
			--AND capital_status IN ("2","7")
			AND capital_status in ('2','7','6') --Se agrega nuevo estatus para IFRS
			AND (mora_iva_debe - mora_iva_pagado) > 0
			ORDER BY fecha_cuota

			IF g_TpPago = "2" THEN
				IF e_fcuota <> vFechaCuota THEN
					CONTINUE FOREACH;
				END IF
			END IF;

			IF (g_Remanente > 0) THEN
				IF g_Remanente >= vMoraIvaDebe then
					LET g_Remanente    = g_Remanente - vMoraIvaDebe;
				ELSE
					LET vMoraIvaDebe = g_Remanente;
					LET g_Remanente    = 0;
				END IF;

				UPDATE "informix".sd_amortiza_credito
				SET mora_iva_pagado     = mora_iva_pagado + vMoraIvaDebe,
				mora_iva_fecha_pago = g_fecha
				WHERE empresa     = g_empresa
				and   num_credito = g_NumCredito
				and   fecha_cuota = vFechaCuota;

				LET g_MoraIva = g_MoraIva + vMoraIvaDebe;  

				IF g_Transacc = '9854' and wCodRefMora = 6617 THEN --PAGO ATM CGO CUENTA
					LET wCodRefMora = 44;
				ELIF g_Transacc = '9854' and wCodRefMora = 6616 THEN --PAGO ATM CGO CUENTA
					LET wCodRefMora = 43;
				ELIF g_Transacc = '4356' and wCodRefMora = 6617 THEN --PAGO ATM EFECTIVO
					LET wCodRefMora = 101;
				ELIF g_Transacc = '4356' and wCodRefMora = 6616 THEN --PAGO ATM EFECTIVO
					LET wCodRefMora = 100;
				END IF;
				CALL "informix".GenMov(g_Empresa, g_NumCredito, g_NumProducto,wCodrefMora,
				vCodFunIva, g_Fecha, vMoraIvaDebe, g_Folio,
				g_Sucursal, g_Divisa, g_Transacc) RETURNING
				CodRet, Mensaje;
				IF (CodRet <> "00000") THEN
					RETURN CodRet;
				ELSE
					LET Codret = "000";
				END IF;
			END IF;

		/*{IF g_Remanente > 0 and vIvaStatus <> '5' then
		IF (g_Remanente >= vIvaAdeudo) THEN
		LET g_Remanente = g_Remanente - vIvaAdeudo;
		LET vIvaStatus = '5';
		ELSE
		LET vIvaAdeudo  = g_Remanente;
		LET g_Remanente = 0;
		END IF;

		UPDATE sd_amortiza_credito
		SET 
		iva_pagado     = iva_pagado + vIvaAdeudo,
		iva_status     = vIvaStatus,
		iva_fecha_pago = g_fecha
		WHERE
		empresa     = g_empresa
		and num_credito = g_NumCredito
		and fecha_cuota = vFechaCuota;


		LET g_Iva = g_Iva + vIvaAdeudo;  
		LET wCodigoRef = 2 ; 
		CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto, wCodigoref,
		g_CodigoFun, g_Fecha, vIvaAdeudo, g_Folio,
		g_Sucursal, g_Divisa, g_Transacc) RETURNING
		CodRet, Mensaje;
		IF (CodRet <> "00000") THEN
		RETURN CodRet;
		ELSE
		LET Codret = "000";
		END IF;
		END IF;}*/
		END FOREACH;
RETURN CodRet;
END PROCEDURE
DOCUMENT
'Modifica: Mireya Gpe.Reyes Vargas',
'Folio:1395- Condonacion de intereses vencidos y moratorios.',
'Descripcion: Se modifica para agregar las transacciones (7795 y 7796) para la condonacion de intereses',
'BD: bdicred',
'version: 20140103.1646';


