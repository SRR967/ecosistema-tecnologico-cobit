const { Pool } = require('pg');

// Configuración de conexión
const pool = new Pool({
  user: process.env.DB_USER ,
  host: process.env.DB_HOST ,
  database: process.env.DB_DATABASE ,
  password: process.env.DB_PASSWORD ,
  port: parseInt(process.env.DB_PORT || '5432'),
});

async function testConnection() {
  try {
    console.log('🔄 Probando conexión a la base de datos COBIT...');
    
    const client = await pool.connect();
    console.log('✅ Conexión exitosa');
    
    // Verificar tablas existentes
    const tablesResult = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name IN ('ogg', 'practica', 'herramienta', 'actividad')
      ORDER BY table_name
    `);
    
    console.log('📋 Tablas encontradas:', tablesResult.rows.map(row => row.table_name));
    
    // Contar registros
    for (const table of ['ogg', 'practica', 'herramienta', 'actividad']) {
      try {
        const countResult = await client.query(`SELECT COUNT(*) FROM ${table}`);
        console.log(`📊 ${table}: ${countResult.rows[0].count} registros`);
      } catch (err) {
        console.log(`❌ Error al consultar ${table}: tabla no existe`);
      }
    }
    
    // Mostrar algunos dominios de ejemplo
    try {
      const dominiosResult = await client.query(`
        SELECT DISTINCT 
          SUBSTRING(id FROM 1 FOR 3) as dominio,
          COUNT(*) as objetivos
        FROM ogg 
        GROUP BY SUBSTRING(id FROM 1 FOR 3)
        ORDER BY dominio
      `);
      
      console.log('🎯 Dominios disponibles:');
      dominiosResult.rows.forEach(row => {
        console.log(`   - ${row.dominio}: ${row.objetivos} objetivos`);
      });
    } catch (err) {
      console.log('❌ Error al obtener dominios:', err.message);
    }
    
    client.release();
    console.log('✅ Prueba completada exitosamente');
    
  } catch (error) {
    console.log('❌ Error de conexión:', error.message);
    console.log('💡 Verifica que PostgreSQL esté ejecutándose y la base de datos "cobit" exista');
  } finally {
    await pool.end();
  }
}

testConnection();
