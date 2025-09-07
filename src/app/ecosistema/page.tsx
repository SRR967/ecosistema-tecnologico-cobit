"use client";

import { useState } from "react";
import NavBar from "../../components/organisms/NavBar";
import FilterSidebar from "../../components/molecules/FilterSidebar";

export default function EcosistemaPage() {
  const [filters, setFilters] = useState({
    dominio: "",
    objetivo: "",
    herramienta: "",
  });

  const [viewMode, setViewMode] = useState<"grafico" | "lista">("grafico");

  const handleFilterChange = (
    filterType: "dominio" | "objetivo" | "herramienta",
    value: string
  ) => {
    setFilters((prev) => ({
      ...prev,
      [filterType]: value,
    }));
  };

  const handleViewModeChange = (mode: "grafico" | "lista") => {
    setViewMode(mode);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <NavBar currentPath="/ecosistema" />

      <div className="flex">
        {/* Sidebar */}
        <FilterSidebar
          filters={filters}
          onFilterChange={handleFilterChange}
          viewMode={viewMode}
          onViewModeChange={handleViewModeChange}
        />

        {/* Main Content */}
        <div className="flex-1 p-8">
          <div className="max-w-6xl mx-auto">
            <h1
              className="text-4xl font-bold mb-8"
              style={{ color: "var(--cobit-blue)" }}
            >
              Ecosistema COBIT 2019
            </h1>

            {/* Contenido basado en el modo de vista */}
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
              {viewMode === "lista" ? (
                <div>
                  <h2
                    className="text-2xl font-bold mb-4"
                    style={{ color: "var(--cobit-blue)" }}
                  >
                    Vista de Lista
                  </h2>
                  <p className="b1 text-gray-700">
                    Aquí se mostrará la vista de lista del ecosistema filtrado.
                  </p>

                  {/* Información de filtros activos */}
                  {(filters.dominio ||
                    filters.objetivo ||
                    filters.herramienta) && (
                    <div className="mt-4 p-4 bg-blue-50 rounded-lg">
                      <h3
                        className="font-bold mb-2"
                        style={{ color: "var(--cobit-blue)" }}
                      >
                        Filtros activos:
                      </h3>
                      <ul className="space-y-1">
                        {filters.dominio && (
                          <li className="b1">• Dominio: {filters.dominio}</li>
                        )}
                        {filters.objetivo && (
                          <li className="b1">• Objetivo: {filters.objetivo}</li>
                        )}
                        {filters.herramienta && (
                          <li className="b1">
                            • Herramienta: {filters.herramienta}
                          </li>
                        )}
                      </ul>
                    </div>
                  )}
                </div>
              ) : (
                <div>
                  <h2
                    className="text-2xl font-bold mb-4"
                    style={{ color: "var(--cobit-blue)" }}
                  >
                    Vista Gráfica
                  </h2>
                  <p className="b1 text-gray-700">
                    Aquí se mostrará la vista gráfica del ecosistema con
                    diagramas y visualizaciones.
                  </p>

                  {/* Placeholder para gráfico */}
                  <div className="mt-6 h-64 bg-gray-100 rounded-lg border-2 border-dashed border-gray-300 flex items-center justify-center">
                    <p className="text-gray-500 b1">
                      Área del gráfico - Próximamente
                    </p>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
