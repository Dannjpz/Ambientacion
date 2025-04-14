INSERT INTO bdiaclaracion:acl_movimiento (
    pky_movimiento,
    calculado,
    cargo,
    exitoso,
    fechahora,
    folio_csuac,
    folio_suc,
    monto,
    montoprocedente,
    duplicado,
    numero_transaccion,
    procede,
    referencia,           -- Added this required field
    referencia23,         -- Added this field
    reversado,
    secuencia,
    fky_aclaracion,
    fky_producto,
    fky_tipo_evento,
    fky_tipo_movimiento,
    ref_comercio,
    num_sucursal,
    fecha_consumo,
    recuperacion,
    identificador_adquiriente, -- Added this field
    iso_37,               -- Added this field
    iso_41                -- Added this field
) VALUES (
    (SELECT MAX(pky_movimiento) + 1 FROM bdiaclaracion:acl_movimiento), -- Generar nuevo ID
    0,                                  -- calculado
    1,                                  -- cargo (1=cargo, 0=abono)
    NULL,                               -- exitoso (NULL para que sea procesado)
    CURRENT YEAR TO FRACTION(3),        -- fechahora
    '2710242285',                       -- folio_csuac
    'i061414341443050',                 -- folio_suc (ejemplo)
    100.00,                             -- monto
    100.00,                             -- montoprocedente
    0,                                  -- duplicado
    '4200',                             -- numero_transaccion (código de transacción) 4200 = C/Valido  0340 = R/Retiro
    1,                                  -- procede
    'REF2710242285',                    -- referencia (required)
    'REF23-2710242285',                 -- referencia23
    0,                                  -- reversado
    1,                                  -- secuencia
    (SELECT pky_aclaracion FROM bdiaclaracion:acl_aclaracion WHERE folio_csuac = '2710242285'), -- fky_aclaracion
    (SELECT fky_producto FROM bdiaclaracion:acl_aclaracion WHERE folio_csuac = '2710242285'),   -- fky_producto
    (SELECT fky_tipo_evento FROM bdiaclaracion:acl_aclaracion WHERE folio_csuac = '2710242285'), -- fky_tipo_evento
    332,                                -- fky_tipo_movimiento (basado en ejemplos)
    'COMERCIO EJEMPLO',                 -- ref_comercio
    '9250',                             -- num_sucursal
    CURRENT - 5 UNITS DAY,              -- fecha_consumo (5 días atrás)
    0,                                  -- recuperacion
    'ADQU',                             -- identificador_adquiriente
    'ISO37 EXAMPLE',                    -- iso_37
    'ISO41 EXAMPLE'                     -- iso_41
);


SELECT * FROM bdiaclaracion:acl_movimiento 
WHERE folio_csuac = '2710242285';

-- Verificar si existe la tarjeta
SELECT * FROM bdicred:sd_tarjeta 
WHERE num_tarjeta = '4268070364108912' AND empresa = '001';

-- Verificar si existe el crédito
SELECT * FROM bdicred:sd_maecred 
WHERE num_credito = '600209310934' AND empresa = '001';

-- Verificar la relación entre tarjeta y crédito
SELECT a.num_tarjeta, a.num_credito, b.num_credito 
FROM bdicred:sd_tarjeta a
JOIN bdicred:sd_maecred b ON a.num_credito = b.num_credito AND a.empresa = b.empresa
WHERE a.num_tarjeta = '4268070364108912' AND a.empresa = '001';


-- Insertar registro en sd_tarjeta
INSERT INTO bdicred:sd_tarjeta (
    empresa,
    num_credito,
    secuencia,
    num_tarjeta,
    numcte,
    prodtarjeta,
    expiracion,
    tipo_tarjeta,
    nombre,
    status_tar,
    limite_aut,
    disp_mes,
    motivo,
    tipo_asignacion,
    cobro_comision,
    gerente_autoriza,
    folio_canc
) VALUES (
    '001',                      -- empresa
    '600209310934',             -- num_credito
    1,                          -- sequence
    '4268070364108912',         -- num_tarjeta
    '600209310934',             -- numcte (mismo que num_credito)
    '5400',                     -- prodtarjeta (basado en ejemplos)
    CURRENT + 5 UNITS YEAR,     -- expiracion (5 años a partir de hoy)
    'T',                        -- tipo_tarjeta
    'CLIENTE PRUEBA ACLARACION', -- nombre
    'A',                        -- status_tar (A=Activa)
    20000,                      -- limite_aut
    NULL,                       -- disp_mes
    '06',                       -- motivo
    'R',                        -- tipo_asignacion
    'N',                        -- cobro_comision
    'transBPI',                 -- gerente_autoriza
    NULL                        -- folio_canc
);

