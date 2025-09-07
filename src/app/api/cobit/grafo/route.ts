import { NextResponse } from 'next/server';
import pool from '../../../../lib/database';

export interface GrafoNode {
  id: string;
  name: string;
  type: 'objetivo' | 'herramienta';
  domain?: string; // Solo para objetivos
  category?: string; // Solo para herramientas
  description?: string; // Solo para herramientas
  toolType?: string; // Solo para herramientas (tipo_herramienta)
}

export interface GrafoLink {
  source: string;
  target: string;
  count: number; // Número de actividades que conectan el objetivo con la herramienta
}

export interface GrafoData {
  nodes: GrafoNode[];
  links: GrafoLink[];
}

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const dominio = searchParams.get('dominio');
    const herramienta = searchParams.get('herramienta');

    console.log('🔍 API Grafo - Parámetros:', { dominio, herramienta });

    // Diagnóstico: verificar cada tabla por separado
    try {
      const countOgg = await pool.query('SELECT COUNT(*) as count FROM ogg');
      console.log('🎯 Objetivos (OGG):', countOgg.rows[0].count);

      const countHerramienta = await pool.query('SELECT COUNT(*) as count FROM herramienta');
      console.log('🔧 Herramientas:', countHerramienta.rows[0].count);

      const countPractica = await pool.query('SELECT COUNT(*) as count FROM practica');
      console.log('📋 Prácticas:', countPractica.rows[0].count);

      const countActividad = await pool.query('SELECT COUNT(*) as count FROM actividad');
      console.log('⚡ Actividades:', countActividad.rows[0].count);

      // Verificar algunas relaciones básicas
      const sampleOgg = await pool.query('SELECT id FROM ogg LIMIT 3');
      console.log('📄 Muestra OGG IDs:', sampleOgg.rows.map(r => r.id));

      const sampleHerramienta = await pool.query('SELECT id FROM herramienta LIMIT 3');
      console.log('🔧 Muestra Herramientas:', sampleHerramienta.rows.map(r => r.id));

      // Verificar si hay prácticas conectadas a objetivos
      if (countPractica.rows[0].count > 0) {
        const practicasSample = await pool.query('SELECT practica_id, ogg_id FROM practica LIMIT 3');
        console.log('🔗 Muestra relaciones práctica-ogg:', practicasSample.rows);
      }

      // Verificar si hay actividades conectadas
      if (countActividad.rows[0].count > 0) {
        const actividadesSample = await pool.query('SELECT actividad_id, practica_id, herramienta_id FROM actividad LIMIT 3');
        console.log('🔗 Muestra relaciones actividad:', actividadesSample.rows);
      }

    } catch (diagError) {
      console.error('❌ Error en diagnóstico:', diagError);
    }

    // Query para obtener las relaciones objetivo-herramienta
    let query = `
      SELECT 
        o.id as objetivo_id,
        o.nombre as objetivo_nombre,
        h.id as herramienta_id,
        h.categoria as herramienta_categoria,
        h.descripcion as herramienta_descripcion,
        h.tipo_herramienta as herramienta_tipo,
        COUNT(a.actividad_id) as count_actividades
      FROM ogg o
      JOIN practica p ON o.id = p.ogg_id
      JOIN actividad a ON p.practica_id = a.practica_id
      JOIN herramienta h ON a.herramienta_id = h.id
      WHERE 1=1
    `;

    const params: string[] = [];
    let paramIndex = 1;

    // Filtro por dominio
    if (dominio && dominio !== '') {
      const dominioCode = dominio.split(' - ')[0];
      query += ` AND o.id LIKE $${paramIndex}`;
      params.push(`${dominioCode}%`);
      paramIndex++;
    }

    // Filtro por herramienta
    if (herramienta && herramienta !== '') {
      query += ` AND h.id = $${paramIndex}`;
      params.push(herramienta);
      paramIndex++;
    }

    query += `
      GROUP BY o.id, o.nombre, h.id, h.categoria, h.descripcion, h.tipo_herramienta
      HAVING COUNT(a.actividad_id) > 0
      ORDER BY o.id, count_actividades DESC
    `;

    const result = await pool.query(query, params);
    
    console.log(`📊 Filas obtenidas: ${result.rows.length}`);
    if (result.rows.length > 0) {
      console.log('📄 Primera fila:', result.rows[0]);
    }
    
    // Procesar datos para crear nodos y enlaces
    const nodes: GrafoNode[] = [];
    const links: GrafoLink[] = [];
    const nodeIds = new Set<string>();

    result.rows.forEach(row => {
      const objetivoId = row.objetivo_id;
      const herramientaId = row.herramienta_id;
      
      // Agregar nodo de objetivo si no existe
      if (!nodeIds.has(objetivoId)) {
        const domain = objetivoId.substring(0, 3);
        nodes.push({
          id: objetivoId,
          name: row.objetivo_nombre,
          type: 'objetivo',
          domain: domain
        });
        nodeIds.add(objetivoId);
      }
      
      // Agregar nodo de herramienta si no existe
      if (!nodeIds.has(herramientaId)) {
        nodes.push({
          id: herramientaId,
          name: herramientaId,
          type: 'herramienta',
          category: row.herramienta_categoria,
          description: row.herramienta_descripcion,
          toolType: row.herramienta_tipo
        });
        nodeIds.add(herramientaId);
      }
      
      // Agregar enlace
      links.push({
        source: objetivoId,
        target: herramientaId,
        count: parseInt(row.count_actividades)
      });
    });

    const grafoData: GrafoData = {
      nodes,
      links
    };

    console.log(`🎯 Resultado final - Nodos: ${nodes.length}, Enlaces: ${links.length}`);

    return NextResponse.json(grafoData);
  } catch (error) {
    console.error('Error en API de grafo:', error);
    return NextResponse.json(
      { error: 'Error al cargar los datos del grafo' },
      { status: 500 }
    );
  }
}
