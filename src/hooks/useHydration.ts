import { useEffect, useState } from 'react';

// Hook para detectar si el componente ya se hidrató
// Útil para evitar problemas de hidratación con contenido que difiere entre servidor y cliente
export function useHydration() {
  const [isHydrated, setIsHydrated] = useState(false);

  useEffect(() => {
    setIsHydrated(true);
  }, []);

  return isHydrated;
}
