import { NextResponse } from 'next/server';
import { pool } from '../../../../../lib/database';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    
    if (!id) {
      return NextResponse.json(
        { error: 'ID de herramienta requerido' },
        { status: 400 }
      );
    }

    const result = await pool.query(
      'SELECT id, categoria, descripcion, casos_uso, tipo_herramienta FROM herramienta WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return NextResponse.json(
        { error: 'Herramienta no encontrada' },
        { status: 404 }
      );
    }

    return NextResponse.json(result.rows[0]);
  } catch {
    return NextResponse.json(
      { error: 'Error al cargar la herramienta' },
      { status: 500 }
    );
  }
}
