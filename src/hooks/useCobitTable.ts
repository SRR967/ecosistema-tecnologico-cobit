import { useState, useEffect, useCallback, useMemo } from 'react';

export interface TablaCobitRow {
  objetivo_id: string;
  objetivo_nombre: string;
  practica_id: string;
  practica_nombre: string;
  actividad_id: string;
  actividad_descripcion: string;
  nivel_capacidad: number;
  herramienta_id: string;
  herramienta_nombre?: string;
  herramienta_categoria?: string;
  justificacion: string;
  observaciones?: string;
  integracion?: string;
}

export interface UseCobitTableReturn {
  data: TablaCobitRow[];
  loading: boolean;
  error: string | null;
  total: number;
  refetch: () => Promise<void>;
}

export interface SelectedObjective {
  code: string;
  level: number;
}

export interface TableFilters {
  dominio: string;
  objetivo: string[];
  herramienta: string;
}

export function useCobitTable(
  filters: TableFilters,
  selectedObjectives?: SelectedObjective[]
): UseCobitTableReturn {
  const [data, setData] = useState<TablaCobitRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [total, setTotal] = useState(0);

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
        setData([]);
        setTotal(0);
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

      const response = await fetch(`/api/cobit/tabla?${params}`);
      
      if (!response.ok) {
        throw new Error('Error al cargar los datos de la tabla');
      }

      const result = await response.json();
      setData(result.data || []);
      setTotal(result.total || 0);
    } catch (err) {
      console.error('Error al cargar tabla COBIT:', err);
      setError(err instanceof Error ? err.message : 'Error desconocido');
      setData([]);
      setTotal(0);
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
    total,
    refetch: fetchData
  };
}
