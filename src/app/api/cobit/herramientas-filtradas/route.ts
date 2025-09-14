import { NextRequest, NextResponse } from "next/server";
import pool from "../../../../lib/database";
import { HerramientaRow, DBRow } from "../../../../types/database";
import { cache, cacheHelpers, SimpleCache } from "../../../../lib/cache";

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const dominios = searchParams.getAll('dominio');
    const objetivos = searchParams.getAll('objetivo');
    const herramientas = searchParams.getAll('herramienta');
    
    // Crear clave de caché
    const cacheKey = SimpleCache.generateKey('herramientas-filtradas', {
      dominios: dominios.sort(),
      objetivos: objetivos.sort(),
      herramientas: herramientas.sort()
    });
    
    // Verificar caché
    const cachedResult = cache.get(cacheKey);
    if (cachedResult) {
      return NextResponse.json(cachedResult);
    }
    
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

    // Si no hay filtros activos, devolver todas las herramientas
    const hasActiveFilters = dominios.length > 0 || objetivos.length > 0 || herramientas.length > 0 || selectedObjectives.length > 0;
    
    if (!hasActiveFilters) {
      const allHerramientasQuery = `
        SELECT DISTINCT id, categoria
        FROM herramienta
        ORDER BY id
      `;
      
      const result = await pool.query(allHerramientasQuery);
      
      const response = {
        success: true,
        herramientas: result.rows.map((row: DBRow): HerramientaRow => ({
          id: row.id as string,
          categoria: row.categoria as string
        }))
      };
      
      // Guardar en caché (datos estáticos, TTL más largo)
      cacheHelpers.setStaticData(cacheKey, response);
      
      return NextResponse.json(response);
    }

    // Construir consulta SQL optimizada para herramientas filtradas
    let query = `
      SELECT DISTINCT h.id, h.categoria
      FROM herramienta h
      WHERE EXISTS (
        SELECT 1 FROM actividad a
        INNER JOIN practica p ON a.practica_id = p.practica_id
        INNER JOIN ogg o ON p.ogg_id = o.id
        WHERE h.id = a.herramienta_id`;

    const params: (string | number)[] = [];
    let paramIndex = 1;

    // Filtro por dominios
    if (dominios && dominios.length > 0) {
      const dominioConditions = dominios.map(() => {
        const condition = `o.id LIKE $${paramIndex}`;
        paramIndex++;
        return condition;
      });
      query += ` AND (${dominioConditions.join(' OR ')})`;
      dominios.forEach(dominio => {
        const dominioCode = dominio.split(' - ')[0];
        params.push(`${dominioCode}%`);
      });
    }

    // Filtro por objetivos
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

    // Filtro por objetivos específicos con niveles
    if (selectedObjectives.length > 0) {
      const objectiveConditions = selectedObjectives.map(() => {
        const condition = `(o.id = $${paramIndex} AND a.nivel_capacidad <= $${paramIndex + 1})`;
        paramIndex += 2;
        return condition;
      });
      query += ` AND (${objectiveConditions.join(' OR ')})`;
      selectedObjectives.forEach(obj => {
        params.push(obj.code, obj.level);
      });
    }

    query += `
      )
      ORDER BY h.id`;

    const result = await pool.query(query, params);
    
    const response = {
      success: true,
      herramientas: result.rows.map((row: DBRow): HerramientaRow => ({
        id: row.id as string,
        categoria: row.categoria as string
      }))
    };
    
    // Guardar en caché
    cacheHelpers.setFilteredData(cacheKey, response);
    
    return NextResponse.json(response);

  } catch {
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
