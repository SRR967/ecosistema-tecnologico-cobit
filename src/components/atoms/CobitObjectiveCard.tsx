interface CobitObjectiveCardProps {
  code: string;
  title: string;
  domain: "EDM" | "APO" | "BAI" | "DSS" | "MEA";
  isSelected?: boolean;
  capabilityLevel?: number;
  onClick?: () => void;
  className?: string;
}

export default function CobitObjectiveCard({
  code,
  title,
  // domain,
  isSelected = false,
  capabilityLevel,
  onClick,
  className = "",
}: CobitObjectiveCardProps) {
  const getDomainColor = () => {
    return "var(--cobit-red)"; // Rojo COBIT para todos los dominios
  };

  const getLevelColor = (level: number): string => {
    switch (level) {
      case 1:
        return "#9AA0A6"; // Gris
      case 2:
        return "#4FB4FF"; // Azul claro
      case 3:
        return "#0594FF"; // Azul
      case 4:
        return "#E25088"; // Rosa
      case 5:
        return "#78206E"; // Morado
      default:
        return "#F3F4F6"; // Gris por defecto
    }
  };

  return (
    <div
      onClick={onClick}
      className={`
        rounded p-2 cursor-pointer transition-all duration-200 hover:shadow-md
        ${
          isSelected
            ? "ring-2 ring-offset-1 shadow-lg"
            : "hover:border-opacity-70"
        }
        ${className}
      `}
      style={{
        backgroundColor: isSelected ? "#D1D5DB" : "white",
        border:
          isSelected && capabilityLevel
            ? `3px solid ${getLevelColor(capabilityLevel)}`
            : isSelected
            ? `3px solid ${getDomainColor()}`
            : `2px solid ${getDomainColor()}`,
        boxShadow: isSelected
          ? `0 0 0 1px ${
              isSelected && capabilityLevel
                ? getLevelColor(capabilityLevel)
                : getDomainColor()
            }, 0 4px 6px -1px rgba(0, 0, 0, 0.1)`
          : undefined,
        minHeight: "60px",
      }}
    >
      <div className="flex flex-col h-full">
        <div className="flex justify-between items-start mb-1">
          <h4 className="font-bold text-xs" style={{ color: getDomainColor() }}>
            {code}
          </h4>
          {capabilityLevel && (
            <span
              className="text-xs font-bold px-1 py-0.5 rounded text-white flex-shrink-0"
              style={{
                backgroundColor: getDomainColor(),
                fontSize: "10px",
                minWidth: "18px",
                height: "16px",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                lineHeight: "1",
              }}
              title={`Nivel de Capacidad ${capabilityLevel}`}
            >
              L{capabilityLevel}
            </span>
          )}
        </div>
        <p className="text-xs text-gray-700 leading-tight flex-1 line-clamp-2">
          {title}
        </p>
      </div>
    </div>
  );
}
