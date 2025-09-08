"use client";

// import { useState } from "react";
import DomainSection from "../molecules/DomainSection";
import {
  useCobitBoard,
  getObjectivesByDomain,
  getDomainTitle,
} from "../../hooks/useCobitBoard";

interface ObjectiveWithLevel {
  code: string;
  level: number;
}

interface CobitBoardProps {
  selectedObjectives?: ObjectiveWithLevel[];
  onObjectiveToggle?: (code: string) => void;
  className?: string;
}

export default function CobitBoard({
  selectedObjectives = [],
  onObjectiveToggle,
  className = "",
}: CobitBoardProps) {
  // Cargar objetivos desde la base de datos
  const { objectives, loading, error } = useCobitBoard();

  const handleObjectiveClick = (code: string) => {
    onObjectiveToggle?.(code);
  };

  // const getObjectiveLevel = (code: string): number | undefined => {
  //   return selectedObjectives.find((obj) => obj.code === code)?.level;
  // };

  // const isObjectiveSelected = (code: string): boolean => {
  //   return selectedObjectives.some((obj) => obj.code === code);
  // };

  // Mostrar estado de carga
  if (loading) {
    return (
      <div
        className={`w-full h-full flex items-center justify-center ${className}`}
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
          <p className="text-gray-600 b1">Conectando con la base de datos...</p>
        </div>
      </div>
    );
  }

  // Mostrar error si ocurre
  if (error) {
    return (
      <div
        className={`w-full h-full flex items-center justify-center ${className}`}
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
    );
  }

  return (
    <div className={`w-full h-full flex flex-col ${className}`}>
      {/* Layout principal del tablero COBIT */}
      <div className="grid grid-cols-12 gap-2 h-full p-2">
        {/* Fila 1: EDM - Toda la fila superior */}
        <div className="col-span-12">
          <DomainSection
            domain="EDM"
            title={getDomainTitle("EDM")}
            objectives={getObjectivesByDomain(objectives, "EDM")}
            selectedObjectives={selectedObjectives}
            onObjectiveClick={handleObjectiveClick}
            layout="horizontal"
          />
        </div>

        {/* Columnas principales: APO, BAI, DSS (izquierda) + MEA (derecha) */}
        <div className="col-span-9 flex flex-col space-y-2 h-full">
          {/* APO - Segunda fila */}
          <DomainSection
            domain="APO"
            title={getDomainTitle("APO")}
            objectives={getObjectivesByDomain(objectives, "APO")}
            selectedObjectives={selectedObjectives}
            onObjectiveClick={handleObjectiveClick}
            layout="horizontal"
          />

          {/* BAI - Tercera fila */}
          <DomainSection
            domain="BAI"
            title={getDomainTitle("BAI")}
            objectives={getObjectivesByDomain(objectives, "BAI")}
            selectedObjectives={selectedObjectives}
            onObjectiveClick={handleObjectiveClick}
            layout="horizontal"
          />

          {/* DSS - Cuarta fila */}
          <DomainSection
            domain="DSS"
            title={getDomainTitle("DSS")}
            objectives={getObjectivesByDomain(objectives, "DSS")}
            selectedObjectives={selectedObjectives}
            onObjectiveClick={handleObjectiveClick}
            layout="horizontal"
          />
        </div>

        {/* MEA - Columna vertical derecha */}
        <div className="col-span-3 h-full">
          <DomainSection
            domain="MEA"
            title={getDomainTitle("MEA")}
            objectives={getObjectivesByDomain(objectives, "MEA")}
            selectedObjectives={selectedObjectives}
            onObjectiveClick={handleObjectiveClick}
            layout="vertical"
            className="h-full"
          />
        </div>
      </div>
    </div>
  );
}
