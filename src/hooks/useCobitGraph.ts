import { useState, useEffect, useCallback, useMemo } from 'react';

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

export interface SelectedObjective {
  code: string;
  level: number;
}

export interface GraphFilters {
  dominio: string;
  objetivo: string[];
  herramienta: string;
}

export function useCobitGraph(
  filters: GraphFilters, 
  selectedObjectives?: SelectedObjective[]
): UseCobitGraphReturn {
  const [data, setData] = useState<GrafoData>({ nodes: [], links: [] });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Memoizar selectedObjectives para evitar recreaciones innecesarias
  const memoizedSelectedObjectives = useMemo(() => selectedObjectives, [
    selectedObjectives?.length,
    selectedObjectives?.map(obj => `${obj.code}:${obj.level}`).join(',')
  ]);

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      // Solo no cargar datos si hay objetivos específicos seleccionados pero están vacíos
      // o si estamos en modo de objetivos específicos sin nada seleccionado
      // const hasSelectedObjectives = selectedObjectives && selectedObjectives.length > 0;
      
      // Si se pasaron selectedObjectives (array vacío), significa que venimos del modo específico
      // pero no hay objetivos seleccionados, así que no mostrar nada
      if (memoizedSelectedObjectives !== undefined && memoizedSelectedObjectives.length === 0) {
        setData({ nodes: [], links: [] });
        setLoading(false);
        return;
      }

      // Construir parámetros de query
      const params = new URLSearchParams();
      if (filters.dominio) params.append('dominio', filters.dominio);
      if (filters.objetivo && filters.objetivo.length > 0) {
        filters.objetivo.forEach(obj => params.append('objetivo', obj));
      }
      if (filters.herramienta) params.append('herramienta', filters.herramienta);
      
      // Agregar objetivos seleccionados si existen
      if (memoizedSelectedObjectives && memoizedSelectedObjectives.length > 0) {
        memoizedSelectedObjectives.forEach((obj, index) => {
          params.append(`obj_${index}`, `${obj.code}:${obj.level}`);
        });
      }

      const response = await fetch(`/api/cobit/grafo?${params}`);
      
      if (!response.ok) {
        throw new Error('Error al cargar los datos del grafo');
      }

      const result = await response.json();
      setData(result);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error desconocido');
      setData({ nodes: [], links: [] });
    } finally {
      setLoading(false);
    }
  }, [filters.dominio, filters.objetivo, filters.herramienta, memoizedSelectedObjectives]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return {
    data,
    loading,
    error,
    refetch: fetchData
  };
}
