import { useState, useEffect, useCallback, useRef } from 'react';
import { OGG, Herramienta, Dominio } from '../lib/database';

interface DynamicFilters {
  dominio: string[];
  objetivo: string[];
  herramienta: string[];
}

interface UseSelectiveDynamicFiltersReturn {
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
  updateFilter: (filterType: 'dominios' | 'objetivos' | 'herramientas') => Promise<void>;
}

export function useSelectiveDynamicFilters(
  allDominios: Dominio[],
  allObjetivos: OGG[],
  allHerramientas: Herramienta[],
  filters: DynamicFilters
): UseSelectiveDynamicFiltersReturn {
  const [filteredDominios, setFilteredDominios] = useState<Dominio[]>(allDominios);
  const [filteredObjetivos, setFilteredObjetivos] = useState<OGG[]>(allObjetivos);
  const [filteredHerramientas, setFilteredHerramientas] = useState<Herramienta[]>(allHerramientas);
  const [loading] = useState(false);
  const [error] = useState<string | null>(null);
  const [loadingStates, setLoadingStates] = useState({
    dominios: false,
    objetivos: false,
    herramientas: false,
  });

  // Ref para evitar actualizaciones innecesarias
  const lastFiltersRef = useRef<DynamicFilters>(filters);
  const debounceTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  // Función para actualizar solo un tipo de filtro específico
  const updateFilter = useCallback(async (filterType: 'dominios' | 'objetivos' | 'herramientas') => {
    const hasActiveFilters = filters.dominio.length > 0 || 
                            filters.objetivo.length > 0 || 
                            filters.herramienta.length > 0;

    // Si no hay filtros activos, usar todos los datos
    if (!hasActiveFilters) {
      if (filterType === 'dominios') setFilteredDominios(allDominios);
      if (filterType === 'objetivos') setFilteredObjetivos(allObjetivos);
      if (filterType === 'herramientas') setFilteredHerramientas(allHerramientas);
      return;
    }

    try {
      setLoadingStates(prev => ({ ...prev, [filterType]: true }));

      // Crear parámetros
      const params = new URLSearchParams();
      filters.dominio.forEach(dominio => params.append('dominio', dominio));
      filters.objetivo.forEach(objetivo => params.append('objetivo', objetivo));
      filters.herramienta.forEach(herramienta => params.append('herramienta', herramienta));

      // Hacer consulta específica
      const endpoint = filterType === 'herramientas' 
        ? '/api/cobit/herramientas-filtradas'
        : `/api/cobit/${filterType}-filtrados`;
      
      
      const response = await fetch(`${endpoint}?${params.toString()}`);

      if (!response.ok) {
        throw new Error(`Error al cargar ${filterType}`);
      }

      const data = await response.json();
      
      // Extraer datos según el tipo de filtro
      let result;
      if (filterType === 'herramientas') {
        result = data.success ? data.herramientas : data;
      } else {
        result = data.success ? data[filterType] : data;
      }

      // Actualizar solo el tipo específico
      if (filterType === 'dominios') {
        setFilteredDominios(Array.isArray(result) ? result : []);
      } else if (filterType === 'objetivos') {
        setFilteredObjetivos(Array.isArray(result) ? result : []);
      } else if (filterType === 'herramientas') {
        setFilteredHerramientas(Array.isArray(result) ? result : []);
      }

    } catch (err) {
      console.error(`Error updating ${filterType}:`, err);
      // Fallback a datos completos para este tipo
      if (filterType === 'dominios') setFilteredDominios(allDominios);
      if (filterType === 'objetivos') setFilteredObjetivos(allObjetivos);
      if (filterType === 'herramientas') setFilteredHerramientas(allHerramientas);
    } finally {
      setLoadingStates(prev => ({ ...prev, [filterType]: false }));
    }
  }, [filters, allDominios, allObjetivos, allHerramientas]);

  // Función para determinar qué filtros necesitan actualización
  const getFiltersToUpdate = useCallback((oldFilters: DynamicFilters, newFilters: DynamicFilters) => {
    const toUpdate: ('dominios' | 'objetivos' | 'herramientas')[] = [];

    // Si cambió dominio, actualizar objetivos y herramientas
    if (JSON.stringify(oldFilters.dominio) !== JSON.stringify(newFilters.dominio)) {
      toUpdate.push('objetivos', 'herramientas');
    }

    // Si cambió objetivo, actualizar dominios y herramientas
    if (JSON.stringify(oldFilters.objetivo) !== JSON.stringify(newFilters.objetivo)) {
      toUpdate.push('dominios', 'herramientas');
    }

    // Si cambió herramienta, actualizar dominios y objetivos
    if (JSON.stringify(oldFilters.herramienta) !== JSON.stringify(newFilters.herramienta)) {
      toUpdate.push('dominios', 'objetivos');
    }

    // Eliminar duplicados
    return [...new Set(toUpdate)];
  }, []);

  // Efecto para inicializar datos cuando no hay filtros
  useEffect(() => {
    const hasActiveFilters = filters.dominio.length > 0 || 
                            filters.objetivo.length > 0 || 
                            filters.herramienta.length > 0;

    if (!hasActiveFilters) {
      setFilteredDominios(allDominios);
      setFilteredObjetivos(allObjetivos);
      setFilteredHerramientas(allHerramientas);
    }
  }, [allDominios, allObjetivos, allHerramientas, filters.dominio.length, filters.objetivo.length, filters.herramienta.length]);

  // Efecto principal con debounce inteligente
  useEffect(() => {
    // Limpiar timeout anterior
    if (debounceTimeoutRef.current) {
      clearTimeout(debounceTimeoutRef.current);
    }

    // Verificar si realmente cambiaron los filtros
    const filtersChanged = JSON.stringify(lastFiltersRef.current) !== JSON.stringify(filters);
    
    if (!filtersChanged) {
      return;
    }

    // Determinar qué necesita actualizarse
    const filtersToUpdate = getFiltersToUpdate(lastFiltersRef.current, filters);
    
    if (filtersToUpdate.length === 0) {
      return;
    }

    // Actualizar referencia
    lastFiltersRef.current = filters;

    // Debounce para evitar actualizaciones excesivas
    debounceTimeoutRef.current = setTimeout(() => {
      // Actualizar solo los filtros necesarios
      filtersToUpdate.forEach(filterType => {
        updateFilter(filterType);
      });
    }, 150); // Debounce más corto para mejor responsividad

    return () => {
      if (debounceTimeoutRef.current) {
        clearTimeout(debounceTimeoutRef.current);
      }
    };
  }, [filters, getFiltersToUpdate, updateFilter]);

  return {
    filteredDominios,
    filteredObjetivos,
    filteredHerramientas,
    loading,
    error,
    loadingStates,
    updateFilter,
  };
}
