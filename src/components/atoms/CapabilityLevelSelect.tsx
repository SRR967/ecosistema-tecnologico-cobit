interface CapabilityLevel {
  level: number;
  name: string;
  description: string;
}

interface CapabilityLevelSelectProps {
  selectedLevel: number;
  onLevelChange: (level: number) => void;
  className?: string;
}

const capabilityLevels: CapabilityLevel[] = [
  { level: 1, name: "Ejecutado", description: "El proceso logra su propósito" },
  {
    level: 2,
    name: "Gestionado",
    description: "El proceso se gestiona (planifica, monitorea y ajusta)",
  },
  {
    level: 3,
    name: "Establecido",
    description: "El proceso se implementa usando un proceso definido",
  },
  {
    level: 4,
    name: "Predecible",
    description:
      "El proceso opera de manera predecible dentro de límites definidos",
  },
  {
    level: 5,
    name: "Optimizado",
    description:
      "El proceso se mejora continuamente para cumplir objetivos actuales y futuros",
  },
];

export default function CapabilityLevelSelect({
  selectedLevel,
  onLevelChange,
  className = "",
}: CapabilityLevelSelectProps) {
  return (
    <div className={`space-y-3 ${className}`}>
      <h4
        className="font-bold text-base"
        style={{ color: "var(--cobit-blue)" }}
      >
        Selecciona el Nivel de Capacidad
      </h4>

      <div className="space-y-2">
        {capabilityLevels.map((level) => (
          <label
            key={level.level}
            className={`flex items-start space-x-2 p-2 rounded border-2 cursor-pointer transition-all duration-200 ${
              selectedLevel === level.level
                ? "border-blue-500 bg-blue-50"
                : "border-gray-200 hover:border-gray-300 hover:bg-gray-50"
            }`}
          >
            <input
              type="radio"
              name="capability-level"
              value={level.level}
              checked={selectedLevel === level.level}
              onChange={() => onLevelChange(level.level)}
              className="mt-0.5"
              style={{ accentColor: "var(--cobit-blue)" }}
            />
            <div className="flex-1">
              <div className="flex items-center space-x-2">
                <span
                  className="font-bold text-xs px-1.5 py-0.5 rounded text-white"
                  style={{ backgroundColor: "var(--cobit-blue)" }}
                >
                  Nivel {level.level}
                </span>
                <span className="font-medium text-sm text-gray-900">
                  {level.name}
                </span>
              </div>
              <p className="text-xs text-gray-600 mt-0.5">
                {level.description}
              </p>
            </div>
          </label>
        ))}
      </div>
    </div>
  );
}
