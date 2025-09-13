import CobitObjectiveCard from "../atoms/CobitObjectiveCard";

interface Objective {
  code: string;
  title: string;
}

interface ObjectiveWithLevel {
  code: string;
  level: number;
}

interface DomainSectionProps {
  domain: "EDM" | "APO" | "BAI" | "DSS" | "MEA";
  title: string;
  objectives: Objective[];
  selectedObjectives?: ObjectiveWithLevel[];
  onObjectiveClick?: (code: string) => void;
  layout: "horizontal" | "vertical";
  className?: string;
}

export default function DomainSection({
  domain,
  title,
  objectives,
  selectedObjectives = [],
  onObjectiveClick,
  layout,
  className = "",
}: DomainSectionProps) {
  const getDomainColor = () => {
    return "var(--cobit-red)"; // Rojo COBIT para todos los dominios
  };

  const getGridClass = () => {
    if (layout === "vertical") {
      return "grid grid-cols-1 gap-1";
    }

    // Layout horizontal con diferentes columnas según el dominio
    switch (domain) {
      case "EDM":
        return "grid grid-cols-5 gap-1";
      case "APO":
        return "grid grid-cols-7 gap-1"; // 14 objetivos en 2 filas
      case "BAI":
        return "grid grid-cols-6 gap-1"; // 11 objetivos
      case "DSS":
        return "grid grid-cols-6 gap-1";
      default:
        return "grid grid-cols-4 gap-1";
    }
  };

  return (
    <div className={`flex flex-col h-full ${className}`}>
      <div
        className="text-white text-center py-1 mb-1 rounded-t-lg font-bold text-sm"
        style={{ backgroundColor: getDomainColor() }}
      >
        {title}
      </div>
      <div className={`${getGridClass()} flex-1`}>
        {objectives
          .filter((objective) => objective && objective.code)
          .map((objective) => {
            const selectedObj = selectedObjectives?.find(
              (obj) => obj.code === objective.code
            );
            return (
              <CobitObjectiveCard
                key={objective.code}
                code={objective.code}
                title={objective.title}
                domain={domain}
                isSelected={!!selectedObj}
                capabilityLevel={selectedObj?.level}
                onClick={() => onObjectiveClick?.(objective.code)}
              />
            );
          })}
      </div>
    </div>
  );
}
