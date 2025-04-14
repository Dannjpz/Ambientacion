DROP PROCEDURE IF EXISTS "informix".cargo_comisiones(  CHAR(3),
                                                CHAR(20),
                                              CHAR(4),
                                                 MONEY(14,2),
                                                 CHAR(16),
                                              CHAR(4),
                                               CHAR(8),
                                                INTEGER,
                                                CHAR(2),
                                                   DATE);


CREATE PROCEDURE "informix".cargo_comisiones(eEmpresa  CHAR(3),
                                             eCuenta   CHAR(20),
                                             eComision CHAR(4),
                                             eMonto    MONEY(14,2),
                                             eFolio    CHAR(16),
                                             eSucursal CHAR(4),
                                             eUsuario  CHAR(8),
                                             eCheque   INTEGER,
                                             eDivisa   CHAR(2),
                                             eHoy      DATE)
RETURNING CHAR(5);
    
    DEFINE eCodRet          CHAR(5);
    DEFINE eCodRet2         CHAR(5);
    DEFINE eCodRet3         CHAR(50);
    DEFINE sql_err          SMALLINT;
    DEFINE isam_err         SMALLINT;
    DEFINE error_info       CHAR(50);
    DEFINE vFormaAplic      CHAR(1);
    DEFINE vMtoAplic        MONEY(14,2);
    DEFINE vFactorAplic     DECIMAL(9,6);
    DEFINE vRangos          CHAR(1);
    DEFINE vRangoMin        DECIMAL(14,2);
    DEFINE vRangoMax        DECIMAL(14,2);
    DEFINE vGenIva          CHAR(1);
    DEFINE vTranCom         CHAR(4);
    DEFINE vTranIva         CHAR(4);
	DEFINE vNumTarjeta      CHAR(20);
	DEFINE pNumTarjeta      CHAR(20);
    DEFINE vMontoCom        MONEY(14,2);
    DEFINE vValIva          DECIMAL(9,6);
    DEFINE vDisponible      MONEY(14,2);
    DEFINE vMtoCom          MONEY(14,2);
    DEFINE vMontoPen        MONEY(14,2);
    DEFINE vMontoDif        MONEY(14,2);
    DEFINE vexistecta       SMALLINT;
    DEFINE vexistecom       SMALLINT;
	DEFINE vproducto        CHAR(4);
	DEFINE vIVA             MONEY(14,2);
    DEFINE vSdoDisp         MONEY(14,2);

    ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "/tmp/cargo_comisiones.err";
        TRACE ON;
        LET eCodRet = sql_err;
        LET eCodRet2 = isam_err;
        LET eCodRet3 = error_info;
        RETURN eCodRet;
    END EXCEPTION;

    LET eCodRet      = "000";
    LET eCodRet2     = "000";
    LET eCodRet3     = "000";
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET error_info   = '';
    LET vFormaAplic  = '';
    LET vMtoAplic    = 0;
    LET vFactorAplic = 0;
    LET vRangos      = '';
    LET vRangoMin    = 0;
    LET vRangoMax    = 0;
    LET vGenIva      = '';
    LET vTranCom     = '';
    LET vTranIva     = '';
    LET vMontoCom    = 0;
    LET vValIva      = 0;
	LET vNumTarjeta  = '';
	LET pNumTarjeta  = '';
    LET vDisponible  = 0;
    LET vMtoCom      = 0;
    LET vMontoPen    = 0;
    LET vMontoDif    = 0;
    LET vexistecta   = 0;
    LET vexistecom   = 0;
	LET vproducto    = '';
	LET vIVA         = 0;
    LET vSdoDisp     = 0;
	
    --- SET DEBUG FILE TO "/tmp/cargo_comisiones.out";
    --- TRACE ON;

    --SET DEBUG FILE TO "/resplogifx/repaclaraciones/cargo_comisiones.out";
	--TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA DATOS DE ENTRADA - EMPRESA
    IF eEmpresa is null OR eEmpresa = '' THEN
        LET eCodRet = '110';
        RETURN eCodRet;
    END IF;
    
    -- // VALIDA DATOS DE ENTRADA - CUENTA
    SELECT producto, sdo_actual - ( sdo_retenido + sdo_cong + imp_chq_sbg )
      INTO vproducto, vDisponible
      FROM sc_maechq
     WHERE empresa = eEmpresa
       AND cuenta = eCuenta;

    IF vproducto in('1300', '1400', '1700') THEN
	   LET eCodRet = '000';
	   RETURN eCodRet;
	END IF;
	   
    --// Extrae instrumentacion de la Comision
    SELECT forma_aplica, monto_aplica, factor_aplica, rangos, rango_min, rango_max, genera_iva, transacc_com, transacc_iva
      INTO vFormaAplic, vMtoAplic, vFactorAplic, vRangos, vRangoMin, vRangoMax, vGenIva, vTranCom, vTranIva
      FROM sc_comisiones
     WHERE empresa = eEmpresa
       AND comision = eComision;
	   
	IF vFormaAplic is null OR vFormaAplic = " " THEN
       LET eCodRet = '550';
       RETURN eCodRet;
    END IF; 
	
	-- // Valida la sucursal para transacciones de aclaraciones
	IF eComision = '0343' THEN
	   SELECT sucursal 
	     INTO eSucursal
	     FROM bdinteg:si_sucursales
		WHERE sucursal = eSucursal;
	   IF eSucursal is null or eSucursal = "" THEN
	      SELECT sucursal
            INTO eSucursal		  
		    FROM bdinteg:si_ejecut 
		   WHERE ejecutivo in(SELECT num_empleado 
		                        FROM bdiaclaracion:acl_aclaracion 
							   WHERE folio_csuac = eFolio);
       END IF;
    END IF;	   
	
    SELECT valor 
      INTO vValIva 
      FROM bdinteg:si_param
     WHERE empresa = eEmpresa
       AND cod_param = 47;
		 
    -- // SE AGREGA UNA NUEVA FORMA DE APLICACION '3' VARIABLE 
    -- // Determina Forma de Aplicacion
    IF vFormaAplic = "1" THEN 
        LET vMontoCom = vMtoAplic; -- Monto Fijo de Comision
    ELIF vFormaAplic = "2" THEN  
        LET vMontoCom = eMOnto * vFactorAplic; -- Por Factor
    ELIF vFormaAplic = "3" THEN  -- Variable (JGP - Para Cheques Devueltos)
        LET vMontoDif = eMOnto - vDisponible;
        
        IF vMontoDif > vMtoAplic THEN
            LET vMontoCom = vMtoAplic;
        ELSE
            LET vMontoCom = vMontoDif;
        END IF;
    ELIF vFormaAplic = "4" THEN 
        LET vMontoCom = eMOnto; -- Aclaraciones
    END IF;

    -- // Valida los Rangos
    IF vRangos = "S" THEN
        IF vMontoCom < vRangoMin OR vMontoCom > vRangoMax THEN
            LET vMontoCom = vMtoAplic;
        END IF;
    END IF;

    IF vGenIva = "N" THEN 
        LET vValIva = 0;  
    END IF;

    IF vDisponible < (vMontoCom * (1 + vValIva)) THEN
        LET vMtoCom   = vMontoCom;
        LET vMontoCom = ROUND(vDisponible / (1 + vValIva),2);
        LET vMontoPen = vMtoCom - vMOntoCom;
		LET vIVA      = vDisponible - vMontoCom;
	ELSE
	    LET vIVA      = TRUNC((vMontoCom * vValIva),2);
    END IF;

