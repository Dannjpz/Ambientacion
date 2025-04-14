DROP PROCEDURE IF EXISTS "informix".genmovref(
                   VARCHAR(3),
               VARCHAR(20),
              VARCHAR(4),
                     MONEY(14,2),
                     VARCHAR(16),
                  CHAR(4),
                   CHAR(20),
                VARCHAR(40));


CREATE PROCEDURE "informix".genmovref(
   p_empresa                VARCHAR(3),
   p_num_credito            VARCHAR(20),
   p_num_producto           VARCHAR(4),
   p_monto                  MONEY(14,2),
   p_folio                  VARCHAR(16),
   p_sucursal               CHAR(4),
   p_tarjeta                CHAR(20),
   p_referencia             VARCHAR(40))

RETURNING VARCHAR(5);

DEFINE   p_cod_ret       VARCHAR(10);
DEFINE   p_mensaje       VARCHAR(80);

DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
DEFINE vFecHoy     DATE;
DEFINE vDivisa     CHAR(2);

   --SET DEBUG FILE TO "/resplogifx/repaclaraciones/genmovref.out";
   --TRACE ON;


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET  = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET;
   END EXCEPTION;

   LET P_COD_RET      = '00000';
   LET P_MENSAJE      = 'PROCESO EXITOSO';
   LET vDivisa        = '';

  Select fecha_hoy Into vFecHoy From sd_fechas where empresa = p_empresa;
  Select divisa Into vDivisa From sd_maecred where empresa = p_empresa and num_credito = p_num_credito;

   CALL GenMov(p_empresa, p_num_credito, p_num_producto,20,
                  '336', vFecHoy, p_monto, p_folio,
                  p_sucursal, vDivisa, '0000') RETURNING
                  P_COD_RET, P_MENSAJE;
   IF (P_COD_RET <> "00000") THEN
         RETURN P_COD_RET;
   ELSE
         LET P_COD_RET = "000";
         UPDATE sd_movdia SET referencia23 = p_referencia,
                nro_tarjeta = p_Tarjeta 
         WHERE empresa = p_empresa and fecha_mov = vFecHoy and num_credito = p_num_credito and
               folio_suc = p_folio;
   END IF;
   RETURN P_COD_RET;

END;
END PROCEDURE DOCUMENT "Version 1.00.000";


