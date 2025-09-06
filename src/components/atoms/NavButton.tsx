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
    default: isActive
      ? "text-cobit-red font-bold"
      : "text-cobit-blue hover:text-cobit-red hover:bg-gray-50 font-medium",
    primary: "bg-cobit-blue text-white hover:bg-opacity-90 font-medium",
  };

  const combinedClassName = `${baseStyles} ${variantStyles[variant]} ${className}`;

  if (href) {
    return (
      <a href={href} className={combinedClassName}>
        {children}
      </a>
    );
  }

  return (
    <button onClick={onClick} className={combinedClassName}>
      {children}
    </button>
  );
}
