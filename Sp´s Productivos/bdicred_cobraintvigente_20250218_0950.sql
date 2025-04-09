






CREATE PROCEDURE "informix".cobraintvigente(e_fcuota DATE)
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
   --DEFINE GLOBAL g_MontoFinanciado     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha         DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa        CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_CodigoFun     CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio         CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_ManejaLinea   CHAR(1)     DEFAULT ' ';

   DEFINE GLOBAL g_SdoIntAnticip MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoIntAntDev  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntTraNoExig  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoTrab4      MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoIntereses  MONEY(14,2) DEFAULT 0;
   
   DEFINE GLOBAL g_IntVig        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoAcumMesInt MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_ProvisionNorm MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntVigCob     MONEY(14,2) DEFAULT 0;

   DEFINE vFechaCuota            LIKE sd_paginter.fecha_cuota;
   DEFINE vIntVig                LIKE sd_paginter.monto_cuota;
   DEFINE vCuotaRec              LIKE sd_paginter.cuota_rec;
   DEFINE vMontoCuota            LIKE sd_paginter.monto_cuota;
   DEFINE vMontoRealPag          LIKE sd_paginter.monto_real_pag;
   DEFINE vMontoFinanciado       LIKE sd_paginter.monto_financiado;
   DEFINE vStatusCuota           LIKE sd_paginter.status_cuota;
   DEFINE vReferencia            SMALLINT;
   DEFINE vCodigoFun             CHAR(3);
   DEFINE vSdoACumMesInt         MONEY(14,2);
   DEFINE vProvisionNorm         MONEY(14,2);
   DEFINE vProvision             MONEY(14,2);
   DEFINE vPagMinInt             MONEY(14,2);
   DEFINE vAbonos                MONEY(14,2);
 

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraIntVigente.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;			 
   LET CodRet = "000";
   LET vCodigoFun = "034";   --Utilizada para realizar la provision
   LET vSdoAcumMesInt = 0;
   LET vAbonos = 0;
   LET vProvisionNorm = 0;
   LET vPagMinInt = 0; --g_IntTraNoExig + g_SdoTrab4;

   --IF (g_ManejaLinea <> 'S') THEN

      --SELECT 
      --   fecha_cuota, cuota_rec, monto_cuota,
      --   monto_real_pag, (monto_cuota - monto_real_pag),
      --   NVL(monto_financiado,0),
      --   status_cuota 
      SELECT 
         fecha_cuota, interes_status_ant, 
         interes_debe, interes_pagado, (interes_debe -  interes_pagado),
         --NVL(monto_financiado,0),
         interes_status
       INTO
          vFechaCuota, vCuotaRec, 
          vMontoCuota, vMontorealPag, vIntVig,
          --vMontoFinanciado, 
          vStatusCuota 
      FROM
         sd_amortiza_credito --sd_paginter
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito
      AND 
	fecha_cuota = e_fcuota;


      IF (vStatusCuota <> '1' OR vStatusCuota <> '3') THEN
         RETURN CodRet;
      END IF;

      IF (g_Remanente >= vIntVig) THEN
         LET g_Remanente = g_Remanente - vIntVig;
         If g_ManejaLinea <> 'S' then
             LET vCuotaRec = vStatusCuota;
             LET vStatusCuota = '5';
         end if;
      ELSE
         LET vIntVig = g_Remanente;
         LET g_Remanente = 0;
      END IF;
