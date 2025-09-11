"use client";

import { useState } from "react";
import {
  useCobitTable,
  TableFilters,
  TablaCobitRow,
  SelectedObjective,
} from "../../hooks/useCobitTable";
import { usePDFExport } from "../../hooks/usePDFExport";
import ToolSummaryPills from "../molecules/ToolSummaryPills";

interface CobitTableProps {
  filters: TableFilters;
  selectedObjectives?: SelectedObjective[];
  className?: string;
}

export default function CobitTable({
  filters,
  selectedObjectives,
  className = "",
}: CobitTableProps) {
  const { data, loading, error, total } = useCobitTable(
    filters,
    selectedObjectives
  );

  // Hook para generar PDF
  const { generatePDF } = usePDFExport();

  // Función para manejar la exportación a PDF
  const handleExportPDF = async () => {
    try {
      await generatePDF({
        tableData: filteredData,
        filters,
        selectedObjectives,
        isSpecificMode:
          selectedObjectives !== undefined && selectedObjectives.length > 0,
      });
    } catch (error) {
      console.error("Error al exportar PDF:", error);
    }
  };

  const [sortField, setSortField] =
    useState<keyof TablaCobitRow>("objetivo_id");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc");
  const [currentPage, setCurrentPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState("");
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

  // Filtrar datos por búsqueda
  const filteredData = data.filter((row) => {
    if (!searchTerm) return true;

    const searchLower = searchTerm.toLowerCase();
    return (
      row.objetivo_id.toLowerCase().includes(searchLower) ||
      row.objetivo_nombre.toLowerCase().includes(searchLower) ||
      row.practica_id.toLowerCase().includes(searchLower) ||
      row.practica_nombre.toLowerCase().includes(searchLower) ||
      row.actividad_id.toLowerCase().includes(searchLower) ||
      row.actividad_descripcion.toLowerCase().includes(searchLower) ||
      row.herramienta_id.toLowerCase().includes(searchLower) ||
      (row.herramienta_categoria &&
        row.herramienta_categoria.toLowerCase().includes(searchLower)) ||
      row.justificacion.toLowerCase().includes(searchLower) ||
      (row.observaciones &&
        row.observaciones.toLowerCase().includes(searchLower)) ||
      (row.integracion &&
        row.integracion.toLowerCase().includes(searchLower)) ||
      row.nivel_capacidad.toString().includes(searchTerm)
    );
  });

  // Datos ordenados (ahora de los datos filtrados)
  const sortedData = [...filteredData].sort((a, b) => {
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
    const hasSelectedObjectives =
      selectedObjectives && selectedObjectives.length > 0;
    // const hasTraditionalFilters =
    //   filters.dominio || filters.objetivo || filters.herramienta;
    const isSpecificObjectiveMode = selectedObjectives !== undefined;

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
              {isSpecificObjectiveMode && !hasSelectedObjectives
                ? "Selecciona objetivos para ver las actividades"
                : "No hay datos disponibles"}
            </h3>
            <p className="text-gray-600 b1">
              {isSpecificObjectiveMode && !hasSelectedObjectives
                ? "Ve a 'Crear tu Ecosistema' para seleccionar objetivos COBIT con sus niveles de capacidad, o usa los filtros laterales."
                : "Ajusta los filtros para ver resultados o verifica que existan datos en la base de datos."}
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
        {/* Header con información y búsqueda */}
        <div className="px-6 py-4 border-b border-gray-200">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h2
                className="text-xl font-bold"
                style={{ color: "var(--cobit-blue)" }}
              >
                Datos COBIT 2019
              </h2>
              <p className="text-gray-600 b1 mt-1">
                {total} registros encontrados
                {filteredData.length !== total &&
                  ` (${filteredData.length} después de búsqueda)`}
                {Object.values(filters).some((f) => f !== "") && " (filtrados)"}
              </p>
            </div>
            <div className="flex items-center space-x-4">
              <div className="text-sm text-gray-500">
                Página {currentPage} de {totalPages}
              </div>
              {/* Botón de exportar PDF */}
              <button
                onClick={handleExportPDF}
                className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 transition-colors"
                title="Exportar reporte en PDF"
              >
                <svg
                  className="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                  />
                </svg>
                <span>Exportar</span>
              </button>
            </div>
          </div>

          {/* Barra de búsqueda */}
          <div className="flex items-center space-x-4">
            <div className="flex-1 max-w-md">
              <div className="relative">
                <input
                  type="text"
                  placeholder="Buscar en la tabla..."
                  value={searchTerm}
                  onChange={(e) => {
                    setSearchTerm(e.target.value);
                    setCurrentPage(1); // Resetear a la primera página al buscar
                  }}
                  className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors text-gray-900"
                />
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <svg
                    className="h-5 w-5 text-gray-400"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                    />
                  </svg>
                </div>
                {searchTerm && (
                  <button
                    onClick={() => {
                      setSearchTerm("");
                      setCurrentPage(1);
                    }}
                    className="absolute inset-y-0 right-0 pr-3 flex items-center"
                  >
                    <svg
                      className="h-4 w-4 text-gray-400 hover:text-gray-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M6 18L18 6M6 6l12 12"
                      />
                    </svg>
                  </button>
                )}
              </div>
            </div>

            {searchTerm && (
              <div className="text-sm text-gray-500">
                {filteredData.length} resultado
                {filteredData.length !== 1 ? "s" : ""}
              </div>
            )}
          </div>
        </div>

        {/* Resumen de herramientas */}
        <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
          <h3 className="text-sm font-semibold text-gray-700 mb-3">
            Resumen de Herramientas
          </h3>
          <ToolSummaryPills
            filters={filters}
            selectedObjectives={selectedObjectives}
          />
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
