






CREATE PROCEDURE "informix".cobracapvigente(e_fcuota DATE)
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

   DEFINE GLOBAL g_CapVig        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_CapVigCob     MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL g_MontoFinanciado MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_MontoReservado  MONEY(14,2) DEFAULT 0;

   DEFINE vFechaCuota            LIKE sd_pagocapit.fecha_cuota;
   DEFINE vCuotaRec              LIKE sd_pagocapit.cuota_rec;
   DEFINE vSaldoCuota            LIKE sd_pagocapit.saldo_cuota;
   DEFINE vMontoRealPag          LIKE sd_pagocapit.monto_real_pag;
   DEFINE vAdeudoCuota           LIKE sd_pagocapit.monto_cuota;
   DEFINE vStatusCuota           LIKE sd_pagocapit.status_cuota;
   DEFINE vCobro1                LIKE sd_pagocapit.monto_cuota;
   DEFINE CapCobrado             LIKE sd_pagocapit.monto_cuota;
   DEFINE vStatus                LIKE sd_pagocapit.status_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vPagMinCap             MONEY(14,2);
   DEFINE vMtoMinistraCap        MONEY(14,2);
   DEFINE vSdoMinimo             MONEY(14,2);
   DEFINE vCapDebe               MONEY(14,2);
   DEFINE vSdoCuota              MONEY(14,2);
   DEFINE vDifMinimo            MONEY(14,2);

   DEFINE vCobro0                LIKE sd_pagocapit.monto_cuota;


   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraCapVigente.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;			 

   LET CodRet       = '000';
   LET vCObro1      = 0;
   LET vCobro0      = 0;
   LET vSdoMinimo   = 0;
   LET vCapDebe     = 0;
   LET vSdoCuota    = 0;
   LET vDifMinimo   = 0;

   LET vMtoMinistraCap = 0;
   --IF (g_ManejaLinea <> 'S') THEN
{
      SELECT fecha_cuota, cuota_rec, saldo_cuota, monto_real_pag,
             (saldo_cuota - monto_real_pag), status_cuota
        INTO vFechaCuota, vCuotaRec, vSaldoCuota, vMontoRealPag,
             vAdeudoCuota, vStatusCuota
        FROM sd_pagocapit
       WHERE empresa = g_Empresa
         AND num_credito = g_NumCredito
         AND fecha_cuota = e_fcuota;
}
      SELECT fecha_cuota, capital_status_ant,
              capital_debe, capital_pagado,
              (capital_debe - capital_pagado), capital_status
        INTO vFechaCuota, vCuotaRec,
              vSaldoCuota, vMontoRealPag,
              vAdeudoCuota, vStatusCuota
        FROM sd_amortiza_credito
       WHERE empresa = g_Empresa
         AND num_credito = g_NumCredito
         AND fecha_cuota = e_fcuota;

      IF(vStatusCuota <> '1') THEN
         RETURN CodRet;
      END IF;
      LET vStatus = vStatusCuota;
      IF (g_Remanente >= vAdeudoCuota) THEN
         LET g_Remanente = g_Remanente - vAdeudoCuota;
         LET vCuotaRec = vStatusCuota;
         LET vStatusCuota = '5';
      ELSE
         LET vAdeudoCuota = g_Remanente;
         LET g_Remanente = 0;
      END IF;
      LET vCobro1 = vCobro1 + vAdeudoCuota;
      LET vCobro0 = vCobro1;
	  
	-- Se agrega validación para no actualizar amortización al realizar pago anticipado. AAME 24112017
	IF g_TRansacc <> '8151' THEN
        UPDATE
           sd_amortiza_credito
        SET
         capital_pagado = capital_pagado + vAdeudoCuota,
         capital_fecha_pago = g_fecha,
 --        capital_status = vStatusCuota,
         capital_status_ant = vCuotaRec
      WHERE
         empresa     = g_empresa
      AND
         num_credito = g_NumCredito
      AND
         fecha_cuota = vFechaCuota;
	END IF;

