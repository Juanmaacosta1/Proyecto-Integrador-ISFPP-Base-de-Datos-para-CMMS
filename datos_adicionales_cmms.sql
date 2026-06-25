-- ============================================================================
-- SCRIPT DE DATOS ADICIONALES - CMMS AMARILLO
-- Inserts complementarios para asegurar funcionalidad completa
-- ============================================================================

SET search_path = cmms_amarillo, public;

-- ============================================================================
-- SECCIÓN 1: DATOS PARA RELACIONES N:M (ot_tecnico)
-- ============================================================================

-- ============================================================================
-- Asignar técnicos a las órdenes de trabajo existentes
-- ============================================================================

-- Inserción segura (solo si no existen ya)
INSERT INTO ot_tecnico (id_orden_trabajo, id_usuario)
SELECT ot.id, u.id
FROM orden_trabajo ot
CROSS JOIN usuario u
WHERE ot.id IN (1, 2, 3, 4, 5)
  AND u.id IN (3, 4, 10)  -- Técnicos de campo
  AND NOT EXISTS (
        SELECT 1 
        FROM ot_tecnico 
        WHERE id_orden_trabajo = ot.id 
          AND id_usuario = u.id
  );

-- Inserción manual adicional
INSERT INTO ot_tecnico (id_orden_trabajo, id_usuario)
VALUES 
    (6, 12),
    (7, 10),
    (8, 12),
    (9, 9),
    (10, 3)
ON CONFLICT DO NOTHING;


-- ============================================================================
-- SECCIÓN 2: ÓRDENES DE TRABAJO CON DIFERENTES ESTADOS
-- ============================================================================
-- Agregar más OTs en estado "Abierta" y "En progreso" para las vistas
-- OTs Abiertas (estado_id = 1)
INSERT INTO orden_trabajo (
    titulo, descripcion, f_prog_inicio, f_prog_fin,
    f_real_inicio, f_real_fin, horas_est, horas_reales,
    id_creado_por, id_activo, id_prioridad, id_estado
) VALUES
('Instalación ONT Cliente 001', 'Instalación de equipo terminal en domicilio', 
 DATE '2025-11-15', DATE '2025-11-15',
 TIMESTAMP '2025-11-15 08:00:00', TIMESTAMP '2025-11-15 10:00:00',
 INTERVAL '2 hours', INTERVAL '2 hours', 3, 4, 2, 1),

('Revisión Antena Enlace Salta', 'Chequeo de alineación y niveles', 
 DATE '2025-11-16', DATE '2025-11-16',
 TIMESTAMP '2025-11-16 09:00:00', TIMESTAMP '2025-11-16 11:00:00',
 INTERVAL '2 hours', INTERVAL '2 hours', 6, 11, 2, 1),

('Cambio de fuente UPS', 'Reemplazo de fuente redundante', 
 DATE '2025-11-17', DATE '2025-11-17',
 TIMESTAMP '2025-11-17 10:00:00', TIMESTAMP '2025-11-17 12:00:00',
 INTERVAL '2 hours', INTERVAL '2 hours', 7, 5, 3, 1);

-- OTs En Progreso (estado_id = 2)
INSERT INTO orden_trabajo (
    titulo, descripcion, f_prog_inicio, f_prog_fin,
    f_real_inicio, f_real_fin, horas_est, horas_reales,
    id_creado_por, id_activo, id_prioridad, id_estado
) VALUES
('Migración Clientes OLT Nueva', 'Migración de ONTs a nueva OLT', 
 DATE '2025-11-13', DATE '2025-11-14',
 TIMESTAMP '2025-11-13 08:00:00', TIMESTAMP '2025-11-14 18:00:00',
 INTERVAL '10 hours', INTERVAL '10 hours', 5, 10, 3, 2),

