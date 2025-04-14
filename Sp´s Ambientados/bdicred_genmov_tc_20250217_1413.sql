DROP PROCEDURE IF EXISTS "informix".genmov_tc(
                   VARCHAR(3),
               VARCHAR(20),
              VARCHAR(4),
                 DATE,
                     MONEY(14,2),
                  VARCHAR(16),
                  VARCHAR(4),
                    VARCHAR(2),
              VARCHAR(4),
                   VARCHAR(20),
                VARCHAR(40),
               DECIMAL(14,6),
                 DECIMAL(14,2),
                   CHAR(8),
   		    CHAR(4),
   	  	    VARCHAR(20),
   	    VARCHAR(23));

CREATE PROCEDURE "informix".genmov_tc(
   p_empresa                VARCHAR(3),
   p_num_credito            VARCHAR(20),
   p_num_producto           VARCHAR(4),
   p_fecha_hoy              DATE,
   p_monto                  MONEY(14,2),
   p_foliosuc               VARCHAR(16),
   p_sucursal               VARCHAR(4),
   p_divisa                 VARCHAR(2),
   p_transacc_suc           VARCHAR(4),
   p_tarjeta                VARCHAR(20),
   p_referencia             VARCHAR(40),
   p_tipo_cambio            DECIMAL(14,6),
   p_monto_dls              DECIMAL(14,2),
   p_usuario                CHAR(8),
   p_sucorigen		    CHAR(4),
   p_rfc_comer	  	    VARCHAR(20),
   p_referencia23	    VARCHAR(23))

RETURNING VARCHAR(10), VARCHAR(80);

DEFINE   p_cod_ret       VARCHAR(10);
DEFINE   p_mensaje       VARCHAR(80);

DEFINE   v_plaza         VARCHAR(3);
DEFINE   v_hora          DATETIME HOUR TO FRACTION(3);
DEFINE   vm_secuencia    INTEGER;
DEFINE   v_reversado     VARCHAR(1);
DEFINE   v_usuario       VARCHAR(8);

DEFINE   v_num_producto  VARCHAR(4);
DEFINE   v_codigo_ref    INTEGER;
DEFINE   v_codigo_fun    VARCHAR(3);
DEFINE   v_fecha_hoy     DATE;
DEFINE   v_monto         DECIMAL(18,2);
DEFINE   v_foliosuc      VARCHAR(16);
DEFINE   v_sucursal      VARCHAR(4);
DEFINE   v_divisa        VARCHAR(2);
DEFINE   v_transacc_suc  VARCHAR(4);
DEFINE   vCodFun         CHAR(3);
DEFINE   vCodRef         SMALLINT;
define   v_refpaso       varchar(63);

DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
DEFINE vcadena     INTEGER;

	--SET DEBUG FILE TO "/resplogifx/repaclaraciones/genmov_tc.out";
	--TRACE ON;

BEGIN


   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET  = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET      = '000';
   LET P_MENSAJE      = 'PROCESO EXITOSO';
   LET v_num_producto =  p_num_producto ;
   LET v_fecha_hoy    =  p_fecha_hoy    ;
   LET v_monto        =  p_monto        ;
   LET v_foliosuc     =  p_foliosuc     ;
   LET v_sucursal     =  p_sucursal     ;
   LET v_divisa       =  p_divisa       ;
   LET v_transacc_suc =  p_transacc_suc ;
   let v_refpaso      = '';

   IF (p_transacc_suc IS NULL) THEN
      LET p_cod_ret = '110';
      LET P_MENSAJE = 'ERROR';
      RETURN P_COD_RET, P_MENSAJE;
   ELSE
      SELECT codigo_fun, codigo_ref
	INTO vCodFun, vCodRef
       FROM sd_transfun
      WHERE empresa = p_empresa
	AND transacc = p_transacc_suc;

      IF vCodFun IS NULL THEN
      	LET p_cod_ret = '110';
      	LET P_MENSAJE = 'ERROR';
      	RETURN P_COD_RET, P_MENSAJE;
      END IF
   END IF;

   IF (v_fecha_hoy IS NULL) THEN
      SELECT fecha_hoy
      INTO   v_fecha_hoy
      FROM   sd_fechas;
   END IF;
   IF (v_monto IS NULL) THEN
      LET v_monto = 0;
   END IF;
   IF (v_divisa IS NULL) THEN
      LET v_divisa = '00';
   END IF;
   IF (v_num_producto IS NULL) THEN
      LET v_num_producto = '    ';
   END IF;

   IF (v_foliosuc IS NULL) THEN
      LET p_cod_ret = '110';
      LET P_MENSAJE = 'ERROR';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   LET p_cod_ret    = '000';
   LET P_MENSAJE    = 'PROCESO EXITOSO';
   LET v_hora       = EXTEND(CURRENT,HOUR TO fraction(3));

   LET v_reversado  = 'N';
