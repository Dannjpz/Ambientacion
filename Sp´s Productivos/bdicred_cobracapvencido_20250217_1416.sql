






CREATE PROCEDURE "informix".cobracapvencido(e_fcuota DATE)
   RETURNING CHAR(5);

   DEFINE CodRet                 CHAR(5);
   DEFINE Mensaje                CHAR(80);
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR(40);
   DEFINE nRows                  SMALLINT;

   DEFINE GLOBAL g_Empresa       CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito    CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto   CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa        CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun     CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_ManejaLinea   CHAR(1)     DEFAULT ' ';
   DEFINE GLOBAL g_TpPago        SMALLINT    DEFAULT 0;

   DEFINE GLOBAL g_MontoVencido  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MtoVencTrasp  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_CapVencCob    MONEY(14,2) DEFAULT 0;
   DEFINE gLOBAL g_MontoReservado MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_PagoCapVencido  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_StCred	      CHAR(2) DEFAULT ' ';

   DEFINE vFechaCuota            LIKE sd_pagocapit.fecha_cuota;
   DEFINE vCuotaRec              LIKE sd_pagocapit.cuota_rec;
   DEFINE vSaldoCuota            LIKE sd_pagocapit.saldo_cuota;
   DEFINE vMontoRealPag          LIKE sd_pagocapit.monto_real_pag;
   DEFINE vAdeudoCuota           LIKE sd_pagocapit.monto_real_pag;
   DEFINE vStatusCuota           LIKE sd_pagocapit.status_cuota;
   DEFINE vCobro                LIKE sd_pagocapit.monto_cuota;
   DEFINE vCobro7                LIKE sd_pagocapit.monto_cuota;
   DEFINE vCobro2                LIKE sd_pagocapit.monto_cuota;
   DEFINE vCapCobrado            LIKE sd_pagocapit.monto_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vStatus                LIKE sd_pagocapit.status_cuota;
   DEFINE vMtoVencido           LIKE sd_pagocapit.monto_cuota;
   DEFINE vMtoVencido7           LIKE sd_pagocapit.monto_cuota;
   DEFINE vMtoVencido2           LIKE sd_pagocapit.monto_cuota;

   DEFINE vMinistrado            LIKE sd_pagocapit.monto_cuota;

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraCapVencido.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;			 


   LET vCobro      = 0;
   LET vCapCobrado  = 0;
   LET CodRet       = "000";
   LET vMinistrado  = 0;
   LET vMtoVencido = 0;
   LET vCobro7      = 0;
   LET vCobro2      = 0;
   LET vMtoVencido7 = 0;
   LET vMtoVencido2 = 0;


   IF (g_StCred='AA' OR g_StCred='BA' OR g_StCred='BT') THEN

      FOREACH
            SELECT fecha_cuota, capital_status_ant,
                     capital_debe, capital_pagado,
                     (capital_debe - capital_pagado), capital_status
            INTO vFechaCuota, vCuotaRec,
                  vSaldoCuota, vMontoRealPag,
                  vAdeudoCuota, vStatusCuota
            FROM sd_amortiza_credito
            WHERE empresa = g_Empresa
               AND num_credito = g_NumCredito
               AND fecha_cuota = e_fcuota
            let vMontoRealPag = vMontoRealPag;

            IF (vStatusCuota = 7 ) THEN
                  SELECT monto_vencido INTO vMtoVencido7
                  FROM SD_MAESDOS
                  WHERE empresa = g_Empresa AND
                        num_credito = g_NumCredito;
                  IF (g_Remanente >= vAdeudoCuota) THEN
                     LET g_Remanente = g_Remanente - vAdeudoCuota;
                     LET vCobro7 = vCobro7 + vAdeudoCuota;
                     LET vCuotaRec = vStatusCuota;
                     LET vStatusCuota = '5';
                  LET g_MontoVencido = 0;
                  ELSE
                     LET g_MontoVencido = g_MontoVencido - g_Remanente;
                  LET vCobro7 = vCobro7 + g_Remanente;
                     LET g_Remanente = 0;
                  END IF;
                  LET vCapCobrado = vCapCobrado + vCobro7;
            END IF;
            IF (vStatusCuota = 2 ) THEN
                  SELECT mto_venc_trasp INTO vMtoVencido2
                  FROM SD_MAESDOS
                  WHERE empresa = g_Empresa AND
                        num_credito = g_NumCredito;
               IF (g_Remanente >= vAdeudoCuota) THEN
                     LET g_Remanente = g_Remanente - vAdeudoCuota;
                     LET vCobro2 = vCobro2 + vAdeudoCuota;
                     LET vCuotaRec = vStatusCuota;
                     LET vStatusCuota = '5';
               LET g_MtoVencTrasp = g_MtoVencTrasp- vAdeudoCuota;
               ELSE
                     LET g_MtoVencTrasp = g_MtoVencTrasp - g_Remanente;
               LET vCobro2 = vCobro2 + g_Remanente;
                     LET g_Remanente = 0;
               END IF;
               LET vCapCobrado = vCapCobrado + vCobro2;
            END IF;
            LET vMinistrado = vCobro7 + vCobro2;

            UPDATE
            sd_amortiza_credito
            SET
            capital_pagado = capital_pagado + vMinistrado,
            capital_fecha_pago = g_fecha,
            capital_status = vStatusCuota,
            capital_status_ant = vCuotaRec
         WHERE
            empresa     = g_empresa
         AND
            num_credito = g_NumCredito
         AND
            fecha_cuota = vFechaCuota;

      END FOREACH;

      IF (vCapCobrado > 0) THEN
         IF (g_ManejaLinea = 'S') THEN
            IF vMtoVencido7 > 0 THEN
                     IF vCobro7 > vMtoVencido7 THEN
                        UPDATE sd_maesdos
                        SET   monto_vencido    = 0,
                              sdo_cap_insoluto = sdo_cap_insoluto - vCapCobrado,
                              mto_ministra_cap = mto_ministra_cap - vMinistrado,
                              abonos_mes_cap   = abonos_mes_cap + vCapCobrado
                        WHERE empresa = g_Empresa AND
                              num_credito = g_NumCredito;
                     ELSE
                        UPDATE sd_maesdos
                        SET   monto_vencido    = monto_vencido - vCobro7,
                              sdo_cap_insoluto = sdo_cap_insoluto - vCapCobrado,
                              mto_ministra_cap = mto_ministra_cap - vMinistrado,
                              abonos_mes_cap   = abonos_mes_cap + vCapCobrado
                        WHERE empresa = g_Empresa AND
                              num_credito = g_NumCredito;
                     END IF;
            END IF;
            IF vMtoVencido2 > 0 THEN
                     IF vCobro2 > vMtoVencido2 THEN
                        UPDATE sd_maesdos
                        SET   mto_venc_trasp   = 0,
                              sdo_cap_insoluto = sdo_cap_insoluto - vCapCobrado,
                              mto_ministra_cap = mto_ministra_cap - vMinistrado,
                              abonos_mes_cap   = abonos_mes_cap + vCapCobrado
                        WHERE empresa = g_Empresa AND
                              num_credito = g_NumCredito;
                     ELSE
                        UPDATE sd_maesdos
                        SET   mto_venc_trasp   = mto_venc_trasp - vCobro2,
                              sdo_cap_insoluto = sdo_cap_insoluto - vCapCobrado,
                              mto_ministra_cap = mto_ministra_cap - vMinistrado,
                              abonos_mes_cap   = abonos_mes_cap + vCapCobrado
                        WHERE empresa = g_Empresa AND
                              num_credito = g_NumCredito;
                     END IF;
            END IF;
         ELSE
                     UPDATE sd_maesdos
                        SET   monto_vencido    = monto_vencido - vCobro7,
               --             mto_venc_trasp   = mto_venc_trasp - vCobro2,
                              sdo_cap_insoluto = sdo_cap_insoluto - vCapCobrado,
                              mto_ministra_cap = mto_ministra_cap - vMinistrado,
                              abonos_mes_cap   = abonos_mes_cap + vCapCobrado
                     WHERE empresa = g_Empresa AND
                           num_credito = g_NumCredito;
            IF vMtoVencido2 > 0 THEN
                     UPDATE sd_maesdos
                        SET   --monto_vencido    = monto_vencido - vCobro7,
                              mto_venc_trasp   = mto_venc_trasp - vCobro2,
                              sdo_cap_insoluto = sdo_cap_insoluto - vCapCobrado,
                              mto_ministra_cap = mto_ministra_cap - vMinistrado,
                              abonos_mes_cap   = abonos_mes_cap + vCapCobrado
                     WHERE empresa = g_Empresa AND
                           num_credito = g_NumCredito;
            END IF;
         END IF;

         IF (vCobro7 > 0) THEN
			IF g_Transacc = '9854' THEN
				LET vReferencia = 34;   --PAGO ATM CGO CUENTA
			ELIF g_Transacc = '4356' THEN
				LET vReferencia = 91;   --PAGO ATM EFECTIVO
			ELSE
				LET vReferencia = 7;   --Capital vencido no traspasado
			END IF;
            CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                        g_CodigoFun, g_Fecha, vCobro7, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc) RETURNING
                        CodRet, Mensaje;
            IF (CodRet <> "00000") THEN
               RETURN CodRet;
            ELSE
               LET CodRet = "000";
               LET g_PagoCapVencido = g_PagoCapVencido + vCobro7;
            END IF;
         END IF;
         IF (vCobro2 > 0) THEN
			IF g_Transacc = '9854' THEN
				LET vReferencia = 34;   --PAGO ATM CGO CUENTA
			ELIF g_Transacc = '4356' THEN
				LET vReferencia = 91;   --PAGO ATM EFECTIVO
			ELSE
				LET vReferencia = 8;   --Capital vencido traspasado
			END IF;
            CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                        g_CodigoFun, g_Fecha, vCobro2, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc) RETURNING
                        CodRet, Mensaje;
            IF (CodRet <> "00000") THEN
               RETURN CodRet;
            ELSE
               LET CodRet = "000";
               LET g_PagoCapVencido = g_PagoCapVencido + vCobro2;
            END IF;
         END IF;
         LET g_CapVencCob = g_CapVencCob + vCapCobrado;
      END IF;

   ELIF (g_StCred='E1' OR g_StCred='E2' OR g_StCred='E3') THEN

      FOREACH
            SELECT fecha_cuota, capital_status_ant,
                     capital_debe, capital_pagado,
                     (capital_debe - capital_pagado), capital_status
            INTO vFechaCuota, vCuotaRec,
                  vSaldoCuota, vMontoRealPag,
                  vAdeudoCuota, vStatusCuota
            FROM sd_amortiza_credito
            WHERE empresa = g_Empresa
               AND num_credito = g_NumCredito
               AND fecha_cuota = e_fcuota
            let vMontoRealPag = vMontoRealPag;

            SELECT monto_vencido INTO vMtoVencido
               FROM SD_MAESDOS
               WHERE empresa = g_Empresa AND
                     num_credito = g_NumCredito;

            IF (g_Remanente >= vAdeudoCuota) THEN
                  LET g_Remanente = g_Remanente - vAdeudoCuota;
                  LET vCobro = vCobro + vAdeudoCuota;
                  LET vCuotaRec = vStatusCuota;
                  LET vStatusCuota = '5';
               IF (vStatusCuota = 7 ) THEN
                  LET g_MontoVencido = 0;
               ELSE
                  LET g_MontoVencido = g_MontoVencido- vAdeudoCuota;
               END IF;
            ELSE
                  LET g_MontoVencido = g_MontoVencido - g_Remanente;
                  LET vCobro = vCobro + g_Remanente;
                  LET g_Remanente = 0;
            END IF;

            LET vCapCobrado = vCapCobrado + vCobro;   
            LET vMinistrado = vCobro ;

            UPDATE sd_amortiza_credito SET
                  capital_pagado = capital_pagado + vMinistrado,
                  capital_fecha_pago = g_fecha,
                  capital_status = vStatusCuota,
                  capital_status_ant = vCuotaRec
               WHERE empresa     = g_empresa
               AND num_credito = g_NumCredito
               AND fecha_cuota = vFechaCuota;

      END FOREACH;

      IF (vCapCobrado > 0) THEN
         IF (g_ManejaLinea = 'S') THEN
            IF vMtoVencido > 0 THEN
                     IF vCobro > vMtoVencido THEN
                        UPDATE sd_maesdos
                        SET   monto_vencido    = 0,
                              sdo_cap_insoluto = sdo_cap_insoluto - vCapCobrado,
                              mto_ministra_cap = mto_ministra_cap - vMinistrado,
                              abonos_mes_cap   = abonos_mes_cap + vCapCobrado
                        WHERE empresa = g_Empresa AND
                              num_credito = g_NumCredito;
                     ELSE
                        UPDATE sd_maesdos
                        SET   monto_vencido    = monto_vencido - vCobro,
                              sdo_cap_insoluto = sdo_cap_insoluto - vCapCobrado,
                              mto_ministra_cap = mto_ministra_cap - vMinistrado,
                              abonos_mes_cap   = abonos_mes_cap + vCapCobrado
                        WHERE empresa = g_Empresa AND
                              num_credito = g_NumCredito;
                     END IF;
            END IF;
         ELSE
               UPDATE sd_maesdos
               SET   monto_vencido    = monto_vencido - vCobro,
                     sdo_cap_insoluto = sdo_cap_insoluto - vCapCobrado,
                     mto_ministra_cap = mto_ministra_cap - vMinistrado,
                     abonos_mes_cap   = abonos_mes_cap + vCapCobrado
               WHERE empresa = g_Empresa AND
                     num_credito = g_NumCredito;
         END IF;

         IF (vCobro > 0) THEN
            IF g_StCred='E1' THEN
               LET vReferencia = 907;   --Capital vencido E1
            ELIF g_StCred='E2' THEN
               LET vReferencia = 908;   --Capital vencido E2
            ELIF g_StCred='E3' THEN
               LET vReferencia = 909;   --Capital vencido E3
            END IF;
            
			IF g_Transacc = '9854' and vReferencia = 907 THEN
				LET vReferencia = 34;   --PAGO ATM CGO CUENTA
			ELIF g_Transacc = '9854' and vReferencia = 908 THEN
				LET vReferencia = 36;   --PAGO ATM CGO CUENTA
			ELIF g_Transacc = '9854' and vReferencia = 909 THEN
				LET vReferencia = 38;   --PAGO ATM CGO CUENTA
			ELIF g_Transacc = '4356' and vReferencia = 907 THEN
				LET vReferencia = 91;   --PAGO ATM EFECTIVO
			ELIF g_Transacc = '4356' and vReferencia = 908 THEN
				LET vReferencia = 93;   --PAGO ATM EFECTIVO
			ELIF g_Transacc = '4356' and vReferencia = 909 THEN
				LET vReferencia = 95;   --PAGO ATM EFECTIVO
			END IF;
            CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                        g_CodigoFun, g_Fecha, vCobro, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc) RETURNING
                        CodRet, Mensaje;
            IF (CodRet <> "00000") THEN
               RETURN CodRet;
            ELSE
               LET CodRet = "000";
               LET g_PagoCapVencido = g_PagoCapVencido + vCobro;
            END IF;
         END IF;

         LET g_CapVencCob = g_CapVencCob + vCapCobrado;
      END IF;

   END IF;
   RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Capital vencido, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'BD    : BDICRED';