('Configuración VLAN Switches', 'Implementación de VLANs por servicio', 
 DATE '2025-11-12', DATE '2025-11-13',
 TIMESTAMP '2025-11-12 14:00:00', TIMESTAMP '2025-11-13 14:00:00',
 INTERVAL '8 hours', INTERVAL '8 hours', 2, 3, 2, 2),

('Reparación Cable Fibra Mendoza', 'Corte de fibra por obras viales', 
 DATE '2025-11-12', DATE '2025-11-12',
 TIMESTAMP '2025-11-12 10:00:00', TIMESTAMP '2025-11-12 16:00:00',
 INTERVAL '6 hours', INTERVAL '6 hours', 10, 17, 3, 2);


-- ============================================================================
-- SECCIÓN 3: ACTIVOS EN DIFERENTES ESTADOS
-- ============================================================================
-- Agregar activos en mantenimiento para probar funciones

-- Poner algunos activos en mantenimiento
UPDATE activo SET id_estado_activo = 2 WHERE id IN (8, 10, 15);

-- Poner un activo fuera de servicio
UPDATE activo SET id_estado_activo = 3 WHERE id = 11;


-- ============================================================================
-- SECCIÓN 4: REGISTROS ADICIONALES
-- ============================================================================
-- Agregar más registros de eventos para el historial

INSERT INTO registro (fecha, id_activo, id_tipo_evento, id_usuario, id_mantenimiento_preventivo)
VALUES
(TIMESTAMP '2025-11-01 08:00:00', 2, 1, 2, 4),
(TIMESTAMP '2025-11-02 09:30:00', 8, 4, 12, 4),
(TIMESTAMP '2025-11-03 14:15:00', 10, 2, 10, 1),
(TIMESTAMP '2025-11-04 11:00:00', 15, 3, 6, 5),
(TIMESTAMP '2025-11-05 16:45:00', 3, 5, 11, 4),
(TIMESTAMP '2025-11-06 10:20:00', 17, 1, 13, 1),
(TIMESTAMP '2025-11-07 13:30:00', 5, 2, 7, 3),
(TIMESTAMP '2025-11-08 08:45:00', 12, 3, 6, 5),
(TIMESTAMP '2025-11-09 15:00:00', 19, 2, 12, 4),
(TIMESTAMP '2025-11-10 09:15:00', 14, 1, 10, 1);


-- ============================================================================
-- SECCIÓN 5: MANTENIMIENTOS PREVENTIVOS ADICIONALES
-- ============================================================================
-- Agregar más MPs para diferentes activos

INSERT INTO mantenimiento_preventivo (
    nombre, descripcion, duracion_estimada, 
    fecha_ultima_ejecucion, fecha_proxima_programada, 
    id_activo, id_frecuencia_mantenimiento
) VALUES
('Backup Router Córdoba', 'Respaldo de configuración mensual', 
 INTERVAL '1 hour', DATE '2025-10-15', DATE '2025-11-15', 8, 2),

('Limpieza Rack Rosario', 'Limpieza y orden trimestral', 
 INTERVAL '3 hours', DATE '2025-09-01', DATE '2025-12-01', 13, 3),

('Prueba Generador Mendoza', 'Test de funcionamiento semestral', 
 INTERVAL '2 hours', DATE '2025-06-01', DATE '2025-12-01', 6, 4),

('Actualización Switch Tucumán', 'Actualización de firmware anual', 
 INTERVAL '4 hours', DATE '2024-11-01', DATE '2025-11-01', 19, 5),

('Inspección OLT Mendoza', 'Revisión de potencias ópticas', 
 INTERVAL '2 hours', DATE '2025-10-01', DATE '2025-11-01', 17, 2);


-- ============================================================================
-- SECCIÓN 6: DOCUMENTACIÓN ADICIONAL
-- ============================================================================
-- Agregar más documentación para OTs y registros

