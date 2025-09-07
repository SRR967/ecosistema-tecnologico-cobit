interface ObjectiveWithLevel {
  code: string;
  level: number;
}

interface SelectedObjectivesBarProps {
  selectedObjectives: ObjectiveWithLevel[];
  onClearSelection: () => void;
  onCreateEcosystem: () => void;
  className?: string;
}

export default function SelectedObjectivesBar({
  selectedObjectives,
  onClearSelection,
  onCreateEcosystem,
  className = "",
}: SelectedObjectivesBarProps) {
  if (selectedObjectives.length === 0) return null;

  return (
    <div className={`fixed bottom-0 left-0 right-0 z-40 ${className}`}>
      <div className="bg-white border-t border-gray-200 shadow-lg">
        <div className="max-w-7xl mx-auto px-4 py-1.5">
          <div className="flex items-center justify-between">
            {/* Información de objetivos seleccionados */}
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <div
                  className="w-3 h-3 rounded-full"
                  style={{ backgroundColor: "var(--cobit-red)" }}
                />
                <span
                  className="font-bold b1"
                  style={{ color: "var(--cobit-blue)" }}
                >
                  {selectedObjectives.length} objetivo
                  {selectedObjectives.length !== 1 ? "s" : ""} seleccionado
                  {selectedObjectives.length !== 1 ? "s" : ""}
                </span>
              </div>

              {/* Lista de objetivos en formato compacto */}
              <div className="flex flex-wrap gap-2 max-w-md overflow-hidden">
                {selectedObjectives.slice(0, 3).map((objective) => (
                  <span
                    key={objective.code}
                    className="px-2 py-1 rounded text-xs font-medium text-white"
                    style={{ backgroundColor: "var(--cobit-blue)" }}
                  >
                    {objective.code} (L{objective.level})
                  </span>
                ))}
                {selectedObjectives.length > 3 && (
                  <span className="px-2 py-1 rounded text-xs font-medium bg-gray-500 text-white">
                    +{selectedObjectives.length - 3} más
                  </span>
                )}
              </div>
            </div>

            {/* Botones de acción */}
            <div className="flex items-center space-x-3">
              <button
                onClick={onClearSelection}
                className="px-4 py-2 border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 transition-colors b1"
              >
                Limpiar
              </button>
              <button
                onClick={onCreateEcosystem}
                className="px-6 py-2 rounded-lg font-medium text-white transition-colors b1 shadow-md"
                style={{ backgroundColor: "var(--cobit-blue)" }}
              >
                Crear Ecosistema ({selectedObjectives.length})
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
