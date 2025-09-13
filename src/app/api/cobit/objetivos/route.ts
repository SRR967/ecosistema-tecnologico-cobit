import { NextResponse } from 'next/server';
import { getOGGs, getOGGsByDominio } from '../../../../lib/database';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const dominio = searchParams.get('dominio');
    
    let objetivos;
    if (dominio) {
      // Extraer código del dominio (ej: "APO - Alinear..." → "APO")
      const dominioCode = dominio.split(' - ')[0];
      objetivos = await getOGGsByDominio(dominioCode);
    } else {
      objetivos = await getOGGs();
    }
    
    return NextResponse.json(objetivos);
  } catch {
    return NextResponse.json(
      { error: 'Error al cargar los objetivos' },
      { status: 500 }
    );
  }
}
