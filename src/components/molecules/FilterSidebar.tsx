"use client";

import FilterSelect from "../atoms/FilterSelect";
import ToggleButtonGroup from "../atoms/ToggleButtonGroup";
import { useCobitData } from "../../hooks/useCobitData";

interface FilterSidebarProps {
  filters: {
    dominio: string;
    objetivo: string;
    herramienta: string;
  };
  onFilterChange: (
    filterType: "dominio" | "objetivo" | "herramienta",
    value: string
  ) => void;
  viewMode: "grafico" | "lista";
  onViewModeChange: (mode: "grafico" | "lista") => void;
  className?: string;
}

export default function FilterSidebar({
  filters,
  onFilterChange,
  viewMode,
  onViewModeChange,
  className = "",
}: FilterSidebarProps) {
  // Cargar datos desde la base de datos
  const { dominios, objetivos, herramientas, loading, error } = useCobitData();

  // Transformar datos para los selectores
  const dominioOptions = dominios.map(
    (dominio) => `${dominio.code} - ${dominio.name}`
  );

  const objetivoOptions = objetivos.map((objetivo) => objetivo.id);

  const herramientaOptions = herramientas.map((herramienta) => herramienta.id);

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
    <div className={`w-80 p-6 ${className}`}>
      <div className="space-y-6">
        {/* Título */}
        <h2
          className="text-2xl font-bold"
          style={{ color: "var(--cobit-blue)" }}
        >
          Filtros
        </h2>

        {/* Filtros */}
        <div className="space-y-4">
          <FilterSelect
            label="Dominio"
            options={dominioOptions}
            value={filters.dominio}
            onChange={(value) => onFilterChange("dominio", value)}
          />

          <FilterSelect
            label="Objetivo"
            options={objetivoOptions}
            value={filters.objetivo}
            onChange={(value) => onFilterChange("objetivo", value)}
          />

          <FilterSelect
            label="Herramienta"
            options={herramientaOptions}
            value={filters.herramienta}
            onChange={(value) => onFilterChange("herramienta", value)}
          />
        </div>

        {/* Separador */}
        <div className="border-t border-gray-200 pt-4">
          <ToggleButtonGroup
            label="Vista"
            options={[
              { value: "grafico", label: "Gráfico" },
              { value: "lista", label: "Lista" },
            ]}
            selectedValue={viewMode}
            onChange={onViewModeChange}
          />
        </div>
      </div>
    </div>
  );
}
