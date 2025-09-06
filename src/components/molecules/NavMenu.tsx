import NavButton from "../atoms/NavButton";

interface NavMenuItem {
  label: string;
  href: string;
  variant?: "default" | "primary";
  isActive?: boolean;
}

interface NavMenuProps {
  items: NavMenuItem[];
  className?: string;
}

export default function NavMenu({ items, className = "" }: NavMenuProps) {
  return (
    <nav className={`flex items-center space-x-6 ${className}`}>
      {items.map((item, index) => (
        <NavButton
          key={index}
          href={item.href}
          variant={item.variant}
          isActive={item.isActive}
        >
          {item.label}
        </NavButton>
      ))}
    </nav>
  );
}
