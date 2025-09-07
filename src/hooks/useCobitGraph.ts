import { useState, useEffect } from 'react';

export interface GrafoNode {
  id: string;
  name: string;
  type: 'objetivo' | 'herramienta';
  domain?: string;
  category?: string;
  description?: string;
  toolType?: string;
}

export interface GrafoLink {
  source: string;
  target: string;
  count: number;
}

export interface GrafoData {
  nodes: GrafoNode[];
  links: GrafoLink[];
}

export interface UseCobitGraphReturn {
  data: GrafoData;
  loading: boolean;
  error: string | null;
  refetch: () => Promise<void>;
}

export interface GraphFilters {
  dominio: string;
  herramienta: string;
}

export function useCobitGraph(filters: GraphFilters): UseCobitGraphReturn {
  const [data, setData] = useState<GrafoData>({ nodes: [], links: [] });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Construir parámetros de query
      const params = new URLSearchParams();
      if (filters.dominio) params.append('dominio', filters.dominio);
      if (filters.herramienta) params.append('herramienta', filters.herramienta);

      const response = await fetch(`/api/cobit/grafo?${params}`);
      
      if (!response.ok) {
        throw new Error('Error al cargar los datos del grafo');
      }

      const result = await response.json();
      setData(result);
    } catch (err) {
      console.error('Error al cargar grafo COBIT:', err);
      setError(err instanceof Error ? err.message : 'Error desconocido');
      setData({ nodes: [], links: [] });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [filters.dominio, filters.herramienta]);

  return {
    data,
    loading,
    error,
    refetch: fetchData
  };
}
