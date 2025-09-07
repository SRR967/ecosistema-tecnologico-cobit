import { NextResponse } from 'next/server';
import { getHerramientas } from '../../../../lib/database';

export async function GET() {
  try {
    const herramientas = await getHerramientas();
    return NextResponse.json(herramientas);
  } catch (error) {
    console.error('Error en API de herramientas:', error);
    return NextResponse.json(
      { error: 'Error al cargar las herramientas' },
      { status: 500 }
    );
  }
}
