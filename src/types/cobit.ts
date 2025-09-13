// Tipos para los objetivos COBIT
export interface CobitObjective {
  code: string;
  title: string;
  domain: 'EDM' | 'APO' | 'BAI' | 'DSS' | 'MEA';
}

// Interfaz para los datos que vienen de la base de datos (OGG)
export interface OGGObjective {
  id: string;
  nombre: string;
  proposito: string;
  dominio_codigo: string;
}

// Función para convertir OGG a CobitObjective
export function oggToCobitObjective(ogg: OGGObjective): CobitObjective {
  // Usar el dominio_codigo directamente de la base de datos
  const domain = ogg.dominio_codigo as 'EDM' | 'APO' | 'BAI' | 'DSS' | 'MEA';
  
  return {
    code: ogg.id,
    title: ogg.nombre,
    domain: domain
  };
}
