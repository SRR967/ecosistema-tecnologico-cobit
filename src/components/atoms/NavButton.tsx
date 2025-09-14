"use client";

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
    "px-4 py-2 rounded-md transition-colors duration-200 text-b1 cursor-pointer";

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

  // Handler para navegación con router como backup
  const handleNavigation = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();

    if (href) {
      // Usar navegación directa sin verificaciones de window
      // para evitar problemas de hidratación
      setTimeout(() => {
        window.location.href = href;
      }, 100);
    }
  };

  if (href) {
    return (
      <button
        className={combinedClassName}
        style={dynamicStyles}
        onClick={handleNavigation}
        type="button"
      >
        {children}
      </button>
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
