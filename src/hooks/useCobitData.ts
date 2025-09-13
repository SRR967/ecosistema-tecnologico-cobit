import { useState, useEffect } from 'react';
import { OGG, Herramienta, Dominio } from '../lib/database';

export interface UseCobitDataReturn {
  dominios: Dominio[];
  objetivos: OGG[];
  herramientas: Herramienta[];
  loading: boolean;
  error: string | null;
  refetch: () => Promise<void>;
}

export function useCobitData(): UseCobitDataReturn {
  const [dominios, setDominios] = useState<Dominio[]>([]);
  const [objetivos, setObjetivos] = useState<OGG[]>([]);
  const [herramientas, setHerramientas] = useState<Herramienta[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Cargar datos en paralelo
      const [dominiosRes, objetivosRes, herramientasRes] = await Promise.all([
        fetch('/api/cobit/dominios'),
        fetch('/api/cobit/objetivos'),
        fetch('/api/cobit/herramientas')
      ]);

      // Verificar que todas las respuestas sean exitosas
      if (!dominiosRes.ok || !objetivosRes.ok || !herramientasRes.ok) {
        throw new Error('Error al cargar los datos de COBIT');
      }

      // Parsear respuestas
      const [dominiosData, objetivosData, herramientasData] = await Promise.all([
        dominiosRes.json(),
        objetivosRes.json(),
        herramientasRes.json()
      ]);

      setDominios(dominiosData);
      setObjetivos(objetivosData);
      setHerramientas(herramientasData);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error desconocido');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  return {
    dominios,
    objetivos,
    herramientas,
    loading,
    error,
    refetch: fetchData
  };
}

// Hook específico para obtener objetivos por dominio
export function useObjetivosByDominio(dominio?: string) {
  const [objetivos, setObjetivos] = useState<OGG[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!dominio) {
      setObjetivos([]);
      return;
    }

    const fetchObjetivos = async () => {
      try {
        setLoading(true);
        setError(null);

        const response = await fetch(`/api/cobit/objetivos?dominio=${encodeURIComponent(dominio)}`);
        if (!response.ok) {
          throw new Error('Error al cargar objetivos del dominio');
        }

        const data = await response.json();
        setObjetivos(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Error desconocido');
      } finally {
        setLoading(false);
      }
    };

    fetchObjetivos();
  }, [dominio]);

  return { objetivos, loading, error };
}
