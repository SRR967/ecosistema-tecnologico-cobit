import { useState, useEffect, useCallback } from 'react';
import { OGG, Herramienta, Dominio } from '../lib/database';

interface DynamicFilters {
  dominio: string[];
  objetivo: string[];
  herramienta: string[];
}

interface UseSimpleDynamicFiltersReturn {
  filteredDominios: Dominio[];
  filteredObjetivos: OGG[];
  filteredHerramientas: Herramienta[];
  loading: boolean;
  error: string | null;
  loadingStates: {
    dominios: boolean;
    objetivos: boolean;
    herramientas: boolean;
  };
}

export function useSimpleDynamicFilters(
  allDominios: Dominio[],
  allObjetivos: OGG[],
  allHerramientas: Herramienta[],
  filters: DynamicFilters
): UseSimpleDynamicFiltersReturn {
  const [filteredDominios, setFilteredDominios] = useState<Dominio[]>([]);
  const [filteredObjetivos, setFilteredObjetivos] = useState<OGG[]>([]);
  const [filteredHerramientas, setFilteredHerramientas] = useState<Herramienta[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loadingStates, setLoadingStates] = useState({
    dominios: false,
    objetivos: false,
    herramientas: false,
  });

  // Función para hacer fetch de datos filtrados
  const fetchFilteredData = useCallback(async () => {
    const hasActiveFilters = filters.dominio.length > 0 || 
                            filters.objetivo.length > 0 || 
                            filters.herramienta.length > 0;

    // Si no hay filtros activos, usar todos los datos
    if (!hasActiveFilters) {
      setFilteredDominios(allDominios);
      setFilteredObjetivos(allObjetivos);
      setFilteredHerramientas(allHerramientas);
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);
      setLoadingStates({ dominios: true, objetivos: true, herramientas: true });

      // Crear parámetros
      const params = new URLSearchParams();
      filters.dominio.forEach(dominio => params.append('dominio', dominio));
      filters.objetivo.forEach(objetivo => params.append('objetivo', objetivo));
      filters.herramienta.forEach(herramienta => params.append('herramienta', herramienta));

      // Hacer consultas en paralelo
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

      // Actualizar estados
      setFilteredDominios(Array.isArray(dominiosData) ? dominiosData : []);
      setFilteredObjetivos(Array.isArray(objetivosData) ? objetivosData : []);
      setFilteredHerramientas(Array.isArray(herramientasData) ? herramientasData : []);
      
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error desconocido');
      // Fallback a datos completos
      setFilteredDominios(allDominios);
      setFilteredObjetivos(allObjetivos);
      setFilteredHerramientas(allHerramientas);
    } finally {
      setLoading(false);
      setLoadingStates({ dominios: false, objetivos: false, herramientas: false });
    }
  }, [filters.dominio, filters.objetivo, filters.herramienta, allDominios, allObjetivos, allHerramientas]);

  // Efecto con debounce simple
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      fetchFilteredData();
    }, 300);

    return () => clearTimeout(timeoutId);
  }, [fetchFilteredData]);

  return {
    filteredDominios,
    filteredObjetivos,
    filteredHerramientas,
    loading,
    error,
    loadingStates,
  };
}
