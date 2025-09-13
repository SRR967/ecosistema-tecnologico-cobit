import { useState, useEffect } from 'react';
import { OGG } from '../lib/database';
import { CobitObjective, oggToCobitObjective } from '../types/cobit';

export interface UseCobitBoardReturn {
  objectives: CobitObjective[];
  loading: boolean;
  error: string | null;
  refetch: () => Promise<void>;
}

export function useCobitBoard(): UseCobitBoardReturn {
  const [objectives, setObjectives] = useState<CobitObjective[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchObjectives = async () => {
    try {
      setLoading(true);
      setError(null);

      const response = await fetch('/api/cobit/objetivos');
      
      if (!response.ok) {
        throw new Error('Error al cargar los objetivos');
      }

      const oggs: OGG[] = await response.json();
      
      // Convertir OGGs a CobitObjectives
      const convertedObjectives = oggs.map(ogg => oggToCobitObjective({
        id: ogg.id,
        nombre: ogg.nombre,
        proposito: ogg.proposito,
        dominio_codigo: ogg.dominio_codigo
      }));

      setObjectives(convertedObjectives);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error desconocido');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchObjectives();
  }, []);

  return {
    objectives,
    loading,
    error,
    refetch: fetchObjectives
  };
}

// Función helper para obtener objetivos por dominio
export function getObjectivesByDomain(
  objectives: CobitObjective[], 
  domain: 'EDM' | 'APO' | 'BAI' | 'DSS' | 'MEA'
): CobitObjective[] {
  return objectives.filter(obj => obj.domain === domain);
}

// Función helper para obtener título del dominio (ahora se obtiene de la base de datos)
export function getDomainTitle(domain: 'EDM' | 'APO' | 'BAI' | 'DSS' | 'MEA', dominios?: Array<{codigo: string, nombre: string}>): string {
  if (dominios) {
    const dominio = dominios.find(d => d.codigo === domain);
    return dominio ? `${domain} - ${dominio.nombre}` : domain;
  }
  
  // Fallback si no se proporcionan los dominios
  switch (domain) {
    case 'EDM': return 'EDM - Evaluar, Dirigir y Monitorear';
    case 'APO': return 'APO - Alinear, Planificar y Organizar';
    case 'BAI': return 'BAI - Construir, Adquirir e Implementar';
    case 'DSS': return 'DSS - Entregar, Dar Soporte y Servicio';
    case 'MEA': return 'MEA - Monitorizar, Evaluar y Valorar';
    default: return domain;
  }
}