/*
       -- Valida Provision Pendiente
      IF (vMontoFinanciado <= (vMontoRealPag + vIntVig)) THEN
         LET vProvision = vIntVig - vMontoFinanciado;
      ELSE
         LET vProvision = 0;
      END IF;
               
      IF (vProvision > 0) THEN
         LET vReferencia = 11;   --Provision de Intereses 
         CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                     vCodigoFun, g_Fecha, vProvision, g_Folio,
                     g_Sucursal, g_Divisa, g_Transacc) RETURNING
                     CodRet, Mensaje;
         IF (CodRet <> "00000") THEN
            RETURN CodRet;
         ELSE
            LET CodRet = "000";
         END IF;
      END IF;
*/
      IF (vIntVig > 0) THEN
		IF g_Transacc = '9854' THEN
			LET vReferencia = 39;   --PAGO ATM CGO CUENTA
		 ELIF g_Transacc = '4356' THEN
			LET vReferencia = 96;   --PAGO ATM EFECTIVO
		 ELSE
			LET vReferencia = 9;   --Pago de Intereses 
		 END IF;
         CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                     g_CodigoFun, g_Fecha, vIntVig, g_Folio,
                     g_Sucursal, g_Divisa, g_Transacc) RETURNING
                     CodRet, Mensaje;
         IF (CodRet <> "00000") THEN
            RETURN CodRet;
         ELSE
            LET CodRet = "000";
         END IF;
      END IF;

      UPDATE    
         --sd_paginter
         sd_amortiza_credito
      SET
         --monto_real_pag = monto_real_pag + vIntVig,
         interes_pagado = interes_pagado + vIntVig,
         --fecha_pag      = g_fecha,
         interes_fecha_pago = g_fecha,
         --monto_financiado = vMontoFinanciado + vProvision,
         --cuota_rec      = vCuotaRec,
         --status_cuota   = vStatusCuota
         interes_status   = vStatusCuota,
         interes_status_ant = vCuotaRec
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito
      AND
         fecha_cuota = vFechaCuota;    
      
    If (vStatusCuota = '5' and vCuotaRec = '1') or vStatusCuota = '1' then
        UPDATE sd_maesdos
        SET 
            sdo_no_exig      = sdo_no_exig - vIntVig--,
                --abonos_mes_cap   = abonos_mes_cap + vIntVig
        WHERE empresa = g_Empresa
          AND num_credito = g_NumCredito;
    Elif (vStatusCuota = '5' and vCuotaRec = '3') or vStatusCuota = '3' then
        UPDATE sd_maesdos
        SET 
            int_tra_no_exig      = int_tra_no_exig - vIntVig--,
                --abonos_mes_cap   = abonos_mes_cap + vIntVig
        WHERE empresa = g_Empresa
          AND num_credito = g_NumCredito;
    End if;


    ----------------------------------
    --       TARJETA                --
    ----------------------------------
/*
   ELSE        
        LET vIntVig = g_IntVig;
        IF (g_Remanente > 0) THEN
            IF (vPagMinInt > 0) THEN
                IF (g_Remanente >= vPagMinInt) THEN
                    LET g_Remanente = g_Remanente - vPagMinInt;
                ELSE
                    LET vPagMinInt = g_Remanente;
                    LET g_Remanente = 0;
                END IF;
            ELSE
                IF (g_Remanente >= vIntVig) THEN
                    LET g_Remanente = g_Remanente - vIntVig;
                ELSE
                    LET vIntVig = g_Remanente;     
                    LET g_Remanente = 0;
                END IF;
            END IF;
       
            IF (vPagMinInt > 0) THEN
                LET vIntVig = vPagMinInt;
                LET g_SdoIntereses = g_SdoIntereses - vIntVig;
            END IF; 

            IF (g_IntTraNoExig >= vPagMinInt) THEN
                LET g_IntTraNoExig = g_IntTraNoExig - vPagMinInt;
                LET vPagMinInt = 0;
            ELSE
                LET vPagMinInt = vPagMinInt - g_IntTraNoExig;
                LET g_IntTraNoExig = 0;
            END IF;
            --IF (g_SdoTrab4 >= vPagMinInt) THEN
            --   LET g_SdoTrab4 = g_SdoTrab4 - vPagMinInt;
            --   LET vPagMinInt = 0;
            --ELSE
            --   LET vPagMinInt = vPagMinInt - g_SdoTrab4;
            --   LET g_SdoTrab4 = 0;
            --END IF;
            LET vAbonos = vIntVig;
            --LET g_MontoFinanciado = g_MontoFinanciado - vIntVig;

            IF (vIntVig > 0) THEN
                LET vReferencia = 9;   --Pago  de Intereses 
                CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                            g_CodigoFun, g_Fecha, vIntVig, g_Folio,
                            g_Sucursal, g_Divisa, g_Transacc) RETURNING
                            CodRet, Mensaje;
                IF (CodRet <> "00000") THEN
                   RETURN CodRet;
                ELSE
                   LET CodRet = "000";
                END IF;

                --LET vReferencia = 11;   --Provision de intereses
                --CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                --            '034', g_Fecha, vIntVig, g_Folio,
                --            g_Sucursal, g_Divisa, g_Transacc) RETURNING
                --            CodRet, Mensaje;
                --IF (CodRet <> "00000") THEN
                --   RETURN CodRet;
                --ELSE
                --   LET CodRet = "000";
                --END IF;
            END IF;
        END IF;
      
        UPDATE sd_maesdos
         SET sdo_no_exig      = sdo_no_exig - vIntVig,
             abonos_mes_cap   = abonos_mes_cap + vAbonos
             --monto_financiado = monto_financiado - vIntVig
             --sdo_cap_insoluto = sdo_cap_insoluto - vIntVig,
             --sdo_capital      = sdo_capital - vIntVig
        WHERE empresa = g_Empresa
         AND num_credito = g_NumCredito;

    END IF;
*/
    LET g_IntVigCob = g_IntVigCob + vIntVig;  
    RETURN CodRet; 

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro de Capital vencido, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED';


