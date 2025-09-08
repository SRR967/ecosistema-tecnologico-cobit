import { NextRequest, NextResponse } from "next/server";
import pool from "../../../../lib/database";

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    
    // Extraer objetivos seleccionados de los parámetros
    const selectedObjectives: Array<{ code: string; level: number }> = [];
    
    // Buscar parámetros obj_0, obj_1, etc.
    let index = 0;
    while (searchParams.has(`obj_${index}`)) {
      const param = searchParams.get(`obj_${index}`);
      if (param) {
        const [code, levelStr] = param.split(':');
        const level = parseInt(levelStr);
        if (code && !isNaN(level)) {
          selectedObjectives.push({ code, level });
        }
      }
      index++;
    }

    if (selectedObjectives.length === 0) {
      // Si no hay objetivos específicos, devolver todas las herramientas
      const allHerramientasQuery = `
        SELECT DISTINCT id, categoria
        FROM herramienta
        ORDER BY id
      `;
      
      const result = await pool.query(allHerramientasQuery);
      
      return NextResponse.json({
        success: true,
        herramientas: result.rows.map((row: any) => ({
          id: row.id,
          categoria: row.categoria
        }))
      });
    }

    // Construir consulta SQL para herramientas filtradas
    const conditions = selectedObjectives.map((_, index) => 
      `(o.id = $${index * 2 + 1} AND a.nivel_capacidad <= $${index * 2 + 2})`
    ).join(' OR ');
    
    const values: any[] = [];
    selectedObjectives.forEach(obj => {
      values.push(obj.code, obj.level);
    });

    const herramientasQuery = `
      SELECT DISTINCT h.id, h.categoria
      FROM herramienta h
      INNER JOIN actividad a ON h.id = a.herramienta_id
      INNER JOIN practica p ON a.practica_id = p.practica_id
      INNER JOIN ogg o ON p.ogg_id = o.id
      WHERE ${conditions}
      ORDER BY h.id
    `;

    const result = await pool.query(herramientasQuery, values);
    
    return NextResponse.json({
      success: true,
      herramientas: result.rows.map((row: any) => ({
        id: row.id,
        categoria: row.categoria
      }))
    });

  } catch (error) {
    console.error("Error en API de herramientas filtradas:", error);
    return NextResponse.json(
      { 
        success: false, 
        error: "Error interno del servidor",
        herramientas: []
      },
      { status: 500 }
    );
  }
}
