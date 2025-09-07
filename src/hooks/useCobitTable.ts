import { useState, useEffect } from 'react';

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

export interface TableFilters {
  dominio: string;
  objetivo: string;
  herramienta: string;
}

export function useCobitTable(filters: TableFilters): UseCobitTableReturn {
  const [data, setData] = useState<TablaCobitRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [total, setTotal] = useState(0);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Construir parámetros de query
      const params = new URLSearchParams();
      if (filters.dominio) params.append('dominio', filters.dominio);
      if (filters.objetivo) params.append('objetivo', filters.objetivo);
      if (filters.herramienta) params.append('herramienta', filters.herramienta);

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
  };

  useEffect(() => {
    fetchData();
  }, [filters.dominio, filters.objetivo, filters.herramienta]);

  return {
    data,
    loading,
    error,
    total,
    refetch: fetchData
  };
}
