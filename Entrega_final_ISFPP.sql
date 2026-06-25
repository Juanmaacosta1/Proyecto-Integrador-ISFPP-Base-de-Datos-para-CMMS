CREATE SCHEMA IF NOT EXISTS cmms_amarillo;

set search_path = cmms_amarillo, public;

SHOW search_path;

create extension if not exists unaccent;
-- ============================================================================
-- CREACION DE TABLAS
-- ============================================================================

-- sección 1: tablas de catálogo y parámetros
create table rol (
    id int generated always as identity,
    nombre varchar(50) not null,
    descripcion text,
    constraint pk_rol_id primary key (id),
    constraint uk_rol_nombre unique (nombre)
);

create table prioridad (
    id int generated always as identity,
    nombre varchar(50) not null,
    constraint pk_prioridad_id primary key (id),
    constraint uk_prioridad_nombre unique(nombre)
);

create table if not exists estado_ot (
    id int generated always as identity,
    nombre varchar(50) not null,
    descripcion text,
    constraint pk_estado_ot_id primary key (id),
    constraint uk_estado_ot_nombre unique(nombre)
);

create table tipo_activo (
    id int generated always as identity,
    nombre varchar(100) not null,
    descripcion text,
    constraint pk_tipo_activo_id primary key (id),
    constraint uk_tipo_activo_nombre unique(nombre)
);

create table estado_activo (
    id int generated always as identity,
    nombre varchar(50) not null,
    constraint pk_estado_activo_id primary key (id),
    constraint uk_estado_activo_nombre unique (nombre)
);

create table nombre_ubicacion (
    id int generated always as identity,
    nombre varchar(100) not null,
    descripcion text,
    constraint pk_nombre_ubicacion_id primary key (id),
    constraint uk_nombre_ubicacion unique (nombre) 
);

create table tipo_evento (
    id int generated always as identity,
    nombre varchar(100) not null,
    descripcion text,
    constraint pk_tipo_evento_id primary key (id),
    constraint uk_tipo_evento_nombre unique (nombre)
);

create table frecuencia_mantenimiento (
    id int generated always as identity,
    nombre varchar(100) not null,
    frecuencia interval not null,
    constraint pk_frecuencia_mantenimiento_id primary key (id),
    constraint uk_frec_mant_nombre unique(nombre)
);

-- sección 2: tablas de entidades principales (dependen de las tablas de catálogo).
create table usuario (
    id int generated always as identity,
    nombre varchar(100) not null,
    correo varchar(150) not null,
    telefono int not null,
    id_rol int not null,
    turno_laboral varchar(50) not null,
    especialidad varchar(50) not null,
    
    constraint pk_usuario_id primary key (id),
    constraint uk_usuario_correo unique (correo),
    constraint fk_usuario_rol foreign key (id_rol) references rol(id)
);

create table ubicacion (
    id int generated always as identity,
    id_nombre_ubicacion int not null,
    id_ubicacion_padre int,
    
    constraint pk_ubicacion_id primary key (id),
    constraint fk_ubicacion_nombre foreign key (id_nombre_ubicacion) references nombre_ubicacion(id),
    constraint fk_ubicacion_padre foreign key (id_ubicacion_padre) references ubicacion(id)
);

create table activo (
    id int generated always as identity,
    nombre varchar(100) not null,
    nro_serie int not null,
    fabricante varchar(100),
    modelo varchar(50),
    fecha_compra date not null,
    id_tipo_activo int not null,
    id_ubicacion int not null,
    id_estado_activo int not null,
    id_activo_padre int,
    
    constraint pk_activo_id primary key (id),
    constraint uk_activo_nro_serie unique (nro_serie),
    constraint fk_activo_tipo_activo foreign key (id_tipo_activo) references tipo_activo(id),
    constraint fk_activo_ubicacion foreign key (id_ubicacion) references ubicacion(id),
    constraint fk_activo_estado_activo foreign key (id_estado_activo) references estado_activo(id),
    constraint fk_activo_padre foreign key (id_activo_padre) references activo(id)
);


-- sección 3: tablas transaccionales (representan las operaciones y eventos del sistema).

create table mantenimiento_preventivo (
    id int generated always as identity,
    nombre varchar(150) not null,
    descripcion text not null,
    duracion_estimada interval not null,
    fecha_ultima_ejecucion date not null,
    fecha_proxima_programada date not null,
    id_activo int not null,
    id_frecuencia_mantenimiento int not null,
    
    constraint pk_mantenimiento_preventivo_id primary key (id),
    constraint fk_mantprev_activo foreign key (id_activo) references activo(id),
    constraint fk_mantprev_frecuencia foreign key (id_frecuencia_mantenimiento) references frecuencia_mantenimiento(id)
);

create table orden_trabajo (
    id int generated always as identity,
    titulo varchar(100) not null,
    descripcion text not null,
    f_prog_inicio date not null,
    f_prog_fin date not null,
    f_real_inicio timestamp not null,
    f_real_fin timestamp not null,
    horas_est interval not null,
    horas_reales interval not null,
	id_creado_por int not null, 
    id_activo int not null, 
    id_prioridad int not null,
    id_estado int not null,

    constraint pk_orden_trabajo_id primary key (id),
    constraint fk_ordentrabajo_usuario foreign key (id_creado_por) references usuario(id),
    constraint fk_ordentrabajo_activo foreign key (id_activo) references activo(id),
    constraint fk_ordentrabajo_prioridad foreign key (id_prioridad) references prioridad(id),
    constraint fk_ordentrabajo_estado_ot foreign key (id_estado) references estado_ot(id)
);

create table registro (
    id int generated always as identity,
    fecha timestamp not null default current_timestamp,
    id_activo int not null,
    id_tipo_evento int not null,
    id_usuario int not null,
    id_mantenimiento_preventivo int not null,
    
    constraint pk_registro_id primary key (id),
    constraint fk_registro_activo foreign key (id_activo) references activo(id),
    constraint fk_registro_tipoevento foreign key (id_tipo_evento) references tipo_evento(id),
    constraint fk_registro_usuario foreign key (id_usuario) references usuario(id),
    constraint fk_registro_mantprev foreign key (id_mantenimiento_preventivo) references mantenimiento_preventivo(id)
);

create table auditoria_ot (
    id int generated always as identity,
	id_orden int not null,
    id_usuario_auditor int not null,

    fecha date not null,
    operacion varchar(50) not null,
    descripcion text not null,
    estado varchar(100) not null,
    f_prog_inicio date not null,
    f_prog_fin date not null,
    f_real_inicio date not null,
    f_real_fin date not null,
    horas_est interval not null,
    horas_reales interval not null,
    
    constraint pk_auditoria_ot_id primary key (id),
    constraint fk_auditoriaot_ordentrabajo foreign key (id_orden) references orden_trabajo(id) ON DELETE SET NULL,
    constraint fk_auditoriaot_usuario foreign key (id_usuario_auditor) references usuario(id)
);

-- sección 4: tablas asociativas y de documentación (Conectan entidades (n:m) y añaden información complementaria).

create table ot_tecnico (
    id_orden_trabajo int NOT NULL,
    id_usuario int NOT NULL,
    
    constraint pk_ot_tecnico_id primary key (id_orden_trabajo, id_usuario),
	constraint fk_ot_tecnico_orden_trabajo foreign key (id_orden_trabajo) references orden_trabajo(id),
	constraint fk_ot_tecnico_usuario foreign key (id_usuario) references usuario(id)
	
);

create table documentacion_ot (
    id int generated always as identity,
	tipo varchar (20),
    ruta_archivo varchar(255),
    comentario text,
    id_orden_trabajo int not null,
	id_usuario int not null,
    
    constraint pk_documentacion_ot primary key (id),
    constraint fk_docot_ordentrabajo foreign key (id_orden_trabajo) references orden_trabajo(id),
	constraint fk_docot_usuario foreign key (id_usuario) references usuario(id)
);

create table documentacion_registro (
    id int generated always as identity,
	tipo varchar (20),
    ruta_archivo varchar(255),
    comentario text,
    id_registro int not null,
	id_usuario int not null,

    constraint pk_documentacion_registro_id primary key (id),
    constraint fk_docreg_registro foreign key (id_registro) references registro(id),
	constraint fk_docregistro_usuario foreign key (id_usuario) references usuario(id)
);

-- sección 5 : tablas adicionales para nuevas auditorias (para entrega 3)
CREATE TABLE historial_orden_trabajo (
    titulo 		VARCHAR(100) NOT NULL,
    descripcion 	TEXT NOT NULL,
    f_prog_inicio 	DATE NOT NULL,
    f_prog_fin 		DATE NOT NULL,
    f_real_inicio 	TIMESTAMP NOT NULL,
    f_real_fin 		TIMESTAMP NOT NULL,
    horas_est 		INTERVAL NOT NULL,
    horas_reales 	INTERVAL NOT NULL,
    id_creado_por 	INT NOT NULL, 
    id_activo 		INT NOT NULL, 
    id_prioridad 	INT NOT NULL,
    id_estado 		INT NOT NULL,
    fecha_registrada	TIMESTAMP NOT NULL,
    operacion		TEXT NOT NULL
);

CREATE TABLE historial_usuario (
    nombre 		VARCHAR(100) NOT NULL,
    correo 		VARCHAR(150) NOT NULL,
    telefono 		INT NOT NULL,
    id_rol 		INT NOT NULL,
    turno_laboral 	VARCHAR(50) NOT NULL,
    especialidad 	VARCHAR(50) NOT NULL,
    fecha_registrada	TIMESTAMP NOT NULL,
    operacion		TEXT NOT NULL
);


