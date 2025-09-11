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
  descripcion: string;
  proposito: string;
}

// Función para convertir OGG a CobitObjective
export function oggToCobitObjective(ogg: OGGObjective): CobitObjective {
  // Extraer el dominio del ID (primeros 3 caracteres)
  const domain = ogg.id.substring(0, 3) as 'EDM' | 'APO' | 'BAI' | 'DSS' | 'MEA';
  
  return {
    code: ogg.id,
    title: ogg.nombre,
    domain: domain
  };
}
