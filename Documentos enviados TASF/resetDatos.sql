-- Actualización principal en acl_aclaracion por folios
UPDATE acl_aclaracion
SET fky_estatus_aclaracion = 1,
    fky_estatus_corp_general = 6,  -- EN_PROCESO
    fecha_dictamen = NULL,
    dias_conclusion = NULL,
    predictamen = NULL,
    procede = NULL
WHERE folio_csuac IN (
    '3012241210', '0303250002', '2710242285', '2610241719', '0303250001',
    '2510243532', '2510243321', '2510243295', '2510243122', '2510243070',
    '2510243036', '2510242971', '2710242286', '2610241720', '2510243533',
    '2510243327', '2510243037', '2510242972', '0710240007', '2208240003'
);

-- Actualización de movimientos en bdiaclaracion
UPDATE bdiaclaracion:acl_movimiento
SET exitoso = NULL,
    cargo = 1,
    reversado = 0
WHERE folio_csuac IN (
    '3012241210', '0303250002', '2710242285', '2610241719', '0303250001',
    '2510243532', '2510243321', '2510243295', '2510243122', '2510243070',
    '2510243036', '2510242971', '2710242286', '2610241720', '2510243533',
    '2510243327', '2510243037', '2510242972', '0710240007', '2208240003'
);

-- Eliminación de registros en acl_cierre_masivo
DELETE FROM informix.acl_cierre_masivo
WHERE folio_csuac IN (
    '3012241210', '0303250002', '2710242285', '2610241719', '0303250001',
    '2510243532', '2510243321', '2510243295', '2510243122', '2510243070',
    '2510243036', '2510242971', '2710242286', '2610241720', '2510243533',
    '2510243327', '2510243037', '2510242972', '0710240007', '2208240003'
);

-- Verificación
SELECT pky_aclaracion, folio_csuac, predictamen, fky_estatus_aclaracion, procede
FROM bdiaclaracion:acl_aclaracion
WHERE folio_csuac IN (
    '3012241210', '0303250002', '2710242285', '2610241719', '0303250001',
    '2510243532', '2510243321', '2510243295', '2510243122', '2510243070',
    '2510243036', '2510242971', '2710242286', '2610241720', '2510243533',
    '2510243327', '2510243037', '2510242972', '0710240007', '2208240003'
);



--- SP principalrefer

DELETE FROM bdicred:sd_maecredanexorev 
WHERE empresa = '001' 
AND num_credito = '540000000005' 
AND folio = '3012241210';

DELETE FROM bdicred:sd_paginterrev 
WHERE empresa = '001' 
AND num_credito = '540000000005'  -- cambiar por el num credito usado
AND folio = '3012241210'; --cambiar por el folio usado

DELETE FROM bdicred:sd_pagocapitrev 
WHERE empresa = '001' 
AND num_credito = '540000000005' 
AND folio = '3012241210';

DELETE FROM bdicred:sd_maesdosrev 
WHERE empresa = '001' 
AND num_credito = '540000000005' 
AND folio = '3012241210';

DELETE FROM bdicred:sd_maecredrev 
WHERE empresa = '001' 
AND num_credito = '540000000005' 
AND folio = '3012241210';

SELECT * FROM bdicred:sd_maecredanexorev 
WHERE empresa = '001' 
AND num_credito = '540000000005' 
AND folio = '3012241210';

