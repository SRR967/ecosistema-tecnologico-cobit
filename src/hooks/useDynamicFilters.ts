import { useState, useEffect, useMemo } from 'react';
import { OGG, Herramienta, Dominio } from '../lib/database';

interface DynamicFilters {
  dominio: string[];
  objetivo: string[];
  herramienta: string[];
}

interface UseDynamicFiltersReturn {
  filteredDominios: Dominio[];
  filteredObjetivos: OGG[];
  filteredHerramientas: Herramienta[];
  loading: boolean;
  error: string | null;
  refetch: () => Promise<void>;
}

export function useDynamicFilters(
  allDominios: Dominio[],
  allObjetivos: OGG[],
  allHerramientas: Herramienta[],
  filters: DynamicFilters
): UseDynamicFiltersReturn {
  const [filteredDominios, setFilteredDominios] = useState<Dominio[]>([]);
  const [filteredObjetivos, setFilteredObjetivos] = useState<OGG[]>([]);
  const [filteredHerramientas, setFilteredHerramientas] = useState<Herramienta[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchFilteredData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Verificar si hay filtros activos
      const hasActiveFilters = filters.dominio.length > 0 || 
                              filters.objetivo.length > 0 || 
                              filters.herramienta.length > 0;

      // Si no hay filtros activos, usar todos los datos
      if (!hasActiveFilters) {
        setFilteredDominios(Array.isArray(allDominios) ? allDominios : []);
        setFilteredObjetivos(Array.isArray(allObjetivos) ? allObjetivos : []);
        setFilteredHerramientas(Array.isArray(allHerramientas) ? allHerramientas : []);
        setLoading(false);
        return;
      }

      // Crear parámetros para las consultas solo si hay filtros
      const params = new URLSearchParams();
      
      // Agregar filtros de dominio
      filters.dominio.forEach(dominio => {
        params.append('dominio', dominio);
      });
      
      // Agregar filtros de objetivo
      filters.objetivo.forEach(objetivo => {
        params.append('objetivo', objetivo);
      });
      
      // Agregar filtros de herramienta
      filters.herramienta.forEach(herramienta => {
        params.append('herramienta', herramienta);
      });

      // Hacer consultas en paralelo para obtener datos filtrados
      const [dominiosRes, objetivosRes, herramientasRes] = await Promise.all([
        fetch(`/api/cobit/dominios-filtrados?${params.toString()}`),
        fetch(`/api/cobit/objetivos-filtrados?${params.toString()}`),
        fetch(`/api/cobit/herramientas-filtradas?${params.toString()}`)
      ]);

      // Verificar respuestas
      if (!dominiosRes.ok || !objetivosRes.ok || !herramientasRes.ok) {
        throw new Error('Error al cargar datos filtrados');
      }

      // Parsear respuestas
      const [dominiosData, objetivosData, herramientasResponse] = await Promise.all([
        dominiosRes.json(),
        objetivosRes.json(),
        herramientasRes.json()
      ]);

      // Extraer herramientas del formato de respuesta
      const herramientasData = herramientasResponse.success 
        ? herramientasResponse.herramientas 
        : herramientasResponse;

      // Asegurar que siempre sean arrays
      setFilteredDominios(Array.isArray(dominiosData) ? dominiosData : []);
      setFilteredObjetivos(Array.isArray(objetivosData) ? objetivosData : []);
      setFilteredHerramientas(Array.isArray(herramientasData) ? herramientasData : []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error desconocido');
      // Fallback a datos completos si hay error
      setFilteredDominios(Array.isArray(allDominios) ? allDominios : []);
      setFilteredObjetivos(Array.isArray(allObjetivos) ? allObjetivos : []);
      setFilteredHerramientas(Array.isArray(allHerramientas) ? allHerramientas : []);
    } finally {
      setLoading(false);
    }
  };

  // Efecto para recalcular filtros cuando cambien los filtros o datos base
  useEffect(() => {
    fetchFilteredData();
  }, [filters.dominio, filters.objetivo, filters.herramienta, allDominios, allObjetivos, allHerramientas]);

  // Memoizar resultados para evitar recálculos innecesarios
  const memoizedResults = useMemo(() => ({
    filteredDominios,
    filteredObjetivos,
    filteredHerramientas,
    loading,
    error,
    refetch: fetchFilteredData
  }), [filteredDominios, filteredObjetivos, filteredHerramientas, loading, error]);

  return memoizedResults;
}
