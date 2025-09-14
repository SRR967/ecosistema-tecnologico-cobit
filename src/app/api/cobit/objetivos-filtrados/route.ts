import { NextRequest, NextResponse } from "next/server";
import pool from "../../../../lib/database";

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const dominios = searchParams.getAll('dominio');
    const herramientas = searchParams.getAll('herramienta');
    
    let query = `
      SELECT DISTINCT o.id, o.nombre, o.proposito, o.dominio_codigo
      FROM ogg o
      INNER JOIN practica p ON o.id = p.ogg_id
      INNER JOIN actividad a ON p.practica_id = a.practica_id
      INNER JOIN herramienta h ON a.herramienta_id = h.id
      WHERE 1=1
    `;

    const params: string[] = [];
    let paramIndex = 1;

    // Filtro por dominios específicos
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

    query += ` ORDER BY o.id`;

    const result = await pool.query(query, params);
    
    return NextResponse.json(result.rows);
  } catch (error) {
    console.error('Error en objetivos-filtrados:', error);
    return NextResponse.json(
      { error: 'Error al cargar objetivos filtrados' },
      { status: 500 }
    );
  }
}
