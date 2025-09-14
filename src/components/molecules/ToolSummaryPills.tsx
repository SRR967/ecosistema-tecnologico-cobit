"use client";

import React from "react";
import { useCobitTable } from "../../hooks/useCobitTable";

interface ToolSummaryPillsProps {
  filters: {
    dominio: string[];
    objetivo: string[];
    herramienta: string[];
  };
  selectedObjectives?: Array<{
    code: string;
    level: number;
  }>;
  className?: string;
}

interface ToolCount {
  id: string;
  nombre: string;
  categoria?: string;
  count: number;
}

export default function ToolSummaryPills({
  filters,
  selectedObjectives,
  className = "",
}: ToolSummaryPillsProps) {
  const { data, loading } = useCobitTable(filters, selectedObjectives);

  // Calcular conteo de herramientas
  const toolCounts: ToolCount[] = React.useMemo(() => {
    if (!data || data.length === 0) return [];

    const counts: { [key: string]: ToolCount } = {};

    data.forEach((row) => {
      const toolId = row.herramienta_id || "N/A";
      const toolName = row.herramienta_nombre || toolId;
      const toolCategory = row.herramienta_categoria;

      if (counts[toolId]) {
        counts[toolId].count++;
      } else {
        counts[toolId] = {
          id: toolId,
          nombre: toolName,
          categoria: toolCategory,
          count: 1,
        };
      }
    });

    // Convertir a array y ordenar por conteo descendente
    return Object.values(counts).sort((a, b) => b.count - a.count);
  }, [data]);

  if (loading) {
    return (
      <div className={`flex items-center space-x-2 ${className}`}>
        <div className="animate-pulse bg-gray-200 h-8 w-24 rounded-full"></div>
        <div className="animate-pulse bg-gray-200 h-8 w-32 rounded-full"></div>
        <div className="animate-pulse bg-gray-200 h-8 w-28 rounded-full"></div>
      </div>
    );
  }

  // Filtrar herramientas reales para verificar si hay alguna
  const realTools = toolCounts.filter((tool) => tool.id !== "N/A");

  if (realTools.length === 0) {
    return (
      <div className={`flex items-center space-x-2 ${className}`}>
        <div className="px-4 py-2 bg-gray-100 rounded-full text-sm text-gray-600">
          No hay herramientas disponibles
        </div>
      </div>
    );
  }

  return (
    <div className={`flex flex-wrap items-center gap-2 ${className}`}>
      {/* Contador total */}
      <div className="px-4 py-2 bg-blue-100 text-blue-800 rounded-full text-sm font-medium">
        {realTools.length} herramienta{realTools.length !== 1 ? "s" : ""}
      </div>

      {/* Pastillas individuales */}
      {toolCounts.map((tool) => (
        <div
          key={tool.id}
          className="px-3 py-1 bg-white border border-gray-200 rounded-full text-sm shadow-sm hover:shadow-md transition-shadow"
        >
          <span className="font-medium text-gray-900">{tool.nombre}</span>
          <span className="ml-2 px-2 py-0.5 bg-gray-100 text-gray-600 rounded-full text-xs">
            {tool.count}
          </span>
        </div>
      ))}
    </div>
  );
}
