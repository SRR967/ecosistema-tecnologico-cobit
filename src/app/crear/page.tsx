"use client";

import { useState } from "react";
import NavBar from "../../components/organisms/NavBar";
import CobitBoard from "../../components/organisms/CobitBoard";
import CapabilityModal from "../../components/molecules/CapabilityModal";
import SelectedObjectivesBar from "../../components/molecules/SelectedObjectivesBar";
import FilterSidebar from "../../components/molecules/FilterSidebar";
import CobitTable from "../../components/organisms/CobitTable";
import CobitGraph from "../../components/organisms/CobitGraph";
import { useCobitBoard } from "../../hooks/useCobitBoard";

interface ObjectiveWithLevel {
  code: string;
  level: number;
}

export default function CrearEcosistemaPage() {
  // Hook para obtener objetivos desde la base de datos
  const { objectives, loading, error } = useCobitBoard();

  const [selectedObjectives, setSelectedObjectives] = useState<
    ObjectiveWithLevel[]
  >([]);
  const [showEcosistema, setShowEcosistema] = useState(false);
  const [modalState, setModalState] = useState<{
    isOpen: boolean;
    objectiveCode: string;
    objectiveTitle: string;
    currentLevel: number;
  }>({
    isOpen: false,
    objectiveCode: "",
    objectiveTitle: "",
    currentLevel: 1,
  });

  // Estados para el ecosistema creado
  const [filters, setFilters] = useState({
    dominio: [] as string[],
    objetivo: [] as string[],
    herramienta: [] as string[],
  });
  const [viewMode, setViewMode] = useState<"grafico" | "lista">("grafico");
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const handleObjectiveToggle = (code: string) => {
    const existingObjective = selectedObjectives.find(
      (obj) => obj.code === code
    );

    if (existingObjective) {
      // Si ya existe, lo removemos
      setSelectedObjectives((prev) => prev.filter((obj) => obj.code !== code));
    } else {
      // Si no existe, abrimos el modal para seleccionar nivel
      const objective = objectives.find((obj) => obj.code === code);
      setModalState({
        isOpen: true,
        objectiveCode: code,
        objectiveTitle: objective?.title || "",
        currentLevel: 1,
      });
    }
  };

  const handleLevelSelect = (level: number) => {
    setSelectedObjectives((prev) => [
      ...prev,
      { code: modalState.objectiveCode, level },
    ]);
  };

  const closeModal = () => {
    setModalState((prev) => ({ ...prev, isOpen: false }));
  };

  // const getObjectiveLevel = (code: string): number | undefined => {
  //   return selectedObjectives.find((obj) => obj.code === code)?.level;
  // };

  // Funciones para manejar el ecosistema creado
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

  const handleBackToSelection = () => {
    setShowEcosistema(false);
    setFilters({
      dominio: [],
      objetivo: [],
      herramienta: [],
    });
  };

  const handleCreateEcosystem = () => {
    setShowEcosistema(true);
  };

  // Convertir ObjectiveWithLevel a SelectedObjective para compatibilidad
  const selectedObjectivesForFilter = selectedObjectives.map((obj) => ({
    code: obj.code,
    level: obj.level,
  }));

  // Mostrar estado de carga
  if (loading) {
    return (
      <div className="h-screen bg-gray-50 overflow-hidden">
        <NavBar currentPath="/crear" />
        <div
          className="h-full flex items-center justify-center"
          style={{ height: "calc(100vh - 4rem)" }}
        >
          <div className="text-center">
            <div
              className="animate-spin rounded-full h-12 w-12 border-b-2 mx-auto mb-4"
              style={{ borderColor: "var(--cobit-red)" }}
            ></div>
            <h3
              className="text-xl font-bold mb-2"
              style={{ color: "var(--cobit-blue)" }}
            >
              Cargando Objetivos COBIT
            </h3>
            <p className="text-gray-600 b1">
              Conectando con la base de datos...
            </p>
          </div>
        </div>
      </div>
    );
  }

  // Mostrar error si ocurre
  if (error) {
    return (
      <div className="h-screen bg-gray-50 overflow-hidden">
        <NavBar currentPath="/crear" />
        <div
          className="h-full flex items-center justify-center"
          style={{ height: "calc(100vh - 4rem)" }}
        >
          <div className="text-center">
            <div className="text-red-500 text-4xl mb-4">⚠️</div>
            <h3
              className="text-xl font-bold mb-2"
              style={{ color: "var(--cobit-red)" }}
            >
              Error al cargar objetivos
            </h3>
            <p className="text-red-600 b1 mb-4">{error}</p>
            <button
              onClick={() => window.location.reload()}
              className="px-6 py-3 rounded-lg font-medium text-white transition-colors"
              style={{ backgroundColor: "var(--cobit-blue)" }}
            >
              Reintentar
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen bg-gray-50 overflow-hidden">
      <NavBar currentPath="/crear" />

      {!showEcosistema ? (
        // Vista de selección de objetivos
        <div
          className="h-full bg-gray-50 flex flex-col overflow-hidden"
          style={{ height: "calc(100vh - 4rem)" }}
        >
          <div className="flex-1 px-32 pt-6 pb-4 overflow-hidden">
            {/* Tablero COBIT */}
            <CobitBoard
              selectedObjectives={selectedObjectives}
              onObjectiveToggle={handleObjectiveToggle}
              className="h-full"
            />
          </div>

          {/* Barra fija inferior con objetivos seleccionados */}
          <SelectedObjectivesBar
            selectedObjectives={selectedObjectives}
            onClearSelection={() => setSelectedObjectives([])}
            onCreateEcosystem={handleCreateEcosystem}
          />

          {/* Modal de selección de nivel de capacidad */}
          <CapabilityModal
            isOpen={modalState.isOpen}
            onClose={closeModal}
            objectiveCode={modalState.objectiveCode}
            objectiveTitle={modalState.objectiveTitle}
            currentLevel={modalState.currentLevel}
            onLevelSelect={handleLevelSelect}
          />
        </div>
      ) : (
        // Vista del ecosistema creado
        <div className="h-full" style={{ height: "calc(100vh - 4rem)" }}>
          <FilterSidebar
            filters={filters}
            onFilterChange={handleFilterChange}
            onClearFilters={handleClearFilters}
            viewMode={viewMode}
            onViewModeChange={handleViewModeChange}
            selectedObjectives={selectedObjectivesForFilter}
            onBackToNormal={handleBackToSelection}
            isSpecificMode={true}
            className="bg-white rounded-lg shadow-sm border border-gray-200 m-6"
            onSidebarToggle={setSidebarOpen}
          >
            {/* Contenido basado en el modo de vista */}
            {viewMode === "lista" ? (
              <div className="h-full overflow-y-auto">
                <CobitTable
                  filters={filters}
                  selectedObjectives={selectedObjectivesForFilter}
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
                selectedObjectives={selectedObjectivesForFilter}
                className="m-4"
                sidebarOpen={sidebarOpen}
              />
            )}
          </FilterSidebar>
        </div>
      )}
    </div>
  );
}
