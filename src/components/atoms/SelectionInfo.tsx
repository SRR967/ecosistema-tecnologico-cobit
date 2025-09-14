import React from "react";

interface SelectionInfoProps {
  selectedItems: Array<{
    id: string;
    name: string;
    level?: number;
    category?: string;
    domain?: string;
  }>;
  type: "objetivos" | "herramientas" | "dominios";
  className?: string;
}

export function SelectionInfo({
  selectedItems,
  type,
  className = "",
}: SelectionInfoProps) {
  if (selectedItems.length === 0) {
    return null;
  }

  const getTypeLabel = () => {
    switch (type) {
      case "objetivos":
        return "Objetivos Seleccionados";
      case "herramientas":
        return "Herramientas Seleccionadas";
      case "dominios":
        return "Dominios Seleccionados";
      default:
        return "Elementos Seleccionados";
    }
  };

  const getLevelColor = (level: number): string => {
    switch (level) {
      case 1:
        return "#9AA0A6"; // Gris
      case 2:
        return "#4FB4FF"; // Azul claro
      case 3:
        return "#0594FF"; // Azul
      case 4:
        return "#E25088"; // Rosa
      case 5:
        return "#78206E"; // Morado
      default:
        return "#F3F4F6"; // Gris por defecto
    }
  };

  return (
    <div
      className={`bg-white rounded-lg border border-gray-200 p-4 shadow-sm ${className}`}
    >
      <h3 className="text-sm font-semibold text-blue-600 mb-3">
        {getTypeLabel()}:
      </h3>

      <div className="space-y-2">
        {selectedItems.map((item) => (
          <div
            key={item.id}
            className="flex items-center justify-between p-2 bg-gray-50 rounded-md"
          >
            <div className="flex-1">
              <span className="text-sm font-medium text-gray-900">
                {item.name}
              </span>
              {item.category && (
                <span className="ml-2 text-xs text-gray-500">
                  ({item.category})
                </span>
              )}
            </div>

            {item.level && (
              <div className="flex items-center space-x-2">
                <span className="text-xs text-gray-500">Nivel</span>
                <div
                  className="w-4 h-4 rounded-full border-2 border-white shadow-sm"
                  style={{ backgroundColor: getLevelColor(item.level) }}
                ></div>
                <span className="text-sm font-medium text-gray-700">
                  {item.level}
                </span>
              </div>
            )}

            {item.domain && (
              <span className="text-xs text-gray-500 bg-blue-100 px-2 py-1 rounded">
                {item.domain}
              </span>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
