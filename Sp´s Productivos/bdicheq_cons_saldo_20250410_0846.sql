DROP PROCEDURE IF EXISTS "informix".cons_saldo( char(20));

create procedure "informix".cons_saldo(pcuenta char(20))

returning char(5),money(16,2),char(1);

    define vcodret    char(5);
    define vsqlerr    integer;
    define vcuenta    char(20);
    define vsdodisp   money(16,2);
    define vstatuscta char(1);
    define vmotivo    char(2);
    define vcargo     char(1);
    define vabono     char(1);

    let vcodret    = "000";
    let vcuenta    = "";
    let vsdodisp   =  0;
    let vstatuscta = " ";

	--SET DEBUG FILE TO "/resplogifx/repaclaraciones/cons_saldo.out";
	--TRACE ON;
    
    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vsdodisp,vstatuscta;
        end if
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;

    --- // Valida que la Cuenta no sea Blanco
    if pcuenta = " " then
        let vcodret = "110";
        return vcodret,vsdodisp,vstatuscta;
    end if

    --- // Valida que Exista la Cuenta de Cheques
    select cuenta, sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc), status_cta, motivo
      into vcuenta, vsdodisp, vstatuscta, vmotivo
      from sc_maechq
     where cuenta = pcuenta;
     
    if vcuenta is null or vcuenta <> pcuenta then
        let vcodret = "100";
        return vcodret, vsdodisp,vstatuscta;
    end if

    if vstatuscta = "3" then
        select cargo, abono 
          into vcargo, vabono
          from sc_bloqueo
         where codigo = vmotivo;
         
        if vcargo = "S" or vabono = "S" then
            let vstatuscta = "1";
        end if
    end if
    
    return vcodret,vsdodisp,vstatuscta;
    
    end
    
end procedure;