--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra comision por reposicion de TDD
	IF vDisponible > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;
	    -- // Aplica Cargo por Comision	 
		IF vDisponible > 0 THEN 
        CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranCom, "0000", eFolio, eCuenta, eCheque, vMontoCom, eDivisa, "", pNumTarjeta,"")
        RETURNING eCodRet, eComision;
        
        IF eCodRet <> "000" THEN
            RETURN eCodRet;
        END IF;
        
        -- // Valida Cobro de Iva
        IF vGenIva = "S" THEN
            SELECT sdo_actual - ( sdo_retenido + sdo_cong + imp_chq_sbg )
              INTO vSdoDisp
              FROM sc_maechq
             WHERE empresa = eEmpresa
               AND cuenta = eCuenta;
--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra IVA de comision por reposicion de TDD			   
       IF vSdoDisp > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;  
            IF vSdoDisp > 0 THEN
                CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranIva, "0000", eFolio, eCuenta, eCheque, vIVA, eDivisa, "",pNumTarjeta,"")
                RETURNING eCodRet, eComision;
            END IF;
                
            IF eCodRet <> "000" THEN
                RETURN eCodRet;
            END IF;
        END IF;
    END IF;

    -- // Registra comision pendiente si es el caso
    IF vMontoPen > 0 THEN
        INSERT INTO sc_detcomis 
        VALUES(eEmpresa, eCuenta, vTranCom, vMontoPen  , 0, eHoy, "", "P", eFolio);

        UPDATE sc_maechq
           SET com_pendiente =  com_pendiente + vMontoPen
         WHERE empresa = eEmpresa
           AND cuenta  = eCuenta;
    END IF;

    RETURN eCodRet;

END PROCEDURE

DOCUMENT
'Esta funcion se encarga de realizar los movimientos de cargo por ',
'concepto de comisiones e iva de las mismas',
'AUTOR : Procesaminto Interactivo S.A. Axl',
'FECHA : 28/01/2010',
'BD : bdicheq ',
'CLIENTE : Todos';


