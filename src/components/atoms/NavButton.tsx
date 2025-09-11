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
    console.log(`🚨 CLICK DETECTADO en NavButton`);
    console.log(`🔗 Navegando a: ${href}`);
    console.log(`⭐ Event target:`, e.target);
    console.log(`⭐ Current target:`, e.currentTarget);

    e.preventDefault();
    e.stopPropagation();

    if (href && typeof window !== "undefined") {
      // Detectar si estamos en la página ecosistema
      const currentPath = window.location.pathname;
      console.log(`📍 Página actual: ${currentPath}`);

      // Siempre usar navegación directa para debugging
      console.log(`🚀 FORZANDO navegación directa para debugging`);
      console.log(`🚀 Navegando directamente a: ${href}`);

      // Usar setTimeout para asegurar que no hay interferencias
      setTimeout(() => {
        console.log(`⏰ Ejecutando navegación después de timeout`);
        if (typeof window !== "undefined") {
          window.location.href = href;
        }
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
