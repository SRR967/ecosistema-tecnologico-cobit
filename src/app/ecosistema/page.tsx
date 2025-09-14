"use client";

import { useState, useEffect, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import NavBar from "../../components/organisms/NavBar";
import FilterSidebar from "../../components/molecules/FilterSidebar";
import CobitTable from "../../components/organisms/CobitTable";
import CobitGraph from "../../components/organisms/CobitGraph";

interface SelectedObjective {
  code: string;
  level: number;
}

function EcosistemaContent() {
  const searchParams = useSearchParams();
  const [selectedObjectives, setSelectedObjectives] = useState<
    SelectedObjective[]
  >([]);
  const [isSpecificMode, setIsSpecificMode] = useState(false);

  const [filters, setFilters] = useState({
    dominio: [] as string[],
    objetivo: [] as string[],
    herramienta: [] as string[],
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
    }
  }, [searchParams]);

  const handleFilterChange = (
    filterType: "dominio" | "objetivo" | "herramienta",
    value: string[]
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
      dominio: [],
      objetivo: [],
      herramienta: [],
    });
  };

  const handleBackToNormal = () => {
    setIsSpecificMode(false);
    setSelectedObjectives([]);
    setFilters({
      dominio: "",
      objetivo: [],
      herramienta: "",
    });
    // Limpiar URL
    window.history.replaceState({}, document.title, window.location.pathname);
  };

  return (
    <div className="h-screen bg-gray-50 overflow-hidden">
      <NavBar currentPath="/ecosistema" />

      <div className="flex h-full" style={{ height: "calc(100vh - 4rem)" }}>
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
        <div className="flex-1 overflow-hidden">
          <div className="w-full h-full">
            {/* Contenido basado en el modo de vista */}
            {viewMode === "lista" ? (
              <div className="h-full overflow-y-auto">
                <CobitTable
                  filters={filters}
                  selectedObjectives={
                    isSpecificMode ? selectedObjectives : undefined
                  }
                  className="shadow-sm"
                />
              </div>
            ) : (
              <CobitGraph
                filters={{
                  dominio: filters.dominio,
                  objetivo: filters.objetivo,
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

export default function EcosistemaPage() {
  return (
    <Suspense
      fallback={
        <div className="flex h-screen items-center justify-center">
          <div className="text-center">
            <div
              className="animate-spin rounded-full h-12 w-12 border-b-2 mx-auto mb-4"
              style={{ borderColor: "var(--cobit-blue)" }}
            ></div>
            <p className="text-gray-600">Cargando ecosistema...</p>
          </div>
        </div>
      }
    >
      <EcosistemaContent />
    </Suspense>
  );
}
