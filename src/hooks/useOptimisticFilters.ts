import { useState, useCallback } from 'react';

// Hook para manejar actualizaciones optimistas en filtros
export function useOptimisticFilters<T>(
  initialFilters: T,
  onFilterChange: (filters: T) => void,
  debounceMs: number = 300
) {
  const [optimisticFilters, setOptimisticFilters] = useState<T>(initialFilters);
  const [isUpdating, setIsUpdating] = useState(false);

  // Función para actualizar filtros de manera optimista
  const updateFilters = useCallback((newFilters: T) => {
    // Actualización optimista inmediata
    setOptimisticFilters(newFilters);
    setIsUpdating(true);

    // Debounce para la actualización real
    const timeoutId = setTimeout(() => {
      onFilterChange(newFilters);
      setIsUpdating(false);
    }, debounceMs);

    return () => clearTimeout(timeoutId);
  }, [onFilterChange, debounceMs]);

  // Función para actualizar un filtro específico
  const updateFilter = useCallback(<K extends keyof T>(
    key: K,
    value: T[K]
  ) => {
    const newFilters = {
      ...optimisticFilters,
      [key]: value
    };
    updateFilters(newFilters);
  }, [optimisticFilters, updateFilters]);

  return {
    filters: optimisticFilters,
    isUpdating,
    updateFilters,
    updateFilter,
    setOptimisticFilters
  };
}
