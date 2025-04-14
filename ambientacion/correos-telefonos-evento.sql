Select * from bdinteg:si_cliente

-- insertar clientes
INSERT INTO bdinteg:"informix".si_cliente (
    empresa,           -- CHAR(3)
    numcte,            -- CHAR(20) - Clave primaria
    status_cte,        -- CHAR(2)
    sucursal,          -- CHAR(4)
    ejecutivo,         -- CHAR(8)
    tpo_persona,      -- CHAR(2)
    tipo_cliente,      -- CHAR(1)
    apell_paterno,      -- CHAR(26)
    apell_materno,      -- CHAR(26)
    nombre1,           -- CHAR(26)
    nombre2,           -- CHAR(26)
    razon_social,      -- CHAR(120)
    rfc,               -- CHAR(13)
    sector,            -- CHAR(2)
    segmento,          -- CHAR(3)
    actividad_princ,   -- CHAR(3)
    grupo,             -- CHAR(3)
    subgrupo,          -- CHAR(3)
    residencia,        -- CHAR(1)
    fecha_alta,        -- DATE
    apell_casada,       -- CHAR(25)
    distrito,          -- CHAR(2)
    numcte_ref,        -- CHAR(20)
    string1,           -- CHAR(20)
    string2,           -- CHAR(60)
    numeric1,          -- SMALLINT
    numeric2,          -- INTEGER
    money1,            -- MONEY
    date1,             -- DATE
    puesto_ppes,       -- CHAR(1)
    familiar_ppes,      -- CHAR(1)
    actividad_esp,     -- CHAR(11)
    ejecut_autoriza,   -- CHAR(8)
    user_insert,       -- CHAR(12)
    fecha_insert,      -- DATE
    rfc_alterno,       -- CHAR(13)
    tpo_biometria,    -- CHAR(1)
    cliente_pros,      -- CHAR(1)
    envio_movtos       -- SMALLINT
) VALUES (
    '001',                     -- empresa
    '031547492',               -- numcte (el número de cliente que necesitas) --
    'A',                       -- status_cte (Activo)
    '0001',                    -- sucursal
    'SISTEMA',                 -- ejecutivo
    '01',                      -- tipo_persona (01=Física, 02=Moral)
    'N',                       -- tipo_cliente (N=Normal)
    'APELLIDO',                -- apel_paterno
    'MATERNO',                 -- apel_materno
    'NOMBRE',                  -- nombre1
    '',                        -- nombre2
    '',                        -- razon_social
    'XXXX999999XX9',           -- rfc
    '01',                      -- sector
    '001',                     -- segmento
    '001',                     -- actividad_princ
    '001',                     -- grupo
    '001',                     -- subgrupo
    'N',                       -- residencia (N=Nacional)
    CURRENT,                   -- fecha_alta (fecha actual)
    '',                        -- apel_casada
    '01',                      -- distrito
    '',                        -- numcte_ref
    '',                        -- string1
    '',                        -- string2
    0,                         -- numeric1
    0,                         -- numeric2
    0,                         -- money1
    CURRENT,                   -- date1
    'N',                       -- puesto_ppes (N=No)
    'N',                       -- familar_ppes (N=No)
    '',                        -- actividad_esp
    'SISTEMA',                 -- ejecut_autoriza
    'SISTEMA',                 -- user_insert
    CURRENT,                   -- fecha_insert
    '',                        -- rfc_alterno
    'N',                       -- tipo_biometria
    'N',                       -- cliente_pros
    0                          -- envio_movtos
);

INSERT INTO bdinteg:"informix".si_correos (
    empresa,        -- CHAR(3)
    numcte,         -- CHAR(20)
    correo_elec,    -- CHAR(100)
    tipo_correo,    -- SMALLINT
    status_correo,  -- CHAR(1)
    secuencia,      -- SMALLINT
    canal,          -- SMALLINT
    fecha_hora,     -- CHAR(23)
    user_insert,    -- CHAR(8)
    valida_correo,  -- CHAR(1)
    valido,         -- CHAR(1)
    fecha_valida    -- DATETIME
) VALUES (
    '001',                     -- empresa
    '031547492',               -- numcte --
    'cliente@ejemplo.com',     -- correo_elec
    1,                         -- tipo_correo (1=principal)
    'A',                       -- status_correo (A=Activo)
    1,                         -- secuencia
    1,                         -- canal
    CURRENT,                   -- fecha_hora
    'SISTEMA',                 -- user_insert
    'S',                       -- valida_correo (S=Sí)
    'S',                       -- valido (S=Sí)
    CURRENT                    -- fecha_valida
);

INSERT INTO bdinteg:"informix".si_telefonos (
    empresa,        -- CHAR(3)
    numcte,         -- CHAR(20)
    telefono,       -- CHAR(13)
    tipo_tel,       -- SMALLINT
    status_tel,     -- CHAR(1)
    secuencia,      -- SMALLINT
    extension,      -- CHAR(5)
    carrier,        -- SMALLINT
    canal,          -- SMALLINT
    contacto,       -- SMALLINT
    cofetel,        -- CHAR(1)
    fecha_hora,     -- DATETIME
    user_insert,    -- CHAR(8)
    movil_fijo,     -- CHAR(1)
    status_stel,    -- CHAR(1)
    verificado,     -- CHAR(1)
    marcatel,       -- CHAR(1)
    fecha_actualiza,-- DATE
    tel_confirmado, -- CHAR(1)
    fech_confirmado -- DATETIME
) VALUES (
    '001',                     -- empresa
    '031547492',               -- numcte --
    '5512345678',              -- telefono
    2,                         -- tipo_tel (2=celular)
    'A',                       -- status_tel (A=Activo)
    1,                         -- secuencia
    '',                        -- extension
    1,                         -- carrier (1=Telcel, ajustar según corresponda)
    1,                         -- canal
    1,                         -- contacto
    'S',                       -- cofetel
    CURRENT,                   -- fecha_hora
    'SISTEMA',                 -- user_insert
    'M',                       -- movil_fijo (M=Móvil)
    'A',                       -- status_stel
    'S',                       -- verificado
    'N',                       -- marcatel
    CURRENT,                   -- fecha_actualiza
    'S',                       -- tel_confirmado
    CURRENT                    -- fech_confirmado
);


SELECT *
FROM acl_aclaracion
WHERE folio_csuac = '2710242285'

SELECT COUNT(*)
FROM bdinteg:"informix".si_cliente
WHERE numcte = '031547492'


UPDATE acl_aclaracion
SET folio_csuac = '2710242286'  -- Use a new unique folio
WHERE pky_aclaracion = 2475466;
