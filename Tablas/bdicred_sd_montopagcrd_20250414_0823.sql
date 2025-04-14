






{ TABLE "informix".sd_montopagcrd row size = 51 number of columns = 6 index size = 24 }

create table "informix".sd_montopagcrd 
  (
    empresa char(3),
    monto money(14,2),
    mv_interes_cs money(14,2),
    mv_iva_cs money(14,2),
    mv_capital_cs money(14,2),
    folio char(16),
    primary key (empresa,folio) 
  );

revoke all on "informix".sd_montopagcrd from "public" as "informix";