--   v_usuario    := USER;


   LET vcadena = 0;

--   let vcadena = length(p_foliosuc) - 8;
--   LET v_usuario    = substr(p_foliosuc,1,vcadena);

--   LET v_usuario    = substr(v_foliosuc,1,8);

   --############################################################
   --####  GENERACION DE MOVIMIENTOS Y DETALLE CONTABLE     #####
   --############################################################

   IF p_referencia IS NULL OR p_referencia = " " THEN
	SELECT nvl(abreviatura,'') INTO p_referencia
	  FROM sd_transfun a, bdinteg:si_transacc b
	 WHERE a.empresa = p_empresa
	   AND a.codigo_fun = vCodFun
	   AND a.codigo_ref = vCodRef
	   AND b.empresa = a.empresa
	   AND b.numero = a.transacc
	   AND b.sistema = "06";
   END IF

   if (length(p_referencia) > 1) then
      LET v_refpaso = trim(p_foliosuc || " " || trim(p_referencia));
   else
      LET v_refpaso = trim(p_foliosuc);
   end if;

-- En caso de no tener referencia23 utilzia espacios para guardar referencia adicional
   if (trim(nvl(p_referencia23,'')) = '' and length(trim(v_refpaso)) > 40) then
      LET p_referencia23 = substr(trim(v_refpaso),41);
   end if;

   let p_referencia = trim(v_refpaso);

-- limpia referencia en IVA
   if (vCodFun = '340') then
      LET p_referencia = '';
   end if;

   SELECT plaza
   INTO   v_plaza
   FROM   bdinteg:si_sucursales
   WHERE  empresa  = p_empresa
   AND    sucursal = v_sucursal;

   IF V_PLAZA IS NULL OR V_PLAZA = '' THEN
      LET P_COD_RET = '00100';
      LET P_MENSAJE = 'LA INFORMACION PLAZA/SUCURSAL DEL CREDITO ES INCORRECTA';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   INSERT INTO sd_movdia (
               EMPRESA        ,
               FECHA_MOV      ,
               HORA_MOV       ,
               SUCURSAL       ,
               NUM_CREDITO    ,
               PLAZA          ,
               TRANSACC_SUC   ,
               USUARIO        ,
               MONTO          ,
               CODIGO_FUN     ,
               CODIGO_REF     ,
               DIVISA         ,
               REVERSADO      ,
               FOLIO_SUC      ,
               NUM_PRODUCTO   ,
	       NRO_TARJETA    ,
	       REFERENCIA     ,
               TIPO_CAMBIO    ,
	       MONTO_DLS      ,
	       SUC_ORIGEN     ,
	       RFC_COMER      ,
	       REFERENCIA23   )
      VALUES ( p_empresa,
               v_fecha_hoy,
               current,
               v_sucursal,
               p_num_credito,
               v_plaza,
               v_transacc_suc,
               p_usuario,
               v_monto,
               vCodFun,
               vCodRef,
               v_divisa,
               v_reversado,
               v_foliosuc,
               v_num_producto,
	       p_tarjeta,
	       p_referencia,
	       p_tipo_cambio,
	       p_monto_dls,
               p_sucorigen,
	       p_rfc_comer,
	       p_referencia23);

   RETURN P_COD_RET, P_MENSAJE;

END
END PROCEDURE
DOCUMENT
'Esta funcion realiza el Registro de los Movimientos generados por T.C.',
'AUTOR : Antonio Ruiz Martinez',
'FECHA : 29/12/2006',
'BD : bdicred ',
'CLIENTE : COPPEL';


