interface HeroSectionProps {
  title: string;
  className?: string;
}

export default function HeroSection({
  title,
  className = "",
}: HeroSectionProps) {
  return (
    <section
      className={`bg-gradient-to-r from-blue-50 to-red-50 py-16 px-6 ${className}`}
    >
      <div className="max-w-4xl mx-auto text-center">
        <h1
          className="text-4xl md:text-5xl font-bold leading-tight mb-8"
          style={{ color: "var(--cobit-blue)" }}
        >
          {title}
        </h1>
        <div
          className="w-24 h-1 mx-auto"
          style={{ backgroundColor: "var(--cobit-red)" }}
        ></div>
      </div>
    </section>
  );
}