-- Insertar registro en sd_maecred
INSERT INTO bdicred:sd_maecred (
    empresa,
    num_credito,
    num_producto,
    ejecutivo,
    numcte,
    divisa,
    sucursal,
    id_origen,
    origen,
    cod_tipo_linea,
    cod_linea,
    porc_rec_prop,
    status_cred,
    bandera_renovac,
    bandera_prorroga,
    periodo_plazo,
    plazo,
    fecha_apertura,
    fecha_vencim,
    period_pago_cap,
    period_pag_int,
    dias_trasp_cap,
    dias_trasp_int,
    tasa_fija_o_var,
    cod_tasa_base,
    factor_sobretasa,
    sobretasa,
    tasa_interes,
    cod_tasa_mora,
    sobretasa_mora,
    fact_sobret_mora,
    tasa_moratorios,
    fecha_pago_cap,
    fecha_pago_int,
    es_fisica,
    bandera_fi_fo,
    codigo_pro,
    superficie,
    actividad,
    cal_edos_fin,
    tipo_calculo,
    admite_tlp,
    rel_garcred,
    id_unidad_prod,
    num_aper_ant,
    rev_tasa_var_per,
    dia_para_revisar,
    cod_prod,
    bandera_ministra,
    num_fideicomiso,
    credito_externo,
    gracia_capital,
    diferimiento_int,
    fecha_fin_prorrateo,
    campo_trab1,
    campo_trab2,
    campo_trab3,
    campo_trab4,
    calificacion_riesgo,
    cod_agricola,
    tasa_base_piso,
    sobretasa_piso,
    factor_piso,
    tasa_piso,
    tasa_base_techo,
    sobretasa_techo,
    factor_techo,
    tasa_techo,
    cod_caract,
    cod_caract_2,
    cuenta_clabe
) VALUES (
    '001',                      -- empresa
    '600209310934',             -- num_credito
    '5400',                     -- num_producto
    '90045445',                 -- ejecutivo
    '600209310934',             -- numcte
    '01',                       -- divisa
    '6700',                     -- sucursal
    NULL,                       -- id_origen
    NULL,                       -- origen
    NULL,                       -- cod_tipo_linea
    NULL,                       -- cod_linea
    100,                        -- porc_rec_prop
    'E1',                       -- status_cred
    'N',                        -- bandera_renovac
    'N',                        -- bandera_prorroga
    'M',                        -- periodo_plazo
    0,                          -- plazo
    CURRENT,                    -- fecha_apertura
    CURRENT + 1 UNITS YEAR,     -- fecha_vencim
    '3',                        -- period_pago_cap
    '2',                        -- period_pag_int
    60,                         -- dias_trasp_cap
    60,                         -- dias_trasp_int
    'F',                        -- tasa_fija_o_var (changed from NULL to 'F')
    'TASATC54',                 -- cod_tasa_base
    '+',                        -- factor_sobretasa
    0,                          -- sobretasa
    14,                         -- tasa_interes
    'TMORAINF',                 -- cod_tasa_mora
    0,                          -- sobretasa_mora
    '+',                        -- fact_sobret_mora
    17,                         -- tasa_moratorios
    NULL,                       -- fecha_pago_cap
    NULL,                       -- fecha_pago_int
    'S',                        -- es_fisica
    NULL,                       -- bandera_fi_fo
    NULL,                       -- codigo_pro
    0,                          -- superficie
    NULL,                       -- actividad
    NULL,                       -- cal_edos_fin
    'TC',                       -- tipo_calculo (changed from NULL to 'TC')
    '0',                        -- admite_tlp (changed from 0 to '0')
    0,                          -- rel_garcred
    1,                          -- id_unidad_prod (changed from NULL to 1)
    NULL,                       -- num_aper_ant
    '0',                        -- rev_tasa_var_per (changed from 0 to '0')
    NULL,                       -- dia_para_revisar
    'M',                        -- cod_prod
    'N',                        -- bandera_ministra (changed from NULL to 'N')
    '600209310934',             -- num_fideicomiso
    NULL,                       -- credito_externo (changed from 0 to NULL)
    0,                          -- gracia_capital
    0,                          -- diferimiento_int
    CURRENT,                    -- fecha_fin_prorrateo
    0,                          -- campo_trab1
    0,                          -- campo_trab2
    NULL,                       -- campo_trab3
    NULL,                       -- campo_trab4
    'A1',                       -- calificacion_riesgo
    NULL,                       -- cod_agricola
    NULL,                       -- tasa_base_piso
    NULL,                       -- sobretasa_piso
    NULL,                       -- factor_piso
    NULL,                       -- tasa_piso
    NULL,                       -- tasa_base_techo
    NULL,                       -- sobretasa_techo
    NULL,                       -- factor_techo
    NULL,                       -- tasa_techo
    NULL,                       -- cod_caract
    NULL,                       -- cod_caract_2
    '137975600209310934'        -- cuenta_clabe
);

