import React, { useState, useRef, useEffect } from "react";

interface SmartFilterSelectProps {
  label: string;
  options: string[];
  selectedValues: string[];
  onChange: (values: string[]) => void;
  loading?: boolean;
  placeholder?: string;
  className?: string;
}

export function SmartFilterSelect({
  label,
  options,
  selectedValues,
  onChange,
  loading = false,
  placeholder = "Seleccionar...",
  className = "",
}: SmartFilterSelectProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [isUpdating, setIsUpdating] = useState(false);
  const selectRef = useRef<HTMLDivElement>(null);
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);

  // Manejar cambios con feedback inmediato y mantener select abierto
  const handleChange = (values: string[]) => {
    // Feedback visual inmediato
    setIsUpdating(true);

    // Llamar al onChange inmediatamente
    onChange(values);

    // Limpiar estado de actualización rápidamente
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    timeoutRef.current = setTimeout(() => {
      setIsUpdating(false);
    }, 100);
  };

  // Manejar clic fuera del select
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        selectRef.current &&
        !selectRef.current.contains(event.target as Node)
      ) {
        setIsOpen(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

  // Limpiar timeout al desmontar
  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  return (
    <div className={`space-y-2 ${className}`} ref={selectRef}>
      <label className="block text-sm font-medium text-gray-700">
        {label}
        {loading && (
          <span className="ml-2 text-blue-500 text-xs">
            <div className="animate-spin rounded-full h-3 w-3 border-b-2 border-blue-500 inline-block"></div>
          </span>
        )}
        {isUpdating && (
          <span className="ml-2 text-green-500 text-xs">
            <div className="animate-spin rounded-full h-3 w-3 border-b-2 border-green-500 inline-block"></div>
          </span>
        )}
      </label>

      <div className="relative">
        <button
          type="button"
          onClick={() => setIsOpen(!isOpen)}
          className="w-full px-3 py-2 text-left bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          disabled={loading}
        >
          <span
            className={`block truncate ${
              selectedValues.length === 0 ? "text-gray-900" : "text-gray-700"
            }`}
          >
            {selectedValues.length === 0
              ? placeholder
              : selectedValues.length === 1
              ? selectedValues[0]
              : `${selectedValues.length} seleccionados`}
          </span>
          <span className="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
            <svg
              className={`w-5 h-5 text-gray-400 transition-transform ${
                isOpen ? "rotate-180" : ""
              }`}
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M19 9l-7 7-7-7"
              />
            </svg>
          </span>
        </button>

        {isOpen && (
          <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-auto">
            {options.length === 0 ? (
              <div className="px-3 py-2 text-sm text-gray-500">
                {loading ? "Cargando..." : "No hay opciones disponibles"}
              </div>
            ) : (
              <div className="py-1">
                {options.map((option) => {
                  const isSelected = selectedValues.includes(option);
                  return (
                    <button
                      key={option}
                      type="button"
                      onClick={() => {
                        const newValues = isSelected
                          ? selectedValues.filter((v) => v !== option)
                          : [...selectedValues, option];
                        handleChange(newValues);
                      }}
                      className={`w-full px-3 py-2 text-left text-sm hover:bg-gray-100 focus:outline-none focus:bg-gray-100 ${
                        isSelected
                          ? "bg-blue-50 text-blue-700"
                          : "text-gray-900"
                      }`}
                    >
                      <div className="flex items-center">
                        <input
                          type="checkbox"
                          checked={isSelected}
                          onChange={() => {}} // Manejado por el onClick del botón
                          className="mr-2 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                        />
                        <span className="truncate">{option}</span>
                      </div>
                    </button>
                  );
                })}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
