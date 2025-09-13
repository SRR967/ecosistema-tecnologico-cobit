import { NextResponse } from 'next/server';
import { getDominios } from '../../../../lib/database';

export async function GET() {
  try {
    const dominios = await getDominios();
    return NextResponse.json(dominios);
  } catch {
    return NextResponse.json(
      { error: 'Error al cargar los dominios' },
      { status: 500 }
    );
  }
}
