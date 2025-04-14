DROP PROCEDURE IF EXISTS "informix".cargo_ref(     char(3),
                                          char(4),
                                           char(8),
                                          char(4),
                                           char(4),
                                            char(16),
                                            char(20),
                                            integer,
                                             money(14,2),
                                            char(2),
                                        char(40),
                                        char(16),
                                        char(8) );


CREATE PROCEDURE "informix".cargo_ref( pempresa    char(3),
                                       psucursal   char(4),
                                       pusuario    char(8),
                                       ptransacc   char(4),
                                       ptransuc    char(4),
                                       pfolsuc     char(16),
                                       pcuenta     char(20),
                                       pcheque     integer,
                                       pmonto      money(14,2),
                                       pdivisa     char(2),
                                       preferencia char(40),
                                       pnum_tarjeta char(16),
                                       pusuautoriza char(8) )
RETURNING CHAR(5), CHAR(4), DATE, MONEY(14,2), MONEY(14,2);
    
    -- // Variables Globales Conciliacion intercar
    DEFINE GLOBAL vg_estatus    VARCHAR(5)  DEFAULT " ";
    DEFINE GLOBAL vgrfc_comer   VARCHAR(20) DEFAULT " ";
    DEFINE GLOBAL vgreferencia  VARCHAR(40) DEFAULT " ";
    
    define vsqlerr              integer;
    define visamerr             integer;
    define vdescerr             char(50);
    define vcodret              char(5);
    define vcodret2             char(5);
    define vcodret3             char(50);
    define vtiptran             char(2);
    define vcodret1             char(5);
    define vtranret             char(4);
    define vtiporef             char(1);
    define vclave               char(4);
    define vcomision            money(14,2);
    define vfechoy              date;
    define vfechacalendario     date;
    define vsdodisp             money(14,2);
    define vcompend             money(14,2);
    define vmontoret            money(14,2);
    define vnip                 char(4);
    define vlimite_aut          money(14,2);
    define vdisp_mes            money(14,2);
    define vadicional           integer;
    define vtransaccion         integer;
    define vstatus_cta          char(1);
    define vmsje_limites        char(80);
    define vid_autor            char(1);
    define vnum_cte             char(20);
    define vuser_limit          char(8);
    define vtran_limit          char(8);
    define vid_transacc         char(2);
    define vid_canal            char(2);
    define vproducto            char(4);
    define vind_dispon          char(1);
    define vhora                DATETIME HOUR TO FRACTION(3);
    define vidtransacc          char(5);
    define vcodret_reg          char(5);
    define vserial              integer;
    define vprodtrnf            char(4);
    define vvueltas             integer;
    define vSQL                 char(10);
    define cStatus              char(1);
    define vcodretrev           char(5);
	define vfecha_operacion     date;
    define vstatus              smallint;
    define vcodretver           char(5);
    define vfecharet            date;
    define vsdo_cuenta          decimal(14,2);
    define vsdo_disponible      decimal(14,2);
    define vsdo_actual          decimal(14,2);
    define vsdo_retenido        decimal(14,2);
    define vsdo_cong            decimal(14,2);
    define vimp_chq_sbg         decimal(14,2);
    define vpri_dia_mes         date;
    define msdo_actual          money(14,2);
    define msdo_retenido        money(14,2);
    define msdo_cong            money(14,2);
    define mimp_chq_sbg         money(14,2);
	DEFINE vcuenta              CHAR(20);
	DEFINE ccodretma            CHAR(5);
    define vflag_siweb          smallint;
    
    let vsqlerr      = 0;
    let visamerr     = 0;
    let vdescerr     = '';
    let vtransaccion = 0;
    let vclave       = " ";
    let vind_dispon  = '0';
    let vcodret      = "000";
    let vcodret2     = "";
    let vcodret3     = "";
    let vtranret     = " ";
    let vtiporef     = "4";
    let vmontoret    = 0;
    let vsdodisp     = 0;
    let vnip         = " ";
    let vfechoy      = " ";
    
    let vidtransacc      = '';
    let vcodret_reg      = '';
    let vserial          = 0;
    let vprodtrnf        = '8000';
    let vvueltas         = 0; 
    let vSQL             = '';
    let cStatus          = '';
    let vcodretrev       = '';
	let vfecha_operacion = TODAY;
    let vstatus          = 0;
    let vcodretver       = '';
    let vfecharet        = '';
    let vsdo_cuenta      = 0.00;
    let vsdo_disponible  = 0.00;
    let vsdo_actual      = 0.00;
    let vsdo_retenido    = 0.00;
    let vsdo_cong        = 0.00;
    let vimp_chq_sbg     = 0.00;
    let vpri_dia_mes     = '';
    let msdo_actual      = 0.00;
    let msdo_retenido    = 0.00;
    let msdo_cong        = 0.00;
    let mimp_chq_sbg     = 0.00;
	LET vcuenta          = '';
	LET ccodretma        = '';
    let vflag_siweb      = 0;

    --SET DEBUG FILE TO "/resplogifx/repaclaraciones/cargo_ref.out";
	--TRACE ON;
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        --set debug file to "/tmp/cargo_ref.err";
        --trace on;
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            IF SUBSTR(pcuenta, 1, 2) <> '80' THEN
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
            END IF;
            return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if;
    end exception;
    
    on exception in (-535)
        let vtransaccion = 1;
    end exception with resume;
    
    --- set debug file to "/tmp/cargo_ref.out";
    --- trace on;
    
    set isolation to dirty read;
    set lock mode to wait 5;
	
	
	--SIWEB
	IF ((TRIM(pcuenta) == '') AND (TRIM(pnum_tarjeta) == '')) THEN
		LET vcodret = '100';
		RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
	END IF;
	--SIWEB
	
	--AFORE
	IF ptransacc = '0223' and ptransuc= '0223' AND pcuenta <> '' AND psucursal <> '' AND pusuario <> '' THEN
    EXECUTE PROCEDURE bdinteg:"informix".sp_inserta_msjafore('',pcuenta,psucursal, pusuario)
    INTO ccodretma;
    END IF;
    --AFORE

	
    -- // PARA CUENTAS TRANSFER
    IF SUBSTR(pcuenta, 1, 2) = '80' THEN
        
        LET vcodret = "999";
        RETURN vcodret, '', vfechoy, 0, 0;
            
        /* ##########################################################################################################################################
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
    
        -- // Valida fecha de proceso de la cuenta
        select fecha_hoy, ind_disponible
          into vfechoy, vind_dispon
          from sc_fechas 
         where empresa = pempresa;
        
        IF vind_dispon = '0' THEN
            LET vcodret = "004";
            RETURN vcodret, '', vfechoy, 0, 0;
        END IF;
        
        SELECT valor
          INTO vprodtrnf
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = 'ProductoTransfer';
           
        SELECT status_cta
          INTO vstatus_cta
          FROM bditransfer:tf_maecte
         WHERE cuenta_tf = pcuenta;
        
        IF ( pcuenta = '80009999999' AND ptransacc = '0223' AND ptransuc = '9002' ) THEN
        
            LET vhora = CURRENT HOUR TO FRACTION;
            
            -- // Inserta el movimiento en la tabla de movimientos diarios...
            INSERT INTO sc_movdia VALUES
            ( 0, pfolsuc, psucursal, pusuario, vfechoy, vfechoy, vhora, ptransacc, psucursal, vprodtrnf, 
              pempresa, pcuenta, "", 0, pmonto, 0, 0, 0, 0, "", vstatus_cta, 0.00, ptransuc, preferencia, 0, '', '', '', vfecha_operacion);
            
        ELSE
            
            SELECT valor
              INTO vidtransacc
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = 'TranCargoTransfer';    
            
            --- CALL sp_transfer_online_cargo( vidtransacc, pcuenta, pfolsuc, pmonto, pusuario )
            --- RETURNING vcodret_reg, vserial;
            
            IF ptransacc = '0274' THEN
                CALL sp_transfer_online_cargospei( vidtransacc, pcuenta, pfolsuc, pmonto, pusuario )
                RETURNING vcodret_reg, vserial;
            ELSE
                CALL sp_transfer_online_cargo( vidtransacc, pcuenta, pfolsuc, pmonto, pusuario )
                RETURNING vcodret_reg, vserial;
            END IF;
            
            IF ( vcodret_reg is null OR vcodret_reg <> '000' ) OR ( vserial is null OR vserial = 0 ) THEN                
                LET vcodret = '999';
                
                IF vtransaccion = 1 THEN
                    COMMIT WORK;
                    BEGIN WORK;
                ELSE
                    COMMIT WORK;
                END IF;
                
                RETURN vcodret, '', vfechoy, 0, 0;
            END IF;
            
            COMMIT WORK;
            
            LET vvueltas = 0;
            LET cStatus = 'N';
            
            WHILE cStatus IN('N','E') 
                SELECT status
                  INTO cStatus
                  FROM sc_transfer_online
                 WHERE no_serial = vserial
                   AND cuenta = pcuenta
                   AND folio_suc = pfolsuc
                   AND id_transacc = vidtransacc;
                   
                IF cStatus IN('F','X') THEN
                    EXIT WHILE;
                ELSE
                    LET vSQL = 'sleep 3';
                    SYSTEM vSQL;
                       
                    LET vvueltas = vvueltas + 1;
                    
                    IF vvueltas > 5 THEN
                        EXIT WHILE; 
                    END IF;
                END IF;
            END WHILE;
            
            IF ( cStatus is null OR cStatus = '' OR cStatus IN('N','E') ) THEN
            
                UPDATE {+INDEX(sc_transfer_online idx_transferonline_serctafoltra)} 
                       sc_transfer_online
                   SET status = 'T'
                 WHERE no_serial = vserial
                   AND cuenta = pcuenta
                   AND folio_suc = pfolsuc
                   AND id_transacc = vidtransacc;
                   
                -- // INICIO REVERSO AUTOMATICO A TRANSFER POR TIMEOUT // --
                SELECT valor
                  INTO vidtransacc
                  FROM sc_param
                 WHERE empresa = pempresa
                   AND codparam = 'TranReverTransfer';
                   
                CALL sp_transfer_online_reverso( vidtransacc, pcuenta, pfolsuc, pusuario )
                RETURNING vcodret_reg, vserial;
                
                IF ( vcodret_reg = '000' AND vserial > 0 ) THEN
                    LET vvueltas = 0;
                    LET cStatus = 'N';
                    
                    WHILE cStatus IN('N','E') 
                        SELECT status
                          INTO cStatus
                          FROM sc_transfer_online
                         WHERE no_serial = vserial
                           AND cuenta = pcuenta
                           AND folio_suc = pfolsuc
                           AND id_transacc = vidtransacc;
                           
                        IF cStatus IN('F','X') THEN
                            EXIT WHILE;
                        ELSE
                            LET vSQL = 'sleep 3'; 
                            SYSTEM vSQL;
                               
                            LET vvueltas = vvueltas + 1;
                            
                            IF vvueltas > 5 THEN
                                EXIT WHILE;
                            END IF;
                        END IF;
                    END WHILE;
                    
                    IF ( cStatus is null OR cStatus = '' OR cStatus IN('N','E') ) THEN
                        UPDATE {+INDEX(sc_transfer_online idx_transferonline_serctafoltra)} 
                               sc_transfer_online
                           SET status = 'T'
                         WHERE no_serial = vserial
                           AND cuenta = pcuenta
                           AND folio_suc = pfolsuc
                           AND id_transacc = vidtransacc;
                    END IF;
                END IF;
                -- // FINAL REVERSO AUTOMATICO A TRANSFER POR TIMEOUT // --
                
                LET vcodret = '24';
                
                IF vtransaccion = 1 THEN
                    BEGIN WORK;
                END IF;
                
                RETURN vcodret, '', vfechoy, 0, 0;
                
            ELIF cStatus = 'X' THEN
            
                SELECT cod_ret
                  INTO vcodret
                  FROM sc_transfer_online
                 WHERE no_serial = vserial
                   AND cuenta = pcuenta
                   AND folio_suc = pfolsuc
                   AND id_transacc = vidtransacc;
                
                IF vtransaccion = 1 THEN
                    BEGIN WORK;
                END IF;
                
                RETURN vcodret, '', vfechoy, 0, 0;
            END IF;
            
            BEGIN WORK;
            
            LET vhora = CURRENT HOUR TO FRACTION;
            
            -- // Inserta el movimiento en la tabla de movimientos diarios...
            INSERT INTO sc_movdia VALUES
            ( 0, pfolsuc, psucursal, pusuario, vfechoy, vfechoy, vhora, ptransacc, psucursal, vprodtrnf, 
              pempresa, pcuenta, "", 0, pmonto, 0, 0, 0, 0, "", vstatus_cta, 0.00, ptransuc, preferencia, 0, '', '', '', vfecha_operacion);
        
        END IF;
          
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
        ########################################################################################################################################## */
    
    -- // PARA CUENTAS DEL BANCO
    ELSE
    
        if vtransaccion = 1 then
            COMMIT WORK;
            BEGIN WORK;
        else
            BEGIN WORK;
        end if;
    
        -- // Valida fecha de proceso de la cuenta
        select fecha_hoy, ind_disponible, pri_dia_mes
          into vfechacalendario, vind_dispon, vpri_dia_mes
          from sc_fechas 
         where empresa = pempresa;
        
        if vind_dispon = '0' then
            let vcodret = "004";
            return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if;
		
		--  SIWEB EN CASO DE NO TRAER CUENTA
		IF (TRIM(pcuenta) == '') THEN
			SELECT cuenta
			INTO vcuenta
			FROM sc_tarjeta
			WHERE empresa = pempresa
			AND num_tarjeta = pnum_tarjeta
			AND status_tar = 'A';
			
			IF (TRIM(vcuenta) == '') THEN 
				LET vcodret = "100";
				RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
			END IF;
			
			LET pcuenta = TRIM(vcuenta);
		END IF;
		--SIWEB EN CASO DE NO TRAER CUENTA
		
        select fecha_proceso, status_cta, num_cte, producto, sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg
          into vfechoy, vstatus_cta, vnum_cte, vproducto, vsdo_actual, vsdo_retenido, vsdo_cong, vimp_chq_sbg
          from sc_maechq
         where empresa = pempresa
           and cuenta = pcuenta;
		   
   -- // 05/06/2021
		   
		execute procedure sp_cargo_val(pcuenta)
		into vcodret;

		if vcodret <> '00000' then
			let vcodret = '307';
			return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
		end if;
		
    -- // 05/06/2021
           
        if vsdo_retenido < 0 then
            let vsdo_retenido = vsdo_retenido * -1;
        end if;
        
        if vsdo_cong < 0 then
            let vsdo_cong = vsdo_cong * -1;
        end if;
        
        if vimp_chq_sbg < 0 then
            let vimp_chq_sbg = vimp_chq_sbg * -1;
        end if;
           
        if vproducto in('1100', '2300') and ptransacc = '0223' then
           let vcodret = "962";
           return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if  
		
		if vproducto in('1100', '2300') and ptransacc = '0402' then
           let vcodret = "100";
           return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if  

        if vproducto = '2300' and ptransacc = '0239' and ptransuc <> '0000' then
           let vcodret = "962";
           return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if   
        
        if vproducto in('2800') and ptransacc in ('0223','0402') then
           let vcodret = "404";
           return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if    
    
        if (vfechoy is null or vstatus_cta = '4' or vstatus_cta = '5') then
            let vfechoy = vfechacalendario;
        end if
        
        if vstatus_cta = '8' then
            if ptransacc = '0223' or ptransacc = '0320' or ptransacc = '0270' or ptransacc = '0252' or ptransacc = '0402' then
                let vfechoy = vfechacalendario;
            else
                let vcodret = "200";
                return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
            end if
        end if
    
        if (vfechoy < vfechacalendario) then
            let vcodret = "549";
            return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if
        
        if ( vstatus_cta in('2','6','7') ) then
            let vcodret = "200";
            return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if
        
        -- // Valida que exista la transaccion de cargo y determina el tipo de transacciÃÂ³n
        select tipo_tran
          into vtiptran
          from bdinteg:si_transacc
         where empresa = pempresa
           and numero = ptransacc
           and sistema = '01'
           and naturaleza = 'C';
        
        if vtiptran is null then
            let vcodret = "550";
            return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if;
	
        -- // Valida la sucursal para transacciones de aclaraciones
        IF ptransacc IN('0342', '0343') THEN
            SELECT sucursal 
              INTO psucursal
              FROM bdinteg:si_sucursales
             WHERE sucursal = psucursal;
             
                IF psucursal is null or psucursal = "" THEN
                    SELECT sucursal
                      INTO psucursal		  
                      FROM bdinteg:si_ejecut 
                     WHERE ejecutivo in( SELECT num_empleado 
                                           FROM bdiaclaracion:acl_aclaracion 
                                          WHERE folio_csuac = preferencia );
                END IF;
        END IF;	   
	
        -- // Valida limite autorizado en tarjetas adicionales
        if pcuenta = "" then
            select cuenta
              into pcuenta
              from sc_tarjeta
             where empresa = pempresa
               and num_tarjeta = pnum_tarjeta;
        end if;
    
        if ptransacc <> '0830' and ptransacc <> '0887' then
            select limite_aut, disp_mes
              into vlimite_aut, vdisp_mes
              from sc_tarjeta
             where empresa = pempresa
               and num_tarjeta = pnum_tarjeta
               and cuenta = pcuenta
               and tipo_tarjeta = "A";
        
            let vadicional = dbinfo("sqlca.sqlerrd2");
        
            if vadicional <> 0 then
                IF vlimite_aut <> 0 THEN
                    let vdisp_mes = nvl(vdisp_mes,0)  + pmonto;
                    
                    if vdisp_mes > vlimite_aut then
                        let  vcodret = "777";
                        return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
                    end if
                END IF
            end if
        end if;
    
        -- // Se modifca  la referencia pra el Pago de Cheque Propio en Sucursal
        if ptransacc ='3333' then 
            let preferencia = 'Pago Cheq. No.'|| trim(pcheque::char(7)) || ' Suc. ' || trim(psucursal::char(4));
        end if;
        
        -- // ValidaciÃÂ³n de limites 
        select usuario
          into vuser_limit
          from bdinteg:si_usuario_limites
         where usuario = pusuario
           and empresa = pempresa;
    
        if (vuser_limit is not null or vuser_limit <> '') then 
            -- // validaciÃÂ³n adicional para reconocimiento de canal 120612
            IF (vuser_limit = "intercar") then
                select transacc, id_transacc, id_canal
                  into vtran_limit, vid_transacc, vid_canal
                  from bdinteg:si_transacc_limites
                 where transacc = ptransacc
                   and empresa = pempresa
                   and sistema = '01';
            ELSE
                SELECT id_canal 
                  into vid_canal
                  from bdinteg:si_canales
                 where cc_canal = psucursal;

                select transacc, id_transacc
                  into vtran_limit, vid_transacc
                  from bdinteg:si_transacc_limites
                 where transacc = ptransacc
                   and empresa = pempresa
                   and sistema = '01'
                   and id_canal = vid_canal;
            END IF;         

            if (vtran_limit is not null or vtran_limit <> '') then
                execute procedure bdinteg:sp_limite_max(vnum_cte, pcuenta, vid_transacc, vid_canal, vfechoy, pmonto, pnum_tarjeta)
                into vcodret, vmsje_limites, vid_autor;

                if vcodret = '00035' then
                    let vcodret = '035';
                    return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
                else
                    let vcodret = '000';
                end if;
            end if;
        end if;
        
        -- // Valida Nuevos Limites Establecidos por PLD para Retiros en Efectivo
        if ptransacc = '0223' and ptransuc <> '0301' then
            select status
              into vstatus
              from sc_retirocliente_exento 
             where cliente = vnum_cte; 
             
            if ( vstatus = 0 or vstatus is null ) then
                call sp_verifica_retiro_efectivo( psucursal, pcuenta, pmonto, vfechacalendario, vpri_dia_mes )
                returning vcodretver, vfecharet, vsdo_cuenta;
                
                if vcodretver = '000' then
                    if vfecharet < vfechacalendario then
                        let vsdo_cuenta = vsdo_cuenta;
                    else
                        let vsdo_cuenta = vsdo_actual;
                    end if;                    
                    
                    let vsdo_disponible = vsdo_cuenta - vsdo_retenido - vsdo_cong - vimp_chq_sbg;
                    
                    if vsdo_disponible < 0 then
                        let vsdo_disponible = 0.00;
                    end if;
                    
                    if pmonto > vsdo_disponible then
                        let vcodret = "400";
                        return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
                    end if;
                else
                    let vcodret = '999';
                    return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
                end if;
            end if;
        end if;
        
        -- // Determina tipo de cargo
        if vtiptran >= "20" and vtiptran <= "29" then
            call gen_protsdo(pempresa, psucursal, pusuario, ptransacc, ptransuc, pfolsuc, pcuenta, pmonto, 
                             pcheque, pdivisa, vnip, preferencia, vtiporef, pnum_tarjeta, pusuautoriza)
            returning vcodret, vclave, vcomision;
        
            if vcodret <> "000" then
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
                return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
            end if;
        else
            if vtiptran >= "30" and vtiptran <= "39" then
                call protsdo(pempresa, psucursal, pusuario, ptransacc, ptransuc, pfolsuc, pcuenta, pcheque, pmonto, pdivisa, vclave)
                returning vcodret, vtranret;
            
                if vcodret <> "000" then
                    if vtransaccion = 1 then
                        ROLLBACK WORK;
                        BEGIN WORK;
                    else
                        ROLLBACK WORK;
                    end if;
            
                    return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
                end if;
            else
                --//validacion piloto SIWEB
                select nvl(flag_piloto,0)
                into vflag_siweb 
                from bdinteg:si_sucursales_web
                where sucursal = psucursal;
                
                if vflag_siweb <> 0 then
                    --//SP SIWEB validacion de transacciones duplicadas
                    call cargon_ref_web(pempresa, psucursal, pusuario, ptransacc, ptransuc, pfolsuc, pcuenta, 
                                pcheque, pmonto, pdivisa, preferencia, pnum_tarjeta, pusuautoriza)
                    returning vcodret, vtranret;                
                else
                    call cargon_ref(pempresa, psucursal, pusuario, ptransacc, ptransuc, pfolsuc, pcuenta, 
                                pcheque, pmonto, pdivisa, preferencia, pnum_tarjeta, pusuautoriza)
                    returning vcodret, vtranret;
                end if;

                -- // Forza a aplicar los movtos para un cheque propio sobregirado PISA 26 Marzo 2010
                if vcodret <> "000" and vcodret <> "400" then 
                    if vtransaccion = 1 then
                        ROLLBACK WORK;
                        BEGIN WORK;
                    else
                        ROLLBACK WORK;
                    end if;
                    
                    return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
                end if;
            end if
        end if
        
        -- // Obtiene saldo disponible de la cuenta despues de la transacciÃÂ³n de cargo
        --- select sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc), com_pendiente
        --- into vsdodisp, vcompend
        select sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, com_pendiente
          into msdo_actual, msdo_retenido, msdo_cong, mimp_chq_sbg, vcompend
          from sc_maechq
         where empresa = pempresa
           and cuenta = pcuenta;
           
        if msdo_retenido < 0 then
            let msdo_retenido = msdo_retenido * -1;
        end if;
        
        if msdo_cong < 0 then
            let msdo_cong = msdo_cong * -1;
        end if;
        
        if mimp_chq_sbg < 0 then
            let mimp_chq_sbg = mimp_chq_sbg * -1;
        end if;   
        
        let vsdodisp = msdo_actual - ( msdo_retenido + msdo_cong + mimp_chq_sbg);
        
        IF vsdodisp is null or vsdodisp < 0 then
            LET vsdodisp = 0.00;
        END IF;
        
        if vtransaccion = 1 then
            COMMIT WORK;
            BEGIN WORK;
        else
            COMMIT WORK;
        end if;
    END IF;
        
    let vtranret = ptransacc;
    let vmontoret = pmonto;
    
    return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        
    END;
    
END PROCEDURE;


