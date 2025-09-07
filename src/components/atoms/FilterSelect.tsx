interface FilterSelectProps {
  label: string;
  options: string[];
  value: string;
  onChange: (value: string) => void;
  className?: string;
}

export default function FilterSelect({
  label,
  options,
  value,
  onChange,
  className = "",
}: FilterSelectProps) {
  return (
    <div className={`space-y-2 ${className}`}>
      <label
        className="block text-sm font-medium"
        style={{ color: "var(--cobit-blue)" }}
      >
        {label}
      </label>
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 b1 text-black"
        style={{
          maxWidth: "280px",
          overflow: "hidden",
          textOverflow: "ellipsis",
          whiteSpace: "nowrap",
        }}
      >
        <option value="">Seleccionar {label.toLowerCase()}</option>
        {options.map((option) => (
          <option key={option} value={option}>
            {option}
          </option>
        ))}
      </select>
    </div>
  );
}
