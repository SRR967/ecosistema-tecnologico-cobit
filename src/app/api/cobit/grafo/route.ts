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
    const dominios = searchParams.getAll('dominio'); // Cambiar a getAll para múltiples valores
    const objetivos = searchParams.getAll('objetivo'); // Cambiar a getAll para múltiples valores
    const herramientas = searchParams.getAll('herramienta'); // Cambiar a getAll para múltiples valores
    
    // Nuevos parámetros para objetivos específicos con niveles
    const selectedObjectives: { code: string; level: number }[] = [];
    
    // Buscar todos los parámetros que empiecen con 'obj_'
    searchParams.forEach((value, key) => {
      if (key.startsWith('obj_')) {
        const [code, level] = value.split(':');
        if (code && level) {
          selectedObjectives.push({
            code: code,
            level: parseInt(level, 10)
          });
        }
      }
    });



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

    // Filtro por dominios (múltiples)
    if (dominios && dominios.length > 0) {
      const dominioConditions = dominios.map(() => {
        const condition = `o.id LIKE $${paramIndex}`;
        paramIndex++;
        return condition;
      });
      query += ` AND (${dominioConditions.join(' OR ')})`;
      // Agregar el patrón % para cada dominio
      dominios.forEach(dominio => {
        const dominioCode = dominio.split(' - ')[0];
        params.push(`${dominioCode}%`);
      });
    }

    // Filtro por objetivos específicos (múltiples)
    if (objetivos && objetivos.length > 0) {
      const objetivoConditions = objetivos.map(() => {
        const condition = `o.id = $${paramIndex}`;
        paramIndex++;
        return condition;
      });
      query += ` AND (${objetivoConditions.join(' OR ')})`;
      params.push(...objetivos);
    }

    // Filtro por herramientas (múltiples)
    if (herramientas && herramientas.length > 0) {
      const herramientaConditions = herramientas.map(() => {
        const condition = `h.id = $${paramIndex}`;
        paramIndex++;
        return condition;
      });
      query += ` AND (${herramientaConditions.join(' OR ')})`;
      params.push(...herramientas);
    }
    
    // Filtro por objetivos específicos con niveles de capacidad
    if (selectedObjectives.length > 0) {
      // Crear condiciones para cada objetivo seleccionado
      const objectiveConditions: string[] = [];
      
      selectedObjectives.forEach((obj) => {
        // Filtrar por objetivo específico Y nivel de capacidad máximo
        objectiveConditions.push(
          `(o.id = $${paramIndex} AND a.nivel_capacidad <= $${paramIndex + 1})`
        );
        params.push(obj.code);
        params.push(obj.level.toString());
        paramIndex += 2;
      });
      
      // Unir todas las condiciones con OR
      if (objectiveConditions.length > 0) {
        query += ` AND (${objectiveConditions.join(' OR ')})`;
      }
    }

    query += `
      GROUP BY o.id, o.nombre, h.id, h.categoria, h.descripcion, h.tipo_herramienta
      HAVING COUNT(a.actividad_id) > 0
      ORDER BY o.id, count_actividades DESC
    `;

    const result = await pool.query(query, params);
    
    
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

    return NextResponse.json(grafoData);
  } catch {
    return NextResponse.json(
      { error: 'Error al cargar los datos del grafo' },
      { status: 500 }
    );
  }
}