-- Verificar que los registros se insertaron correctamente
SELECT * FROM bdicred:sd_tarjeta 
WHERE num_tarjeta = '4268070364108912' AND empresa = '001';

SELECT * FROM bdicred:sd_maecred 
WHERE num_credito = '600209310934' AND empresa = '001';

SELECT a.num_tarjeta, a.num_credito, b.num_credito 
FROM bdicred:sd_tarjeta a
JOIN bdicred:sd_maecred b ON a.num_credito = b.num_credito AND a.empresa = b.empresa
WHERE a.num_tarjeta = '4268070364108912' AND a.empresa = '001';


INSERT INTO bdicred:sd_maesdos (
    empresa,
    num_credito,
    fecha_ult_mov,
    sdo_int_anticip,
    sdo_int_ant_dev,
    sdo_intereses,
    sdo_dia_ant_int,
    sdo_mes_ant_int,
    sdo_acum_mes_int,
    sdo_retenido,
    sdo_acum_cap_int,
    sdo_exig_int,
    sdo_no_exig,
    provision_normal,
    dias_acum_int,
    sdo_moratorio,
    sdo_dia_ant_mor,
    sdo_mes_ant_mor,
    sdo_contab_mora,
    dias_acum_mora,
    sdo_capital,
    sdo_cap_insoluto,
    sdo_dia_ant_cap,
    sdo_mes_ant_cap,
    sdo_acum_mes_cap,
    mto_capitalizado,
    mto_ministra_cap,
    cargos_dia_cap,
    abonos_dia_cap,
    cargos_mes_cap,
    abonos_mes_cap,
    dias_acum_cap,
    monto_vencido,
    mto_venc_trasp,
    monto_financiado,
    monto_reservado,
    sdo_acum_vencido,
    dias_acum_intper,
    sdo_global_int,
    sdo_acum_intper,
    monto_otorgado,
    provi_venc_normal,
    provi_venc_anticip,
    cap_tras_no_venci,
    mto_venc_int,
    mto_venc_tra_int,
    mto_finan_vdo,
    mto_reser_int,
    mto_fin_ven_trasp,
    mto_fin_vig_trasp,
    int_tra_no_exig,
    sdo_trab4,
    act
) VALUES (
    '001',                      -- empresa
    '600209310934',             -- num_credito
    CURRENT,                    -- fecha_ult_mov
    0,                          -- sdo_int_anticip
    0,                          -- sdo_int_ant_dev
    0,                          -- sdo_intereses
    0,                          -- sdo_dia_ant_int
    0,                          -- sdo_mes_ant_int
    0,                          -- sdo_acum_mes_int
    0,                          -- sdo_retenido
    0,                          -- sdo_acum_cap_int
    0,                          -- sdo_exig_int
    0,                          -- sdo_no_exig
    0,                          -- provision_normal
    0,                          -- dias_acum_int
    0,                          -- sdo_moratorio
    0,                          -- sdo_dia_ant_mor
    0,                          -- sdo_mes_ant_mor
    0,                          -- sdo_contab_mora
    0,                          -- dias_acum_mora
    5000,                       -- sdo_capital
    5000,                       -- sdo_cap_insoluto
    0,                          -- sdo_dia_ant_cap
    0,                          -- sdo_mes_ant_cap
    0,                          -- sdo_acum_mes_cap
    5000,                       -- mto_capitalizado
    0,                          -- mto_ministra_cap
    0,                          -- cargos_dia_cap
    0,                          -- abonos_dia_cap
    0,                          -- cargos_mes_cap
    0,                          -- abonos_mes_cap
    0,                          -- dias_acum_cap
    0,                          -- monto_vencido
    0,                          -- mto_venc_trasp
    0,                          -- monto_financiado
    0,                          -- monto_reservado
    0,                          -- sdo_acum_vencido
    0,                          -- dias_acum_intper
    0,                          -- sdo_global_int
    0,                          -- sdo_acum_intper
    20000,                      -- monto_otorgado
    0,                          -- provi_venc_normal
    0,                          -- provi_venc_anticip
    0,                          -- cap_tras_no_venci
    0,                          -- mto_venc_int
    0,                          -- mto_venc_tra_int
    0,                          -- mto_finan_vdo
    0,                          -- mto_reser_int
    0,                          -- mto_fin_ven_trasp
    0,                          -- mto_fin_vig_trasp
    0,                          -- int_tra_no_exig
    0,                          -- sdo_trab4
    0                           -- act
);

