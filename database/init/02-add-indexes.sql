-- Script para agregar índices que optimicen las consultas de filtrado
-- Ejecutar después de 01-init-cobit-schema.sql

-- Índices para la tabla ogg (objetivos)
CREATE INDEX IF NOT EXISTS idx_ogg_id ON ogg(id);
CREATE INDEX IF NOT EXISTS idx_ogg_dominio_codigo ON ogg(dominio_codigo);

-- Índices para la tabla practica
CREATE INDEX IF NOT EXISTS idx_practica_ogg_id ON practica(ogg_id);
CREATE INDEX IF NOT EXISTS idx_practica_id ON practica(practica_id);

-- Índices para la tabla actividad
CREATE INDEX IF NOT EXISTS idx_actividad_practica_id ON actividad(practica_id);
CREATE INDEX IF NOT EXISTS idx_actividad_herramienta_id ON actividad(herramienta_id);
CREATE INDEX IF NOT EXISTS idx_actividad_nivel_capacidad ON actividad(nivel_capacidad);

-- Índices para la tabla herramienta
CREATE INDEX IF NOT EXISTS idx_herramienta_id ON herramienta(id);
CREATE INDEX IF NOT EXISTS idx_herramienta_categoria ON herramienta(categoria);

-- Índices compuestos para optimizar JOINs frecuentes
CREATE INDEX IF NOT EXISTS idx_actividad_practica_herramienta ON actividad(practica_id, herramienta_id);
CREATE INDEX IF NOT EXISTS idx_actividad_herramienta_nivel ON actividad(herramienta_id, nivel_capacidad);

-- Índices para consultas LIKE en dominios
CREATE INDEX IF NOT EXISTS idx_ogg_id_pattern ON ogg(id text_pattern_ops);

-- Estadísticas de la base de datos para el optimizador de consultas
ANALYZE;
