"use client";

import { useState } from "react";
import {
  useCobitTable,
  TableFilters,
  TablaCobitRow,
} from "../../hooks/useCobitTable";

interface CobitTableProps {
  filters: TableFilters;
  className?: string;
}

export default function CobitTable({
  filters,
  className = "",
}: CobitTableProps) {
  const { data, loading, error, total } = useCobitTable(filters);
  const [sortField, setSortField] =
    useState<keyof TablaCobitRow>("objetivo_id");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc");
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  // Función para manejar ordenamiento
  const handleSort = (field: keyof TablaCobitRow) => {
    if (sortField === field) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortField(field);
      setSortDirection("asc");
    }
  };

  // Datos ordenados
  const sortedData = [...data].sort((a, b) => {
    const aValue = a[sortField] || "";
    const bValue = b[sortField] || "";

    if (typeof aValue === "number" && typeof bValue === "number") {
      return sortDirection === "asc" ? aValue - bValue : bValue - aValue;
    }

    const comparison = String(aValue).localeCompare(String(bValue));
    return sortDirection === "asc" ? comparison : -comparison;
  });

  // Paginación
  const totalPages = Math.ceil(sortedData.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;
  const currentData = sortedData.slice(startIndex, endIndex);

  // Componente de header de columna
  const SortableHeader = ({
    field,
    children,
  }: {
    field: keyof TablaCobitRow;
    children: React.ReactNode;
  }) => (
    <th
      className="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100 transition-colors"
      onClick={() => handleSort(field)}
    >
      <div className="flex items-center space-x-1">
        <span>{children}</span>
        <span className="text-gray-400">
          {sortField === field ? (sortDirection === "asc" ? "↑" : "↓") : "↕"}
        </span>
      </div>
    </th>
  );

  // Estado de carga
  if (loading) {
    return (
      <div className="m-8">
        <div
          className={`bg-white rounded-lg border border-gray-200 p-8 ${className}`}
        >
          <div className="flex items-center justify-center">
            <div className="text-center">
              <div
                className="animate-spin rounded-full h-8 w-8 border-b-2 mx-auto mb-4"
                style={{ borderColor: "var(--cobit-blue)" }}
              ></div>
              <p className="text-gray-600 b1">Cargando datos de la tabla...</p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Estado de error
  if (error) {
    return (
      <div className="m-8">
        <div
          className={`bg-white rounded-lg border border-gray-200 p-8 ${className}`}
        >
          <div className="text-center">
            <div className="text-red-500 text-2xl mb-2">⚠️</div>
            <h3
              className="text-lg font-bold mb-2"
              style={{ color: "var(--cobit-red)" }}
            >
              Error al cargar datos
            </h3>
            <p className="text-red-600 b1">{error}</p>
          </div>
        </div>
      </div>
    );
  }

  // Sin datos
  if (data.length === 0) {
    return (
      <div className="m-8">
        <div
          className={`bg-white rounded-lg border border-gray-200 p-8 ${className}`}
        >
          <div className="text-center">
            <div className="text-gray-400 text-4xl mb-4">📊</div>
            <h3
              className="text-lg font-bold mb-2"
              style={{ color: "var(--cobit-blue)" }}
            >
              No hay datos disponibles
            </h3>
            <p className="text-gray-600 b1">
              Ajusta los filtros para ver resultados o verifica que existan
              datos en la base de datos.
            </p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="m-8">
      <div
        className={`bg-white rounded-lg border border-gray-200 ${className}`}
      >
        {/* Header con información */}
        <div className="px-6 py-4 border-b border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <h2
                className="text-xl font-bold"
                style={{ color: "var(--cobit-blue)" }}
              >
                Datos COBIT 2019
              </h2>
              <p className="text-gray-600 b1 mt-1">
                {total} registros encontrados
                {Object.values(filters).some((f) => f !== "") && " (filtrados)"}
              </p>
            </div>
            <div className="text-sm text-gray-500">
              Página {currentPage} de {totalPages}
            </div>
          </div>
        </div>

        {/* Tabla responsive */}
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <SortableHeader field="objetivo_id">Objetivo</SortableHeader>
                <SortableHeader field="practica_nombre">
                  Práctica
                </SortableHeader>
                <SortableHeader field="actividad_descripcion">
                  Actividad
                </SortableHeader>
                <SortableHeader field="nivel_capacidad">Nivel</SortableHeader>
                <SortableHeader field="herramienta_id">
                  Herramienta
                </SortableHeader>
                <SortableHeader field="justificacion">
                  Justificación
                </SortableHeader>
                <SortableHeader field="observaciones">
                  Observaciones
                </SortableHeader>
                <SortableHeader field="integracion">Integración</SortableHeader>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {currentData.map((row, index) => (
                <tr
                  key={`${row.actividad_id}-${index}`}
                  className="hover:bg-gray-50 transition-colors"
                >
                  <td className="px-3 py-4 whitespace-nowrap">
                    <div
                      className="text-sm font-medium"
                      style={{ color: "var(--cobit-blue)" }}
                    >
                      {row.objetivo_id}
                    </div>
                    <div
                      className="text-xs text-gray-500 max-w-32 truncate"
                      title={row.objetivo_nombre}
                    >
                      {row.objetivo_nombre}
                    </div>
                  </td>
                  <td className="px-3 py-4">
                    <div className="text-sm text-gray-900 max-w-40 break-words">
                      {row.practica_nombre}
                    </div>
                    <div className="text-xs text-gray-500">
                      {row.practica_id}
                    </div>
                  </td>
                  <td className="px-3 py-4">
                    <div className="text-sm text-gray-900 max-w-48 break-words leading-tight">
                      {row.actividad_descripcion}
                    </div>
                    <div className="text-xs text-gray-500">
                      {row.actividad_id}
                    </div>
                  </td>
                  <td className="px-3 py-4 whitespace-nowrap text-center">
                    <span
                      className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium text-white"
                      style={{ backgroundColor: "var(--cobit-red)" }}
                    >
                      Nivel {row.nivel_capacidad}
                    </span>
                  </td>
                  <td className="px-3 py-4">
                    <div className="text-sm text-gray-900 max-w-32 break-words">
                      {row.herramienta_id}
                    </div>
                    {row.herramienta_categoria && (
                      <div className="text-xs text-gray-500">
                        {row.herramienta_categoria}
                      </div>
                    )}
                  </td>
                  <td className="px-3 py-4">
                    <div className="text-sm text-gray-900 max-w-48 break-words leading-tight">
                      {row.justificacion}
                    </div>
                  </td>
                  <td className="px-3 py-4">
                    <div className="text-sm text-gray-900 max-w-40 break-words leading-tight">
                      {row.observaciones || "-"}
                    </div>
                  </td>
                  <td className="px-3 py-4">
                    <div className="text-sm text-gray-900 max-w-40 break-words leading-tight">
                      {row.integracion || "-"}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Paginación */}
        {totalPages > 1 && (
          <div className="px-6 py-4 border-t border-gray-200">
            <div className="flex items-center justify-between">
              <div className="text-sm text-gray-500">
                Mostrando {startIndex + 1} a{" "}
                {Math.min(endIndex, sortedData.length)} de {sortedData.length}{" "}
                registros
              </div>
              <div className="flex space-x-2">
                <button
                  onClick={() =>
                    setCurrentPage((page) => Math.max(1, page - 1))
                  }
                  disabled={currentPage === 1}
                  className="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  Anterior
                </button>
                <span className="px-3 py-2 text-sm text-gray-700">
                  {currentPage} / {totalPages}
                </span>
                <button
                  onClick={() =>
                    setCurrentPage((page) => Math.min(totalPages, page + 1))
                  }
                  disabled={currentPage === totalPages}
                  className="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  Siguiente
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
