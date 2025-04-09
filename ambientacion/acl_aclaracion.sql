-- Se actualizaron los registros de acl_aclaracion:

UPDATE acl_aclaracion
SET folio_csuac = '3012241210',
    fky_estatus_aclaracion = 3,
    procede = 1,
    fky_tipo_codigo_resolucion = 6,
    predictamen = '{* Hemos atendido tu aclaración y abonado el importe reclamado a tu cuenta. Valoramos tu elección como cliente en BanCoppel y esperamos seguir siendo tu elección para futuras compras. ¡Siempre estaremos aquí para ayudarte!'
WHERE pky_aclaracion = 2475468;


UPDATE acl_aclaracion
SET fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 1,
    predictamen = '< Solicitud no procede ya que la transacción fue reversada por lo que no hubo cargo a cliente.(28-OCT-2024 / MLL)'
WHERE pky_aclaracion = 2475467;


UPDATE acl_aclaracion
SET folio_csuac = '2710242285',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 1,
    predictamen = '< Solicitud no procede ya que la transacción fue reversada por lo que no hubo cargo a cliente.(28-OCT-2024 / MLL)'
WHERE pky_aclaracion = 2475466;

UPDATE acl_aclaracion
SET folio_csuac = '2610241719',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '<+Tras revisar la transacción en detalle encontramos que no se esta cumpliendo con la digitalización completa de la documentación requerida en el folio y expediente del cliente como lo marca la decisión 6.0(28-OCT-2024 / ARAV)'
WHERE pky_aclaracion = 2475465;


UPDATE acl_aclaracion
SET fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación que previamente recibió en su teléfono o correo electrónico. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475464;

UPDATE acl_aclaracion
SET folio_csuac = '2510243532',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación que previamente recibió en su teléfono o correo electrónico. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475463;

-- Actualización del séptimo registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243321',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación que previamente recibió en su teléfono o correo electrónico. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475462;

-- Actualización del octavo registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243295',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede Se autentico introduciendo la tarjeta a una terminal leyendo el chip de la tarjeta y accesando su Nip. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475461;

-- Actualización del noveno registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243122',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede Se autentico introduciendo la tarjeta a una terminal leyendo el chip de la tarjeta y accesando su Nip. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475443;

-- Actualización del décimo registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243070',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede Se autentico introduciendo la tarjeta a una terminal leyendo el chip de la tarjeta y accesando su Nip. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475442;

-- Continuar con el resto de registros siguiendo el mismo patrón
UPDATE acl_aclaracion
SET folio_csuac = '2510243036',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '>Solicitud no procede la transacción fue devuelta por el comercio el día 16/10/2024 por la cantidad de $ 461 (25-OCT-2024 / USR5)'
WHERE pky_aclaracion = 2475441;

UPDATE acl_aclaracion
SET folio_csuac = '2510242972',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '>Solicitud no procede la transacción fue devuelta por el comercio el día 14/10/2024 por la cantidad de $ 471.16 (25-OCT-2024 / USR1)'
WHERE pky_aclaracion = 2475433;


---- COPIA:


UPDATE acl_aclaracion
SET folio_csuac = '2710242285',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 1,
    predictamen = '< Solicitud no procede ya que la transacción fue reversada por lo que no hubo cargo a cliente.(28-OCT-2024 / MLL)'
WHERE pky_aclaracion = 2475439;

UPDATE acl_aclaracion
SET folio_csuac = '2610241720',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '<+Tras revisar la transacción en detalle encontramos que no se esta cumpliendo con la digitalización completa de la documentación requerida en el folio y expediente del cliente como lo marca la decisión 6.0(28-OCT-2024 / ARAV)'
WHERE pky_aclaracion = 2475438;


UPDATE acl_aclaracion
SET fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación que previamente recibió en su teléfono o correo electrónico. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475437;

UPDATE acl_aclaracion
SET folio_csuac = '2510243532',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación que previamente recibió en su teléfono o correo electrónico. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475436;

-- Actualización del séptimo registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243327',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación que previamente recibió en su teléfono o correo electrónico. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475435;

-- Actualización del octavo registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243295',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede Se autentico introduciendo la tarjeta a una terminal leyendo el chip de la tarjeta y accesando su Nip. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475461;

-- Actualización del noveno registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243122',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede Se autentico introduciendo la tarjeta a una terminal leyendo el chip de la tarjeta y accesando su Nip. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475443;

-- Actualización del décimo registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243070',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede Se autentico introduciendo la tarjeta a una terminal leyendo el chip de la tarjeta y accesando su Nip. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475442;

-- Continuar con el resto de registros siguiendo el mismo patrón
UPDATE acl_aclaracion
SET folio_csuac = '2510243036',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '>Solicitud no procede la transacción fue devuelta por el comercio el día 16/10/2024 por la cantidad de $ 461 (25-OCT-2024 / USR5)'
WHERE pky_aclaracion = 2475441;

UPDATE acl_aclaracion
SET folio_csuac = '2510242971',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '>Solicitud no procede la transacción fue devuelta por el comercio el día 14/10/2024 por la cantidad de $ 471.16 (25-OCT-2024 / USR1)'
WHERE pky_aclaracion = 2475440;


UPDATE acl_aclaracion
SET folio_csuac = '2510243036',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '>Solicitud no procede la transacción fue devuelta por el comercio el día 16/10/2024 por la cantidad de $ 461 (25-OCT-2024 / USR5)'
WHERE pky_aclaracion = 2475434;



-- Se actualizaron los registros de acl_aclaracion:

