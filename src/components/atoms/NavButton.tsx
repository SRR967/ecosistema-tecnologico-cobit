interface NavButtonProps {
  children: React.ReactNode;
  href?: string;
  onClick?: () => void;
  variant?: "default" | "primary";
  isActive?: boolean;
  className?: string;
}

export default function NavButton({
  children,
  href,
  onClick,
  variant = "default",
  isActive = false,
  className = "",
}: NavButtonProps) {
  const baseStyles =
    "px-4 py-2 rounded-md transition-colors duration-200 text-b1";

  const variantStyles = {
    default: isActive ? "font-bold" : "hover:bg-gray-50 font-medium",
    primary: isActive
      ? "font-bold bg-transparent border-2"
      : "text-white font-medium",
  };

  // Estilos dinámicos usando CSS variables
  const dynamicStyles = isActive
    ? {
        color: "var(--cobit-red)",
        borderColor:
          isActive && variant === "primary" ? "var(--cobit-red)" : undefined,
      }
    : variant === "primary"
    ? { backgroundColor: "var(--cobit-blue)" }
    : { color: "var(--cobit-blue)" };

  const combinedClassName = `${baseStyles} ${variantStyles[variant]} ${className}`;

  if (href) {
    return (
      <a href={href} className={combinedClassName} style={dynamicStyles}>
        {children}
      </a>
    );
  }

  return (
    <button
      onClick={onClick}
      className={combinedClassName}
      style={dynamicStyles}
    >
      {children}
    </button>
  );
}