SELECT * FROM bdicred:sd_maesdos 
WHERE num_credito = '600209310934' AND empresa = '001';


INSERT INTO bdicred:sd_maecredanexo (
    empresa,
    num_credito,
    dia_corte,
    dias_gracia_mora,
    tp_dias_calc_mora,
    dias_fecha_max_pago,
    tp_dias_fecha_pago,
    cod_tasa_base_cte,
    factor_sobretasa_cte,
    sobretasa_cte,
    tasa_interes_cte,
    fecha_vencto,
    prox_fecha_pago,
    fecha_proceso,
    fecha_ult_pago
) VALUES (
    '001',                      -- empresa
    '600209310934',             -- num_credito
    19,                         -- dia_corte (día del mes para el corte)
    4,                          -- dias_gracia_mora
    '1',                        -- tp_dias_calc_mora
    26,                         -- dias_fecha_max_pago
    '1',                        -- tp_dias_fecha_pago
    'TASATC54',                 -- cod_tasa_base_cte
    '+',                        -- factor_sobretasa_cte
    0,                          -- sobretasa_cte
    NULL,                       -- tasa_interes_cte
    NULL,                       -- fecha_vencto
    CURRENT + 30 UNITS DAY,     -- prox_fecha_pago (30 días después de la fecha actual)
    CURRENT,                    -- fecha_proceso (fecha actual)
    CURRENT - 15 UNITS DAY      -- fecha_ult_pago (15 días antes de la fecha actual)
);

-- Verificar que el registro se insertó correctamente
SELECT * FROM bdicred:sd_maecredanexo 
WHERE num_credito = '600209310934' AND empresa = '001';


SELECT pky_movimiento, folio_csuac, numero_transaccion
FROM bdiaclaracion:acl_movimiento
WHERE folio_csuac = '2710242285';

-- Actualiza transacción a la deseada
UPDATE bdiaclaracion:acl_movimiento
SET numero_transaccion = '4200'  -- Actualizar el código de transacción
WHERE folio_csuac = '2710242285';

-- Tambien validamos la tipo_acl_movimiento
SELECT a.pky_movimiento, a.folio_csuac, a.numero_transaccion, a.fky_tipo_movimiento, 
       c.pky_tipo_movimiento, c.trans_procede, c.trans_no_procede, 
       c.trans_procede_automatico, c.trans_procede_sin_autorizacion
FROM bdiaclaracion:acl_movimiento a
LEFT JOIN bdiaclaracion:acl_tipo_movimiento c ON a.fky_tipo_movimiento = c.pky_tipo_movimiento
WHERE a.folio_csuac = '2710242285';

UPDATE bdiaclaracion:acl_tipo_movimiento
SET trans_procede = '4200',
    trans_procede_automatico = '4200',
    trans_procede_sin_autorizacion = '4200'
WHERE pky_tipo_movimiento = 332;

