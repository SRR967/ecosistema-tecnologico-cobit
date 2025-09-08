interface ToggleButtonGroupProps {
  label: string;
  options: { value: string; label: string }[];
  selectedValue: string;
  onChange: (value: string) => void;
  className?: string;
}

export default function ToggleButtonGroup({
  label,
  options,
  selectedValue,
  onChange,
  className = "",
}: ToggleButtonGroupProps) {
  return (
    <div className={`space-y-3 ${className}`}>
      <label
        className="block text-sm font-medium"
        style={{ color: "var(--cobit-blue)" }}
      >
        {label}
      </label>
      <div className="flex bg-gray-100 rounded-lg p-1">
        {options.map((option) => (
          <button
            key={option.value}
            onClick={() => onChange(option.value)}
            className={`flex-1 px-4 py-2 text-sm font-medium rounded-md transition-all duration-200 b1 ${
              selectedValue === option.value
                ? "text-white shadow-sm"
                : "text-gray-600 hover:text-gray-900"
            }`}
            style={{
              backgroundColor:
                selectedValue === option.value
                  ? "var(--cobit-blue)"
                  : "transparent",
            }}
          >
            {option.label}
          </button>
        ))}
      </div>
    </div>
  );
}
