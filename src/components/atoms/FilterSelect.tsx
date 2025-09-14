"use client";

import { useState, useEffect } from "react";
import MultiSelect from "./MultiSelect";

interface ResponsiveFilterProps {
  label: string;
  options: string[];
  selectedValues: string[];
  onChange: (values: string[]) => void;
  loading?: boolean;
  isMultiSelect?: boolean;
  placeholder?: string;
  className?: string;
}

export default function ResponsiveFilter({
  label,
  options,
  selectedValues,
  onChange,
  loading = false,
  isMultiSelect = false,
  placeholder = "Seleccionar opciones",
  className = "",
}: ResponsiveFilterProps) {
  const [isUpdating, setIsUpdating] = useState(false);
  const [localOptions, setLocalOptions] = useState(options);

  // Actualizar opciones locales cuando cambien las opciones
  useEffect(() => {
    setLocalOptions(options);
  }, [options]);

  // Manejar cambios con feedback inmediato
  const handleChange = (values: string[]) => {
    // Feedback visual inmediato
    setIsUpdating(true);

    // Llamar al onChange inmediatamente
    onChange(values);

    // Limpiar estado de actualización rápidamente
    setTimeout(() => {
      setIsUpdating(false);
    }, 100);
  };

  // Mostrar indicador de carga sutil
  const showLoading = loading || isUpdating;

  if (isMultiSelect) {
    return (
      <div className={`space-y-2 ${className}`}>
        <div className="flex items-center justify-between">
          <label className="block text-sm font-medium text-gray-700">
            {label}
          </label>
          {showLoading && (
            <div className="flex items-center space-x-1">
              <div className="animate-spin rounded-full h-3 w-3 border-b border-blue-500"></div>
              <span className="text-xs text-gray-500">Actualizando...</span>
            </div>
          )}
        </div>
        <MultiSelect
          label=""
          options={localOptions}
          selectedValues={selectedValues}
          onChange={handleChange}
          placeholder={placeholder}
          className={showLoading ? "opacity-75" : ""}
        />
      </div>
    );
  }

  return (
    <div className={`space-y-2 ${className}`}>
      <div className="flex items-center justify-between">
        <label className="block text-sm font-medium text-gray-700">
          {label}
        </label>
        {showLoading && (
          <div className="flex items-center space-x-1">
            <div className="animate-spin rounded-full h-3 w-3 border-b border-blue-500"></div>
            <span className="text-xs text-gray-500">Actualizando...</span>
          </div>
        )}
      </div>
      <select
        value={selectedValues[0] || ""}
        onChange={(e) => handleChange([e.target.value])}
        className={`w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
          showLoading ? "opacity-75" : ""
        }`}
      >
        <option value="">{placeholder}</option>
        {localOptions.map((option) => (
          <option key={option} value={option}>
            {option}
          </option>
        ))}
      </select>
    </div>
  );
}
