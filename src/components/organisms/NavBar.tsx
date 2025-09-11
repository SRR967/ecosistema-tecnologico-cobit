"use client";

import Logo from "../atoms/Logo";
import NavMenu from "../molecules/NavMenu";

const navigationItems = [
  { label: "Inicio", href: "/" },
  { label: "Ecosistema", href: "/ecosistema" },
  {
    label: "Crear tu Ecosistema",
    href: "/crear",
  },
];

interface NavBarProps {
  currentPath?: string;
  className?: string;
}

export default function NavBar({
  currentPath = "/",
  className = "",
}: NavBarProps) {
  // Marcar el item activo basado en la ruta actual
  const navigationItemsWithActive = navigationItems.map((item) => ({
    ...item,
    isActive: currentPath === item.href,
  }));

  return (
    <header
      className={`bg-white shadow-sm border-b border-gray-200 ${className}`}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo/Brand */}
          <div className="flex-shrink-0">
            <Logo />
          </div>

          {/* Navigation Menu */}
          <div className="hidden md:block">
            <NavMenu items={navigationItemsWithActive} />
          </div>

          {/* Mobile menu button (placeholder for future implementation) */}
          <div className="md:hidden">
            <button className="text-cobit-gray hover:text-cobit-blue">
              <svg
                className="h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 6h16M4 12h16M4 18h16"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </header>
  );
}
