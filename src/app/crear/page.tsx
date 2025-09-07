"use client";

import { useState } from "react";
import NavBar from "../../components/organisms/NavBar";
import CobitBoard from "../../components/organisms/CobitBoard";
import CapabilityModal from "../../components/molecules/CapabilityModal";
import SelectedObjectivesBar from "../../components/molecules/SelectedObjectivesBar";
import { cobitObjectives } from "../../data/cobitObjectives";

interface ObjectiveWithLevel {
  code: string;
  level: number;
}

export default function CrearEcosistemaPage() {
  const [selectedObjectives, setSelectedObjectives] = useState<
    ObjectiveWithLevel[]
  >([]);
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

  return (
    <div className="h-screen bg-gray-50 flex flex-col overflow-hidden">
      <NavBar currentPath="/crear" />

      <div className="flex-1 px-24 pt-6 pb-12">
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
        onCreateEcosystem={() => {
          // Aquí puedes agregar la lógica para crear el ecosistema
          console.log("Crear ecosistema con:", selectedObjectives);
        }}
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
  );
}