INSERT INTO documentacion_ot (tipo, ruta_archivo, comentario, id_orden_trabajo, id_usuario)
VALUES
('pdf', '/docs/ot/6/diagnostico_switch.pdf', 'Reporte de diagnóstico completo', 6, 11),
('imagen', '/docs/ot/7/olt_cordoba_puertos.jpg', 'Estado de puertos PON', 7, 10),
('comentario', NULL, 'Ventiladores reemplazados sin problemas', 8, 12),
('pdf', '/docs/ot/11/switch_mendoza_logs.pdf', 'Logs de flaps detectados', 11, 12),
('imagen', '/docs/ot/15/router_tucuman_cpu.png', 'Gráfico de uso de CPU', 15, 11),
('comentario', NULL, 'Trabajo completado en tiempo estimado', 16, 13),
('pdf', '/docs/ot/17/olt_tucuman_modulos.pdf', 'Informe de módulos ópticos', 17, 10),
('comentario', NULL, 'Optimización exitosa, latencia reducida', 18, 2);

INSERT INTO documentacion_registro (tipo, ruta_archivo, comentario, id_registro, id_usuario)
VALUES
('comentario', NULL, 'Incidente resuelto satisfactoriamente', 6, 11),
('pdf', '/docs/reg/7/mp_olt_cordoba.pdf', 'Checklist de mantenimiento', 7, 10),
('imagen', '/docs/reg/8/router_cordoba_ventiladores.jpg', 'Ventiladores nuevos instalados', 8, 12),
('comentario', NULL, 'Inspección sin novedades', 9, 9),
('pdf', '/docs/reg/10/olt_rosario_potencias.pdf', 'Mediciones de potencia', 10, 3);


-- ============================================================================
-- SECCIÓN 7: ÓRDENES CON DESVIACIÓN DE HORAS
-- ============================================================================
-- Crear OTs cerradas con diferentes desviaciones para demostrar la vista

INSERT INTO orden_trabajo (
    titulo, descripcion, f_prog_inicio, f_prog_fin,
    f_real_inicio, f_real_fin, horas_est, horas_reales,
    id_creado_por, id_activo, id_prioridad, id_estado
) VALUES
-- OT con desviación positiva (tomó más tiempo)
('Migración Clientes OLT Cerrada', 'Migración completada con retrasos', 
 DATE '2025-10-25', DATE '2025-10-25',
 TIMESTAMP '2025-10-25 08:00:00', TIMESTAMP '2025-10-25 16:00:00',
 INTERVAL '5 hours', INTERVAL '8 hours', 5, 4, 3, 3),

-- OT con desviación negativa (tomó menos tiempo)
('Cambio SFP Rápido', 'Reemplazo de SFP defectuoso', 
 DATE '2025-10-26', DATE '2025-10-26',
 TIMESTAMP '2025-10-26 10:00:00', TIMESTAMP '2025-10-26 11:00:00',
 INTERVAL '2 hours', INTERVAL '1 hour', 3, 3, 2, 3),

-- OT sin desviación (tiempo exacto)
('Limpieza Programada', 'Limpieza ejecutada según plan', 
 DATE '2025-10-27', DATE '2025-10-27',
 TIMESTAMP '2025-10-27 09:00:00', TIMESTAMP '2025-10-27 12:00:00',
 INTERVAL '3 hours', INTERVAL '3 hours', 9, 7, 1, 3),

-- OT con gran desviación positiva
('Reparación Corte Fibra Complejo', 'Corte múltiple, más complejo de lo esperado', 
 DATE '2025-10-28', DATE '2025-10-28',
 TIMESTAMP '2025-10-28 08:00:00', TIMESTAMP '2025-10-28 20:00:00',
 INTERVAL '4 hours', INTERVAL '12 hours', 10, 17, 3, 3);


-- ============================================================================
-- SECCIÓN 8: DATOS PARA AUDITORÍA
-- ============================================================================
-- Las tablas de auditoría e historial se llenarán automáticamente por triggers
-- Pero creamos algunos cambios para que se registren


-- Cambiar estados de algunas OTs para generar registros de auditoría
UPDATE orden_trabajo SET id_estado = 2 WHERE id = 1;
UPDATE orden_trabajo SET id_estado = 3 WHERE id = 1;