UPDATE acl_aclaracion
SET folio_csuac = '3012241210',
    fky_estatus_aclaracion = 3,
    procede = 1,
    fky_tipo_codigo_resolucion = 6,
    predictamen = '{* Hemos atendido tu aclaración y abonado el importe reclamado a tu cuenta. Valoramos tu elección como cliente en BanCoppel y esperamos seguir siendo tu elección para futuras compras. ¡Siempre estaremos aquí para ayudarte!'
WHERE pky_aclaracion = 2475468;


UPDATE acl_aclaracion
SET fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 1,
    predictamen = '< Solicitud no procede ya que la transacción fue reversada por lo que no hubo cargo a cliente.(28-OCT-2024 / MLL)'
WHERE pky_aclaracion = 2475467;


UPDATE acl_aclaracion
SET folio_csuac = '2710242285',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 1,
    predictamen = '< Solicitud no procede ya que la transacción fue reversada por lo que no hubo cargo a cliente.(28-OCT-2024 / MLL)'
WHERE pky_aclaracion = 2475466;

UPDATE acl_aclaracion
SET folio_csuac = '2610241719',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '<+Tras revisar la transacción en detalle encontramos que no se esta cumpliendo con la digitalización completa de la documentación requerida en el folio y expediente del cliente como lo marca la decisión 6.0(28-OCT-2024 / ARAV)'
WHERE pky_aclaracion = 2475465;


UPDATE acl_aclaracion
SET fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación que previamente recibió en su teléfono o correo electrónico. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475464;

UPDATE acl_aclaracion
SET folio_csuac = '2510243532',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación que previamente recibió en su teléfono o correo electrónico. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475463;

-- Actualización del séptimo registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243321',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación que previamente recibió en su teléfono o correo electrónico. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475462;

-- Actualización del octavo registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243295',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede Se autentico introduciendo la tarjeta a una terminal leyendo el chip de la tarjeta y accesando su Nip. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475461;

-- Actualización del noveno registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243122',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede Se autentico introduciendo la tarjeta a una terminal leyendo el chip de la tarjeta y accesando su Nip. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475443;

-- Actualización del décimo registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243070',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede Se autentico introduciendo la tarjeta a una terminal leyendo el chip de la tarjeta y accesando su Nip. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475442;

-- Continuar con el resto de registros siguiendo el mismo patrón
UPDATE acl_aclaracion
SET folio_csuac = '2510243036',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '>Solicitud no procede la transacción fue devuelta por el comercio el día 16/10/2024 por la cantidad de $ 461 (25-OCT-2024 / USR5)'
WHERE pky_aclaracion = 2475441;

UPDATE acl_aclaracion
SET folio_csuac = '2510242972',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '>Solicitud no procede la transacción fue devuelta por el comercio el día 14/10/2024 por la cantidad de $ 471.16 (25-OCT-2024 / USR1)'
WHERE pky_aclaracion = 2475433;


---- COPIA:


UPDATE acl_aclaracion
SET folio_csuac = '2710242285',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 1,
    predictamen = '< Solicitud no procede ya que la transacción fue reversada por lo que no hubo cargo a cliente.(28-OCT-2024 / MLL)'
WHERE pky_aclaracion = 2475439;

UPDATE acl_aclaracion
SET folio_csuac = '2610241720',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '<+Tras revisar la transacción en detalle encontramos que no se esta cumpliendo con la digitalización completa de la documentación requerida en el folio y expediente del cliente como lo marca la decisión 6.0(28-OCT-2024 / ARAV)'
WHERE pky_aclaracion = 2475438;


UPDATE acl_aclaracion
SET fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación que previamente recibió en su teléfono o correo electrónico. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475437;

UPDATE acl_aclaracion
SET folio_csuac = '2510243532',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación que previamente recibió en su teléfono o correo electrónico. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475436;

-- Actualización del séptimo registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243327',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede: El cliente ingresó datos de su tarjeta y código de autenticación que previamente recibió en su teléfono o correo electrónico. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475435;

-- Actualización del octavo registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243295',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede Se autentico introduciendo la tarjeta a una terminal leyendo el chip de la tarjeta y accesando su Nip. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475461;

-- Actualización del noveno registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243122',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede Se autentico introduciendo la tarjeta a una terminal leyendo el chip de la tarjeta y accesando su Nip. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475443;

-- Actualización del décimo registro
UPDATE acl_aclaracion
SET folio_csuac = '2510243070',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = 'No procede Se autentico introduciendo la tarjeta a una terminal leyendo el chip de la tarjeta y accesando su Nip. (26-OCT-2024 / USR6)'
WHERE pky_aclaracion = 2475442;

-- Continuar con el resto de registros siguiendo el mismo patrón
UPDATE acl_aclaracion
SET folio_csuac = '2510243036',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '>Solicitud no procede la transacción fue devuelta por el comercio el día 16/10/2024 por la cantidad de $ 461 (25-OCT-2024 / USR5)'
WHERE pky_aclaracion = 2475441;

UPDATE acl_aclaracion
SET folio_csuac = '2510242971',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '>Solicitud no procede la transacción fue devuelta por el comercio el día 14/10/2024 por la cantidad de $ 471.16 (25-OCT-2024 / USR1)'
WHERE pky_aclaracion = 2475440;


UPDATE acl_aclaracion
SET folio_csuac = '2510243036',
    fky_estatus_aclaracion = 3,
    procede = 0,
    fky_tipo_codigo_resolucion = 5,
    predictamen = '>Solicitud no procede la transacción fue devuelta por el comercio el día 16/10/2024 por la cantidad de $ 461 (25-OCT-2024 / USR5)'
WHERE pky_aclaracion = 2475434;