DROP PROCEDURE IF EXISTS "informix".renivelaplanpagos();


CREATE PROCEDURE "informix".renivelaplanpagos()
   RETURNING CHAR(5);

   DEFINE CodRet                CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nRows                 SMALLINT;

   DEFINE GLOBAL g_Empresa       CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito    CHAR(20)    DEFAULT ' ';

   DEFINE CuotaFija              MONEY(14,2);
   DEFINE TasaInteres            DECIMAL(9,6);
   DEFINE vPlazo                 SMALLINT;
   DEFINE Factor                 DECIMAL(9,6);

   DEFINE Interes                MONEY(14,2);
   DEFINE Capital                MONEY(14,2);
   DEFINE SdoCapital             MONEY(14,2);

   DEFINE vFecha                 DATE;
   DEFINE vSdoCap                MONEY(14,2);
   DEFINE vCapit                 MONEY(14,2);
   DEFINE vInter                 MONEY(14,2);
   DEFINE SdoInteres             MONEY(14,2);

   DEFINE MontoRealPag           MONEY(14,2);
   DEFINE StatusCuota            CHAR(1);
   DEFINE wfecha                 DATE;


   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "RenivelaPLanPagos.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

   SET DEBUG FILE TO "/resplogifx/repaclaraciones/sp_renivelaplanpagos.out";
   TRACE ON;

   LET CodRet = '000';

   CREATE  TEMP TABLE
      RenivPagos
         (fecha   DATE,
          sdocap  MONEY(14,2),
          capit   MONEY(14,2),
          inter   MONEY(14,2));

   INSERT INTO RenivPagos SELECT
                             fecha_cuota,
                             0,
                             0,
                             0
                          FROM
                             sd_pagocapit
                          WHERE
                             empresa  = g_Empresa
                          AND
                             num_credito = g_NumCredito
                          AND
                             status_cuota = '1';

   SELECT
      tasa_interes,
      (SELECT a.monto_cuota + b.monto_cuota
         FROM sd_pagocapit a, sd_paginter b
        WHERE b.num_credito = a.num_credito
          AND b.fecha_cuota = a.fecha_cuota
          AND a.num_credito = g_NumCredito
          AND a.fecha_cuota = (SELECT MIN(fecha_cuota) FROM sd_pagocapit d
                                WHERE d.num_credito = g_NumCredito)),
 
      plazo,
      sdo_capital
   INTO
      TasaInteres,
      CuotaFija,
      vPlazo,
      SdoCapital
   FROM
      sd_maecred a,
      sd_maesdos b
   WHERE
      a.empresa = g_Empresa
   AND
     a.num_credito = g_NumCredito
   AND
      b.empresa = a.empresa
   AND
      b.num_credito = a.num_credito;

   SELECT
      SUM(saldo_cuota - monto_real_pag)
   INTO
      SdoCapital
   FROM
      sd_pagocapit
   WHERE
      empresa = g_Empresa
   AND
      num_credito = g_NumCredito
   AND
     status_cuota = '1';


   LET Factor = ROUND((((TasaInteres/ 100) / 12) + 1) , 6);

   FOREACH
      SELECT
         fecha,
         sdocap,
         capit ,
         inter
      INTO
         vFecha,
         vSdoCap,
         vCapit,
         vInter
      FROM
         RenivPagos
      ORDER BY
         fecha

      LET vInter = ROUND((SdoCapital * (Factor - 1)), 2);
      LET vCapit = CuotaFija - vInter;
      IF (vCapit > SdoCapital) THEN
         LET vCapit = SdoCapital;
      END IF;
      LET vSdoCap = SdoCapital;
      LET SdoCapital = SdoCapital - vCapit;
      UPDATE
         RenivPagos
      SET
         SdoCap = vSdoCap,
         Capit  = vCapit,
         Inter  = vInter
      WHERE
         fecha = vFecha;

   END FOREACH;

   FOREACH
      SELECT
         fecha,
         sdocap,
         capit ,
         inter
      INTO
         vFecha,
         vSdoCap,
         vCapit,
         vInter
      FROM
         RenivPagos
      ORDER BY
         fecha

      UPDATE
         sd_pagocapit
      SET
         monto_cuota = vCapit,
         saldo_cuota = vCapit,
         monto_real_pag = 0
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito
      AND
         fecha_cuota = vFecha;

      UPDATE
         sd_paginter
      SET
         monto_cuota = vInter
      WHERE
         empresa = g_Empresa
      AND
         num_credito = g_NumCredito
      AND
         fecha_cuota = vFecha;

   END FOREACH;

   SELECT
      SUM(monto_cuota - monto_real_pag)
   INTO
     SdoInteres
   FROM
      sd_paginter
   WHERE
      empresa = g_Empresa
   AND
      num_credito = g_NumCredito;

   UPDATE
      sd_maesdos
   SET
      sdo_no_exig = SdoInteres
   WHERE
      empresa = g_Empresa
   AND
      num_credito = g_NumCredito;


   DROP TABLE RenivPagos;

   RETURN CodRet;

END PROCEDURE

DOCUMENT
'Programa de Renivelacion de Pagos despues de un Pago Anticipado ',
'AUTOR : Raul Mendoza D nes',
'FECHA : 17/Diciembre/2003',
'CTE   : CACSI',
'BD    : BDICRED';


