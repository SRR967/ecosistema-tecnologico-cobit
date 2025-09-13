import { Pool } from 'pg';

// Configuración de la conexión a PostgreSQL
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_DATABASE || 'cobit',
  password: process.env.DB_PASSWORD || 'root',
  port: parseInt(process.env.DB_PORT || '5432'),
});

// Tipos para los datos basados en tu esquema
export interface Dominio {
  codigo: string;       // EDM, APO, BAI, DSS, MEA
  nombre: string;
}

export interface OGG {
  id: string;           // Formato: APO01, DSS01, etc.
  nombre: string;
  proposito: string;
  dominio_codigo: string; // EDM, APO, BAI, DSS, MEA
}

export interface Practica {
  practica_id: string;  // Formato: DSS01-P01
  ogg_id: string;
  nombre: string;
}

export interface Herramienta {
  id: string;
  categoria: string;
  descripcion: string;
  casos_uso: string[];
  tipo_herramienta: string;
}

export interface Actividad {
  actividad_id: string;    // Formato: DSS01-P01-A01
  practica_id: string;
  descripcion: string;
  nivel_capacidad: number; // 1-5
  herramienta_id: string;
  justificacion: string;
  observaciones?: string;
  integracion?: string;
}

// Función para obtener dominios desde la tabla dominio
export async function getDominios(): Promise<Dominio[]> {
  try {
    const result = await pool.query(`
      SELECT codigo, nombre 
      FROM dominio 
      ORDER BY codigo
    `);
    return result.rows;
  } catch {
    throw new Error('No se pudieron cargar los dominios');
  }
}

// Función para obtener todos los OGGs (objetivos)
export async function getOGGs(): Promise<OGG[]> {
  try {
    const result = await pool.query('SELECT * FROM ogg ORDER BY id');
    return result.rows;
  } catch {
    throw new Error('No se pudieron cargar los objetivos');
  }
}

// Función para obtener OGGs por dominio
export async function getOGGsByDominio(dominioCode: string): Promise<OGG[]> {
  try {
    const result = await pool.query(
      'SELECT * FROM ogg WHERE dominio_codigo = $1 ORDER BY id',
      [dominioCode]
    );
    return result.rows;
  } catch {
    throw new Error('No se pudieron cargar los objetivos del dominio');
  }
}

// Función para obtener todas las herramientas
export async function getHerramientas(): Promise<Herramienta[]> {
  try {
    const result = await pool.query('SELECT * FROM herramienta ORDER BY id');
    return result.rows;
  } catch {
    throw new Error('No se pudieron cargar las herramientas');
  }
}

// Función para obtener herramientas por categoría
export async function getHerramientasByCategoria(): Promise<{categoria: string, count: number}[]> {
  try {
    const result = await pool.query(`
      SELECT categoria, COUNT(*) as count 
      FROM herramienta 
      GROUP BY categoria 
      ORDER BY categoria
    `);
    return result.rows;
  } catch {
    throw new Error('No se pudieron cargar las categorías');
  }
}

// Función para obtener prácticas por OGG
export async function getPracticasByOGG(oggId: string): Promise<Practica[]> {
  try {
    const result = await pool.query(
      'SELECT * FROM practica WHERE ogg_id = $1 ORDER BY practica_id',
      [oggId]
    );
    return result.rows;
  } catch {
    throw new Error('No se pudieron cargar las prácticas');
  }
}

// Función para obtener actividades por práctica
export async function getActividadesByPractica(practicaId: string): Promise<Actividad[]> {
  try {
    const result = await pool.query(
      'SELECT * FROM actividad WHERE practica_id = $1 ORDER BY actividad_id',
      [practicaId]
    );
    return result.rows;
  } catch {
    throw new Error('No se pudieron cargar las actividades');
  }
}

// Función para cerrar la conexión
export async function closePool(): Promise<void> {
  await pool.end();
}

// Exportar pool como exportación nombrada y por defecto
export { pool };
export default pool;
