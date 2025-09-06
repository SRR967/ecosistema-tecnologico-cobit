interface InfoSectionProps {
  title: string;
  children: React.ReactNode;
  className?: string;
}

export default function InfoSection({
  title,
  children,
  className = "",
}: InfoSectionProps) {
  return (
    <section className={`p-6 space-y-4 ${className}`}>
      <h2 className="text-2xl font-bold" style={{ color: "var(--cobit-blue)" }}>
        {title}
      </h2>
      <div className="text-justify text-gray-700 b1">{children}</div>
    </section>
  );
}
