import { useEffect, useLayoutEffect } from 'react';

// Hook para usar useLayoutEffect en el cliente y useEffect en el servidor
// Esto evita problemas de hidratación
export const useIsomorphicLayoutEffect = typeof window !== 'undefined' 
  ? useLayoutEffect 
  : useEffect;
