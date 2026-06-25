# Proyecto Integrador ISFPP: Base de Datos para CMMS

## Descripción del Proyecto
[cite_start]Diseño e implementación de una base de datos para un Sistema Computarizado de Gestión de Mantenimiento (CMMS)[cite: 26, 27]. [cite_start]Este proyecto es desarrollado para la empresa BoscoMaq S.A., dedicada a la producción industrial, con el fin de digitalizar su gestión de mantenimiento[cite: 29]. [cite_start]El trabajo corresponde a la Instancia Supervisada de Formación Práctica Profesional (ISFPP) de la cátedra de Bases de Datos (2025) de la UNPSJB[cite: 1, 3, 4].

## Requerimientos y Entidades Principales
* [cite_start]**Usuarios y Técnicos:** Registro de planificadores, técnicos y administradores con sus datos personales, rol, turnos y especialidades[cite: 32, 33, 35].
* [cite_start]**Ubicaciones:** Organización jerárquica de plantas, talleres, depósitos y oficinas[cite: 37, 38].
* [cite_start]**Activos:** Inventario de máquinas y equipos (código, modelo, estado, etc.) con capacidad de agruparse jerárquicamente[cite: 40, 41, 42].
* [cite_start]**Órdenes de Trabajo (OT):** Gestión de mantenimientos con estados, prioridades, tiempos estimados/reales y técnicos asignados[cite: 44, 45, 48].
* [cite_start]**Mantenimiento Preventivo:** Programación de tareas recurrentes para activos[cite: 50, 51].
* [cite_start]**Registros y Auditoría:** Historial de intervenciones [cite: 52, 53] [cite_start]y trazabilidad de cambios en datos críticos[cite: 58, 59].
* [cite_start]**Documentación:** Soporte para archivos adjuntos y comentarios[cite: 56, 57].

## Implementación Técnica
* [cite_start]**Motor de Base de Datos:** PostgreSQL[cite: 66].
* [cite_start]**Estructura:** Definición de tablas, claves primarias, foráneas y restricciones[cite: 64, 67].
* [cite_start]**Datos de Prueba:** Inserción mínima de 15 usuarios, 10 ubicaciones, 20 activos, 30 OT, entre otros[cite: 70].
* [cite_start]**Vistas:** Reportes y estadísticas (ej. mantenimientos programados a 7 días)[cite: 72, 73, 74].
* [cite_start]**Funciones:** Mínimo de 3 funciones implementadas[cite: 77, 78].
* [cite_start]**Procedimientos Almacenados:** Mínimo de 3 procedimientos (ej. cerrar una orden)[cite: 79, 80, 81].
* [cite_start]**Triggers:** Mínimo de 3 triggers (ej. registro de auditoría de estados de OT)[cite: 82, 83].

## Cronograma de Entregas
* [cite_start]**1er Entrega (16/10/2025):** Diagramas conceptual, relacional y scripts SQL DDL[cite: 5, 6, 7].
* [cite_start]**2da Entrega (30/10/2025):** Inserción de datos, procedimientos y funciones[cite: 8, 9].
* [cite_start]**3er Entrega (6/11/2025):** Triggers, vistas y consultas SQL representativas[cite: 10, 11].
* [cite_start]**4ta Entrega (13/11/2025):** Presentación del informe final con diagrama de clases, decisiones de diseño, implementación y conclusiones[cite: 12, 13, 17, 18, 19, 22].