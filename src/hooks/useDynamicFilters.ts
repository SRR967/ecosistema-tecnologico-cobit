import { useState, useEffect, useMemo, useCallback, useRef } from 'react';
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
  // Estados granulares para cada filtro
  loadingStates: {
    dominios: boolean;
    objetivos: boolean;
    herramientas: boolean;
  };
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
  
  // Estados de carga granulares
  const [loadingStates, setLoadingStates] = useState({
    dominios: false,
    objetivos: false,
    herramientas: false,
  });
  
  // Ref para el timeout del debounce
  const debounceTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  
  // Cache simple para evitar consultas repetidas
  const cacheRef = useRef<Map<string, { dominios: Dominio[]; objetivos: OGG[]; herramientas: Herramienta[] }>>(new Map());

  const fetchFilteredData = useCallback(async () => {
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
      
      // Crear clave de caché basada en los filtros
      const cacheKey = JSON.stringify({
        dominio: filters.dominio.sort(),
        objetivo: filters.objetivo.sort(),
        herramienta: filters.herramienta.sort()
      });
      
      // Verificar caché
      if (cacheRef.current.has(cacheKey)) {
        const cachedData = cacheRef.current.get(cacheKey);
        if (cachedData) {
          setFilteredDominios(cachedData.dominios);
          setFilteredObjetivos(cachedData.objetivos);
          setFilteredHerramientas(cachedData.herramientas);
          setLoading(false);
          return;
        }
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
      // pero con estados de carga individuales
      setLoadingStates({ dominios: true, objetivos: true, herramientas: true });
      
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
      const finalDominios = Array.isArray(dominiosData) ? dominiosData : [];
      const finalObjetivos = Array.isArray(objetivosData) ? objetivosData : [];
      const finalHerramientas = Array.isArray(herramientasData) ? herramientasData : [];
      
      setFilteredDominios(finalDominios);
      setFilteredObjetivos(finalObjetivos);
      setFilteredHerramientas(finalHerramientas);
      
      // Limpiar estados de carga individuales
      setLoadingStates({ dominios: false, objetivos: false, herramientas: false });
      
      // Guardar en caché (limitar tamaño del caché)
      if (cacheRef.current.size > 50) {
        const firstKey = cacheRef.current.keys().next().value;
        if (firstKey) {
          cacheRef.current.delete(firstKey);
        }
      }
      cacheRef.current.set(cacheKey, {
        dominios: finalDominios,
        objetivos: finalObjetivos,
        herramientas: finalHerramientas
      });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error desconocido');
      // Fallback a datos completos si hay error
      setFilteredDominios(Array.isArray(allDominios) ? allDominios : []);
      setFilteredObjetivos(Array.isArray(allObjetivos) ? allObjetivos : []);
      setFilteredHerramientas(Array.isArray(allHerramientas) ? allHerramientas : []);
    } finally {
      setLoading(false);
    }
  }, [filters.dominio, filters.objetivo, filters.herramienta, allDominios, allObjetivos, allHerramientas]);

  // Efecto para recalcular filtros cuando cambien los filtros o datos base (con debounce)
  useEffect(() => {
    // Limpiar timeout anterior
    if (debounceTimeoutRef.current) {
      clearTimeout(debounceTimeoutRef.current);
    }
    
    // Establecer nuevo timeout para debounce (300ms)
    debounceTimeoutRef.current = setTimeout(() => {
      fetchFilteredData();
    }, 300);
    
    // Cleanup function
    return () => {
      if (debounceTimeoutRef.current) {
        clearTimeout(debounceTimeoutRef.current);
      }
    };
  }, [filters.dominio, filters.objetivo, filters.herramienta, allDominios, allObjetivos, allHerramientas, fetchFilteredData]);

  // Memoizar resultados para evitar recálculos innecesarios
  const memoizedResults = useMemo(() => ({
    filteredDominios,
    filteredObjetivos,
    filteredHerramientas,
    loading,
    error,
    refetch: fetchFilteredData,
    loadingStates
  }), [filteredDominios, filteredObjetivos, filteredHerramientas, loading, error, loadingStates]);

  return memoizedResults;
}
