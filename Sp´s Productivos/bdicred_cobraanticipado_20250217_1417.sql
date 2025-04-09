






CREATE PROCEDURE "informix".cobraanticipado()
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

   DEFINE GLOBAL g_PagoAdic      CHAR(1)     DEFAULT ' ';

   DEFINE GLOBAL g_SdoIntAnticip MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoIntAntDev  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoIntereses  MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoAcumInt    MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL g_MtoCapitalizado MONEY(14,2) DEFAULT 0;


   DEFINE GLOBAL g_IntVig        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_SdoAcumMesInt MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_ProvisionNorm MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_IntVigCob     MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_CapVigCob     MONEY(14,2) DEFAULT 0;

   DEFINE GLOBAL g_ManejaLinea   CHAR(1)     DEFAULT ' ';

   DEFINE vIntAnticip            MONEY(14,2);
   DEFINE vIntVig                MONEY(14,2);
   DEFINE vProvAnticip           MONEY(14,2);
   DEFINE vProvision             MONEY(14,2);
   DEFINE vCapVig                MONEY(14,2);
   DEFINE vCapAnticip            MONEY(14,2);
   DEFINE vSalida                SMALLINT;

   DEFINE vCodigoFun             CHAR(3);
   DEFINE vReferencia            SMALLINT;

   DEFINE vMtoMinistraCap        MONEY(14,2);

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraAnticipado.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

   LET CodRet = '000';
   LET vIntAnticip = 0;
   LET vIntVig = 0;
   LET vProvAnticip = 0;
   LET vProvision = 0;
   LET vSalida = 1;
   LET vCodigoFun = "034";
   LET vCapAnticip = 0;
   LET vMtoMinistraCap = 0;
   IF (g_ManejaLinea <> 'S') THEN
      WHILE (vSalida  > 0 )
         CALL CobraCapAnticip() RETURNING CodRet, VCapVig;
         LET vCapAnticip = vCapAnticip + vCapVig;
      --   CALL CobraIntAnticip() RETURNING CodRet, vIntVig, vProvision;
      --   LET vIntAnticip = vIntAnticip + vIntVIg;
      --   LET vProvAnticip = vProvAnticip + vProvision;
      --   IF (vIntVig = 0 AND vCapVig = 0) THEN
         IF (vCapVig = 0) THEN
            LET vSalida = 0;
         END IF;
         IF (g_Remanente = 0) THEN
            LET vSalida = 0;
         END IF;
      END WHILE

      {IF (vIntAnticip >0) THEN
         IF (vProvAnticip > 0) THEN
			IF g_Transacc = '9854' THEN
				LET vReferencia = 41;   --PAGO ATM CGO CUENTA
			ELIF g_Transacc = '4356' THEN
				LET vReferencia = 98;   --PAGO ATM EFECTIVO
			ELSE
				LET vReferencia = 11;   --Provision de Intereses
			END IF;
			    IF g_Transacc = '9854' or g_Transacc = '4356' THEN
					CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                        '059', g_Fecha, vProvAnticip, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc) RETURNING
                        CodRet, Mensaje;
					IF (CodRet <> "00000") THEN
					   RETURN CodRet;
					ELSE
					  LET CodRet = "000";
                    END IF;
				ELSE
					CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                        vCodigoFun, g_Fecha, vProvAnticip, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc) RETURNING
                        CodRet, Mensaje;
					IF (CodRet <> "00000") THEN
					   RETURN CodRet;
					ELSE
					  LET CodRet = "000";
                    END IF;
		        END IF;
            
         END IF;
		IF g_Transacc = '9854' THEN
			LET vReferencia = 39;   --PAGO ATM CGO CUENTA
		ELIF g_Transacc = '4356' THEN
			LET vReferencia = 96;   --PAGO ATM EFECTIVO
		ELSE
			LET vReferencia = 9;   --Pago De Intereses
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
      END IF;}

      IF (vCapAnticip > 0) THEN
		IF g_Transacc = '9854' THEN
			LET vReferencia = 33;   --PAGO ATM CGO CUENTA
		ELIF g_Transacc = '4356' THEN
			LET vReferencia = 90;   --PAGO ATM EFECTIVO
		ELSE
			LET vReferencia = 10;   --Pago de Capital
		END IF; 
         CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                     g_CodigoFun, g_Fecha, vCapAnticip, g_Folio,
                     g_Sucursal, g_Divisa, g_Transacc) RETURNING
                     CodRet, Mensaje;
         IF (CodRet <> "00000") THEN
            RETURN CodRet;
         ELSE
            LET CodRet = "000";
         END IF;
      END IF;
   ELSE
      CALL CobraIntAnticip() RETURNING CodRet, vIntVig, vProvision;
      LET g_IntVigCob = g_IntVigCob + vIntVig;
      IF (vIntvig >0) THEN
         IF (vProvision > 0) THEN
			IF g_Transacc = '9854' THEN
				LET vReferencia = 41;   --PAGO ATM CGO CUENTA
			ELIF g_Transacc = '4356' THEN
				LET vReferencia = 98;   --PAGO ATM EFECTIVO
			ELSE
				LET vReferencia = 11;   --Provision de Intereses
			END IF;
			
			    IF g_Transacc = '9854' or g_Transacc = '4356' THEN
					CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                        '059', g_Fecha, vProvision, g_Folio,
                        g_Sucursal, g_Divisa, g_Transacc) RETURNING
                        CodRet, Mensaje;
					IF (CodRet <> "00000") THEN
					   RETURN CodRet;
					ELSE
					   LET CodRet = "000";
					END IF;
				ELSE
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
				
            
         END IF;
		IF g_Transacc = '9854' THEN
			LET vReferencia = 39;   --PAGO ATM CGO CUENTA
		ELIF g_Transacc = '4356' THEN
			LET vReferencia = 96;   --PAGO ATM EFECTIVO
		ELSE
			LET vReferencia = 9;   --Pago De Intereses
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
      CALL CobraCapAnticip() RETURNING CodRet, vCapAnticip;
      LET vMtoMinistraCap = vCapAnticip;
      IF (vCapAnticip > 0) THEN
		IF g_Transacc = '9854' THEN
			LET vReferencia = 33;   --PAGO ATM CGO CUENTA
		 ELIF g_Transacc = '4356' THEN
			LET vReferencia = 90;   --PAGO ATM EFECTIVO
		 ELSE
			LET vReferencia = 10;   --Pago de Capital
		 END IF;
         CALL GenMov(g_Empresa, g_NumCredito, g_NumProducto,vReferencia,
                     g_CodigoFun, g_Fecha, vCapAnticip, g_Folio,
                     g_Sucursal, g_Divisa, g_Transacc) RETURNING
                     CodRet, Mensaje;
         IF (CodRet <> "00000") THEN
            RETURN CodRet;
         ELSE
            LET CodRet = "000";
         END IF;
      END IF;
   END IF;

   UPDATE
     sd_maesdos
   SET
      sdo_int_anticip = g_SdoIntAnticip,
      sdo_int_ant_dev = g_SdoIntAntDev,
      sdo_intereses   = g_SdoIntereses,
      provision_normal = provision_normal + vProvision,
      sdo_no_exig = sdo_no_exig - vIntAnticip,
      sdo_capital = sdo_capital - vCapAnticip,
      sdo_cap_insoluto = sdo_cap_insoluto - vCapAnticip,
      mto_capitalizado = g_MtoCapitalizado,
      mto_ministra_cap = mto_ministra_cap - vMtoMinistraCap
   WHERE
      empresa = g_Empresa
   AND
      num_credito = g_NumCredito;
   LET g_IntVigCob = g_IntVigCob + vIntAnticip;
   LET g_CapVigCob = g_CapVigCob + vCapAnticip;


   RETURN CodRet;

END PROCEDURE
DOCUMENT
'Sub Procedimiento para el cobro Anticipado, ',
' es llamada por Principal',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Octubre/2003',
'CTE   : CACSI',
'BD    : BDICRED';


