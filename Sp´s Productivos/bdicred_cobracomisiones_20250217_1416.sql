






CREATE PROCEDURE "informix".cobracomisiones(e_tpcom  CHAR(2),
				 e_fcuota DATE)
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
   DEFINE GLOBAL g_Impuesto     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Seguro       MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Comision     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha        DATE        DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa       CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc     CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_TpPago       SMALLINT    DEFAULT 0;
   --DEFINE GLOBAL g_MontoFinanciado       MONEY(14,2)    DEFAULT 0;
   DEFINE GLOBAL g_StCred        CHAR(2) DEFAULT ' ';
   DEFINE GLOBAL g_ACT	   INTEGER DEFAULT 0;

   DEFINE GLOBAL g_CodigoFun    CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_Folio        CHAR(16)    DEFAULT ' ';

   DEFINE wCodigoRef            SMALLINT;
   DEFINE wCodComis             CHAR(4);
   DEFINE wNumCredito           CHAR(20);
   DEFINE wMontoCom             MONEY(14,2);
   DEFINE wFechaPago            DATE;
   DEFINE wmCom                 MONEY(14,2);
   DEFINE wmPag                 MONEY(14,2);
   DEFINE wEstadoCom            CHAR(1);
   DEFINE wTpCom		CHAR(1);

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraComisiones.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;



   LET CodRet = "000";

   FOREACH
      SELECT a.cod_comis, c.num_credito, c.monto_com, c.monto_pag,
             c.monto_com - c.monto_pag, c.fecha_alta, c.estado_com ,
	     a.comi_o_seg
        INTO wCodComis, wNumCredito, wmCom, wmPag, wMontoCom, wFechaPago,
             wEstadoCom, wTpCom
        FROM sd_tpcomis a, sd_detcomi c
       WHERE a.empresa     = g_empresa
    --     AND a.comi_o_seg   = e_tpcom
         AND c.empresa     = a.empresa
         AND c.cod_comis   = a.cod_comis
         AND c.num_credito = g_NumCredito
         AND c.estado_com  = 'A'
    --   ORDER BY 1

      IF e_tpcom = "2" AND g_TpPago = "2" THEN
	   IF e_fcuota <> wFechaPago THEN
		CONTINUE FOREACH;
	   END IF
      END IF

      IF (g_Remanente > 0) THEN
         IF (g_Remanente >= wMontoCom) THEN
            LET g_Remanente = g_Remanente - wMontoCom;
         ELSE
            LET wMontoCom = g_Remanente;
            LET g_Remanente = 0;
         END IF;
         IF (e_tpcom = "2") THEN
            LET wCodigoRef = wCodComis;
            CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,wCodigoref,
                        g_CodigoFun, g_Fecha, wMontoCom, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc) RETURNING
                           CodRet, Mensaje;
            IF(CodRet <> "00000") THEN
               RETURN CodRet;
            ELSE
               LET g_Seguro = g_Seguro + wMontoCom;
	       UPDATE sd_escrow SET saldo = saldo + wMontoCom
		WHERE empresa = g_Empresa
		  AND num_credito = g_NumCredito
		  AND cod_comis = wCodComis;
               LET Codret = "000";
            END IF;
         ELSE
            LET wCodigoRef = wCodComis;
            CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto, wCodigoref,
              	        g_CodigoFun, g_Fecha, wMontoCom, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc)
	    RETURNING CodRet, Mensaje;
            IF(CodRet <> "00000") THEN
               RETURN CodRet;
            ELSE
               LET CodRet = "000";
	       IF wTpCom = "1" THEN
                 LET g_Comision = g_Comision + wMontoCom;
	       ELIF wTpCom = "4" THEN
		 LET g_Impuesto = g_Impuesto + wMontoCom;
	       END IF
	    END IF
         END IF;

         IF (wmCom = wmPag + wMontoCom) THEN
            LET wEstadoCom = 'P';
         END IF;

         UPDATE sd_detcomi
            SET monto_pag = monto_pag + wMontoCom,
                fecha_pago = g_Fecha,
                estado_com = wEstadoCom
          WHERE empresa = g_empresa
            AND cod_comis = wCodComis
            AND num_credito = wNumCredito
            AND fecha_alta = wFechaPago;


	  --LET g_MontoFinanciado = g_MontoFinanciado - wMontoCom;
         IF g_StCred = "AA" THEN
              UPDATE sd_maesdos
                 SET sdo_cap_insoluto = sdo_cap_insoluto - wMontoCom,
                     sdo_capital = sdo_capital - wMontoCom --,
		     --monto_financiado = monto_financiado - wMontoCom
               WHERE num_credito = wNumCredito
                 AND empresa = g_empresa;
       	ELIF g_StCred = "BA" THEN
              UPDATE sd_maesdos
       	         SET sdo_cap_insoluto = sdo_cap_insoluto - wMontoCom,
               	     monto_vencido = monto_vencido - wMontoCom --,
		     --monto_financiado = monto_financiado - wMontoCom
               WHERE num_credito = wNumCredito
       	         AND empresa = g_empresa;
         ELIF g_StCred = "BT" THEN
       	      UPDATE sd_maesdos
                 SET sdo_cap_insoluto = sdo_cap_insoluto - wMontoCom,
       	             mto_venc_trasp = mto_venc_trasp - wMontoCom --,
		     --monto_financiado = monto_financiado - wMontoCom
               WHERE num_credito = wNumCredito
       	         AND empresa = g_empresa;
         ELIF g_ACT = 0 and g_StCred = 'E1' THEN
              UPDATE sd_maesdos
                 SET sdo_cap_insoluto = sdo_cap_insoluto - wMontoCom,
                     sdo_capital = sdo_capital - wMontoCom --,
		     --monto_financiado = monto_financiado - wMontoCom
               WHERE num_credito = wNumCredito
                 AND empresa = g_empresa;
       	ELIF g_ACT > 0 and (g_StCred = 'E1' or g_StCred = 'E2' or g_StCred = 'E3') THEN
              UPDATE sd_maesdos
       	         SET sdo_cap_insoluto = sdo_cap_insoluto - wMontoCom,
               	     monto_vencido = monto_vencido - wMontoCom --,
		     --monto_financiado = monto_financiado - wMontoCom
               WHERE num_credito = wNumCredito
       	         AND empresa = g_empresa;
         END IF --SE ELIMINA ESTE BLOQUE PORQUE YA NO SE UTLIZAN ESTOS ESTATUS

      END IF;


   END FOREACH;
   RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procfedimiento para el cobro de comisiones, lo primero que ',
'cobra es el seguro, posteriormente el resto de comisiones que ',
'tengan que cobrarse, es llamada por Principal',
'Se modifica para que realice tambien el cobro por cuota',
'AUTOR : Raul Mendoza D nes',
'MOD   : Axel',
'FECHA : 17/Octubre/2003',
'FEC MOD 10/Enero/2004',
'CTE   : CACSI',
'BD    : BDICRED';