-- ============================================================================
-- CARGA DE DATOS
-- ============================================================================

-- 1) Tablas de Catálogo

-- Roles
INSERT INTO rol (id, nombre, descripcion) OVERRIDING SYSTEM VALUE VALUES
(1, 'Administrador', 'Acceso completo al sistema'),
(2, 'Técnico de Campo', 'Instalación y mantenimiento en campo'),
(3, 'Operador NOC', 'Monitoreo y operación de red'),
(4, 'Supervisor', 'Supervisión y auditoría');

-- Esto solo es necesario si se ingresaron manualmente antes
-- y se uso OVERRIDING SYSTEM VALUE 
SELECT setval(pg_get_serial_sequence('rol', 'id'),
              COALESCE((SELECT MAX(id) FROM rol), 0) + 1,
              false);

-- Prioridades
INSERT INTO prioridad (nombre) VALUES
('Baja'),
('Media'),
('Alta');
			  
-- Estados de OT
INSERT INTO estado_ot (nombre, descripcion) VALUES
('Abierta', 'OT creada y pendiente de programación'),
('En progreso', 'OT en ejecución'),
('Cerrada', 'OT finalizada'),
('Cancelada', 'OT cancelada');

-- Tipos de Activo (enfocados a ISP)
INSERT INTO tipo_activo (nombre, descripcion) VALUES
('Router', 'Equipo de enrutamiento'),
('Switch', 'Equipo de conmutación'),
('OLT', 'Optical Line Terminal para FTTH'),
('Radio Enlace', 'Equipo de microondas / radioenlace'),
('UPS', 'Sistema de energía ininterrumpida'),
('Generador', 'Grupo electrógeno'),
('Servidor', 'Servidor NMS/AAA/DNS/etc.'),
('ODF', 'Optical Distribution Frame'),
('Antena', 'Antena de microondas'),
('ONT', 'Equipo terminal de cliente FTTH'),
('Infraestructura', 'Elemento lógico/agrupador de red');

-- Estados de Activo
INSERT INTO estado_activo (nombre) VALUES
('Operativo'),
('En Mantenimiento'),
('Fuera de Servicio');
			  
-- Nombres de Ubicación (sucursales y áreas)
INSERT INTO nombre_ubicacion (nombre, descripcion) VALUES
('Argentina', 'Ámbito nacional'),
('Sede Central Buenos Aires', 'Oficinas centrales'),
('NOC Buenos Aires', 'Centro de operaciones de red'),
('Data Center Buenos Aires', 'CPD principal'),
('Sucursal Córdoba', 'Operaciones Córdoba'),
('Sucursal Rosario', 'Operaciones Rosario'),
('Sucursal Mendoza', 'Operaciones Mendoza'),
('Sucursal La Plata', 'Operaciones La Plata'),
('Sucursal Mar del Plata', 'Operaciones MdP'),
('Sucursal Tucumán', 'Operaciones Tucumán'),
('Sucursal Salta', 'Operaciones Salta'),
('Sucursal Neuquén', 'Operaciones Neuquén'),
('Depósito Logístico BA', 'Almacén de repuestos y equipos');

-- Tipos de Evento (operación ISP)
INSERT INTO tipo_evento (nombre, descripcion) VALUES
('Incidente', 'Evento correctivo o caída'),
('Mantenimiento', 'Ejecución de mantenimiento'),
('Inspección', 'Inspección rutinaria'),
('Corte de Fibra', 'Interrupción por corte de FO'),
('Alerta NMS', 'Alarma de sistema de monitoreo');

-- Frecuencias de Mantenimiento
INSERT INTO frecuencia_mantenimiento (nombre, frecuencia) VALUES
('Semanal', INTERVAL '1 week'),
('Mensual', INTERVAL '1 month'),
('Trimestral', INTERVAL '3 months'),
('Semestral', INTERVAL '6 months'),
('Anual', INTERVAL '1 year');

-- 2) Entidades Principales

-- Usuarios (15)
INSERT INTO usuario (nombre, correo, telefono, id_rol, turno_laboral, especialidad) VALUES
('Nerea Toledo', 'nerea.toledo@isp.com.ar', 1141234567, 1, 'Diurno', 'Administración'),
('Juan Pérez', 'juan.perez@isp.com.ar', 1142345678, 3, 'Diurno', 'NOC'),
('María González', 'maria.gonzalez@isp.com.ar', 1143456789, 2, 'Diurno', 'Fibra Óptica'),
('Carlos López', 'carlos.lopez@isp.com.ar', 1144567890, 2, 'Nocturno', 'Redes'),
('Lucía Fernández', 'lucia.fernandez@isp.com.ar', 1145678901, 4, 'Diurno', 'Supervisión'),
('Martín Rodríguez', 'martin.rodriguez@isp.com.ar', 1146789012, 2, 'Diurno', 'Wireless'),
('Florencia Álvarez', 'florencia.alvarez@isp.com.ar', 1147890123, 2, 'Nocturno', 'Energía'),
('Diego Romero', 'diego.romero@isp.com.ar', 1148901234, 3, 'Nocturno', 'NOC'),
('Sofía Morales', 'sofia.morales@isp.com.ar', 1159012345, 2, 'Diurno', 'Redes'),
('Pablo Sosa', 'pablo.sosa@isp.com.ar', 1160123456, 2, 'Diurno', 'Fibra Óptica'),
('Agustina Castro', 'agustina.castro@isp.com.ar', 1161234567, 3, 'Nocturno', 'NOC'),
('Federico Ruiz', 'federico.ruiz@isp.com.ar', 1162345678, 2, 'Diurno', 'Redes'),
('Valentina Díaz', 'valentina.diaz@isp.com.ar', 1163456789, 2, 'Nocturno', 'Wireless'),
('Joaquín Herrera', 'joaquin.herrera@isp.com.ar', 1164567890, 2, 'Diurno', 'Energía'),
('Paula Benítez', 'paula.benitez@isp.com.ar', 1165678901, 4, 'Diurno', 'Supervisión');

-- Ubicaciones (13)
-- Nota: por la FK NOT NULL y auto-relación, la raíz se autoreferencia (válido en PostgreSQL).
INSERT INTO ubicacion (id_nombre_ubicacion, id_ubicacion_padre) VALUES
(1, 1),   -- Argentina (raíz)
(2, 1),   -- Sede Central BA -> Argentina
(3, 2),   -- NOC BA -> Sede Central
(4, 2),   -- Data Center BA -> Sede Central
(5, 1),   -- Sucursal Córdoba -> Argentina
(6, 1),   -- Sucursal Rosario -> Argentina
(7, 1),   -- Sucursal Mendoza -> Argentina
(8, 1),   -- Sucursal La Plata -> Argentina
(9, 1),   -- Sucursal Mar del Plata -> Argentina
(10, 1), -- Sucursal Tucumán -> Argentina
(11, 1), -- Sucursal Salta -> Argentina
(12, 1), -- Sucursal Neuquén -> Argentina
(13, 2); -- Depósito Logístico BA -> Sede Central

-- Activos (20) — uno raíz lógico y el resto jerárquicos
INSERT INTO activo (nombre, nro_serie, fabricante, modelo, fecha_compra, id_tipo_activo, id_ubicacion, id_estado_activo, id_activo_padre)
VALUES
('Backbone Nacional', 20001, 'Logical', 'INF-ARG', DATE '2019-01-01', 11, 3, 1, 1),
('Router Core BA', 20002, 'Cisco', 'ASR-9001', DATE '2020-05-10', 1, 4, 1, 1),
('Switch Core BA', 20003, 'Cisco', 'N9K-C93180', DATE '2020-06-15', 2, 4, 1, 2),
('OLT BA-1', 20004, 'Huawei', 'MA5800', DATE '2021-02-20', 3, 4, 1, 3),
('UPS Data Center BA', 20005, 'APC', 'Symmetra PX', DATE '2018-11-11', 5, 4, 1, 1),
('Generador BA', 20006, 'Caterpillar', 'C9', DATE '2018-12-05', 6, 2, 1, 1),
('ODF Principal BA', 20007, 'Panduit', 'ODF-72', DATE '2021-03-30', 8, 4, 1, 1),
('Router Sucursal Córdoba', 20008, 'Juniper', 'MX204', DATE '2020-09-01', 1, 5, 1, 1),
('Switch Acceso Córdoba', 20009, 'Cisco', 'C9500', DATE '2021-07-07', 2, 5, 1, 8),
('OLT Córdoba-1', 20010, 'ZTE', 'C320', DATE '2022-01-15', 3, 5, 1, 9),
('Antena Enlace Córdoba', 20011, 'UBNT', 'AirFiber 5XHD', DATE '2019-10-10', 9, 5, 1, 8),
('Radio Enlace BA-CBA', 20012, 'Cambium', 'PTP 820', DATE '2019-10-10', 4, 3, 1, 1),
('Router Sucursal Rosario', 20013, 'Cisco', 'ASR-920', DATE '2020-09-15', 1, 6, 1, 1),
('OLT Rosario-1', 20014, 'Huawei', 'MA5608T', DATE '2021-05-05', 3, 6, 1, 13),
('Router Sucursal Mendoza', 20015, 'Juniper', 'MX104', DATE '2020-11-20', 1, 7, 1, 1),
('Switch Acceso Mendoza', 20016, 'Cisco', 'C9300', DATE '2021-02-10', 2, 7, 1, 15),
('OLT Mendoza-1', 20017, 'ZTE', 'C300', DATE '2022-03-03', 3, 7, 1, 16),
('Router Sucursal Tucumán', 20018, 'Cisco', 'ASR-920', DATE '2020-10-10', 1, 10, 1, 1),
('Switch Acceso Tucumán', 20019, 'Cisco', 'C9300', DATE '2021-04-12', 2, 10, 1, 18),
('OLT Tucumán-1', 20020, 'Huawei', 'MA5608T', DATE '2022-06-06', 3, 10, 1, 19);

