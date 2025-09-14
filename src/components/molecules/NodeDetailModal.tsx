"use client";

import { useEffect, useState } from "react";
import { XMarkIcon } from "@heroicons/react/24/outline";

interface HerramientaDetail {
  id: string;
  categoria: string;
  descripcion: string;
  casos_uso: string[];
  tipo_herramienta: string;
}

interface ObjetivoDetail {
  id: string;
  nombre: string;
  proposito: string;
}

interface NodeDetailModalProps {
  isOpen: boolean;
  onClose: () => void;
  nodeType: "objetivo" | "herramienta";
  nodeId: string;
}

export default function NodeDetailModal({
  isOpen,
  onClose,
  nodeType,
  nodeId,
}: NodeDetailModalProps) {
  const [data, setData] = useState<HerramientaDetail | ObjetivoDetail | null>(
    null
  );
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (isOpen && nodeId) {
      fetchNodeDetails();
    }
  }, [isOpen, nodeId, nodeType]);

  const fetchNodeDetails = async () => {
    try {
      setLoading(true);
      setError(null);

      const endpoint =
        nodeType === "objetivo"
          ? `/api/cobit/objetivos/${nodeId}`
          : `/api/cobit/herramientas/${nodeId}`;

      const response = await fetch(endpoint);

      if (!response.ok) {
        throw new Error("Error al cargar los detalles");
      }

      const result = await response.json();
      setData(result);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Error desconocido");
    } finally {
      setLoading(false);
    }
  };

  if (!isOpen) return null;

  const renderHerramientaContent = (herramienta: HerramientaDetail) => (
    <div className="space-y-4">
      <div>
        <div className="bg-blue-50 p-3 rounded-lg mb-4">
          <h4 className="font-bold text-blue-900 text-lg">{herramienta.id}</h4>
        </div>
      </div>

      <div>
        <h4 className="font-semibold text-gray-700 mb-2 text-sm">Categoría</h4>
        <p className="text-gray-600 bg-gray-50 p-2 rounded text-sm">
          {herramienta.categoria}
        </p>
      </div>

      <div>
        <h4 className="font-semibold text-gray-700 mb-2 text-sm">
          Descripción
        </h4>
        <p className="text-gray-600 bg-gray-50 p-3 rounded leading-relaxed text-sm">
          {herramienta.descripcion}
        </p>
      </div>

      <div>
        <h4 className="font-semibold text-gray-700 mb-2 text-sm">
          Tipo de Herramienta
        </h4>
        <p className="text-gray-600 bg-gray-50 p-2 rounded text-sm">
          {herramienta.tipo_herramienta}
        </p>
      </div>

      <div>
        <h4 className="font-semibold text-gray-700 mb-2 text-sm">
          Casos de Uso
        </h4>
        <div className="bg-gray-50 p-3 rounded">
          {herramienta.casos_uso && herramienta.casos_uso.length > 0 ? (
            <ul className="space-y-1">
              {herramienta.casos_uso.map((caso, index) => (
                <li
                  key={index}
                  className="text-gray-600 flex items-start text-sm"
                >
                  <span className="text-blue-500 mr-2">•</span>
                  {caso}
                </li>
              ))}
            </ul>
          ) : (
            <p className="text-gray-500 italic text-sm">
              No se especificaron casos de uso
            </p>
          )}
        </div>
      </div>
    </div>
  );

  const renderObjetivoContent = (objetivo: ObjetivoDetail) => (
    <div className="space-y-4">
      <div>
        <div className="bg-green-50 p-3 rounded-lg mb-4">
          <h4 className="font-bold text-green-900 text-lg">{objetivo.id}</h4>
        </div>
      </div>

      <div>
        <h4 className="font-semibold text-gray-700 mb-2 text-sm">Nombre</h4>
        <p className="text-gray-600 bg-gray-50 p-2 rounded text-sm">
          {objetivo.nombre}
        </p>
      </div>

      <div>
        <h4 className="font-semibold text-gray-700 mb-2 text-sm">Propósito</h4>
        <p className="text-gray-600 bg-gray-50 p-3 rounded leading-relaxed text-sm">
          {objetivo.proposito}
        </p>
      </div>
    </div>
  );

  return (
    <div className="fixed inset-0 z-50">
      {/* Overlay invisible para cerrar al hacer clic fuera */}
      <div className="absolute inset-0 pointer-events-auto" onClick={onClose} />

      {/* Sidebar desde la derecha */}
      <div
        className="absolute right-0 top-0 h-full w-96 bg-white shadow-2xl transform transition-transform duration-300 ease-in-out pointer-events-auto"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="h-full flex flex-col">
          {/* Header */}
          <div className="flex justify-between items-center p-6 border-b border-gray-200 bg-gray-50">
            <h2 className="text-lg font-bold text-gray-900">
              {nodeType === "objetivo" ? "Objetivo" : "Herramienta"}
            </h2>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600 transition-colors p-1 rounded-full hover:bg-gray-200"
            >
              <XMarkIcon className="w-5 h-5" />
            </button>
          </div>

          {/* Content */}
          <div className="flex-1 overflow-y-auto p-6">
            {loading && (
              <div className="flex items-center justify-center py-8">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
                <span className="ml-3 text-gray-600">Cargando detalles...</span>
              </div>
            )}

            {error && (
              <div className="text-center py-8">
                <div className="text-red-500 text-4xl mb-4">⚠️</div>
                <h3 className="text-lg font-bold text-red-600 mb-2">
                  Error al cargar detalles
                </h3>
                <p className="text-red-600 mb-4">{error}</p>
                <button
                  onClick={fetchNodeDetails}
                  className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors"
                >
                  Reintentar
                </button>
              </div>
            )}

            {data && !loading && !error && (
              <>
                {nodeType === "herramienta"
                  ? renderHerramientaContent(data as HerramientaDetail)
                  : renderObjetivoContent(data as ObjetivoDetail)}
              </>
            )}
          </div>

          {/* Footer */}
          <div className="p-6 border-t border-gray-200 bg-gray-50">
            <button
              onClick={onClose}
              className="w-full px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
            >
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
