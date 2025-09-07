import FilterSelect from "../atoms/FilterSelect";
import ToggleButtonGroup from "../atoms/ToggleButtonGroup";

interface FilterSidebarProps {
  filters: {
    dominio: string;
    objetivo: string;
    herramienta: string;
  };
  onFilterChange: (
    filterType: "dominio" | "objetivo" | "herramienta",
    value: string
  ) => void;
  viewMode: "grafico" | "lista";
  onViewModeChange: (mode: "grafico" | "lista") => void;
  className?: string;
}

export default function FilterSidebar({
  filters,
  onFilterChange,
  viewMode,
  onViewModeChange,
  className = "",
}: FilterSidebarProps) {
  // Datos de ejemplo - en un caso real vendrían de una API o estado global
  const dominioOptions = [
    "EDM - Evaluar, Orientar y Monitorear",
    "APO - Alinear, Planificar y Organizar",
    "BAI - Construir, Adquirir e Implementar",
    "DSS - Entregar, Dar Servicio y Soporte",
    "MEA - Monitorear, Evaluar y Valorar",
  ];
  const objetivoOptions = [
    "EDM01",
    "EDM02",
    "APO01",
    "APO02",
    "BAI01",
    "BAI02",
    "DSS01",
    "DSS02",
    "MEA01",
    "MEA02",
  ];
  const herramientaOptions = [
    "Microsoft Project",
    "Jira",
    "ServiceNow",
    "Tableau",
    "Power BI",
    "Git",
    "Jenkins",
  ];

  return (
    <div
      className={`w-80 bg-white shadow-lg border-r border-gray-200 h-full p-6 ${className}`}
    >
      <div className="space-y-6">
        {/* Título */}
        <h2
          className="text-2xl font-bold"
          style={{ color: "var(--cobit-blue)" }}
        >
          Filtros
        </h2>

        {/* Filtros */}
        <div className="space-y-4">
          <FilterSelect
            label="Dominio"
            options={dominioOptions}
            value={filters.dominio}
            onChange={(value) => onFilterChange("dominio", value)}
          />

          <FilterSelect
            label="Objetivo"
            options={objetivoOptions}
            value={filters.objetivo}
            onChange={(value) => onFilterChange("objetivo", value)}
          />

          <FilterSelect
            label="Herramienta"
            options={herramientaOptions}
            value={filters.herramienta}
            onChange={(value) => onFilterChange("herramienta", value)}
          />
        </div>

        {/* Separador */}
        <div className="border-t border-gray-200 pt-4">
          <ToggleButtonGroup
            label="Vista"
            options={[
              { value: "grafico", label: "Gráfico" },
              { value: "lista", label: "Lista" },
            ]}
            selectedValue={viewMode}
            onChange={onViewModeChange}
          />
        </div>
      </div>
    </div>
  );
}
