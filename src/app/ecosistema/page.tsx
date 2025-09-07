"use client";

import { useState } from "react";
import NavBar from "../../components/organisms/NavBar";
import FilterSidebar from "../../components/molecules/FilterSidebar";
import CobitTable from "../../components/organisms/CobitTable";
import CobitGraph from "../../components/organisms/CobitGraph";

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
        {/* Sidebar con márgenes y bordes */}
        <div className="ml-6 mt-6 mb-6 flex-shrink-0">
          <FilterSidebar
            filters={filters}
            onFilterChange={handleFilterChange}
            viewMode={viewMode}
            onViewModeChange={handleViewModeChange}
            className="bg-white rounded-lg shadow-sm border border-gray-200"
          />
        </div>

        {/* Main Content */}
        <div className="flex-1">
          <div className="w-full">
            {/* Contenido basado en el modo de vista */}
            {viewMode === "lista" ? (
              <CobitTable filters={filters} className="shadow-sm" />
            ) : (
              <CobitGraph
                filters={{
                  dominio: filters.dominio,
                  herramienta: filters.herramienta,
                }}
                className="m-4"
              />
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
