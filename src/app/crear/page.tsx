"use client";

import { useState } from "react";
import NavBar from "../../components/organisms/NavBar";
import CobitBoard from "../../components/organisms/CobitBoard";
import CapabilityModal from "../../components/molecules/CapabilityModal";
import SelectedObjectivesBar from "../../components/molecules/SelectedObjectivesBar";
import FilterSidebar from "../../components/molecules/FilterSidebar";
import CobitTable from "../../components/organisms/CobitTable";
import CobitGraph from "../../components/organisms/CobitGraph";
import { cobitObjectives } from "../../data/cobitObjectives";

interface ObjectiveWithLevel {
  code: string;
  level: number;
}

export default function CrearEcosistemaPage() {
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
    dominio: "",
    objetivo: "",
    herramienta: "",
  });
  const [viewMode, setViewMode] = useState<"grafico" | "lista">("grafico");

  const handleObjectiveToggle = (code: string) => {
    const existingObjective = selectedObjectives.find(
      (obj) => obj.code === code
    );

    if (existingObjective) {
      // Si ya existe, lo removemos
      setSelectedObjectives((prev) => prev.filter((obj) => obj.code !== code));
    } else {
      // Si no existe, abrimos el modal para seleccionar nivel
      const objective = cobitObjectives.find((obj) => obj.code === code);
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

  const getObjectiveLevel = (code: string): number | undefined => {
    return selectedObjectives.find((obj) => obj.code === code)?.level;
  };

  // Funciones para manejar el ecosistema creado
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

  const handleBackToSelection = () => {
    setShowEcosistema(false);
    setFilters({
      dominio: "",
      objetivo: "",
      herramienta: "",
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
        <div className="flex min-h-screen">
          {/* Sidebar con márgenes y bordes */}
          <div
            className="ml-6 mt-6 mb-6 flex-shrink-0"
            style={{ height: "calc(100vh - 8rem)" }}
          >
            <FilterSidebar
              filters={filters}
              onFilterChange={handleFilterChange}
              onClearFilters={handleClearFilters}
              viewMode={viewMode}
              onViewModeChange={handleViewModeChange}
              selectedObjectives={selectedObjectivesForFilter}
              onBackToNormal={handleBackToSelection}
              isSpecificMode={true}
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
                  selectedObjectives={selectedObjectivesForFilter}
                  className="shadow-sm"
                />
              ) : (
                <CobitGraph
                  filters={{
                    dominio: filters.dominio,
                    herramienta: filters.herramienta,
                  }}
                  selectedObjectives={selectedObjectivesForFilter}
                  className="m-4"
                />
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
