const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Configuración de la base de datos
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_DATABASE || 'cobit',
  password: process.env.DB_PASSWORD || 'root',
  port: parseInt(process.env.DB_PORT || '5432'),
});

async function optimizeDatabase() {
  console.log('🚀 Iniciando optimización de la base de datos...');
  
  try {
    // Leer el script de índices
    const indexPath = path.join(__dirname, '..', 'database', 'init', '02-add-indexes.sql');
    const indexScript = fs.readFileSync(indexPath, 'utf8');
    
    console.log('📊 Ejecutando script de índices...');
    await pool.query(indexScript);
    
    console.log('✅ Índices creados exitosamente');
    
    // Verificar que los índices se crearon
    console.log('🔍 Verificando índices creados...');
    const indexQuery = `
      SELECT 
        schemaname,
        tablename,
        indexname,
        indexdef
      FROM pg_indexes 
      WHERE schemaname = 'public' 
      AND indexname LIKE 'idx_%'
      ORDER BY tablename, indexname;
    `;
    
    const result = await pool.query(indexQuery);
    
    if (result.rows.length > 0) {
      console.log('📋 Índices encontrados:');
      result.rows.forEach(row => {
        console.log(`  - ${row.tablename}.${row.indexname}`);
      });
    } else {
      console.log('⚠️  No se encontraron índices personalizados');
    }
    
    // Analizar estadísticas de las tablas
    console.log('📈 Actualizando estadísticas de las tablas...');
    await pool.query('ANALYZE;');
    
    console.log('✅ Optimización completada exitosamente');
    
  } catch (error) {
    console.error('❌ Error durante la optimización:', error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Ejecutar si se llama directamente
if (require.main === module) {
  optimizeDatabase();
}

module.exports = { optimizeDatabase };
