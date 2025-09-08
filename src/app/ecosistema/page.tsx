"use client";

import { useState, useEffect } from "react";
import { useSearchParams } from "next/navigation";
import NavBar from "../../components/organisms/NavBar";
import FilterSidebar from "../../components/molecules/FilterSidebar";
import CobitTable from "../../components/organisms/CobitTable";
import CobitGraph from "../../components/organisms/CobitGraph";

interface SelectedObjective {
  code: string;
  level: number;
}

export default function EcosistemaPage() {
  const searchParams = useSearchParams();
  const [selectedObjectives, setSelectedObjectives] = useState<
    SelectedObjective[]
  >([]);
  const [isSpecificMode, setIsSpecificMode] = useState(false);

  const [filters, setFilters] = useState({
    dominio: "",
    objetivo: "",
    herramienta: "",
  });

  const [viewMode, setViewMode] = useState<"grafico" | "lista">("grafico");

  // Efecto para parsear parámetros URL de objetivos seleccionados
  useEffect(() => {
    const objectives: SelectedObjective[] = [];

    // Buscar todos los parámetros que empiecen con 'obj_'
    searchParams.forEach((value, key) => {
      if (key.startsWith("obj_")) {
        const [code, level] = value.split(":");
        if (code && level) {
          objectives.push({
            code: code,
            level: parseInt(level, 10),
          });
        }
      }
    });

    setSelectedObjectives(objectives);
    setIsSpecificMode(objectives.length > 0);

    // Debug: mostrar objetivos parseados
    if (objectives.length > 0) {
      console.log("🎯 Objetivos seleccionados desde URL:", objectives);
    }
  }, [searchParams]);

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

  const handleClearFilters = () => {
    setFilters({
      dominio: "",
      objetivo: "",
      herramienta: "",
    });
  };

  const handleBackToNormal = () => {
    setIsSpecificMode(false);
    setSelectedObjectives([]);
    setFilters({
      dominio: "",
      objetivo: "",
      herramienta: "",
    });
    // Limpiar URL
    window.history.replaceState({}, document.title, window.location.pathname);
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
            onClearFilters={handleClearFilters}
            viewMode={viewMode}
            onViewModeChange={handleViewModeChange}
            selectedObjectives={isSpecificMode ? selectedObjectives : undefined}
            onBackToNormal={isSpecificMode ? handleBackToNormal : undefined}
            isSpecificMode={isSpecificMode}
            className="bg-white rounded-lg shadow-sm border border-gray-200"
          />
        </div>

        {/* Main Content */}
        <div className="flex-1">
          <div className="w-full">
            {/* Contenido basado en el modo de vista */}
            {viewMode === "lista" ? (
              <CobitTable
                filters={filters}
                selectedObjectives={
                  isSpecificMode ? selectedObjectives : undefined
                }
                className="shadow-sm"
              />
            ) : (
              <CobitGraph
                filters={{
                  dominio: filters.dominio,
                  herramienta: filters.herramienta,
                }}
                selectedObjectives={
                  isSpecificMode ? selectedObjectives : undefined
                }
                className="m-4"
              />
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
