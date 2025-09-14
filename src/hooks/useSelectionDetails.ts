import { useState, useEffect, useMemo } from 'react';
import { OGG, Herramienta, Dominio } from '../lib/database';

interface SelectionDetails {
  objetivos: Array<{
    id: string;
    name: string;
    level: number;
    domain: string;
  }>;
  herramientas: Array<{
    id: string;
    name: string;
    category: string;
  }>;
  dominios: Array<{
    id: string;
    name: string;
  }>;
}

export function useSelectionDetails(
  allObjetivos: OGG[],
  allHerramientas: Herramienta[],
  allDominios: Dominio[],
  selectedObjetivos: string[],
  selectedHerramientas: string[],
  selectedDominios: string[]
): SelectionDetails {
  const [details, setDetails] = useState<SelectionDetails>({
    objetivos: [],
    herramientas: [],
    dominios: []
  });

  // Obtener detalles de objetivos seleccionados
  const objetivosDetails = useMemo(() => {
    const filtered = allObjetivos
      .filter(obj => selectedObjetivos.includes(obj.nombre))
      .map(obj => ({
        id: obj.id,
        name: obj.nombre,
        level: 0, // Los objetivos no tienen nivel de capacidad directo
        domain: obj.dominio_codigo || ''
      }));
    
    
    return filtered;
  }, [allObjetivos, selectedObjetivos]);

  // Obtener detalles de herramientas seleccionadas
  const herramientasDetails = useMemo(() => {
    const filtered = allHerramientas
      .filter(herramienta => selectedHerramientas.includes(herramienta.categoria))
      .map(herramienta => ({
        id: herramienta.id,
        name: herramienta.categoria,
        category: herramienta.categoria
      }));
    
    
    return filtered;
  }, [allHerramientas, selectedHerramientas]);

  // Obtener detalles de dominios seleccionados
  const dominiosDetails = useMemo(() => {
    const filtered = allDominios
      .filter(dominio => selectedDominios.includes(dominio.nombre))
      .map(dominio => ({
        id: dominio.codigo,
        name: dominio.nombre
      }));
    
    
    return filtered;
  }, [allDominios, selectedDominios]);

  // Actualizar detalles cuando cambien las selecciones
  useEffect(() => {
    setDetails({
      objetivos: objetivosDetails,
      herramientas: herramientasDetails,
      dominios: dominiosDetails
    });
  }, [objetivosDetails, herramientasDetails, dominiosDetails]);

  return details;
}
