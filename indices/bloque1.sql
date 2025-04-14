CREATE INDEX idx_movimiento_filters 
    ON intercad:movimiento(secuenciaextendida, numtarjeta);

CREATE INDEX idx_acl_aclaracion_pky 
    ON bdiaclaracion:acl_aclaracion(pky_aclaracion);

CREATE INDEX idx_acl_movimiento_fky 
    ON bdiaclaracion:acl_movimiento(fky_aclaracion);

CREATE INDEX idx_acl_aclaracion_evento_producto 
    ON bdiaclaracion:acl_aclaracion(fky_tipo_evento, fky_producto);


    -- pendiente:

    