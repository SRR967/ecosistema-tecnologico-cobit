import { useEffect, useRef } from 'react';

// Hook para pre-cargar datos en segundo plano
export function usePreloadData() {
  const preloadCache = useRef<Map<string, any>>(new Map());
  const preloadPromises = useRef<Map<string, Promise<any>>>(new Map());

  // Función para pre-cargar datos
  const preload = async (key: string, fetchFn: () => Promise<any>) => {
    // Si ya está en caché, no hacer nada
    if (preloadCache.current.has(key)) {
      return preloadCache.current.get(key);
    }

    // Si ya hay una promesa en curso, esperarla
    if (preloadPromises.current.has(key)) {
      return preloadPromises.current.get(key);
    }

    // Crear nueva promesa de pre-carga
    const promise = fetchFn().then(data => {
      preloadCache.current.set(key, data);
      preloadPromises.current.delete(key);
      return data;
    }).catch(error => {
      preloadPromises.current.delete(key);
      throw error;
    });

    preloadPromises.current.set(key, promise);
    return promise;
  };

  // Función para obtener datos pre-cargados
  const getPreloadedData = (key: string) => {
    return preloadCache.current.get(key);
  };

  // Función para limpiar caché
  const clearCache = () => {
    preloadCache.current.clear();
    preloadPromises.current.clear();
  };

  // Pre-cargar datos comunes cuando el componente se monta
  useEffect(() => {
    // Pre-cargar datos de dominios
    preload('dominios', async () => {
      const response = await fetch('/api/cobit/dominios');
      return response.json();
    });

    // Pre-cargar datos de objetivos
    preload('objetivos', async () => {
      const response = await fetch('/api/cobit/objetivos');
      return response.json();
    });

    // Pre-cargar datos de herramientas
    preload('herramientas', async () => {
      const response = await fetch('/api/cobit/herramientas');
      return response.json();
    });
  }, []);

  return {
    preload,
    getPreloadedData,
    clearCache
  };
}
