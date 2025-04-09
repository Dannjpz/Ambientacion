






CREATE PROCEDURE "informix".sp_cargo_abono_aclara(p_Empresa  CHAR(3),
                           p_NumCredito             CHAR(20),
                           p_Tarjeta                CHAR(16),
                           p_Monto                  MONEY(14,2),
                           p_Usuario                CHAR(8),
                           p_Sucursal               CHAR(4),
                           p_Transacc               CHAR(4),
                           p_Operacion              SMALLINT,
                           p_referencia             CHAR(16))

-- ACL
   RETURNING CHAR(5), CHAR(80)     -- Codigo de Retorno


   DEFINE CodRet                CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nRows                 SMALLINT;
   DEFINE Mensaje               CHAR(80);
   DEFINE wBegin                CHAR(1);
   DEFINE pFecha                CHAR(6);


   DEFINE g_Remanente      MONEY(14,2);
   DEFINE g_IntMoraCob     MONEY(14,2);
   DEFINE g_IntVencCob     MONEY(14,2);
   DEFINE g_CapVencCob     MONEY(14,2);
   DEFINE g_IntVigCob      MONEY(14,2);
   DEFINE g_CapVigCob      MONEY(14,2);
   DEFINE g_Impuesto       MONEY(14,2);
   DEFINE g_Comision       MONEY(14,2);
   DEFINE g_Seguro         MONEY(14,2);
   DEFINE g_IvaCte         DECIMAL(9,6);
   DEFINE g_PagoCapVencido MONEY(14,2);
   DEFINE g_sistema        CHAR(2);
   DEFINE SaldoCom         MONEY(14,2);
   DEFINE MtoCgo		   MONEY(14,2);
   DEFINE MtoCom		   MONEY(12,2);
   DEFINE vIva		       MONEY(14,2);

   ON EXCEPTION SET sql_err, isam_err, error_info
      --SET DEBUG FILE TO "/pisa/Principal.err";
      LET CodRet = sql_err;
      LET Mensaje = error_info;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN CodRet,Mensaje ;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;


  --SET DEBUG FILE TO "/pisa/sp_cargo_abono_aclara.out";
  --TRACE ON;


   LET CodRet                = "000";
   LET sql_err               = 0;
   LET isam_err              = 0;
   LET error_info            = "";
   LET nRows                 = 0;
   LET Mensaje               = "Transaccion Exitosa";
   LET wBegin                = "";
   LET pFecha                = "";

   LET g_Remanente		= p_Monto;
   LET g_IntMoraCob		= 0;
   LET g_IntVencCob		= 0;
   LET g_IntVigCob		= 0;
   LET g_CapVigCob		= 0;
   LET g_Seguro         = 0;
   LET g_Comision		= 0;
   LET g_sistema        = "06";
   LET SaldoCom         = 0;
   LET MtoCgo	        = 0;
   LET MtoCom	        = 0;
   LET vIva             = 0;
   LET wBegin           = "N";


   BEGIN WORK;


    IF p_Operacion = 1 THEN  -- CARGO

        CALL cargoref_tc_ofi(p_Empresa, p_Sucursal, p_Usuario, p_Tarjeta, p_Monto,p_referencia, p_Transacc)
             RETURNING CodRet, SaldoCom, MtoCgo, MtoCom, vIva;

          IF(CodRet <> "000") THEN
             ROLLBACK WORK;
             IF (wBegin = "S") THEN
                 BEGIN WORK;
             END IF;
          END IF;

    ELSE --ABONO

--        CALL principal(p_Empresa,p_NumCredito,1,p_Monto,p_Usuario,p_Sucursal,vFolio,p_Transacc)
--         RETURNING CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
--	     g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;

         CALL principalrefer(p_Empresa,p_NumCredito,1,p_Tarjeta,p_Usuario,p_Sucursal,p_referencia,p_Transacc,0,p_Monto,p_referencia)
         RETURNING CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
	     g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;


          IF(CodRet <> "000") THEN
             ROLLBACK WORK;
            IF (wBegin = "S") THEN
                BEGIN WORK;
            END IF;
          END IF;

   END IF


        SELECT descripcion
          INTO Mensaje
          FROM bdinteg:si_codret
         WHERE sistema = g_sistema
           AND codigo_retorno = CodRet;


           IF CodRet < 0 THEN
               LET Mensaje = "Ocurrio un error en informix";
           END IF;



   RETURN CodRet,Mensaje;

END PROCEDURE
DOCUMENT
'Programa de Cargos y Abonos para Aclaraciones',
'Es llamado desde la aplicacion de aclaraciones',
'Sistema Aclaraciones',
'AUTOR : Juan Olivares Martinez',
'FECHA : 02/Febrero/2011',
'VERSION: 1.0.0',
'BD    : BDICRED';


