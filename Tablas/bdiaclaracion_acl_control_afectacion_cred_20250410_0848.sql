






{ TABLE "informix".acl_control_afectacion_cred row size = 356 number of columns = 7 index size = 9 }

create table "informix".acl_control_afectacion_cred 
  (
    id_registro serial not null ,
    folio_csuac varchar(50),
    fecha_hora datetime year to fraction(5),
    tipo_afectacion char(20),
    codigo_retorno char(20),
    descripcion char(150),
    procedurename char(100),
    primary key (id_registro) 
  );

revoke all on "informix".acl_control_afectacion_cred from "public" as "informix";




