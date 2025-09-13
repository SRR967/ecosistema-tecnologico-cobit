import { NextResponse } from 'next/server';
import pool from '../../../../lib/database';

export interface TablaCobitRow {
  objetivo_id: string;
  objetivo_nombre: string;
  practica_id: string;
  practica_nombre: string;
  actividad_id: string;
  actividad_descripcion: string;
  nivel_capacidad: number;
  herramienta_id: string;
  herramienta_nombre?: string;
  herramienta_categoria?: string;
  justificacion: string;
  observaciones?: string;
  integracion?: string;
}

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const dominio = searchParams.get('dominio');
    const objetivos = searchParams.getAll('objetivo'); // Cambiar a getAll para múltiples valores
    const herramienta = searchParams.get('herramienta');
    
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

    // Query base con todos los joins
    let query = `
      SELECT 
        o.id as objetivo_id,
        o.nombre as objetivo_nombre,
        p.practica_id,
        p.nombre as practica_nombre,
        a.actividad_id,
        a.descripcion as actividad_descripcion,
        a.nivel_capacidad,
        a.herramienta_id,
        h.id as herramienta_nombre,
        h.categoria as herramienta_categoria,
        a.justificacion,
        a.observaciones,
        a.integracion
      FROM ogg o
      JOIN practica p ON o.id = p.ogg_id
      JOIN actividad a ON p.practica_id = a.practica_id
      LEFT JOIN herramienta h ON a.herramienta_id = h.id
      WHERE 1=1
    `;

    const params: (string | number)[] = [];
    let paramIndex = 1;

    // Filtro por dominio
    if (dominio && dominio !== '') {
      // Extraer código del dominio (ej: "APO - Alinear..." → "APO")
      const dominioCode = dominio.split(' - ')[0];
      query += ` AND o.id LIKE $${paramIndex}`;
      params.push(`${dominioCode}%`);
      paramIndex++;
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

    // Filtro por herramienta
    if (herramienta && herramienta !== '') {
      query += ` AND h.id = $${paramIndex}`;
      params.push(herramienta);
      paramIndex++;
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
        params.push(obj.level);
        paramIndex += 2;
      });
      
      // Unir todas las condiciones con OR
      if (objectiveConditions.length > 0) {
        query += ` AND (${objectiveConditions.join(' OR ')})`;
      }
    }

    query += ` ORDER BY o.id, p.practica_id, a.actividad_id`;

    const result = await pool.query(query, params);
    
    return NextResponse.json({
      data: result.rows,
      total: result.rows.length
    });
  } catch {
    return NextResponse.json(
      { error: 'Error al cargar los datos de la tabla' },
      { status: 500 }
    );
  }
}