{
      UPDATE
         sd_pagocapit
      SET
         monto_real_pag = monto_real_pag + vAdeudoCuota,
         fecha_pago     = g_fecha,
         status_cuota   = vStatusCuota
      WHERE
         empresa     = g_empresa
      AND
         num_credito = g_NumCredito
      AND
         fecha_cuota = vFechaCuota;

      UPDATE
         sd_maesdos
      SET
         sdo_capital        = sdo_capital - vCobro1 ,
         sdo_cap_insoluto   = sdo_cap_insoluto - vCobro1
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito;


      -------------------------------
      --      TARJETA              --
      -------------------------------
--   ELSE
}
      LET g_CapVig = g_CapVig;
      LET g_Remanente = g_Remanente;
      LET vCobro1 = vCobro1;
      LET vCobro0 = vCobro0;
      LET vAdeudoCuota = vAdeudoCuota;
      IF (g_Remanente > 0 AND g_CapVig > 0) THEN
         IF (g_Remanente + vCobro0 >= g_CapVig ) THEN
            Let g_Remanente = g_Remanente - g_CapVig + vAdeudoCuota; --- agregue + vAdeudoCuota
            LET vCobro0 = g_CapVig;
            LET vCobro1 =  vCobro0;
	    LET g_CapVig = 0;
         ELSE
            LET vCobro0 = g_Remanente + vAdeudoCuota;
            --LET vCobro1 = vCobro1 + vCobro0;
            LET vCobro1 =  vCobro0;
            LET g_Remanente = 0;
         END IF;
         --LET vCobro1 = vCobro1 + vCobro0;
      END IF;
      LET g_CapVig = g_CapVig;
      LET g_Remanente = g_Remanente;
      LET vCobro1 = vCobro1;
      LET vCobro0 = vCobro0;
      LET vAdeudoCuota = vAdeudoCuota;

      UPDATE sd_maesdos
         SET sdo_capital        = sdo_capital - vCobro0 ,
             sdo_cap_insoluto   = sdo_cap_insoluto - vCobro0,
             mto_ministra_cap   = mto_ministra_cap - vCobro0,
             abonos_mes_cap     = abonos_mes_cap + vCobro0
       WHERE empresa = g_Empresa
         AND num_credito = g_NumCredito;

{
	SELECT MIN(fecha_cuota) INTO vFechaCuota
	  FROM sd_amortiza_credito
	 WHERE empresa = g_Empresa
	   AND num_credito = g_NumCredito
	   AND capital_status = "1"
	   AND fecha_cuota = (SELECT (prox_fecha_pago + 4) - 1 UNITS MONTH
			         FROM sd_maecredanexo
	 			WHERE empresa = g_Empresa
	   			  AND num_credito = g_NumCredito);
				  
		UPDATE sd_amortiza_credito
		   SET capital_pagado = capital_pagado + vCobro0
		 WHERE empresa = g_Empresa
		   AND num_credito = g_NumCredito
		   AND fecha_cuota = vFechaCuota;

}


--   END IF;

   IF (vCobro0 > 0) THEN
		IF g_Transacc = '9854' THEN
			LET vReferencia = 33;   --PAGO ATM CGO CUENTA
		ELIF g_Transacc = '4356' THEN
			LET vReferencia = 90;    --PAGO ATM EFECTIVO
		ELSE
		  LET vReferencia = 10;   --Capital Vigente
		END IF;
      CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                  g_CodigoFun, g_Fecha, vCobro1, g_Folio,
                  g_Sucursal, g_Divisa, g_Transacc) RETURNING
                  CodRet, Mensaje;
      IF (CodRet <> "00000") THEN
         RETURN CodRet;
      ELSE
         LET CodRet = "000";
      END IF;
   END IF;
   LET g_CapVigCob = g_CapVigCob + vCobro0;

   RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Capital vigente, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'VERSION: 1.00.003',
'BD    : BDICRED';


