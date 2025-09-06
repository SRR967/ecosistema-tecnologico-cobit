import NavBar from "../components/organisms/NavBar";
import HeroSection from "../components/organisms/HeroSection";
import InfoSection from "../components/molecules/InfoSection";
import TeamCard from "../components/molecules/TeamCard";

export default function Home() {
  const teamMembers = [
    { name: "Johana Paola Palacio Osorio" },
    { name: "Jesús Santiago Ramón Ramos" },
    { name: "Jhoan Esteban Soler Giraldo" },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      <NavBar currentPath="/" />

      {/* Hero Section */}
      <HeroSection title="Ecosistema tecnológico para la implementación de hojas de ruta de COBIT 2019" />

      {/* Main Content */}
      <div className="max-w-6xl mx-auto py-12 px-4 space-y-8">
        {/* ¿Qué es COBIT 2019? */}
        <InfoSection title="¿Qué es COBIT 2019?">
          <p>
            COBIT 2019 es un marco de referencia desarrollado por ISACA para la
            gobernanza y gestión de las tecnologías de la información en las
            organizaciones. Su finalidad es proporcionar un conjunto
            estructurado de principios, objetivos y prácticas que faciliten la
            creación de valor a partir de la tecnología, la mitigación de
            riesgos relacionados con la información y la optimización de los
            recursos disponibles. Esta versión actualizada de COBIT se adapta a
            las necesidades actuales de transformación digital, ofreciendo una
            guía flexible que puede ajustarse a distintos tamaños de
            organización y a contextos empresariales diversos.
          </p>
        </InfoSection>

        {/* Propósito del proyecto */}
        <InfoSection title="Propósito del proyecto">
          <p>
            El proyecto de grado tiene como propósito diseñar un ecosistema
            tecnológico que permita llevar a la práctica las hojas de ruta
            planteadas por COBIT 2019. Para ello, se propone identificar y
            organizar herramientas de tecnologías de la información que den
            soporte directo a las prácticas y actividades definidas en los
            Objetivos de Gobierno y Gestión (OGG). De esta manera, se busca
            cerrar la brecha existente entre el nivel conceptual del marco y su
            aplicación en escenarios organizacionales, ofreciendo una estructura
            tecnológica que acompañe desde la planificación hasta la evaluación
            de las acciones propuestas.
          </p>
        </InfoSection>

        {/* Sobre esta aplicación */}
        <InfoSection title="Sobre esta aplicación">
          <p>
            La aplicación web constituye un prototipo académico que materializa
            el diseño del ecosistema tecnológico. A través de sus diferentes
            módulos, se permite gestionar hojas de ruta personalizadas,
            visualizar relaciones entre objetivos y herramientas, y analizar de
            manera detallada cómo las actividades descritas en COBIT 2019 pueden
            ser respaldadas con tecnologías específicas. El diseño de esta
            aplicación no pretende ser un sistema productivo definitivo, sino un
            instrumento de validación que evidencia la viabilidad de traducir
            lineamientos estratégicos en soluciones digitales interactivas y
            comprensibles.
          </p>
        </InfoSection>

        {/* Team Card */}
        <TeamCard
          institution="Universidad del Quindío – Facultad de Ingeniería – Programa de Ingeniería de Sistemas y Computación."
          members={teamMembers}
          director="Luis Eduardo Sepúlveda Rodríguez – Ingeniero de Sistemas y Computación, Magíster en Software Libre, Doctorado en Ingeniería (énfasis en Ciencias de la Computación)."
          className="mt-12"
        />
      </div>
    </div>
  );
}
