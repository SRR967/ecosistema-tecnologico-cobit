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
        { error: 'ID de objetivo requerido' },
        { status: 400 }
      );
    }

    const result = await pool.query(
      'SELECT id, nombre, descripcion, proposito FROM ogg WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return NextResponse.json(
        { error: 'Objetivo no encontrado' },
        { status: 404 }
      );
    }

    return NextResponse.json(result.rows[0]);
  } catch {
    return NextResponse.json(
      { error: 'Error al cargar el objetivo' },
      { status: 500 }
    );
  }
}
