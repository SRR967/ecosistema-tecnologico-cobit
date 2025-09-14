import { NextRequest, NextResponse } from "next/server";
import pool from "../../../../lib/database";

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const objetivos = searchParams.getAll('objetivo');
    const herramientas = searchParams.getAll('herramienta');
    
    let query = `
      SELECT DISTINCT d.codigo, d.nombre
      FROM dominio d
      INNER JOIN ogg o ON d.codigo = SUBSTRING(o.id, 1, 3)
      INNER JOIN practica p ON o.id = p.ogg_id
      INNER JOIN actividad a ON p.practica_id = a.practica_id
      INNER JOIN herramienta h ON a.herramienta_id = h.id
      WHERE 1=1
    `;

    const params: string[] = [];
    let paramIndex = 1;

    // Filtro por objetivos específicos
    if (objetivos && objetivos.length > 0) {
      const objetivoConditions = objetivos.map(() => {
        const condition = `o.id = $${paramIndex}`;
        paramIndex++;
        return condition;
      });
      query += ` AND (${objetivoConditions.join(' OR ')})`;
      params.push(...objetivos);
    }

    // Filtro por herramientas específicas
    if (herramientas && herramientas.length > 0) {
      const herramientaConditions = herramientas.map(() => {
        const condition = `h.id = $${paramIndex}`;
        paramIndex++;
        return condition;
      });
      query += ` AND (${herramientaConditions.join(' OR ')})`;
      params.push(...herramientas);
    }

    query += ` ORDER BY d.codigo`;

    const result = await pool.query(query, params);
    
    return NextResponse.json(result.rows);
  } catch (error) {
    console.error('Error en dominios-filtrados:', error);
    return NextResponse.json(
      { error: 'Error al cargar dominios filtrados' },
      { status: 500 }
    );
  }
}
