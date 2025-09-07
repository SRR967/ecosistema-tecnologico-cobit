interface ToggleSwitchProps {
  label: string;
  isOn: boolean;
  onToggle: (isOn: boolean) => void;
  offLabel: string;
  onLabel: string;
  className?: string;
}

export default function ToggleSwitch({
  label,
  isOn,
  onToggle,
  offLabel,
  onLabel,
  className = "",
}: ToggleSwitchProps) {
  return (
    <div className={`space-y-3 ${className}`}>
      <label
        className="block text-sm font-medium"
        style={{ color: "var(--cobit-blue)" }}
      >
        {label}
      </label>
      <div className="flex items-center space-x-3">
        <span
          className={`b1 ${!isOn ? "font-bold" : ""}`}
          style={{ color: !isOn ? "var(--cobit-red)" : "var(--cobit-gray)" }}
        >
          {offLabel}
        </span>
        <button
          onClick={() => onToggle(!isOn)}
          className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2`}
          style={{
            backgroundColor: isOn ? "var(--cobit-blue)" : "var(--cobit-gray)",
          }}
        >
          <span
            className={`inline-block h-4 w-4 transform rounded-full bg-white transition ${
              isOn ? "translate-x-6" : "translate-x-1"
            }`}
          />
        </button>
        <span
          className={`b1 ${isOn ? "font-bold" : ""}`}
          style={{ color: isOn ? "var(--cobit-red)" : "var(--cobit-gray)" }}
        >
          {onLabel}
        </span>
      </div>
    </div>
  );
}
