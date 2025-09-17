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
        <InfoSection title="¿Qué es nuestro ecosistema tecnológico?">
          <p>
            El ecosistema tecnológico se concibe como un entorno que integra los
            Objetivos de Gobierno y Gestión (OGG) de COBIT 2019 con sus
            prácticas y actividades correspondientes, vinculándolos con
            herramientas de TI que hacen posible su implementación. Este modelo
            permite visualizar cómo cada objetivo se despliega en prácticas y
            actividades específicas, y cómo dichas actividades encuentran
            soporte en soluciones tecnológicas concretas. De esta manera, el
            ecosistema ofrece una visión que facilita identificar qué
            herramientas respaldan los distintos niveles del marco, analizar su
            cobertura y orientar la ejecución de hojas de ruta en contextos
            organizacionales reales.
          </p>
        </InfoSection>

        {/* Propósito del proyecto */}
        <InfoSection title="Propósito del proyecto">
          <p>
            El propósito central de este proyecto es posibilitar la
            implementación de hojas de ruta basadas en COBIT 2019. Este marco,
            ampliamente adoptado por las organizaciones, orienta la toma de
            decisiones estratégicas a través de Objetivos de Gobierno y Gestión
            (OGG), que se desglosan en procesos, prácticas y actividades. A
            partir de estos elementos se construyen hojas de ruta que indican
            qué pasos seguir para su aplicación. Sin embargo, uno de los
            principales desafíos identificados radica en que COBIT 2019, a pesar
            de ser un marco ampliamente reconocido, no ofrece una guía explícita
            sobre cómo implementar en la práctica las actividades propuestas ni
            qué herramientas de TI utilizar para soportarlas. En este contexto
            surge la pregunta central que da sentido al proyecto: ¿cómo llevar a
            la práctica estas hojas de ruta y con qué herramientas de TI es
            posible hacerlo?.
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
