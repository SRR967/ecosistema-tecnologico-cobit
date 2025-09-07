import { useEffect, useState } from "react";
import CapabilityLevelSelect from "../atoms/CapabilityLevelSelect";

interface CapabilityModalProps {
  isOpen: boolean;
  onClose: () => void;
  objectiveCode: string;
  objectiveTitle: string;
  currentLevel: number;
  onLevelSelect: (level: number) => void;
}

export default function CapabilityModal({
  isOpen,
  onClose,
  objectiveCode,
  objectiveTitle,
  currentLevel,
  onLevelSelect,
}: CapabilityModalProps) {
  const [selectedLevel, setSelectedLevel] = useState(currentLevel);
  const [isAnimating, setIsAnimating] = useState(false);

  // Resetear el nivel seleccionado cuando se abre el modal y manejar animación
  useEffect(() => {
    if (isOpen) {
      setSelectedLevel(currentLevel);
      // Pequeño delay para que la animación se vea suave
      setTimeout(() => setIsAnimating(true), 10);
    } else {
      setIsAnimating(false);
    }
  }, [isOpen, currentLevel]);

  // Cerrar modal con ESC
  useEffect(() => {
    const handleEsc = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        handleClose();
      }
    };

    if (isOpen) {
      document.addEventListener("keydown", handleEsc);
      document.body.style.overflow = "hidden";
    }

    return () => {
      document.removeEventListener("keydown", handleEsc);
      document.body.style.overflow = "unset";
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const handleConfirm = () => {
    onLevelSelect(selectedLevel);
    onClose();
  };

  const handleClose = () => {
    setIsAnimating(false);
    // Delay para que la animación de salida se complete
    setTimeout(() => onClose(), 200);
  };

  return (
    <div
      className={`fixed inset-0 z-50 flex items-center justify-center transition-opacity duration-300 ${
        isAnimating ? "opacity-100" : "opacity-0"
      }`}
    >
      {/* Overlay transparente */}
      <div className="absolute inset-0" onClick={handleClose} />

      {/* Modal */}
      <div
        className={`relative bg-white rounded-lg shadow-2xl border border-gray-200 max-w-lg w-full mx-4 max-h-[80vh] overflow-y-auto transform transition-all duration-300 ease-out ${
          isAnimating
            ? "scale-100 translate-y-0 opacity-100"
            : "scale-95 translate-y-4 opacity-0"
        }`}
      >
        <div className="p-4">
          {/* Header */}
          <div className="flex justify-between items-start mb-4">
            <div>
              <h3
                className="text-xl font-bold"
                style={{ color: "var(--cobit-blue)" }}
              >
                {objectiveCode}
              </h3>
              <p className="text-gray-600 b1 mt-1">{objectiveTitle}</p>
            </div>
            <button
              onClick={handleClose}
              className="text-gray-400 hover:text-gray-600 transition-colors"
            >
              <svg
                className="w-6 h-6"
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
          </div>

          {/* Capability Level Select */}
          <CapabilityLevelSelect
            selectedLevel={selectedLevel}
            onLevelChange={setSelectedLevel}
          />

          {/* Actions */}
          <div className="flex justify-end space-x-3 mt-6 pt-4 border-t">
            <button
              onClick={handleClose}
              className="px-4 py-2 border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 transition-colors b1"
            >
              Cancelar
            </button>
            <button
              onClick={handleConfirm}
              className="px-4 py-2 rounded-lg font-medium text-white transition-colors b1"
              style={{ backgroundColor: "var(--cobit-blue)" }}
            >
              Confirmar Nivel {selectedLevel}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