UPDATE orden_trabajo SET id_estado = 2 WHERE id = 2;
UPDATE orden_trabajo SET id_estado = 3 WHERE id = 2;

-- Actualizar algunos usuarios para generar historial
UPDATE usuario SET telefono = 1141111111 WHERE id = 2;
UPDATE usuario SET especialidad = 'NOC Senior' WHERE id = 2;

UPDATE usuario SET turno_laboral = 'Nocturno' WHERE id = 3;


-- ============================================================================
-- SECCIÓN 9: ACTIVOS COMPRADOS RECIENTEMENTE
-- ============================================================================
-- Para la vista vw_compras_recientes_act

INSERT INTO activo (
    nombre, nro_serie, fabricante, modelo, fecha_compra,
    id_tipo_activo, id_ubicacion, id_estado_activo, id_activo_padre
) VALUES
('Switch Nuevo La Plata', 30001, 'Cisco', 'C9300-24U', DATE '2025-10-15', 
 2, 8, 1, 1),

('Router Nuevo Salta', 30002, 'Juniper', 'MX204', DATE '2025-09-20', 
 1, 11, 1, 1),

('OLT Neuquén-1', 30003, 'Huawei', 'MA5800', DATE '2025-08-10', 
 3, 12, 1, 1),

('UPS Nueva Mar del Plata', 30004, 'APC', 'Smart-UPS 3000', DATE '2025-07-05', 
 5, 9, 1, 1),

('Switch Core Backup BA', 30005, 'Cisco', 'N9K-C93180YC-FX', DATE '2025-06-15', 
 2, 4, 1, 3);


-- ============================================================================
-- SECCIÓN 10: VERIFICACIÓN DE DATOS
-- ============================================================================
-- Consultas para verificar que todo se insertó correctamente


SELECT 'Relaciones OT-Técnico' AS tabla, COUNT(*) AS registros FROM ot_tecnico
UNION ALL
SELECT 'Órdenes de Trabajo' AS tabla, COUNT(*) AS registros FROM orden_trabajo
UNION ALL
SELECT 'Registros' AS tabla, COUNT(*) AS registros FROM registro
UNION ALL
SELECT 'Mantenimientos Preventivos' AS tabla, COUNT(*) AS registros FROM mantenimiento_preventivo
UNION ALL
SELECT 'Documentación OT' AS tabla, COUNT(*) AS registros FROM documentacion_ot
UNION ALL
SELECT 'Documentación Registro' AS tabla, COUNT(*) AS registros FROM documentacion_registro
UNION ALL
SELECT 'Activos' AS tabla, COUNT(*) AS registros FROM activo
UNION ALL
SELECT 'Auditoría OT' AS tabla, COUNT(*) AS registros FROM auditoria_ot
UNION ALL
SELECT 'Historial Usuario' AS tabla, COUNT(*) AS registros FROM historial_usuario
UNION ALL
SELECT 'Historial OT' AS tabla, COUNT(*) AS registros FROM historial_orden_trabajo;

-- Verificar distribución por estados
SELECT 
    eo.nombre AS estado,
    COUNT(*) AS cantidad
FROM orden_trabajo ot
JOIN estado_ot eo ON ot.id_estado = eo.id
GROUP BY eo.nombre
ORDER BY cantidad DESC;

-- Verificar distribución de activos por estado
SELECT 
    ea.nombre AS estado,
    COUNT(*) AS cantidad
FROM activo a
JOIN estado_activo ea ON a.id_estado_activo = ea.id
GROUP BY ea.nombre
ORDER BY cantidad DESC;

-- Verificar órdenes por prioridad
SELECT 
    p.nombre AS prioridad,
    COUNT(*) AS cantidad
FROM orden_trabajo ot
JOIN prioridad p ON ot.id_prioridad = p.id
GROUP BY p.nombre
ORDER BY cantidad DESC;
