// Sistema de caché simple en memoria para optimizar consultas frecuentes

interface CacheEntry<T> {
  data: T;
  timestamp: number;
  ttl: number; // Time to live en milisegundos
}

export class SimpleCache {
  private cache = new Map<string, CacheEntry<unknown>>();
  private maxSize = 100; // Máximo número de entradas en caché
  private defaultTTL = 5 * 60 * 1000; // 5 minutos por defecto

  set<T>(key: string, data: T, ttl?: number): void {
    // Limpiar entradas expiradas
    this.cleanup();
    
    // Si el caché está lleno, eliminar la entrada más antigua
    if (this.cache.size >= this.maxSize) {
      const oldestKey = this.cache.keys().next().value;
      if (oldestKey) {
        this.cache.delete(oldestKey);
      }
    }

    this.cache.set(key, {
      data,
      timestamp: Date.now(),
      ttl: ttl || this.defaultTTL
    });
  }

  get<T>(key: string): T | null {
    const entry = this.cache.get(key);
    
    if (!entry) {
      return null;
    }

    // Verificar si la entrada ha expirado
    if (Date.now() - entry.timestamp > entry.ttl) {
      this.cache.delete(key);
      return null;
    }

    return entry.data as T;
  }

  has(key: string): boolean {
    const entry = this.cache.get(key);
    
    if (!entry) {
      return false;
    }

    // Verificar si la entrada ha expirado
    if (Date.now() - entry.timestamp > entry.ttl) {
      this.cache.delete(key);
      return false;
    }

    return true;
  }

  delete(key: string): boolean {
    return this.cache.delete(key);
  }

  clear(): void {
    this.cache.clear();
  }

  private cleanup(): void {
    const now = Date.now();
    for (const [key, entry] of this.cache.entries()) {
      if (now - entry.timestamp > entry.ttl) {
        this.cache.delete(key);
      }
    }
  }

  // Generar clave de caché basada en parámetros
  static generateKey(prefix: string, params: Record<string, unknown>): string {
    const sortedParams = Object.keys(params)
      .sort()
      .map(key => `${key}=${JSON.stringify(params[key])}`)
      .join('&');
    
    return `${prefix}:${sortedParams}`;
  }
}

// Instancia global del caché
export const cache = new SimpleCache();

// Funciones helper para tipos específicos
export const cacheHelpers = {
  // Caché para consultas de filtrado (TTL más corto)
  setFilteredData: <T>(key: string, data: T) => {
    cache.set(key, data, 2 * 60 * 1000); // 2 minutos
  },
  
  // Caché para datos estáticos (TTL más largo)
  setStaticData: <T>(key: string, data: T) => {
    cache.set(key, data, 30 * 60 * 1000); // 30 minutos
  },
  
  // Caché para consultas de grafo (TTL medio)
  setGraphData: <T>(key: string, data: T) => {
    cache.set(key, data, 5 * 60 * 1000); // 5 minutos
  }
};