-- 3) Transaccionales

-- Mantenimientos Preventivos (5)
INSERT INTO mantenimiento_preventivo ( nombre, descripcion, duracion_estimada, fecha_ultima_ejecucion, fecha_proxima_programada, id_activo, id_frecuencia_mantenimiento) 
VALUES
('Backup configuración OLT BA-1', 'Respaldo de running-config y verificación de versión', INTERVAL '1 hour', DATE '2025-09-15', DATE '2025-10-15', 4, 2),
('Limpieza y orden ODF BA', 'Limpieza, etiquetado y orden de latiguillos', INTERVAL '2 hours', DATE '2025-07-01', DATE '2025-10-01', 7, 3),
('Chequeo UPS DC BA', 'Prueba de baterías y transferencia', INTERVAL '2 hours', DATE '2025-08-20', DATE '2025-10-20', 5, 2),
( 'Actualización Router Core BA', 'Revisión de parches y mantenimiento de software', INTERVAL '3 hours', DATE '2025-06-10', DATE '2025-09-10', 2, 3),
('Inspección Enlace BA-CBA', 'Revisión alineación y RSSI del radioenlace', INTERVAL '1 hour 30 minutes', DATE '2025-09-05', DATE '2025-10-05', 12, 2);

-- Órdenes de Trabajo (30)
INSERT INTO orden_trabajo (titulo, descripcion, f_prog_inicio, f_prog_fin, f_real_inicio, f_real_fin,
  horas_est, horas_reales, id_creado_por, id_activo, id_prioridad, id_estado
) VALUES
('Backup configuración OLT BA-1', 'Ejecución de respaldo mensual', DATE '2025-10-01', DATE '2025-10-01', TIMESTAMP '2025-10-01 09:00:00', TIMESTAMP '2025-10-01 10:00:00', INTERVAL '1 hour', INTERVAL '1 hour', 8, 4, 2, 3),
('Limpieza ODF BA', 'Limpieza de paneles y orden de patch cords', DATE '2025-10-02', DATE '2025-10-02', TIMESTAMP '2025-10-02 08:00:00', TIMESTAMP '2025-10-02 10:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 3, 7, 1, 3),
('Chequeo UPS Data Center', 'Prueba de autonomía y transferencia', DATE '2025-10-03', DATE '2025-10-03', TIMESTAMP '2025-10-03 11:00:00', TIMESTAMP '2025-10-03 13:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 7, 5, 2, 3),
('Actualización Router Core', 'Aplicación de parches recomendados', DATE '2025-10-04', DATE '2025-10-04', TIMESTAMP '2025-10-04 22:00:00', TIMESTAMP '2025-10-05 01:00:00', INTERVAL '3 hours', INTERVAL '3 hours', 2, 2, 2, 3),
('Inspección Radio BA-CBA', 'Verificación de niveles y alineación', DATE '2025-10-05', DATE '2025-10-05', TIMESTAMP '2025-10-05 09:00:00', TIMESTAMP '2025-10-05 10:30:00', INTERVAL '1 hour 30 minutes', INTERVAL '1 hour 30 minutes', 6, 12, 2, 3),
('Revisión Switch Core BA', 'Diagnóstico por alertas NMS', DATE '2025-10-06', DATE '2025-10-06', TIMESTAMP '2025-10-06 10:00:00', TIMESTAMP '2025-10-06 12:30:00', INTERVAL '2 hours', INTERVAL '2 hours 30 minutes', 11, 3, 3, 3),
('Mantenimiento OLT Córdoba-1', 'Revisión de puertos PON', DATE '2025-10-07', DATE '2025-10-07', TIMESTAMP '2025-10-07 08:00:00', TIMESTAMP '2025-10-07 10:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 10, 10, 2, 3),
('Cambio de ventiladores Router Córdoba', 'Reemplazo preventivo', DATE '2025-10-08', DATE '2025-10-08', TIMESTAMP '2025-10-08 09:00:00', TIMESTAMP '2025-10-08 11:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 12, 8, 2, 3),
('Limpieza rack sucursal Rosario', 'Retiro de polvo y ordenado', DATE '2025-10-09', DATE '2025-10-09', TIMESTAMP '2025-10-09 14:00:00', TIMESTAMP '2025-10-09 16:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 9, 13, 1, 3),
('Revisión OLT Rosario-1', 'Chequeo de potencia óptica', DATE '2025-10-10', DATE '2025-10-10', TIMESTAMP '2025-10-10 08:30:00', TIMESTAMP '2025-10-10 10:30:00', INTERVAL '2 hours', INTERVAL '2 hours', 3, 14, 2, 3),
('Inspección Switch Acceso Mendoza', 'Inspección por flaps', DATE '2025-10-11', DATE '2025-10-11', TIMESTAMP '2025-10-11 13:00:00', TIMESTAMP '2025-10-11 16:00:00', INTERVAL '3 hours', INTERVAL '3 hours', 12, 16, 2, 3),
('Actualización Router Mendoza', 'Upgrade de software', DATE '2025-10-12', DATE '2025-10-12', TIMESTAMP '2025-10-12 22:00:00', TIMESTAMP '2025-10-13 00:30:00', INTERVAL '2 hours', INTERVAL '2 hours 30 minutes', 2, 15, 2, 3),
('Prueba de baterías UPS', 'Pruebas de carga', DATE '2025-10-13', DATE '2025-10-13', TIMESTAMP '2025-10-13 09:00:00', TIMESTAMP '2025-10-13 11:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 7, 5, 2, 3),
('Mantenimiento Generador BA', 'Cambio de aceite', DATE '2025-10-14', DATE '2025-10-14', TIMESTAMP '2025-10-14 08:00:00', TIMESTAMP '2025-10-14 12:00:00', INTERVAL '4 hours', INTERVAL '4 hours', 14, 6, 1, 3),
('Revisión Router Tucumán', 'Chequeo por alta CPU', DATE '2025-10-15', DATE '2025-10-15', TIMESTAMP '2025-10-15 10:00:00', TIMESTAMP '2025-10-15 12:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 11, 18, 3, 3),
('Inspección Switch Tucumán', 'Flaps en interfaz', DATE '2025-10-16', DATE '2025-10-16', TIMESTAMP '2025-10-16 09:00:00', TIMESTAMP '2025-10-16 11:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 13, 19, 2, 3),
('Revisión OLT Tucumán-1', 'Revisión de módulos ópticos', DATE '2025-10-17', DATE '2025-10-17', TIMESTAMP '2025-10-17 08:30:00', TIMESTAMP '2025-10-17 10:00:00', INTERVAL '1 hour 30 minutes', INTERVAL '1 hour 30 minutes', 10, 20, 2, 3),
('Optimización OSPF Router Core', 'Ajuste de timers', DATE '2025-10-18', DATE '2025-10-18', TIMESTAMP '2025-10-18 23:00:00', TIMESTAMP '2025-10-19 01:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 2, 2, 1, 3),
('Reemplazo SFP OLT BA-1', 'SFP con errores CRC', DATE '2025-10-19', DATE '2025-10-19', TIMESTAMP '2025-10-19 09:00:00', TIMESTAMP '2025-10-19 10:30:00', INTERVAL '1 hour 30 minutes', INTERVAL '1 hour 30 minutes', 3, 4, 2, 3),
('Orden y etiquetado ODF', 'Reetiquetado de paneles', DATE '2025-10-20', DATE '2025-10-20', TIMESTAMP '2025-10-20 08:00:00', TIMESTAMP '2025-10-20 12:00:00', INTERVAL '4 hours', INTERVAL '4 hours', 9, 7, 1, 3),
('Limpieza rack Córdoba', 'Limpieza preventiva', DATE '2025-10-21', DATE '2025-10-21', TIMESTAMP '2025-10-21 15:00:00', TIMESTAMP '2025-10-21 17:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 12, 9, 1, 3),
('Verificación antena Córdoba', 'Ajuste de tornillería', DATE '2025-10-22', DATE '2025-10-22', TIMESTAMP '2025-10-22 10:00:00', TIMESTAMP '2025-10-22 11:30:00', INTERVAL '1 hour 30 minutes', INTERVAL '1 hour 30 minutes', 6, 11, 2, 3),
('Diagnóstico Switch Core BA', 'Incremento de errores en puerto', DATE '2025-10-23', DATE '2025-10-23', TIMESTAMP '2025-10-23 09:00:00', TIMESTAMP '2025-10-23 12:00:00', INTERVAL '3 hours', INTERVAL '3 hours', 8, 3, 3, 3),
('Verificación enlaces Rosario', 'Inspección general', DATE '2025-10-24', DATE '2025-10-24', TIMESTAMP '2025-10-24 08:00:00', TIMESTAMP '2025-10-24 10:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 11, 13, 1, 3),
('Revisión cableado Mendoza', 'Ajuste de bandejas y patch', DATE '2025-10-25', DATE '2025-10-25', TIMESTAMP '2025-10-25 09:00:00', TIMESTAMP '2025-10-25 12:00:00', INTERVAL '3 hours', INTERVAL '3 hours', 3, 16, 1, 3),
('Pruebas failover Router Córdoba', 'Validación de redundancia', DATE '2025-10-26', DATE '2025-10-26', TIMESTAMP '2025-10-26 22:00:00', TIMESTAMP '2025-10-27 00:30:00', INTERVAL '2 hours', INTERVAL '2 hours 30 minutes', 2, 8, 2, 3),
('Mantenimiento correctivo OLT BA-1', 'Porta PON sin luz', DATE '2025-10-27', DATE '2025-10-27', TIMESTAMP '2025-10-27 13:00:00', TIMESTAMP '2025-10-27 15:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 8, 4, 3, 3),
('Ajuste de políticas QoS', 'Revisión de colas en Core', DATE '2025-10-28', DATE '2025-10-28', TIMESTAMP '2025-10-28 21:00:00', TIMESTAMP '2025-10-28 23:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 2, 2, 2, 3),
('Revisión alarmas NMS', 'Cierre de alarmas pendientes', DATE '2025-10-29', DATE '2025-10-29', TIMESTAMP '2025-10-29 07:00:00', TIMESTAMP '2025-10-29 09:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 11, 2, 1, 3),
('Prueba de carga UPS', 'Prueba con carga simulada', DATE '2025-10-30', DATE '2025-10-30', TIMESTAMP '2025-10-30 14:00:00', TIMESTAMP '2025-10-30 16:00:00', INTERVAL '2 hours', INTERVAL '2 hours', 7, 5, 2, 3);

-- Registros (10)
INSERT INTO registro (fecha, id_activo, id_tipo_evento, id_usuario, id_mantenimiento_preventivo)
VALUES
(TIMESTAMP '2025-10-01 10:05:00', 4, 2, 3, 1),
(TIMESTAMP '2025-10-02 10:10:00', 7, 2, 3, 2),
(TIMESTAMP '2025-10-03 13:10:00', 5, 2, 7, 3),
(TIMESTAMP '2025-10-04 23:50:00', 2, 2, 2, 4),
(TIMESTAMP '2025-10-05 10:25:00', 12, 3, 6, 5),
(TIMESTAMP '2025-10-06 12:35:00', 3, 5, 11, 4),
(TIMESTAMP '2025-10-07 10:05:00', 10, 2, 10, 1),
(TIMESTAMP '2025-10-08 11:05:00', 8, 2, 12, 4),
(TIMESTAMP '2025-10-09 16:15:00', 13, 3, 9, 2),
(TIMESTAMP '2025-10-10 10:25:00', 14, 2, 3, 1);

-- 4) Documentación (Comentarios/Adjuntos)

-- Documentación de Órdenes de Trabajo
INSERT INTO documentacion_ot (tipo, ruta_archivo, comentario, id_orden_trabajo, id_usuario) VALUES
('pdf', '/docs/ot/1/backup_olt_ba1.pdf', 'Respaldo generado y verificado', 1, 8),
('imagen', '/docs/ot/2/odf_limpio.jpg', 'ODF ordenado y limpio', 2, 3),
('comentario', NULL, 'Autonomía dentro de parámetros', 3, 7),
('pdf', '/docs/ot/4/actualizacion_core.pdf', 'Checklist de actualización', 4, 2),
('imagen', '/docs/ot/5/rssi_ok.jpg', 'RSSI dentro de valores esperados', 5, 6),
('comentario', NULL, 'SFP reemplazado, sin errores', 19, 3),
('imagen', '/docs/ot/20/etiquetado.jpg', 'Reetiquetado completado', 20, 9),
('comentario', NULL, 'Mantenimiento correctivo completado', 27, 8);

-- Documentación de Registros
INSERT INTO documentacion_registro (tipo, ruta_archivo, comentario, id_registro, id_usuario) VALUES
('comentario', NULL, 'MP ejecutado sin novedades', 1, 3),
('imagen', '/docs/reg/2/odf.jpg', 'Paneles limpios', 2, 3),
('pdf', '/docs/reg/3/ups_prueba.pdf', 'Resultados de prueba', 3, 7),
('comentario', NULL, 'Ventana de mantenimiento nocturna', 4, 2),
('imagen', '/docs/reg/5/enlace_ok.jpg', 'Alineación dentro de tolerancia', 5, 6);


-- ============================================================================
-- FUNCIONES
-- ============================================================================

-- normalización y validación de entrada de usuario
create or replace function fn_norm(p_text text)
returns text
language sql
immutable
as $$
  select lower(regexp_replace(btrim(coalesce(unaccent(p_text), '')), '\s+', ' ', 'g'));
$$;


-- normalización y validación de emails
create or replace function fn_norm_email(p_email text)
returns text
language plpgsql
as $$
declare
    v_norm text;
begin
    if p_email is null then
        return null;
    end if;

    v_norm := lower(unaccent(btrim(p_email)));
    v_norm := regexp_replace(v_norm, '\s+', '', 'g');

    if v_norm ~ '^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$' then
        return v_norm;
    else
        return null;
    end if;
end;
$$;


-- validar existencia de distintas entidades por id
create or replace function fn_validacion(p_id int, p_entidad text)
returns boolean
language plpgsql
as $$
declare
    v_ent text := lower(coalesce(p_entidad, ''));
    v_exists boolean := false;
begin
    case v_ent
        when 'usuario' then
            v_exists := exists (select 1 from usuario where id = p_id);
        when 'activo' then
            v_exists := exists (select 1 from activo where id = p_id);
        when 'orden_trabajo' then
            v_exists := exists (select 1 from orden_trabajo where id = p_id);
        when 'mantenimiento_preventivo' then
            v_exists := exists (select 1 from mantenimiento_preventivo where id = p_id);
        when 'ubicacion' then
            v_exists := exists (select 1 from ubicacion where id = p_id);
        when 'nombre_ubicacion' then
            v_exists := exists (select 1 from nombre_ubicacion where id = p_id);
        when 'rol' then
            v_exists := exists (select 1 from rol where id = p_id);
        when 'prioridad' then
            v_exists := exists (select 1 from prioridad where id = p_id);
        when 'estado_ot' then
            v_exists := exists (select 1 from estado_ot where id = p_id);
        when 'estado_activo' then
            v_exists := exists (select 1 from estado_activo where id = p_id);
        when 'tipo_activo' then
            v_exists := exists (select 1 from tipo_activo where id = p_id);
        when 'tipo_evento' then
            v_exists := exists (select 1 from tipo_evento where id = p_id);
        else
            v_exists := false;
    end case;

    return v_exists;
end;
$$;


-- ============================================================================
-- FUNCIONES DE CÁLCULO Y CONSULTA
-- ============================================================================

-- calcular próxima fecha de mantenimiento preventivo
create or replace function fn_calcular_proxima_fecha_mp(fecha_ultima date, id_frecuencia int)
returns date
language plpgsql
as $$
declare
    v_intervalo interval;
begin
    select frecuencia 
    into v_intervalo
    from frecuencia_mantenimiento
    where id = id_frecuencia;

    if v_intervalo is null then
        raise exception 'La frecuencia con ID % no existe o no tiene intervalo definido.', id_frecuencia;
    end if;

    return fecha_ultima + v_intervalo;
end;
$$;


-- contar órdenes de trabajo activas de un técnico
create or replace function fn_contar_ot_activas_tecnico(id_tecnico int)
returns int
language plpgsql
as $$
declare
    v_conteo int;
begin
    select count(ot.id) into v_conteo
    from orden_trabajo as ot
    join ot_tecnico as ott on ot.id = ott.id_orden_trabajo
    join estado_ot as eot on ot.id_estado = eot.id
    where ott.id_usuario = id_tecnico
      and eot.nombre not in ('Cerrada', 'Cancelada');

    return coalesce(v_conteo, 0);
end;
$$;


-- verificar si un activo tiene órdenes de trabajo abiertas
create or replace function fn_activo_tiene_ot_abierta(id_activo_evaluar int)
returns boolean
language plpgsql
as $$
declare
    v_existe boolean;
begin
    select exists (
        select 1
        from orden_trabajo as ot
        join estado_ot as eot on ot.id_estado = eot.id
        where ot.id_activo = id_activo_evaluar
          and eot.nombre not in ('Cerrada', 'Cancelada')
    ) into v_existe;
    
    return coalesce(v_existe, false);
end;
$$;


-- calcular desviación de horas (estimadas vs. reales)
create or replace function fn_calcular_desviacion_horas_ot(id_ot int)
returns interval
language plpgsql
as $$
declare
    v_desviacion interval;
begin
    select horas_reales - horas_est into v_desviacion
    from orden_trabajo
    where id = id_ot;

    return v_desviacion;
end;
$$;


-- valida fechas
create or replace function fn_validar_fechas(
    f_fecha date,
    f_fecha_referencia date)
returns varchar(50)
language plpgsql
as $$
declare
    estado_fecha varchar(50);
begin
    if f_fecha > f_fecha_referencia then
        estado_fecha := 'FUTURA';
    elsif f_fecha < f_fecha_referencia then
        estado_fecha := 'PASADA';
    else
        estado_fecha := 'EXACTA';
    end if;
    return estado_fecha;
end;
$$;


-- ============================================================================
-- FUNCIONES COMPLEMENTARIAS DE TRIGGERS
-- ============================================================================

-- función para el trigger que audita las órdenes de trabajo
create or replace function fn_trg_auditar_ot()
returns trigger as $$
declare
    v_estado_anterior  varchar(50);
    v_estado_actual    varchar(50);
    v_operacion        varchar(50);
    v_usuario_auditor  int;
    v_descripcion_log  text;
begin
    -- RAISE NOTICE 'Trigger ejecutado: %', TG_OP;

    if (TG_OP = 'INSERT') then
        v_operacion := 'alta';
        v_usuario_auditor := coalesce(NEW.id_creado_por, 1);
        select nombre into v_estado_actual from estado_ot where id = NEW.id_estado;
        v_descripcion_log := 'OT creada: ' || NEW.titulo;

        insert into auditoria_ot (
            id_orden, id_usuario_auditor, fecha, operacion, descripcion, 
            estado, f_prog_inicio, f_prog_fin, f_real_inicio, f_real_fin, 
            horas_est, horas_reales
        ) values (
            NEW.id, v_usuario_auditor, CURRENT_DATE, v_operacion, v_descripcion_log,
            v_estado_actual, NEW.f_prog_inicio, NEW.f_prog_fin,
            NEW.f_real_inicio::date, NEW.f_real_fin::date,
            NEW.horas_est, NEW.horas_reales
        );

        return new;

    elsif (TG_OP = 'UPDATE') then
        v_operacion := 'modificación';
        v_usuario_auditor := COALESCE(NEW.id_creado_por, 1);

        select nombre into v_estado_anterior from estado_ot where id = OLD.id_estado;
        select nombre into v_estado_actual from estado_ot where id = NEW.id_estado;

        if OLD.id_estado is distinct from NEW.id_estado then
            v_descripcion_log := 'Cambio estado: ' || v_estado_anterior || ' → ' || v_estado_actual;
        else
            v_descripcion_log := 'Cambio en fechas/horas planificadas';
        end if;

        insert into auditoria_ot (
            id_orden, id_usuario_auditor, fecha, operacion, descripcion, 
            estado, f_prog_inicio, f_prog_fin, f_real_inicio, f_real_fin, 
            horas_est, horas_reales
        ) values (
            OLD.id, v_usuario_auditor, CURRENT_DATE, v_operacion, v_descripcion_log,
            v_estado_actual, NEW.f_prog_inicio, NEW.f_prog_fin,
            NEW.f_real_inicio::date, NEW.f_real_fin::date,
            NEW.horas_est, NEW.horas_reales
        );

        return new;
    end if;

    return null;

exception when others then
    raise notice 'Error en auditoría: %', SQLERRM;
    return null;
end;
$$ language plpgsql;


-- Funcion para bloquear el Delete de una orden de trabajo
create or replace function fn_trg_bloquear_delete_ot()
returns trigger as $$
begin
    raise exception 'No se permite eliminar órdenes de trabajo. Use un cambio de estado (por ejemplo: "Cancelada").';
    return null;
end;
$$ language plpgsql;


-- función para el trigger que fuerza el cambio de estado de un activo cuando su orden de trabajo se cierra
create or replace function fn_trg_forzar_activo_operativo_al_cerrar_ot()
returns trigger
language plpgsql
as $$
declare
    -- ids de los catálogos
    v_nombre_estado_cerrada constant text := 'Cerrada';
    v_nombre_estado_operativo constant text := 'Operativo';
    v_nombre_estado_mantenimiento constant text := 'En Mantenimiento';
    
    -- variables para los ids obtenidos de la tabla
    v_id_estado_cerrada int;
    v_id_estado_operativo int;
    v_id_estado_en_mant int;
    v_estado_actual_activo int;
begin
	-- estado de la ot
    select id into v_id_estado_cerrada
    from estado_ot
    where nombre = v_nombre_estado_cerrada;

    -- estados del activo
    select id into v_id_estado_operativo
    from estado_activo
    where nombre = v_nombre_estado_operativo;
    
    select id into v_id_estado_en_mant
    from estado_activo
    where nombre = v_nombre_estado_mantenimiento;

    if v_id_estado_cerrada is null or v_id_estado_operativo is null or v_id_estado_en_mant is null then
        raise exception 'Error de configuración: los nombres de estados requeridos no se encontraron en las tablas de catálogo.';
    end if;
    
	if new.id_estado = v_id_estado_cerrada and old.id_estado is distinct from v_id_estado_cerrada then    
        select id_estado_activo into v_estado_actual_activo
        from activo
        where id = new.id_activo;

        if v_estado_actual_activo = v_id_estado_en_mant then
            update activo
            set id_estado_activo = v_id_estado_operativo
            where id = new.id_activo;
            
            raise notice 'Activo ID % actualizado a "operativo" tras el cierre de OT %.', new.id_activo, new.id;
        end if; 
    end if;
    
    return new;
end;
$$;


-- función para el trigger de ubicacion
create or replace function fn_trg_set_ubicacion()
returns trigger as $$
begin
    -- chequea si la fila se insertó con un padre NULO
    if new.id_ubicacion_padre is null then
        -- actualiza la fila recién insertada para que apunte a sí misma
        update ubicacion
        set id_ubicacion_padre = new.id
        where id = new.id;
    end if;
    return new;
end;
$$ language plpgsql;


-- función del trigger para activo
create or replace function fn_trg_set_activo()
returns trigger as $$
begin
    -- chequea si la fila se insertó con un padre nulo
    if new.id_activo_padre is null then
        -- actualiza la fila recién insertada para que apunte a sí misma
        update cmms_amarillo.activo
        set id_activo_padre = new.id
        where id = new.id;
    end if;
    return new; 
end;
$$ language plpgsql;


-- función trigger para registrar un mantenimiento preventivo
create or replace function fn_trg_registrar_mp()
returns trigger
language plpgsql
as $$
declare
	v_id_tipo_evento int;
	v_nombre_evento varchar := 'Mantenimiento';
begin
	
	select id into v_id_tipo_evento
	from tipo_evento
	where fn_norm(nombre) = fn_norm(v_nombre_evento);
	
	call proc_registrar_mp(new.id_activo, v_tipo_evento, new.id_mant_prev);
	
	return null;
end;
$$;


-- función para el trigger del historial de usuario
create or replace function fn_trg_historial_usuario()
returns trigger
language plpgsql
as $$
begin
	--se encarga de isertar datos en una nueva tabla
	if tg_op='INSERT' then
		insert into historial_usuario values (new.nombre, new.correo, new.telefono, 
		new.id_rol, new.turno_laboral, new.especialidad, now(),'INSERT');

		return new;

		--se encarga de guardar los datos viejos 
	elsif tg_op='UPDATE' then
		insert into historial_usuario values (old.nombre, old.correo, old.telefono, 
		old.id_rol, old.turno_laboral, old.especialidad ,now(),'UPDATE');
	
		return new;

    --se encarga de guardar los datos eliminados
	elsif tg_op='DELETE' then
		insert into historial_usuario values (old.nombre, old.correo, old.telefono, 
		old.id_rol, old.turno_laboral, old.especialidad, now(),'DELETE');

	return old;
	end if;
end;
$$;


-- función para el trigger de historial de orden de trabajo
create or replace function fn_trg_historial_orden_trabajo()
returns trigger
language plpgsql
as $$
begin
	if tg_op='INSERT' then
		insert into historial_orden_trabajo values (new.titulo, new.descripcion, new.f_prog_inicio, 
		new.f_prog_fin, new.f_real_inicio,new.f_real_fin, new.horas_est,new.horas_reales,new.id_creado_por,new.id_activo,
		new.id_prioridad,new.id_estado,now(),'INSERT');
		return new;

	
	elsif tg_op='UPDATE' then
		insert into historial_orden_trabajo values (old.titulo, old.descripcion, old.f_prog_inicio, 
		old.f_prog_fin, old.f_real_inicio,old.f_real_fin, old.horas_est,old.horas_reales,old.id_creado_por,old.id_activo,
		old.id_prioridad,old.id_estado,now(),'UPDATE');
		return new;

   
	elsif tg_op='DELETE' then
		insert into historial_orden_trabajo values (old.titulo, old.descripcion, old.f_prog_inicio, 
		old.f_prog_fin, old.f_real_inicio,old.f_real_fin, old.horas_est,old.horas_reales,old.id_creado_por,old.id_activo,
		old.id_prioridad,old.id_estado,now(),'DELETE');
		return old;
	
	end if;
end;
$$;


-- ============================================================================
-- PROCEDIMIENTOS
-- ============================================================================

-- crea ubicaciones
create or replace procedure proc_crear_ubicacion(
    p_nombre        varchar,
    p_descripcion   text default null,
    p_nombre_padre  varchar default 'Argentina')
language plpgsql
as $$
declare
    v_nom_norm   text := fn_norm(p_nombre);
    v_padre_norm text := fn_norm(p_nombre_padre);
    v_id_nombre  int;
    v_id_padre   int;
    v_id_ubic    int;
begin
    if v_nom_norm is null or v_nom_norm = '' then
        raise notice 'Nombre vacío. Ingrese p_nombre.';
        return;
    end if;

    select id into v_id_nombre
    from nombre_ubicacion
    where fn_norm(nombre) = v_nom_norm
    limit 1;

    if v_id_nombre is null then
        insert into nombre_ubicacion(nombre, descripcion)
        values (p_nombre, p_descripcion)
        returning id into v_id_nombre;
        raise notice 'Se creó nombre_ubicacion "%" (id=%).', p_nombre, v_id_nombre;
    end if;

    select u.id into v_id_padre
    from ubicacion u
    join nombre_ubicacion nu on nu.id = u.id_nombre_ubicacion
    where fn_norm(nu.nombre) = v_padre_norm
    limit 1;

    if v_id_padre is null then
        raise notice 'No se encontró el padre "%". Cree la ubicación padre primero.', p_nombre_padre;
        return;
    end if;

    perform 1
    from ubicacion u
    join nombre_ubicacion nu on nu.id = u.id_nombre_ubicacion
    where u.id_ubicacion_padre = v_id_padre
      and fn_norm(nu.nombre) = v_nom_norm;

    if found then
        raise notice 'Ya existe la ubicación "%" bajo "%".', p_nombre, p_nombre_padre;
        return;
    end if;

    insert into ubicacion(id_nombre_ubicacion, id_ubicacion_padre)
    values (v_id_nombre, v_id_padre)
    returning id into v_id_ubic;

    raise notice 'Ubicación "%" creada con id % bajo "%".', p_nombre, v_id_ubic, p_nombre_padre;
    commit;
end;
$$;


-- agregar órdenes de trabajo
create or replace procedure proc_crear_ot(
    p_titulo        varchar,
    p_descripcion   text,
    p_f_prog_inicio date,
    p_f_prog_fin    date,
    p_creado_por    varchar,
    p_activo        varchar,
    p_prioridad     varchar default 'Media',
    p_estado        varchar default 'Abierta')
language plpgsql
as $$
declare
    v_tit_norm   text := fn_norm(p_titulo);
    v_desc       text := coalesce(p_descripcion,'');
    v_ini        date := p_f_prog_inicio;
    v_fin        date := p_f_prog_fin;
    v_user_norm  text;
    v_act_norm   text := fn_norm(p_activo);
    v_id_user    int;
    v_id_act     int;
    v_id_prio    int;
    v_id_est     int;
    v_num        bigint;
    v_count      int;
    v_email_norm text;
begin
    if v_tit_norm is null or v_tit_norm = '' then
        raise notice 'Título vacío. Ingrese un titulo.';
        return;
    end if;
    if v_desc = '' then
        raise notice 'Descripción vacía. Ingrese una descripcion.';
        return;
    end if;
    if v_ini is null or v_fin is null then
        raise notice 'Las fechas programadas son obligatorias.';
        return;
    end if;

    if fn_validar_fechas(v_ini, v_fin) = 'FUTURA' then
        raise notice 'La fecha de fin no puede ser anterior a la de inicio.';
        return;
    end if;

    if position('@' in p_creado_por) > 0 then
        v_email_norm := fn_norm_email(p_creado_por);
        if v_email_norm is null then
            raise notice 'Email inválido: "%".', p_creado_por;
            return;
        end if;
        select id into v_id_user
        from usuario
        where fn_norm_email(correo) = v_email_norm
        limit 1;
    else
        v_user_norm := fn_norm(p_creado_por);
        select id into v_id_user
        from usuario
        where fn_norm(nombre) = v_user_norm
        limit 1;
    end if;

    if v_id_user is null then
        raise notice 'Usuario "%" no encontrado.', p_creado_por;
        return;
    end if;

    if regexp_replace(coalesce(p_activo,''), '\s', '', 'g') ~ '^[0-9]+$' then
        v_num := regexp_replace(p_activo, '\s', '', 'g')::bigint;
        select id into v_id_act
        from activo
        where id = v_num
        limit 1;

        if v_id_act is null then
            select id into v_id_act
            from activo
            where nro_serie = v_num
            limit 1;
        end if;

        if v_id_act is null then
            raise notice 'Activo por id/nro_serie "%" no encontrado.', p_activo;
            return;
        end if;
    else
        select count(*) into v_count
        from activo
        where fn_norm(nombre) = v_act_norm;

        if v_count = 0 then
            raise notice 'Activo con nombre "%" no encontrado.', p_activo;
            return;
        elsif v_count > 1 then
            raise notice 'Nombre de activo "%" ambiguo (% resultados). Use id o nro_serie.', p_activo, v_count;
            return;
        else
            select id into v_id_act
            from activo
            where fn_norm(nombre) = v_act_norm
            limit 1;
        end if;
    end if;

    select id into v_id_prio
    from prioridad
    where fn_norm(nombre) = fn_norm(coalesce(p_prioridad,'Media'))
    limit 1;

    if v_id_prio is null then
        select id into v_id_prio from prioridad limit 1;
    end if;

    select id into v_id_est
    from estado_ot
    where fn_norm(nombre) = fn_norm(coalesce(p_estado,'Abierta'))
    limit 1;

    if v_id_est is null then
        select id into v_id_est from estado_ot limit 1;
    end if;

    perform 1 from orden_trabajo
    where fn_norm(titulo) = v_tit_norm
      and id_activo = v_id_act
      and not (f_prog_fin < v_ini or f_prog_inicio > v_fin);

    if found then
        raise notice 'Ya existe una OT con mismo título y activo en la ventana programada.';
        return;
    end if;

    insert into orden_trabajo(
        titulo, descripcion,
        f_prog_inicio, f_prog_fin,
        f_real_inicio, f_real_fin,
        horas_est, horas_reales,
        id_creado_por, id_activo, id_prioridad, id_estado)
    values (
        p_titulo, p_descripcion,
        v_ini, v_fin,
        v_ini::timestamp, v_fin::timestamp,
        interval '1 hour', interval '1 hour',
        v_id_user, v_id_act, v_id_prio, v_id_est
    );

    raise notice 'Orden de trabajo "%" creada para activo id=% por usuario id=%.', p_titulo, v_id_act, v_id_user;
    commit;
end;
$$;


-- cambiar estado de órdenes de trabajo
create or replace procedure proc_cambiar_estado_ot(p_id int, p_estado varchar)
language plpgsql
as $$
declare
    titulo_ot varchar(150);
	v_estado varchar := fn_norm(p_estado);
	v_id_estado int;
begin
    select titulo into titulo_ot
    from orden_trabajo
    where id = p_id
    limit 1;

    if titulo_ot is null then
        raise notice 'No se encontró la orden de trabajo con id %', p_id;
        return;
    end if;

	select id into v_id_estado
	from estado_ot
	where fn_norm(nombre) = v_estado;

	if v_id_estado is null then
		raise exception 'El ID de estado no fue encontrado.';
	end if;

	update orden_trabajo
	set id_estado = v_id_estado
	where id = p_id;

    raise notice 'Estado de orden de trabajo "%" cambiada a %.', titulo_ot, p_estado;
    commit;
end;
$$;


-- agregar usuario
create or replace procedure proc_ingresar_usuario(
    p_nombre varchar(100),
    p_correo varchar(150),
    p_telefono int,
    p_nombre_rol varchar(50),
    p_turno_laboral varchar(50),
    p_especialidad varchar(50))
language plpgsql
as $$
declare
    v_id_rol int;
    v_correo_norm text;
    v_rol_norm text := fn_norm(p_nombre_rol);
begin
    v_correo_norm := fn_norm_email(p_correo);

    if v_correo_norm is null then
        raise exception 'Dato erróneo. El correo "%" es inválido o contiene caracteres no permitidos.', p_correo;
    end if;

    select id into v_id_rol
    from rol
    where fn_norm(nombre) = v_rol_norm
    limit 1;

    if v_id_rol is null then
        raise exception 'Dato erróneo. El rol "%" no existe. Por favor, ingrese un nombre de rol válido.', p_nombre_rol;
    end if;

    if exists (select 1 from usuario where fn_norm_email(correo) = v_correo_norm) then
        raise exception 'Dato duplicado. Ya existe un usuario con el correo "%".', p_correo;
    end if;

    insert into usuario (nombre, correo, telefono, id_rol, turno_laboral, especialidad)
    values (p_nombre, p_correo, p_telefono, v_id_rol, p_turno_laboral, p_especialidad);

    raise notice 'Usuario % ingresado con éxito con el rol: %.', p_nombre, p_nombre_rol;
    commit;
end;
$$;


-- agregar activo
create or replace procedure proc_ingresar_activo(
    p_nombre varchar(100),
    p_nro_serie int,
    p_fabricante varchar(100),
    p_modelo varchar(50),
    p_fecha_compra date,
    p_tipo_activo_nombre varchar(100),
    p_estado_activo_nombre varchar(50),
    p_ubicacion_nombre varchar(100),
    p_id_activo_padre int)
language plpgsql
as $$
declare
    v_id_tipo_activo int;
    v_id_ubicacion int;
    v_id_estado_activo int;
    v_ubicacion_nombre_id int;
    v_id_activo_padre int;
    v_tipo_activo_norm text := fn_norm(p_tipo_activo_nombre);
    v_estado_activo_norm text := fn_norm(p_estado_activo_nombre);
    v_ubicacion_norm text := fn_norm(p_ubicacion_nombre);
begin
    if exists (select 1 from activo where nro_serie = p_nro_serie) then
        raise exception 'Dato duplicado. Ya existe un activo con el Número de Serie: %.', p_nro_serie;
    end if;

    select id into v_id_tipo_activo
    from tipo_activo
    where fn_norm(nombre) = v_tipo_activo_norm
    limit 1;

    if v_id_tipo_activo is null then
        raise exception 'Dato erróneo. Tipo de Activo "%" no existe.', p_tipo_activo_nombre;
    end if;

    select id into v_id_estado_activo
    from estado_activo
    where fn_norm(nombre) = v_estado_activo_norm
    limit 1;

    if v_id_estado_activo is null then
        raise exception 'Dato erróneo. Estado de Activo "%" no existe.', p_estado_activo_nombre;
    end if;

    select id into v_ubicacion_nombre_id
    from nombre_ubicacion
    where fn_norm(nombre) = v_ubicacion_norm
    limit 1;

    if v_ubicacion_nombre_id is null then
        raise exception 'Dato erróneo. Nombre de Ubicación "%" no existe.', p_ubicacion_nombre;
    end if;

    select id into v_id_ubicacion
    from ubicacion
    where id_nombre_ubicacion = v_ubicacion_nombre_id
    limit 1;

    if v_id_ubicacion is null then
        raise exception 'Error de configuración. La ubicación "%" existe, pero no está configurada correctamente en la tabla "ubicacion".', p_ubicacion_nombre;
    end if;

    if p_id_activo_padre is not null then
        select id into v_id_activo_padre
        from activo
        where id = p_id_activo_padre;

        if v_id_activo_padre is null then
            raise exception 'Dato erróneo. El activo padre con ID "%" no existe.', p_id_activo_padre;
        end if;
    end if; -- va de la mano con un trigger

    insert into activo (nombre, nro_serie, fabricante, modelo, fecha_compra, id_tipo_activo, id_ubicacion, id_estado_activo, id_activo_padre)
    values (p_nombre, p_nro_serie, p_fabricante, p_modelo, p_fecha_compra, v_id_tipo_activo, v_id_ubicacion, v_id_estado_activo, p_id_activo_padre);

    raise notice 'Activo % (Nro. Serie: %) ingresado con éxito.', p_nombre, p_nro_serie;
    commit;
end;
$$;


-- dar baja activo
create or replace procedure proc_dar_baja_activo(p_id_activo int)
language plpgsql
as $$
declare
    v_id_estado_baja int;
    v_nombre_estado_baja constant text := 'Fuera de Servicio';
begin
    if not fn_validacion(p_id_activo, 'activo') then
        raise exception 'Dato erróneo. No se encontró ningún activo con el ID: %.', p_id_activo;
    end if;

    select id into v_id_estado_baja
    from estado_activo
    where fn_norm(nombre) = fn_norm(v_nombre_estado_baja)
    limit 1;

    if v_id_estado_baja is null then
        raise exception 'Estado de baja "%" no existe en estado_activo.', v_nombre_estado_baja;
    end if;

    update activo
    set id_estado_activo = v_id_estado_baja
    where id = p_id_activo;

    if found then
        raise notice 'Activo (ID: %) ha sido dado de baja (Estado cambiado a: %). Su historial se mantiene.', p_id_activo, v_nombre_estado_baja;
    else
        raise notice 'No se actualizó el activo (ID: %).', p_id_activo;
    end if;
    commit;
end;
$$;


-- ingresar nuevo mantenimiento preventivo
create or replace procedure proc_ingresar_nuevo_mp(
    p_nombre varchar,
    p_descripcion text,
    p_duracion_estimada interval,
    p_f_ultima_ejecucion date,
    p_f_prox_programada date,
    p_id_activo int,
    p_id_frec_mantenimiento int)
language plpgsql
as $$
begin
    if p_id_activo is null or p_nombre is null or p_f_prox_programada is null or p_duracion_estimada is null or p_f_ultima_ejecucion is null then
        raise exception 'Los campos id, nombre y fecha proxima programada no pueden ser nulos.';
    end if;

    if fn_validar_fechas(p_f_ultima_ejecucion, p_f_prox_programada) = 'FUTURA' then
        raise exception 'La fecha de última ejecución no puede ser después de la próxima programada.';
    end if;

    if not fn_validacion(p_id_activo, 'activo') then
        raise exception 'El activo con ID % no existe.', p_id_activo;
    end if;

    insert into mantenimiento_preventivo(nombre, descripcion, duracion_estimada, fecha_ultima_ejecucion, fecha_proxima_programada, id_activo, id_frecuencia_mantenimiento)
    values (p_nombre, p_descripcion, p_duracion_estimada, p_f_ultima_ejecucion, p_f_prox_programada, p_id_activo, p_id_frec_mantenimiento);

    commit;
end;
$$;


-- dar baja mantenimiento preventivo
create or replace procedure proc_dar_baja_mp(p_id_mant_prev int)
language plpgsql
as $$
declare
    v_nombre_mant_prev varchar(150);
begin
    select nombre into v_nombre_mant_prev
    from mantenimiento_preventivo
    where id = p_id_mant_prev;

    if v_nombre_mant_prev is null then
        raise exception 'El mantenimiento preventivo con ID % no fue encontrado.', p_id_mant_prev;
    end if;

    update mantenimiento_preventivo
    set fecha_ultima_ejecucion = current_date, fecha_proxima_programada = null
    where id = p_id_mant_prev;

    raise notice 'El mantenimiento preventivo "%" se dio de baja exitosamente.', v_nombre_mant_prev;
    commit;
end;
$$;



-- ingresar documentación de registros
create or replace procedure proc_ingresar_documentacion_registro(
    p_tipo varchar,
    p_ruta_archivo varchar,
    p_comentario text,
    p_id_registro int,
    p_id_usuario int)
language plpgsql
as $$
begin
    if p_id_registro is null or p_id_usuario is null or p_tipo is null then
        raise exception 'Los ID de registro y usuario, y el tipo no pueden ser nulos.';
    end if;

    if p_ruta_archivo is null and p_comentario is null then
        raise exception 'Tiene que haber al menos una ruta de archivo o un comentario.';
    end if;

    if not fn_validacion(p_id_usuario, 'usuario') then
        raise exception 'El usuario con ID % no fue encontrado.', p_id_usuario;
    end if;

    insert into documentacion_registro(tipo, ruta_archivo, comentario, id_registro, id_usuario)
    values (p_tipo, p_ruta_archivo, p_comentario, p_id_registro, p_id_usuario);

    commit;
end;
$$;


-- ingresar documentación de órdenes de trabajo
create or replace procedure proc_ingresar_documentacion_ot(
    p_tipo varchar,
    p_ruta_archivo varchar,
    p_comentario text,
    p_id_ot int,
    p_id_usuario int)
language plpgsql
as $$
declare
    v_id_usuario_ok boolean;
    v_id_ot_ok boolean;
begin
    if p_id_ot is null or p_id_usuario is null or p_tipo is null then
        raise exception 'Los ID de ot y usuario, y el tipo no pueden ser nulos.';
    end if;

    if p_ruta_archivo is null and p_comentario is null then
        raise exception 'Tiene que haber al menos una ruta de archivo o un comentario.';
    end if;

    v_id_usuario_ok := fn_validacion(p_id_usuario, 'usuario');
    if not v_id_usuario_ok then
        raise exception 'El usuario con ID % no fue encontrado.', p_id_usuario;
    end if;

    v_id_ot_ok := fn_validacion(p_id_ot, 'orden_trabajo');
    if not v_id_ot_ok then
        raise exception 'La orden de trabajo con ID % no fue encontrada.', p_id_ot;
    end if;

    insert into documentacion_ot (tipo, ruta_archivo, comentario, id_orden_trabajo, id_usuario)
    values (p_tipo, p_ruta_archivo, p_comentario, p_id_ot, p_id_usuario);

    commit;
end;
$$;


-- ============================================================================
-- PROCEDIMIENTOS COMPLEMENTARIOS PARA TRIGGERS
-- ============================================================================
-- procedimiento para actualizar un mantenimiento preventivo
create or replace procedure proc_actualizar_mp(p_id int)
language plpgsql
as $$
declare
    v_fecha timestamp := CURRENT_TIMESTAMP;
begin
	
	if not fn_validacion(p_id, 'mantenimiento_preventivo') then
		raise exception 'El ID % de mantenimiento preventivo no fue encontrado.', p_id;
	end if;

	update mantenimiento_preventivo
	set fecha_ultima_ejecucion = v_fecha
	where id = p_id;

	raise notice 'El mantenimiento preventivo con ID % fue actualizado con éxito.', p_id;
end;
$$;


-- procedimiento para registrar mantenimiento preventivo
create or replace procedure proc_registrar_mp(p_id_activo int, p_id_tipo_evento int, p_id_mant_prev int)
language plpgsql
as $$
declare
	v_id_usuario int;
	v_fecha timestamp := CURRENT_TIMESTAMP;
begin
	select id into v_id_usuario
	from usuario
	where fn_norm(nombre) = fn_norm(CURRENT_USER);
	
	if not fn_validacion(p_id_activo, 'activo') then
		raise exception 'El ID % de activo no fue encontrado.', p_id_activo;
	end if;

	if not fn_validacion(p_id_tipo_evento, 'tipo_evento') then
		raise exception 'El ID % del tipo de evento no fue encontrado.', p_id_tipo_evento;
	end if;

	if not fn_validacion(p_id_mant_prev, 'mantenimiento_preventivo') then
		raise exception 'El ID % de mantenimiento preventivo no fue encontrado.', p_id_mant_prev;
	end if;

	insert into registro(
		fecha,
		id_activo,
		id_tipo_evento,
		id_usuario,
		id_mantenimiento_preventivo)
	values(
		v_fecha,
		p_id_activo,
		p_id_tipo_evento,
		v_id_usuario,
		p_id_mant_prev);
end;
$$;


-- TRIGGERS --

-- creamos el trigger para ubicacion
create trigger trg_raiz_ubicacion
after insert on cmms_amarillo.ubicacion
for each row
execute function fn_trg_set_ubicacion();

-- creamos el trigger para activo
create trigger trg_raiz_activo
after insert on cmms_amarillo.activo
for each row
execute function fn_trg_set_activo();

-- trigger para registrar un mantenimiento preventivo
create trigger trg_registrar_mp
after update of fecha_ultima_ejecucion on mantenimiento_preventivo
for each row
execute function fn_trg_registrar_mp();

-- trigger para forzar el cambio de estado de un activo cuando su orden de trabajo se cierra
create trigger trg_forzar_activo_operativo_al_cerrar_ot
after update on cmms_amarillo.orden_trabajo
for each row
when (old.id_estado is distinct from new.id_estado and new.id_estado = 3)
execute function fn_trg_forzar_activo_operativo_al_cerrar_ot();

-- trigger que audita las órdenes de trabajo cuando se inserta en la tabla
create trigger trg_auditar_ot_insert
after insert on cmms_amarillo.orden_trabajo
for each row
execute function fn_trg_auditar_ot();

-- trigger que audita las órdenes de trabajo cuando se actualiza la tabla
create trigger trg_auditar_ot_update
after update on orden_trabajo
for each row
when (
    old.id_estado is distinct from new.id_estado or
    old.f_prog_inicio is distinct from new.f_prog_inicio or
    old.f_prog_fin is distinct from new.f_prog_fin or
    old.horas_est is distinct from new.horas_est or
    old.f_real_inicio is distinct from new.f_real_inicio or
    old.f_real_fin is distinct from new.f_real_fin or
    old.horas_reales is distinct from new.horas_reales
)
execute function fn_trg_auditar_ot();

-- trigger para 
create trigger trg_bloquear_delete_ot
before delete on cmms_amarillo.orden_trabajo
for each row
execute function fn_trg_bloquear_delete_ot();

-- trigger que audita las órdenes de trabajo cuando se elimina de la tabla
create trigger trg_auditar_ot_delete
after delete on cmms_amarillo.orden_trabajo
for each row
execute function fn_trg_auditar_ot();

-- trigger para el historial de usuario
create trigger trg_historial_usuario
before insert or update or delete
on cmms_amarillo.usuario
for each row
execute function fn_trg_historial_usuario();

-- trigger para el historial de orden de trabajo
create trigger trg_historial_orden_trabajo
before insert or update or delete
on cmms_amarillo.orden_trabajo
for each row
execute function fn_trg_historial_orden_trabajo();


-- ============================================================================
-- VISTAS
-- ============================================================================

-- vista para visualizar el historial completo de la tabla activo
create or replace view vw_historial_completo_activo as
select 
    a.nombre as activo,
    a.nro_serie,
    r.fecha as fecha_evento,
    te.nombre as tipo_de_evento,
    u.nombre as registrado_por
from 
    registro r
join 
    activo a on r.id_activo = a.id
join 
    tipo_evento te on r.id_tipo_evento = te.id
join 
    usuario u on r.id_usuario = u.id
order by 
    a.nombre, r.fecha desc;


-- vista que muestra la desviación de las horas programadas con las reales
create or replace view vw_ot_desviacion_horas as
select 
    ot.id as id_ot,
    ot.titulo,
    a.nombre as activo_afectado,
    ot.horas_est as estimado,
    ot.horas_reales as real_ejecutado,

    fn_calcular_desviacion_horas_ot(ot.id) as desviacion_tiempo,
    
    u.nombre as creado_por,
    eo.nombre as estado
from 
    orden_trabajo ot
join
    activo a on ot.id_activo = a.id
join
    usuario u on ot.id_creado_por = u.id
join
    estado_ot eo on ot.id_estado = eo.id
where 
    eo.nombre = 'Cerrada'
order by
    abs(extract(epoch from fn_calcular_desviacion_horas_ot(ot.id))) desc;


-- vista que muestra todas las órdenes de trabajo activas, ordenadas por técnico
create or replace view vw_carga_trabajo_tecnico_activa as
select
    u.nombre as nombre_tecnico,
    u.especialidad,
    eot.nombre as estado_ot,
    count(ot.id) as ot_activas_en_estado
from
    usuario u
join
    ot_tecnico ott on u.id = ott.id_usuario -- unión para técnicos asignados a ots
join
    orden_trabajo ot on ott.id_orden_trabajo = ot.id
join
    estado_ot eot on ot.id_estado = eot.id
where
    -- filtra por estados que indican que el trabajo está en curso o pendiente
    eot.nombre not in ('Cerrada', 'Cancelada')
group by
    u.nombre, u.especialidad, eot.nombre;


-- vista que muestra los técnicos existentes en el sistema
create or replace view vw_tecnicos as
select nombre as nombre, 
       correo as correo,
	   id as identificacion,
	   telefono as telefono
from usuario
where id_rol=3
order by nombre asc;


-- vista que muestra todas las órdenes de trabajo abiertas en el sistema
create view vw_ot_abiertas as
select titulo as nombre,
	   descripcion,
	   id
from orden_trabajo
where id_estado = 1;


-- vista que muestra las compras recientes de activos
create or replace view vw_compras_recientes_act as
select nombre as nombre,
       nro_serie as numero_de_serie,
	   fabricante as fabricante,
	   fecha_compra as fecha
from activo
where fecha_compra > current_date - interval '1 year';


-- vista que muestra las órdenes de trabajo de mayor prioridad
create view vw_ordenes_importantes as
select titulo as nombre,
	   descripcion,
	   id
from orden_trabajo
where id_prioridad = 3;


-- vista que muestra todos los archivos del sistema
create view vw_ver_archivos as
select tipo,
       comentario,
	   ruta_archivo
from documentacion_registro
where ruta_archivo like '/docs/reg/%';


-- vista que muestra los activos según su ubicación
create view vw_activos_ubicacion as
select a.nombre as nombre_activo, a.nro_serie, nu.nombre as nombre_ubicacion
from activo a join ubicacion u on a.id_ubicacion = u.id
			join nombre_ubicacion nu on u.id = nu.id
order by nu.nombre;


--vista que muestra la hoja de vida de un técnico.
create or replace view vw_hoja_vida_tecnico as
select 
    u.id as id_tecnico,
    u.nombre as nombre_tecnico,
    u.especialidad,
    'ejecución de ot' as tipo_actividad,
    ot.titulo as detalle,
    a.nombre as activo_relacionado,
    ot.f_real_fin as fecha_actividad,
    eot.nombre as estado_resultado,
    ot.horas_reales as tiempo_invertido
from 
    usuario u
join 
    ot_tecnico ott on u.id = ott.id_usuario
join 
    orden_trabajo ot on ott.id_orden_trabajo = ot.id
join 
    activo a on ot.id_activo = a.id
join 
    estado_ot eot on ot.id_estado = eot.id

union all

select 
    u.id as id_tecnico,
    u.nombre as nombre_tecnico,
    u.especialidad,
    'reporte de evento' as tipo_actividad,
    te.nombre || coalesce(' - ' || mp.nombre, '') as detalle,
    a.nombre as activo_relacionado,
    r.fecha as fecha_actividad,
    'registrado' as estado_resultado,
    null as tiempo_invertido
from 
    usuario u
join 
    registro r on u.id = r.id_usuario
join 
    tipo_evento te on r.id_tipo_evento = te.id
join 
    activo a on r.id_activo = a.id
left join 
    mantenimiento_preventivo mp on r.id_mantenimiento_preventivo = mp.id
order by 
    fecha_actividad desc;


-- vista que nuestra los técnicos disponibles (sin ot asignada actualmente)
create or replace view vw_tecnicos_disponibles as
select 
    u.id,
    u.nombre,
    u.especialidad,
    u.turno_laboral,
    u.telefono,
    r.nombre as rol
from 
    usuario u
join 
    rol r on u.id_rol = r.id
where 
    lower(r.nombre) in ('técnico de campo', 'operador noc') 
    and u.id not in (
        select ott.id_usuario
        from ot_tecnico ott
        join orden_trabajo ot on ott.id_orden_trabajo = ot.id
        join estado_ot eot on ot.id_estado = eot.id
        where lower(eot.nombre) in ('abierta', 'en progreso')
    );


-- vista que muestra los próximos mantenimientos (7 días)
create or replace view vw_proximos_mantenimientos as
select 
    mp.id as id_mantenimiento,
    mp.nombre as titulo_mantenimiento,
    mp.descripcion,
    a.nombre as activo_a_mantener,
    mp.fecha_proxima_programada as fecha_programada,
    mp.duracion_estimada,
    f.nombre as frecuencia,
    (mp.fecha_proxima_programada - current_date) as dias_restantes
from 
    mantenimiento_preventivo mp
join 
    activo a on mp.id_activo = a.id
join 
    frecuencia_mantenimiento f on mp.id_frecuencia_mantenimiento = f.id
where 
    mp.fecha_proxima_programada between current_date and (current_date + interval '7 days')
order by 
    mp.fecha_proxima_programada asc;

-- vista que muestra la duración real de una ot
create view vw_calcular_duracion_ot as
select
    id as ID_ORDEN_TRABAJO,
    f_real_fin - f_real_inicio as DURACION_REAL
from orden_trabajo;

-- vista que retorna el estado actual de una orden de trabajo
create view vw_orden_estado as
select
    OT.id as ID_ORDEN_TRABAJO,
    EO.nombre as ESTADO
from orden_trabajo OT
join estado_ot EO
    on OT.id_estado = EO.id;

-- vista que muestra la fecha del último mantenimiento realizado
create view vw_ultimo_mantenimiento as
select fecha_ultima_ejecucion
from mantenimiento_preventivo
WHERE fecha_ultima_ejecucion is not null
ORDER BY fecha_ultima_ejecucion desc;


