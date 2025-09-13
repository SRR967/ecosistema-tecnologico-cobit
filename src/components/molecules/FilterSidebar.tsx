"use client";

import FilterSelect from "../atoms/FilterSelect";
import MultiSelect from "../atoms/MultiSelect";
import ToggleButtonGroup from "../atoms/ToggleButtonGroup";
import { useCobitData } from "../../hooks/useCobitData";
// import { Dominio } from "../../lib/database"; // Comentado temporalmente
import { useState, useEffect, useMemo } from "react";

interface SelectedObjective {
  code: string;
  level: number;
}

interface FilterSidebarProps {
  filters: {
    dominio: string;
    objetivo: string[];
    herramienta: string;
  };
  onFilterChange: (
    filterType: "dominio" | "objetivo" | "herramienta",
    value: string | string[]
  ) => void;
  onClearFilters: () => void;
  viewMode: "grafico" | "lista";
  onViewModeChange: (mode: "grafico" | "lista") => void;
  className?: string;
  // Props opcionales para modo específico
  selectedObjectives?: SelectedObjective[];
  onBackToNormal?: () => void;
  isSpecificMode?: boolean;
}

export default function FilterSidebar({
  filters,
  onFilterChange,
  onClearFilters,
  viewMode,
  onViewModeChange,
  className = "",
  selectedObjectives = [],
  onBackToNormal,
  isSpecificMode = false,
}: FilterSidebarProps) {
  // Cargar datos desde la base de datos
  const { dominios, objetivos, herramientas, loading, error } = useCobitData();

  // Estado para herramientas filtradas en modo específico
  const [herramientasFiltradas, setHerramientasFiltradas] = useState<
    Array<{ id: string; categoria: string }>
  >([]);

  // Memoizar selectedObjectives para evitar recreaciones innecesarias
  const memoizedSelectedObjectives = useMemo(
    () => selectedObjectives,
    [
      selectedObjectives?.length,
      selectedObjectives?.map((obj) => `${obj.code}:${obj.level}`).join(","),
    ]
  );

  // Memoizar herramientas para evitar recreaciones innecesarias
  const memoizedHerramientas = useMemo(
    () => herramientas,
    [
      herramientas?.length,
      herramientas?.map((h) => `${h.id}:${h.categoria}`).join(","),
    ]
  );

  // Efecto para cargar herramientas filtradas en modo específico
  useEffect(() => {
    if (isSpecificMode && memoizedSelectedObjectives.length > 0) {
      // Crear parámetros para la API igual que en useCobitTable
      const params = new URLSearchParams();
      memoizedSelectedObjectives.forEach((obj, index) => {
        params.append(`obj_${index}`, `${obj.code}:${obj.level}`);
      });

      // Llamar a la API de herramientas filtradas
      fetch(`/api/cobit/herramientas-filtradas?${params.toString()}`)
        .then((response) => response.json())
        .then((data) => {
          if (data.success) {
            setHerramientasFiltradas(data.herramientas);
          }
        })
        .catch((error) => {
          // Fallback: usar todas las herramientas
          setHerramientasFiltradas(
            memoizedHerramientas.map((h) => ({
              id: h.id,
              categoria: h.categoria,
            }))
          );
        });
    } else {
      // En modo normal, usar todas las herramientas
      setHerramientasFiltradas(
        memoizedHerramientas.map((h) => ({ id: h.id, categoria: h.categoria }))
      );
    }
  }, [isSpecificMode, memoizedSelectedObjectives, memoizedHerramientas]);

  // En modo específico, filtrar las opciones según los objetivos seleccionados
  const filteredDominios = isSpecificMode
    ? dominios.filter(
        (dominio) =>
          dominio &&
          dominio.codigo &&
          memoizedSelectedObjectives.some((obj) =>
            obj.code.startsWith(dominio.codigo)
          )
      )
    : dominios.filter((dominio) => dominio && dominio.codigo && dominio.nombre);

  const filteredObjetivos = isSpecificMode
    ? objetivos.filter(
        (objetivo) =>
          objetivo &&
          objetivo.id &&
          memoizedSelectedObjectives.some((obj) => obj.code === objetivo.id)
      )
    : objetivos.filter((objetivo) => objetivo && objetivo.id);

  // En modo específico, usar herramientas filtradas
  const filteredHerramientas = isSpecificMode
    ? herramientasFiltradas.filter((h) => h && h.id)
    : herramientas.filter((h) => h && h.id);

  // Debug: verificar datos de dominios
  console.log("Debug dominios:", {
    dominios,
    filteredDominios,
    loading,
    error,
    isSpecificMode,
  });

  // Transformar datos para los selectores (ya filtrados arriba)
  const dominioOptions = filteredDominios.map(
    (dominio) => `${dominio.codigo} - ${dominio.nombre}`
  );
  const objetivoOptions = filteredObjetivos.map((objetivo) => objetivo.id);
  const herramientaOptions = filteredHerramientas.map(
    (herramienta) => herramienta.id
  );

  // Detectar si hay filtros activos
  const hasActiveFilters = Object.entries(filters).some(([key, filter]) => {
    if (key === "objetivo") {
      return Array.isArray(filter) && filter.length > 0;
    }
    return filter !== "";
  });

  // Mostrar estado de carga
  if (loading) {
    return (
      <div className={`w-80 p-6 ${className}`}>
        <div className="space-y-6">
          <h2
            className="text-2xl font-bold"
            style={{ color: "var(--cobit-blue)" }}
          >
            Filtros
          </h2>
          <div className="flex items-center justify-center py-8">
            <div className="text-center">
              <div
                className="animate-spin rounded-full h-8 w-8 border-b-2 mx-auto mb-2"
                style={{ borderColor: "var(--cobit-blue)" }}
              ></div>
              <p className="text-gray-600 b1">Cargando datos...</p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Mostrar error si ocurre
  if (error) {
    return (
      <div className={`w-80 p-6 ${className}`}>
        <div className="space-y-6">
          <h2
            className="text-2xl font-bold"
            style={{ color: "var(--cobit-blue)" }}
          >
            Filtros
          </h2>
          <div className="text-center py-8">
            <div className="text-red-500 mb-2">⚠️</div>
            <p className="text-red-600 b1">{error}</p>
            <button
              onClick={() => window.location.reload()}
              className="mt-2 px-4 py-2 text-sm rounded-md"
              style={{ backgroundColor: "var(--cobit-blue)", color: "white" }}
            >
              Reintentar
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className={`w-80 h-full flex flex-col ${className}`}>
      <div className="flex-1 overflow-y-auto p-6">
        <div className="space-y-6">
          {/* Título con indicador y botón de limpiar */}
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              {/* Botón volver (solo en modo específico) */}
              {isSpecificMode && onBackToNormal && (
                <button
                  onClick={onBackToNormal}
                  className="p-2 text-gray-600 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors"
                  title="Volver a vista normal"
                >
                  <svg
                    className="w-5 h-5"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M10 19l-7-7m0 0l7-7m-7 7h18"
                    />
                  </svg>
                </button>
              )}
              <h2
                className={
                  isSpecificMode ? "text-xl font-bold" : "text-2xl font-bold"
                }
                style={{ color: "var(--cobit-blue)" }}
              >
                {isSpecificMode ? "Ecosistema Filtrado" : "Filtros"}
              </h2>
              {hasActiveFilters && (
                <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                  {
                    Object.entries(filters).filter(([key, f]) => {
                      if (key === "objetivo") {
                        return Array.isArray(f) && f.length > 0;
                      }
                      return f !== "";
                    }).length
                  }
                </span>
              )}
            </div>

            {!isSpecificMode && hasActiveFilters && (
              <button
                onClick={onClearFilters}
                className="flex items-center space-x-1 px-3 py-1.5 text-sm text-gray-600 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
                title="Limpiar todos los filtros"
              >
                <svg
                  className="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
                <span>Limpiar</span>
              </button>
            )}
          </div>

          {/* Objetivos seleccionados (solo en modo específico) */}
          {isSpecificMode && memoizedSelectedObjectives.length > 0 && (
            <div className="bg-blue-50 p-4 rounded-lg">
              <h3 className="text-sm font-semibold text-blue-800 mb-2">
                Objetivos Seleccionados:
              </h3>
              <div className="space-y-1">
                {memoizedSelectedObjectives.map((obj, index) => (
                  <div key={index} className="flex justify-between text-sm">
                    <span className="text-blue-700 font-medium">
                      {obj.code}
                    </span>
                    <span className="text-blue-600">Nivel {obj.level}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Sección de filtros con título condicional */}
          {isSpecificMode && (
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <h3
                  className="text-lg font-semibold"
                  style={{ color: "var(--cobit-blue)" }}
                >
                  Filtros Adicionales
                </h3>
                {hasActiveFilters && (
                  <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                    {
                      Object.entries(filters).filter(([key, f]) => {
                        if (key === "objetivo") {
                          return Array.isArray(f) && f.length > 0;
                        }
                        return f !== "";
                      }).length
                    }
                  </span>
                )}
              </div>

              {hasActiveFilters && (
                <button
                  onClick={onClearFilters}
                  className="flex items-center space-x-1 px-3 py-1.5 text-sm text-gray-600 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
                  title="Limpiar filtros adicionales"
                >
                  <svg
                    className="w-4 h-4"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                  <span>Limpiar</span>
                </button>
              )}
            </div>
          )}

          {/* Filtros */}
          <div className="space-y-4">
            {dominioOptions.length > 0 ? (
              <FilterSelect
                label="Dominio"
                options={dominioOptions}
                value={filters.dominio}
                onChange={(value) => onFilterChange("dominio", value)}
              />
            ) : (
              <div className="space-y-2">
                <label
                  className="block text-sm font-medium"
                  style={{ color: "var(--cobit-blue)" }}
                >
                  Dominio
                </label>
                <div className="text-sm text-gray-500">
                  {loading
                    ? "Cargando dominios..."
                    : "No hay dominios disponibles"}
                </div>
              </div>
            )}

            <MultiSelect
              label="Objetivo"
              options={objetivoOptions}
              selectedValues={filters.objetivo}
              onChange={(values) => onFilterChange("objetivo", values)}
              placeholder="Seleccionar objetivos"
            />

            <FilterSelect
              label="Herramienta"
              options={herramientaOptions}
              value={filters.herramienta}
              onChange={(value) => onFilterChange("herramienta", value)}
            />
          </div>

          {/* Información de datos filtrados (solo en modo específico) */}
          {isSpecificMode && (
            <div className="bg-gray-50 p-3 rounded-md text-sm text-gray-600">
              <div className="space-y-1">
                <div>• {filteredDominios.length} dominio(s) disponible(s)</div>
                <div>
                  • {filteredObjetivos.length} objetivo(s) seleccionado(s)
                </div>
                <div>
                  • {filteredHerramientas.length} herramienta(s) relacionada(s)
                </div>
              </div>
            </div>
          )}

          {/* Separador */}
          <div className="border-t border-gray-200 pt-4">
            <ToggleButtonGroup
              label="Vista"
              options={[
                { value: "grafico", label: "Gráfico" },
                { value: "lista", label: "Lista" },
              ]}
              selectedValue={viewMode}
              onChange={(value) =>
                onViewModeChange(value as "grafico" | "lista")
              }
            />
          </div>
        </div>
      </div>
    </div>
  );
}
