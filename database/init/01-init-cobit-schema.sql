-- Inicialización del esquema COBIT 2019
-- Este script crea las tablas si no existen

-- Crear extensión UUID si no existe
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- Reinicio ordenado (para desarrollo)
-- ============================================================================
DROP TABLE IF EXISTS actividad   CASCADE;
DROP TABLE IF EXISTS practica    CASCADE;
DROP TABLE IF EXISTS herramienta CASCADE;
DROP TABLE IF EXISTS ogg         CASCADE;
DROP TABLE IF EXISTS dominio     CASCADE;

-- ============================================================================
-- 0) Dominio (COBIT 2019)  [sin campo descripcion]
-- ============================================================================
CREATE TABLE dominio (
  codigo  TEXT PRIMARY KEY
          CHECK (codigo ~ '^[A-Z]{3}$'),   -- EDM, APO, BAI, DSS, MEA
  nombre  TEXT NOT NULL
);

-- Carga inicial de dominios COBIT 2019
INSERT INTO dominio (codigo, nombre) VALUES
  ('EDM', 'Evaluar, Dirigir y Monitorear'),
  ('APO', 'Alinear, Planificar y Organizar'),
  ('BAI', 'Construir, Adquirir e Implementar'),
  ('DSS', 'Entregar, Dar Soporte y Servicio'),
  ('MEA', 'Monitorizar, Evaluar y Valorar');

-- ============================================================================
-- 1) OGG (Objetivo de Gobierno/Gestión)
--    - dominio_codigo es columna generada (STORED)
--    - FK sin ON UPDATE CASCADE (usa RESTRICT)
-- ============================================================================
CREATE TABLE ogg (
  id             TEXT PRIMARY KEY,
  nombre         TEXT NOT NULL,
  proposito      TEXT NOT NULL,
  CHECK (id ~ '^[A-Z]{3}[0-9]{2}$'),

  dominio_codigo TEXT GENERATED ALWAYS AS (substr(id, 1, 3)) STORED,

  CONSTRAINT fk_ogg_dominio
    FOREIGN KEY (dominio_codigo)
    REFERENCES dominio(codigo)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT
);

CREATE INDEX idx_ogg_dominio_codigo ON ogg(dominio_codigo);

-- ============================================================================
-- 2) Práctica
-- ============================================================================
CREATE TABLE practica (
  practica_id  TEXT PRIMARY KEY,
  ogg_id       TEXT NOT NULL REFERENCES ogg(id)
               ON UPDATE CASCADE
               ON DELETE RESTRICT,
  nombre       TEXT NOT NULL,
  CHECK (practica_id ~ '^[A-Z]{3}[0-9]{2}-P[0-9]{2}$')  -- p.ej., DSS01-P01
);

CREATE INDEX idx_practica_ogg_id ON practica(ogg_id);

-- ============================================================================
-- 3) Herramienta
-- ============================================================================
CREATE TABLE herramienta (
  id               TEXT PRIMARY KEY,
  categoria        TEXT NOT NULL,
  descripcion      TEXT NOT NULL,
  casos_uso        TEXT[] NOT NULL,
  tipo_herramienta TEXT NOT NULL
);

-- ============================================================================
-- 4) Actividad
-- ============================================================================
CREATE TABLE actividad (
  actividad_id     TEXT PRIMARY KEY,
  practica_id      TEXT NOT NULL REFERENCES practica(practica_id)
                    ON UPDATE CASCADE
                    ON DELETE RESTRICT,
  descripcion      TEXT NOT NULL,
  nivel_capacidad  SMALLINT NOT NULL CHECK (nivel_capacidad BETWEEN 1 AND 5),
  herramienta_id   TEXT REFERENCES herramienta(id)
                    ON UPDATE CASCADE
                    ON DELETE RESTRICT,
  justificacion    TEXT NOT NULL,
  observaciones    TEXT,
  integracion      TEXT,
  CHECK (actividad_id ~ '^[A-Z]{3}[0-9]{2}-P[0-9]{2}-A[0-9]{2}$')  -- DSS01-P01-A01
);

CREATE INDEX idx_actividad_practica_id    ON actividad(practica_id);
CREATE INDEX idx_actividad_herramienta_id ON actividad(herramienta_id);


-- ─────────────────────────────────────────────────────────────────────────────
-- INSERCIÓN DE DATOS - TABLA OGG
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO ogg (id, nombre, proposito) VALUES 

-- Dominio APO (Alinear, Planificar y Organizar)
('APO01', 'Marco de gestión de I&T gestionado', 'Implementar un enfoque de gestión consistente para cumplir con los requisitos de gobernanza empresarial, que cubra componentes de gobernanza tales como procesos de gestión, estructuras organizacionales, roles y responsabilidades, actividades confiables y repetibles, elementos de información, políticas y procedimientos, habilidades y competencias, cultura y comportamiento, y servicios, infraestructura y aplicaciones.'),
('APO02', 'Estrategia gestionada', 'Apoyar la estrategia de transformación digital de la organización y generar el valor deseado mediante una hoja de ruta de cambios graduales. Aplicar un enfoque holístico de I&T, garantizando que cada iniciativa esté claramente conectada con una estrategia global. Impulsar el cambio en todos los aspectos de la organización, desde canales y procesos hasta datos, cultura, habilidades, modelo operativo e incentivos.'),
('APO03', 'Arquitectura empresarial gestionada', 'Representar los diferentes bloques que conforman la empresa y sus interrelaciones, así como los principios que guían su diseño y evolución a lo largo del tiempo, para permitir una entrega estándar, responsiva y eficiente de los objetivos operativos y estratégicos.'),
('APO04', 'Innovación gestionada', 'Lograr ventaja competitiva, innovación empresarial, mejor experiencia del cliente y mayor eficacia y eficiencia operativa mediante la explotación de los desarrollos de I&T y las tecnologías emergentes.'),
('APO05', 'Cartera gestionada', 'Optimizar el rendimiento de la cartera general de programas en respuesta al desempeño individual de programas, productos y servicios y a las cambiantes prioridades y demandas de la empresa.'),
('APO06', 'Presupuesto y costos administrados', 'Fomentar la colaboración entre las partes interesadas de TI y la empresa para facilitar el uso eficaz y eficiente de los recursos de TI y brindar transparencia y rendición de cuentas sobre el coste y el valor comercial de las soluciones y servicios. Facilitar la toma de decisiones informadas en la empresa sobre el uso de las soluciones y servicios de TI.'),
('APO07', 'Recursos humanos gestionados', 'Optimizar las capacidades de los recursos humanos para cumplir los objetivos empresariales.'),
('APO08', 'Relaciones gestionadas', 'Habilitar los conocimientos, las habilidades y los comportamientos adecuados para crear mejores resultados, mayor confianza, confianza mutua y un uso eficaz de los recursos que estimulen una relación productiva con las partes interesadas del negocio.'),
('APO09', 'Acuerdos de servicios gestionados', 'Garantizar que los productos, servicios y niveles de servicio de I&T satisfagan las necesidades empresariales actuales y futuras.'),
('APO10', 'Proveedores gestionados', 'Optimizar las capacidades de I&T disponibles para respaldar la estrategia y la hoja de ruta de I&T, minimizar el riesgo asociado con proveedores de bajo rendimiento o que no cumplen con las normas y garantizar precios competitivos.'),
('APO11', 'Calidad gestionada', 'Garantizar la entrega consistente de soluciones y servicios tecnológicos para cumplir con los requisitos de calidad de la empresa y satisfacer las necesidades de las partes interesadas.'),
('APO12', 'Riesgo gestionado', 'Integrar la gestión del riesgo empresarial relacionado con I&T con la gestión general del riesgo empresarial (ERM) y equilibrar los costos y beneficios de la gestión del riesgo empresarial relacionado con I&T.'),
('APO13', 'Seguridad administrada', 'Mantener el impacto y la ocurrencia de incidentes de privacidad de seguridad de la información dentro de los niveles de tolerancia al riesgo de la empresa.'),
('APO14', 'Datos gestionados', 'Garantizar la utilización eficaz de los activos de datos críticos para lograr las metas y objetivos empresariales.'),

-- Dominio BAI (Construir, Adquirir e Implementar)
('BAI01', 'Programas administrados', 'Obtenga el valor comercial deseado y reduzca el riesgo de retrasos inesperados, costos y pérdida de valor. Para ello, mejore la comunicación y la participación de las empresas y los usuarios finales, garantice el valor y la calidad de los entregables del programa y el seguimiento de los proyectos dentro de los programas, y maximice la contribución del programa a la cartera de inversiones.'),
('BAI02', 'Definición de requisitos gestionados', 'Crear soluciones óptimas que satisfagan las necesidades de la empresa y minimicen el riesgo.'),
('BAI03', 'Identificación y desarrollo de soluciones gestionadas', 'Garantizar una entrega ágil y escalable de productos y servicios digitales. Establecer soluciones oportunas y rentables (tecnología, procesos de negocio y flujos de trabajo) capaces de respaldar los objetivos estratégicos y operativos de la empresa.'),
('BAI04', 'Disponibilidad y capacidad gestionadas', 'Mantener la disponibilidad del servicio, la gestión eficiente de los recursos y la optimización del rendimiento del sistema mediante la predicción del rendimiento futuro y los requisitos de capacidad.'),
('BAI05', 'Cambio organizacional gestionado', 'Preparar y comprometer a las partes interesadas para el cambio empresarial y reducir el riesgo de fracaso.'),
('BAI06', 'Cambios de TI gestionados', 'Permitir una implementación rápida y confiable de los cambios en la empresa. Mitigar el riesgo de afectar negativamente la estabilidad o la integridad del entorno modificado.'),
('BAI07', 'Aceptación y transición de cambios de TI gestionados', 'Implementar soluciones de forma segura y de acuerdo con las expectativas y resultados acordados.'),
('BAI08', 'Conocimiento gestionado', 'Proporcionar el conocimiento y la información necesarios para apoyar a todo el personal en la gobernanza y gestión de la I&T empresarial y permitir una toma de decisiones informada.'),
('BAI09', 'Activos gestionados', 'Contabilizar todos los activos de I&T y optimizar el valor proporcionado por su uso.'),
('BAI10', 'Configuración administrada', 'Proporcionar información suficiente sobre los activos del servicio para permitir su gestión eficaz. Evaluar el impacto de los cambios y gestionar las incidencias del servicio.'),
('BAI11', 'Proyectos gestionados', 'Logre los resultados definidos del proyecto y reduzca el riesgo de retrasos inesperados, costos y pérdida de valor mejorando la comunicación y la participación de la empresa y los usuarios finales. Garantice el valor y la calidad de los entregables del proyecto y maximice su contribución a los programas y la cartera de inversiones definidos.'),

-- Dominio DSS (Entregar, Dar Soporte y Servicio)
('DSS01', 'Operaciones gestionadas', 'Entregar resultados de productos y servicios operativos de I&T según lo planificado.'),
('DSS02', 'Solicitudes de servicio gestionadas e incidentes', 'Aumente la productividad y minimice las interrupciones mediante la rápida resolución de consultas e incidentes de los usuarios. Evalúe el impacto de los cambios y gestione los incidentes de servicio. Resuelva las solicitudes de los usuarios y restablezca el servicio en respuesta a los incidentes.'),
('DSS03', 'Problemas gestionados', 'Aumente la disponibilidad, mejore los niveles de servicio, reduzca los costos, mejore la comodidad y la satisfacción del cliente al reducir la cantidad de problemas operativos e identifique las causas fundamentales como parte de la resolución de problemas.'),
('DSS04', 'Continuidad gestionada', 'Adaptarse rápidamente, continuar las operaciones comerciales y mantener la disponibilidad de recursos e información a un nivel aceptable para la empresa en caso de una interrupción significativa (por ejemplo, amenazas, oportunidades, demandas).'),
('DSS05', 'Servicios de seguridad gestionados', 'Minimizar el impacto empresarial de las vulnerabilidades e incidentes de seguridad de la información operativa.'),
('DSS06', 'Controles de procesos empresariales gestionados', 'Mantener la integridad de la información y la seguridad de los activos de información manejados dentro de los procesos de negocio en la empresa o su operación subcontratada.'),

-- Dominio EDM (Evaluar, Dirigir y Monitorizar)
('EDM01', 'Establecimiento y mantenimiento de un marco de gobernanza garantizado', 'Proporcionar un enfoque coherente, integrado y alineado con el enfoque de gobernanza empresarial. Las decisiones relacionadas con I&T se toman en consonancia con las estrategias y objetivos de la empresa, y se obtiene el valor deseado. Para ello, es necesario garantizar que los procesos relacionados con I&T se supervisen de forma eficaz y transparente; que se confirme el cumplimiento de los requisitos legales, contractuales y regulatorios; y que se cumplan los requisitos de gobernanza para los miembros del consejo de administración.'),
('EDM02', 'Entrega de beneficios garantizada', 'Obtenga un valor óptimo de las iniciativas, servicios y activos basados en I&T; una entrega rentable de soluciones y servicios; y una imagen confiable y precisa de los costos y los posibles beneficios para que las necesidades del negocio sean respaldadas de manera eficaz y eficiente.'),
('EDM03', 'Optimización de riesgos garantizada', 'Asegúrese de que el riesgo empresarial relacionado con I&T no exceda el apetito y la tolerancia al riesgo de la empresa, que el impacto del riesgo de I&T en el valor empresarial se identifique y gestione, y que el potencial de fallas de cumplimiento se minimice.'),
('EDM04', 'Optimización de recursos garantizada', 'Asegúrese de que las necesidades de recursos de la empresa se satisfagan de manera óptima, se optimicen los costos de I&T y haya una mayor probabilidad de obtención de beneficios y preparación para cambios futuros.'),
('EDM05', 'Participación garantizada de las partes interesadas', 'Asegúrese de que las partes interesadas apoyen la estrategia y la hoja de ruta de I&T, que la comunicación con ellas sea eficaz y oportuna, y que se establezcan las bases para la elaboración de informes que permitan mejorar el rendimiento. Identifique las áreas de mejora y confirme que los objetivos y estrategias de I&T estén alineados con la estrategia de la empresa.'),

-- Dominio MEA (Monitorizar, Evaluar y Valorar)
('MEA01', 'Monitoreo del desempeño y la conformidad gestionados', 'Proporcionar transparencia en el desempeño y la conformidad e impulsar el logro de los objetivos.'),
('MEA02', 'Sistema Gestionado de Control Interno', 'Obtener transparencia para los principales interesados sobre la adecuación del sistema de controles internos y así brindar confianza en las operaciones, seguridad en el logro de los objetivos empresariales y una adecuada comprensión del riesgo residual.'),
('MEA03', 'Cumplimiento gestionado de los requisitos externos', 'Asegúrese de que la empresa cumpla con todos los requisitos externos aplicables.'),
('MEA04', 'Aseguramiento administrado', 'Permitir a la organización diseñar y desarrollar iniciativas de aseguramiento eficientes y efectivas, proporcionando orientación sobre la planificación, el alcance, la ejecución y el seguimiento de las revisiones de aseguramiento, utilizando una hoja de ruta basada en enfoques de aseguramiento bien aceptados.');

-- ─────────────────────────────────────────────────────────────────────────────
-- INSERCIÓN DE DATOS - TABLA PRACTICA
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO practica (practica_id, ogg_id, nombre) VALUES

('DSS01-P01', 'DSS01', 'Realizar procedimientos operativos.'),

('DSS01-P02', 'DSS01', 'Gestionar servicios de I&T externalizados.'),

('DSS01-P03', 'DSS01', 'Supervisar la infraestructura de I&T.'),

('DSS01-P04', 'DSS01', 'Gestionar el medio ambiente.'),

('DSS01-P05', 'DSS01', 'Administrar instalaciones.'),

('DSS02-P01', 'DSS02', 'Definir esquemas de clasificación para incidentes y solicitudes de servicio.'),

('DSS02-P02', 'DSS02', 'Registrar, clasificar y priorizar solicitudes e incidentes.'),

('DSS02-P03', 'DSS02', 'Verificar, aprobar y cumplir solicitudes de servicio.'),

('DSS02-P04', 'DSS02', 'Investigar, diagnosticar y asignar incidentes.'),

('DSS02-P05', 'DSS02', 'Resolver y recuperarse de incidentes.'),

('DSS02-P06', 'DSS02', 'Cerrar solicitudes de servicio e incidentes.'),

('DSS02-P07', 'DSS02', 'Realizar un seguimiento del estado y generar informes.'),

('DSS03-P01', 'DSS03', 'Identificar y clasificar problemas.'),

('DSS03-P02', 'DSS03', 'Investigar y diagnosticar problemas.'),

('DSS03-P03', 'DSS03', 'Plantear errores conocidos.'),

('DSS03-P04', 'DSS03', 'Resolver y cerrar problemas.'),

('DSS03-P05', 'DSS03', 'Realizar una gestión proactiva de problemas.'),

('DSS04-P01', 'DSS04', 'Definir la política, objetivos y alcance de la continuidad del negocio.'),

('DSS04-P02', 'DSS04', 'Mantener la resiliencia empresarial.'),

('DSS04-P03', 'DSS04', 'Desarrollar e implementar una respuesta de continuidad de negocio.'),

('DSS04-P04', 'DSS04', 'Ejercitar, probar y revisar el plan de continuidad del negocio (BCP) y el plan de respuesta ante desastres (DRP).'),

('DSS04-P05', 'DSS04', 'Revisar, mantener y mejorar los planes de continuidad.'),

('DSS04-P06', 'DSS04', 'Realizar capacitación sobre plan de continuidad.'),

('DSS04-P07', 'DSS04', 'Gestionar los acuerdos de respaldo.'),

('DSS04-P08', 'DSS04', 'Realizar una revisión posterior a la reanudación.'),

('DSS05-P01', 'DSS05', 'Protéjase contra malware.'),

('DSS05-P02', 'DSS05', 'Gestionar la seguridad de la red y la conectividad.'),

('DSS05-P03', 'DSS05', 'Gestionar la seguridad de los puntos finales.'),

('DSS05-P04', 'DSS05', 'Gestionar la identidad del usuario y el acceso lógico.'),

('DSS05-P05', 'DSS05', 'Gestionar el acceso físico a los activos de I&T.'),

('DSS05-P06', 'DSS05', 'Gestionar documentos confidenciales y dispositivos de salida.'),

('DSS05-P07', 'DSS05', 'Gestionar vulnerabilidades y supervisar la infraestructura para detectar eventos relacionados con la seguridad.'),

('DSS06-P01', 'DSS06', 'Alinear las actividades de control integradas en los procesos de negocio con los objetivos de la empresa.'),

('DSS06-P02', 'DSS06', 'Controlar el procesamiento de la información.'),

('DSS06-P03', 'DSS06', 'Gestionar roles, responsabilidades, privilegios de acceso y niveles de autoridad.'),

('DSS06-P04', 'DSS06', 'Gestionar errores y excepciones.'),

('DSS06-P05', 'DSS06', 'Garantizar la trazabilidad y rendición de cuentas de los eventos de información.'),

('DSS06-P06', 'DSS06', 'Asegure los activos de información.'),

('BAI01-P01', 'BAI01', 'Mantener un enfoque estándar para la gestión del programa.'),

('BAI01-P02', 'BAI01', 'Iniciar un programa.'),

('BAI01-P03', 'BAI01', 'Gestionar la participación de las partes interesadas.'),

('BAI01-P04', 'BAI01', 'Desarrollar y mantener el plan del programa.'),

('BAI01-P05', 'BAI01', 'Iniciar y ejecutar el programa.'),

('BAI01-P06', 'BAI01', 'Monitorear, controlar e informar sobre los resultados del programa.'),

('BAI01-P07', 'BAI01', 'Gestionar la calidad del programa.'),

('BAI01-P08', 'BAI01', 'Gestionar el riesgo del programa.'),

('BAI01-P09', 'BAI01', 'Cerrar un programa.'),

('BAI02-P01', 'BAI02', 'Definir y mantener los requisitos funcionales y técnicos del negocio.'),

('BAI02-P02', 'BAI02', 'Realizar un estudio de viabilidad y formular soluciones alternativas.'),

('BAI02-P03', 'BAI02', 'Gestionar el riesgo de requisitos.'),

('BAI02-P04', 'BAI02', 'Obtener la aprobación de requisitos y soluciones.'),

('BAI03-P01', 'BAI03', 'Diseñar soluciones de alto nivel.'),

('BAI03-P02', 'BAI03', 'Diseñar componentes detallados de la solución.'),

('BAI03-P03', 'BAI03', 'Desarrollar componentes de la solución.'),

('BAI03-P04', 'BAI03', 'Adquirir componentes de la solución.'),

('BAI03-P05', 'BAI03', 'Construir soluciones.'),

('BAI03-P06', 'BAI03', 'Realizar el aseguramiento de la calidad (QA).'),

('BAI03-P07', 'BAI03', 'Prepárese para probar la solución.'),

('BAI03-P08', 'BAI03', 'Ejecutar pruebas de solución.'),

('BAI03-P09', 'BAI03', 'Gestionar cambios en los requisitos.'),

('BAI03-P10', 'BAI03', 'Mantener soluciones.'),

('BAI03-P11', 'BAI03', 'Definir productos y servicios de TI y mantener la cartera de servicios.'),

('BAI03-P12', 'BAI03', 'Diseñar soluciones basadas en la metodología de desarrollo definida.'),

('BAI04-P01', 'BAI04', 'Evaluar la disponibilidad, el rendimiento y la capacidad actuales y crear una línea de base.'),

('BAI04-P02', 'BAI04', 'Evaluar el impacto empresarial.'),

('BAI04-P03', 'BAI04', 'Planificar los requisitos de servicio nuevos o modificados.'),

('BAI04-P04', 'BAI04', 'Monitorear y revisar la disponibilidad y capacidad.'),

('BAI04-P05', 'BAI04', 'Investigar y abordar problemas de disponibilidad, rendimiento y capacidad.'),

('BAI05-P01', 'BAI05', 'Establecer el deseo de cambiar.'),

('BAI05-P02', 'BAI05', 'Formar un equipo de implementación eficaz.'),

('BAI05-P03', 'BAI05', 'Comunicar la visión deseada.'),

('BAI05-P04', 'BAI05', 'Empoderar a los jugadores e identificar victorias a corto plazo.'),

('BAI05-P05', 'BAI05', 'Habilitar operación y uso.'),

('BAI05-P06', 'BAI05', 'Incorporar nuevos enfoques.'),

('BAI05-P07', 'BAI05', 'Mantener los cambios.'),

('BAI06-P01', 'BAI06', 'Evaluar, priorizar y autorizar solicitudes de cambio.'),

('BAI06-P02', 'BAI06', 'Gestionar cambios de emergencia.'),

('BAI06-P03', 'BAI06', 'Realizar un seguimiento e informar del estado de los cambios.'),

('BAI06-P04', 'BAI06', 'Cerrar y documentar los cambios.'),

('BAI07-P01', 'BAI07', 'Establecer un plan de implementación.'),

('BAI07-P02', 'BAI07', 'Planificar procesos de negocio, sistemas y conversión de datos.'),

('BAI07-P03', 'BAI07', 'Pruebas de aceptación del plan.'),

('BAI07-P04', 'BAI07', 'Establecer un entorno de prueba.'),

('BAI07-P05', 'BAI07', 'Realizar pruebas de aceptación.'),

('BAI07-P06', 'BAI07', 'Promover a producción y gestionar lanzamientos.'),

('BAI07-P07', 'BAI07', 'Proporcionar soporte de producción temprana.'),

('BAI07-P08', 'BAI07', 'Realizar una revisión posterior a la implementación.'),

('BAI08-P01', 'BAI08', 'Identificar y clasificar fuentes de información para la gobernanza y gestión de I&T.'),

('BAI08-P02', 'BAI08', 'Organizar y contextualizar la información en conocimiento.'),

('BAI08-P03', 'BAI08', 'Utilice y comparta el conocimiento.'),

('BAI08-P04', 'BAI08', 'Evaluar y actualizar o retirar información.'),

('BAI09-P01', 'BAI09', 'Identificar y registrar los activos corrientes.'),

('BAI09-P02', 'BAI09', 'Gestionar activos críticos.'),

('BAI09-P03', 'BAI09', 'Gestionar el ciclo de vida de los activos.'),

('BAI09-P04', 'BAI09', 'Optimizar el valor de los activos.'),

('BAI09-P05', 'BAI09', 'Administrar licencias.'),

('BAI10-P01', 'BAI10', 'Establecer y mantener un modelo de configuración.'),

('BAI10-P02', 'BAI10', 'Establecer y mantener un repositorio de configuración y una línea base.'),

('BAI10-P03', 'BAI10', 'Mantener y controlar los elementos de configuración.'),

('BAI10-P04', 'BAI10', 'Producir informes de estado y configuración.'),

('BAI10-P05', 'BAI10', 'Verificar y revisar la integridad del repositorio de configuración.'),

('BAI11-P01', 'BAI11', 'Mantener un enfoque estándar para la gestión de proyectos.'),

('BAI11-P02', 'BAI11', 'Poner en marcha e iniciar un proyecto.'),

('BAI11-P03', 'BAI11', 'Gestionar la participación de las partes interesadas.'),

('BAI11-P04', 'BAI11', 'Desarrollar y mantener el plan del proyecto.'),

('BAI11-P05', 'BAI11', 'Gestionar la calidad del proyecto.'),

('BAI11-P06', 'BAI11', 'Gestionar el riesgo del proyecto.'),

('BAI11-P07', 'BAI11', 'Supervisar y controlar proyectos.'),

('BAI11-P08', 'BAI11', 'Gestionar los recursos del proyecto y los paquetes de trabajo.'),

('BAI11-P09', 'BAI11', 'Cerrar un proyecto o iteración.'),

('APO01-P01', 'APO01', 'Diseñar el sistema de gestión de I&T empresarial.'),

('APO01-P02', 'APO01', 'Comunicar los objetivos de gestión, la dirección y las decisiones tomadas.'),

('APO01-P03', 'APO01', 'Implementar procesos de gestión (para apoyar el logro de los objetivos de gobernanza y gestión).'),

('APO01-P04', 'APO01', 'Definir e implementar las estructuras organizacionales.'),

('APO01-P05', 'APO01', 'Establecer roles y responsabilidades.'),

('APO01-P06', 'APO01', 'Optimizar la colocación de la función TI.'),

('APO01-P07', 'APO01', 'Definir la información (datos) y la propiedad del sistema.'),

('APO01-P08', 'APO01', 'Definir las habilidades y competencias objetivo.'),

('APO01-P09', 'APO01', 'Definir y comunicar políticas y procedimientos.'),

('APO01-P10', 'APO01', 'Definir e implementar infraestructura, servicios y aplicaciones para apoyar el sistema de gobernanza y gestión.'),

('APO01-P11', 'APO01', 'Gestionar la mejora continua del sistema de gestión de I&T.'),

('APO02-P01', 'APO02', 'Habilitar el cambio en todos los diferentes aspectos de la organización, desde los canales y procesos hasta los datos, la cultura, las habilidades, el modelo operativo y los incentivos.'),

('APO02-P02', 'APO02', 'Evaluar las capacidades actuales, el rendimiento y la madurez digital de la empresa.'),

('APO02-P03', 'APO02', 'Definir las capacidades digitales objetivo.'),

('APO02-P04', 'APO02', 'Realizar un análisis de brechas.'),

('APO02-P05', 'APO02', 'Definir el plan estratégico y la hoja de ruta.'),

('APO02-P06', 'APO02', 'Comunicar la estrategia y dirección de I&T.'),

('APO03-P01', 'APO03', 'Desarrollar la visión de la arquitectura empresarial.'),

('APO03-P02', 'APO03', 'Definir arquitectura de referencia.'),

('APO03-P03', 'APO03', 'Seleccionar oportunidades y soluciones.'),

('APO03-P04', 'APO03', 'Definir la implementación de la arquitectura.'),

('APO03-P05', 'APO03', 'Proporcionar servicios de arquitectura empresarial.'),

('APO04-P01', 'APO04', 'Crear un entorno propicio para la innovación.'),

('APO04-P02', 'APO04', 'Mantener una comprensión del entorno empresarial.'),

('APO04-P03', 'APO04', 'Monitorear y escanear el entorno tecnológico.'),

('APO04-P04', 'APO04', 'Evaluar el potencial de las tecnologías emergentes y las ideas innovadoras.'),

('APO04-P05', 'APO04', 'Recomendar otras iniciativas apropiadas.'),

('APO04-P06', 'APO04', 'Monitorear la implementación y utilización de la innovación.'),

('APO05-P01', 'APO05', 'Determinar la disponibilidad y fuentes de fondos.'),

('APO05-P02', 'APO05', 'Evaluar y seleccionar programas a financiar.'),

('APO05-P03', 'APO05', 'Monitorear, optimizar e informar sobre el rendimiento de la cartera de inversiones.'),

('APO05-P04', 'APO05', 'Mantener carteras.'),

('APO05-P05', 'APO05', 'Gestionar el logro de beneficios.'),

('APO06-P01', 'APO06', 'Gestionar finanzas y contabilidad.'),

('APO06-P02', 'APO06', 'Priorizar la asignación de recursos.'),

('APO06-P03', 'APO06', 'Crear y mantener presupuestos.'),

('APO06-P04', 'APO06', 'Modelar y asignar costos.'),

('APO06-P05', 'APO06', 'Gestionar costos.'),

('APO07-P01', 'APO07', 'Adquirir y mantener una dotación de personal adecuada y apropiada.'),

('APO07-P02', 'APO07', 'Identificar al personal clave de TI.'),

('APO07-P03', 'APO07', 'Mantener las habilidades y competencias del personal.'),

('APO07-P04', 'APO07', 'Evaluar y reconocer/recompensar el desempeño laboral de los empleados.'),

('APO07-P05', 'APO07', 'Planificar y realizar el seguimiento del uso de TI y de los recursos humanos de la empresa.'),

('APO07-P06', 'APO07', 'Gestionar el personal contratado.'),

('APO08-P01', 'APO08', 'Comprender las expectativas del negocio.'),

('APO08-P02', 'APO08', 'Alinear la estrategia de I&T con las expectativas del negocio e identificar oportunidades para que TI mejore el negocio.'),

('APO08-P03', 'APO08', 'Gestionar la relación comercial.'),

('APO08-P04', 'APO08', 'Coordinar y comunicar.'),

('APO08-P05', 'APO08', 'Proporcionar información para la mejora continua de los servicios.'),

('APO09-P01', 'APO09', 'Identificar servicios de I&T.'),

('APO09-P02', 'APO09', 'Catálogo de servicios habilitados para I&T.'),

('APO09-P03', 'APO09', 'Definir y elaborar contratos de servicios.'),

('APO09-P04', 'APO09', 'Supervisar y reportar los niveles de servicio.'),

('APO09-P05', 'APO09', 'Revisar acuerdos y contratos de servicios.'),

('APO10-P01', 'APO10', 'Identificar y evaluar relaciones y contratos con proveedores.'),

('APO10-P02', 'APO10', 'Seleccionar proveedores.'),

('APO10-P03', 'APO10', 'Gestionar relaciones y contratos con proveedores.'),

('APO10-P04', 'APO10', 'Gestionar el riesgo del proveedor.'),

('APO10-P05', 'APO10', 'Supervisar el rendimiento y el cumplimiento de los proveedores.'),

('APO11-P01', 'APO11', 'Establecer un sistema de gestión de calidad (SGC).'),

('APO11-P02', 'APO11', 'Centrar la gestión de calidad en el cliente.'),

('APO11-P03', 'APO11', 'Gestionar estándares, prácticas y procedimientos de calidad e integrar la gestión de calidad en procesos y soluciones clave.'),

('APO11-P04', 'APO11', 'Realizar seguimiento, control y revisiones de calidad.'),

('APO11-P05', 'APO11', 'Mantener la mejora continua.'),

('APO12-P01', 'APO12', 'Recopilar datos.'),

('APO12-P02', 'APO12', 'Analizar el riesgo.'),

('APO12-P03', 'APO12', 'Mantener un perfil de riesgo.'),

('APO12-P04', 'APO12', 'Articular el riesgo.'),

('APO12-P05', 'APO12', 'Definir una cartera de acciones de gestión de riesgos.'),

('APO12-P06', 'APO12', 'Responder al riesgo.'),

('APO13-P01', 'APO13', 'Establecer y mantener un sistema de gestión de seguridad de la información (SGSI).'),

('APO13-P02', 'APO13', 'Definir y gestionar un plan de tratamiento de riesgos de seguridad de la información y privacidad.'),

('APO13-P03', 'APO13', 'Supervisar y revisar el sistema de gestión de seguridad de la información (SGSI).'),

('APO14-P01', 'APO14', 'Definir y comunicar la estrategia de gestión de datos de la organización, así como sus roles y responsabilidades.'),

('APO14-P02', 'APO14', 'Definir y mantener un glosario empresarial coherente.'),

('APO14-P03', 'APO14', 'Establecer los procesos y la infraestructura para la gestión de metadatos.'),

('APO14-P04', 'APO14', 'Definir una estrategia de calidad de datos.'),

('APO14-P05', 'APO14', 'Establecer metodologías, procesos y herramientas de perfilación de datos.'),

('APO14-P06', 'APO14', 'Garantizar un enfoque de evaluación de la calidad de los datos.'),

('APO14-P07', 'APO14', 'Definir el enfoque de limpieza de datos.'),

('APO14-P08', 'APO14', 'Gestionar el ciclo de vida de los activos de datos.'),

('APO14-P09', 'APO14', 'Apoyar el archivado y retención de datos.'),

('APO14-P10', 'APO14', 'Gestionar acuerdos de copia de seguridad y restauración de datos.'),

('MEA01-P01', 'MEA01', 'Establecer un enfoque de seguimiento.'),

('MEA01-P02', 'MEA01', 'Establecer objetivos de rendimiento y conformidad.'),

('MEA01-P03', 'MEA01', 'Recopilar y procesar datos de rendimiento y conformidad.'),

('MEA01-P04', 'MEA01', 'Analizar e informar el desempeño.'),

('MEA01-P05', 'MEA01', 'Garantizar la implementación de acciones correctivas.'),

('MEA02-P01', 'MEA02', 'Monitorear los controles internos.'),

('MEA02-P02', 'MEA02', 'Revisar la efectividad de los controles de los procesos de negocio.'),

('MEA02-P03', 'MEA02', 'Realizar autoevaluaciones de control.'),

('MEA02-P04', 'MEA02', 'Identificar y reportar deficiencias de control.'),

('MEA03-P01', 'MEA03', 'Identificar los requisitos de cumplimiento externo.'),

('MEA03-P02', 'MEA03', 'Optimizar la respuesta a los requerimientos externos.'),

('MEA03-P03', 'MEA03', 'Confirmar el cumplimiento externo.'),

('MEA03-P04', 'MEA03', 'Obtener garantía de cumplimiento externo.'),

('MEA04-P01', 'MEA04', 'Asegúrese de que los proveedores de garantía sean independientes y calificados.'),

('MEA04-P02', 'MEA04', 'Desarrollar una planificación basada en riesgos de iniciativas de aseguramiento.'),

('MEA04-P03', 'MEA04', 'Determinar los objetivos de la iniciativa de aseguramiento.'),

('MEA04-P04', 'MEA04', 'Definir el alcance de la iniciativa de aseguramiento.'),

('MEA04-P05', 'MEA04', 'Definir el programa de trabajo para la iniciativa de aseguramiento.'),

('MEA04-P06', 'MEA04', 'Ejecutar la iniciativa de aseguramiento, centrándose en la eficacia del diseño.'),

('MEA04-P07', 'MEA04', 'Ejecutar la iniciativa de aseguramiento, centrándose en la eficacia operativa.'),

('MEA04-P08', 'MEA04', 'Informar y dar seguimiento a la iniciativa de aseguramiento.'),

('MEA04-P09', 'MEA04', 'Dar seguimiento a recomendaciones y acciones.'),

('EDM01-P01', 'EDM01', 'Evaluar el sistema de gobernanza'),

('EDM01-P02', 'EDM01', 'Dirigir el sistema de gobierno.'),

('EDM01-P03', 'EDM01', 'Supervisar el sistema de gobernanza.'),

('EDM02-P01', 'EDM02', 'Establecer la combinación de inversiones objetivo.'),

('EDM02-P02', 'EDM02', 'Evaluar la optimización del valor.'),

('EDM02-P03', 'EDM02', 'Optimización de valor directo.'),

('EDM02-P04', 'EDM02', 'Monitorizar la optimización del valor.'),

('EDM03-P01', 'EDM03', 'Evaluar la gestión de riesgos.'),

('EDM03-P02', 'EDM03', 'Gestión directa de riesgos.'),

('EDM03-P03', 'EDM03', 'Monitorizar la gestión de riesgos.'),

('EDM04-P01', 'EDM04', 'Evaluar la gestión de recursos.'),

('EDM04-P02', 'EDM04', 'Gestión directa de recursos.'),

('EDM04-P03', 'EDM04', 'Supervisar la gestión de recursos.'),

('EDM05-P01', 'EDM05', 'Evaluar la participación de las partes interesadas y los requisitos de presentación de informes.'),

('EDM05-P02', 'EDM05', 'Participación directa de las partes interesadas, comunicación e informes.'),

('EDM05-P03', 'EDM05', 'Monitorear la participación de las partes interesadas.');

-- ─────────────────────────────────────────────────────────────────────────────
-- INSERCIÓN DE DATOS - TABLA HERRAMIENTA
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO herramienta (id, categoria, descripcion, casos_uso, tipo_herramienta) VALUES

('Alfresco', 'Gestión documental', 'Plataforma de gestión documental empresarial y colaboración que permite centralizar archivos, controlar versiones, flujos de aprobación y automatizar procesos relacionados con la gestión de la información.', '{"Repositorio documental corporativo","Automatización de flujos de trabajo","Colaboración en proyectos"}', 'Gestor de contenidos'),

('Anaconda', 'Ciencia de datos', 'Distribución de Python y R para ciencia de datos, machine learning y análisis avanzado. Incluye librerías populares como NumPy, pandas y TensorFlow, así como entornos interactivos como Jupyter Notebook.', '{"Análisis de datos masivos","Modelos de machine learning","Visualización y exploración de datos"}', 'Distribución científica'),

('Ansible', 'DevOps / Infraestructura', 'Herramienta para automatización de configuración, orquestación y despliegue de aplicaciones. Utiliza archivos YAML fáciles de entender y no requiere agentes.', '{"Infraestructura como código","Automatización de despliegues","Configuración de servidores"}', 'Automatización'),

('Apache Dubbo', 'Integración de servicios', 'Framework Java para llamadas a procedimientos remotos (RPC) y desarrollo de arquitecturas distribuidas basadas en microservicios. Ofrece balanceo de carga, descubrimiento de servicios y tolerancia a fallos.', '{"Implementación de microservicios","Integración de aplicaciones distribuidas","Comunicación entre sistemas"}', 'Framework RPC'),

('Apache Hive', 'Bases de datos', 'Framework open source para almacenamiento y procesamiento de grandes volúmenes de datos basado en Hadoop', '{"Procesamiento de datos masivos","Consultas distribuidas con SQL","Integración con ecosistemas Big Data"}', 'Bases de datos / Big Data'),

('Apache JMeter', 'QA / Testing', 'Herramienta para realizar pruebas de carga y estrés en aplicaciones web, servidores y servicios. Genera reportes detallados y métricas de rendimiento.', '{"Stress testing","Medición de rendimiento web","QA en aplicaciones"}', 'Pruebas de rendimiento'),

('Apache OFBiz', 'Negocios / ERP', 'Framework open source para gestión empresarial que incluye ERP, CRM y e-commerce. Es modular y permite personalizar procesos internos y de comercio electrónico.', '{"Gestión de procesos empresariales","Implementación de CRM","Plataformas de e-commerce"}', 'ERP/CRM/E-Commerce'),

('Apache Open', 'Productividad', 'Una completa suite ofimática de código abierto que incluye procesador de textos, hojas de cálculo, presentaciones, diagramación y bases de datos. Está diseñada para ofrecer una alternativa libre a soluciones propietarias y permite trabajar con formatos estándar y abrir archivos de otras suites como Microsoft Office.', '{"Creación y edición de documentos corporativos","Presentaciones empresariales","Gestión de hojas de cálculo y reportes"}', 'Suite ofimática'),

('Archi', 'Arquitectura empresarial', 'Herramienta especializada en la creación de modelos de arquitectura empresarial utilizando el estándar ArchiMate. Permite visualizar relaciones entre procesos, aplicaciones, infraestructura y estrategias, ayudando a planificar la evolución de sistemas de TI y procesos de negocio.', '{"Diseño de arquitecturas empresariales","Documentación de procesos de TI","Planificación estratégica de sistemas"}', 'Modelador de arquitectura'),

('Collabtive', 'Colaboración', 'Sistema open source para la gestión de proyectos y tareas en equipo. Ofrece seguimiento de hitos, calendarios, gestión de usuarios y comunicación interna. Está orientado a pequeñas y medianas empresas que buscan una alternativa libre a herramientas comerciales de gestión de proyectos.', '{"Planificación de proyectos colaborativos","Asignación y seguimiento de tareas","Gestión de hitos y tiempos"}', 'Gestor de proyectos'),

('Eramba', 'Seguridad y cumplimiento', 'Solución integral de Gobernanza, Riesgo y Cumplimiento (GRC) diseñada para la gestión de políticas, auditorías, riesgos y controles de seguridad. Incluye módulos para evaluación de riesgos, gestión documental y planificación de auditorías.', '{"Gobernanza y gestión de riesgos","Cumplimiento de normativas internacionales","Planificación de auditorías internas"}', 'Plataforma GRC'),

('GitHub', 'Desarrollo', 'Plataforma de control de versiones basada en Git que permite colaboración de código, revisión de cambios e integración continua.', '{"Control de versiones","Colaboración en proyectos","Integración CI/CD"}', 'Repositorio de código'),

('GLPI', 'Gestión de TI', 'Sistema de gestión de activos de TI, helpdesk y mantenimiento preventivo/correctivo. Permite gestionar inventarios de hardware y software, contratos, licencias y tickets de soporte.', '{"Inventario de activos TI","Mesa de ayuda corporativa","Gestión de contratos y licencias"}', 'IT Asset Management (ITAM)'),

('GPG', 'Seguridad / Criptografía', 'Herramienta de cifrado de clave pública utilizada para proteger datos y realizar firmas digitales seguras.', '{"Cifrado de datos sensibles","Firmas digitales","Seguridad de comunicaciones"}', 'Cifrado'),

('Grafana', 'Monitoreo / Analítica', 'Plataforma de visualización de métricas y dashboards en tiempo real. Compatible con múltiples fuentes de datos como Prometheus, InfluxDB y Elastic.', '{"Dashboards de monitoreo TI","Visualización de métricas de negocio","Análisis en tiempo real"}', 'Visualización de datos'),

('HAProxy', 'Redes / Infraestructura', 'Software open source para balanceo de carga y proxy inverso de alto rendimiento, utilizado para aplicaciones web y servicios críticos.', '{"Balanceo de tráfico web","Alta disponibilidad","Proxy inverso seguro"}', 'Balanceador de carga'),

('Huginn', 'Integración / Bots', 'Plataforma para crear agentes automatizados que monitorean eventos y realizan tareas automáticamente integrándose con APIs externas.', '{"Automatización de tareas repetitivas","Integración de servicios","Monitoreo de eventos"}', 'Automatización'),

('Issabel', 'Telefonía VoIP', 'Plataforma de comunicaciones unificadas basada en Asterisk. Ofrece funciones de PBX, call center, grabación de llamadas, IVR y herramientas de integración VoIP.', '{"Central telefónica empresarial","Plataformas de call center","Comunicaciones VoIP integradas"}', 'PBX / Comunicaciones'),

('iTop by Combodo', 'Gestión de TI', 'Plataforma ITSM modular que incluye gestión de servicios, incidencias, problemas, cambios y una CMDB completa.', '{"Gestión de servicios TI","Mesa de ayuda","Gestión de cambios y configuración"}', 'IT Service Management (ITSM)'),

('JFire', 'Negocios / ERP', 'Plataforma modular de ERP y CRM open source para empresas. Permite gestionar clientes, procesos de negocio, ventas, inventarios y finanzas. Es extensible y puede adaptarse a distintos sectores industriales.', '{"Gestión de clientes y ventas","Administración de inventarios","Automatización de procesos empresariales"}', 'ERP/CRM'),

('Kali Linux', 'Ciberseguridad', 'Distribución Linux especializada en pruebas de penetración, auditorías de seguridad y análisis forense digital. Incluye una gran cantidad de herramientas de hacking ético.', '{"Pentesting profesional","Auditorías de seguridad","Forense digital"}', 'Distribución de pentesting'),

('MantisBT', 'Gestión de incidencias', 'Herramienta para la gestión de errores (bug tracking) y seguimiento de incidencias. Permite gestionar proyectos de desarrollo, priorizar errores, asignar tareas y generar reportes detallados.', '{"Gestión de bugs en software","Seguimiento de incidencias de TI","Reportes de calidad en proyectos"}', 'Sistema de seguimiento'),

('Moodle', 'Educación', 'Plataforma de aprendizaje online open source utilizada por instituciones educativas y empresas para capacitación interna. Ofrece cursos, evaluaciones, foros y reportes de progreso.', '{"Cursos de educación virtual","Capacitación interna corporativa","Programas de e-learning"}', 'LMS (Learning Management)'),

('MySQL', 'Bases de datos', 'Base de datos relacional open source ampliamente utilizada en aplicaciones web y empresariales. Ofrece alta escalabilidad y soporte para transacciones ACID.', '{"Almacenamiento de datos","Aplicaciones web","Sistemas empresariales"}', 'Sistema de base de datos'),

('Open Source Risk Engine', 'Finanzas / Cumplimiento', 'Plataforma open source diseñada para el modelado, simulación y análisis cuantitativo de riesgos financieros, de mercado y operacionales. Facilita la creación de escenarios y permite cumplir con regulaciones relacionadas con la gestión de riesgos.', '{"Gestión de riesgos financieros","Simulación de escenarios económicos","Cumplimiento de normativas regulatorias"}', 'Motor de análisis de riesgo'),

('OpenAudIT', 'Gestión de TI', 'Herramienta para descubrimiento automático y auditoría de dispositivos conectados en una red corporativa.', '{"Inventario automático de red","Auditoría de dispositivos","Gestión de infraestructura TI"}', 'Auditoría de red'),

('OpenSCAP v2.1', 'Seguridad y cumplimiento', 'Framework open source para auditorías de seguridad, escaneo de vulnerabilidades y cumplimiento de estándares.', '{"Auditorías de políticas de seguridad","Cumplimiento normativo","Escaneo de vulnerabilidades"}', 'Escáner de cumplimiento'),

('OpenSSH', 'Redes / Seguridad', 'Implementación de SSH y SFTP para conexiones seguras, administración remota y transferencia cifrada de archivos.', '{"Acceso remoto seguro","Transferencias cifradas","Automatización segura"}', 'Herramienta de conexión SSH'),

('OrangeHRM', 'Recursos Humanos', 'Sistema de gestión de recursos humanos que incluye módulos de reclutamiento, evaluación de desempeño y administración de personal.', '{"Gestión de empleados","Procesos de RRHH","Administración de talento"}', 'HR Management'),

('Owasp ZAP', 'Ciberseguridad', 'Herramienta de pruebas de penetración para aplicaciones web mantenida por OWASP. Facilita la detección de vulnerabilidades y pruebas automatizadas.', '{"Pentesting de aplicaciones web","Análisis de seguridad automatizado","Auditorías de vulnerabilidades"}', 'Escáner de seguridad web'),

('pfSense', 'Seguridad de red', 'Sistema de firewall y router basado en FreeBSD. Permite configurar VPNs, balanceo de carga y políticas de seguridad de red avanzadas.', '{"Seguridad perimetral","Redes corporativas","Configuración de VPNs"}', 'Firewall / Router'),

('phpBB', 'Comunicación / Comunidad', 'Plataforma de foros en línea open source utilizada para crear comunidades virtuales y sistemas de soporte. Ofrece herramientas de moderación, gestión de usuarios, mensajería y personalización de temas.', '{"Creación de comunidades en línea","Foros de soporte técnico","Comunicación interna corporativa"}', 'Foro web'),

('Proxmox', 'Infraestructura', 'Plataforma para virtualización de servidores basada en KVM y contenedores LXC. Permite gestionar clústeres de alta disponibilidad.', '{"Gestión de máquinas virtuales","Virtualización de servidores","Entornos de alta disponibilidad"}', 'Virtualización'),

('Proxmox Mail Gateway', 'Seguridad / Correo', 'Sistema de filtrado de correo empresarial que protege contra spam, phishing y malware. Se integra fácilmente con servidores de correo existentes.', '{"Protección contra correo malicioso","Filtro de spam empresarial","Seguridad de correo electrónico"}', 'Filtro de correo'),

('Ralph', 'Gestión de TI', 'Sistema para inventario, gestión de activos de TI y auditoría de infraestructura. Integrable con CMDB y sistemas de gestión.', '{"Inventario de hardware y software","Gestión de activos TI","Auditoría de infraestructura"}', 'IT Asset Management'),

('RocketChat', 'Colaboración', 'Plataforma de mensajería y colaboración en equipo open source con soporte para integración de bots, APIs y canales seguros.', '{"Comunicación interna","Integración con herramientas empresariales","Mensajería en tiempo real"}', 'Comunicación en equipo'),

('SnipeIT', 'IT Asset Management (ITAM)', 'Plataforma para gestionar inventarios de hardware y software, seguimiento de licencias y control de activos en empresas.', '{"Inventario de hardware y software","Gestión de licencias","Control de activos TI"}', 'Gestión de activos TI'),

('Snort', 'Seguridad de red', 'Sistema de detección y prevención de intrusiones que analiza tráfico de red en tiempo real y genera alertas ante patrones maliciosos.', '{"Detección de intrusiones","Monitoreo de red","Seguridad perimetral"}', 'IDS/IPS'),

('Tactical RMM', 'Monitoreo de TI', 'Plataforma de monitoreo y gestión remota de sistemas y endpoints. Permite automatizar tareas y administrar dispositivos de forma centralizada.', '{"Administración remota","Monitoreo de endpoints","Soporte técnico a distancia"}', 'Remote Monitoring & Mgmt'),

('Wazuh', 'Monitoreo y seguridad', 'Plataforma SIEM open source para el monitoreo de logs, detección de intrusiones y análisis de seguridad. Ofrece integración con Elastic Stack.', '{"Detección de amenazas","Monitoreo de logs en tiempo real","Cumplimiento de normativas"}', 'Seguridad / SIEM'),

('Wireshark', 'Redes / Monitoreo', 'Analizador de protocolos de red que captura y examina paquetes en tiempo real para diagnóstico y auditoría de seguridad.', '{"Análisis de tráfico de red","Diagnóstico de problemas de conectividad","Seguridad de redes"}', 'Analizador de red'),

('Zabbix', 'Monitoreo', 'Solución open source para el monitoreo de redes, servidores y aplicaciones. Ofrece métricas en tiempo real, alertas, dashboards personalizables y capacidad de monitoreo distribuido.', '{"Monitoreo de infraestructuras TI","Alertas en tiempo real","Seguimiento de rendimiento de aplicaciones y servidores"}', 'Monitor de infraestructura'),

('Zammad', 'Helpdesk / Soporte', 'Plataforma open source para la gestión de tickets y soporte al cliente. Integra múltiples canales de comunicación (correo, chat, redes sociales).', '{"Soporte ITSM","Atención multicanal al cliente","Gestión de incidencias internas"}', 'Sistema de ticketing'),

('Znuny', 'Helpdesk / Soporte', 'Sistema de gestión de tickets y soporte técnico. Znuny es la versión open source de OTRS, utilizada ampliamente en empresas para gestionar solicitudes, incidencias y flujos de trabajo de atención al cliente.', '{"Mesa de ayuda corporativa","Gestión de solicitudes internas","ITSM y soporte técnico"}', 'Sistema de ticketing');

-- ─────────────────────────────────────────────────────────────────────────────
-- INSERCIÓN DE DATOS - TABLA ACTIVIDAD
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO actividad (actividad_id, practica_id, descripcion, nivel_capacidad, herramienta_id, justificacion, observaciones, integracion) VALUES

('DSS01-P01-A01', 'DSS01-P01', 'Desarrollar y mantener procedimientos operativos y actividades relacionadas para apoyar todos los servicios prestados.', 2, 'GLPI', 'Permite documentar y mantener procedimientos operativos, usar flujos, tareas y base de conocimientos.', 'Cumple por medio de plugins', 'Formcreator'),

('DSS01-P01-A02', 'DSS01-P01', 'Mantener un cronograma de actividades operativas y ejecutar las actividades.', 2, 'GLPI', 'GLPI permite programar tareas, asignarlas a usuarios, establecer fechas y estados de avance mediante su sistema de tickets y proyectos.', '-', '-'),

('DSS01-P01-A03', 'DSS01-P01', 'Verificar que todos los datos previstos para el procesamiento se reciban y procesen de forma completa, precisa y oportuna. Entregar los resultados según los requisitos de la empresa. Dar soporte a las necesidades de reinicio y reprocesamiento. Asegurar que los usuarios reciban los resultados correctos de forma segura y oportuna.', 3, NULL, '-', '-', '-'),

('DSS01-P01-A04', 'DSS01-P01', 'Gestionar el rendimiento y el rendimiento de las actividades programadas.', 4, 'GLPI', 'Por medio de plugins permite generar informes y visualización de cumplimiento, tiempos y KPIs de tareas.', 'Cumple por medio de plugins', 'Dashboard, Reports'),

('DSS01-P01-A05', 'DSS01-P01', 'Monitorear incidentes y problemas relacionados con los procedimientos operativos y tomar las medidas apropiadas para mejorar la confiabilidad de las tareas operativas realizadas.', 5, 'GLPI', 'Diseñada precisamente para gestionar incidentes, problemas, su categorización, historial y resolución.', '-', '-'),

('DSS01-P02-A01', 'DSS01-P02', 'Garantizar que los requisitos de la empresa en materia de seguridad de los procesos de información se ajusten a los contratos y acuerdos de nivel de servicio con terceros que alojan o prestan servicios.', 3, 'Eramba', 'Permite definir políticas, controles y requisitos de seguridad, y mapearlos contra cumplimiento contractual y normativo.', '-', '-'),

('DSS01-P02-A02', 'DSS01-P02', 'Garantizar que los requisitos y prioridades de procesamiento de TI y negocios operativos de la empresa para la prestación de servicios se ajusten a los contratos y acuerdos de nivel de servicio con terceros que alojan o prestan servicios.', 3, NULL, '-', '-', '-'),

('DSS01-P02-A03', 'DSS01-P02', 'Integrar los procesos críticos de gestión interna de TI con los de los proveedores de servicios externalizados. Esto debe abarcar, por ejemplo, la planificación del rendimiento y la capacidad, la gestión de cambios, la gestión de la configuración, la gestión de solicitudes de servicio e incidentes, la gestión de problemas, la gestión de la seguridad, la continuidad del negocio y la supervisión del rendimiento de los procesos y la generación de informes.', 3, 'GLPI', 'GLPI gestiona internamente solicitudes, incidentes, cambios, configuración y problemas; puede incluir proveedores como actores del sistema para integrarlos parcialmente.', '-', '-'),

('DSS01-P02-A04', 'DSS01-P02', 'Planificar una auditoría y aseguramiento independientes de los entornos operativos de los proveedores subcontratados para confirmar que se están abordando adecuadamente los requisitos acordados.', 4, 'Eramba', 'Eramba permite planificar y registrar auditorías, generar evidencia y verificar cumplimiento contractual con terceros.', '-', '-'),

('DSS01-P03-A01', 'DSS01-P03', 'Registrar eventos. Identificar el nivel de información que debe registrarse, considerando el riesgo y el rendimiento.', 2, 'GLPI', 'FusionInventory permite registrar eventos básicos de hardware, red, software y alertas de dispositivos conectados.', 'Cumple por medio de plugins', 'FusionInventory'),

('DSS01-P03-A02', 'DSS01-P03', 'Identificar y mantener una lista de activos de infraestructura que necesitan ser monitoreados, en función de la criticidad del servicio y la relación entre los elementos de configuración y los servicios que dependen de ellos.', 3, 'GLPI', 'GLPI permite inventariar, categorizar y asociar activos con servicios o criticidad.', '-', '-'),

('DSS01-P03-A03', 'DSS01-P03', 'Defina e implemente reglas que identifiquen y registren las infracciones de umbral y las condiciones de los eventos. Encuentre un equilibrio entre la generación de eventos menores falsos y eventos significativos para evitar la sobrecarga de información innecesaria en los registros de eventos.', 3, 'GLPI', 'A través de monitoreo activo con agentes, se pueden definir alertas ante ciertos umbrales (RAM, CPU, disco, etc.).', 'Cumple por medio de plugins', 'FusionInventory'),

('DSS01-P03-A04', 'DSS01-P03', 'Elaborar registros de eventos y conservarlos durante un período adecuado para ayudar en futuras investigaciones.', 3, 'GLPI', 'FusionInventory permiten guardar logs e historiales de eventos por dispositivo en la base de datos.', 'Cumple por medio de plugins', 'FusionInventory'),

('DSS01-P03-A05', 'DSS01-P03', 'Asegúrese de que los tickets de incidentes se creen de manera oportuna al monitorear las desviaciones identificadas de los umbrales definidos.', 3, 'GLPI', 'Se puede configurar para que ciertos eventos generen tickets automáticamente (fallos de hardware, etc.).', 'Cumple por medio de plugins', 'FusionInventory'),

('DSS01-P03-A06', 'DSS01-P03', 'Establecer procedimientos para supervisar los registros de eventos. Realizar revisiones periódicas.', 4, 'GLPI', 'Se pueden estructurar los procedimientos y tareas periódicas de revisión en proyectos/tareas.', 'Cumple por medio de plugins', 'Formcreator'),

('DSS01-P04-A01', 'DSS01-P04', 'Identificar los desastres naturales y antropogénicos que podrían ocurrir en la zona donde se ubican las instalaciones de TI. Evaluar el posible impacto en las instalaciones de TI.', 2, 'Eramba', 'Se pueden definir riesgos físicos y ambientales, su evaluación y su tratamiento.', '-', '-'),

('DSS01-P04-A02', 'DSS01-P04', 'Identificar cómo se protegen los equipos de TI, incluyendo los equipos móviles y externos, contra las amenazas ambientales. Asegurarse de que la política limite o excluya comer, beber y fumar en áreas sensibles, y prohíba el almacenamiento de material de oficina y otros suministros que representen un riesgo de incendio dentro de las salas de informática.', 2, 'Eramba', 'Puede documentar políticas físicas de acceso y uso, controles internos y cumplimiento.', '-', '-'),

('DSS01-P04-A03', 'DSS01-P04', 'Mantenga los sitios de TI y las salas de servidores limpios y en condiciones seguras en todo momento (es decir, sin desorden, sin papel o cajas de cartón, sin botes de basura llenos, sin productos químicos o materiales inflamables).', 2, 'GLPI', 'Se pueden crear formularios o tareas periódicas para inspección de condiciones físicas.', 'Cumple por medio de plugins', 'Formcreator / Checklists'),

('DSS01-P04-A04', 'DSS01-P04', 'Ubicar y construir instalaciones de TI para minimizar y mitigar la susceptibilidad a amenazas ambientales (p. ej., robo, aire, fuego, humo, agua, vibraciones, terrorismo, vandalismo, sustancias químicas, explosivos). Considerar zonas de seguridad específicas o celdas ignífugas (p. ej., ubicando los entornos/servidores de producción y desarrollo separados entre sí).', 3, NULL, '-', 'Ninguna herramienta puede ubicar y construir', '-'),

('DSS01-P04-A05', 'DSS01-P04', 'Compare las medidas y los planes de contingencia con los requisitos de la póliza de seguro e informe los resultados. Aborde los puntos de incumplimiento de manera oportuna.', 3, 'Eramba', 'Se pueden mapear controles a requisitos de aseguramiento y documentar hallazgos.', '-', '-'),

('DSS01-P04-A06', 'DSS01-P04', 'Responda a las alarmas ambientales y otras notificaciones. Documente y pruebe los procedimientos, que deben incluir la priorización de las alarmas y la comunicación con las autoridades locales de respuesta a emergencias. Capacite al personal en estos procedimientos.', 3, 'Eramba', 'Se pueden documentar procedimientos, entrenamientos y respuestas simuladas a eventos ambientales.', '-', '-'),

('DSS01-P04-A07', 'DSS01-P04', 'Supervisar y mantener periódicamente los dispositivos que detectan de forma proactiva las amenazas ambientales (por ejemplo, fuego, agua, humo, humedad).', 4, 'GLPI', 'Con sensores conectados vía SNMP y FusionInventory, se puede monitorear dispositivos como UPS, sensores de temperatura, humedad, etc.', 'Cumple por medio de plugins', 'FusionInventory'),

('DSS01-P05-A01', 'DSS01-P05', 'Examine los requisitos de las instalaciones de TI para la protección contra fluctuaciones y cortes de energía, junto con otros requisitos de la planificación de la continuidad del negocio. Adquiera equipos de suministro ininterrumpido adecuados (p. ej., baterías, generadores) para respaldar la planificación de la continuidad del negocio.', 2, 'Eramba', 'Se puede modelar este tipo de riesgo físico y establecer controles asociados a infraestructura crítica.', '-', '-'),

('DSS01-P05-A02', 'DSS01-P05', 'Pruebe periódicamente los mecanismos del sistema de alimentación ininterrumpida (SAI). Asegúrese de que se pueda conectar la alimentación sin afectar significativamente las operaciones comerciales.', 2, 'GLPI', 'Puedes programar tareas de verificación periódica, con seguimiento y responsables.', 'Cumple por medio de plugins', 'Formcreator'),

('DSS01-P05-A03', 'DSS01-P05', 'Asegúrese de que las instalaciones que albergan los sistemas de I&T cuenten con más de una fuente para los servicios públicos dependientes (p. ej., electricidad, telecomunicaciones, agua, gas). Separe la entrada física de cada servicio.', 2, 'Eramba', 'Permite documentar riesgos identificados de dependencia única y definir medidas de mitigación.', 'La herramienta solo facilita la documentación, debido a la propiedad fisica de la actividad', '-'),

('DSS01-P05-A04', 'DSS01-P05', 'Confirme que el cableado externo al sitio de TI esté ubicado bajo tierra o cuente con protección alternativa adecuada. Asegúrese de que el cableado dentro del sitio de TI esté dentro de conductos seguros y que el acceso a los gabinetes de cableado esté restringido al personal autorizado. Proteja adecuadamente el cableado contra daños causados por fuego, humo, agua, interceptación e interferencias.', 2, NULL, 'Eramba puede establecer políticas y controles de protección física.', 'La herramienta solo facilita la documentación, debido a la propiedad fisica de la actividad', '-'),

('DSS01-P05-A05', 'DSS01-P05', 'Asegúrese de que el cableado y la interconexión física (de datos y telefónica) estén estructurados y organizados. Las estructuras de cableado y conductos deben estar documentadas (por ejemplo, el plano del edificio y los diagramas de cableado).', 2, 'GLPI', 'Puedes adjuntar diagramas y planos físicos en los elementos de la CMDB.', 'Cumple por medio de plugins', 'Diagrams'),

('DSS01-P05-A06', 'DSS01-P05', 'Capacitar periódicamente al personal sobre las leyes, reglamentos y directrices pertinentes en materia de salud y seguridad. Capacitar al personal sobre simulacros de incendio y rescate para garantizar los conocimientos y las medidas a tomar en caso de incendio o incidentes similares.', 2, 'Eramba', 'Puedes documentar entrenamientos, asignarlos y hacer seguimiento al cumplimiento.', '-', '-'),

('DSS01-P05-A07', 'DSS01-P05', 'Asegúrese de que las instalaciones y equipos informáticos se mantengan según los intervalos de servicio y las especificaciones recomendadas por el proveedor. Asegúrese de que el mantenimiento lo realice únicamente personal autorizado.', 3, 'GLPI', 'Puedes crear tareas cíclicas y asignarlas a técnicos responsables con fechas y registros.', '-', '-'),

('DSS01-P05-A08', 'DSS01-P05', 'Analizar los requerimientos de cableado de redundancia y conmutación por error (externo e interno) de las instalaciones que albergan los sistemas de alta disponibilidad.', 3, 'Eramba', 'Puedes modelar estos escenarios de disponibilidad como riesgos de continuidad.', '-', '-'),

('DSS01-P05-A09', 'DSS01-P05', 'Asegúrese de que los sitios e instalaciones de TI cumplan continuamente con las leyes, regulaciones, pautas y especificaciones de los proveedores en materia de salud y seguridad.', 3, 'Eramba', 'Puedes mapear controles normativos y auditar el cumplimiento.', '-', '-'),

('DSS01-P05-A10', 'DSS01-P05', 'Registrar, supervisar, gestionar y resolver los incidentes en las instalaciones de acuerdo con el proceso de gestión de incidentes de I&T. Publicar informes sobre los incidentes en las instalaciones cuya divulgación esté exigida por la legislación y la normativa.', 4, 'GLPI', 'Permite registrar y gestionar incidentes físicos, incluyendo filtraciones, fallos de energía, etc.', '-', '-'),

('DSS01-P05-A11', 'DSS01-P05', 'Analizar las alteraciones físicas en los sitios o instalaciones de TI para reevaluar el riesgo ambiental (p. ej., daños por incendio o agua). Informar de los resultados de este análisis a la gestión de continuidad del negocio y de las instalaciones.', 4, 'Eramba', 'Se pueden registrar alteraciones como eventos de riesgo y documentar el análisis y respuesta.', '-', '-'),

('DSS02-P01-A01', 'DSS02-P01', 'Defina los esquemas de clasificación y priorización de incidentes y solicitudes de servicio, así como los criterios para el registro de problemas. Utilice esta información para garantizar enfoques consistentes para gestionar e informar a los usuarios sobre los problemas, así como para realizar análisis de tendencias.', 3, 'GLPI', 'GLPI permite definir categorías, subcategorías, niveles de prioridad, severidad y urgencia.', '-', '-'),

('DSS02-P01-A02', 'DSS02-P01', 'Definir modelos de incidentes para errores conocidos para permitir una resolución eficiente y efectiva.', 3, 'GLPI', 'Se pueden configurar plantillas de tickets con campos prellenados y asociarlas a errores conocidos.', '-', '-'),

('DSS02-P01-A03', 'DSS02-P01', 'Definir modelos de solicitud de servicio según el tipo de solicitud de servicio para permitir la autoayuda y un servicio eficiente para solicitudes estándar.', 3, 'GLPI', 'Soporta catálogos de servicios con formularios asociados según tipo de solicitud.', '-', '-'),

('DSS02-P01-A04', 'DSS02-P01', 'Definir reglas y procedimientos de escalada de incidentes, especialmente para incidentes importantes e incidentes de seguridad.', 3, 'GLPI', 'Puedes definir reglas de negocio para escalamiento automático basado en prioridad, tiempo u otras condiciones.', '-', '-'),

('DSS02-P01-A05', 'DSS02-P01', 'Definir fuentes de conocimiento sobre incidentes y solicitudes y describir cómo utilizarlas.', 3, 'GLPI', 'Incluye base de conocimientos que se puede enlazar con categorías, tipos de solicitudes e incidentes.', '-', '-'),

('DSS02-P02-A01', 'DSS02-P02', 'Registrar todas las solicitudes de servicio e incidentes, registrando toda la información relevante, para que puedan gestionarse de manera efectiva y se pueda mantener un registro histórico completo.', 2, 'GLPI', 'GLPI permite registrar tickets con múltiples campos personalizables (categoría, urgencia, impacto, grupo, SLA, etc.).', '-', '-'),

('DSS02-P02-A02', 'DSS02-P02', 'Para permitir el análisis de tendencias, clasifique las solicitudes de servicio y los incidentes identificando el tipo y la categoría.', 2, 'GLPI', 'Se puede categorizar por tipo, subcategoría, y utilizar informes o exportaciones para análisis.', '-', '-'),

('DSS02-P02-A03', 'DSS02-P02', 'Priorizar las solicitudes de servicio y los incidentes según la definición del servicio SLA en cuanto a impacto comercial y urgencia.', 2, 'GLPI', 'GLPI tiene matriz de impacto/urgencia para calcular prioridad automática según los SLA definidos.', '-', '-'),

('DSS02-P03-A01', 'DSS02-P03', 'Verificar la legitimación de las solicitudes de servicio utilizando, cuando sea posible, un flujo de proceso predefinido y cambios estándar.', 2, 'GLPI', 'Con plugins, puedes definir flujos de aprobación y validación de solicitudes y cambios.', 'Cumple por medio de plugins', 'Formcreator o Approval'),

('DSS02-P03-A02', 'DSS02-P03', 'Obtener la aprobación financiera y funcional o la firma, si es necesario, o aprobaciones predefinidas para los cambios estándar acordados.', 2, 'GLPI', 'Se puede configurar validación multietapa para aprobaciones técnicas, funcionales o financieras.', 'Cumple por medio de plugins', 'Formcreator o Approval'),

('DSS02-P03-A03', 'DSS02-P03', 'Atienda las solicitudes siguiendo el procedimiento seleccionado. Siempre que sea posible, utilice menús automatizados de autoservicio y modelos de solicitud predefinidos para los artículos solicitados con frecuencia.', 3, 'GLPI', 'El portal de autoservicio permite a los usuarios realizar solicitudes estandarizadas con formularios predefinidos.', '-', '-'),

('DSS02-P04-A01', 'DSS02-P04', 'Identifique y describa los síntomas relevantes para determinar las causas más probables de los incidentes. Consulte los recursos de conocimiento disponibles (incluidos los errores y problemas conocidos) para identificar posibles soluciones a los incidentes (soluciones temporales o permanentes).', 2, 'GLPI', 'Puedes registrar síntomas, vincular a base de conocimientos, errores conocidos y adjuntar soluciones temporales o definitivas.', '-', '-'),

('DSS02-P04-A02', 'DSS02-P04', 'Si aún no existe un problema relacionado o un error conocido y el incidente satisface los criterios acordados para el registro de problemas, registre un nuevo problema.', 2, 'GLPI', 'Se puede registrar problemas distintos a los incidentes, y relacionarlos entre sí. Soporta errores conocidos.', '-', '-'),

('DSS02-P04-A03', 'DSS02-P04', 'Asignar incidentes a funciones especializadas si se requiere mayor experiencia. Involucrar al nivel directivo adecuado, cuando sea necesario.', 2, 'GLPI', 'GLPI permite asignar a grupos técnicos, técnicos específicos y escalar incidentes por reglas automáticas.', '-', '-'),

('DSS02-P05-A01', 'DSS02-P05', 'Seleccionar y aplicar las resoluciones de incidentes más adecuadas (solución temporal y/o solución permanente).', 2, 'GLPI', 'Puedes aplicar soluciones manuales o predefinidas y documentar si son temporales o definitivas.', '-', '-'),

('DSS02-P05-A02', 'DSS02-P05', 'Registre si se utilizaron soluciones alternativas para la resolución del incidente.', 2, 'GLPI', 'Puedes detallar en el campo de solución si fue workaround o solución permanente.', '-', '-'),

('DSS02-P05-A03', 'DSS02-P05', 'Realice acciones de recuperación, si es necesario.', 2, 'GLPI', 'Las tareas, notas y seguimiento permiten documentar acciones técnicas de recuperación.', '-', '-'),

('DSS02-P05-A04', 'DSS02-P05', 'Documentar la resolución del incidente y evaluar si dicha resolución puede utilizarse como fuente de conocimiento futuro.', 2, 'GLPI', 'Puedes enviar la resolución a la base de conocimientos o vincularla a artículos existentes.', '-', '-'),

('DSS02-P06-A01', 'DSS02-P06', 'Verificar con los usuarios afectados que la solicitud de servicio se ha cumplido satisfactoriamente o que la incidencia se ha resuelto satisfactoriamente y en un plazo acordado/aceptable.', 2, 'GLPI', 'GLPI permite solicitar validación del usuario antes de cerrar el ticket, incluyendo campos para comentarios y confirmación.', '-', '-'),

('DSS02-P06-A02', 'DSS02-P06', 'Cerrar solicitudes de servicio e incidentes.', 2, 'GLPI', 'El técnico o el usuario pueden cerrar el ticket según el flujo definido, y se mantiene el histórico completo.', '-', '-'),

('DSS02-P07-A01', 'DSS02-P07', 'Monitorear y dar seguimiento a las escaladas y resoluciones de incidentes y solicitar procedimientos de manejo para avanzar hacia la resolución o finalización.', 2, 'GLPI', 'GLPI permite seguir el flujo de tickets, escalaciones y tiempos de resolución con alertas.', '-', '-'),

('DSS02-P07-A02', 'DSS02-P07', 'Identificar a los interesados en la información y sus necesidades de datos o informes. Identificar la frecuencia y el formato de los informes.', 3, 'GLPI', 'Con plugins puedes crear informes dirigidos a roles específicos, exportarlos o automatizar su generación.', 'Cumple por medio de plugins', 'Reports plugin / Dashboards'),

('DSS02-P07-A03', 'DSS02-P07', 'Producir y distribuir informes oportunos o proporcionar acceso controlado a datos en línea.', 4, 'GLPI', 'Tiene informes predefinidos, filtros personalizados y control de acceso por perfil.', 'Cumple por medio de plugins', 'Reports plugin o Dashboards'),

('DSS02-P07-A04', 'DSS02-P07', 'Analice incidentes y solicitudes de servicio por categoría y tipo. Establezca tendencias e identifique patrones de problemas recurrentes, incumplimientos del SLA o ineficiencias.', 4, 'GLPI', 'Permite generar informes con filtros avanzados por tipo, categoría, SLA, estado, tiempos, etc.', 'Cumple por medio de plugins', 'Reports plugin'),

('DSS02-P07-A05', 'DSS02-P07', 'Utilizar la información como insumo para la planificación de la mejora continua.', 5, 'GLPI', 'Con dashboards o tareas puedes alimentar acciones de mejora continua a partir de métricas.', 'Cumple por medio de plugins', 'Reports / Dashboards + gestión de proyectos'),

('DSS03-P01-A01', 'DSS03-P01', 'Identificar problemas a través de la correlación de informes de incidentes, registros de errores y otros recursos de identificación de problemas.', 2, 'GLPI', 'GLPI permite relacionar múltiples tickets e incidentes con un problema.', '-', '-'),

('DSS03-P01-A02', 'DSS03-P01', 'Gestionar todos los problemas formalmente, con acceso a todos los datos relevantes. Incluir información del sistema de gestión de cambios de TI y detalles de la configuración/activos de TI y de los incidentes.', 2, 'GLPI', 'Se puede enlazar problemas con activos, historial de cambios, incidentes y notas.', '-', '-'),

('DSS03-P01-A03', 'DSS03-P01', 'Defina los grupos de soporte adecuados para ayudar con la identificación de problemas, el análisis de la causa raíz y la búsqueda de soluciones para apoyar la gestión de problemas. Determine los grupos de soporte según categorías predefinidas, como hardware, red, software, aplicaciones y software de soporte.', 2, 'GLPI', 'Puedes asignar problemas a técnicos o grupos definidos (hardware, red, etc.).', '-', '-'),

('DSS03-P01-A04', 'DSS03-P01', 'Defina los niveles de prioridad mediante consultas con la empresa para garantizar que la identificación de problemas y el análisis de la causa raíz se gestionen oportunamente, de acuerdo con los SLA acordados. Establezca los niveles de prioridad en función del impacto y la urgencia en la empresa.', 2, 'GLPI', 'Se pueden definir niveles de prioridad con base en impacto y urgencia.', '-', '-'),

('DSS03-P01-A05', 'DSS03-P01', 'Informar el estado de los problemas identificados a la mesa de servicio para que los clientes y la gerencia de TI puedan mantenerse informados.', 2, 'GLPI', 'Seguimiento automático del estado del problema visible en dashboard y notificaciones.', '-', '-'),

('DSS03-P01-A06', 'DSS03-P01', 'Mantener un catálogo único de gestión de problemas para registrar e informar los problemas identificados. Usar el catálogo para establecer registros de auditoría de los procesos de gestión de problemas, incluyendo el estado de cada problema (es decir, abierto, reabierto, en curso o cerrado).', 2, 'GLPI', 'Existe módulo de problemas independiente con estados y trazabilidad.', '-', '-'),

('DSS03-P02-A01', 'DSS03-P02', 'Identifique los problemas que puedan ser errores conocidos comparando los datos de incidentes con la base de datos de errores conocidos y sospechosos (p. ej., los comunicados por proveedores externos). Clasifique los problemas como errores conocidos.', 3, 'GLPI', 'Puedes marcar un problema como ôerror conocidoö, relacionarlo con tickets y documentar soluciones parciales o temporales.', '-', '-'),

('DSS03-P02-A02', 'DSS03-P02', 'Asocie los elementos de configuración afectados al error establecido/conocido.', 3, 'GLPI', 'Se pueden vincular equipos, software, redes, etc., al problema en curso o al error identificado.', '-', '-'),

('DSS03-P02-A03', 'DSS03-P02', 'Elaborar informes para comunicar el progreso en la resolución de problemas y monitorear el impacto continuo de los problemas no resueltos. Supervisar el estado del proceso de gestión de problemas a lo largo de su ciclo de vida, incluyendo la información de la gestión de cambios y configuración de TI.', 3, 'GLPI', 'Puedes hacer seguimiento al estado, agregar notas, relacionarlo con solicitudes de cambio, y generar informes o exportar CSV.', '-', '-'),

('DSS03-P03-A01', 'DSS03-P03', 'Una vez identificadas las causas fundamentales de los problemas, crear registros de errores conocidos y desarrollar una solución alternativa adecuada.', 2, 'GLPI', 'Puedes crear un problema, marcarlo como error conocido, y documentar workarounds o soluciones temporales.', '-', '-'),

('DSS03-P03-A02', 'DSS03-P03', 'Identificar, evaluar, priorizar y procesar (a través de la gestión de cambios de TI) soluciones a errores conocidos, basándose en un análisis de costo-beneficio y en el impacto y urgencia del negocio.', 3, 'GLPI', 'Puedes vincular problemas con solicitudes de cambio, priorizar por urgencia, y documentar análisis técnico.', '-', '-'),

('DSS03-P04-A01', 'DSS03-P04', 'Cerrar los registros de problemas después de la confirmación de la eliminación exitosa del error conocido o después de un acuerdo con la empresa sobre cómo manejar alternativamente el problema.', 2, 'GLPI', 'Soporta cierre formal, validación por técnico o cliente, documentación y trazabilidad.', 'Flujo de trabajo configurable según política interna.', '-'),

('DSS03-P04-A02', 'DSS03-P04', 'Informar al servicio de asistencia sobre el cronograma de resolución del problema (p. ej., el cronograma de corrección de errores conocidos, la posible solución alternativa o la posibilidad de que el problema persista hasta la implementación del cambio) y las consecuencias del enfoque adoptado. Mantener informados a los usuarios y clientes afectados según corresponda.', 2, 'Zammad', 'Permite automatizar la comunicación con soporte y usuarios a través de tickets, correo y canales integrados.', 'Ideal para mantener a todos informados en tiempo real.', '-'),

('DSS03-P04-A03', 'DSS03-P04', 'Durante todo el proceso de resolución, obtener informes periódicos de la gestión de cambios de TI sobre el progreso en la resolución de problemas y errores.', 3, 'iTop by Combodo', 'Tiene un módulo de gestión de cambios completo y vinculado al ciclo de vida de problemas.', 'Requiere tener bien configurado el CMDB y relaciones entre objetos.', '-'),

('DSS03-P04-A04', 'DSS03-P04', 'Monitorear el impacto continuo de los problemas y errores conocidos en los servicios.', 4, 'Zabbix', 'Monitorea continuamente servicios afectados por errores o problemas conocidos. Puede generar alertas y visualizar su impacto.', 'Puede integrarse con GLPI o iTop para vinculación automática.', 'GLPI'),

('DSS03-P04-A05', 'DSS03-P04', 'Revisar y confirmar el éxito de las resoluciones de los principales problemas.', 4, 'GLPI', 'Soporta procesos de revisión y confirmación antes de cierre final del problema.', 'Opcionalmente permite reabrir si la solución no fue efectiva.', '-'),

('DSS03-P04-A06', 'DSS03-P04', 'Asegúrese de que el conocimiento aprendido de la revisión se incorpore en una reunión de revisión de servicio con el cliente comercial.', 5, 'Eramba', 'Permite registrar conocimiento, vincularlo a políticas y generar trazabilidad de revisiones.', 'Las reuniones deben registrarse manualmente; no automatiza convocatorias.', '-'),

('DSS03-P05-A01', 'DSS03-P05', 'Capturar información sobre problemas relacionados con cambios e incidentes de I&T y comunicarla a las partes interesadas clave. Comunicarse mediante informes y reuniones periódicas entre los responsables de los procesos de gestión de incidentes, problemas, cambios y configuración para analizar los problemas recientes y las posibles acciones correctivas.', 3, 'iTop by Combodo', 'Permite vincular incidentes, cambios y problemas, generar reportes y dar visibilidad a interesados a través de vistas de CMDB.', 'Las reuniones deben gestionarse manualmente, pero la trazabilidad entre procesos es nativa.', '-'),

('DSS03-P05-A02', 'DSS03-P05', 'Asegúrese de que los propietarios y gerentes de procesos de gestión de incidentes, problemas, cambios y configuración se reúnan periódicamente para analizar los problemas conocidos y los cambios planificados para el futuro.', 3, 'GLPI', 'Permite organizar y registrar reuniones periódicas con responsables, mediante tickets y documentación interna.', 'La reunión no se convoca automáticamente, pero puede documentarse en procesos.', 'Moodle'),

('DSS03-P05-A03', 'DSS03-P05', 'Identificar e implementar soluciones sostenibles (soluciones permanentes) que aborden la causa raíz. Presentar solicitudes de cambio mediante los procesos de gestión de cambios establecidos.', 3, 'iTop by Combodo', 'iTop gestiona el ciclo completo desde el problema hasta el cambio, con registros detallados y flujos de validación.', 'Integración nativa entre módulo de problemas y módulo de cambios.', '-'),

('DSS03-P05-A04', 'DSS03-P05', 'Permitir a la empresa monitorear los costos totales de los problemas, capturar los esfuerzos de cambio resultantes de las actividades del proceso de gestión de problemas (por ejemplo, correcciones a problemas y errores conocidos) e informar sobre ellos.', 4, 'GLPI', 'GLPI permite asociar tiempo, técnicos, recursos y costos estimados/ejecutados por cada problema o cambio.', 'Puede exportar datos para análisis financiero o reportes personalizados.', '-'),

('DSS03-P05-A05', 'DSS03-P05', 'Generar informes para supervisar la resolución de problemas según los requisitos de negocio y los SLA. Garantizar la escalación adecuada de los problemas, por ejemplo, escalarlos a un nivel superior de gestión según los criterios acordados, contactar con proveedores externos o consultar con el comité asesor de cambios para aumentar la prioridad de una solicitud urgente de cambio (RFC) e implementar una solución temporal.', 4, 'Zammad', 'Soporta definición de SLA, reglas de escalado automático, alertas y visualización en tiempo real.', 'Configuración altamente personalizable para reglas de negocio y flujo de escalación.', '-'),

('DSS03-P05-A06', 'DSS03-P05', 'Para optimizar el uso de recursos y reducir las soluciones alternativas, realice un seguimiento de las tendencias de los problemas.', 4, 'Zabbix', 'Zabbix analiza patrones de fallas/problemas y tendencias a largo plazo. Se puede correlacionar con tickets o registros de problemas.', 'Puede integrarse con GLPI o iTop para trazabilidad histórica entre alertas y soluciones.', 'GLPI'),

('DSS04-P01-A01', 'DSS04-P01', 'Identificar los procesos de negocio internos y subcontratados y las actividades de servicio que son críticos para las operaciones de la empresa o necesarios para cumplir con las obligaciones legales y/o contractuales.', 2, 'Archi', 'permite modelar detalladamente los procesos internos y tercerizados, sus relaciones con servicios tecnológicos, unidades de negocio y obligaciones contractuales. Esto facilita una visión clara del alcance de la continuidad operativa, estableciendo una base sólida para el análisis de impacto', 'Su modelo visual permite identificar procesos críticos, simular escenarios y documentar requisitos regulatorios', '-'),

('DSS04-P01-A02', 'DSS04-P01', 'Identificar las partes interesadas clave y los roles y responsabilidades para definir y acordar la política y el alcance de la continuidad.', 2, 'Eramba', 'Eramba permite definir claramente partes interesadas, sus roles y responsabilidades, y vincularlas con políticas, riesgos y procesos críticos de continuidad.', 'Excelente trazabilidad entre responsables, políticas y procesos; interfaz clara para auditoría y revisión.', '-'),

('DSS04-P01-A03', 'DSS04-P01', 'Definir y documentar los objetivos políticos mínimos acordados y el alcance para la resiliencia empresarial.', 2, 'Eramba', 'Permite documentar políticas formales con alcance, justificación y asignación de responsables; vincula objetivos con procesos críticos y riesgos.', 'Documentación estructurada con control de versiones, aprobaciones y seguimiento de cumplimiento.', '-'),

('DSS04-P01-A04', 'DSS04-P01', 'Identificar los procesos de soporte esenciales del negocio y los servicios de I&T relacionados.', 2, 'Archi', 'mediante ArchiMate, permite mapear procesos de negocio, sus dependencias con TI y visualizar servicios críticos de soporte.', 'Ideal para análisis visual y estructural de la continuidad entre negocio y TI; se pueden mapear relaciones críticas.', '-'),

('DSS04-P02-A01', 'DSS04-P02', 'Identificar escenarios potenciales que puedan dar lugar a eventos que podrían causar incidentes disruptivos significativos.', 2, 'Eramba', 'Permite identificar amenazas, escenarios de riesgo, vinculados a procesos y activos.', 'Se pueden definir escenarios disruptivos con contexto, responsables y controles.', '-'),

('DSS04-P02-A02', 'DSS04-P02', 'Realizar un análisis de impacto empresarial para evaluar el impacto a lo largo del tiempo de una interrupción en funciones empresariales críticas y el efecto que dicha interrupción tendría sobre ellas.', 2, 'Eramba', 'Soporta análisis de impacto cruzado entre funciones, activos y amenazas; permite cuantificar impactos.', 'Formaliza impacto en el tiempo, recursos, ingresos, cumplimiento, reputación, etc.', '-'),

('DSS04-P02-A03', 'DSS04-P02', 'Establecer el tiempo mínimo requerido para recuperar un proceso de negocio y la I&T de soporte, con base en una duración aceptable de interrupción del negocio y una interrupción máxima tolerable.', 2, 'Eramba', 'Permite configurar MTPD, RTO y RPO para cada proceso o activo, y asociarlo a controles.', 'Compatible con documentación de recuperación y priorización de servicios.', '-'),

('DSS04-P02-A04', 'DSS04-P02', 'Determinar las condiciones y los responsables de las decisiones clave que harán que se invoquen los planes de continuidad.', 2, 'Eramba', 'Asigna responsables, roles críticos, condiciones de activación y procedimientos asociados.', 'Se puede simular activación y asociar decisiones clave a roles de negocio.', '-'),

('DSS04-P02-A05', 'DSS04-P02', 'Evaluar la probabilidad de amenazas que podrían causar la pérdida de la continuidad del negocio. Identificar medidas que reduzcan la probabilidad y el impacto mediante una mejor prevención y una mayor resiliencia.', 3, 'Eramba', 'Evaluación de amenazas y vulnerabilidades por activo, con controles preventivos y de mitigación.', 'Permite mantener la resiliencia documentada y medible.', '-'),

('DSS04-P02-A06', 'DSS04-P02', 'Analizar los requisitos de continuidad para identificar posibles opciones estratégicas de negocio y técnicas.', 3, 'Archi', 'Permite visualizar dependencias y modelar escenarios estratégicos de continuidad.', 'Ideal para representar soluciones como alta disponibilidad, redundancia, etc.', '-'),

('DSS04-P02-A07', 'DSS04-P02', 'Identificar los requisitos de recursos y los costos para cada opción técnica estratégica y formular recomendaciones estratégicas.', 3, 'Archi', 'Puede incluir modelos de capacidad, infraestructura y relaciones de costo/beneficio.', 'Representa arquitecturas alternativas e insumos para decisiones ejecutivas.', '-'),

('DSS04-P02-A08', 'DSS04-P02', 'Obtener la aprobación ejecutiva de la empresa para las opciones estratégicas seleccionadas.', 3, 'Eramba', 'Permite registrar decisiones ejecutivas, justificar selección y documentar firma/aprobación.', 'Incluye historial de aprobación y control de versiones para auditoría.', '-'),

('DSS04-P03-A01', 'DSS04-P03', 'Defina las acciones de respuesta a incidentes y las comunicaciones que se deben tomar en caso de interrupción. Defina las funciones y responsabilidades relacionadas, incluyendo la responsabilidad de las políticas y su implementación.', 2, 'Eramba', 'Gestiona roles, planes de respuesta, responsabilidades y notificaciones.', 'Documentación clara, asignación de roles y trazabilidad. Total cobertura.', '-'),

('DSS04-P03-A02', 'DSS04-P03', 'Asegúrese de que los proveedores clave y los socios externos cuenten con planes de continuidad eficaces. Obtenga evidencia auditada según sea necesario.', 2, 'Eramba', 'Permite gestionar terceros, registrar evidencia de cumplimiento (auditorías, planes, contratos).', 'Gestión formal de evidencias y control de proveedores. Alta trazabilidad.', '-'),

('DSS04-P03-A03', 'DSS04-P03', 'Definir las condiciones y los procedimientos de recuperación que permitan reanudar la actividad comercial. Incluir la actualización y conciliación de las bases de datos para preservar la integridad de la información.', 2, 'Eramba', 'Permite definir procedimientos formales de recuperación, integridad y responsables.', 'Muy fuerte para documentación técnica y validación de integridad de datos.', '-'),

('DSS04-P03-A04', 'DSS04-P03', 'Desarrollar y mantener planes de continuidad del negocio (BCP) y planes de recuperación de desastres (DRP) operativos que incluyan los procedimientos a seguir para garantizar la continuidad de los procesos críticos del negocio o los acuerdos de procesamiento temporal. Incluir enlaces a los planes de los proveedores de servicios subcontratados.', 2, 'Eramba', 'Soporta ciclo de vida completo de BCP/DRP, control de versiones, aprobaciones y vínculos a terceros.', 'Ideal para entornos regulados o críticos. Excelente control documental.', '-'),

('DSS04-P03-A05', 'DSS04-P03', 'Definir y documentar los recursos necesarios para apoyar los procedimientos de continuidad y recuperación, considerando personas, instalaciones e infraestructura de TI.', 2, 'Eramba', 'Permite listar recursos clave por proceso/plan, incl. infraestructura, roles y ubicaciones.', 'Bien estructurado y auditable. Ideal para evaluaciones de preparación.', '-'),

('DSS04-P03-A06', 'DSS04-P03', 'Defina y documente los requisitos de respaldo de la información necesarios para respaldar los planes. Incluya los planos y documentos en papel, así como los archivos de datos. Considere la necesidad de seguridad y almacenamiento externo.', 2, 'Eramba', 'Permite definir requisitos de respaldo por tipo de información, confidencialidad y ubicación.', 'Soporte para medios físicos y digitales, en línea con cumplimiento.', '-'),

('DSS04-P03-A07', 'DSS04-P03', 'Determinar las habilidades requeridas para las personas involucradas en la ejecución del plan y los procedimientos.', 2, 'Eramba', 'Puede definir roles críticos, capacidades requeridas, vinculación con planes y responsables.', 'Se puede asociar a requerimientos de formación y certificación.', '-'),

('DSS04-P03-A08', 'DSS04-P03', 'Distribuya los planos y la documentación de apoyo de forma segura a las partes interesadas debidamente autorizadas. Asegúrese de que los planos y la documentación sean accesibles en cualquier escenario de desastre.', 3, 'Eramba', 'Soporta control de acceso, trazabilidad de entrega, copias externas y control de versiones.', 'Permite distribución segura y controlada incluso en escenarios offline. Eramba cubre las 8 actividades al 100%, de forma estructurada, auditable y alineada con estándares internacionales (ISO 22301, ISO 27001, etc.).', '-'),

('DSS04-P04-A01', 'DSS04-P04', 'Definir objetivos para ejercitar y probar los sistemas comerciales, técnicos, logísticos, administrativos, procedimentales y operativos del plan para verificar la integridad del BCP y el DRP para satisfacer el riesgo comercial.', 2, 'Eramba', 'Permite definir objetivos de pruebas alineados al riesgo y al impacto del negocio. Documenta alcance, métricas y procedimientos de validación.', 'Ideal para planes multidimensionales (negocio, técnico, logístico).', '-'),

('DSS04-P04-A02', 'DSS04-P04', 'Definir y acordar ejercicios realistas para las partes interesadas y validar los procedimientos de continuidad. Incluir roles, responsabilidades y mecanismos de retención de datos que minimicen la interrupción de los procesos de negocio.', 2, 'Eramba', 'Permite construir escenarios de prueba con condiciones reales, asignar roles, definir mecanismos de retención y asegurar continuidad de operación.', 'Soporte detallado de configuración de pruebas sin afectar operación real.', '-'),

('DSS04-P04-A03', 'DSS04-P04', 'Asignar roles y responsabilidades para realizar ejercicios y pruebas del plan de continuidad.', 2, 'Eramba', 'Asigna responsables y validadores por prueba, con trazabilidad. Permite notificar e incluir roles internos y externos.', 'Alta trazabilidad de la ejecución por persona/responsable.', '-'),

('DSS04-P04-A04', 'DSS04-P04', 'Programar ejercicios y actividades de prueba según lo definido en los planes de continuidad.', 3, 'Eramba', 'Integra programación de pruebas, ciclos de vida de continuidad, notificaciones y cadencias.', 'Alineado a marcos como ISO 22301. Soporta versiones, evidencia y cumplimiento.', '-'),

('DSS04-P04-A05', 'DSS04-P04', 'Realice una sesión informativa y un análisis posterior al ejercicio para considerar el logro.', 4, 'Eramba', 'Soporta documentar hallazgos, observaciones, desviaciones y resultados del ejercicio.', 'Controla hallazgos con evidencia, análisis y vínculo a planes.', '-'),

('DSS04-P04-A06', 'DSS04-P04', 'Con base en los resultados de la revisión, elaborar recomendaciones para mejorar los planes de continuidad actuales.', 5, 'Eramba', 'Permite registrar, validar y aprobar recomendaciones, con trazabilidad hacia planes actualizados.', 'Ideal para auditoría y gestión formal de mejora con control de cambios.', '-'),

('DSS04-P05-A01', 'DSS04-P05', 'Revise periódicamente los planes de continuidad y la capacidad frente a las suposiciones realizadas y los objetivos operativos y estratégicos actuales del negocio.', 3, 'Eramba', 'Incluye ciclos de revisión programados y verificación de alineación con objetivos operativos y estratégicos.', 'Permite documentación de hallazgos y recomendaciones por revisión.', '-'),

('DSS04-P05-A02', 'DSS04-P05', 'Revise periódicamente los planes de continuidad para considerar el impacto de cambios nuevos o importantes en la organización empresarial, los procesos de negocios, los acuerdos de subcontratación, las tecnologías, la infraestructura, los sistemas operativos y los sistemas de aplicación.', 3, 'Eramba', 'Permite registrar cambios en cualquier dimensión (procesos, tecnología, subcontratistas), y forzar revisión de planes asociados.', 'Automatiza alertas ante cambios relevantes para planes de continuidad.', '-'),

('DSS04-P05-A03', 'DSS04-P05', 'Considere si puede ser necesaria una evaluación de impacto empresarial revisada, dependiendo de la naturaleza del cambio.', 3, 'Eramba', 'Define condiciones para disparar una nueva evaluación de impacto; relaciona procesos, riesgos, recursos y sistemas.', 'Soporte completo para procesos iterativos de BIA condicionada.', '-'),

('DSS04-P05-A04', 'DSS04-P05', 'Recomendar cambios en políticas, planes, procedimientos, infraestructura, roles y responsabilidades. Comunicarlos según corresponda para su aprobación y procesamiento a la gerencia mediante el proceso de gestión de cambios de TI.', 3, 'Eramba', 'Soporta flujos de aprobación, versionado, auditoría y comunicación formal a las partes interesadas.', 'Se integra con gestión de cambios y ciclo de vida del plan. Permite trazabilidad.', '-'),

('DSS04-P06-A01', 'DSS04-P06', 'Implementar programas de concientización y capacitación sobre BCP y DRP.', 2, 'Moodle', 'Moodle es un LMS open source maduro, ideal para implementar programas de concientización y formación en continuidad.', 'Puede alojar módulos sobre BCP/DRP con pruebas, foros y certificaciones internas.', '-'),

('DSS04-P06-A02', 'DSS04-P06', 'Definir y mantener los requisitos y planes de capacitación para quienes realizan la planificación de la continuidad, las evaluaciones de impacto, las evaluaciones de riesgos, la comunicación con los medios y la respuesta a incidentes. Asegurarse de que los planes de capacitación consideren la frecuencia y los mecanismos de impartición de la capacitación.', 3, 'Moodle', 'Permite definir itinerarios formativos, programar repeticiones, usar varios formatos (video, PDF, SCORM).', 'Ideal para trazabilidad de participación, frecuencia y formato de entrega.', '-'),

('DSS04-P06-A03', 'DSS04-P06', 'Desarrollar competencias basadas en la formación práctica, incluyendo la participación en ejercicios y pruebas.', 3, 'Eramba', 'Aunque no es LMS, permite vincular ejercicios reales a personas, registrar su participación y competencias desarrolladas.', 'Ideal para registrar la parte práctica y operacional de la formación.', '-'),

('DSS04-P06-A04', 'DSS04-P06', 'Con base en los resultados de los ejercicios y pruebas, monitorear las habilidades y competencias.', 4, 'Eramba', 'Evalúa desempeño real en ejercicios, con evidencias por usuario. Genera acciones correctivas si la competencia no se evidencia.', 'Gestión de brechas basada en desempeño, no solo formación teórica.', '-'),

('DSS04-P07-A01', 'DSS04-P07', 'Realice copias de seguridad de sistemas, aplicaciones, datos y documentación según un programa definido. Considere la frecuencia (mensual, semanal, diaria, etc.), el modo de copia de seguridad (p. ej., duplicación de disco para copias de seguridad en tiempo real o DVD-ROM para retención a largo plazo), el tipo de copia de seguridad (p. ej., completa o incremental) y el tipo de medio. Considere también las copias de seguridad en línea automatizadas, los tipos de datos (p. ej., voz, ópticos), la creación de registros, los datos informáticos críticos del usuario final (p. ej., hojas de cálculo), la ubicación física y lógica de las fuentes de datos, la seguridad y los derechos de acceso, y el cifrado.', 2, 'Zabbix', 'Zabbix puede monitorear tareas de backup (frecuencia, estado, alertas). Para gestión real de backups se requiere integración con una solución de backup especializada.', 'Zabbix solo gestiona visibilidad. Se requiere BorgBackup (CLI, deduplicación, cifrado) o Bareos (open source, completo).', 'BorgBackup o Bareos'),

('DSS04-P07-A02', 'DSS04-P07', 'Defina los requisitos para el almacenamiento local y remoto de los datos de respaldo que cumplan con los requisitos del negocio. Considere la accesibilidad necesaria para respaldar los datos.', 2, 'Eramba', 'Permite definir políticas, controles y requisitos de almacenamiento conforme a regulación y seguridad de la información.', 'Gestión documental sólida. Puede auditar cumplimiento y justificar decisiones de almacenamiento.', '-'),

('DSS04-P07-A03', 'DSS04-P07', 'Pruebe y actualice periódicamente los datos archivados y respaldados.', 2, 'Zabbix', 'Zabbix puede verificar estado, alertar sobre fallas y automatizar tests periódicos. Bareos permite restauración programada y verificación de integridad.', 'Zabbix no ejecuta pruebas, pero monitoriza. Requiere backup engine integrado.', 'Bareos (o Borg)'),

('DSS04-P07-A04', 'DSS04-P07', 'Asegúrese de que los sistemas, aplicaciones, datos y documentación mantenidos o procesados por terceros cuenten con copias de seguridad adecuadas o estén protegidos de alguna otra manera. Considere exigir la devolución de las copias de seguridad a terceros. Considere la posibilidad de establecer un depósito en garantía.', 2, 'Eramba', 'Permite gestionar proveedores, evaluar cumplimiento, exigir evidencia de backup y acuerdos de protección documental.', 'Control y trazabilidad legal/técnica de respaldo en proveedores. Muy alineado a auditoría y normativa.', '-'),

('DSS04-P08-A01', 'DSS04-P08', 'Evaluar el cumplimiento del BCP y DRP documentados.', 4, 'Eramba', 'Eramba permite contrastar la ejecución real contra el plan documentado, evaluar desviaciones, registrar evidencia y establecer cumplimiento.', 'Ideal para entornos regulados que requieren evidencia formal post-ejercicio.', '-'),

('DSS04-P08-A02', 'DSS04-P08', 'Determinar la eficacia de los planes, las capacidades de continuidad, los roles y responsabilidades, las habilidades y competencias, la resiliencia ante el incidente, la infraestructura técnica y las estructuras y relaciones organizacionales.', 4, 'Eramba', 'Ofrece trazabilidad entre pruebas, roles, responsables, infraestructura y respuesta. Permite analizar qué funcionó, qué falló y por qué.', 'Analiza el ecosistema completo post-BCP/DRP. Útil para evaluaciones cruzadas y causa raíz.', '-'),

('DSS04-P08-A03', 'DSS04-P08', 'Identificar debilidades u omisiones en los planes y capacidades, y formular recomendaciones de mejora. Obtener la aprobación de la gerencia para cualquier cambio en los planes y aplicarlo mediante el proceso de control de cambios de la empresa.', 5, 'Eramba', 'Permite registrar hallazgos, generar recomendaciones, someterlas a aprobación y vincularlas a cambios con control de versiones.', 'Trazabilidad completa de mejora continua, con control formal y aprobaciones.', '-'),

('DSS05-P01-A01', 'DSS05-P01', 'Instalar y activar herramientas de protección contra software malicioso en todas las instalaciones de procesamiento, con archivos de definición de software malicioso que se actualicen según sea necesario (de forma automática o semiautomática).', 2, 'Wazuh', 'Wazuh permite gestionar agentes de seguridad en endpoints, monitorear antivirus, aplicar políticas de actualización y alertar sobre desincronización de firmas.', 'Específicamente diseñado para esta funcionalidad', '-'),

('DSS05-P01-A02', 'DSS05-P01', 'Filtrar el tráfico entrante, como correo electrónico y descargas, para protegerse contra información no solicitada (por ejemplo, software espía, correos electrónicos de phishing).', 2, 'Proxmox Mail Gateway', 'Filtra correos y adjuntos maliciosos usando firmas, RBL, heurística y antivirus integrados. Muy efectivo contra phishing y spam.', 'Enfocado exclusivamente a email y malware. GLPI, Jira, Eramba no cubren esto.', '-'),

('DSS05-P01-A03', 'DSS05-P01', 'Comunicar la concienciación sobre el software malicioso e implementar procedimientos y responsabilidades de prevención. Realizar capacitaciones periódicas sobre malware en el uso del correo electrónico e internet. Capacitar a los usuarios para que no abran, sino que reporten, correos electrónicos sospechosos y para que no instalen software compartido o no autorizado.', 3, 'Moodle', 'Plataforma LMS ideal para cursos sobre ciberseguridad, concientización sobre malware, phishing, y simulacros.', 'Permite medir progreso, hacer refuerzos periódicos y emitir certificaciones internas.', '-'),

('DSS05-P01-A04', 'DSS05-P01', 'Distribuya todo el software de protección de forma centralizada (versión y nivel de parche) mediante una configuración centralizada y una gestión de cambios de TI.', 3, 'Wazuh', 'Wazuh gestiona agentes y supervisa estado; GLPI puede documentar despliegues, parches y versiones en inventario con control de cambios.', 'Wazuh supervisa el cumplimiento y GLPI documenta el ciclo de distribución.', 'GLPI'),

('DSS05-P01-A05', 'DSS05-P01', 'Revisar y evaluar periódicamente la información sobre nuevas amenazas potenciales (por ejemplo, revisar los avisos de seguridad de los productos y servicios de los proveedores).', 4, 'Eramba', 'Eramba permite mantener alertas, boletines y análisis de vulnerabilidades como parte del sistema de controles; Wazuh obtiene feeds automáticos.', 'Ideal para mantener vigilancia activa y realizar acciones correctivas oportunas.', 'Wazuh'),

('DSS05-P02-A01', 'DSS05-P02', 'Permita que solo los dispositivos autorizados accedan a la información corporativa y a la red empresarial. Configure estos dispositivos para forzar el ingreso de contraseñas.', 2, 'Wazuh', 'Monitorea endpoints, identifica dispositivos no autorizados y verifica políticas de acceso (contraseñas, login fallidos).', 'Puede integrarse con AD o directorios para control de acceso.', '-'),

('DSS05-P02-A02', 'DSS05-P02', 'Implemente mecanismos de filtrado de red, como firewalls y software de detección de intrusos. Aplique políticas adecuadas para controlar el tráfico entrante y saliente.', 2, 'pfSense', 'pfSense es un firewall/router OS potente. Suricata es un motor IDS/IPS que se puede integrar para detección profunda.', 'Juntos brindan filtrado, inspección de paquetes, alertas y bloqueo.', 'Suricata Motor'),

('DSS05-P02-A03', 'DSS05-P02', 'Aplicar protocolos de seguridad aprobados a la conectividad de la red.', 2, 'pfSense', 'Permite configurar protocolos seguros: IPsec, OpenVPN, TLS, HTTPS en todas las rutas de comunicación.', 'Puede forzar estándares mínimos por segmento de red.', '-'),

('DSS05-P02-A04', 'DSS05-P02', 'Configurar el equipo de red de forma segura.', 2, 'Ansible', 'Automatiza la configuración segura de switches, routers, firewalls.', 'Permite repetibilidad y hardening estructurado en dispositivos de red.', '-'),

('DSS05-P02-A05', 'DSS05-P02', 'Cifrar la información en tránsito según su clasificación.', 3, 'pfSense', 'Soporta VPNs, túneles cifrados, y reglas TLS/IPsec. Se puede definir según nivel de clasificación.', 'Alta granularidad por red, protocolo y aplicación.', '-'),

('DSS05-P02-A06', 'DSS05-P02', 'Con base en las evaluaciones de riesgos y los requisitos del negocio, establecer y mantener una política de seguridad de la conectividad.', 3, 'Eramba', 'Permite definir, documentar y revisar políticas de conectividad, justificadas por evaluación de riesgo.', 'Trazabilidad de políticas con control de versiones.', '-'),

('DSS05-P02-A07', 'DSS05-P02', 'Establecer mecanismos confiables para apoyar la transmisión y recepción segura de información.', 3, 'Proxmox Mail Gateway', 'Proxmox garantiza correo seguro. pfSense protege transferencia general vía VPN/HTTPS.', '-', '-'),

('DSS05-P02-A08', 'DSS05-P02', 'Realizar pruebas de penetración periódicas para determinar la idoneidad de la protección de la red.', 4, 'Kali Linux', 'Suite estándar para pentesting: Nmap, Metasploit, Nikto, etc. Evaluación ofensiva real de la red.', 'Requiere expertos. Totalmente open source.', '-'),

('DSS05-P02-A09', 'DSS05-P02', 'Realizar pruebas periódicas de seguridad del sistema para determinar la idoneidad de la protección del sistema.', 4, 'Wazuh', 'Plataforma de seguridad integral que permite realizar monitoreo continuo del sistema, detección de amenazas, análisis de integridad, auditoría de logs y cumplimiento normativo. Automatiza tareas periódicas de seguridad.', 'Solución open source robusta y extensible. Soporta sistemas Linux y Windows. Requiere despliegue de agentes en los dispositivos a monitorear. Muy útil para entornos medianos a grandes.', '-'),

('DSS05-P03-A01', 'DSS05-P03', 'Configurar los sistemas operativos de forma segura.', 2, 'OpenSCAP v2.1', 'OpenSCAP permite aplicar y validar configuraciones seguras según estándares internacionales (CIS, DISA STIG). Escanea, genera reportes y ayuda a automatizar el hardening de sistemas operativos.', 'OpenSCAP permite escanear, comparar con estándares (CIS, STIG), generar reportes y aplicar remediaciones automáticas. La otras herramientas no ejecutan esta validación técnica directamente. https://www.open-scap.org/', '-'),

('DSS05-P03-A02', 'DSS05-P03', 'Implementar mecanismos de bloqueo de dispositivos.', 2, 'Zabbix', 'Monitoreo de dispositivos y posibilidad de ejecutar scripts para bloqueo automatizado.', 'Bloqueo no es nativo, se logra con integraciones.', 'iptables, scripts, firewalls'),

('DSS05-P03-A03', 'DSS05-P03', 'Gestionar el acceso y control remoto (por ejemplo, dispositivos móviles, teletrabajo).', 2, 'OpenSSH', 'Acceso remoto seguro mediante cifrado, autenticación y control de sesiones.', 'Solución ampliamente adoptada para gestión remota.', 'Fail2ban, Zabbix'),

('DSS05-P03-A04', 'DSS05-P03', 'Gestionar la configuración de la red de forma segura.', 2, 'HAProxy', 'Gestión de red a través de reglas de balanceo, control de tráfico y políticas de acceso.', 'Requiere conocimiento técnico para seguridad óptima.', 'Firewalls, Zabbix'),

('DSS05-P03-A05', 'DSS05-P03', 'Implementar el filtrado de tráfico de red en los dispositivos terminales.', 2, 'Snort', 'IDS/IPS que analiza tráfico y aplica reglas de bloqueo a nivel de red o endpoint.', 'Integrable con firewalls para acción automatizada.', 'iptables, pfSense, Wazuh'),

('DSS05-P03-A06', 'DSS05-P03', 'Proteger la integridad del sistema.', 2, 'Zabbix', 'Monitoreo de integridad de archivos, servicios y comportamiento anómalo del sistema.', 'Puede combinarse con herramientas SIEM.', 'Wazuh, scripts'),

('DSS05-P03-A07', 'DSS05-P03', 'Proporcionar protección física a los dispositivos terminales.', 2, NULL, '-', '-', '-'),

('DSS05-P03-A08', 'DSS05-P03', 'Deseche los dispositivos terminales de forma segura.', 2, NULL, '-', '-', '-'),

('DSS05-P03-A09', 'DSS05-P03', 'Gestione el acceso malicioso a través del correo electrónico y los navegadores web. Por ejemplo, bloquee ciertos sitios web y desactive la función de clic en enlaces para smartphones.', 2, 'Snort', 'IDS/IPS que detecta y bloquea tráfico web/correo malicioso.', 'Puede bloquear acceso o tráfico malicioso.', 'pfSense, SquidGuard'),

('DSS05-P03-A10', 'DSS05-P03', 'Cifrar la información almacenada según su clasificación.', 3, 'GPG', 'Cifra datos con clave pública/privada según niveles de confidencialidad.', 'Requiere clasificación y políticas definidas previamente.', 'Scripts, backup tools'),

('DSS05-P04-A01', 'DSS05-P04', 'Mantener los derechos de acceso de los usuarios de acuerdo con la función empresarial, los requisitos de los procesos y las políticas de seguridad. Alinear la gestión de identidades y derechos de acceso con los roles y responsabilidades definidos, basándose en los principios de privilegio mínimo, necesidad de tener y necesidad de saber.', 2, 'GLPI', 'Define perfiles y permisos según funciones empresariales y privilegios mínimos.', 'Plugin opcional para sincronización.', 'LDAP, FusionInventory'),

('DSS05-P04-A02', 'DSS05-P04', 'Administrar todos los cambios a los derechos de acceso (creación, modificaciones y eliminaciones) de manera oportuna basándose únicamente en transacciones aprobadas y documentadas autorizadas por personas de gestión designadas.', 3, 'GLPI', 'Flujos de aprobación para creación, modificación y eliminación de accesos, con trazabilidad.', 'Requiere plugin de autorización y flujos.', 'Approval Management, Behaviors'),

('DSS05-P04-A03', 'DSS05-P04', 'Segregar, reducir al mínimo necesario y gestionar activamente las cuentas de usuarios privilegiados. Supervisar toda la actividad de estas cuentas.', 3, 'Eramba', 'Define políticas, segrega accesos, audita actividades de roles privilegiados.', 'No aplica cambios directos, pero audita conforme a políticas de seguridad.', 'Active Directory, IAM externos'),

('DSS05-P04-A04', 'DSS05-P04', 'Identifique de forma única todas las actividades de procesamiento de información por roles funcionales. Coordínese con las unidades de negocio para garantizar que todos los roles estén definidos de forma coherente, incluidos los definidos por la propia empresa dentro de las aplicaciones de procesos de negocio.', 3, 'Eramba', 'Relaciona roles con procesos de negocio, mantiene definición y coherencia organizacional.', 'Alineado con estándares de gobernanza y cumplimiento.', 'Sistemas de gestión de procesos'),

('DSS05-P04-A05', 'DSS05-P04', 'Autenticar todo acceso a los activos de información según el rol del individuo o las reglas de negocio. Coordinarse con las unidades de negocio que gestionan la autenticación en las aplicaciones utilizadas en los procesos de negocio para garantizar que los controles de autenticación se hayan administrado correctamente.', 3, 'Eramba', 'Define roles, gestiona autenticación y autorización conforme a procesos empresariales.', 'Requiere integración para autenticación externa.', 'LDAP / SSO / Active Directory'),

('DSS05-P04-A06', 'DSS05-P04', 'Garantizar que todos los usuarios (internos, externos y temporales) y su actividad en los sistemas de TI (aplicaciones empresariales, infraestructura de TI, operaciones del sistema, desarrollo y mantenimiento) sean identificables de forma única.', 3, 'OpenSSH', 'Autenticación única por usuario, logs detallados de sesiones remotas.', 'Limitado a entornos Unix/Linux.', 'Syslog / Fail2Ban'),

('DSS05-P04-A07', 'DSS05-P04', 'Mantener un registro de auditoría del acceso a la información en función de su sensibilidad y los requisitos reglamentarios.', 4, NULL, 'Zabbix registra eventos y accesos configurables, alineado a parámetros de seguridad.', 'Requiere configuración de triggers y plantillas.', 'Syslog / SIEM'),

('DSS05-P04-A08', 'DSS05-P04', 'Realizar una revisión periódica de la gestión de todas las cuentas y privilegios relacionados.', 4, 'GLPI', 'Permite gestionar cuentas y su historial con soporte para revisiones manuales o por plugins.', 'Puede integrarse para revisión avanzada.', 'LDAP / Reports Plugin / DataInjection'),

('DSS05-P05-A01', 'DSS05-P05', 'Registre y monitoree todos los puntos de acceso a los sitios de TI. Registre a todos los visitantes, incluyendo contratistas y proveedores, del sitio.', 2, 'GLPI', 'Registra visitas mediante tickets, seguimiento y entradas personalizadas.', 'Admite personalización de formularios.', 'Formcreator / Reports Plugin'),

('DSS05-P05-A02', 'DSS05-P05', 'Asegúrese de que todo el personal muestre una identificación debidamente aprobada en todo momento.', 2, 'GLPI', 'Documentación de identificaciones en fichas de usuario.', 'No gestiona control físico, pero sí validación documental.', 'LDAP / Directorio de usuarios'),

('DSS05-P05-A03', 'DSS05-P05', 'Exigir que los visitantes estén escoltados en todo momento mientras se encuentren en el lugar.', 2, NULL, 'GLPI permite la asignación de acompañantes mediante tareas o responsables.', 'Se puede configurar como política interna de atención.', 'Formcreator'),

('DSS05-P05-A04', 'DSS05-P05', 'Restrinja y monitoree el acceso a sitios de TI sensibles estableciendo restricciones perimetrales, como cercas, muros y dispositivos de seguridad en puertas interiores y exteriores.', 2, 'Zabbix', 'Monitorea dispositivos conectados, sensores o controladores de acceso mediante red.', 'Requiere hardware compatible.', 'SNMP / IoT / Controladores de acceso'),

('DSS05-P05-A05', 'DSS05-P05', 'Gestionar las solicitudes para permitir el acceso debidamente autorizado a las instalaciones informáticas.', 3, 'GLPI', 'Tickets con validaciones y aprobaciones para control de acceso físico.', 'Puede tener flujos de autorización según cargos/responsables.', 'Formcreator / Approval Plugin'),

('DSS05-P05-A06', 'DSS05-P05', 'Asegúrese de que los perfiles de acceso se mantengan actualizados. Adapte el acceso a los sitios de TI (salas de servidores, edificios, áreas o zonas) a la función y las responsabilidades del puesto.', 3, 'GLPI', 'Gestión y actualización de roles y permisos conforme a perfiles definidos.', 'No gestiona acceso físico, pero permite control documental.', 'LDAP / Plugins de Recursos Humanos'),

('DSS05-P05-A07', 'DSS05-P05', 'Realizar periódicamente capacitaciones sobre concientización sobre seguridad de la información física.', 3, 'Eramba', 'Incluye campañas de concienciación, formación y seguimiento.', 'Permite evaluaciones y reportes de cumplimiento.', 'No requiere integración adicional'),

('DSS05-P06-A01', 'DSS05-P06', 'Establecer procedimientos para regular la recepción, el uso, la eliminación y la disposición de documentos confidenciales y dispositivos de salida dentro y fuera de la empresa.', 2, NULL, 'GLPI ayuda a documentar procedimientos y el ciclo de vida de activos.', 'Usa plugins para trazabilidad.', 'Formcreator / DataInjection'),

('DSS05-P06-A02', 'DSS05-P06', 'Asegúrese de que existan controles criptográficos para proteger la información confidencial almacenada electrónicamente.', 2, 'GPG', 'Cifrado de archivos y correos con GPG.', 'Alta compatibilidad.', 'Mailvelope / clientes de correo'),

('DSS05-P06-A03', 'DSS05-P06', 'Asignar privilegios de acceso a documentos confidenciales y dispositivos de salida según el principio de mínimo privilegio, equilibrando el riesgo y los requisitos comerciales.', 3, NULL, 'Eramba ayuda con el control de acceso basado en roles y políticas.', 'Necesita configuración robusta.', 'LDAP / Integraciones externas'),

('DSS05-P06-A04', 'DSS05-P06', 'Establecer un inventario de documentos sensibles y dispositivos de salida y realizar conciliaciones periódicas.', 3, 'GLPI', 'Gestión de activos con marcación de sensibilidad.', 'Campos personalizables para sensibilidad.', 'Plugins de inventario / DataInjection'),

('DSS05-P06-A05', 'DSS05-P06', 'Establecer medidas de seguridad físicas adecuadas para los documentos sensibles.', 3, NULL, 'Eramba ayuda con la gestión documental de controles físicos de seguridad.', 'No ejecuta controles, los documenta.', 'Herramientas de cumplimiento externo'),

('DSS05-P06-A06', 'DSS05-P06', 'Implementar controles criptográficos para garantizar la protección de la información sensible (confidencialidad, autenticidad, integridad).', 3, 'GPG', 'Protección de datos mediante cifrado y firma digital.', 'Amplia adopción en entornos críticos.', 'Clientes de correo / plataformas de cifrado'),

('DSS05-P07-A01', 'DSS05-P07', 'Utilizar continuamente una cartera de tecnologías, servicios y activos compatibles (por ejemplo, escáneres de vulnerabilidad, detectores de errores y rastreadores, analizadores de protocolo) para identificar vulnerabilidades de seguridad de la información.', 2, NULL, 'Owasp ZAP escanea aplicaciones web para encontrar vulnerabilidades.', 'Necesita configuración para escaneos automáticos.', 'Jenkins / GLPI / pipelines'),

('DSS05-P07-A02', 'DSS05-P07', 'Definir y comunicar los escenarios de riesgo para que puedan reconocerse fácilmente y comprenderse su probabilidad e impactos.', 2, 'Eramba', 'Modelado y documentación de escenarios de riesgo.', 'Visualización clara del impacto/probabilidad.', 'APIs externas / Exportadores'),

('DSS05-P07-A03', 'DSS05-P07', 'Revise periódicamente los registros de eventos para detectar posibles incidentes.', 2, 'Zabbix', 'Permite recolectar y analizar eventos del sistema.', 'Compatible con múltiples plataformas.', 'GLPI'),

('DSS05-P07-A04', 'DSS05-P07', 'Asegúrese de que los tickets de incidentes relacionados con la seguridad se creen de manera oportuna cuando el monitoreo identifique incidentes potenciales.', 2, 'GLPI', 'Automatización de creación de tickets ante incidentes monitoreados.', 'Soporte vía plugins para herramientas de monitoreo.', 'Zabbix / Snort / Formcreator'),

('DSS05-P07-A05', 'DSS05-P07', 'Registrar eventos relacionados con la seguridad y conservar los registros durante el período apropiado.', 3, NULL, 'Snort tiene IDS que registra y almacena tráfico y eventos de seguridad.', 'Puede integrarse con sistemas de alerta y SIEM.', 'Zabbix / syslog / GLPI'),

('DSS06-P01-A01', 'DSS06-P01', 'Identificar y documentar las actividades de control necesarias para los procesos de negocio clave para satisfacer los requisitos de control de los objetivos estratégicos, operativos, de informes y de cumplimiento.', 2, 'Eramba', 'Permite documentar controles asociados a objetivos y procesos clave.', 'Alta trazabilidad.', 'API / CSV / Excel'),

('DSS06-P01-A02', 'DSS06-P01', 'Priorizar las actividades de control según el riesgo inherente al negocio. Identificar los controles clave.', 2, 'Eramba', 'Evaluación de riesgos con matrices y priorización de controles clave.', 'Apoya toma de decisiones con mapas de riesgo.', 'API'),

('DSS06-P01-A03', 'DSS06-P01', 'Garantizar la propiedad de las actividades de control clave.', 2, 'Eramba', 'Asignación clara de responsables y tareas de seguimiento.', 'Seguimiento automático.', 'Outlook / API'),

('DSS06-P01-A04', 'DSS06-P01', 'Implementar controles automatizados.', 3, 'Zabbix', 'Automatización de respuestas y acciones ante condiciones definidas.', 'Requiere definición técnica previa.', 'GLPI / scripts externos'),

('DSS06-P01-A05', 'DSS06-P01', 'Monitorear continuamente las actividades de control de principio a fin para identificar oportunidades de mejora.', 4, 'Eramba', 'Seguimiento de estado, cumplimiento y efectividad de controles.', 'Permite acciones correctivas planificadas.', 'GLPI / BI tools'),

('DSS06-P01-A06', 'DSS06-P01', 'Mejorar continuamente el diseño y el funcionamiento de los controles de los procesos de negocio.', 5, 'Eramba', 'Evaluación continua y revisión cíclica de efectividad y diseño de controles.', 'Apoya cultura de mejora en procesos críticos.', 'API / Sistema de gestión de calidad externo'),

('DSS06-P02-A01', 'DSS06-P02', 'Autenticar al originador de las transacciones y verificar que el individuo tenga la autoridad para originar la transacción.', 2, 'OpenSSH', 'Permite autenticación mediante claves públicas, validando identidad previa a conexión remota.', 'Aplica principalmente a acceso remoto, no cubre lógica de negocio transaccional.', 'LDAP, Kerberos'),

('DSS06-P02-A02', 'DSS06-P02', 'Garantizar una adecuada segregación de funciones respecto del origen y aprobación de transacciones.', 2, NULL, '-', '-', '-'),

('DSS06-P02-A03', 'DSS06-P02', 'Verificar que las transacciones sean precisas, completas y válidas. Los controles pueden incluir secuencia, límite, rango, validez, razonabilidad, búsquedas en tablas, existencia, verificación de claves, dígito de control, integridad, comprobaciones de duplicados y relaciones lógicas, y modificaciones de tiempo. Los criterios y parámetros de validación deben estar sujetos a revisiones y confirmaciones periódicas. Validar los datos de entrada y modificarlos o, si corresponde, devolverlos para su corrección lo más cerca posible del punto de origen.', 3, NULL, '-', '-', '-'),

('DSS06-P02-A04', 'DSS06-P02', 'Sin comprometer los niveles de autorización de la transacción original, corrija y reenvíe los datos ingresados erróneamente. Cuando sea necesario para la reconstrucción, conserve los documentos originales durante el tiempo necesario.', 3, NULL, '-', '-', '-'),

('DSS06-P02-A05', 'DSS06-P02', 'Mantener la integridad y validez de los datos durante todo el ciclo de procesamiento. Asegurarse de que la detección de transacciones erróneas no interrumpa el procesamiento de las transacciones válidas.', 3, 'Wireshark', 'Permite análisis detallado de paquetes para confirmar que los datos no sean alterados en tránsito.', 'Solo valida integridad en tránsito de red, no aplicación.', 'SIEM, herramientas forenses'),

('DSS06-P02-A06', 'DSS06-P02', 'Gestionar la información de forma autorizada, entregarla al destinatario correspondiente y protegerla durante su transmisión. Verificar la exactitud e integridad de la información.', 3, 'GPG', 'Cifra y firma digitalmente la información para asegurar integridad, confidencialidad y autenticidad.', 'Ideal para correos, archivos y documentos.', 'Clientes de correo, automatización'),

('DSS06-P02-A07', 'DSS06-P02', 'Mantener la integridad de los datos durante interrupciones inesperadas en el procesamiento empresarial. Confirmar la integridad de los datos tras fallos de procesamiento.', 3, NULL, '-', '-', '-'),

('DSS06-P02-A08', 'DSS06-P02', 'Antes de transferir datos de transacciones entre aplicaciones internas y funciones comerciales/operativas (dentro o fuera de la empresa), verifique el direccionamiento correcto, la autenticidad del origen y la integridad del contenido. Mantenga la autenticidad e integridad durante la transmisión o el transporte.', 3, 'HAProxy', 'Verifica origen, destino y puede usar TLS para asegurar la integridad en flujo de red.', 'Aplica en red, no valida contenido interno.', 'Firewalls, IDS'),

('DSS06-P03-A01', 'DSS06-P03', 'Asignar roles y responsabilidades según las descripciones de trabajo aprobadas y las actividades del proceso de negocio.', 2, 'GLPI', 'Permite definir perfiles de usuario con diferentes roles y permisos asociados a tareas específicas.', 'Se puede complementar con plugins para workflows más complejos.', 'Plugin: Data Injection, Formcreator'),

('DSS06-P03-A02', 'DSS06-P03', 'Asignar niveles de autoridad para la aprobación de transacciones, límites de transacciones y cualquier otra decisión relacionada con el proceso de negocio, según los roles laborales aprobados.', 2, NULL, '-', '-', '-'),

('DSS06-P03-A03', 'DSS06-P03', 'Asignar roles para actividades sensibles de modo que haya una clara segregación de funciones.', 2, 'Eramba', 'Permite la asignación de roles y políticas de control de acceso, útil para funciones sensibles.', 'Enfocado en GRC (Gobierno, Riesgo y Cumplimiento).', 'No requiere integración para esta funcionalidad básica.'),

('DSS06-P03-A04', 'DSS06-P03', 'Asignar derechos y privilegios de acceso según el mínimo requerido para realizar las actividades laborales, según los roles predefinidos. Eliminar o revisar los derechos de acceso inmediatamente si el rol laboral cambia o si un miembro del personal deja el área de procesos de negocio. Revisar periódicamente para garantizar que el acceso sea adecuado para las amenazas, los riesgos, la tecnología y las necesidades del negocio.', 3, 'OpenSSH', 'Permite acceso granular mediante llaves públicas y configuraciones de acceso.', 'Aplicable a servidores y entornos Unix/Linux.', 'LDAP o sistemas de autenticación externos'),

('DSS06-P03-A05', 'DSS06-P03', 'Proporcionar periódicamente concientización y capacitación sobre las funciones y responsabilidades para que todos comprendan sus responsabilidades, la importancia de los controles y la seguridad, integridad, confidencialidad y privacidad de la información de la empresa en todas sus formas.', 3, NULL, '-', '-', '-'),

('DSS06-P03-A06', 'DSS06-P03', 'Garantizar que los privilegios administrativos estén protegidos, rastreados y controlados de manera suficiente y eficaz para evitar su uso indebido.', 3, 'Zabbix', 'Monitorea accesos, actividades de red y cambios en infraestructura, ayudando a rastrear privilegios.', 'No gestiona privilegios, pero sí evidencia de uso indebido.', 'Syslog, herramientas de SIEM'),

('DSS06-P03-A07', 'DSS06-P03', 'Revise periódicamente las definiciones de control de acceso, los registros y los informes de excepciones. Asegúrese de que todos los privilegios de acceso sean válidos y estén alineados con el personal actual y sus roles asignados.', 4, 'GLPI', 'A través de la gestión de usuarios y perfiles, junto a logs y auditoría del sistema.', 'Puede complementarse con informes y validaciones periódicas.', 'Plugin: Audit, Reports'),

('DSS06-P04-A01', 'DSS06-P04', 'Revisar errores, excepciones y desviaciones.', 2, 'GLPI', 'Permite registrar, rastrear y categorizar errores y excepciones mediante tickets.', 'Soporta revisión mediante flujos de trabajo y estados personalizados.', 'Plugin: Behaviors para validaciones personalizadas'),

('DSS06-P04-A02', 'DSS06-P04', 'Dar seguimiento, corregir, aprobar y reenviar documentos fuente y transacciones.', 2, 'GLPI', 'Usa tickets vinculados con tareas y aprobaciones; puede reenviar solicitudes y actualizaciones.', 'Se requiere diseño adecuado del flujo de aprobación.', 'Plugin: Formcreator para formularios estructurados'),

('DSS06-P04-A03', 'DSS06-P04', 'Mantener evidencia de acciones correctivas.', 2, 'Eramba', 'Permite registrar y documentar acciones correctivas derivadas de excepciones y no conformidades.', 'Enfocado a organizaciones con necesidades GRC.', 'No requiere plugin para esta funcionalidad'),

('DSS06-P04-A04', 'DSS06-P04', 'Definir y mantener procedimientos para asignar la propiedad de errores y excepciones, corregir errores, anular errores y manejar condiciones de desequilibrio.', 3, 'GLPI', 'Permite definir responsables por tipo de error mediante asignación automática y categorización.', 'Se puede complementar con flujos condicionales.', 'Plugin: Escalation y RulesEngine'),

('DSS06-P04-A05', 'DSS06-P04', 'Informar oportunamente los errores relevantes del proceso de información empresarial para realizar un análisis de causa raíz y tendencias.', 4, NULL, 'Zabbix permite registrar eventos, crear alertas y generar reportes para análisis de tendencias de errores.', 'Ideal para eventos de infraestructura o sistemas críticos.', 'Integración con Grafana para visualización avanzada'),

('DSS06-P05-A01', 'DSS06-P05', 'Capturar la información de la fuente, la evidencia de apoyo y el registro de las transacciones.', 2, NULL, 'Zabbix permite recopilar registros detallados de eventos, monitorear la infraestructura, y almacenar métricas y alertas que pueden actuar como evidencia de soporte.', 'Puede extenderse con scripts personalizados para capturar registros más específicos.', 'Integración con syslog y bases de datos externas'),

('DSS06-P05-A02', 'DSS06-P05', 'Definir los requisitos de retención, en función de los requisitos del negocio, para satisfacer las necesidades operativas, de informes financieros y de cumplimiento.', 3, 'Eramba', 'Permite establecer políticas y procedimientos documentados sobre retención de información, auditorías y controles asociados.', 'Diseñada para entornos regulados y controlados.', 'Compatible con LDAP y herramientas externas de almacenamiento'),

('DSS06-P05-A03', 'DSS06-P05', 'Eliminar la información fuente, la evidencia de soporte y el registro de transacciones de acuerdo con la política de retención.', 3, 'Eramba', 'Soporta procesos documentados para manejo del ciclo de vida de la información, incluyendo eliminación conforme a política.', 'Se requiere integración o proceso externo para automatizar la eliminación física de datos.', 'Puede complementarse con scripts o herramientas de gestión documental'),

('DSS06-P06-A01', 'DSS06-P06', 'Restringir el uso, distribución y acceso físico a la información según su clasificación.', 2, 'OpenSSH', 'Permite establecer conexiones seguras con acceso controlado a recursos de TI, limitando la distribución de información a través de autenticación y cifrado.', 'Ideal para controlar acceso lógico y evitar fuga de datos en tránsito.', 'Compatible con LDAP, Fail2ban'),

('DSS06-P06-A02', 'DSS06-P06', 'Proporcionar concientización y capacitación sobre el uso aceptable.', 2, 'GLPI', 'Permite crear y distribuir campañas internas de concientización a través de su base de conocimientos y notificaciones internas.', 'Puede ser complementado con campañas de e-learning externas.', 'Plugin: News, Notificaciones personalizadas'),

('DSS06-P06-A03', 'DSS06-P06', 'Aplicar políticas y procedimientos de clasificación de datos, uso aceptable y seguridad para proteger los activos de información bajo el control del negocio.', 3, 'Eramba', 'Herramienta de GRC orientada a la implementación y seguimiento de políticas, controles y clasificaciones de datos.', 'Soporta auditoría y cumplimiento automatizado.', 'Nativa, no requiere integración adicional'),

('DSS06-P06-A04', 'DSS06-P06', 'Identificar e implementar procesos, herramientas y técnicas para verificar razonablemente el cumplimiento.', 3, 'Eramba', 'Permite definir métricas, indicadores y revisiones para asegurar el cumplimiento de políticas.', 'Específicamente diseñada para entornos regulados.', 'Puede integrarse con LDAP o AD para validación de usuarios'),

('DSS06-P06-A05', 'DSS06-P06', 'Informar a la empresa y otras partes interesadas sobre las infracciones y desviaciones.', 4, 'GLPI', 'A través de la gestión de incidentes, permite notificar automáticamente al personal asignado y generar reportes sobre desviaciones o brechas.', 'Se puede automatizar vía reglas y flujos.', 'Plugin: Reports, Notificaciones, Escalation'),

('BAI01-P01-A01', 'BAI01-P01', 'Mantener y aplicar un enfoque estándar para la gestión de programas, alineado con el entorno específico de la empresa y con buenas prácticas basadas en procesos definidos y el uso de tecnología apropiada. Garantizar que el enfoque cubra todo el ciclo de vida y las disciplinas a seguir, incluyendo la gestión del alcance, los recursos, el riesgo, los costos, la calidad, el tiempo, la comunicación, la participación de las partes interesadas, las adquisiciones, el control de cambios, la integración y la obtención de beneficios.', 2, 'GLPI', 'Puede gestionar proyectos, tareas, recursos y documentar procesos.', 'No cubre todas las disciplinas (ej. adquisiciones, calidad).', 'Projects'),

('BAI01-P01-A02', 'BAI01-P01', 'Implementar una oficina de programas u oficina de gestión de proyectos (PMO) que mantenga el enfoque estándar para la gestión de programas y proyectos en toda la organización. La PMO apoya todos los programas y proyectos mediante la creación y el mantenimiento de las plantillas de documentación de proyectos requeridas, la capacitación y las mejores prácticas para los gerentes de programas/proyectos, el seguimiento de métricas sobre el uso de las mejores prácticas para la gestión de proyectos, etc. En algunos casos, la PMO también puede informar sobre el progreso del programa/proyecto a la alta dirección o a las partes interesadas, ayudar a priorizar los proyectos y garantizar que todos los proyectos respalden los objetivos generales de negocio de la empresa.', 3, 'GLPI', 'Puede usarse como base para una PMO sencilla con seguimiento de plantillas y métricas.', 'Limitado a operaciones TI, no tiene PMO formal.', 'Generic Object Management'),

('BAI01-P01-A03', 'BAI01-P01', 'Evaluar las lecciones aprendidas con base en el uso del enfoque de gestión de programas y actualizar el enfoque en consecuencia.', 4, 'GLPI', 'Se pueden documentar proyectos anteriores y adaptar procesos.', 'Muy flexible para generar y almacenar conocimiento.', '-'),

('BAI01-P02-A01', 'BAI01-P02', 'Acordar el patrocinio del programa. Designar una junta/comité del programa con miembros que tengan un interés estratégico en el programa, sean responsables de la toma de decisiones de inversión, se vean significativamente afectados por el programa y sean necesarios para facilitar la implementación del cambio.', 2, 'GLPI', 'uede definir roles y documentación de comité vía objetos y seguimiento.', 'No estructura oficialmente comités, pero puede documentars', 'Generic Object Management'),

('BAI01-P02-A02', 'BAI01-P02', 'Designar un gerente dedicado al programa, con las competencias y habilidades necesarias para gestionar el programa de manera eficaz y eficiente.', 2, 'GLPI', 'Permite asignar responsables de proyectos o programas.', 'No valida competencias ni tiene estructura de RRHH.', '-'),

('BAI01-P02-A03', 'BAI01-P02', 'Confirmar el mandato del programa con los patrocinadores y las partes interesadas. Definir los objetivos estratégicos del programa, las posibles estrategias de ejecución, las mejoras y los beneficios esperados, y cómo se integra el programa con otras iniciativas.', 3, 'GLPI', 'Se puede documentar mandato, objetivos y alineación de programas.', 'Muy útil si se combina con políticas organizacionales.', '-'),

('BAI01-P02-A04', 'BAI01-P02', 'Desarrollar un análisis de negocio detallado para un programa. Involucrar a todas las partes interesadas clave para desarrollar y documentar una comprensión completa de los resultados empresariales esperados, cómo se medirán, el alcance total de las iniciativas requeridas, el riesgo involucrado y el impacto en todos los aspectos de la empresa. Identificar y evaluar alternativas de acción para lograr los resultados empresariales deseados.', 3, NULL, 'GLPI puede registrar alcance, tareas, plazos y riesgos.', 'No incluye modelos financieros complejos.', '-'),

('BAI01-P02-A05', 'BAI01-P02', 'Desarrollar un plan de realización de beneficios que se gestionará a lo largo del programa para garantizar que los beneficios planificados siempre tengan propietarios y se logren, se mantengan y se optimicen.', 3, NULL, 'Apache Open tiene  una Herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('BAI01-P02-A06', 'BAI01-P02', 'Preparar el caso de negocio del programa inicial (conceptual), proporcionando información esencial para la toma de decisiones respecto al propósito, la contribución a los objetivos del negocio, el valor esperado creado, los plazos, etc. Presentarlo para su aprobación.', 3, 'GLPI', 'Puede documentarse un caso de negocio básico.', 'Debe complementarse con presentación o aprobación externa.', '-'),

('BAI01-P03-A01', 'BAI01-P03', 'Planificar cómo se identificarán, analizarán, involucrarán y gestionarán las partes interesadas dentro y fuera de la empresa a lo largo del ciclo de vida de los proyectos.', 3, 'GLPI', 'Puede registrar interesados y planificar su involucramiento mediante tareas.', 'Limitado al uso organizativo interno.', 'Generic Object Management'),

('BAI01-P03-A02', 'BAI01-P03', 'Identificar, involucrar y gestionar a las partes interesadas estableciendo y manteniendo niveles adecuados de coordinación, comunicación y enlace para garantizar que participen en el programa.', 3, 'GLPI', 'Se pueden asignar interesados como observadores o responsables.', 'No incluye herramientas de comunicación activa.', '-'),

('BAI01-P03-A03', 'BAI01-P03', 'Analizar los intereses y requisitos de las partes interesadas.', 3, 'GLPI', 'Información de interesados puede ser extendida con campos personalizados.', 'Permite registrar roles, intereses, notificaciones.', '-'),

('BAI01-P03-A04', 'BAI01-P03', 'Seguir un proceso definido para acuerdos de colaboración con respecto a los datos compartidos y el uso de datos dentro de los procesos de negocio.', 4, 'GLPI', 'Documentos pueden contener acuerdos básicos o plantillas compartidas.', 'No es sistema jurídico, pero funcional como soporte.', '-'),

('BAI01-P04-A01', 'BAI01-P04', 'Especificar el financiamiento, el costo, el cronograma y las interdependencias de múltiples proyectos.', 2, 'GLPI', 'Permite asignar costos por proyectos y tareas con tiempos y responsables.', 'No tiene análisis de interdependencias entre múltiples proyectos.', 'Plugin Projects'),

('BAI01-P04-A02', 'BAI01-P04', 'Definir y documentar el plan del programa que abarca todos los proyectos. Incluir lo necesario para implementar cambios en la empresa: su propósito, misión, visión, valores, cultura, productos y servicios; procesos de negocio; habilidades interpersonales y número de empleados; relaciones con las partes interesadas, clientes, proveedores y otros; necesidades tecnológicas; y la reestructuración organizacional necesaria para lograr los resultados empresariales previstos del programa.', 3, 'GLPI', 'Puede registrar visión, estrategia y elementos organizacionales en documentos.', 'Falta soporte formal para estructuración estratégica.', '-'),

('BAI01-P04-A03', 'BAI01-P04', 'Asegurar una comunicación eficaz de los planes del programa y los informes de progreso entre todos los proyectos y con el programa general. Asegurar que cualquier cambio realizado en los planes individuales se refleje en los demás planes del programa de la empresa.', 3, 'GLPI', 'Permite adjuntar informes de avance y comentarios internos.', 'No hay integración automática entre planes.', '-'),

('BAI01-P04-A04', 'BAI01-P04', 'Mantener el plan del programa actualizado y alineado con los objetivos estratégicos actuales, el progreso real y los cambios sustanciales en los resultados, beneficios, costos y riesgos. Que la empresa impulse los objetivos y priorice el trabajo a lo largo del proceso para garantizar que el programa, tal como está diseñado, cumpla con los requisitos de la empresa. Revisar el progreso de cada proyecto y ajustarlos según sea necesario para cumplir con los hitos y lanzamientos programados.', 3, 'GLPI', 'Puede documentarse progreso y vincular tareas con objetivos.', 'Actualización de estrategia debe realizarse manualmente.', '-'),

('BAI01-P04-A05', 'BAI01-P04', 'A lo largo de la vida económica del programa, actualizar y mantener el análisis de negocios y un registro de beneficios para identificar y definir los beneficios clave que surgen de la ejecución del programa.', 3, 'Open Source Risk Engine', 'Puede modelar beneficios económicos si se parametrizan.', 'Solo aplicable si se integra con modelo de negocio.', '-'),

('BAI01-P04-A06', 'BAI01-P04', 'Preparar un presupuesto del programa que refleje los costos completos del ciclo de vida económico y los beneficios financieros y no financieros asociados.', 3, 'Open Source Risk Engine', 'Capaz de calcular presupuesto de ciclo económico.', 'Sin visualización operativa de proyectos.', '-'),

('BAI01-P05-A01', 'BAI01-P05', 'Planificar, asignar recursos y poner en marcha los proyectos necesarios para lograr los resultados del programa, basándose en la revisión de la financiación y las aprobaciones en cada etapa de la revisión.', 3, 'GLPI', 'Puede asignar responsables, definir tareas y registrar costos.', 'No contiene control financiero detallado.', 'Projects'),

('BAI01-P05-A02', 'BAI01-P05', 'Gestionar cada programa o proyecto para garantizar que la toma de decisiones y las actividades de entrega se centren en el valor mediante el logro de beneficios para el negocio y los objetivos de manera consistente, abordando el riesgo y logrando los requisitos de las partes interesadas.', 3, 'GLPI', 'Permite hacer seguimiento de tareas y resultados, pero no gestiona beneficios.', 'Falta alineación con métricas de valor o beneficios estratégicos.', '-'),

('BAI01-P05-A03', 'BAI01-P05', 'Establecer las etapas acordadas del proceso de desarrollo (puntos de control de desarrollo). Al final de cada etapa, facilitar debates formales sobre los criterios aprobados con las partes interesadas. Tras completar satisfactoriamente las revisiones de funcionalidad, rendimiento y calidad, y antes de finalizar las actividades de la etapa, obtener la aprobación formal de todas las partes interesadas y del patrocinador/responsable del proceso de negocio.', 3, 'GLPI', 'Puede crear tareas de revisión y seguimiento entre etapas.', 'Revisión formal debe organizarse externamente.', '-'),

('BAI01-P05-A04', 'BAI01-P05', 'Implementar un proceso de materialización de beneficios a lo largo del programa para garantizar que los beneficios planificados siempre tengan responsables y que sea probable que se alcancen, se mantengan y se optimicen. Supervisar la entrega de beneficios e informar sobre los objetivos de rendimiento en las revisiones de iteración y lanzamiento. Realizar análisis de causa raíz para detectar desviaciones del plan e identificar y abordar las medidas correctivas necesarias.', 4, 'Open Source Risk Engine', 'Puede analizar desvíos financieros, pero no seguimiento organizacional.', 'Requiere complemento externo para gestión integral.', '-'),

('BAI01-P05-A05', 'BAI01-P05', 'Planificar auditorías, revisiones de calidad, revisiones de fases/etapas y revisiones de los beneficios obtenidos.', 4, 'GLPI', 'Soporta planificación de auditorías internas y controles de calidad.', 'No permite informes detallados por iteración.', '-'),

('BAI01-P06-A01', 'BAI01-P06', 'Actualizar las carteras operativas de I&T para reflejar los cambios que resulten del programa en las carteras de servicios, activos o recursos de I&T pertinentes.', 3, 'GLPI', 'Permite documentar servicios, activos e intervenciones sobre I&T.', 'No estructura carteras, pero puede dar seguimiento básico.', '-'),

('BAI01-P06-A02', 'BAI01-P06', 'Supervisar y controlar el rendimiento del programa general y de los proyectos dentro del programa, incluyendo las contribuciones del área de negocio y de TI a los proyectos. Informar de forma oportuna, completa y precisa. Los informes pueden incluir el cronograma, la financiación, la funcionalidad, la satisfacción del usuario, los controles internos y la aceptación de responsabilidades.', 4, 'GLPI', 'Permite control de tareas y registrar avance con informes.', 'No refleja beneficios ni calidad del entregable.', 'Projects'),

('BAI01-P06-A03', 'BAI01-P06', 'Supervisar y controlar el desempeño en relación con las estrategias y objetivos empresariales y de I&T. Informar a la gerencia sobre los cambios empresariales implementados, los beneficios obtenidos según el plan de realización de beneficios y la idoneidad del proceso de realización de beneficios.', 4, 'Open Source Risk Engine', 'Puede vincular escenarios financieros a indicadores estratégicos.', 'Requiere integración para verificación de resultados reales.', '-'),

('BAI01-P06-A04', 'BAI01-P06', 'Supervisar y controlar los servicios, activos y recursos de TI creados o modificados como resultado del programa. Anotar las fechas de implementación y puesta en servicio. Informar a la gerencia sobre los niveles de rendimiento, la prestación sostenida del servicio y la contribución al valor.', 4, 'GLPI', 'Puede anotar cambios en activos, fechas y responsables.', 'No mide contribución al valor ni sostenibilidad del servicio.', '-'),

('BAI01-P06-A05', 'BAI01-P06', 'Gestionar el desempeño del programa frente a criterios clave (por ejemplo, alcance, cronograma, calidad, obtención de beneficios, costos, riesgo, velocidad), identificar desviaciones del plan y tomar medidas correctivas oportunas cuando sea necesario.', 4, 'GLPI', 'Se puede controlar cronograma y asignación de tareas.', 'No gestiona indicadores financieros ni medición de beneficios.', '-'),

('BAI01-P06-A06', 'BAI01-P06', 'Supervisar el desempeño de cada proyecto en relación con la entrega de las capacidades previstas, el cronograma, la obtención de beneficios, los costos, los riesgos u otras métricas. Identificar los posibles impactos en el desempeño del programa y tomar las medidas correctivas oportunas cuando sea necesario.', 4, 'GLPI', 'Permite revisar tareas con responsables y fechas.', 'No conecta métricas de riesgo ni beneficio.', '-'),

('BAI01-P06-A07', 'BAI01-P06', 'De acuerdo con los criterios de revisión de etapa, lanzamiento o iteración, realizar revisiones para informar sobre el progreso del programa para que la gerencia pueda tomar decisiones de continuar/no continuar o de ajustes y aprobar financiamiento adicional hasta la siguiente etapa, lanzamiento o iteración.', 4, 'GLPI', 'Se pueden programar tareas por fases, pero sin control formal de iteraciones.', 'No permite aprobar o rechazar etapas desde la gerencia.', '-'),

('BAI01-P07-A01', 'BAI01-P07', 'Identificar las tareas y prácticas de aseguramiento necesarias para respaldar la acreditación de sistemas nuevos o modificados durante la planificación del programa e incluirlas en los planes integrados. Asegurar que las tareas garanticen que los controles internos y las soluciones de seguridad y privacidad cumplan con los requisitos definidos.', 3, 'GLPI', 'Permite registrar tareas de aseguramiento y relacionarlas a tickets o cambios.', 'No vincula directamente con modelos de acreditación ni seguridad formal.', '-'),

('BAI01-P07-A02', 'BAI01-P07', 'Proporcionar garantía de calidad para los entregables del programa, identificar la propiedad y las responsabilidades, los procesos de revisión de calidad, los criterios de éxito y las métricas de desempeño.', 3, 'GLPI', 'Se pueden crear responsables de tareas y registrar cumplimiento, pero no genera métricas automatizadas.', 'Falta trazabilidad formal de calidad sobre entregables estratégicos.', 'Projects'),

('BAI01-P07-A03', 'BAI01-P07', 'Definir cualquier requisito para la validación y verificación independiente de la calidad de los entregables del plan.', 4, NULL, 'Apache open Herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('BAI01-P07-A04', 'BAI01-P07', 'Realizar actividades de aseguramiento y control de calidad de acuerdo con el plan de gestión de calidad y el SGC.', 4, 'GLPI', 'Puede documentar actividades de control, pero no las ejecuta automáticamente.', 'No alineado con un SGC completo (Sistema de Gestión de Calidad).', '-'),

('BAI01-P08-A01', 'BAI01-P08', 'Establecer un enfoque formal de gestión de riesgos alineado con el marco de gestión de riesgos empresariales (ERM). Asegurarse de que el enfoque incluya la identificación, el análisis, la respuesta, la mitigación, la supervisión y el control de los riesgos.', 3, 'Eramba', 'Eramba está diseñado como una solución de gestión de riesgos y cumplimiento.', 'Alinea con marcos ERM (como ISO 31000) de forma estructurada.', '-'),

('BAI01-P08-A02', 'BAI01-P08', 'Asignar a personal debidamente capacitado la responsabilidad de ejecutar el proceso de gestión de riesgos de la empresa dentro de un programa y garantizar que se incorpore en las prácticas de desarrollo de soluciones. Considere asignar esta función a un equipo independiente, especialmente si se requiere una perspectiva objetiva o si un programa se considera crítico.', 3, 'Eramba', 'Permite asignar responsables de riesgos y roles diferenciados.', 'Se pueden separar funciones operativas de análisis objetivo.', '-'),

('BAI01-P08-A03', 'BAI01-P08', 'Realizar la evaluación de riesgos para identificar y cuantificar los riesgos continuamente durante todo el programa. Gestionar y comunicar adecuadamente los riesgos dentro de la estructura de gobernanza del programa.', 3, 'Eramba', 'Realiza evaluaciones continuas, cuantitativas y cualitativas.', 'Genera alertas, reportes y trazabilidad de mitigación.', '-'),

('BAI01-P08-A04', 'BAI01-P08', 'Identificar a los responsables de las acciones para evitar, aceptar o mitigar el riesgo.', 3, 'Eramba', 'Asigna responsables por acción: aceptación, mitigación o transferencia.', 'Compatible con seguimiento y auditoría posterior.', '-'),

('BAI01-P09-A01', 'BAI01-P09', 'Llevar el programa a un cierre ordenado, incluyendo la aprobación formal, la disolución de la organización del programa y la función de apoyo, la validación de los entregables y la comunicación del retiro.', 3, 'GLPI', 'Permite cerrar proyectos y tareas, pero no gestiona formalmente la disolución de estructuras de programa.', 'Puede cerrar elementos técnicos, pero no es un gestor de ciclo de vida de programas.', '-'),

('BAI01-P09-A02', 'BAI01-P09', 'Revisar y documentar las lecciones aprendidas. Una vez retirado el programa, retirarlo de la cartera de inversión activa. Trasladar las capacidades resultantes a una cartera de activos operativos para garantizar que se siga creando y manteniendo valor.', 4, 'GLPI', 'pueden documentar notas y lecciones aprendidas; permite desactivar recursos y equipos.', 'No hay función de transferencia estructurada a activos operativos.', 'Projects'),

('BAI01-P09-A03', 'BAI01-P09', 'Implementar la rendición de cuentas y los procesos necesarios para garantizar que la empresa siga optimizando el valor del servicio, activo o recursos. Es posible que se requieran inversiones adicionales en el futuro para garantizar que esto ocurra.', 5, 'Zabbix', 'Puede seguir el desempeño técnico de activos heredados del programa.', 'No gestiona procesos de negocio ni asignación de valor.', '-'),

('BAI02-P01-A01', 'BAI02-P01', 'Garantizar que todos los requisitos de las partes interesadas, incluidos los criterios de aceptación pertinentes, se consideren, capturen, prioricen y registren de una manera que sea comprensible para todas las partes interesadas, reconociendo que los requisitos pueden cambiar y se volverán más detallados a medida que se implementen.', 2, 'GLPI', 'Se puede capturar solicitudes mediante tickets o tareas.', 'Falta estructura formal de requisitos.', '-'),

('BAI02-P01-A02', 'BAI02-P01', 'Expresar los requisitos del negocio en términos de cómo debe abordarse la brecha entre las capacidades comerciales actuales y deseadas y cómo el usuario (empleado, cliente, etc.) interactuará con la solución y la utilizará.', 2, NULL, 'La herramienta Apache Open, herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('BAI02-P01-A03', 'BAI02-P01', 'Especificar y priorizar la información, los requisitos funcionales y técnicos, con base en el diseño de la experiencia del usuario y los requisitos confirmados de las partes interesadas.', 2, 'GLPI', 'Permite asociar información funcional y técnica en proyectos.', 'No tiene enfoque completo en diseño técnico.', '-'),

('BAI02-P01-A04', 'BAI02-P01', 'Garantizar que los requisitos cumplan con las políticas y estándares empresariales, la arquitectura empresarial, los planes estratégicos y tácticos de I&T, los procesos comerciales y de TI internos y subcontratados, los requisitos de seguridad, los requisitos reglamentarios, las competencias de las personas, la estructura organizacional, el caso de negocios y la tecnología habilitadora.', 3, 'Eramba', 'Permite evaluar cumplimiento con estándares y arquitectura.', 'Muy útil en entornos regulados.', '-'),

('BAI02-P01-A05', 'BAI02-P01', 'Incluir requisitos de control de información en los procesos de negocio, procesos automatizados y entornos de I&T para abordar el riesgo de la información y cumplir con las leyes, regulaciones y contratos comerciales.', 3, 'Eramba', 'Controla riesgos de información y cumplimiento.', 'Se alinea con normativas de privacidad y protección.', '-'),

('BAI02-P01-A06', 'BAI02-P01', 'Confirmar la aceptación de los aspectos clave de los requisitos, incluidas las reglas empresariales, la experiencia del usuario, los controles de información, la continuidad del negocio, el cumplimiento legal y normativo, la auditabilidad, la ergonomía, la operabilidad y usabilidad, la seguridad, la confidencialidad y la documentación de respaldo.', 3, 'GLPI', 'Documentación posible por tareas, pero no validación formal.', 'No incluye aspectos como auditabilidad o ergonomía.', '-'),

('BAI02-P01-A07', 'BAI02-P01', 'Realizar un seguimiento y controlar el alcance, los requisitos y los cambios a lo largo del ciclo de vida de la solución a medida que evoluciona la comprensión de la solución.', 3, 'GLPI', 'Se puede rastrear cambios por historial y tareas.', 'Sin funcionalidades avanzadas de trazabilidad.', '-'),

('BAI02-P01-A08', 'BAI02-P01', 'Definir e implementar un procedimiento de definición y mantenimiento de requisitos y un repositorio de requisitos que sean apropiados para el tamaño, la complejidad, los objetivos y el riesgo de la iniciativa que la empresa está considerando emprender.', 3, 'GLPI', 'Tiene repositorio básico de requerimientos por proyecto.', 'Funcional para iniciativas pequeñas.', '-'),

('BAI02-P01-A09', 'BAI02-P01', 'Validar todos los requisitos mediante enfoques como la revisión por pares, la validación de modelos o la creación de prototipos operativos.', 3, NULL, 'La herramienta Apache Open, herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('BAI02-P02-A01', 'BAI02-P02', 'Identifique las acciones necesarias para la adquisición o el desarrollo de la solución según la arquitectura empresarial. Tenga en cuenta las limitaciones de alcance, tiempo y presupuesto.', 2, 'GLPI', 'Permite organizar recursos, tiempos y presupuesto en iniciativas técnicas.', 'Adecuado para planificar acciones operativas.', '-'),

('BAI02-P02-A02', 'BAI02-P02', 'Analice las soluciones alternativas con todas las partes interesadas. Seleccione la más adecuada según los criterios de viabilidad, incluyendo el riesgo y el costo.', 2, 'GLPI', 'Se puede coordinar con usuarios e interesados, pero sin análisis estructurado.', 'Puede usarse para recolectar opiniones, no para evaluar costo/viabilidad.', '-'),

('BAI02-P02-A03', 'BAI02-P02', 'Traducir el curso de acción preferido en un plan de adquisición y desarrollo de alto nivel que identifique los recursos que se utilizarán y las etapas que requieren una decisión de seguir adelante o no.', 3, 'GLPI', 'Documenta etapas del proyecto, responsables y recursos.', 'Útil para seguimiento y control, aunque limitado en detalle estratégico.', '-'),

('BAI02-P02-A04', 'BAI02-P02', 'Definir y ejecutar un estudio de viabilidad, una prueba piloto o una solución básica de trabajo que describa de forma clara y concisa las alternativas y mida cómo estas satisfarían los requisitos empresariales y funcionales. Incluir una evaluación de su viabilidad tecnológica y económica.', 4, 'Open Source Risk Engine', 'Puede simular escenarios y rendimientos de opciones.', 'Útil como apoyo técnico para evaluación de viabilidad.', '-'),

('BAI02-P03-A01', 'BAI02-P03', 'Identificar los riesgos de calidad, funcionales y técnicos (debido, por ejemplo, a la falta de participación del usuario, expectativas poco realistas, desarrolladores que agregan funcionalidad innecesaria, suposiciones poco realistas, etc.).', 3, 'Eramba', 'Eramba permite identificar riesgos técnicos y de calidad asociados a controles, requisitos regulatorios o faltas de participación.', 'Aunque no fue diseñada para requisitos de software, se adapta bien a riesgos de tipo organizacional y de cumplimiento.', '-'),

('BAI02-P03-A02', 'BAI02-P03', 'Determinar la respuesta de riesgo apropiada al riesgo de los requisitos.', 3, 'Eramba', 'La herramienta permite definir acciones correctivas y tratamientos para cada riesgo.', 'Su enfoque formal permite respuestas de mitigación y asignación de responsables', '-'),

('BAI02-P03-A03', 'BAI02-P03', 'Analice el riesgo identificado estimando su probabilidad e impacto en el presupuesto y el cronograma. Evalúe el impacto presupuestario de las medidas adecuadas de respuesta al riesgo.', 4, 'Eramba', 'Incluye evaluaciones de probabilidad, impacto y medidas de tratamiento con relación a procesos o requisitos.', 'Muy útil para trazabilidad de costos y plazos relacionados con riesgos.', '-'),

('BAI02-P04-A01', 'BAI02-P04', 'Asegúrese de que el patrocinador o el propietario del producto tome la decisión final sobre la solución, el enfoque de adquisición y el diseño general, según el caso de negocio. Obtenga las aprobaciones necesarias de las partes interesadas (p. ej., propietario del proceso de negocio, arquitecto empresarial, gerente de operaciones, responsable de seguridad y responsable de privacidad).', 3, 'Eramba', 'Permite definir responsables, criterios de aceptación, y aprobación de planes de control.', 'Adecuado en entornos de GRC, pero no diseñado específicamente para aprobación de requisitos técnicos.', '-'),

('BAI02-P04-A02', 'BAI02-P04', 'Obtener revisiones de calidad durante y al final de cada etapa clave del proyecto, iteración o lanzamiento. Evaluar los resultados según los criterios de aceptación originales. Solicitar la aprobación de los patrocinadores empresariales y otras partes interesadas en cada revisión de calidad aprobada.', 4, 'Eramba', 'Soporta auditoría y revisión de cumplimiento, aplicable como control de calidad.', 'Puede apoyar revisiones de calidad, aunque no fue concebido para proyectos iterativos.', '-'),

('BAI03-P01-A01', 'BAI03-P01', 'Establecer una especificación de diseño de alto nivel que traduzca la solución propuesta en un diseño de alto nivel para procesos de negocio, servicios de soporte, flujos de trabajo, aplicaciones, infraestructura y repositorios de información capaces de cumplir con los requisitos de arquitectura empresarial y comercial.', 2, 'Eramba', 'Permite alinear requisitos y controles con procesos y arquitectura existente.', 'Puede contribuir desde el enfoque GRC, pero no diseña infraestructuras técnicas.', '-'),

('BAI03-P01-A02', 'BAI03-P01', 'Involucrar a diseñadores de experiencia de usuario y especialistas en TI debidamente calificados y con experiencia en el proceso de diseño para asegurarse de que el diseño proporcione una solución que utilice de manera óptima las capacidades de I&T propuestas para mejorar el proceso comercial.', 2, NULL, 'La herramienta Apache Open, herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('BAI03-P01-A03', 'BAI03-P01', 'Crear un diseño que cumpla con los estándares de diseño de la organización. Asegurarse de que mantenga un nivel de detalle adecuado a la solución y al método de desarrollo, y que sea coherente con las estrategias de negocio, empresariales y de I&T, la arquitectura empresarial, el plan de seguridad y privacidad, y las leyes, regulaciones y contratos aplicables.', 2, 'Eramba', 'Facilita cumplimiento con estándares y políticas, especialmente en privacidad y seguridad.', 'No crea diseños funcionales pero asegura alineación normativa.', '-'),

('BAI03-P01-A04', 'BAI03-P01', 'Tras la aprobación del control de calidad, presente el diseño final de alto nivel a las partes interesadas del proyecto y al patrocinador/responsable del proceso de negocio para su aprobación según los criterios acordados. Este diseño evolucionará a lo largo del proyecto a medida que se comprenda mejor el proceso.', 2, 'Eramba', 'Puede documentar decisiones de validación, no presenta visuales de diseño.', 'Aporta trazabilidad de decisiones estratégicas, pero no presenta artefactos técnicos.', '-'),

('BAI03-P02-A01', 'BAI03-P02', 'Diseñar progresivamente las actividades de los procesos de negocio y los flujos de trabajo que deben realizarse en conjunto con el nuevo sistema de aplicación para cumplir los objetivos de la empresa, incluido el diseño de las actividades de control manual.', 2, 'JFire', 'Modela flujos de negocio a través de su framework de procesos.', 'Muy útil para procesos personalizados.', '-'),

('BAI03-P02-A02', 'BAI03-P02', 'Diseñe los pasos de procesamiento de la aplicación. Estos pasos incluyen la especificación de los tipos de transacción y las reglas de procesamiento empresarial, los controles automatizados, las definiciones de datos/objetos de negocio, los casos de uso, las interfaces externas, las restricciones de diseño y otros requisitos (p. ej., licencias, requisitos legales, estándares e internacionalización/localización).', 2, 'JFire', 'Soporta reglas, objetos, interfaces y control de transacciones.', 'Se integra fácilmente con otros servicios', '-'),

('BAI03-P02-A03', 'BAI03-P02', 'Clasifique las entradas y salidas de datos según los estándares de arquitectura empresarial. Especifique el diseño de la recopilación de datos fuente. Documente las entradas de datos (independientemente de su origen) y la validación para el procesamiento de transacciones, así como los métodos de validación. Diseñe las salidas identificadas, incluyendo las fuentes de datos.', 2, 'JFire', 'Diseña formularios con validaciones incorporadas.', 'Útil en soluciones empresariales', '-'),

('BAI03-P02-A04', 'BAI03-P02', 'Diseñar la interfaz del sistema/solución, incluido cualquier intercambio automatizado de datos.', 2, 'JFire', 'Admite REST/SOAP para integración de sistemas.', 'Puede integrarse con APIs externas.', '-'),

('BAI03-P02-A05', 'BAI03-P02', 'Diseñar el almacenamiento, ubicación, recuperación y recuperabilidad de datos.', 2, 'JFire', 'Utiliza estructuras de persistencia con soporte de consultas.', 'Requiere conocimientos en Java persistente.', '-'),

('BAI03-P02-A06', 'BAI03-P02', 'Diseñe redundancia, recuperación y respaldo apropiados.', 2, 'JFire', 'Ofrece opciones de respaldo y recuperación.', 'Respaldo configurable.', '-'),

('BAI03-P02-A07', 'BAI03-P02', 'Diseñe la interfaz entre el usuario y la aplicación del sistema para que sea fácil de usar y autodocumentada.', 3, 'JFire', 'UI adaptable y extensible sobre Eclipse RCP.', 'Puede necesitar ajustes para UX moderno.', '-'),

('BAI03-P02-A08', 'BAI03-P02', 'Considere el impacto de la necesidad de la solución en el rendimiento de la infraestructura, siendo sensible a la cantidad de activos computacionales, la intensidad del ancho de banda y la sensibilidad temporal de la información.', 3, 'JFire', 'Monitorea consumo de recursos y adaptación del sistema.', 'Se recomienda monitoreo externo.', '-'),

('BAI03-P02-A09', 'BAI03-P02', 'Evaluar proactivamente las debilidades del diseño (p. ej., inconsistencias, falta de claridad, posibles fallos) a lo largo del ciclo de vida. Identificar mejoras cuando sea necesario.', 3, 'JFire', 'Herramientas para revisión y mejora continua.', 'Apto para pruebas continuas.', '-'),

('BAI03-P02-A10', 'BAI03-P02', 'Proporcionar la capacidad de auditar transacciones e identificar las causas fundamentales de los errores de procesamiento.', 3, 'JFire', 'Registro detallado de transacciones y cambios.', 'Facilita análisis de errores y cumplimiento.', '-'),

('BAI03-P03-A01', 'BAI03-P03', 'Dentro de un entorno separado, desarrollar el diseño detallado propuesto para los procesos de negocio, servicios de soporte, aplicaciones, infraestructura y repositorios de información.', 2, 'GLPI', 'Puede simular entornos separados usando gestión de activos virtuales.', 'Requiere configuración avanzada.', 'FusionInventory'),

('BAI03-P03-A02', 'BAI03-P03', 'Cuando proveedores externos participen en el desarrollo de la solución, asegúrese de que el mantenimiento, el soporte, los estándares de desarrollo y las licencias se aborden y se respeten en las obligaciones contractuales.', 2, 'GLPI', 'Registro de contratos, SLA, licencias y soporte de proveedores.', 'Muy útil para relaciones con terceros.', '-'),

('BAI03-P03-A03', 'BAI03-P03', 'Dar seguimiento a las solicitudes de cambio y a las revisiones de diseño, rendimiento y calidad. Garantizar la participación activa de todas las partes interesadas.', 2, 'GLPI', 'Sistema de tickets permite flujos de cambios y validación.', 'Participación configurable de stakeholders.', '-'),

('BAI03-P03-A04', 'BAI03-P03', 'Documentar todos los componentes de la solución según los estándares definidos. Mantener el control de versiones de todos los componentes desarrollados y la documentación asociada.', 2, 'GLPI', 'Documentación asociada a activos con versionado básico.', 'Puede enlazarse a soluciones específicas.', '-'),

('BAI03-P03-A05', 'BAI03-P03', 'Evaluar el impacto de la personalización y configuración de la solución en el rendimiento y la eficiencia de las soluciones adquiridas, así como en la interoperabilidad con las aplicaciones, sistemas operativos y demás infraestructura existentes. Adaptar los procesos de negocio según sea necesario para aprovechar al máximo la capacidad de la aplicación.', 3, 'GLPI', 'Plugins modifican comportamiento y rendimiento del sistema.', 'Depende de buena administración', 'Formcreator, Fields, DataInjection'),

('BAI03-P03-A06', 'BAI03-P03', 'Asegurar que quienes desarrollan e integran componentes de infraestructura de alta seguridad o acceso restringido tengan claras y comprendidas las responsabilidades sobre el uso de estos componentes. Su uso debe ser monitoreado y evaluado.', 3, 'GLPI', 'Maneja perfiles, ACLs, logs de auditoría.', 'Requiere configuración detallada.', '-'),

('BAI03-P04-A01', 'BAI03-P04', 'Crear y mantener un plan para la adquisición de componentes de la solución. Considerar la flexibilidad futura para la ampliación de capacidad, los costos de transición, el riesgo y las actualizaciones durante la vida útil del proyecto.', 3, 'GLPI', 'Permite solicitudes, planificación y seguimiento de compras.', 'Extensible con plugin para ciclo completo.', 'Order Management'),

('BAI03-P04-A02', 'BAI03-P04', 'Revisar y aprobar todos los planes de adquisición. Considerar los riesgos, costos, beneficios y la conformidad técnica con los estándares de arquitectura empresarial.', 3, 'GLPI', 'Validación de flujos y decisiones documentadas.', 'Aprobadores pueden visualizar planes.', '-'),

('BAI03-P04-A03', 'BAI03-P04', 'Evaluar y documentar el grado en que las soluciones adquiridas requieren la adaptación del proceso de negocio para aprovechar los beneficios de la solución adquirida.', 3, 'GLPI', 'Documentación de cambios relacionados con nuevas adquisiciones.', 'Relación con activos y base de conocimientos.', '-'),

('BAI03-P04-A04', 'BAI03-P04', 'Seguir las aprobaciones requeridas en los puntos de decisión clave durante los procesos de adquisición.', 3, 'GLPI', 'Puntos de control en cada fase del proceso.', 'Controlado paso a paso.', '-'),

('BAI03-P04-A05', 'BAI03-P04', 'Registrar la recepción de todas las adquisiciones de infraestructura y software en un inventario de activos.', 3, 'GLPI', 'Registro detallado de hardware, software y licencias.', '-', '-'),

('BAI03-P05-A01', 'BAI03-P05', 'Integrar y configurar los componentes de las soluciones empresariales y de TI, así como los repositorios de información, de acuerdo con las especificaciones detalladas y los requisitos de calidad. Considerar el rol de los usuarios, las partes interesadas del negocio y el responsable del proceso en la configuración de los procesos de negocio.', 2, 'GLPI', 'GLPI permite registrar e interconectar activos, configurar servicios y ajustar parámetros técnicos en función de las necesidades de TI. Aunque no realiza integraciones profundas como un ERP, permite simular configuraciones de infraestructura.', 'No es una plataforma de desarrollo, pero se adapta bien a la gestión de componentes físicos y lógicos.', '-'),

('BAI03-P05-A02', 'BAI03-P05', 'Completar y actualizar los manuales de procesos de negocio y operativos, cuando sea necesario, para tener en cuenta cualquier personalización o condiciones especiales propias de la implementación.', 2, 'GLPI', 'La base de conocimientos permite documentar procedimientos operativos, condiciones especiales, soluciones personalizadas e instrucciones por tipo de activo o servicio.', 'Puede ser actualizada por técnicos o responsables de procesos.', '-'),

('BAI03-P05-A03', 'BAI03-P05', 'Considere todos los requisitos de control de información relevantes para la integración y configuración de los componentes de la solución. Incluya la implementación de controles de negocio, cuando corresponda, en los controles automatizados de la aplicación, de modo que el procesamiento sea preciso, completo, oportuno, autorizado y auditable.', 2, 'GLPI', 'permite configurar controles administrativos mediante perfiles, políticas de acceso, reglas de aprobación y flujo de trabajo. Si bien no son controles de negocio automatizados al nivel de una aplicación financiera, aseguran integridad operativa.', 'Ideal para asegurar flujo de trabajo en soporte TI.', '-'),

('BAI03-P05-A04', 'BAI03-P05', 'Implementar registros de auditoría durante la configuración e integración de hardware y software de infraestructura para proteger los recursos y garantizar la disponibilidad y la integridad.', 3, 'GLPI', 'registra todas las acciones realizadas por usuarios, cambios en configuración y operaciones sobre activos. Esto incluye logs detallados y trazabilidad completa.', 'Compatible con requisitos de trazabilidad y control de cambios.', '-'),

('BAI03-P05-A05', 'BAI03-P05', 'Considere cuándo el efecto de las personalizaciones y configuraciones acumulativas (incluidos cambios menores que no estuvieron sujetos a especificaciones de diseño formales) requiere una reevaluación de alto nivel de la solución y la funcionalidad asociada.', 3, 'GLPI', 'Los cambios y personalizaciones se reflejan en el historial de cada entidad (activo, ticket, solicitud), lo que permite detectar acumulación de cambios no planificados.', 'Reevaluación depende de gestión activa del administrador.', '-'),

('BAI03-P05-A06', 'BAI03-P05', 'Configurar el software de aplicación adquirido para satisfacer los requisitos de procesamiento comercial.', 3, 'GLPI', 'Se pueden instalar, configurar y documentar aplicaciones adquiridas dentro del inventario y asociarlas a usuarios o servicios. Adicionalmente, se pueden gestionar accesos, actualizaciones y relaciones con tickets.', 'Configuración operativa y trazabilidad total.', '-'),

('BAI03-P05-A07', 'BAI03-P05', 'Definir catálogos de productos y servicios para grupos objetivos internos y externos relevantes, en función de los requisitos del negocio.', 3, 'GLPI', 'permite crear un catálogo de servicios orientado al usuario interno (TI, soporte, solicitudes), incluyendo descripciones, condiciones y flujos asociados.', 'El catálogo puede ser extendido con módulos.', '-'),

('BAI03-P05-A08', 'BAI03-P05', 'Garantizar la interoperabilidad de los componentes de la solución con pruebas de apoyo, preferiblemente automatizadas.', 3, 'GLPI', 'GLPI no ejecuta pruebas automatizadas, permite documentar resultados, relacionar componentes entre sí y gestionar incidencias derivadas de pruebas de integración.', 'No prueba, pero soporta la trazabilidad técnica necesaria', '-'),

('BAI03-P06-A01', 'BAI03-P06', 'Definir un plan de control de calidad y prácticas que incluyan, por ejemplo, la especificación de los criterios de calidad, los procesos de validación y verificación, la definición de cómo se revisará la calidad, las calificaciones necesarias de los revisores de calidad y los roles y responsabilidades para el logro de la calidad.', 3, 'GLPI', 'Permite registrar planes de QA como documentación asociada a tickets, proyectos o la base de conocimientos. Se pueden definir roles y criterios en formularios personalizados.', 'Control orientado a procesos TI.', '-'),

('BAI03-P06-A02', 'BAI03-P06', 'Supervisar frecuentemente la calidad de la solución en función de los requisitos del proyecto, las políticas empresariales, la adherencia a las metodologías de desarrollo, los procedimientos de gestión de calidad y los criterios de aceptación.', 4, 'GLPI', 'Configura SLAs, flujos de validación, y condiciones específicas por tipo de solicitud. Permite verificar adherencia a políticas internas y medir contra objetivos.', 'Cumple requisitos operativos de control.', '-'),

('BAI03-P06-A03', 'BAI03-P06', 'Implementar, según corresponda, la inspección de código, prácticas de desarrollo basadas en pruebas, pruebas automatizadas, integración continua, tutoriales y pruebas de aplicaciones. Informar sobre los resultados del proceso de monitoreo y las pruebas al equipo de desarrollo de software de la aplicación y a la gerencia de TI.', 4, 'JFire', 'Es compatible con prácticas como pruebas automatizadas, integración continua y revisión de código si se despliega en entornos Java empresariales con herramientas como Jenkins, SonarQube, etc.', 'Necesita integraciones externas.', 'Jenkins, JUnit, SonarQube'),

('BAI03-P06-A04', 'BAI03-P06', 'Supervisar todas las excepciones de calidad y abordar todas las acciones correctivas. Mantener un registro de todas las revisiones, resultados, excepciones y correcciones. Repetir las revisiones de calidad, cuando corresponda, según la cantidad de retrabajo y las acciones correctivas.', 4, 'GLPI', 'Puede documentar fallas, correcciones, resultados y revisiones mediante su sistema de tickets y problemas. Todo queda auditado.', 'Alta trazabilidad operativa.', '-'),

('BAI03-P07-A01', 'BAI03-P07', 'Crear un plan de pruebas integrado y prácticas acordes con el entorno empresarial y los planes tecnológicos estratégicos. Asegurarse de que el plan de pruebas integrado y las prácticas permitan la creación de entornos de prueba y simulación adecuados para verificar que la solución funcionará correctamente en el entorno real, ofrecerá los resultados previstos y que los controles sean adecuados.', 2, 'GLPI', 'permite documentar planes de prueba como parte de la gestión de proyectos, relacionarlos con tickets, activos y procedimientos definidos por el equipo TI. Se pueden definir responsables, roles, criterios y flujos de aprobación.', 'Aunque no ejecuta pruebas, permite planearlas y gestionarlas documentalmente', '-'),

('BAI03-P07-A02', 'BAI03-P07', 'Cree un entorno de pruebas que respalde todo el alcance de la solución. Asegúrese de que el entorno de pruebas refleje, en la medida de lo posible, las condiciones reales, incluyendo los procesos y procedimientos de negocio, la gama de usuarios, los tipos de transacciones y las condiciones de implementación.', 2, 'JFire', 'puede simular entornos completos replicando lógica de negocio, usuarios, transacciones y comportamientos reales si se despliega con herramientas de testing Java.', 'Requiere integración con herramientas como JUnit, TestNG.', 'JUnit, Mockito, Arquillian'),

('BAI03-P07-A03', 'BAI03-P07', 'Crear procedimientos de prueba que se ajusten al plan y las prácticas, y que permitan evaluar el funcionamiento de la solución en condiciones reales. Asegurarse de que los procedimientos de prueba evalúen la idoneidad de los controles, basándose en estándares empresariales que definen roles, responsabilidades y criterios de prueba, y que estén aprobados por las partes interesadas del proyecto y el patrocinador/responsable del proceso de negocio.', 3, 'GLPI', 'Pueden definir flujos de revisión, pasos operativos, condiciones de éxito y validación desde tickets o formularios. Roles y criterios pueden asignarse manualmente.', 'La ejecución es externa; GLPI sirve como registro y verificación.', 'Formcreator'),

('BAI03-P07-A04', 'BAI03-P07', 'Documente y guarde los procedimientos de prueba, casos, controles y parámetros para futuras pruebas de la aplicación.', 3, 'GLPI', 'Todos los procedimientos, parámetros y evidencias pueden archivarse como documentos asociados o soluciones dentro de la base de conocimientos.', 'Permite trazabilidad futura de los procesos QA.', '-'),

('BAI03-P08-A01', 'BAI03-P08', 'Realizar pruebas de las soluciones y sus componentes de acuerdo con el plan de pruebas. Incluir probadores independientes del equipo de la solución, con representantes de los responsables de los procesos de negocio y usuarios finales. Asegurarse de que las pruebas se realicen únicamente en los entornos de desarrollo y prueba.', 2, 'JFire', 'JFIRE permite ejecutar pruebas dentro de entornos separados de desarrollo, integrando a usuarios clave mediante flujos configurables y roles definidos.', 'Soporta pruebas en ambientes controlados.', '-'),

('BAI03-P08-A02', 'BAI03-P08', 'Utilice instrucciones de prueba claramente definidas, tal como se definen en el plan de pruebas. Considere el equilibrio adecuado entre las pruebas automatizadas con script y las pruebas de usuario interactivas.', 2, 'JFire', 'Los planes de prueba pueden incorporar scripts automatizados y pruebas manuales. Compatible con frameworks de testing como JUnit o Selenium.', 'Requiere herramientas externas para pruebas formales.', 'JUnit, Selenium, TestNG'),

('BAI03-P08-A03', 'BAI03-P08', 'Realizar todas las pruebas de acuerdo con el plan y las prácticas de prueba. Incluir la integración de los procesos de negocio y los componentes de la solución de TI, así como de los requisitos no funcionales (p. ej., seguridad, privacidad, interoperabilidad y usabilidad).', 2, 'JFire', 'Permite validar reglas de negocio, procesos técnicos, interoperabilidad y requisitos no funcionales dentro del ciclo de desarrollo.', 'Muy útil para ambientes críticos y distribuidos.', '-'),

('BAI03-P08-A04', 'BAI03-P08', 'Identificar, registrar y clasificar errores (p. ej., menores, significativos y críticos) durante las pruebas. Repetir las pruebas hasta que se hayan resuelto todos los errores significativos. Asegurarse de mantener un registro de auditoría de los resultados de las pruebas.', 2, 'JFire', 'Los errores pueden documentarse, clasificarse y rastrearse; se permite reejecución hasta que el estado sea conforme. Toda actividad queda auditada.', 'Trazabilidad y control iterativo robusto.', '-'),

('BAI03-P08-A05', 'BAI03-P08', 'Registrar los resultados de las pruebas y comunicarlos a las partes interesadas de acuerdo con el plan de pruebas.', 2, 'JFire', 'Resultados de pruebas y logs pueden consolidarse, visualizarse y compartirse con los responsables técnicos y del negocio.', 'Integra visibilidad para toda la organización.', '-'),

('BAI03-P09-A01', 'BAI03-P09', 'Evalúe el impacto de todas las solicitudes de cambio de la solución en el desarrollo de la misma, el caso de negocio original y el presupuesto. Clasifíquelas y priorícelas según corresponda.', 3, 'GLPI', 'permite registrar solicitudes de cambio mediante tickets y categorizarlas. Con plugins adecuados, se pueden evaluar contra presupuestos y relacionarlas a proyectos o contratos.', 'Se puede extender con lógica de aprobación y clasificación', 'Changes'),

('BAI03-P09-A02', 'BAI03-P09', 'Realizar un seguimiento de los cambios en los requisitos, permitiendo que todas las partes interesadas los supervisen, revisen y aprueben. Garantizar que los resultados del proceso de cambio sean plenamente comprendidos y aceptados por todas las partes interesadas y el patrocinador/responsable del proceso de negocio.', 3, 'GLPI', 'Cada solicitud de cambio puede tener validadores asignados. Las notificaciones permiten a las partes interesadas revisar, comentar y aprobar.', 'La aceptación puede controlarse por estado o por usuarios claves.', '-'),

('BAI03-P09-A03', 'BAI03-P09', 'Aplicar las solicitudes de cambio, manteniendo la integridad de la integración y la configuración de los componentes de la solución. Evaluar el impacto de cualquier actualización importante de la solución y clasificarla según criterios objetivos acordados (como los requisitos de la empresa), basándose en el resultado del análisis de riesgos (como el impacto en los sistemas y procesos existentes o en la seguridad/privacidad), la justificación de la relación coste-beneficio y otros requisitos.', 3, 'GLPI', 'El historial de cambios permite registrar versiones anteriores, evaluar su impacto y documentar actualizaciones. También se pueden definir reglas de criticidad e impacto.', 'Puede requerir soporte administrativo para trazabilidad avanzada.', '-'),

('BAI03-P10-A01', 'BAI03-P10', 'Desarrollar y ejecutar un plan de mantenimiento para los componentes de la solución. Incluir revisiones periódicas según las necesidades del negocio y los requisitos operativos, como la gestión de parches, las estrategias de actualización, los riesgos, la privacidad, la evaluación de vulnerabilidades y los requisitos de seguridad.', 2, 'GLPI', 'permite definir planes de mantenimiento para activos, gestionar parches, planificar actualizaciones, documentar riesgos y asociar reglas de privacidad y seguridad a cada activo o software.', 'Se puede automatizar con reglas y cronogramas', '-'),

('BAI03-P10-A02', 'BAI03-P10', 'Evalúe la importancia de una actividad de mantenimiento propuesta en el diseño, la funcionalidad o los procesos de negocio actuales de la solución. Considere el riesgo, el impacto en el usuario y la disponibilidad de recursos. Asegúrese de que los responsables de los procesos de negocio comprendan el efecto de designar los cambios como mantenimiento.', 3, 'GLPI', 'Cada solicitud o evento de mantenimiento puede clasificarse por prioridad, riesgo e impacto sobre procesos. Es posible asociar responsables y documentar decisiones.', 'Requiere disciplina operativa constante.', '-'),

('BAI03-P10-A03', 'BAI03-P10', 'En caso de cambios importantes en las soluciones existentes que resulten en cambios significativos en los diseños, la funcionalidad o los procesos de negocio actuales, siga el proceso de desarrollo utilizado para los nuevos sistemas. Para las actualizaciones de mantenimiento, utilice el proceso de gestión de cambios.', 3, 'GLPI', 'Permite escalar solicitudes de mantenimiento a solicitudes de cambio mayores que involucren flujo de aprobación. La trazabilidad se mantiene entre solicitudes, problemas y cambios.', 'Bien integrado al ciclo de vida ITSM.', 'Changes'),

('BAI03-P10-A04', 'BAI03-P10', 'Asegúrese de que el patrón y el volumen de las actividades de mantenimiento se analicen periódicamente para detectar tendencias anormales que indiquen problemas subyacentes de calidad o rendimiento, relación costo-beneficio de una actualización importante o reemplazo en lugar de mantenimiento.', 4, 'GLPI', 'Mediante reportes e históricos, se pueden identificar patrones repetitivos de incidencias o mantenimientos que evidencien causas subyacentes o decisiones estratégicas.', 'Requiere explotación periódica de datos', '-'),

('BAI03-P11-A01', 'BAI03-P11', 'Proponer definiciones de los productos y servicios de TI nuevos o modificados para garantizar su idoneidad para el propósito. Documentar las definiciones propuestas en la lista de productos y servicios a desarrollar.', 3, 'GLPI', 'permite definir nuevos servicios o productos en su módulo de catálogo, documentarlos, asignar propietarios, requisitos y fechas de entrega esperadas.', 'Alta personalización y seguimiento.', 'Service Catalo'),

('BAI03-P11-A02', 'BAI03-P11', 'Proponer opciones de nivel de servicio nuevas o modificadas (tiempo de servicio, satisfacción del usuario, disponibilidad, rendimiento, capacidad, seguridad, privacidad, continuidad, cumplimiento normativo y usabilidad) para garantizar que los productos y servicios de TI sean adecuados para su uso. Documentar las opciones de servicio propuestas en el portafolio.', 3, 'GLPI', 'Se pueden definir niveles de servicio por tipo de solicitud, incluyendo tiempos de respuesta, disponibilidad, prioridades y condiciones de seguridad.', 'Muy útil en entornos orientados a soporte.', '-'),

('BAI03-P11-A03', 'BAI03-P11', 'Interactuar con la gestión de relaciones comerciales y la gestión de cartera para acordar las definiciones de productos y servicios propuestas y las opciones de nivel de servicio.', 3, 'GLPI', 'Puede configurarse para integrarse con estructuras de negocio y relaciones cliente internoûTI mediante asignación de roles, aprobaciones y seguimiento.', 'Integración documental, no financiera.', '-'),

('BAI03-P11-A04', 'BAI03-P11', 'Si el cambio de producto o servicio se encuentra dentro de la autoridad de aprobación acordada, desarrolle los productos y servicios de TI, o las opciones de nivel de servicio, nuevos o modificados. De lo contrario, remita el cambio a la administración de cartera para su revisión de inversión.', 3, 'GLPI', 'Si se tiene autorización, GLPI permite implementar directamente los cambios. Si no, se puede redirigir vía flujo de validación o mediante informes al comité de gestión.', 'Muy útil para controlar gobernanza operativa', '-'),

('BAI03-P12-A01', 'BAI03-P12', 'Analizar y evaluar el impacto de la elección de una metodología de desarrollo (es decir, cascada, Agile, bimodal) en los recursos disponibles, los requisitos de arquitectura, las configuraciones y la rigidez del sistema.', 3, 'JFire', 'JFIRE permite modelar arquitectura modular y evaluar compatibilidad con metodologías ágiles, cascada o híbridas. Considera recursos, arquitectura y configuración como parte del diseño.', 'Adaptable a cualquier marco de desarrollo.', '-'),

('BAI03-P12-A02', 'BAI03-P12', 'Establecer la metodología de desarrollo y el enfoque organizativo adecuados que permitan implementar la solución propuesta de forma eficiente y eficaz, y que sea capaz de satisfacer los requisitos del negocio, la arquitectura y el sistema. Adaptar los procesos según sea necesario a la estrategia elegida.', 3, 'JFire', 'Se pueden implementar procesos personalizados según la metodología elegida, con ajustes a los flujos, reglas, validaciones y gobernanza.', 'Muy flexible para entornos Agile, DevOps, bimodal.', '-'),

('BAI03-P12-A03', 'BAI03-P12', 'Establecer los equipos de proyecto necesarios según la metodología de desarrollo elegida. Proporcionar la capacitación necesaria.', 3, 'JFire', 'JFIRE permite crear equipos dedicados, asignar funciones, definir recursos y establecer rutas de capacitación interna para cada rol.', 'Robusto para gestión organizacional por proyecto.', '-'),

('BAI03-P12-A04', 'BAI03-P12', 'Considere la posibilidad de aplicar un sistema dual, si es necesario, en el que grupos interfuncionales (fábricas digitales) se centren en el desarrollo de un producto o proceso utilizando una tecnología, metodología operativa o de gestión diferente a la del resto de la empresa. Integrar estos grupos en las unidades de negocio tiene la ventaja de difundir la nueva cultura de desarrollo ágil y convertir este enfoque de fábrica digital en la norma.', 3, 'JFire', 'Admite la implementación de entornos independientes (por ejemplo, fábricas digitales) y su integración con el ecosistema organizacional, fomentando la cultura ágil.', 'Soporte total para arquitectura bimodal.', '-'),

('BAI04-P01-A01', 'BAI04-P01', 'Considere lo siguiente (actual y previsto) en la evaluación de la disponibilidad, el rendimiento y la capacidad de los servicios y recursos: requisitos del cliente, prioridades del negocio, objetivos del negocio, impacto presupuestario, utilización de recursos, capacidades de TI y tendencias de la industria.', 2, 'Zabbix', 'Permite evaluar en tiempo real múltiples indicadores de capacidad y disponibilidad', 'Admite umbrales, alarmas y reportes comparativos históricos', '-'),

('BAI04-P01-A02', 'BAI04-P01', 'Identificar y dar seguimiento a todos los incidentes ocasionados por un desempeño o capacidad inadecuados.', 3, 'GLPI', 'Incidentes vinculados a activos con métricas de rendimiento deficientes', '-', '-'),

('BAI04-P01-A03', 'BAI04-P01', 'Supervisar el rendimiento real y el uso de la capacidad frente a umbrales definidos, con el apoyo, cuando sea necesario, de software automatizado.', 4, 'Zabbix', 'Configuración de umbrales personalizados y alertas automáticas', 'Automatización avanzada con scripts de corrección', '-'),

('BAI04-P01-A04', 'BAI04-P01', 'Evalúe periódicamente los niveles actuales de rendimiento de todos los niveles de procesamiento (demanda de negocio, capacidad de servicio y capacidad de recursos) comparándolos con las tendencias y los SLA. Tenga en cuenta los cambios en el entorno.', 4, 'Zabbix', 'Reportes históricos y visuales de rendimiento y cumplimiento', 'Admite métricas multinivel: recursos, servicios, negocio', '-'),

('BAI04-P02-A01', 'BAI04-P02', 'Identifique únicamente aquellas soluciones o servicios que sean críticos en el proceso de gestión de disponibilidad y capacidad.', 2, 'GLPI', 'Permite marcar activos o servicios como críticos', 'No hace análisis automatizado del impacto, solo inventario', 'Zabbix para metricas criticas.'),

('BAI04-P02-A02', 'BAI04-P02', 'Asigne las soluciones o servicios seleccionados a las aplicaciones y la infraestructura (TI e instalaciones) de las que dependen para permitir un enfoque en los recursos críticos para la planificación de la disponibilidad.', 3, 'GLPI', 'Asociación de servicios, equipos y software en CMDB', 'Permite vistas jerárquicas y dependencias', '-'),

('BAI04-P02-A03', 'BAI04-P02', 'Recopile datos sobre patrones de disponibilidad a partir de registros de fallos anteriores y la monitorización del rendimiento. Utilice herramientas de modelado que permitan predecir fallos basándose en tendencias de uso anteriores y las expectativas de gestión del nuevo entorno o las condiciones del usuario.', 4, 'Zabbix', 'Muestra patrones y permite estimaciones manuales de tendencia', 'No tiene modelado predictivo por IA, pero sí por historial', '-'),

('BAI04-P02-A04', 'BAI04-P02', 'Con base en los datos recopilados, cree escenarios que describan situaciones de disponibilidad futuras para ilustrar una variedad de niveles de capacidad potenciales necesarios para lograr el objetivo de rendimiento de disponibilidad.', 4, 'Zabbix', 'Zabbix entrega métricas históricas y en tiempo real; Grafana con plugins permite hacer proyecciones y construir modelos de tendencia basados en series temporales', 'Requiere configuración avanzada de modelos predictivos en Grafana', 'Grafana Forecast plugin'),

('BAI04-P02-A05', 'BAI04-P02', 'Con base en los escenarios, determine la probabilidad de que no se alcance el objetivo de desempeño de disponibilidad.', 4, 'Zabbix', 'Zabbix recoge métricas de disponibilidad y rendimiento en tiempo real. Grafana permite visualizar esos datos en dashboards. El plugin de forecasting permite aplicar modelos de predicción basados en series de tiempo, generando tendencias y probabilidades de incumplimiento.', 'Requiere configurar umbrales y objetivos (SLA), así como integrar series históricas para aplicar el forecast. El plugin de forecasting debe estar activado y configurado con parámetros de confianza. Se pueden definir alertas ante probabilidades de incumplimiento.', 'Grafana Forecasting Plugin'),

('BAI04-P02-A06', 'BAI04-P02', 'Determine el impacto de los escenarios en las medidas de rendimiento del negocio (p. ej., ingresos, beneficios, servicio al cliente). Involucre a los líderes de las líneas de negocio, funcionales (especialmente financieros) y regionales para comprender su evaluación del impacto.', 4, 'Zabbix', 'Si se integra con Apache Superset o Metabase Permite conectar fuentes de datos (Zabbix, contabilidad, GLPI) y construir dashboards para evaluar impactos en KPI como ingresos, SLA, tiempos de respuesta', 'Se debe diseñar manualmente el modelo de correlación entre disponibilidad y métricas del negocio', 'Apache Superset o Metabase'),

('BAI04-P02-A07', 'BAI04-P02', 'Asegúrese de que los responsables de los procesos de negocio comprendan y acepten plenamente los resultados de este análisis. Solicite a los responsables de los procesos de negocio una lista de escenarios de riesgo inaceptables que requieran una respuesta para reducir el riesgo a niveles aceptables.', 4, 'Eramba', 'Permite formalizar aceptación o rechazo de riesgos, agregar comentarios, evidencias y generar reportes sobre decisiones de negocio ante escenarios de riesgo', 'Aunque no modela disponibilidad, sí gestiona la aceptación empresarial de escenarios de riesgo', 'Complementar con reporte exportado desde Superset o Jupyter'),

('BAI04-P03-A01', 'BAI04-P03', 'Identificar las implicaciones de disponibilidad y capacidad de las necesidades cambiantes del negocio y las oportunidades de mejora. Utilizar técnicas de modelado para validar los planes de disponibilidad, rendimiento y capacidad.', 3, 'Zabbix', 'Permite monitoreo histórico y en tiempo real. Los gráficos de Grafana junto a plugins de predicción ayudan a visualizar el impacto de nuevos requerimientos.', 'Puede integrarse con scripts externos para validar proyecciones.', 'Grafana forecasting plugin'),

('BAI04-P03-A02', 'BAI04-P03', 'Revisar las implicaciones de disponibilidad y capacidad del análisis de tendencias del servicio.', 4, 'Zabbix', 'Los dashboards permiten visualizar las tendencias de uso, rendimiento y disponibilidad, facilitando la revisión continua.', 'Requiere métricas correctamente configuradas y comparables.', '-'),

('BAI04-P03-A03', 'BAI04-P03', 'Asegúrese de que la administración realice comparaciones de la demanda real de recursos con la oferta y la demanda previstas para evaluar las técnicas de previsión actuales y realizar mejoras cuando sea posible.', 4, 'Zabbix', 'Uso de series de tiempo y gráficos comparativos. Se pueden definir umbrales para automatizar alertas de desviación.', 'Ideal con histórico bien definido y forecast activo.', 'Grafana forecasting plugin'),

('BAI04-P03-A04', 'BAI04-P03', 'Priorizar las mejoras necesarias y crear planes de disponibilidad y capacidad que justifiquen sus costos.', 5, 'Zabbix', 'Dashboards ayudan a identificar cuellos de botella y justificar mejoras con datos visuales de uso.', 'Necesita un enfoque combinado con gestión de portafolio si se integran decisiones de inversión.', '-'),

('BAI04-P03-A05', 'BAI04-P03', 'Ajuste los planes de rendimiento y capacidad, así como los SLA, en función de los procesos de negocio realistas, nuevos, propuestos o proyectados, así como de los cambios en los servicios, aplicaciones e infraestructura de soporte. Incluya también revisiones del rendimiento real y el uso de la capacidad, incluyendo los niveles de carga de trabajo.', 5, 'Zabbix', 'Permite revisar umbrales, carga de trabajo y ajustar alertas o métricas.', 'Se puede exportar el análisis para validarlo con líderes de negocio.', 'Grafana forecasting plugin'),

('BAI04-P04-A01', 'BAI04-P04', 'Proporcionar informes de capacidad a los procesos de presupuestación.', 2, 'Zabbix', 'Exporta métricas de uso real y proyecciones para alimentar decisiones de inversión.', 'Puede automatizarse en PDF o JSON vía API.', '-'),

('BAI04-P04-A02', 'BAI04-P04', 'Establecer un proceso para recopilar datos que proporcionen a la gerencia información de seguimiento y generación de informes sobre la disponibilidad, el rendimiento y la capacidad de carga de trabajo de todos los recursos relacionados con I&T.', 3, 'Zabbix', 'Especializado en recopilar KPIs de disponibilidad, rendimiento, carga de CPU, RAM, etc.', 'Alta compatibilidad con agentes SNMP, IPMI y APIs.', '-'),

('BAI04-P04-A03', 'BAI04-P04', 'Proporcionar informes periódicos de los resultados en un formato apropiado para su revisión por parte de TI y la gerencia empresarial, y su comunicación a la gerencia de la empresa.', 4, 'Grafana', 'Tableros visuales y exportables para públicos técnicos o ejecutivos.', 'Se pueden programar alertas visuales y exportables.', '-'),

('BAI04-P04-A04', 'BAI04-P04', 'Integrar actividades de seguimiento y presentación de informes en las actividades iterativas de gestión de la capacidad (seguimiento, análisis, ajuste e implementaciones).', 4, 'Zabbix', 'Ciclos de revisión automatizados con comparativas y alertas. Apoya el ciclo PDCA (Plan-Do-Check-Act).', 'Requiere proceso documentado en la organización.', '-'),

('BAI04-P05-A01', 'BAI04-P05', 'Obtenga orientación de los manuales de productos de los proveedores para garantizar un nivel adecuado de disponibilidad de rendimiento para cargas de trabajo y procesamiento máximos.', 3, NULL, 'Las herramientas open source como Zabbix o Grafana no ofrecen directamente manuales de fabricantes; se requiere documentación externa.', 'Esta actividad depende del fabricante del hardware o software utilizado.', '-'),

('BAI04-P05-A02', 'BAI04-P05', 'Definir un procedimiento de escalamiento para una rápida resolución en caso de problemas de capacidad y rendimiento de emergencia.', 3, 'GLPI', 'GLPI permite definir procesos de escalamiento (tickets y flujos), y Zabbix detecta eventos que los activan.', 'Se puede automatizar el escalamiento mediante reglas de alerta.', 'zabbix'),

('BAI04-P05-A03', 'BAI04-P05', 'Identifique las brechas de rendimiento y capacidad con base en la monitorización del rendimiento actual y previsto. Utilice las especificaciones conocidas de disponibilidad, continuidad y recuperación para clasificar los recursos y permitir la priorización.', 4, 'Zabbix', 'Permite identificar brechas mediante métricas en tiempo real y comparación con umbrales definidos.', 'Puede complementarse con herramientas de continuidad si se desea un análisis más profundo.', 'Grafana Forecast plugin'),

('BAI04-P05-A04', 'BAI04-P05', 'Definir acciones correctivas (por ejemplo, cambiar la carga de trabajo, priorizar tareas o agregar recursos cuando se identifican problemas de rendimiento y capacidad).', 5, 'Zabbix', 'Zabbix puede ejecutar acciones automáticas al detectar umbrales críticos (scripts o llamadas API para redistribuir cargas, apagar/encender servicios, etc.).', 'Acciones más complejas pueden necesitar herramientas de orquestación como Ansible.', 'scripts personalizados'),

('BAI04-P05-A05', 'BAI04-P05', 'Integrar las acciones correctivas necesarias en los procesos adecuados de planificación y gestión del cambio.', 5, 'GLPI', 'GLPI permite la gestión de solicitudes de cambio, vinculándolas a incidentes, problemas o acciones correctivas.', 'Requiere configurar correctamente el flujo de cambios correctivos, enlazando con los incidentes/performance.', '(con módulo de gestión de cambios)'),

('BAI05-P01-A01', 'BAI05-P01', 'Evaluar el alcance y el impacto del cambio previsto, las distintas partes interesadas afectadas, la naturaleza del impacto y la participación requerida de cada grupo de partes interesadas, y la preparación y capacidad actuales para adoptar el cambio.', 2, 'GLPI', 'Permite gestionar evaluaciones de impacto, riesgos y controles asociados', 'No incluye un framework completo de gestión del cambio organizacional, se centra en ciberseguridad', 'GLPI (para centralizar actividades y recursos)'),

('BAI05-P01-A02', 'BAI05-P01', 'Establecer el deseo de cambiar, identificar, aprovechar y comunicar los puntos críticos actuales, los eventos negativos, los riesgos, la insatisfacción del cliente y los problemas del negocio, así como los beneficios iniciales, las oportunidades y recompensas futuras y las ventajas competitivas.', 2, NULL, 'Las herramientas listadas no incluyen módulos de comunicación estratégica ni de gestión del cambio organizacional', 'Requiere herramientas de comunicación interna o gestión de cultura organizacional', '-'),

('BAI05-P01-A03', 'BAI05-P01', 'Emitir comunicaciones clave del comité ejecutivo o del CEO para demostrar el compromiso con el cambio.', 2, NULL, 'Ninguna herramienta facilita gestión de comunicaciones ejecutivas internas formalizadas o campañas de compromiso', 'Se requiere software de comunicación (no disponible entre herramientas listadas)', '-'),

('BAI05-P01-A04', 'BAI05-P01', 'Proporcionar un liderazgo visible desde la alta dirección para establecer la dirección y alinear, motivar e inspirar a las partes interesadas a desear el cambio.', 2, NULL, 'Ninguna de las herramientas permite vincular directamente liderazgo ejecutivo con gestión del cambio', 'Este componente es cultural y debe gestionarse externamente', '-'),

('BAI05-P02-A01', 'BAI05-P02', 'Identificar y formar un equipo de implementación central eficaz que incluya a miembros adecuados de la empresa y de TI con la capacidad de dedicar el tiempo necesario y aportar conocimientos, experiencia, credibilidad y autoridad. Considere la posibilidad de incluir a terceros, como consultores, para aportar una visión independiente o abordar las carencias de habilidades. Identifique a posibles agentes de cambio en las diferentes áreas de la empresa con quienes el equipo central pueda colaborar para respaldar la visión e implementar los cambios en cascada.', 3, 'GLPI', 'Permite asignar tareas y roles a distintos usuarios y gestionar proyectos con equipos internos', 'No facilita formación de equipos desde una perspectiva estratégica, pero es útil para organización operativa', '-'),

('BAI05-P02-A02', 'BAI05-P02', 'Crear confianza dentro del equipo central de implementación a través de eventos cuidadosamente planificados con comunicación efectiva y actividades conjuntas.', 3, NULL, 'No hay herramientas de comunicación o eventos colaborativos en la lista actual', 'Se requiere software de colaboración o mensajería', '-'),

('BAI05-P02-A03', 'BAI05-P02', 'Desarrollar una visión y objetivos comunes que respalden los objetivos de la empresa.', 3, NULL, 'Ninguna herramienta provee funciones de desarrollo de estrategia empresarial compartida o co-creación', 'Se gestiona fuera del entorno de TI', '-'),

('BAI05-P03-A01', 'BAI05-P03', 'Desarrollar un plan de comunicación de la visión para abordar los grupos de audiencia principales, sus perfiles de comportamiento y requisitos de información, canales de comunicación y principios.', 3, 'RocketChat', 'Permite crear canales temáticos, comunicaciones repetitivas y verificación de lectura', 'Se adapta a comunicación estratégica y masiva interna', '-'),

('BAI05-P03-A02', 'BAI05-P03', 'Entregar la comunicación a los niveles apropiados de la empresa, de acuerdo con el plan.', 3, 'Moodle', 'Diseño de programas de formación, tutorías, evaluaciones y seguimiento', 'Integración posible con otros sistemas de la empresa', '-'),

('BAI05-P03-A03', 'BAI05-P03', 'Reforzar la comunicación a través de múltiples foros y repetición.', 3, 'GLPI', 'GLPI gestiona mejoras rápidas (proyectos), RocketChat comunica y refuerza', 'Se logra una combinación efectiva de acción y divulgación', 'RocketChat'),

('BAI05-P03-A04', 'BAI05-P03', 'Hacer que todos los niveles de liderazgo sean responsables de demostrar la visión.', 3, 'OrangeHRM', 'Permite gestionar procesos de evaluación, compensación, promociones y seguimiento de desempeño', 'Puede integrarse con otros módulos de cambio', '-'),

('BAI05-P03-A05', 'BAI05-P03', 'Verificar la comprensión de la visión deseada y responder a cualquier problema destacado por el personal.', 4, 'OrangeHRM', 'A través de evaluaciones de desempeño o feedback organizacional', 'No identifica resistencia cultural sin input externo', '-'),

('BAI05-P04-A01', 'BAI05-P04', 'Planifique las oportunidades de capacitación que el personal necesitará para desarrollar las habilidades y actitudes apropiadas para sentirse empoderado.', 2, 'GLPI', 'Moodle cubre capacitación post-implementación; GLPI apoya documentación y soporte', 'Complementan el despliegue y estabilización del cambio', 'Moodle'),

('BAI05-P04-A02', 'BAI05-P04', 'Identificar, priorizar y aprovechar oportunidades para obtener resultados rápidos. Estas podrían estar relacionadas con áreas de dificultad conocidas o factores externos que requieren atención urgente.', 2, 'Eramba', 'Permite definir responsables y hacer seguimiento del cumplimiento', 'Útil si los procesos están regulados o documentados', '-'),

('BAI05-P04-A03', 'BAI05-P04', 'Aprovechar los logros rápidos obtenidos comunicando los beneficios a los afectados para demostrar que la visión va por buen camino. Perfeccionar la visión, mantener a los líderes comprometidos y generar impulso.', 2, 'RocketChat', 'Facilita campañas de reconocimiento y difusión de logros', 'Puede integrarse con RRHH (OrangeHRM)', '-'),

('BAI05-P04-A04', 'BAI05-P04', 'Identificar estructuras organizacionales compatibles con la visión; si es necesario, realizar cambios para asegurar la alineación.', 3, 'OrangeHRM', 'OrangeHRM evalúa desempeño, Moodle permite validar aprendizaje/adopción', 'Complementar con métricas visuales en Grafana (opcional)', 'Moodle'),

('BAI05-P04-A05', 'BAI05-P04', 'Alinear los procesos de RRHH y los sistemas de medición (por ejemplo, evaluación del desempeño, decisiones de compensación, decisiones de promoción, reclutamiento y contratación) para respaldar la visión.', 3, 'OrangeHRM', 'Gestiona evaluación de desempeño, compensación, promociones y reclutamiento', 'Se adapta a cualquier marco estratégico de cambio', '-'),

('BAI05-P04-A06', 'BAI05-P04', 'Identificar y gestionar a los líderes que continúan resistiéndose al cambio necesario.', 3, 'OrangeHRM', 'A través de métricas de desempeño; requiere refuerzo para lo cultural', 'Puede apoyarse en observaciones informales', 'RocketChat'),

('BAI05-P05-A01', 'BAI05-P05', 'Desarrollar un plan para la operación y el uso del cambio. El plan debe comunicar y aprovechar los logros inmediatos, abordar los aspectos conductuales y culturales de la transición general y fomentar la aceptación y el compromiso. Asegúrese de que el plan abarque una visión integral del cambio y proporcione documentación (p. ej., procedimientos), mentoría, capacitación, coaching, transferencia de conocimientos, un mejor soporte inmediato posterior a la implementación y apoyo continuo.', 3, 'GLPI', 'Moodle para formación y coaching, GLPI para soporte post-implementación', 'Permite acompañamiento durante la transición', 'Moodle'),

('BAI05-P05-A02', 'BAI05-P05', 'Implementar el plan de operación y uso. Definir y monitorear indicadores de éxito, incluyendo indicadores empresariales clave y de percepción que indiquen la percepción de las personas sobre un cambio. Implementar las medidas correctivas necesarias.', 4, 'GLPI', 'GLPI puede registrar métricas clave, Grafana ayuda con visualización', 'GLPI soporta acciones correctivas desde tickets', '-'),

('BAI05-P06-A01', 'BAI05-P06', 'Hacer que los propietarios de procesos sean responsables de las operaciones normales del día a día.', 2, 'Eramba', 'Permite asignar controles, responsables y medir cumplimiento', 'Asegura trazabilidad y rendición de cuentas', '-'),

('BAI05-P06-A02', 'BAI05-P06', 'Celebrar los éxitos e implementar programas de recompensa y reconocimiento para reforzar el cambio.', 3, 'RocketChat', 'Campañas internas de reconocimiento, integración con RRHH', 'Refuerza cultura de cambio positiva', '-'),

('BAI05-P06-A03', 'BAI05-P06', 'Proporcionar conciencia continua mediante la comunicación regular del cambio y su adopción.', 3, 'RocketChat', 'Canales dedicados a la transformación, newsletters, recordatorios', 'Refuerzo clave para mantener conciencia activa', '-'),

('BAI05-P06-A04', 'BAI05-P06', 'Utilice sistemas de medición del rendimiento para identificar las causas de la baja adopción. Tome medidas correctivas.', 4, 'OrangeHRM', 'Evaluaciones de desempeño + resultados de formación', 'Cruce de datos permite detectar problemas reales', 'Moodle'),

('BAI05-P06-A05', 'BAI05-P06', 'Realizar auditorías de cumplimiento para identificar las causas de la baja adopción. Recomendar medidas correctivas.', 4, 'Eramba', 'Auditoría sobre implementación de controles y cambios definidos', 'Permite documentación de medidas correctivas', '-'),

('BAI05-P07-A01', 'BAI05-P07', 'Mantener y reforzar el cambio mediante una comunicación regular que demuestre el compromiso de la alta dirección.', 2, 'RocketChat', 'Comunicación oficial recurrente y liderazgo visible', 'Útil como reforzador transversal del cambio', '-'),

('BAI05-P07-A02', 'BAI05-P07', 'Brindar tutoría, capacitación, entrenamiento y transferencia de conocimientos al nuevo personal para sostener el cambio.', 3, 'Moodle', 'Capacitación continua y onboarding basado en cambios', 'Ideal para institucionalizar el cambio', '-'),

('BAI05-P07-A03', 'BAI05-P07', 'Realizar revisiones periódicas del funcionamiento y la aplicación del cambio. Identificar mejoras.', 4, 'GLPI', 'Registro, seguimiento y evaluación de incidencias o mejoras', 'Da trazabilidad al desempeño del cambio', '-'),

('BAI05-P07-A04', 'BAI05-P07', 'Captar las lecciones aprendidas en relación con la implementación del cambio. Compartir el conocimiento con toda la empresa.', 5, 'GLPI', 'Documentación colaborativa + espacios de retroalimentación', 'Permite compartir y almacenar aprendizaje', '-'),

('BAI06-P01-A01', 'BAI06-P01', 'Utilice solicitudes de cambio formales para que los responsables de los procesos de negocio y el departamento de TI puedan solicitar cambios en los procesos, la infraestructura, los sistemas o las aplicaciones. Asegúrese de que todos estos cambios se realicen únicamente mediante el proceso de gestión de solicitudes de cambio.', 2, 'GLPI', 'Cuenta con módulo completo de Gestión de Cambios, soporte de CMDB, flujo de aprobación, evaluación de impacto, prioridades, SLA y control de proveedores.', 'Permite modelar los flujos de cambio con impacto técnico, contractual y de negocio. Algunas validaciones deben configurarse.', 'FusionInventory, OCS Inventory, Zabbix'),

('BAI06-P01-A02', 'BAI06-P01', 'Clasifique todos los cambios solicitados (por ejemplo, proceso de negocio, infraestructura, sistemas operativos, redes, sistemas de aplicación, software de aplicación comprado/empaquetado) y relacione los elementos de configuración afectados.', 2, 'GLPI', 'Cuenta con módulo completo de Gestión de Cambios, soporte de CMDB, flujo de aprobación, evaluación de impacto, prioridades, SLA y control de proveedores.', 'Permite modelar los flujos de cambio con impacto técnico, contractual y de negocio. Algunas validaciones deben configurarse.', 'FusionInventory, OCS Inventory, Zabbix'),

('BAI06-P01-A03', 'BAI06-P01', 'Priorizar todos los cambios solicitados en función de los requisitos comerciales y técnicos, los recursos necesarios y las razones legales, regulatorias y contractuales del cambio solicitado.', 2, 'GLPI', 'Cuenta con módulo completo de Gestión de Cambios, soporte de CMDB, flujo de aprobación, evaluación de impacto, prioridades, SLA y control de proveedores.', 'Permite modelar los flujos de cambio con impacto técnico, contractual y de negocio. Algunas validaciones deben configurarse.', 'FusionInventory, OCS Inventory, Zabbix'),

('BAI06-P01-A04', 'BAI06-P01', 'Aprobar formalmente cada cambio por parte de los propietarios de procesos de negocio, los gerentes de servicio y las partes interesadas técnicas de TI, según corresponda. Los cambios de bajo riesgo y relativamente frecuentes deben aprobarse previamente como cambios estándar.', 2, 'GLPI', 'Cuenta con módulo completo de Gestión de Cambios, soporte de CMDB, flujo de aprobación, evaluación de impacto, prioridades, SLA y control de proveedores.', 'Permite modelar los flujos de cambio con impacto técnico, contractual y de negocio. Algunas validaciones deben configurarse.', 'FusionInventory, OCS Inventory, Zabbix'),

('BAI06-P01-A05', 'BAI06-P01', 'Planifique y programe todos los cambios aprobados.', 2, 'GLPI', 'Cuenta con módulo completo de Gestión de Cambios, soporte de CMDB, flujo de aprobación, evaluación de impacto, prioridades, SLA y control de proveedores.', 'Permite modelar los flujos de cambio con impacto técnico, contractual y de negocio. Algunas validaciones deben configurarse.', 'FusionInventory, OCS Inventory, Zabbix'),

('BAI06-P01-A06', 'BAI06-P01', 'Planifique y evalúe todas las solicitudes de forma estructurada. Incluya un análisis de impacto en los procesos de negocio, la infraestructura, los sistemas y las aplicaciones, los planes de continuidad de negocio (PCN) y los proveedores de servicios para garantizar que se hayan identificado todos los componentes afectados. Evalúe la probabilidad de afectar negativamente al entorno operativo y el riesgo de implementar el cambio. Considere las implicaciones de seguridad, privacidad, legales, contractuales y de cumplimiento del cambio solicitado. Considere también las interdependencias entre los cambios. Involucre a los responsables de los procesos de negocio en el proceso de evaluación, según corresponda.', 3, 'iTop by Combodo', 'Permite modelar el análisis de impacto detallado de los cambios, sus dependencias, SLA, continuidad y gestión de proveedores con relaciones contractuales.', 'Permite trazabilidad total del cambio, impacto operativo, legal y contractual. Genera workflows y documentación integrados.', 'GLPI'),

('BAI06-P01-A07', 'BAI06-P01', 'Considere el impacto de los proveedores de servicios contratados (p. ej., procesamiento empresarial externalizado, infraestructura, desarrollo de aplicaciones y servicios compartidos) en el proceso de gestión de cambios. Incluya la integración de los procesos de gestión de cambios organizacionales con los procesos de gestión de cambios de los proveedores de servicios y su impacto en los términos contractuales y los acuerdos de nivel de servicio (SLA).', 3, 'iTop by Combodo', 'Permite modelar el análisis de impacto detallado de los cambios, sus dependencias, SLA, continuidad y gestión de proveedores con relaciones contractuales.', 'Permite trazabilidad total del cambio, impacto operativo, legal y contractual. Genera workflows y documentación integrados.', 'GLPI'),

('BAI06-P02-A01', 'BAI06-P02', 'Defina qué constituye un cambio de emergencia.', 2, 'iTop by Combodo', 'Permite configurar tipos de cambios personalizados (por ejemplo, ôCambio de Emergenciaö), con criterios definidos y categorización automática.', 'Puede incluir reglas para clasificación automática.', '-'),

('BAI06-P02-A02', 'BAI06-P02', 'Asegurarse de que exista un procedimiento documentado para declarar, evaluar, aprobar preliminarmente, autorizar después del cambio y registrar un cambio de emergencia.', 2, 'iTop by Combodo', 'Flujos de trabajo configurables permiten definir pasos de aprobación preliminar, ejecución y cierre de forma documentada.', 'La trazabilidad de cada paso se mantiene íntegra.', '-'),

('BAI06-P02-A03', 'BAI06-P02', 'Verificar que todos los acuerdos de acceso de emergencia para los cambios estén debidamente autorizados, documentados y revocados después de que se haya aplicado el cambio.', 3, 'iTop by Combodo', 'Permite registrar accesos temporales, autorizaciones y tareas de revocación automática asociadas al cambio.', 'Compatible con LDAP para control de accesos.', '-'),

('BAI06-P02-A04', 'BAI06-P02', 'Supervisar todos los cambios de emergencia y realizar revisiones posteriores a la implementación con la participación de todas las partes involucradas. La revisión debe considerar e implementar acciones correctivas basadas en las causas raíz, como problemas con los procesos de negocio, el desarrollo y mantenimiento del sistema de aplicaciones, los entornos de desarrollo y prueba, la documentación y los manuales, y la integridad de los datos.', 4, 'iTop by Combodo', 'Permite registrar revisiones postimplementación, análisis de causa raíz y acciones correctivas.', 'Incluye tareas automáticas y trazabilidad de mejoras.', '-'),

('BAI06-P03-A01', 'BAI06-P03', 'Clasifique las solicitudes de cambio en el proceso de seguimiento (por ejemplo, rechazadas, aprobadas pero aún no iniciadas, aprobadas y en proceso y cerradas).', 4, 'iTop by Combodo', 'Soporta estados personalizables en el ciclo de vida del cambio: Rechazado, Aprobado, En proceso, Cerrado, etc.', 'Visualización clara del estado en cada fase del proceso.', '-'),

('BAI06-P03-A02', 'BAI06-P03', 'Implementar informes de estado de cambios con métricas de rendimiento para que la gerencia pueda revisar y supervisar tanto el estado detallado de los cambios como el estado general (p. ej., análisis de solicitudes de cambio con antig³edad). Garantizar que los informes de estado formen un registro de auditoría para que se pueda realizar un seguimiento posterior de los cambios desde su inicio hasta su disposición final.', 4, 'iTop by Combodo', 'Genera reportes automáticos y métricas de rendimiento; historial de auditoría completo con trazabilidad.', 'Exportación en PDF/CSV, paneles dinámicos.', '-'),

('BAI06-P03-A03', 'BAI06-P03', 'Supervisar los cambios abiertos para garantizar que todos los cambios aprobados se cierren de manera oportuna, según la prioridad.', 4, 'iTop by Combodo', 'Permite programar seguimientos, alertas y escalamiento por prioridad para cambios no cerrados.', 'Incluye SLA configurables.', '-'),

('BAI06-P03-A04', 'BAI06-P03', 'Mantener un sistema de seguimiento e informes para todas las solicitudes de cambio.', 4, 'iTop by Combodo', 'Gestión completa del ciclo de vida de cada cambio con logs, alertas, seguimiento y generación de informes integrados.', 'Información consolidada y consultable históricamente.', '-'),

('BAI06-P04-A01', 'BAI06-P04', 'Incluya los cambios en la documentación dentro del procedimiento de gestión. Algunos ejemplos de documentación incluyen procedimientos operativos empresariales y de TI, documentación de continuidad de negocio y recuperación ante desastres, información de configuración, documentación de aplicaciones, pantallas de ayuda y materiales de capacitación.', 2, 'GLPI', 'Permite adjuntar documentación técnica y operativa a los tickets de cambio, vincular con la CMDB, y registrar planes de continuidad y recuperación.', 'Compatible con estándares ITIL para documentación completa.', '-'),

('BAI06-P04-A02', 'BAI06-P04', 'Defina un período de retención apropiado para la documentación de cambios y la documentación del sistema y del usuario previa y posterior al cambio.', 3, 'GLPI', 'Soporta políticas de retención mediante configuración de ciclo de vida de elementos documentales y tickets.', 'Se pueden aplicar reglas según tipo de documento.', '-'),

('BAI06-P04-A03', 'BAI06-P04', 'Someter la documentación al mismo nivel de revisión que el cambio real.', 3, 'GLPI', 'Los flujos de trabajo incluyen validaciones y aprobaciones tanto para los cambios como para los documentos asociados.', 'Permite establecer validadores y responsables de documentación.', '-'),

('BAI07-P01-A01', 'BAI07-P01', 'Crear un plan de implementación que refleje la estrategia de implementación general, la secuencia de pasos de implementación, los requisitos de recursos, las interdependencias, los criterios para la aceptación de la administración de la implementación de producción, los requisitos de verificación de la instalación, la estrategia de transición para el soporte de producción y la actualización de los planes de continuidad del negocio.', 2, 'iTop by Combodo', 'Permite definir y gestionar planes de implementación como parte del ciclo de gestión de cambios y liberaciones, incluyendo pasos, recursos, dependencias y aceptación.', 'Tiene capacidades de planificación dentro del contexto ITSM y gestión de cambios', '-'),

('BAI07-P01-A02', 'BAI07-P01', 'De los proveedores de soluciones externos, obtener el compromiso de involucrarlos en cada paso de la implementación.', 2, 'iTop by Combodo', 'Integra y gestiona relaciones con proveedores como parte de su gestión de servicios. Se pueden registrar tareas e hitos que involucren proveedores.', 'Permite seguimiento de proveedores y su participación en cada etapa', '-'),

('BAI07-P01-A03', 'BAI07-P01', 'Identificar y documentar los procesos de respaldo y recuperación.', 2, 'iTop by Combodo', 'Soporta la documentación de procedimientos clave en su CMDB, incluyendo planes de respaldo y recuperación.', 'Se pueden asociar documentos y configuraciones a elementos críticos de TI', '-'),

('BAI07-P01-A04', 'BAI07-P01', 'Confirmar que todos los planes de implementación estén aprobados por las partes interesadas técnicas y comerciales y revisados por auditoría interna, según corresponda.', 3, 'iTop by Combodo', 'Registra aprobaciones y responsables técnicos/comerciales en procesos de cambio e implementación. Auditoría de acciones incluida.', 'Capacidad de traza de aprobaciones y revisión interna', '-'),

('BAI07-P01-A05', 'BAI07-P01', 'Revise formalmente los riesgos técnicos y comerciales asociados con la implementación. Asegúrese de que el riesgo clave se considere y aborde en el proceso de planificación.', 3, 'Eramba', 'Plataforma especializada en gestión de riesgos. Permite identificar, documentar y hacer seguimiento de riesgos técnicos y de negocio.', 'Ideal para complementar la planificación con análisis formal de riesgos', '-'),

('BAI07-P02-A01', 'BAI07-P02', 'Defina un plan de migración de procesos de negocio, datos de servicios de I&T e infraestructura. Al desarrollar el plan, considere, por ejemplo, hardware, redes, sistemas operativos, software, datos de transacciones, archivos maestros, copias de seguridad y archivos, interfaces con otros sistemas (tanto internos como externos), posibles requisitos de cumplimiento, procedimientos de negocio y documentación del sistema.', 2, 'iTop by Combodo', 'Permite planificar cambios en infraestructura, servicios, software y relaciones. La CMDB y módulos de cambio soportan todas estas áreas.', 'Se puede planificar cada aspecto citado en la actividad', '-'),

('BAI07-P02-A02', 'BAI07-P02', 'En el plan de conversión de procesos de negocio, considere todos los ajustes necesarios a los procedimientos, incluidos los roles y responsabilidades revisados y los procedimientos de control.', 2, 'iTop by Combodo', 'Permite definir flujos de trabajo y roles involucrados en los procesos. Soporta gestión documental asociada a cada etapa.', 'Soporte total para procedimientos, revisión de roles/responsabilidades', '-'),

('BAI07-P02-A03', 'BAI07-P02', 'Confirme que el plan de conversión de datos no requiera cambios en los valores de los datos a menos que sea absolutamente necesario por razones comerciales. Documente los cambios realizados en los valores de los datos y obtenga la aprobación del responsable del proceso de negocio.', 2, 'iTop by Combodo', 'Documentación vinculada a procesos de conversión puede registrar excepciones aprobadas, incluyendo trazabilidad.', 'Puede documentarse la justificación del cambio con firmas y trazas', '-'),

('BAI07-P02-A04', 'BAI07-P02', 'Planifique la retención de datos de respaldo y archivados para cumplir con las necesidades comerciales y los requisitos regulatorios o de cumplimiento.', 2, 'Eramba', 'Eramba permite gestionar políticas de retención de información alineadas con normativas y riesgos regulatorios.', 'Soporta definición y seguimiento de retención y cumplimiento', '-'),

('BAI07-P02-A05', 'BAI07-P02', 'Ensaye y pruebe la conversión antes de intentar una conversión en vivo.', 2, 'Apache JMeter', 'Herramienta especializada para pruebas de carga y comportamiento, ideal para ensayos de conversión.', 'Permite simular conversiones para detectar errores previos', '-'),

('BAI07-P02-A06', 'BAI07-P02', 'Coordinar y verificar la sincronización y la integridad de la transición de conversión para que la transición sea fluida y continua, sin pérdida de datos de transacciones. De ser necesario, a falta de otra alternativa, congelar las operaciones activas.', 2, 'iTop by Combodo', 'Permite modelar servicios, dependencias y validar estado antes/durante la migración, con trazabilidad.', 'Puede registrar acciones sincronizadas y estados clave de transición', '-'),

('BAI07-P02-A07', 'BAI07-P02', 'Planifique realizar copias de seguridad de todos los sistemas y datos obtenidos antes de la conversión. Mantenga registros de auditoría para poder rastrear la conversión. Asegúrese de que exista un plan de recuperación que incluya la reversión de la migración y el retorno al procesamiento anterior en caso de que la migración falle.', 2, 'iTop by Combodo', 'iTop permite definir y documentar planes de respaldo y reversión; Zabbix garantiza monitoreo en tiempo real de la infraestructura antes/durante la conversión.', 'La combinación asegura planes documentados + monitoreo operacional', 'Zabbix'),

('BAI07-P02-A08', 'BAI07-P02', 'En el plan de conversión de datos, incorpore métodos para recopilar, convertir y verificar los datos que se convertirán, así como para identificar y corregir cualquier error detectado durante la conversión. Incluya la comparación de los datos originales y los convertidos para garantizar su integridad.', 3, 'iTop by Combodo', 'Permite registrar métodos, verificar la calidad del dato y registrar correcciones antes de cierre de cambio.', 'Se puede incluir como parte del plan de implementación', '-'),

('BAI07-P02-A09', 'BAI07-P02', 'Considere el riesgo de problemas de conversión, la planificación de la continuidad del negocio y los procedimientos de respaldo en el proceso de negocio, el plan de migración de datos e infraestructura donde haya gestión de riesgos, necesidades comerciales o requisitos regulatorios/de cumplimiento.', 3, 'Eramba', 'Eramba permite mapear y gestionar todos los riesgos asociados al proceso de conversión, incluyendo planes de mitigación.', 'Se alinea perfectamente con la gestión de continuidad y riesgos', '-'),

('BAI07-P03-A01', 'BAI07-P03', 'Desarrollar y documentar el plan de pruebas, que se ajuste al programa, al plan de calidad del proyecto y a los estándares organizacionales pertinentes. Comunicarse y consultar con los responsables de los procesos de negocio y las partes interesadas de TI correspondientes.', 2, 'iTop by Combodo', 'Permite documentar planes y relacionarlos con servicios, activos, procesos y partes interesadas. Soporta seguimiento colaborativo.', 'Puede personalizar flujos para aprobar planes con diferentes áreas', '-'),

('BAI07-P03-A02', 'BAI07-P03', 'Asegúrese de que el plan de pruebas refleje una evaluación de riesgos del proyecto y de que se prueben todos los requisitos funcionales y técnicos. Con base en la evaluación del riesgo de fallos del sistema y de fallas en la implementación, incluya en el plan requisitos de rendimiento, estrés, usabilidad, pruebas piloto, seguridad y privacidad.', 2, 'Apache JMeter', 'JMeter permite pruebas de rendimiento, estrés y carga; Eramba documenta riesgos de implementación y cumplimiento.', 'Cobertura completa si se combinan para pruebas + riesgos', 'Eramba'),

('BAI07-P03-A03', 'BAI07-P03', 'Asegúrese de que el plan de pruebas aborde la posible necesidad de acreditación interna o externa de los resultados del proceso de pruebas (por ejemplo, requisitos financieros o reglamentarios).', 2, 'iTop by Combodo', 'Permite registro de firmas, validaciones formales, adjuntos de informes certificados, y seguimiento del flujo de aprobación.', 'Admite documentos de acreditación formal firmados', '-'),

('BAI07-P03-A04', 'BAI07-P03', 'Asegúrese de que el plan de pruebas identifique los recursos necesarios para ejecutar las pruebas y evaluar los resultados. Algunos ejemplos de recursos pueden ser la construcción de entornos de prueba y el uso del tiempo del personal del grupo de pruebas, incluyendo la posible sustitución temporal del personal de pruebas en los entornos de producción o desarrollo. Asegúrese de consultar a las partes interesadas sobre las implicaciones del plan de pruebas en términos de recursos.', 2, 'iTop by Combodo', 'Permite registrar recursos asociados a tareas (personas, entornos), planificar uso de personal y ambientes de pruebas.', 'Soporta planificación de ambientes, tiempos, y personal asignado', '-'),

('BAI07-P03-A05', 'BAI07-P03', 'Asegúrese de que el plan de pruebas identifique las fases de prueba adecuadas a los requisitos operativos y al entorno. Ejemplos de estas fases de prueba incluyen pruebas unitarias, pruebas del sistema, pruebas de integración, pruebas de aceptación del usuario, pruebas de rendimiento, pruebas de estrés, pruebas de conversión de datos, pruebas de seguridad, pruebas de privacidad, pruebas de disponibilidad operativa y pruebas de respaldo y recuperación.', 2, 'Apache JMeter', 'JMeter cubre pruebas de rendimiento, estrés, integración; iTop permite definir y documentar fases y criterios de cada prueba.', 'Permiten trazabilidad de fases y resultados', 'Itop By Combodo'),

('BAI07-P03-A06', 'BAI07-P03', 'Confirme que el plan de pruebas considere la preparación de la prueba (incluida la preparación del sitio), los requisitos de capacitación, la instalación o actualización de un entorno de prueba definido, la planificación/ejecución/documentación/retención de casos de prueba, el manejo de errores y problemas, la corrección y escalada, y la aprobación formal.', 2, 'iTop by Combodo', 'Integra la documentación de cada paso: ambiente, errores, escalamiento, entrenamiento, y estado de aprobación formal.', 'Soporte total, incluyendo control de versiones y registros', '-'),

('BAI07-P03-A07', 'BAI07-P03', 'Confirme que todos los planes de prueba estén aprobados por las partes interesadas, incluyendo a los responsables de los procesos de negocio y al departamento de TI, según corresponda. Las partes interesadas pueden incluir a los responsables de desarrollo de aplicaciones, los gestores de proyectos y los usuarios finales de los procesos de negocio.', 2, 'iTop by Combodo', 'Permite circuitos de aprobación y firma de múltiples perfiles (TI, negocio, proyectos, etc.). Todo queda trazado.', 'Flujo configurable para distintos niveles de aprobación', '-'),

('BAI07-P03-A08', 'BAI07-P03', 'Asegúrese de que el plan de pruebas establezca criterios claros para medir el éxito de cada fase de prueba. Consulte con los responsables de los procesos de negocio y las partes interesadas de TI para definir los criterios de éxito. Asegúrese de que el plan establezca procedimientos de remediación cuando no se cumplan los criterios de éxito. Por ejemplo, si se produce una falla significativa en una fase de prueba, el plan debe indicar si se debe pasar a la siguiente fase, detener las pruebas o posponer la implementación.', 3, 'iTop by Combodo', 'Puede documentar criterios por cada fase, y condicionar el avance según resultados; incluye remediación y reintentos.', 'Flexibilidad total para manejar decisiones ante fallos', '-'),

('BAI07-P04-A01', 'BAI07-P04', 'Cree una base de datos de prueba representativa del entorno de producción. Depure los datos utilizados en el entorno de prueba del entorno de producción según las necesidades del negocio y los estándares de la organización. Por ejemplo, considere si los requisitos de cumplimiento o regulatorios exigen el uso de datos depurados.', 2, 'MySQL', 'Permite clonar bases de datos de producción, realizar anonimización de datos (mediante scripts), y aplicar reglas de limpieza según políticas internas.', 'Se requiere definir scripts personalizados para limpieza/anonymización', '-'),

('BAI07-P04-A02', 'BAI07-P04', 'Proteja los datos y resultados confidenciales de las pruebas contra su divulgación, incluyendo el acceso, la retención, el almacenamiento y la destrucción. Considere el efecto de la interacción de los sistemas de la organización con los de terceros.', 3, 'Proxmox', 'Proxmox aísla entornos de prueba; MySQL controla accesos con roles, cifrado y logs. Ambos permiten gestionar almacenamiento y retención.', 'Se recomienda cifrado de disco y aislamiento de red en Proxmox', 'MySQL'),

('BAI07-P04-A03', 'BAI07-P04', 'Implementar un proceso que permita la correcta conservación o eliminación de los resultados de las pruebas, los medios de prueba y demás documentación asociada, lo que facilitará su revisión y posterior análisis, o la repetición eficiente de las pruebas, según lo exija el plan de pruebas. Considerar el efecto de los requisitos regulatorios o de cumplimiento.', 3, 'iTop by Combodo', 'Permite documentar pruebas, adjuntar evidencias, definir reglas de retención y establecer flujos de eliminación con trazabilidad.', 'Asegura cumplimiento regulatorio y repetibilidad de pruebas', '-'),

('BAI07-P04-A04', 'BAI07-P04', 'Asegúrese de que el entorno de prueba sea representativo del futuro panorama empresarial y operativo. Incluya los procedimientos y roles de los procesos de negocio, la probable carga de trabajo, los sistemas operativos, el software de aplicación necesario, los sistemas de gestión de bases de datos y la infraestructura de red e informática del entorno de producción.', 3, 'Proxmox', 'Proxmox permite replicar el entorno operativo completo (OS, apps, red); Zabbix monitorea cargas y simula escenarios reales.', 'Replica entornos de producción y evalúa desempeño operativo', 'Zabbix'),

('BAI07-P04-A05', 'BAI07-P04', 'Asegúrese de que el entorno de prueba sea seguro y no pueda interactuar con los sistemas de producción.', 3, 'Proxmox', 'Aísla redes virtuales, máquinas y contenedores; permite definir entornos de prueba completamente separados de producción.', 'Soporte completo para aislamiento y pruebas seguras', '-'),

('BAI07-P05-A01', 'BAI07-P05', 'Revise el registro categorizado de errores detectados por el equipo de desarrollo durante el proceso de pruebas. Verifique que todos los errores se hayan corregido o aceptado formalmente.', 2, 'iTop by Combodo', 'Permite gestionar y categorizar errores, con trazabilidad, vinculación al historial de pruebas y aprobación de cierre.', 'Los errores pueden ser marcados como corregidos o aceptados', '-'),

('BAI07-P05-A02', 'BAI07-P05', 'Evalúe la aceptación final según los criterios de éxito e interprete los resultados de las pruebas de aceptación final. Preséntelos de forma comprensible para los responsables de los procesos de negocio y el departamento de TI, de modo que se pueda realizar una revisión y evaluación informadas.', 3, 'iTop by Combodo', 'iTop permite documentar criterios de éxito, informes y análisis para partes interesadas; GLPI puede reforzar presentación de reportes.', 'Adaptar dashboards e informes a stakeholders técnicos y de negocio', 'GLPI'),

('BAI07-P05-A03', 'BAI07-P05', 'Aprobar la aceptación, con la firma formal de los propietarios del proceso de negocio, terceros (según corresponda) y las partes interesadas de TI antes de la promoción.', 3, 'iTop by Combodo', 'Soporta la validación formal de entregables y aprobación de pruebas por partes interesadas, con firma electrónica o validación por flujo.', 'Registrar fecha y responsables del cierre de pruebas', '-'),

('BAI07-P05-A04', 'BAI07-P05', 'Asegúrese de que las pruebas de los cambios se realicen de acuerdo con el plan de pruebas. Asegúrese de que las pruebas sean diseñadas y realizadas por un grupo de pruebas independiente del equipo de desarrollo. Considere el grado de participación de los responsables de los procesos de negocio y los usuarios finales en el grupo de pruebas. Asegúrese de que las pruebas se realicen únicamente dentro del entorno de pruebas.', 3, 'Proxmox', 'Permite la creación de entornos virtuales completamente aislados, operados por personal ajeno al desarrollo.', 'Control de acceso separado por grupo de usuario', '-'),

('BAI07-P05-A05', 'BAI07-P05', 'Asegúrese de que las pruebas y los resultados previstos estén de acuerdo con los criterios de éxito definidos en el plan de pruebas.', 3, 'iTop by Combodo', 'Documentación de criterios, vinculación a scripts y evidencias de pruebas exitosas.', 'Integración con módulos de pruebas planificadas', '-'),

('BAI07-P05-A06', 'BAI07-P05', 'Considere usar instrucciones de prueba claramente definidas (scripts) para implementar las pruebas. Asegúrese de que el grupo de pruebas independiente evalúe y apruebe cada script para confirmar que cumple adecuadamente los criterios de éxito establecidos en el plan de pruebas. Considere usar scripts para verificar el grado de cumplimiento del sistema con los requisitos de seguridad y privacidad.', 3, 'Apache JMeter', 'Soporta ejecución de scripts, validación automatizada de funcionalidades y seguridad; los scripts se pueden revisar manualmente.', 'Se recomienda control de versiones de scripts', '-'),

('BAI07-P05-A07', 'BAI07-P05', 'Considere el equilibrio apropiado entre las pruebas automatizadas con scripts y las pruebas de usuario interactivas.', 3, 'Apache JMeter', 'Permite ejecutar pruebas automatizadas; resultados y pruebas manuales pueden registrarse en GLPI/iTop para balancear ambas.', 'Establecer criterios de uso mixto según el tipo de prueba', '-'),

('BAI07-P05-A08', 'BAI07-P05', 'Realice pruebas de seguridad de acuerdo con el plan de pruebas. Mida el alcance de las debilidades o vulnerabilidades de seguridad. Considere el efecto de los incidentes de seguridad desde la elaboración del plan de pruebas. Considere el efecto en los controles de acceso y límites. Considere la privacidad.', 3, 'Owasp ZAP', 'Realiza análisis de seguridad automatizados, identifica vulnerabilidades, evalúa privacidad y límites de acceso.', 'Informes detallados exportables y trazables', '-'),

('BAI07-P05-A09', 'BAI07-P05', 'Realice pruebas de rendimiento del sistema y de la aplicación según el plan de pruebas. Considere diversas métricas de rendimiento (p. ej., tiempos de respuesta del usuario final y rendimiento de las actualizaciones del sistema de gestión de bases de datos).', 3, 'Apache JMeter', 'Ejecuta pruebas de rendimiento de servicios, sistemas y bases de datos. Soporta métricas de respuesta, carga y estrés.', 'Resultados exportables para informes', '-'),

('BAI07-P05-A10', 'BAI07-P05', 'Al realizar pruebas, asegúrese de que se hayan abordado los elementos de respaldo y reversión del plan de pruebas.', 3, 'iTop by Combodo', 'iTop documenta planes de reversión y respaldo; Proxmox permite snapshots y restauración inmediata de entornos.', 'Se recomienda práctica previa de recuperación', 'Proxmox'),

('BAI07-P05-A11', 'BAI07-P05', 'Identificar, registrar y clasificar errores (p. ej., menores, significativos, críticos) durante las pruebas. Asegurarse de que exista un registro de auditoría de los resultados de las pruebas. De acuerdo con el plan de pruebas, comunicar los resultados de las pruebas a las partes interesadas para facilitar la corrección de errores y la mejora de la calidad.', 3, 'iTop by Combodo', 'Gestión completa de errores por categoría (menores, críticos), trazabilidad de pruebas y comunicación automática a stakeholders.', 'Registro de auditoría activado por defecto', '-'),

('BAI07-P06-A01', 'BAI07-P06', 'Prepararse para la transferencia de procedimientos comerciales y servicios de soporte, aplicaciones e infraestructura desde el entorno de pruebas al entorno de producción de acuerdo con los estándares de gestión de cambios organizacionales.', 2, 'iTop by Combodo', 'Gestiona fases de transferencia bajo procesos controlados y estándares ITIL, soporta planes de cambio organizacional y documentación.', 'Soporta aprobaciones antes de la promoción', '-'),

('BAI07-P06-A02', 'BAI07-P06', 'Determinar el alcance de la implementación piloto o el procesamiento paralelo de los sistemas antiguos y nuevos de acuerdo con el plan de implementación.', 2, 'Proxmox', 'Permite desplegar ambientes paralelos o pilotos controlados sin afectar producción. Se pueden replicar entornos con snapshots y clones.', 'Ideal para entornos de prueba paralela con control de versiones', '-'),

('BAI07-P06-A03', 'BAI07-P06', 'Actualizar rápidamente la documentación del sistema y de los procesos de negocio pertinentes, la información de configuración y los documentos del plan de contingencia, según corresponda.', 2, 'iTop by Combodo', 'Administra documentación relacionada a servicios, CI (Configuration Items) y planes de contingencia actualizados en cada ciclo.', 'Vincula cambios a documentación específica por versión', '-'),

('BAI07-P06-A04', 'BAI07-P06', 'Asegúrese de que todas las bibliotecas de medios se actualicen puntualmente con la versión del componente de la solución que se transfiere del entorno de pruebas al de producción. Archive la versión existente y su documentación de soporte. Asegúrese de que la promoción a producción de los sistemas, el software de aplicación y la infraestructura esté bajo control de configuración.', 2, 'iTop by Combodo', 'Administra versiones de configuración, control de cambios, archivos de soporte y rollback. Gestión completa de versiones de CI.', 'Compatible con ciclos DevOps e ITIL', '-'),

('BAI07-P06-A05', 'BAI07-P06', 'Cuando la distribución de componentes de la solución se realice electrónicamente, se debe controlar la distribución automatizada para garantizar que los usuarios sean notificados y que la distribución se realice únicamente a los destinatarios autorizados y correctamente identificados. Durante el proceso de lanzamiento, se deben incluir procedimientos de respaldo para permitir la revisión de la distribución de cambios en caso de fallo o error.', 2, 'GLPI', 'GLPI puede notificar a usuarios; iTop controla distribución de cambios automatizada bajo usuarios autorizados. Se puede registrar fallos o errores.', 'Asegurar que distribución esté asociada a roles definidos', 'ITop'),

('BAI07-P06-A06', 'BAI07-P06', 'Cuando la distribución tome forma física, mantenga un registro formal de qué artículos se han distribuido, a quién, dónde se han implementado y cuándo se ha actualizado cada uno.', 2, 'iTop by Combodo', 'Permite registrar elementos distribuidos, responsables, ubicación e historial. Cada entrega queda documentada como ítem de configuración.', 'Puede automatizarse mediante campos personalizados', '-'),

('BAI07-P07-A01', 'BAI07-P07', 'Proporcionar recursos adicionales, según sea necesario, a los usuarios finales y al personal de soporte hasta que la versión se haya estabilizado.', 3, 'Zammad', 'Permite escalar soporte de primer nivel con SLAs, asignación de técnicos y categorización de incidentes durante el periodo de estabilización.', 'Permiten medir carga y reasignar según demanda', '-'),

('BAI07-P07-A02', 'BAI07-P07', 'Proporcionar recursos de sistemas de I&T adicionales, según sea necesario, hasta que la versión se encuentre en un entorno operativo estable.', 3, 'Proxmox', 'Permite escalar infraestructura bajo demanda, crear nodos o réplicas del sistema en caliente para balancear carga y estabilizar.', 'Compatible con entornos redundantes y HA', '-'),

('BAI07-P08-A01', 'BAI07-P08', 'Establecer procedimientos para garantizar que las revisiones posteriores a la implementación identifiquen, evalúen e informen en qué medida se han producido los siguientes eventos: se han cumplido los requisitos de la empresa; se han obtenido los beneficios esperados; el sistema se considera utilizable; se han cumplido las expectativas de las partes interesadas internas y externas; se han producido impactos inesperados en la empresa; se ha mitigado el riesgo clave; y los procesos de gestión de cambios, instalación y acreditación se han realizado de forma eficaz y eficiente.', 3, 'iTop by Combodo', 'Administra flujos personalizados para revisiones post-implementación, checklist de criterios, indicadores y reporte estructurado.', 'Se puede diseñar plantilla estándar de revisión', '-'),

('BAI07-P08-A02', 'BAI07-P08', 'Consultar a los propietarios de procesos de negocio y a la gerencia técnica de TI en la elección de métricas para medir el éxito y el logro de requisitos y beneficios.', 4, 'iTop by Combodo', 'Posibilita interacción con stakeholders a través de tickets de validación y flujos de aprobación. Se pueden definir campos personalizados para registrar métricas.', 'Admite input multiactor, cada métrica asociada a criterio claro', '-'),

('BAI07-P08-A03', 'BAI07-P08', 'Realice la revisión posterior a la implementación de acuerdo con el proceso de gestión del cambio organizacional. Involucre a los responsables de los procesos de negocio y a terceros, según corresponda.', 4, 'iTop by Combodo', 'Integrado con gestión de cambios organizacionales. Se pueden incluir partes internas y externas como actores clave en el flujo.', 'Incluye aprobaciones formales y evidencia documentada', '-'),

('BAI07-P08-A04', 'BAI07-P08', 'Considere los requisitos de revisión posterior a la implementación que surgen de áreas externas del negocio y de TI (por ejemplo, auditoría interna, ERM, cumplimiento).', 4, 'Eramba', 'Incluye módulo específico de gestión de cumplimiento, gestión de auditorías y gestión de riesgos corporativos.', 'Revisión puede ser estructurada y trazable', '-'),

('BAI07-P08-A05', 'BAI07-P08', 'Acordar e implementar un plan de acción para abordar los problemas identificados en la revisión posterior a la implementación. Involucrar a los responsables de los procesos de negocio y a la dirección técnica de TI en el desarrollo del plan de acción.', 5, 'GLPI', 'GLPI gestiona el plan de acción como tareas o proyectos vinculados a findings; iTop permite relacionarlos al cambio original y medir su estado.', 'El plan queda documentado, asignado y trazado', 'Itop'),

('BAI08-P01-A01', 'BAI08-P01', 'Identificar a los posibles usuarios del conocimiento, incluyendo a los propietarios de información que puedan necesitar contribuir y aprobar el conocimiento. Obtener los requisitos de conocimiento y las fuentes de información de los usuarios identificados.', 2, 'Huginn', 'Permite crear agentes que recolectan información y envían notificaciones a usuarios definidos', 'Puede integrarse con directorios de usuarios o fuentes de datos externas', 'Webhooks, APIs, servicios de correo y mensajería (Telegram, Slack)'),

('BAI08-P01-A02', 'BAI08-P01', 'Considere los tipos de contenido (procedimientos, procesos, estructuras, conceptos, políticas, reglas, hechos, clasificaciones), artefactos (documentos, registros, video, voz) e información estructurada y no estructurada (expertos, redes sociales, correo electrónico, correo de voz, feeds Rich Site Summary (RSS)).', 2, 'Huginn', 'Admite entradas de múltiples formatos: texto, audio, video, RSS, email, APIs, redes sociales', 'Flexible para monitorear múltiples canales en paralelo', 'Integra fácilmente con fuentes externas y sistemas de almacenamiento'),

('BAI08-P01-A03', 'BAI08-P01', 'Clasifique las fuentes de información según un esquema de clasificación de contenido (p. ej., un modelo de arquitectura de la información). Asocie las fuentes de información al esquema de clasificación.', 3, 'Huginn', 'Puede categorizar la información con lógica condicional y flujos de trabajo personalizados', 'No usa taxonomías estándar, pero es altamente personalizable', 'Puede conectarse con herramientas de documentación como GitHub o bases de datos'),

('BAI08-P01-A04', 'BAI08-P01', 'Recopilar, cotejar y validar fuentes de información basándose en criterios de validación de información (por ejemplo, comprensibilidad, relevancia, importancia, integridad, exactitud, consistencia, confidencialidad, actualidad y confiabilidad).', 4, 'Huginn', 'Configurable para validar criterios como frecuencia, consistencia, actualidad mediante flujos', 'Depende del usuario configurar los criterios, pero es totalmente viable', 'Compatible con bases de datos, correo y herramientas de reporting'),

('BAI08-P02-A01', 'BAI08-P02', 'Identificar atributos compartidos y relacionar fuentes de información, creando relaciones entre conjuntos de información (etiquetado de información).', 3, 'GitHub', 'Permite usar etiquetas (labels), issues vinculados, pull requests relacionados y wikis para relacionar conjuntos de información', 'Requiere estructurar el repositorio con buenas prácticas de documentación', 'Alta integración con herramientas como Git, GitLab, n8n, Jira, etc.'),

('BAI08-P02-A02', 'BAI08-P02', 'Crear vistas de conjuntos de datos relacionados, teniendo en cuenta los requisitos de las partes interesadas y de la organización.', 3, 'GitHub', 'Se pueden usar Boards, Projects y filtros para crear vistas específicas de conjuntos de conocimiento según interés', 'Adaptable a las necesidades de diferentes stakeholders', 'Compatible con dashboards externos (ex. Grafana, Notion, etc.)'),

('BAI08-P02-A03', 'BAI08-P02', 'Diseñar e implementar un esquema para gestionar el conocimiento no estructurado que no está disponible a través de fuentes formales (por ejemplo, el conocimiento de expertos).', 3, 'GitHub', 'A través de Wikis, README, Issues, Discussions y repositorios de documentación colaborativa, se gestiona información tácita y explícita', 'Fomenta documentación viva y participación activa de expertos', 'Integrable con servicios de documentación (ex. MkDocs, Docusaurus)'),

('BAI08-P02-A04', 'BAI08-P02', 'Publicar y hacer accesible el conocimiento a las partes interesadas relevantes, según los roles y los mecanismos de acceso.', 3, 'GitHub', 'Permite gestionar permisos por repositorio, organización y equipo; se pueden controlar accesos y publicar como página web (GitHub Pages)', 'Control de acceso granular y visibilidad pública/privada', 'Integra con SSO, sistemas CI/CD, foros y plataformas de soporte'),

('BAI08-P03-A01', 'BAI08-P03', 'Establecer expectativas de gestión y demostrar una actitud adecuada respecto a la utilidad del conocimiento y la necesidad de compartir conocimientos relacionados con la gobernanza y la gestión de la I&T empresarial.', 2, 'Moodle', 'Permite establecer expectativas a través de cursos formativos, foros de discusión y encuestas sobre políticas y prácticas de gobernanza.', 'Se pueden crear cursos temáticos sobre gobernanza I&T y recursos institucionales.', 'Puede integrarse con herramientas como GitHub, GLPI o Zoho para compartir conocimiento contextual.'),

('BAI08-P03-A02', 'BAI08-P03', 'Identificar usuarios potenciales del conocimiento mediante la clasificación del conocimiento.', 2, 'Moodle', 'Permite segmentar usuarios por roles, grupos y niveles, además de clasificar los contenidos mediante categorías, etiquetas y competencias.', 'La plataforma facilita la asignación de contenidos personalizados según perfiles.', 'Compatible con sistemas de directorio como LDAP o Apache Syncope.'),

('BAI08-P03-A03', 'BAI08-P03', 'Transferir conocimiento a los usuarios, basándose en un análisis de las brechas de necesidades y técnicas de aprendizaje eficaces. Crear un entorno, herramientas y artefactos que faciliten el intercambio y la transferencia de conocimiento. Garantizar la implementación de controles de acceso adecuados, de acuerdo con la clasificación de conocimiento definida.', 3, 'Moodle', 'Diseñado para facilitar el aprendizaje activo, control de acceso basado en rol y múltiples recursos multimedia y colaborativos.', 'Ofrece trazabilidad y seguimiento del proceso de transferencia de conocimiento.', 'Integra con herramientas de autenticación y otras plataformas vía LTI o APIs.'),

('BAI08-P03-A04', 'BAI08-P03', 'Medir el uso de herramientas y elementos de conocimiento y evaluar el impacto en los procesos de gobernanza.', 4, 'Moodle', 'Registra actividad de usuarios, uso de recursos, participación en foros, y permite aplicar encuestas para evaluar impacto.', 'Puede exportar datos para análisis externo o integrarse con herramientas BI.', 'Integrable con herramientas analíticas como Metabase o Power BI mediante conectores.'),

('BAI08-P03-A05', 'BAI08-P03', 'Mejorar la información y el conocimiento de los procesos de gobernanza que presentan brechas de conocimiento.', 5, 'Moodle', 'Facilita la retroalimentación de usuarios, adaptación de contenidos, y creación continua de nuevos materiales según necesidades detectadas.', 'Favorece la mejora continua del conocimiento a través de ciclos de evaluación y adaptación.', 'Puede integrarse con herramientas como GLPI o Eramba para detectar brechas desde operaciones.'),

('BAI08-P04-A01', 'BAI08-P04', 'Defina los controles para el retiro de conocimiento y retire el conocimiento en consecuencia.', 3, 'Moodle', 'Permite definir políticas de acceso y control de contenido obsoleto, así como la gestión del retiro de cursos y materiales antiguos.', 'Permite archivar y retirar material obsoleto basado en reglas definidas por el administrador.', 'Puede integrarse con sistemas de almacenamiento externo o herramientas de archivado.'),

('BAI08-P04-A02', 'BAI08-P04', 'Evaluar la utilidad, relevancia y valor de los elementos de conocimiento. Actualizar la información obsoleta que aún sea relevante y valiosa para la organización. Identificar la información relacionada que ya no sea relevante para las necesidades de conocimiento de la empresa y retirarla o archivarla según la política.', 4, 'Moodle', 'Ofrece herramientas para evaluar la relevancia de los contenidos mediante encuestas, foros y el uso de informes detallados sobre la actividad de los usuarios.', 'Permite actualizar contenido y retirar materiales que ya no sean necesarios.', 'Integración con sistemas de evaluación de desempeño, como GLPI o Jira, para evaluar el impacto de la información.'),

('BAI09-P01-A01', 'BAI09-P01', 'Identifique todos los activos propios en un registro de activos que registre su estado actual. Los activos se reportan en el balance general; se compran o crean para aumentar el valor de una empresa o para beneficiar sus operaciones (por ejemplo, hardware y software). Identifique todos los activos propios y manténgalos alineados con los procesos de gestión de cambios y gestión de la configuración, el sistema de gestión de la configuración y los registros contables.', 2, 'SnipeIT', 'Permite registrar activos con estado actual, historial de cambios, responsable, ubicación y más', 'Soporta etiquetas QR, auditoría, categorías y relaciones', 'Puede integrarse con OpenAudIT para detección automática o con GLPI para gestión de incidencias'),

('BAI09-P01-A02', 'BAI09-P01', 'Identificar los requisitos legales, reglamentarios o contractuales que deben abordarse al gestionar el activo.', 2, 'SnipeIT', 'Permite campos personalizados para registrar información legal y contractual relevante', 'Requiere definición de políticas organizacionales dentro de los formularios', 'Integrable con herramientas de cumplimiento como Eramba o Wazuh'),

('BAI09-P01-A03', 'BAI09-P01', 'Verificar que los activos sean aptos para el propósito (es decir, que estén en condiciones útiles).', 2, 'SnipeIT', 'El historial y el estado de los activos permite verificar su condición y utilidad', 'Se pueden usar etiquetas y políticas para marcar activos con fallos o en revisión', 'Posible integración con Zabbix o TacticalRMM para monitoreo de salud'),

('BAI09-P01-A04', 'BAI09-P01', 'Garantizar la contabilidad de todos los activos.', 3, 'SnipeIT', 'Ofrece exportación detallada y seguimiento financiero de activos (costo, depreciación, etc.)', 'Compatible con políticas contables si se parametriza correctamente', 'Puede integrarse con ERP como Apache OFBiz o soluciones contables externas'),

('BAI09-P01-A05', 'BAI09-P01', 'Verificar la existencia de todos los activos propios mediante la realización periódica de comprobaciones físicas y lógicas de inventario y su conciliación. Incluir el uso de herramientas de detección de software.', 4, 'SnipeIT', 'SnipeIT permite mantener un inventario centralizado de hardware y software, realizar auditorías de activos y llevar trazabilidad de asignaciones. Su API e integraciones permiten complementarlo con agentes de detección automática (ej. OCS Inventory), facilitando la verificación periódica y conciliación entre inventario físico y lógico.', 'SnipeIT por sí solo no detecta software instalado en los equipos, pero su fortaleza está en el control documental, trazabilidad y auditoría de inventario. Se recomienda integrarlo con un agente de descubrimiento (OCS/FusionInventory) para cubrir la detección automática de software y cumplir plenamente la actividad.', 'API para integraciones con detectores automáticos.'),

('BAI09-P01-A06', 'BAI09-P01', 'Determine periódicamente si cada activo continúa aportando valor. De ser así, calcule la vida útil esperada para que siga aportando valor.', 4, 'SnipeIT', 'Incluye campos de costo, fecha de adquisición y depreciación, lo cual permite cálculos de valor residual', 'Las políticas de depreciación deben ser definidas según normativa interna', 'Puede exportarse para análisis financiero externo'),

('BAI09-P02-A01', 'BAI09-P02', 'Identificar los activos que son críticos para brindar capacidad de servicio haciendo referencia a los requisitos en las definiciones de servicio, los SLA y el sistema de gestión de la configuración.', 2, 'Zabbix', 'Permite definir activos y monitorearlos según parámetros de criticidad y SLAs.', 'Se pueden etiquetar activos como críticos y agruparlos.', 'Puede integrarse con GLPI, iTop, SnipeIT, OpenAudIT.'),

('BAI09-P02-A02', 'BAI09-P02', 'Considere periódicamente el riesgo de falla o la necesidad de reemplazo de cada activo crítico.', 2, 'Zabbix', 'Monitorea rendimiento, alertas de fallas y eventos históricos.', 'Proporciona evaluaciones basadas en comportamiento histórico.', 'Compatible con OSQuery, Wazuh para ampliar análisis de riesgo.'),

('BAI09-P02-A03', 'BAI09-P02', 'Comunicar a los clientes y usuarios afectados el impacto esperado (por ejemplo, restricciones de rendimiento) de las actividades de mantenimiento.', 2, 'Zabbix', 'Permite configurar mensajes automáticos y alertas a usuarios sobre eventos o mantenimientos.', 'Soporta notificaciones por correo, Slack, SMS, etc.', 'Integrable con herramientas de helpdesk como GLPI, Zammad.'),

('BAI09-P02-A04', 'BAI09-P02', 'Incorpore el tiempo de inactividad planificado en un programa general de producción. Programe las actividades de mantenimiento para minimizar el impacto negativo en los procesos de negocio.', 3, 'Zabbix', 'Configura ventanas de mantenimiento con calendario y niveles de impacto.', 'Incluye informes de mantenimiento planificado vs real.', 'Puede integrarse con herramientas de gestión de proyectos como Zoho Projects.'),

('BAI09-P02-A05', 'BAI09-P02', 'Mantener la resiliencia de los activos críticos mediante el mantenimiento preventivo regular. Supervisar el rendimiento y, de ser necesario, proporcionar activos alternativos o adicionales para minimizar la probabilidad de fallos.', 3, 'Zabbix', 'Monitoreo constante y detección temprana de fallos; puede activar alertas para prevenir interrupciones.', 'Permite acciones automáticas para minimizar fallos.', 'Integra con sistemas como TacticalRMM o n8n para respuestas automatizadas.'),

('BAI09-P02-A06', 'BAI09-P02', 'Establecer un plan de mantenimiento preventivo para todo el hardware, considerando el análisis de costo/beneficio, recomendaciones de proveedores, riesgo de interrupción, personal calificado y otros factores relevantes.', 3, 'Tactical RMM', 'Permite crear scripts y tareas programadas para mantenimiento preventivo.', 'Permite definir políticas personalizadas según tipo de hardware y prioridad.', 'Integrable con GLPI para gestión de inventario y Zabbix para alertas de monitoreo.'),

('BAI09-P02-A07', 'BAI09-P02', 'Establecer acuerdos de mantenimiento que permitan el acceso de terceros a las instalaciones de I&T de la organización para actividades in situ y externas (p. ej., externalización). Establecer contratos de servicio formales que incluyan o hagan referencia a todas las condiciones de seguridad y privacidad necesarias, incluyendo los procedimientos de autorización de acceso, para garantizar el cumplimiento de las políticas y estándares de seguridad y privacidad de la organización.', 3, 'Tactical RMM', 'Permite documentar y ejecutar procesos bajo políticas de acceso y mantenimiento remoto seguros.', 'Los procedimientos de acceso están controlados por autenticación multifactor y logs de acceso.', 'Complementable con Wazuh para control de cumplimiento y seguridad.'),

('BAI09-P02-A08', 'BAI09-P02', 'Asegúrese de que los servicios de acceso remoto y los perfiles de usuario (u otros medios utilizados para mantenimiento o diagnóstico) estén activos solo cuando sea necesario.', 3, 'Tactical RMM', 'Habilita sesiones remotas bajo demanda, con control total del tiempo de actividad.', 'Control total sobre la activación temporal de servicios de soporte remoto.', 'Puede integrarse con OSQuery para validación en tiempo real de estado del sistema.'),

('BAI09-P02-A09', 'BAI09-P02', 'Supervise el rendimiento de los activos críticos examinando las tendencias de incidentes. De ser necesario, tome medidas para repararlos o reemplazarlos.', 4, 'Tactical RMM', 'Monitorea eventos, errores y alertas mediante logs y patrones de comportamiento.', 'Permite programar alertas inteligentes y asociarlas con procesos correctivos automáticos.', 'Integrable con Zabbix para dashboards y GLPI para generación de tickets.'),

('BAI09-P03-A01', 'BAI09-P03', 'Adquirir todos los activos según las solicitudes aprobadas y de acuerdo con las políticas y prácticas de adquisiciones de la empresa.', 2, 'GLPI', 'Permite gestionar solicitudes de compra aprobadas desde el módulo de Helpdesk y compras', 'Permite validar solicitudes antes de la adquisición', 'Compatible con ERPs mediante plugins o API REST'),

('BAI09-P03-A02', 'BAI09-P03', 'Obtener, recibir, verificar, probar y registrar todos los activos de manera controlada, incluido el etiquetado físico según sea necesario.', 2, 'GLPI', 'Facilita la recepción y validación de activos mediante formularios de recepción y registro', 'Soporta etiquetado físico y asignación de código de barras', 'Puede integrarse con OpenAudIT o FusionInventory'),

('BAI09-P03-A03', 'BAI09-P03', 'Aprobar los pagos y completar el proceso con los proveedores de acuerdo a las condiciones contractuales acordadas.', 2, 'GLPI', 'Maneja flujos de aprobación y registro de proveedores, no ejecuta pagos directamente', 'Permite seguimiento contractual pero requiere integración externa para pagos', 'Puede integrarse con herramientas contables o ERP vía API'),

('BAI09-P03-A04', 'BAI09-P03', 'Implementar activos siguiendo el ciclo de vida de implementación estándar, incluida la gestión de cambios y las pruebas de aceptación.', 3, 'GLPI', 'Ofrece procesos de implementación con flujos de cambio, aceptación y pruebas', 'Incluye fases de cambio y aceptación', 'Puede integrarse con herramientas como Ansible para despliegues'),

('BAI09-P03-A05', 'BAI09-P03', 'Asignar activos a los usuarios, con aceptación de responsabilidades y aprobación, según corresponda.', 3, 'GLPI', 'Gestiona la asignación formal de activos a usuarios con registros y aceptación', 'Genera trazabilidad de activos asignados', 'Integración con Directorios Activos o SSO'),

('BAI09-P03-A06', 'BAI09-P03', 'Siempre que sea posible, reasigne los activos cuando ya no sean necesarios debido a un cambio de rol del usuario, redundancia dentro de un servicio o retiro de un servicio.', 3, 'GLPI', 'Permite reasignar activos mediante el módulo de inventario y cambiar el propietario o la unidad asignada', 'Ofrece trazabilidad completa de reasignaciones, con histórico de movimientos', 'Se puede integrar con Active Directory (AD) o LDAP para gestión de usuarios'),

('BAI09-P03-A07', 'BAI09-P03', 'Planificar, autorizar e implementar actividades relacionadas con la jubilación, conservando registros adecuados para satisfacer las necesidades comerciales y regulatorias actuales.', 3, 'GLPI', 'Gestiona el ciclo de vida del activo, incluyendo su planificación para retiro con estados y flujos de validación', 'Puede registrar fecha de retiro y motivo, y adjuntar documentación', 'Compatible con plugins de auditoría y retención documental'),

('BAI09-P03-A08', 'BAI09-P03', 'Disponer de los activos de forma segura, considerando, por ejemplo, la eliminación permanente de cualquier dato grabado en dispositivos multimedia y los posibles daños al medio ambiente.', 3, 'GLPI', 'Permite registrar procedimientos de disposición segura e incluir verificación de borrado de datos', 'La eliminación física o lógica debe ser registrada manualmente como evidencia', 'Puede integrarse con herramientas de borrado seguro como DBAN (registrando reportes)'),

('BAI09-P03-A09', 'BAI09-P03', 'Disponer responsablemente de los activos cuando no tengan ninguna utilidad debido al retiro de todos los servicios relacionados, tecnología obsoleta o falta de usuarios en relación con el impacto ambiental.', 4, 'GLPI', 'Documenta la disposición final con justificación, responsable y registros ambientales o legales asociados', 'Permite asociar al activo un proveedor de disposición o reciclaje y documentos soporte', 'Compatible con integración con ERPs o gestores documentales externos'),

('BAI09-P04-A01', 'BAI09-P04', 'Revise periódicamente la base general de activos, considerando si está alineada con los requisitos del negocio.', 3, 'Ralph', 'Ralph permite gestionar y revisar continuamente la base de activos (servidores, racks, centros de datos, software, IPs) con actualizaciones periódicas.', 'Permite ver estado, ubicación, y cambios por usuario y tiempo.', 'Puede integrarse con GLPI o Zabbix para ampliar funcionalidades.'),

('BAI09-P04-A02', 'BAI09-P04', 'Evalúe los costos de mantenimiento, considere la viabilidad e identifique opciones de menor costo. Incluya, cuando sea necesario, la sustitución por nuevas alternativas.', 4, 'Ralph', 'Incorpora información de costos operativos y permite asociar activos con contratos, garantizando trazabilidad.', 'Requiere disciplina en el ingreso de datos financieros para análisis efectivos.', 'Puede apoyarse con informes exportados a herramientas de BI.'),

('BAI09-P04-A03', 'BAI09-P04', 'Revise las garantías y considere la relación precio-calidad y las estrategias de reemplazo para determinar las opciones de menor costo.', 5, 'Ralph', 'Soporta seguimiento de fechas de vencimiento de garantías, contratos de soporte y ciclo de vida de equipos.', 'Se puede configurar notificaciones por vencimientos.', 'Integración opcional con sistemas de ticketing como Znuny o GLPI.'),

('BAI09-P04-A04', 'BAI09-P04', 'Utilice estadísticas de capacidad y utilización para identificar activos subutilizados o redundantes que podrían considerarse para su eliminación o reemplazo para reducir costos.', 5, 'Ralph', 'Zabbix permite monitorear el uso en tiempo real de CPU, RAM, red y disco de los activos, útil para detectar subutilización.', 'Ralph no realiza esta función directamente.', 'Integración directa con Ralph mediante plugins o scripts para enriquecer CMDB.'),

('BAI09-P04-A05', 'BAI09-P04', 'Revisar la base general para identificar oportunidades de estandarización, abastecimiento único y otras estrategias que puedan reducir los costos de adquisición, soporte y mantenimiento.', 5, 'Ralph', 'Permite visualizar tipos, modelos y fabricantes de activos para identificar duplicación, estandarización o consolidación.', 'Muy útil en estrategias de reducción de proveedores y modelos.', 'Exportación de datos a herramientas como Excel, BI o integraciones con iTop.'),

('BAI09-P04-A06', 'BAI09-P04', 'Revisar el estado general para identificar oportunidades para aprovechar tecnologías emergentes o estrategias de abastecimiento alternativas para reducir costos o aumentar la relación calidad-precio.', 5, 'Ralph', 'La trazabilidad histórica de tecnologías y capacidad de documentación permiten comparar activos antiguos vs. nuevos.', 'No identifica tendencias automáticamente; depende del análisis del administrador.', 'Complementable con Huginn o n8n para automatizar alertas sobre novedades.'),

('BAI09-P05-A01', 'BAI09-P05', 'Mantener un registro de todas las licencias de software adquiridas y los acuerdos de licencia asociados.', 2, 'OpenAudIT', 'OpenAudIT permite registrar software detectado automáticamente y agregar detalles de licenciamiento, como claves, fechas y contratos.', 'Se puede ampliar la base con información de contratos cargada manualmente o mediante scripts.', 'Puede integrarse con GLPI para extender la gestión documental.'),

('BAI09-P05-A02', 'BAI09-P05', 'Realice periódicamente una auditoría para identificar todas las instancias de software con licencia instalado.', 3, 'OpenAudIT', 'Realiza escaneos automáticos o programados para descubrir software instalado en todos los dispositivos conectados.', 'Compatible con redes grandes y diversas plataformas (Windows, Linux).', 'Puede complementarse con OSQuery o Wazuh para análisis adicionales.'),

('BAI09-P05-A03', 'BAI09-P05', 'Compare el número de instancias de software instaladas con el número de licencias que posee. Asegúrese de que el método de medición del cumplimiento de licencias cumpla con los requisitos contractuales y de licencia.', 4, 'OpenAudIT', 'Ofrece reportes detallados comparativos entre software instalado y licencias registradas.', 'Los informes ayudan a identificar sobreuso o subutilización de licencias.', 'Exportación de datos compatible con GLPI, Zabbix y otros.'),

('BAI09-P05-A04', 'BAI09-P05', 'Cuando el número de instancias sea menor al número propio, decida si es necesario conservar o rescindir las licencias, teniendo en cuenta el potencial de ahorrar en mantenimiento innecesario, capacitación y otros costos.', 4, 'OpenAudIT', 'Permite ver licencias no utilizadas y facilita decisiones estratégicas.', 'Ayuda a reducir costos innecesarios.', 'Puede conectarse con soluciones ERP como Apache OFBiz para impacto financiero.'),

('BAI09-P05-A05', 'BAI09-P05', 'Cuando el número de instancias sea superior al actual, considere primero la oportunidad de desinstalar las instancias que ya no sean necesarias o justificadas y luego, si es necesario, compre licencias adicionales para cumplir con el acuerdo de licencia.', 4, 'OpenAudIT', 'Informa de posibles violaciones y propone acciones correctivas.', 'Genera alertas personalizadas.', 'Integrable con herramientas de automatización como n8n.'),

('BAI09-P05-A06', 'BAI09-P05', 'Considere periódicamente si se puede obtener un mejor valor actualizando los productos y las licencias asociadas.', 5, 'OpenAudIT', 'Proporciona visibilidad sobre versiones antiguas y nuevas disponibles.', 'Facilita decisiones sobre renovación o actualización de software.', 'Puede combinarse con bases de datos externas de precios/licencias.'),

('BAI10-P01-A01', 'BAI10-P01', 'Definir y acordar el alcance y el nivel de detalle para la gestión de la configuración (es decir, qué servicios, activos y elementos configurables de infraestructura incluir).', 3, 'iTop by Combodo', 'iTop permite definir el alcance de la gestión de la configuración incluyendo servicios, activos, software, hardware, y cualquier CI personalizable.', 'iTop permite modelar desde lo más básico hasta configuraciones complejas. Se pueden definir CI personalizados y establecer políticas de alcance.', 'Puede integrarse con herramientas como GLPI, Zabbix, OpenAudIT o scripts vía API REST/CSV.'),

('BAI10-P01-A02', 'BAI10-P01', 'Establecer y mantener un modelo lógico para la gestión de la configuración, incluida información sobre tipos de CI, atributos, tipos de relación, atributos de relación y códigos de estado.', 3, 'iTop by Combodo', 'iTop permite crear un modelo lógico completo de configuración con tipos de CI (hardware, software, servicios), relaciones jerárquicas o de dependencia, atributos definidos por el usuario, estados y flujos de trabajo asociados.', 'Soporta modelos extensibles, gestión del ciclo de vida y control de versiones de CI. Es compatible con prácticas ITIL.', 'Se complementa bien con OpenAudIT (para descubrimiento automático), Zabbix (monitorización) y GLPI (gestión de incidencias).'),

('BAI10-P02-A01', 'BAI10-P02', 'Identificar y clasificar los CI y completar el repositorio.', 2, 'iTop by Combodo', 'iTop permite importar, detectar y clasificar CIs por tipo (hardware, software, red, aplicaciones, servicios, etc.), atributos y relaciones. Se puede llenar el repositorio manualmente o por sincronización automática.', 'Soporta estructuras jerárquicas, filtros, etiquetas, estados de ciclo de vida. Flexible y apto para entornos complejos.', 'Se integra con FusionInventory, GLPI, OCS Inventory, Zabbix, Active Directory.'),

('BAI10-P02-A02', 'BAI10-P02', 'Crear, revisar y acordar formalmente las líneas base de configuración de un servicio, aplicación o infraestructura.', 3, 'iTop by Combodo', 'iTop permite definir líneas base de configuración, gestionar versiones de CIs, realizar auditorías de cambios y generar reportes sobre la consistencia entre líneas base y el estado actual.', 'Las líneas base pueden ser formales y revisadas desde flujos de aprobación (workflow). Ideal para entornos regulados o críticos.', 'Integración con herramientas de ITSM y automatización para disparar auditorías o validaciones.'),

('BAI10-P03-A01', 'BAI10-P03', 'Identificar periódicamente todos los cambios en los IC.', 2, 'iTop by Combodo', 'iTop puede auditar cambios sobre CIs, registrar automáticamente modificaciones a través de descubrimiento o input manual. Soporta registro de eventos de cambio.', 'Puede programarse o integrarse con discovery para actualizar datos de forma periódica.', 'Se integra con FusionInventory, OCS Inventory, Zabbix, etc., para descubrimiento.'),

('BAI10-P03-A02', 'BAI10-P03', 'Para garantizar la integridad y precisión, revise los cambios propuestos a los IC en comparación con la línea base.', 2, 'iTop by Combodo', 'Las líneas base en iTop se pueden comparar con el estado actual de un CI. Las desviaciones se identifican fácilmente.', 'Soporta revisión manual o automatizada de desviaciones. Pueden dispararse acciones o alertas.', 'Compatible con procesos ITSM de gestión de cambios.'),

('BAI10-P03-A03', 'BAI10-P03', 'Actualice los detalles de configuración para los cambios aprobados en los CI.', 2, 'iTop by Combodo', 'iTop incluye flujos de trabajo para la aprobación de cambios y actualización automática de CIs cuando se aprueban.', 'Historial completo y validación de cambios. Alta trazabilidad.', 'Puede integrarse con herramientas de automatización o ticketing.'),

('BAI10-P03-A04', 'BAI10-P03', 'Crear, revisar y acordar formalmente cambios en las líneas base de configuración cuando sea necesario.', 3, 'iTop by Combodo', 'Permite crear nuevas líneas base o modificar las existentes mediante procesos de revisión y aprobación.', 'Cambios registrados, versionados y documentados.', 'Flujo de trabajo configurable, exportación de reportes, alertas.'),

('BAI10-P04-A01', 'BAI10-P04', 'Identificar los cambios de estado de los IC e informarlos en relación con la línea de base.', 2, 'iTop by Combodo', 'iTop permite rastrear el historial de cambios en cada CI con relación a la línea base y generar reportes históricos.', 'Soporta control de versiones y auditoría automatizada.', 'Integrable con herramientas de descubrimiento como OpenAudIT o scripts de sincronización.'),

('BAI10-P04-A02', 'BAI10-P04', 'Compare todos los cambios de configuración con las solicitudes de cambio aprobadas para identificar cualquier cambio no autorizado. Informe los cambios no autorizados a la gestión de cambios.', 3, 'iTop by Combodo', 'iTop relaciona los CI con solicitudes de cambio (RFC), lo que permite identificar fácilmente discrepancias no autorizadas.', 'Automatiza la trazabilidad entre RFC y modificaciones reales.', 'Integrable con controladores de configuración externos (Ansible, Puppet, etc.).'),

('BAI10-P04-A03', 'BAI10-P04', 'Identificar los requisitos de información de todas las partes interesadas, incluyendo contenido, frecuencia y medios. Elaborar informes según los requisitos identificados.', 3, 'iTop by Combodo', 'Permite la generación de reportes personalizados y programados según los requerimientos de diferentes grupos de interés.', 'Reportes exportables vía PDF, HTML, CSV y con planificación automática.', 'Puede conectarse con herramientas externas como Grafana vía API o Webhooks.'),

('BAI10-P05-A01', 'BAI10-P05', 'Verifique periódicamente los elementos de configuración en vivo con el repositorio de configuración comparando las configuraciones físicas y lógicas y utilizando herramientas de descubrimiento adecuadas, según sea necesario.', 4, 'OpenAudIT', 'Tiene capacidades avanzadas de descubrimiento automático de activos y comparación de configuraciones reales vs registradas.', 'Ideal para sincronización con CMDBs; detecta diferencias físicas y lógicas.', 'Se integra bien con iTop, GLPI y otros CMDBs para mantener consistencia.'),

('BAI10-P05-A02', 'BAI10-P05', 'Informar y revisar todas las desviaciones para realizar correcciones aprobadas o tomar medidas para eliminar cualquier activo no autorizado.', 4, 'Wazuh', 'Incorpora detección de cambios no autorizados, alertas en tiempo real y registro de desviaciones para su posterior revisión.', 'Especializado en detectar desviaciones y generar informes accionables.', 'Compatible con herramientas SIEM y plataformas de gestión de incidentes.'),

('BAI10-P05-A03', 'BAI10-P05', 'Verifique periódicamente que todos los elementos de configuración física, tal como se definen en el repositorio, existan físicamente. Informe cualquier desviación a la gerencia.', 4, 'OpenAudIT', 'Puede verificar existencia física de hardware mediante escaneo y descubrimiento de red.', 'Ya usado en Actividad 1, pero cumple perfectamente esta necesidad también.', 'Puede alimentar una CMDB como iTop o GLPI con datos validados.'),

('BAI10-P05-A04', 'BAI10-P05', 'Establecer y revisar periódicamente el objetivo de integridad del repositorio de configuración en función de las necesidades del negocio.', 4, 'iTop by Combodo', 'Permite definir políticas de integridad del repositorio y establecer objetivos de calidad de configuración.', 'Su enfoque en gobierno de configuración lo hace ideal para esta actividad.', 'Puede integrarse con OpenAudIT y otros descubridores.'),

('BAI10-P05-A05', 'BAI10-P05', 'Comparar periódicamente el grado de integridad y precisión con respecto a los objetivos y adoptar medidas correctivas, según sea necesario, para mejorar la calidad de los datos del repositorio.', 5, 'iTop by Combodo', 'Su sistema de seguimiento de calidad y ciclos de revisión permite evaluar la integridad y ejecutar medidas correctivas.', 'Reutilizada porque permite implementar acciones en función de desviaciones.', 'Compatible con herramientas de auditoría y descubrimiento como OpenAudIT.'),

('BAI11-P01-A01', 'BAI11-P01', 'Mantener y aplicar un enfoque estándar para la gestión de proyectos, alineado con el entorno específico de la empresa y con buenas prácticas basadas en procesos definidos y el uso de tecnología apropiada. Garantizar que el enfoque cubra todo el ciclo de vida y las disciplinas a seguir, incluyendo la gestión del alcance, los recursos, el riesgo, los costos, la calidad, el tiempo, la comunicación, la participación de las partes interesadas, las adquisiciones, el control de cambios, la integración y la obtención de beneficios.', 2, 'Collabtive', 'Es una herramienta específica para gestión de proyectos. Permite definir cronogramas, alcance, recursos, tareas, comunicación y seguimiento. Cumple con la mayoría de las disciplinas de gestión de proyectos.', 'Su enfoque es ágil y colaborativo. Aunque no es tan robusta como herramientas empresariales, se adapta a PYMEs.', 'Puede complementarse con herramientas de reporte o plugins externos para métricas o integraciones con ERP.'),

('BAI11-P01-A02', 'BAI11-P01', 'Proporcionar capacitación adecuada en gestión de proyectos y considerar la certificación de los gerentes de proyectos.', 2, 'Moodle', 'Es una plataforma de formación muy robusta. Permite gestionar cursos, rutas de aprendizaje, certificaciones y seguimiento del progreso del aprendizaje.', 'Es ideal para implementar formación formal y continua en gestión de proyectos.', 'Puede integrarse con sistemas de RRHH o portales de empleados. También con Collabtive a través de LTI o herramientas intermedias.'),

('BAI11-P01-A03', 'BAI11-P01', 'Implementar una oficina de gestión de proyectos (PMO) que mantenga el enfoque estándar para la gestión de programas y proyectos en toda la organización. La PMO apoya todos los proyectos mediante la creación y el mantenimiento de las plantillas de documentación requeridas, la capacitación y las mejores prácticas para los gerentes de proyecto, el seguimiento de métricas sobre el uso de las mejores prácticas para la gestión de proyectos, etc. En algunos casos, la PMO también puede informar sobre el progreso del proyecto a la alta dirección o a las partes interesadas, ayudar a priorizar los proyectos y garantizar que todos los proyectos contribuyan a los objetivos generales de negocio de la empresa.', 3, 'GLPI', 'Aunque tradicionalmente usado como ITSM, GLPI permite gestionar proyectos, plantillas, documentación, tareas, roles y permisos. Es adecuado para implementar una PMO básica con workflows y seguimiento.', 'El módulo de proyectos requiere instalación del plugin adecuado. Es más potente si se usa GLPI como plataforma central de gestión TI.', 'Se puede integrar con Znuny para la gestión de solicitudes relacionadas a proyectos y servicios.'),

('BAI11-P01-A04', 'BAI11-P01', 'Evaluar las lecciones aprendidas sobre el uso del enfoque de gestión de proyectos. Actualizar las buenas prácticas, herramientas y plantillas según corresponda.', 4, 'iTop by Combodo', 'Su estructura orientada a procesos permite documentar plantillas, políticas, procesos y registrar cambios en buenas prácticas. Admite documentación estructurada y seguimiento.', 'No está centrado en proyectos, pero es muy útil para estructurar las lecciones aprendidas como parte de la mejora continua.', 'Se puede conectar con GLPI para tener consistencia en la documentación y seguimiento de procesos.'),

('BAI11-P02-A01', 'BAI11-P02', 'Para crear un entendimiento común del alcance del proyecto entre las partes interesadas, proporcióneles una declaración escrita clara que defina la naturaleza, el alcance y los resultados de cada proyecto.', 2, 'Collabtive', 'Permite definir claramente el alcance del proyecto, tareas, hitos y entregables mediante descripción en proyectos y seguimiento colaborativo.', 'Soporta comentarios y archivos adjuntos para lograr claridad entre stakeholders.', 'Puede integrarse vía plugins con sistemas de tickets como Znuny o GLPI si se requiere trazabilidad adicional.'),

('BAI11-P02-A02', 'BAI11-P02', 'Asegurarse de que cada proyecto cuente con uno o más patrocinadores con autoridad suficiente para gestionar la ejecución del proyecto dentro del programa general.', 2, 'Collabtive', 'Soporta la asignación de usuarios con diferentes roles, incluyendo administradores y gestores del proyecto que pueden actuar como patrocinadores con autoridad.', 'Aunque no gestiona jerarquías organizacionales avanzadas, permite configurar autoridad en ejecución mediante roles y permisos.', 'Puede integrarse con LDAP si se requiere control de acceso más sofisticado.'),

('BAI11-P02-A03', 'BAI11-P02', 'Asegúrese de que las partes interesadas clave y los patrocinadores dentro de la empresa (negocios y TI) estén de acuerdo y acepten los requisitos para el proyecto, incluida la definición de los criterios de éxito (aceptación) del proyecto y los indicadores clave de rendimiento (KPI).', 2, 'Collabtive', 'Permite documentar requisitos en descripciones de proyecto, tareas y archivos adjuntos, así como definir hitos que pueden representar KPIs.', 'No es un sistema orientado a KPIs avanzados, pero puede usarse para seguimiento básico.', 'Puede integrarse con herramientas externas de BI (via exportaciones) para visualización de KPIs si se requiere.'),

('BAI11-P02-A04', 'BAI11-P02', 'Designar un gerente dedicado al proyecto. Asegurarse de que posea los conocimientos tecnológicos y de negocio necesarios, así como las competencias y habilidades necesarias para gestionar el proyecto de forma eficaz y eficiente.', 2, 'Collabtive', 'Permite asignar un responsable a cada proyecto. Los usuarios pueden ser configurados con permisos específicos que habilitan la gestión completa.', 'No evalúa competencias, pero permite asegurarse de que cada proyecto tenga un PM asignado con control total.', 'Puede complementarse con Moodle si se desea verificar competencias o formación del PM.'),

('BAI11-P02-A05', 'BAI11-P02', 'Asegúrese de que la definición del proyecto describa los requisitos para un plan de comunicación del proyecto que identifique las comunicaciones internas y externas del proyecto.', 2, 'Collabtive', 'Collabtive permite gestionar la comunicación entre miembros del equipo y con interesados externos mediante su sistema de mensajes y comentarios en tareas y proyectos.', 'Soporta múltiples canales de comunicación centralizados.', 'Opcional integración con correo electrónico o Nextcloud.'),

('BAI11-P02-A06', 'BAI11-P02', 'Con la aprobación de las partes interesadas, mantener la definición del proyecto durante todo el proyecto, reflejando los requisitos cambiantes.', 2, 'Collabtive', 'Permite editar y mantener la información del proyecto, tareas y documentación asociada, con historial de cambios.', 'Se requiere definir roles de aprobación con disciplina organizacional.', 'Puede integrarse con sistemas de control documental externos.'),

('BAI11-P02-A07', 'BAI11-P02', 'Para dar seguimiento a la ejecución de un proyecto, establecer mecanismos tales como informes periódicos y revisiones de etapas, lanzamientos o fases, que se realicen de manera oportuna y con la aprobación correspondiente.', 2, 'Collabtive', 'Incluye funciones de hitos, cronograma y generación de informes que permiten seguimiento por fases y actividades.', 'Las revisiones pueden ser registradas como tareas/hitos con seguimiento.', 'Se puede complementar con herramientas de visualización (ej. GanttProject).'),

('BAI11-P03-A01', 'BAI11-P03', 'Planificar cómo se identificarán, analizarán, involucrarán y gestionarán las partes interesadas dentro y fuera de la empresa a lo largo del ciclo de vida del proyecto.', 3, 'Collabtive', 'Collabtive permite definir proyectos con asignación de usuarios y roles. Se pueden planificar actividades para involucrar partes interesadas a través de tareas, responsables y calendarios.', 'Puede documentarse la estrategia de participación dentro del proyecto.', 'Puede complementarse con herramientas ofimáticas (Nextcloud, OnlyOffice).'),

('BAI11-P03-A02', 'BAI11-P03', 'Identificar, involucrar y gestionar a las partes interesadas estableciendo y manteniendo niveles adecuados de coordinación, comunicación y enlace para garantizar que participen en el proyecto.', 3, 'Collabtive', 'Ofrece mensajería integrada, asignación de tareas y seguimiento, permitiendo mantener informadas y activas a las partes interesadas.', 'Admite coordinación efectiva con múltiples perfiles y notificaciones.', 'Integrable con correo electrónico para alertas y actualizaciones.'),

('BAI11-P03-A03', 'BAI11-P03', 'Analizar los intereses, requisitos y participación de las partes interesadas. Implementar las medidas correctivas necesarias.', 4, 'Collabtive', 'Mediante informes, comentarios y control de progreso en tareas, se puede analizar el nivel de participación. Las medidas correctivas se registran como nuevas tareas o acciones.', 'No incluye analítica avanzada, pero es suficiente para análisis funcional básico.', 'Puede integrarse con herramientas de BI externas si se requiere análisis más profundo.'),

('BAI11-P04-A01', 'BAI11-P04', 'Desarrollar un plan de proyecto que proporcione información que permita a la gerencia controlar el progreso del proyecto progresivamente. El plan debe incluir detalles de los entregables del proyecto y los criterios de aceptación, los recursos y responsabilidades internos y externos requeridos, estructuras de desglose del trabajo y paquetes de trabajo claros, estimaciones de los recursos necesarios, hitos/plan de lanzamiento/fases, dependencias clave, presupuesto y costos, e identificación de una ruta crítica.', 2, 'Collabtive', 'Permite estructurar proyectos con tareas, fases, responsables, fechas, tiempos estimados y asignación de recursos. Aunque no incluye gestión avanzada de ruta crítica, permite definir dependencias y cronogramas.', 'Se puede simular una estructura de desglose del trabajo (EDT/WBS) mediante tareas anidadas.', 'Puede complementarse con herramientas de Gantt externas como GanttProject o diagramadores tipo Draw.io.'),

('BAI11-P04-A02', 'BAI11-P04', 'Mantener actualizado el plan del proyecto y cualquier plan dependiente (p. ej., plan de riesgos, plan de calidad, plan de obtención de beneficios). Asegurarse de que los planes estén actualizados y reflejen el progreso real y los cambios sustanciales aprobados.', 2, 'Collabtive', 'El plan puede actualizarse fácilmente. Permite edición continua de tareas, responsables, fechas, presupuestos y adjuntos. El seguimiento de cambios puede hacerse con comentarios y archivos.', 'No gestiona múltiples planes específicos por defecto, pero pueden representarse como proyectos o secciones distintas.', 'Integrable con sistemas de versionado de documentos (Nextcloud, Git).'),

('BAI11-P04-A03', 'BAI11-P04', 'Asegurar una comunicación eficaz de los planes del proyecto y los informes de progreso. Asegurar que cualquier cambio realizado en los planes individuales se refleje en los demás planes.', 2, 'Collabtive', 'Tiene sistema de mensajería interna, notificaciones y posibilidad de adjuntar informes y comentarios por tarea o proyecto. Ideal para comunicar avances y actualizaciones.', 'Puede automatizar notificaciones a usuarios asignados ante cambios o nuevos hitos.', 'Compatible con notificaciones vía correo y sincronización de calendarios.'),

('BAI11-P04-A04', 'BAI11-P04', 'Determinar las actividades, interdependencias y colaboración y comunicación requeridas dentro del proyecto y entre múltiples proyectos dentro de un programa.', 2, 'Collabtive', 'Collabtive permite definir múltiples proyectos, tareas y subtareas con asignación de responsables, tiempos, dependencias visuales y comunicación interna por comentarios.', 'Interfaz sencilla pero funcional. Permite visualizar dependencias indirectas con tareas asociadas. No es tan potente como herramientas tipo MS Project, pero cumple bien el estándar COBIT.', 'Se puede integrar con herramientas de seguimiento de tiempo como Kimai o módulos de GLPI.'),

('BAI11-P04-A05', 'BAI11-P04', 'Asegúrese de que cada hito esté acompañado de un resultado significativo que requiera revisión y aprobación.', 2, 'Collabtive', 'Collabtive permite asociar entregables a milestones y comentarios, permitiendo validación manual o revisión colaborativa.', 'La aprobación no es automatizada, pero puede gestionarse vía flujo de comentarios o revisión de archivos adjuntos.', 'Se puede integrar con sistemas de documentación como Nextcloud o OnlyOffice para revisión colaborativa.'),

('BAI11-P04-A06', 'BAI11-P04', 'Establecer una línea base del proyecto (por ejemplo, costo, cronograma, alcance, calidad) que se revise, apruebe e incorpore adecuadamente al plan integrado del proyecto.', 2, 'Collabtive', 'Aunque no tiene gestión de presupuestos avanzada, Collabtive permite definir cronogramas, tareas clave y responsables, sirviendo como línea base básica.', 'Se recomienda complementar con otra herramienta si se requiere control financiero estricto. La línea base se gestiona con fechas, responsables y estados.', 'Puede conectarse con módulos financieros externos vía API o exportación de datos.'),

('BAI11-P05-A01', 'BAI11-P05', 'Proporcionar garantía de calidad para los entregables del proyecto, identificar la propiedad y las responsabilidades, los procesos de revisión de calidad, los criterios de éxito y las métricas de desempeño.', 2, 'Eramba', 'Eramba permite definir controles, responsables, métricas de desempeño y criterios de éxito a través de sus módulos de auditoría, gestión de controles y políticas.', 'Permite configurar revisiones periódicas y seguimiento de métricas para evaluar calidad.', 'Puede integrarse con Jira, Confluence y otras plataformas de seguimiento mediante API o intermediarios.'),

('BAI11-P05-A02', 'BAI11-P05', 'Identificar las tareas y prácticas de aseguramiento necesarias para respaldar la acreditación de sistemas nuevos o modificados durante la planificación del proyecto. Incluirlas en los planes integrados. Asegurar que las tareas garanticen que los controles internos y las soluciones de seguridad y privacidad cumplan con los requisitos definidos.', 3, 'Eramba', 'Se pueden definir políticas y tareas de aseguramiento asociadas a controles internos, incluyendo validaciones de cumplimiento de seguridad y privacidad.', 'El sistema permite documentar cada control y relacionarlo con requisitos normativos.', 'Compatible con integraciones externas por API.'),

('BAI11-P05-A03', 'BAI11-P05', 'Definir cualquier requisito para la validación y verificación independiente de la calidad de los entregables del plan.', 3, 'Eramba', 'Se pueden crear procesos de revisión independientes, asignar responsables y configurar auditorías específicas para validación externa.', 'Permite registrar evidencia de verificación independiente.', 'Integrable con repositorios externos para validación documental.'),

('BAI11-P05-A04', 'BAI11-P05', 'Realizar actividades de aseguramiento y control de calidad de acuerdo con el plan de gestión de calidad y el SGC.', 3, 'Eramba', 'El módulo de auditoría permite planear y ejecutar actividades de aseguramiento y control de calidad conforme a un calendario definido.', 'Posibilidad de establecer revisiones internas periódicas y seguir hallazgos.', 'API disponible para sincronizar con herramientas como GLPI o CMDBs.'),

('BAI11-P06-A01', 'BAI11-P06', 'Establecer un enfoque formal de gestión de riesgos del proyecto alineado con el marco de ERM. Asegurarse de que el enfoque incluya la identificación, el análisis, la respuesta, la mitigación, el seguimiento y el control de los riesgos.', 2, 'Eramba', 'Eramba incluye un módulo completo de gestión de riesgos que permite identificar, evaluar, mitigar y monitorear riesgos, siguiendo pasos alineados con ERM y marcos como ISO 31000.', 'Permite clasificar riesgos por proyecto, tipo y criticidad. Se definen planes de tratamiento y seguimiento.', 'API disponible para integración con sistemas como GLPI, Jira, entre otros.'),

('BAI11-P06-A02', 'BAI11-P06', 'Asignar al personal debidamente capacitado la responsabilidad de ejecutar el proceso de gestión de riesgos del proyecto de la empresa y garantizar que se incorpore en las prácticas de desarrollo de soluciones. Considere asignar esta función a un equipo independiente, especialmente si se requiere una perspectiva objetiva o si el proyecto se considera crítico.', 2, 'Eramba', 'Se pueden asignar propietarios de riesgo y responsables de acciones de mitigación o revisión. Es posible definir roles y perfiles según la criticidad del proyecto.', 'Soporta separación de funciones e independencia para revisión de riesgos críticos.', 'Compatible con directorios LDAP y SSO para asignación automática de usuarios/responsables.'),

('BAI11-P06-A03', 'BAI11-P06', 'Identificar a los responsables de las acciones para evitar, aceptar o mitigar el riesgo.', 2, 'Eramba', 'Se asignan responsables por riesgo y por control asociado. Además, se documentan las decisiones tomadas (aceptar, evitar, mitigar) y las evidencias correspondientes.', 'Se pueden registrar actividades por estado y hacer trazabilidad completa de la gestión del riesgo.', 'Se puede integrar con herramientas de seguimiento de tareas para acciones correctivas.'),

('BAI11-P06-A04', 'BAI11-P06', 'Realizar la evaluación de riesgos del proyecto, identificando y cuantificando los riesgos continuamente durante todo el proyecto. Gestionar y comunicar adecuadamente los riesgos dentro de la estructura de gobernanza del proyecto.', 3, 'Eramba', 'Eramba permite registrar riesgos de forma continua, asignarles valores cuantitativos (impacto, probabilidad, umbrales) y notificarlos a los responsables definidos en la estructura de gobernanza del proyecto.', 'Configurable para soportar actualizaciones automáticas de riesgo según frecuencia o cambio de condiciones.', 'Puede integrarse con herramientas de seguimiento de proyectos para recibir cambios o eventos. API disponible.'),

('BAI11-P06-A05', 'BAI11-P06', 'Reevaluar periódicamente el riesgo del proyecto, incluso al inicio de cada fase importante del proyecto y como parte de las evaluaciones de solicitudes de cambio importantes.', 3, 'Eramba', 'Incluye funcionalidades para programar evaluaciones periódicas, con alertas y tareas recurrentes por fase de proyecto o evento de cambio.', 'Las revisiones son documentadas con trazabilidad total. Se pueden asociar con fases de proyectos.', 'Integrable con herramientas de gestión de proyectos tipo Redmine, Jira o GLPI (vía API o scripts).'),

('BAI11-P06-A06', 'BAI11-P06', 'Mantener y revisar un registro de riesgos del proyecto que incluya todos los riesgos potenciales y un registro de mitigación de riesgos que incluya todos los problemas del proyecto y su resolución. Analizar periódicamente el registro para detectar tendencias y problemas recurrentes y asegurar que se corrijan las causas raíz.', 3, 'Eramba', 'Eramba genera automáticamente un registro de riesgos que incluye los riesgos identificados, su estatus, plan de mitigación y evidencia de resolución. Permite análisis de tendencias mediante reportes periódicos.', 'El sistema permite exportar, filtrar y analizar los registros en múltiples formatos (PDF, Excel).', 'Puede integrarse con herramientas BI o con GLPI para vincular problemas técnicos a riesgos.'),

('BAI11-P07-A01', 'BAI11-P07', 'Establecer y utilizar un conjunto de criterios de proyecto que incluyan, entre otros, el alcance, el beneficio comercial esperado, el cronograma, la calidad, el costo y el nivel de riesgo.', 2, 'Collabtive', 'Permite la definición de proyectos con campos personalizables, cronograma, hitos y seguimiento de tiempo y costos.', 'Puede ajustarse para incluir criterios clave como calidad y riesgo mediante campos personalizados.', 'Opcional con ERP o herramientas BI para reportes avanzados.'),

('BAI11-P07-A02', 'BAI11-P07', 'Informar a las partes interesadas clave identificadas sobre el progreso del proyecto, las desviaciones de los criterios clave de desempeño del proyecto establecidos (como, entre otros, los beneficios comerciales esperados) y los posibles efectos positivos y negativos sobre el proyecto.', 2, 'Collabtive', 'Incluye sistema de generación de informes, notificaciones por usuario y seguimiento de tareas.', 'Se pueden configurar alertas y generar reportes exportables.', 'Se puede complementar con correo electrónico o Slack mediante integración de terceros.'),

('BAI11-P07-A03', 'BAI11-P07', 'Documentar y presentar los cambios necesarios a las principales partes interesadas del proyecto para su aprobación antes de su adopción. Comunicar los criterios revisados a los gerentes de proyecto para su uso en futuros informes de desempeño.', 2, 'Collabtive', 'Cuenta con sistema de documentación, comentarios, historial de tareas y control de cambios básicos.', 'Se requiere disciplina organizacional para asegurar el uso correcto de esta funcionalidad.', 'Opcional: wiki o sistema documental externo como DokuWiki.'),

('BAI11-P07-A04', 'BAI11-P07', 'Para los entregables producidos en cada iteración, lanzamiento o fase del proyecto, obtener la aprobación y firma de los gerentes y usuarios designados en las funciones comerciales y de TI afectadas.', 2, 'Collabtive', 'Se puede usar la funcionalidad de tareas finalizadas con comentarios de aprobación y documentos adjuntos.', 'No incluye firma digital nativa, pero puede simularse con comentarios de cierre/aprobación.', 'Se puede complementar con herramientas de firma electrónica como DocuSign si es necesario.'),

('BAI11-P07-A05', 'BAI11-P07', 'Basar el proceso de aprobación en criterios de aceptación claramente definidos y acordados por las partes interesadas clave antes de comenzar a trabajar en la fase del proyecto o en el resultado de la iteración.', 3, 'Collabtive', 'Puede documentarse en la fase de planificación del proyecto e incluirse como criterios de tareas o hitos.', 'No es automatizado, pero se puede gestionar por disciplina organizativa en el flujo de trabajo.', 'Puede integrarse con herramientas de workflow para formalizar la lógica de aprobación.'),

('BAI11-P07-A06', 'BAI11-P07', 'Evaluar el proyecto en las etapas principales acordadas: etapas de cierre, lanzamientos o iteraciones. Tomar decisiones formales de aprobación o rechazo con base en criterios críticos de éxito predeterminados.', 3, 'Collabtive', 'Permite la gestión de fases del proyecto, con hitos, tareas y revisiones de entregables; permite documentar aprobaciones o rechazos con comentarios y adjuntos.', 'Adecuado para proyectos iterativos con validaciones por fase.', 'Puede integrarse con sistemas de almacenamiento externo (e.g., Nextcloud) o GLPI vía plugins.'),

('BAI11-P07-A07', 'BAI11-P07', 'Establecer y operar un sistema de control de cambios para el proyecto de modo que todos los cambios a la línea base del proyecto (por ejemplo, alcance, beneficios comerciales esperados, cronograma, calidad, costo, nivel de riesgo) se revisen, aprueben e incorporen adecuadamente al plan integrado del proyecto de acuerdo con el programa y el marco de gobernanza del proyecto.', 3, 'GLPI', 'Tiene gestión de cambios robusta, flujos de aprobación, y vinculación con proyectos y tareas asociadas.', 'Su módulo ITIL facilita registrar, aprobar y hacer seguimiento a cambios en el proyecto.', 'Integración nativa con FusionInventory, OCS Inventory y posibilidad de integración con Collabtive vía API.'),

('BAI11-P07-A08', 'BAI11-P07', 'Medir el rendimiento del proyecto en relación con los criterios clave. Analizar las desviaciones de los criterios clave establecidos para determinar su causa y evaluar los efectos positivos y negativos en el proyecto.', 4, 'Collabtive', 'Proporciona reportes de progreso y seguimiento de tareas, hitos y tiempo estimado vs. real.', 'Útil para análisis de desempeño basado en tareas y cronograma.', 'Puede complementarse con GLPI para criterios técnicos u operacionales.'),

('BAI11-P07-A09', 'BAI11-P07', 'Supervisar los cambios en el proyecto y revisar los criterios clave de desempeño del proyecto existentes para determinar si aún representan medidas válidas de progreso.', 4, 'GLPI', 'Permite seguimiento detallado de cambios, tareas y KPIs definidos por el usuario, junto con control de configuración.', 'Puede incorporar campos personalizados para definir criterios clave de desempeño.', 'Se integra con Grafana o herramientas BI para visualizar métricas.'),

('BAI11-P07-A10', 'BAI11-P07', 'Recomendar y supervisar las medidas correctivas, cuando sea necesario, de conformidad con el marco de gobernanza del proyecto.', 4, 'GLPI', 'Posibilita la apertura de tareas correctivas, incidentes o solicitudes de cambio como respuesta a desviaciones detectadas.', 'Excelente para supervisar y documentar acciones correctivas.', 'Puede integrarse con Collabtive para ver progreso y tareas detalladas.'),

('BAI11-P08-A01', 'BAI11-P08', 'Identificar las necesidades de recursos comerciales y de TI para el proyecto y asignar claramente los roles y responsabilidades apropiados, con autoridades de escalamiento y toma de decisiones acordadas y entendidas.', 2, 'GLPI', 'GLPI permite definir y gestionar usuarios, perfiles, roles personalizados, escalamiento de tickets y workflows. Se pueden documentar recursos requeridos y asignar responsables.', 'Dispone de módulos de escalamiento y trazabilidad. Adecuado para entornos de TI y proyectos mixtos.', 'Compatible con FusionInventory, iTop, y ERPs vía API REST.'),

('BAI11-P08-A02', 'BAI11-P08', 'Identifique las habilidades y el tiempo requeridos para todas las personas involucradas en las fases del proyecto, en relación con los roles definidos. Asigne personal a los roles según la información disponible sobre habilidades (p. ej., matriz de habilidades de TI).', 2, 'GLPI', 'A través de campos personalizados, se puede crear una matriz de habilidades, registrar disponibilidad de personal y asignación temporal en tareas o proyectos.', 'No tiene un módulo nativo de skills matrix, pero puede lograrse con personalización.', 'Se puede complementar con Moodle para validar habilidades mediante capacitaciones.'),

('BAI11-P08-A03', 'BAI11-P08', 'Utilizar recursos de gestión de proyectos y líderes de equipo experimentados con habilidades apropiadas al tamaño, la complejidad y el riesgo del proyecto.', 2, 'GLPI', 'Se pueden registrar los roles de liderazgo, vincular responsables por proyecto, y documentar experiencia/capacitación previa mediante campos personalizados o plugins.', 'Permite visibilidad sobre quién gestiona qué, con histórico de asignaciones.', 'Puede integrarse con Collabtive para seguimiento más detallado de tareas.'),

('BAI11-P08-A04', 'BAI11-P08', 'Considere y defina claramente los roles y responsabilidades de otras partes involucradas, incluidas finanzas, asuntos legales, adquisiciones, recursos humanos, auditoría interna y cumplimiento.', 2, 'GLPI', 'Ofrece una gestión de perfiles y entidades (como legal, compras, auditoría), permitiendo segmentar responsabilidades por grupo o área.', 'Soporta estructuras organizacionales complejas y multi-área.', 'Integración posible con Znuny para flujos interdepartamentales.'),

('BAI11-P08-A05', 'BAI11-P08', 'Definir y acordar claramente la responsabilidad de la adquisición y gestión de productos y servicios de terceros, y gestionar las relaciones.', 2, 'GLPI', 'GLPI permite registrar proveedores, contratos, productos y servicios adquiridos, y asignar responsables.', 'Permite documentar y controlar la gestión de relaciones con terceros.', 'Se puede integrar con sistemas ERP (como Dolibarr) para mayor detalle en adquisiciones.'),

('BAI11-P08-A06', 'BAI11-P08', 'Identificar y autorizar la ejecución de la obra de acuerdo al plan del proyecto.', 2, 'GLPI', 'GLPI permite la asignación de tareas del proyecto, responsables y fechas de ejecución.', 'La autorización puede simularse con estados personalizados y seguimiento.', 'Posible integración con módulos de workflow o validación por plugins.'),

('BAI11-P08-A07', 'BAI11-P08', 'Identificar las brechas en el plan del proyecto y brindar retroalimentación al gerente del proyecto para remediarlas.', 2, 'GLPI', 'El sistema permite monitorear el avance de tareas, y escribir comentarios sobre el progreso.', 'No hay alertas automáticas sobre desviaciones; requiere revisión manual.', 'Puede integrarse con plugins de reporting o alertas por correo electrónico.'),

('BAI11-P09-A01', 'BAI11-P09', 'Obtener la aceptación de las partes interesadas de los resultados del proyecto y transferir la propiedad.', 2, 'Collabtive', 'Collabtive permite marcar tareas o hitos como completados, agregar comentarios y registrar entregables, incluyendo aprobación de stakeholders mediante actualizaciones o archivos subidos.', 'La aceptación formal puede documentarse mediante archivos adjuntos o comentarios de cierre.', 'Puede exportar resultados o usarse junto con sistemas de documentación.'),

('BAI11-P09-A02', 'BAI11-P09', 'Definir y aplicar los pasos clave para el cierre del proyecto, incluidas las revisiones posteriores a la implementación que evalúan si el proyecto alcanzó los resultados deseados.', 3, 'Collabtive', 'Se pueden planificar tareas específicas para el cierre del proyecto e incluir documentación y comentarios como parte del proceso.', 'Las revisiones se pueden cargar como entregables, no hay plantilla nativa para post-implementación.', 'Integrable con Nextcloud o Wiki para documentación detallada.'),

('BAI11-P09-A03', 'BAI11-P09', 'Planificar y ejecutar revisiones posteriores a la implementación para determinar si los proyectos alcanzaron los resultados esperados. Mejorar la metodología de gestión de proyectos y desarrollo de sistemas.', 3, 'Collabtive', 'Permite agregar tareas y discusiones relacionadas con revisiones y mejora de procesos, que quedan registradas para consulta futura.', 'Las mejoras metodológicas pueden registrarse como notas del proyecto o en tareas de mejora continua.', 'Exportable a formatos externos para análisis más profundo.'),

('BAI11-P09-A04', 'BAI11-P09', 'Identificar, asignar, comunicar y dar seguimiento a cualquier actividad no completada necesaria para garantizar que el proyecto entregó los resultados requeridos en términos de capacidades y que los resultados contribuyeron según lo esperado a los beneficios del programa.', 3, 'Collabtive', 'Las tareas incompletas quedan visibles, se pueden reprogramar, asignar y hacer seguimiento hasta su finalización.', 'No hay módulo automatizado para vinculación con beneficios esperados, debe hacerse manualmente.', 'Se puede integrar con hojas de cálculo o informes para análisis externo.'),

('BAI11-P09-A05', 'BAI11-P09', 'Regularmente, y al finalizar el proyecto, recopile las lecciones aprendidas de los participantes. Revíselas, así como las actividades clave que generaron beneficios y valor. Analice los datos y formule recomendaciones para mejorar el proyecto actual y el método de gestión de proyectos para proyectos futuros.', 4, 'Collabtive', 'Se pueden documentar lecciones aprendidas como archivos, comentarios o tareas. Permite discusión en línea y guardar evidencia.', 'No hay módulo específico para lecciones aprendidas, pero puede adaptarse fácilmente.', 'Recomendable integración con sistemas de gestión del conocimiento (Wiki, Notion, etc).'),

('APO01-P01-A01', 'APO01-P01', 'Obtener una comprensión de la visión, dirección y estrategia de la empresa, así como del contexto y los desafíos actuales de la misma.', 2, 'Archi', 'Modela la estrategia, visión, y contexto empresarial.', 'Permite alinear arquitectura con visión estratégica.', '-'),

('APO01-P01-A02', 'APO01-P01', 'Considere el entorno interno de la empresa, incluida la cultura y la filosofía de gestión, la tolerancia al riesgo, la política de seguridad y privacidad, los valores éticos, el código de conducta, la responsabilidad y los requisitos de integridad de la gestión.', 2, 'Archi', 'Puede representar estructura organizacional y valores en el modelo.', 'Modela el entorno interno y sus relaciones con TI.', '-'),

('APO01-P01-A03', 'APO01-P01', 'Aplicar la cascada de objetivos de COBIT y los factores de diseño a la estrategia y el contexto empresarial para decidir las prioridades para el sistema de gestión y, por tanto, para la implementación de las prioridades de los objetivos de gestión.', 2, 'Archi', 'Permite mapear objetivos y prioridades estratégicas.', 'Útil para operacionalizar la cascada de objetivos de COBIT.', '-'),

('APO01-P01-A04', 'APO01-P01', 'Validar las prioridades seleccionadas para la implementación de los objetivos de gestión con buenas prácticas o requisitos específicos de la industria (por ejemplo, regulaciones específicas de la industria) y con estructuras de gobernanza apropiadas.', 3, 'Eramba', 'Permite validar controles con estándares externos y regulaciones.', 'Útil para verificar alineación normativa e industrial.', '-'),

('APO01-P02-A01', 'APO01-P02', 'Proporcionar recursos suficientes y capacitados para apoyar el proceso de comunicación.', 2, 'Znuny', 'Asigna personal a solicitudes de soporte y comunicación interna.', 'Útil para gestión del personal en procesos comunicativos.', '-'),

('APO01-P02-A02', 'APO01-P02', 'Definir reglas básicas para la comunicación identificando las necesidades de comunicación e implementando planes basados en esas necesidades, considerando la comunicación de arriba hacia abajo, de abajo hacia arriba y horizontal.', 3, 'Znuny', 'Configurable para definir y estandarizar flujos de comunicación.', 'Puede adaptarse para gestión de requerimientos y flujos.', '-'),

('APO01-P02-A03', 'APO01-P02', 'Comunicar continuamente los objetivos y la dirección de I&T. Asegurarse de que la comunicación cuente con el respaldo de la dirección ejecutiva, tanto en acciones como en palabras, utilizando todos los canales disponibles.', 3, 'Znuny', 'Facilita la comunicación constante mediante tickets y avisos.', 'Canal formal para mensajes estructurados de I&T.', '-'),

('APO01-P02-A04', 'APO01-P02', 'Asegúrese de que la información comunicada abarque una misión claramente articulada, objetivos del servicio, política de seguridad y privacidad, controles internos, calidad, código de ética/conducta, políticas y procedimientos, roles y responsabilidades, etc. Comunique la información con el nivel de detalle apropiado para las respectivas audiencias dentro de la empresa.', 3, 'Znuny', 'Permite notificar y adjuntar políticas, roles, documentos, etc.', 'Herramienta orientada a documentación técnica y operativa.', '-'),

('APO01-P03-A01', 'APO01-P03', 'Desarrollar el modelo de proceso objetivo de gobernanza de I&T específico para la organización, basado en la selección de objetivos de gestión prioritarios (resultado de la cascada de objetivos y ejercicio de factores de diseño).', 2, 'Archi', 'Modela procesos de negocio y de gobernanza, alineados con objetivos.', 'Ideal para visualizar procesos objetivos y relaciones entre capas.', '-'),

('APO01-P03-A02', 'APO01-P03', 'Analizar la brecha entre el modelo de proceso objetivo para la organización y las prácticas y actividades actuales.', 3, 'Archi', 'Puede representar visualmente las diferencias entre estados actuales y deseados.', 'Muy útil para análisis estructurado de brechas.', '-'),

('APO01-P03-A03', 'APO01-P03', 'Elaborar una hoja de ruta para la implementación de las prácticas y actividades de proceso faltantes. Utilizar métricas de práctica para dar seguimiento a la implementación exitosa.', 4, 'Apache Open', 'Permite crear y organizar hojas de ruta, seguimiento con cronogramas y reportes.', 'Soporta el seguimiento manual con documentos o plantillas.', '-'),

('APO01-P04-A01', 'APO01-P04', 'Identificar las decisiones necesarias para el logro de los resultados empresariales y la estrategia de I&T y para la gestión y ejecución de los servicios de I&T.', 2, 'Archi', 'Permite modelar decisiones clave y cómo se relacionan con objetivos y procesos.', 'Útil para representar decisiones estratégicas como nodos en el modelo.', 'Se puede coomplementar con una herramienta de documentación como open office'),

('APO01-P04-A02', 'APO01-P04', 'Involucrar a las partes interesadas que son críticas para la toma de decisiones (responsables, consultadas o informadas).', 2, 'Archi', 'Puede modelar actores (stakeholders) y su relación con procesos y decisiones.', 'Ideal para diagramar relaciones RACI o similares.', 'Se puede coomplementar con una herramienta de documentación como open office'),

('APO01-P04-A03', 'APO01-P04', 'Definir el alcance, el enfoque, el mandato y las responsabilidades de cada función dentro de la organización relacionada con I&T, de acuerdo con la dirección de gobernanza.', 2, 'Archi', 'Facilita el diseño estructural de funciones organizativas.', 'Puede documentar responsabilidades por función en la arquitectura.', 'Se puede coomplementar con una herramienta de documentación como open office'),

('APO01-P04-A04', 'APO01-P04', 'Definir el alcance de las funciones internas y externas, los roles internos y externos y las capacidades y derechos de decisión necesarios para cubrir todas las prácticas, incluidas aquellas realizadas por terceros.', 3, 'Archi', 'Puede representar funciones internas, externas y niveles de decisión.', 'Visualiza claramente roles y límites organizacionales.', 'Se puede coomplementar con una herramienta de documentación como open office'),

('APO01-P04-A05', 'APO01-P04', 'Alinear la organización relacionada con I&T con los modelos organizacionales de la arquitectura empresarial.', 3, 'Archi', 'Permite alinear la estructura de I&T con la arquitectura empresarial.', '-', 'Se puede coomplementar con una herramienta de documentación como open office'),

('APO01-P04-A06', 'APO01-P04', 'Establecer un comité directivo de I&T (o equivalente) compuesto por directivos ejecutivos, comerciales y de I&T para realizar el seguimiento del estado de los proyectos, resolver conflictos de recursos y monitorear los niveles de servicio y las mejoras del servicio.', 3, 'Collabtive', 'Puede apoyar coordinación del comité con tareas, fechas y responsables.', '-', 'Se puede coomplementar con una herramienta de documentación como open office'),

('APO01-P04-A07', 'APO01-P04', 'Proporcionar directrices para cada estructura de gestión (incluido el mandato, los objetivos, los asistentes a las reuniones, el calendario, el seguimiento, la supervisión y la vigilancia), así como los insumos necesarios y los resultados esperados de las reuniones.', 3, 'Collabtive', 'Facilita cronogramas y responsables, aunque no es específico.', 'Funcional para seguimiento y documentación de reuniones.', 'Se puede coomplementar con una herramienta de documentación como open office'),

('APO01-P04-A08', 'APO01-P04', 'Verificar periódicamente la adecuación y eficacia de las estructuras organizativas.', 4, 'Eramba', 'Ofrece reportes para verificar cumplimiento organizacional.', 'Aporta control sobre efectividad estructural desde el cumplimiento.', 'Se puede coomplementar con una herramienta de documentación como open office'),

('APO01-P05-A01', 'APO01-P05', 'Establecer, acordar y comunicar las funciones y responsabilidades relacionadas con I&T para todo el personal de la empresa, en consonancia con las necesidades y objetivos del negocio. Definir claramente las responsabilidades y obligaciones, especialmente en lo que respecta a la toma de decisiones y las aprobaciones.', 2, 'Archi', 'Permite modelar actores, roles y funciones alineadas con los objetivos del negocio.', 'Ideal para documentar y visualizar la relación entre funciones y decisiones.', '-'),

('APO01-P05-A02', 'APO01-P05', 'Considere los requisitos de continuidad del servicio empresarial y de I&T al definir roles, incluidos los requisitos de respaldo del personal y capacitación cruzada.', 2, 'Eramba', 'Tiene soporte para planes de continuidad asociados a roles.', 'Útil para vincular roles con planes de respaldo.', '-'),

('APO01-P05-A03', 'APO01-P05', 'Proporcionar información al proceso de continuidad del servicio de I&T manteniendo actualizada la información de contacto y las descripciones de roles en la empresa.', 2, 'Eramba', 'Mantiene registros actualizados de responsables y contactos.', 'Vinculado con otros procesos como continuidad o revisiones.', '-'),

('APO01-P05-A04', 'APO01-P05', 'Incluir requisitos específicos en las descripciones de funciones y responsabilidades con respecto al cumplimiento de las políticas y procedimientos de gestión, el código de ética y las prácticas profesionales.', 2, 'Archi', 'Permite incorporar reglas, políticas o prácticas como atributos o relaciones.', 'Útil para alinear roles con marcos de cumplimiento y ética.', '-'),

('APO01-P05-A05', 'APO01-P05', 'Asegúrese de que la rendición de cuentas esté definida a través de roles y responsabilidades.', 2, 'Archi', 'Asocia roles con responsabilidades y autoridades en el modelo.', 'Es claro para representar rendición de cuentas.', '-'),

('APO01-P05-A06', 'APO01-P05', 'Estructurar roles y responsabilidades para reducir la posibilidad de que un solo rol comprometa un proceso crítico.', 2, 'Archi', 'Permite dividir responsabilidades por rol y representar separación de funciones.', 'Facilita visualizar SoD (Segregation of Duties).', '-'),

('APO01-P05-A07', 'APO01-P05', 'Implementar prácticas de supervisión adecuadas para garantizar el correcto ejercicio de las funciones y responsabilidades, evaluar si todo el personal cuenta con la autoridad y los recursos suficientes para desempeñarlas y, en general, evaluar su desempeño. El nivel de supervisión debe estar acorde con la sensibilidad del puesto y el alcance de las responsabilidades asignadas.', 3, NULL, 'La herramienta Eramba, tiene funciones de supervisión y evaluación periódica del cumplimiento.', 'Permite revisar efectividad segun los parametros definidos del rol de cada responsable.', '-'),

('APO01-P06-A01', 'APO01-P06', 'Comprender el contexto para la ubicación de la función de TI, incluida la evaluación de la estrategia empresarial y el modelo operativo (centralizado, federado, descentralizado, híbrido), la importancia de I&T y la situación y las opciones de abastecimiento.', 3, 'Archi', 'Permite modelar el contexto empresarial, estructuras organizativas y opciones de TI.', 'Facilita evaluar alineación entre modelo operativo y estrategia TI.', '-'),

('APO01-P06-A02', 'APO01-P06', 'Identificar, evaluar y priorizar opciones de ubicación organizacional, abastecimiento y modelos operativos.', 3, 'Archi', 'Soporta representación y análisis de distintas alternativas de colocación.', 'Ayuda a comparar centralizado vs. descentralizado visualmente.', '-'),

('APO01-P06-A03', 'APO01-P06', 'Definir la ubicación de la función de TI y obtener un acuerdo.', 3, NULL, 'La herramienta Archi, se pueden documentar decisiones de ubicación y acuerdos.', 'No ejecuta acuerdos, pero soporta su diseño y visualización.', '-'),

('APO01-P07-A01', 'APO01-P07', 'Proporcionar directrices para garantizar una clasificación adecuada y coherente de los elementos de información en toda la empresa.', 3, NULL, 'La herramienta Archi, permite modelar conceptos como entidades de datos, clasificaciones e información.', 'No realiza la clasificación directamente, pero sí su representación estructural.', '-'),

('APO01-P07-A02', 'APO01-P07', 'Crear y mantener un inventario de información (sistemas y datos) que incluya una lista de propietarios, custodios y clasificaciones. Incluya los sistemas subcontratados y aquellos cuya propiedad debe permanecer dentro de la empresa.', 3, 'Archi', 'Permite documentar activos, relaciones y responsables.', 'Ideal para mantener un inventario lógico de sistemas e información.', '-'),

('APO01-P07-A03', 'APO01-P07', 'Evaluar y distinguir entre datos, información y sistemas críticos (de alto valor) y no críticos. Garantizar la protección adecuada para cada categoría.', 3, 'Archi', 'Se pueden identificar relaciones entre sistemas y nivel de criticidad.', 'Ayuda a visualizar y documentar la diferenciación entre información crítica y no crítica.', '-'),

('APO01-P08-A01', 'APO01-P08', 'Identificar las habilidades y competencias necesarias para alcanzar los objetivos de gestión seleccionados.', 2, 'Eramba', 'Permite definir roles, responsabilidades y asociar competencias clave para cumplir controles y políticas.', 'Aporta desde el enfoque de cumplimiento y seguridad. Puede usarse para mapear necesidades clave de competencias.', '-'),

('APO01-P08-A02', 'APO01-P08', 'Analice la brecha entre las competencias y capacidades objetivo de la empresa y las competencias actuales de la plantilla. Consulte APO07ùGestión de Recursos Humanos para obtener información sobre prácticas de desarrollo y gestión de competencias.', 2, 'Eramba', 'Tiene funcionalidades para identificar brechas en cumplimiento o responsabilidades asignadas, útil para traducirlo en necesidades de desarrollo.', 'Aunque no está orientada directamente a RRHH, puede adaptarse en contextos de cumplimiento regulatorio o de control.', '-'),

('APO01-P09-A01', 'APO01-P09', 'Crear un conjunto de políticas para impulsar las expectativas de control de TI en temas clave relevantes como calidad, seguridad, privacidad, confidencialidad, controles internos, uso de activos de TI y T, ética y derechos de propiedad intelectual (PI).', 3, 'Eramba', 'Diseñada específicamente para la definición y gestión de políticas, alineadas a riesgos, controles, normas.', '-', '-'),

('APO01-P09-A02', 'APO01-P09', 'Implementar y hacer cumplir las políticas de I&T de manera uniforme para todo el personal relevante, de modo que se integren y se conviertan en partes integrales de las operaciones de la empresa.', 3, 'Eramba', 'Permite asignar políticas a personas, registrar aceptación y evaluar cumplimiento.', 'Hace parte del ciclo de gestión de políticas.', '-'),

('APO01-P09-A03', 'APO01-P09', 'Evaluar y actualizar las políticas al menos una vez al año para adaptarse a los cambios en el entorno operativo o comercial.', 4, 'Eramba', 'Permite calendarizar revisiones y versionar políticas conforme cambian los entornos.', 'Facilita seguimiento y trazabilidad del ciclo de vida de políticas.', '-'),

('APO01-P10-A01', 'APO01-P10', 'Identificar los objetivos de gestión prioritarios que pueden lograrse mediante la automatización de servicios, aplicaciones o infraestructura.', 2, 'Eramba', 'Al gestionar riesgos y controles, permite alinear prácticas con herramientas que mitigan brechas de cumplimiento.', 'Ofrece trazabilidad para justificar adopción de herramientas en función de riesgos u objetivos.', '-'),

('APO01-P10-A02', 'APO01-P10', 'Seleccionar e implementar las herramientas más adecuadas y comunicarlas a las partes interesadas.', 2, 'Eramba', 'Permite integrar herramientas externas mediante enlaces y procesos de control.', 'Ofrece gestión integrada con visibilidad para stakeholders.', '-'),

('APO01-P10-A03', 'APO01-P10', 'Proporcionar capacitación sobre herramientas seleccionadas, según sea necesario.', 2, 'Eramba', 'Tiene funcionalidades para asignar usuarios responsables y seguimiento a campañas de concientización y formación.', 'Soporta gestión de campañas de formación con seguimiento.', '-'),

('APO01-P11-A01', 'APO01-P11', 'Evaluar periódicamente el rendimiento de los componentes del marco y tomar las medidas apropiadas.', 4, 'Archi', 'Permite modelar y visualizar componentes del marco, facilitando evaluaciones periódicas del rendimiento estructural.', 'No realiza evaluación automática, pero es útil para análisis estructurado.', 'Se puede coomplementar con una herramienta de documentación como open office'),

('APO01-P11-A02', 'APO01-P11', 'Identificar los procesos críticos para el negocio según los factores de rendimiento y cumplimiento, así como los riesgos asociados. Evaluar la capacidad e identificar objetivos de mejora. Analizar las deficiencias en la capacidad y el control. Identificar opciones para mejorar o rediseñar el proceso.', 4, NULL, 'La herramienta Archi, puede representar procesos críticos y analizar relaciones entre capacidades, riesgos y controles.', 'No permite evaluar capacidades en tiempo real.', '-'),

('APO01-P11-A03', 'APO01-P11', 'Priorizar las iniciativas de mejora según los posibles beneficios y costos. Implementar las mejoras acordadas, operar con normalidad y establecer objetivos y métricas de rendimiento para permitir el seguimiento de las mejoras.', 5, 'Eramba', 'Soporta la definición, ejecución y seguimiento de mejoras con base en planes de tratamiento.', 'Permite seguimiento estructurado.', '-'),

('APO01-P11-A04', 'APO01-P11', 'Considere formas de mejorar la eficiencia y la eficacia (por ejemplo, mediante capacitación, documentación, estandarización y/o automatización de procesos).', 5, 'Eramba', 'Tiene módulo de campañas de concientización, documenta políticas, automatiza revisiones.', 'Muy apropiado para mejora continua.', '-'),

('APO01-P11-A05', 'APO01-P11', 'Aplicar prácticas de gestión de calidad para actualizar el proceso.', 5, 'Archi', 'Puede servir como apoyo visual y documental para actualización de procesos bajo prácticas de calidad.', 'Debido a la naturalidad de la actividad la herramienta solo es de apoyo', '-'),

('APO01-P11-A06', 'APO01-P11', 'Retirar los componentes de gobernanza obsoletos (procesos, elementos de información, políticas, etc.).', 5, NULL, 'La herramienta Archi, permite visualizar qué elementos del marco ya no tienen relaciones funcionales y pueden retirarse.', 'Ideal para detección estructural de obsolescencia.', '-'),

('APO02-P01-A01', 'APO02-P01', 'Desarrollar y mantener una comprensión del entorno externo de la empresa.', 2, 'Archi', 'Permite modelar actores y factores externos en vistas de motivación o estrategia.', 'Ideal para representar factores externos que afectan a la empresa.', '-'),

('APO02-P01-A02', 'APO02-P01', 'Desarrollar y mantener una comprensión de la forma actual de trabajar, incluido el entorno operativo, la arquitectura empresarial (dominios de negocios, información, datos, aplicaciones y tecnología), la cultura empresarial y los desafíos actuales.', 2, 'Archi', 'Modela arquitecturas organizacionales actuales y mapea procesos, aplicaciones y cultura.', 'Herramienta idónea para representar la forma actual de trabajar.', '-'),

('APO02-P01-A03', 'APO02-P01', 'Desarrollar y mantener una comprensión de la dirección futura de la empresa, incluyendo la estrategia, las metas y los objetivos empresariales. Comprender el nivel de ambición de la empresa en términos de digitalización, que puede incluir una gama de objetivos cada vez más ambiciosos, desde la reducción de costes, una mayor orientación al cliente o una mayor comercialización mediante la digitalización de las operaciones internas, hasta la creación de nuevas fuentes de ingresos a partir de nuevos modelos de negocio (por ejemplo, negocios de plataforma).', 2, 'Archi', 'Soporta modelado de visión, metas, drivers y objetivos a futuro.', 'Permite representar ambiciones digitales, objetivos y modelos de negocio emergentes.', '-'),

('APO02-P01-A04', 'APO02-P01', 'Identificar a las partes interesadas clave y obtener información sobre sus requisitos.', 2, 'Archi', 'Facilita la identificación de actores clave mediante vistas de stakeholders.', 'Muy eficaz para representar requerimientos y relaciones de los interesados.', '-'),

('APO02-P02-A01', 'APO02-P02', 'Desarrollar una línea base de las capacidades y servicios empresariales y de I&T actuales. Incluir la evaluación de los servicios externos, la gobernanza de I&T y las habilidades y competencias relacionadas con I&T a nivel empresarial.', 2, 'Eramba', 'Permite documentar capacidades y servicios actuales, y realizar evaluaciones de control, riesgo y cumplimiento.', 'Útil para mapear controles y madurez en gobernanza de I&T.', '-'),

('APO02-P02-A02', 'APO02-P02', 'Evaluar la madurez digital en diferentes dimensiones (p. ej., capacidad del liderazgo para aprovechar la tecnología, nivel de riesgo tecnológico aceptado, enfoque hacia la innovación, cultura y nivel de conocimiento de los usuarios). Evaluar la predisposición al cambio.', 3, 'Eramba', 'Incluye métricas y frameworks para evaluar madurez organizacional y aceptación del riesgo.', 'Ofrece evaluaciones cualitativas que pueden adaptarse a niveles de madurez digital.', '-'),

('APO02-P03-A01', 'APO02-P03', 'Resumir el contexto y la dirección de la empresa e identificar aspectos específicos de I&T de la estrategia empresarial (por ejemplo, digitalización de procesos, implementación de nueva tecnología, soporte de arquitectura heredada, aplicación de nuevos modelos de negocios digitales, desarrollo de cartera de productos digitales, etc.).', 2, 'Archi', 'Permite mapear el contexto, drivers de negocio y vincularlos a capacidades I&T.', 'Muy eficaz para representar la alineación entre estrategia y capacidades tecnológicas.', '-'),

('APO02-P03-A02', 'APO02-P03', 'Definir objetivos y metas de I&T de alto nivel y especificar su contribución a los objetivos de la empresa.', 2, 'Archi', 'Permite definir objetivos, metas y capacidades de soporte alineadas con la estrategia.', 'Ideal para trazabilidad entre objetivos empresariales e I&T.', '-'),

('APO02-P03-A03', 'APO02-P03', 'Detallar los servicios y productos de I&T necesarios para alcanzar los objetivos empresariales. Considerar las tecnologías emergentes validadas o ideas innovadoras, los estándares de referencia, las capacidades de I&T y de negocios de la competencia, los puntos de referencia comparativos de buenas prácticas y la prestación de servicios de I&T emergentes.', 3, 'Archi', 'Permite detallar catálogos de servicios y vincularlos con tecnologías emergentes y capacidades requeridas.', 'Útil para planificar soluciones emergentes y capacidades.', '-'),

('APO02-P03-A04', 'APO02-P03', 'Determine las capacidades, metodologías y enfoques organizativos de I&T necesarios para implementar la cartera de productos y servicios de I&T definida. Considere diferentes metodologías de desarrollo (Agile, Scrum, cascada, TI bimodal) según los requisitos del negocio. Analice cómo cada una podría contribuir al logro de los objetivos de I&T.', 3, 'Archi', 'Modela escenarios con distintas metodologías (Agile, bimodal, cascada) y su efecto sobre objetivos.', 'Permite representar gráficamente cómo las metodologías apoyan la entrega de valor I&T.', '-'),

('APO02-P04-A01', 'APO02-P04', 'Identificar todas las brechas y los cambios necesarios para lograr el entorno objetivo.', 3, 'Archi', 'Permite comparar el estado actual con el estado objetivo modelado y detectar brechas visualmente.', 'Diseñado para análisis de transformación estructural.', '-'),

('APO02-P04-A02', 'APO02-P04', 'Describir cambios de alto nivel en la arquitectura empresarial (dominios de negocios, información, datos, aplicaciones y tecnología).', 3, 'Archi', 'Soporta modelado detallado de todos los dominios de arquitectura empresarial.', 'Ideal para representar cambios a alto nivel.', '-'),

('APO02-P04-A03', 'APO02-P04', 'Considere las implicaciones generales de todas las brechas. Evalúe el impacto de los posibles cambios en los modelos operativos de negocio y de TI, las capacidades de investigación y desarrollo de TI y los programas de inversión en TI.', 3, 'Archi', 'Permite representar el impacto de cambios arquitectónicos en capacidades de negocio y TI.', 'Vincula brechas con implicancias estratégicas.', '-'),

('APO02-P04-A04', 'APO02-P04', 'Considere el valor de los cambios potenciales en las capacidades de negocios y TI, los servicios de I&T y la arquitectura empresarial, y las implicaciones si no se realizan cambios.', 4, 'Archi', 'Soporta análisis de valor y escenarios, incluyendo consecuencias de no actuar.', 'Permite ilustrar pérdida de valor o estancamiento por inacción.', '-'),

('APO02-P04-A05', 'APO02-P04', 'Refinar la definición del entorno objetivo y preparar una declaración de valor que describa los beneficios del entorno objetivo.', 4, 'Archi', 'Facilita el modelado del entorno objetivo y la creación de una narrativa de beneficios esperados.', 'Excelente para justificar decisiones de transformación digital.', '-'),

('APO02-P05-A01', 'APO02-P05', 'Definir las iniciativas necesarias para cerrar las brechas entre el entorno actual y el objetivo. Integrar las iniciativas en una estrategia de I&T coherente que alinee la I&T con todos los aspectos del negocio.', 3, 'Archi', 'Permite definir y vincular iniciativas con brechas arquitectónicas identificadas.', 'Excelente para representar evolución estratégica.', '-'),

('APO02-P05-A02', 'APO02-P05', 'Detallar una hoja de ruta que defina los pasos incrementales necesarios para alcanzar las metas y objetivos de la estrategia de I&T. Asegurarse de que se incluyan acciones para capacitar al personal con nuevas habilidades, apoyar la adopción de nuevas tecnologías, mantener el cambio en toda la organización, etc.', 3, 'Archi', 'Soporta modelado de hojas de ruta y secuencias de implementación a través de vistas temporales.', 'Visualiza progresos y transición hacia el objetivo.', '-'),

('APO02-P05-A03', 'APO02-P05', 'Considere el ecosistema externo (socios empresariales, proveedores, empresas emergentes, etc.) para ayudar a respaldar la ejecución de la hoja de ruta.', 3, 'Archi', 'Modela relaciones con stakeholders externos y ecosistemas mediante vistas de motivación y colaboración.', 'Muy útil para análisis de entorno extendido.', '-'),

('APO02-P05-A04', 'APO02-P05', 'Agrupe las acciones en programas o proyectos con un objetivo o resultado claro. Para cada proyecto, identifique los principales requisitos de recursos, el cronograma, el presupuesto de inversión/operativo, el riesgo, el impacto del cambio, etc.', 3, 'Archi', 'Agrupa proyectos con recursos, objetivos y dependencias representadas gráficamente.', 'Ideal para estructurar proyectos estratégicos.', '-'),

('APO02-P05-A05', 'APO02-P05', 'Determinar dependencias, superposiciones, sinergias e impactos entre proyectos y priorizar.', 3, 'Archi', 'Representa visualmente dependencias, sinergias e impactos entre iniciativas.', 'Soporta priorización visual.', '-'),

('APO02-P05-A06', 'APO02-P05', 'Finalizar la hoja de ruta, indicando la programación relativa y las interdependencias de los proyectos.', 3, 'Archi', 'Ofrece líneas de tiempo y dependencias cruzadas entre iniciativas.', 'Alto nivel de control de ejecución estratégica.', '-'),

('APO02-P05-A07', 'APO02-P05', 'Asegúrese de centrarse en el proceso de transformación. Designe a un líder para la transformación digital y la alineación entre el negocio y las tecnologías de la información y las comunicaciones (director digital [CDO] u otro puesto tradicional de alta dirección).', 3, 'Archi', 'Representa estructuras organizativas y liderazgos estratégicos definidos.', 'Permite asignar roles de liderazgo digital.', '-'),

('APO02-P05-A08', 'APO02-P05', 'Obtener el apoyo y la aprobación formal del plan por parte de las partes interesadas.', 3, 'Archi', 'Documenta formalmente decisiones estratégicas y validación por stakeholders.', 'Integra aprobación en el modelo de transformación.', '-'),

('APO02-P05-A09', 'APO02-P05', 'Traducir los objetivos en resultados medibles representados por métricas (qué) y metas (cuánto). Asegurar que los resultados y las medidas se correlacionen con los beneficios empresariales.', 4, 'Archi', 'Asocia objetivos a métricas y resultados esperados mediante vistas de rendimiento.', 'Vincula metas estratégicas con métricas de valor.', '-'),

('APO02-P06-A01', 'APO02-P06', 'Desarrollar un plan de comunicación que cubra los mensajes requeridos, públicos objetivos, mecanismos/canales de comunicación y cronogramas.', 3, 'Archi', 'Permite modelar el flujo de comunicación y actores involucrados en la estrategia.', 'Ideal para representar planes de comunicación formales y visuales.', '-'),

('APO02-P06-A02', 'APO02-P06', 'Preparar un paquete de comunicación que transmita el plan de manera efectiva, utilizando los medios y tecnologías disponibles.', 3, 'Archi', 'Puede construir vistas formales de paquetes comunicacionales para transmitir estrategia.', 'Excelente para materiales de alto nivel dirigidos a diferentes públicos.', '-'),

('APO02-P06-A03', 'APO02-P06', 'Desarrollar y mantener una red para respaldar, apoyar e impulsar la estrategia de I&T.', 4, 'Archi', 'Soporta representación gráfica de redes organizativas e iniciativas que respaldan la estrategia.', 'Visualiza quiénes influyen, apoyan o ejecutan la estrategia.', '-'),

('APO02-P06-A04', 'APO02-P06', 'Obtener retroalimentación y actualizar el plan de comunicación y su entrega según sea necesario.', 4, 'Archi', 'Permite modelar ciclos de retroalimentación y mejora continua del plan comunicacional.', 'Muy eficaz para planificación comunicativa iterativa.', '-'),

('APO03-P01-A01', 'APO03-P01', 'Identificar a las partes interesadas clave y sus inquietudes/objetivos. Definir los requisitos empresariales clave que deben abordarse, así como las perspectivas de arquitectura que deben desarrollarse para satisfacer las necesidades de las partes interesadas.', 2, 'Eramba', 'Identifica stakeholders relacionados con cumplimiento y riesgo.', 'Útil en entornos regulados.', '-'),

('APO03-P01-A02', 'APO03-P01', 'Identificar los objetivos empresariales y los impulsores estratégicos. Definir las limitaciones que deben abordarse, tanto a nivel de la empresa como de cada proyecto (p. ej., tiempo, cronograma, recursos, etc.).', 2, 'Eramba', 'Documenta objetivos normativos y restricciones estratégicas.', 'Se enfoca en control.', '-'),

('APO03-P01-A03', 'APO03-P01', 'Alinear los objetivos de la arquitectura con las prioridades estratégicas del programa.', 2, 'Archi', 'Permite trazabilidad entre objetivos de negocio y decisiones arquitectónicas.', 'Asegura coherencia con planes estratégicos.', '-'),

('APO03-P01-A04', 'APO03-P01', 'Comprender las capacidades y los objetivos de la empresa y luego identificar las opciones para alcanzar esos objetivos.', 2, 'Eramba', 'Puede evaluar preparación al cambio mediante cumplimiento y madurez.', 'Diagnóstico básico.', '-'),

('APO03-P01-A05', 'APO03-P01', 'Evaluar la preparación de la empresa para el cambio.', 2, NULL, 'La herramienta Archi, puede representar niveles de madurez, restricciones y readiness para transformación.', 'Apto para análisis de impacto y readiness.', '-'),

('APO03-P01-A06', 'APO03-P01', 'Defina el alcance de la arquitectura base y la arquitectura objetivo. Enumere los elementos dentro y fuera del alcance. (La arquitectura base y la arquitectura objetivo no necesitan describirse con el mismo nivel de detalle).', 2, NULL, 'La herramienta Archi, modela arquitectura actual y futura con vistas comparativas.', 'Permite delimitar dominio y evolución.', '-'),

('APO03-P01-A07', 'APO03-P01', 'Comprender las metas y objetivos estratégicos empresariales actuales. Trabajar dentro del proceso de planificación estratégica para garantizar que las oportunidades de arquitectura empresarial relacionadas con I&T se aprovechen en el desarrollo del plan estratégico.', 2, NULL, 'La herramienta Archi, vincula iniciativas de arquitectura con procesos de planificación estratégica.', 'Facilita participación en procesos de planificación.', '-'),

('APO03-P01-A08', 'APO03-P01', 'Con base en las preocupaciones de las partes interesadas, los requisitos de capacidad del negocio, el alcance, las restricciones y los principios, crear la visión de la arquitectura (es decir, la visión de alto nivel de las arquitecturas de referencia y de destino).', 2, 'Eramba', 'Gestiona principios y políticas organizacionales.', 'Muy útil para entornos formales.', '-'),

('APO03-P01-A09', 'APO03-P01', 'Confirmar y desarrollar los principios de arquitectura, incluyendo los principios empresariales. Asegurarse de que las definiciones existentes estén actualizadas. Aclarar cualquier ambig³edad.', 3, 'Eramba', 'Identifica y evalúa riesgos de cambio.', 'Puede ser adaptado al contexto arquitectónico.', '-'),

('APO03-P01-A10', 'APO03-P01', 'Identifique el riesgo de cambio empresarial asociado con la visión de la arquitectura. Evalúe el nivel inicial de riesgo (p. ej., crítico, marginal o insignificante). Desarrolle una estrategia de mitigación para cada riesgo significativo.', 3, 'Archi', 'Permite relacionar elementos arquitectónicos con riesgos y planes de mitigación.', 'Ideal para gestionar cambio desde arquitectura.', '-'),

('APO03-P01-A11', 'APO03-P01', 'Desarrollar un caso de negocio conceptual de arquitectura empresarial y definir los planes y la declaración del trabajo de arquitectura. Obtener la aprobación para iniciar un proyecto alineado e integrado con la estrategia empresarial.', 3, 'Archi', 'Se pueden modelar entregables, hitos y beneficios arquitectónicos.', 'Compatible con estructuras de TOGAF.', '-'),

('APO03-P01-A12', 'APO03-P01', 'Definir las propuestas de valor, los objetivos y las métricas de la arquitectura objetivo.', 4, 'Archi', 'Vincula objetivos arquitectónicos con métricas y beneficios empresariales.', 'Permite seguimiento del valor entregado.', '-'),

('APO03-P02-A01', 'APO03-P02', 'Mantener un repositorio de arquitectura que contenga estándares, componentes reutilizables, artefactos de modelado, relaciones, dependencias y vistas, para permitir la uniformidad de la organización y el mantenimiento de la arquitectura.', 3, 'Archi', 'Archi permite mantener un repositorio de artefactos con relaciones, vistas, componentes reutilizables y capas arquitectónicas.', 'Ideal para mantener uniformidad y trazabilidad de arquitectura empresarial.', '-'),

('APO03-P02-A02', 'APO03-P02', 'Seleccionar puntos de vista de referencia del repositorio de arquitectura que permitan al arquitecto demostrar cómo se abordan las inquietudes de las partes interesadas en la arquitectura.', 3, 'Archi', 'Permite seleccionar y estructurar puntos de vista para responder a necesidades específicas de stakeholders.', 'Soporta comunicación de arquitectura personalizada según audiencia.', '-'),

('APO03-P02-A03', 'APO03-P02', 'Para cada perspectiva, seleccione los modelos necesarios para respaldar la perspectiva específica requerida. Utilice las herramientas o métodos seleccionados y el nivel de descomposición adecuado.', 3, 'Archi', 'Puedes seleccionar y construir modelos específicos por capa (negocio, información, tecnología, etc.).', 'Soporta múltiples niveles de descomposición según necesidad.', '-'),

('APO03-P02-A04', 'APO03-P02', 'Desarrollar descripciones de dominios arquitectónicos de referencia, utilizando el alcance y el nivel de detalle necesarios para respaldar la arquitectura de destino y, en la medida de lo posible, identificando los bloques de construcción de arquitectura relevantes del repositorio de arquitectura.', 3, 'Archi', 'Puedes crear descripciones detalladas de dominios de arquitectura base y objetivo, con bloques reutilizables.', 'Ideal para crear escenarios de arquitectura destino.', '-'),

('APO03-P02-A05', 'APO03-P02', 'Mantener un modelo de arquitectura de procesos como parte de las descripciones de los dominios de referencia y objetivo. Estandarizar las descripciones y la documentación de los procesos. Definir las funciones y responsabilidades de los responsables de la toma de decisiones, el propietario, los usuarios, el equipo y cualquier otra parte interesada que deba participar.', 3, 'Archi', 'Puedes documentar procesos, roles, decisiones y responsables mediante elementos estructurados.', 'Facilita la formalización de responsabilidades arquitectónicas.', '-'),

('APO03-P02-A06', 'APO03-P02', 'Mantener un modelo de arquitectura de información como parte de las descripciones de los dominios de referencia y de destino, coherente con la estrategia empresarial para adquirir, almacenar y utilizar datos de manera óptima en apoyo de la toma de decisiones.', 3, 'Archi', 'Soporta la representación de datos, objetos de negocio, flujos y almacenamiento alineado a estrategia.', 'Útil para representar estrategia de datos y soporte a decisiones.', '-'),

('APO03-P02-A07', 'APO03-P02', 'Verificar la consistencia y precisión interna de los modelos de arquitectura. Realizar un análisis de brechas entre la línea base y el objetivo. Priorizar las brechas y definir los componentes nuevos o modificados que deben desarrollarse para la arquitectura objetivo. Resolver incompatibilidades, inconsistencias o conflictos dentro de la arquitectura objetivo.', 3, 'Archi', 'Permite comparar arquitectura base vs objetivo y realizar análisis de inconsistencias o conflictos.', 'Soporte completo para gestionar transformación estructurada.', '-'),

('APO03-P02-A08', 'APO03-P02', 'Realizar una revisión formal de las partes interesadas comparando la arquitectura propuesta con la intención original del proyecto de arquitectura y la declaración del trabajo de arquitectura.', 3, 'Archi', 'Permite generar modelos y documentación para revisión, con trazabilidad hacia requerimientos iniciales.', 'Apoya el ciclo de aprobación y retroalimentación formal.', '-'),

('APO03-P02-A09', 'APO03-P02', 'Finalizar las arquitecturas de negocio, información, datos, aplicaciones y dominios tecnológicos. Crear un documento de definición de arquitectura.', 3, 'Archi', 'Exporta modelos, vistas y estructuras completas para consolidar documento formal.', 'Cubre todos los dominios: negocio, datos, aplicaciones y tecnología.', '-'),

('APO03-P03-A01', 'APO03-P03', 'Determinar y confirmar los atributos clave del cambio empresarial. Considerar la cultura empresarial, su posible impacto en la implementación de la arquitectura y las capacidades de la empresa para la transición.', 3, 'Archi', 'Permite modelar capacidades, cultura organizacional y su impacto sobre la arquitectura objetivo.', 'Apto para planificación estructural de la transformación.', '-'),

('APO03-P03-A02', 'APO03-P03', 'Identifique cualquier factor empresarial que pueda limitar la secuencia de implementación. Incluya una revisión de los planes estratégicos y de negocio de la empresa y de cada línea de negocio. Considere la madurez actual de la arquitectura empresarial.', 3, 'Archi', 'Permite representar restricciones, secuencias lógicas, planes estratégicos y madurez de arquitectura.', 'Útil para identificar dependencias y condiciones iniciales.', '-'),

('APO03-P03-A03', 'APO03-P03', 'Revisar y consolidar los resultados del análisis de brechas entre las arquitecturas de referencia y las arquitecturas objetivo. Evaluar las implicaciones respecto a las posibles soluciones, oportunidades, interdependencias y la alineación con los programas actuales basados en I+D.', 3, 'Archi', 'Integra el análisis entre arquitectura base y objetivo, visualizando soluciones viables.', 'Aporta trazabilidad entre escenarios y decisiones.', '-'),

('APO03-P03-A04', 'APO03-P03', 'Evaluar requisitos, brechas, soluciones y otros factores para identificar un conjunto mínimo de requisitos funcionales cuya integración en paquetes de trabajo conduciría a una implementación más eficiente y efectiva de la arquitectura de destino.', 3, 'Archi', 'Permite agrupar funcionalidades y elementos arquitectónicos en bloques estructurados.', 'Ideal para planificación por fases.', '-'),

('APO03-P03-A05', 'APO03-P03', 'Conciliar los requisitos consolidados con las soluciones potenciales.', 3, 'Archi', 'Soporta vinculación entre necesidades y capacidades, permitiendo reconciliación formal.', 'Facilita validación de soluciones.', '-'),

('APO03-P03-A06', 'APO03-P03', 'Refinar las dependencias iniciales e identificar las limitaciones en los planes de implementación y migración. Elaborar un informe de análisis de dependencias.', 3, 'Archi', 'Modela relaciones, restricciones y dependencias entre componentes.', 'Ayuda a prever bloqueos o conflictos.', '-'),

('APO03-P03-A07', 'APO03-P03', 'Confirmar la preparación de la empresa para la transformación empresarial y el riesgo asociado a ella.', 3, 'Archi', 'Integra modelado de preparación, evaluación de madurez y riesgos asociados.', 'Compatible con gestión de transformación digital.', '-'),

('APO03-P03-A08', 'APO03-P03', 'Formular una estrategia general para la implementación y la migración. Implementar la arquitectura objetivo (y organizar cualquier arquitectura de transición) de acuerdo con la estrategia, los objetivos y los plazos generales de la empresa.', 3, 'Archi', 'Permite diseñar estrategias de migración y transición, con rutas definidas hacia la arquitectura destino.', 'Cubre desde diseño hasta ejecución táctica.', '-'),

('APO03-P03-A09', 'APO03-P03', 'Identificar y agrupar los principales paquetes de trabajo en un conjunto coherente de programas y proyectos, respetando la dirección y el enfoque de la implementación estratégica empresarial.', 3, 'Archi', 'Permite organizar, priorizar y trazar programas estructurados alineados con objetivos estratégicos.', 'Compatible con metodologías TOGAF y COBIT.', '-'),

('APO03-P03-A10', 'APO03-P03', 'Desarrollar arquitecturas de transición donde el alcance del cambio requerido por la arquitectura de destino requiera un enfoque incremental.', 3, 'Archi', 'Modela arquitecturas temporales, identificando las etapas para la implementación total.', 'Permite enfoque incremental realista.', '-'),

('APO03-P04-A01', 'APO03-P04', 'Establecer los elementos necesarios en el plan de implementación y migración como parte de la planificación del programa y del proyecto. Asegurarse de que el plan se ajuste a los requisitos de los responsables de la toma de decisiones.', 3, 'Archi', 'Define elementos de implementación alineados a decisiones estratégicas.', 'Totalmente alineado con COBIT y TOGAF.', '-'),

('APO03-P04-A02', 'APO03-P04', 'Confirmar los incrementos y las fases de la arquitectura de transición. Actualizar el documento de definición de la arquitectura.', 3, 'Archi', 'Permite modelar y actualizar fases de transición.', 'Soporte completo para evolución progresiva.', '-'),

('APO03-P04-A03', 'APO03-P04', 'Definir y completar el plan de implementación y migración de la arquitectura, incluyendo los requisitos de gobernanza pertinentes. Integrar el plan, las actividades y las dependencias en la planificación de programas y proyectos.', 3, 'Archi', 'Integra gobernanza, actividades, hitos y dependencias.', 'Ideal para proyectos complejos de transformación.', '-'),

('APO03-P04-A04', 'APO03-P04', 'Comunicar la hoja de ruta arquitectónica definida a las partes interesadas relevantes. Informar a las partes interesadas sobre la definición de la arquitectura objetivo, las directrices y principios de la arquitectura, la cartera de servicios, etc.', 3, 'Archi', 'Comunica visual y documentalmente la hoja de ruta arquitectónica.', 'Documentación clara para revisión y validación.', '-'),

('APO03-P05-A01', 'APO03-P05', 'Confirmar el alcance y las prioridades y brindar orientación para el desarrollo y la implementación de soluciones (por ejemplo, mediante el uso de una arquitectura orientada a servicios).', 3, 'Archi', 'Soporta definición de alcance, prioridades y orientación para soluciones.', 'Ideal para planificación e implementación continua.', '-'),

('APO03-P05-A02', 'APO03-P05', 'Gestionar los requisitos de la arquitectura empresarial y brindar apoyo al negocio y a TI con asesoramiento y experiencia sobre principios, modelos y componentes arquitectónicos. Garantizar que las nuevas implementaciones (así como los cambios en la arquitectura actual) se ajusten a los principios y requisitos de la arquitectura empresarial.', 3, 'Archi', 'Permite gestión de requisitos, principios y cumplimiento de arquitectura.', 'Traza alineación entre soluciones y directrices.', '-'),

('APO03-P05-A03', 'APO03-P05', 'Gestionar la cartera de servicios de arquitectura empresarial y garantizar la alineación con los objetivos estratégicos y el desarrollo de soluciones.', 3, 'Archi', 'Administra cartera de servicios y alinea soluciones con objetivos estratégicos.', 'Facilita planificación estructurada.', '-'),

('APO03-P05-A04', 'APO03-P05', 'Identificar las prioridades de la arquitectura empresarial. Alinear las prioridades con los factores de valor. Definir y recopilar métricas de valor, y medir y comunicar el valor de la arquitectura empresarial.', 4, 'Archi', 'Modela prioridades, métricas de valor y permite comunicar beneficios.', 'Soporte total a gestión del valor arquitectónico.', '-'),

('APO03-P05-A05', 'APO03-P05', 'Establecer un foro tecnológico para proporcionar directrices arquitectónicas, asesorar en proyectos y guiar la selección de tecnología. Medir el cumplimiento de las normas y directrices, incluyendo el cumplimiento de los requisitos externos y la relevancia interna del negocio.', 5, 'Archi', 'Soporta la creación de foros de decisiones tecnológicas con trazabilidad.', 'Perfecto para alinear decisiones con estrategia y normativas.', '-'),

('APO04-P01-A01', 'APO04-P01', 'Crear un plan de innovación que incluya el apetito por el riesgo, un presupuesto propuesto para iniciativas de innovación y objetivos de innovación.', 2, 'Collabtive', 'Permite registrar metas, tareas y responsables dentro de proyectos.', 'Puede adaptarse si se documenta correctamente.', '-'),

('APO04-P01-A02', 'APO04-P01', 'Proporcionar infraestructura que pueda ser un componente de gobernanza para la innovación (por ejemplo, herramientas de colaboración para mejorar el trabajo entre ubicaciones geográficas y/o divisiones).', 2, 'Collabtive', 'Herramienta diseñada para colaboración distribuida.', 'Muy útil para trabajo entre ubicaciones y equipos.', '-'),

('APO04-P01-A03', 'APO04-P01', 'Mantener un programa que permita al personal presentar ideas de innovación y crear una estructura de toma de decisiones adecuada para evaluar y hacer avanzar las ideas.', 3, 'Collabtive', 'Puede abrir tareas o temas para recibir ideas del personal.', 'Estructura informal de innovación interna.', '-'),

('APO04-P01-A04', 'APO04-P01', 'Fomentar las ideas de innovación de los clientes, proveedores y socios comerciales.', 3, 'Collabtive', 'Pueden habilitarse espacios colaborativos con clientes/usuarios.', 'Herramienta de colaboracion debido a la caracteristica de la actividad', '-'),

('APO04-P02-A01', 'APO04-P02', 'Mantener un conocimiento profundo de los impulsores de la industria y el negocio, la estrategia empresarial y de I+T, así como de las operaciones empresariales y los desafíos actuales. Aplicar este conocimiento para identificar tecnologías con potencial de valor añadido e innovar en I+T.', 2, 'GLPI', 'Permite registrar información operativa, incidencias y activos de TI relacionados con procesos del negocio.', 'No orientado directamente al análisis estratégico, pero puede adaptarse.', '-'),

('APO04-P02-A02', 'APO04-P02', 'Realizar reuniones periódicas con unidades de negocio, divisiones y/u otras entidades interesadas para comprender los problemas de negocio actuales, los cuellos de botella de los procesos u otras limitaciones donde las tecnologías emergentes o la innovación en I&T pueden crear oportunidades.', 3, 'GLPI', 'Pueden programarse reuniones, registrar incidencias y comentarios entre equipos.', 'Puede servir como soporte para recolectar necesidades operativas.', 'GLPI Calendar'),

('APO04-P02-A03', 'APO04-P02', 'Comprender los parámetros de inversión empresarial en innovación y nuevas tecnologías para desarrollar estrategias adecuadas.', 3, NULL, 'La herramienta Apache Open, herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('APO04-P03-A01', 'APO04-P03', 'Comprender el interés y el potencial de las empresas por la innovación tecnológica. Centrar la atención en las innovaciones tecnológicas más oportunas.', 2, 'GLPI', 'Puede registrar necesidades tecnológicas y tickets que reflejen cambios en tendencias.', 'Puede ayudar a identificar áreas de innovación en el soporte.', '-'),

('APO04-P03-A02', 'APO04-P03', 'Establecer un proceso de vigilancia tecnológica y realizar investigaciones y análisis del entorno externo, incluidos sitios web, revistas y conferencias apropiados, para identificar tecnologías emergentes y su valor potencial para la empresa.', 2, NULL, 'La herramienta Apache Open, herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('APO04-P03-A03', 'APO04-P03', 'Consultar a expertos externos según sea necesario para confirmar la investigación o proporcionar información sobre tecnologías emergentes.', 2, NULL, 'La herramienta Apache Open, herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('APO04-P03-A04', 'APO04-P03', 'Capturar ideas de innovación en TI y tecnología del personal y revisarlas para su posible implementación.', 2, 'GLPI', 'Puede usarse para registrar ideas como tickets o tareas.', 'Estructura básica para canalizar ideas.', '-'),

('APO04-P04-A01', 'APO04-P04', 'Evaluar las tecnologías identificadas, considerando aspectos como el tiempo para alcanzar la madurez, el riesgo inherente (incluidas las posibles implicaciones legales), la adecuación a la arquitectura empresarial y el potencial de valor, en línea con la estrategia empresarial y de I&T.', 2, 'GLPI', 'Puede documentar evaluaciones sobre tecnologías mediante tickets o tareas.', 'Se adapta para registrar, no para evaluar formalmente.', '-'),

('APO04-P04-A02', 'APO04-P04', 'Identificar problemas que puedan necesitar resolverse o validarse a través de una iniciativa de prueba de concepto.', 3, 'GLPI', 'Se pueden registrar problemas en solicitudes o tareas, aunque sin validación técnica.', 'Útil para identificar iniciativas, no para validar pruebas.', '-'),

('APO04-P04-A03', 'APO04-P04', 'Determinar el alcance de la iniciativa de prueba de concepto, incluidos los resultados deseados, el presupuesto requerido, los plazos y las responsabilidades.', 3, 'GLPI', 'Puede detallar responsabilidades y plazos en planes de tareas.', 'Aporta estructura general, no evaluativa.', 'GLPI Projects'),

('APO04-P04-A04', 'APO04-P04', 'Obtener la aprobación para la iniciativa de prueba de concepto.', 3, 'GLPI', 'Puede usarse para registrar ideas como tickets o tareas.', 'Estructura básica para canalizar ideas.', '-'),

('APO04-P04-A05', 'APO04-P04', 'Realizar pruebas de concepto para evaluar tecnologías emergentes u otras ideas innovadoras. Identificar problemas y determinar si se debe considerar la implementación o el despliegue, según la viabilidad y el posible retorno de la inversión (ROI).', 3, 'Apache Dubbo', 'Permite ejecutar pruebas de integración de tecnologías en ambientes de desarrollo.', 'Útil para validación técnica, no para retorno de inversión.', '-'),

('APO04-P05-A01', 'APO04-P05', 'Documentar los resultados de la prueba de concepto, incluyendo orientación y recomendaciones sobre tendencias y programas de innovación.', 3, 'GLPI', 'Permite documentar resultados como tickets o informes en proyectos.', 'No es específico de innovación pero puede adaptarse.', '-'),

('APO04-P05-A02', 'APO04-P05', 'Comunicar oportunidades de innovación viables en la estrategia de I&T y en los procesos de arquitectura empresarial.', 3, NULL, '-', 'Requiere herramienta de comunicacion', '-'),

('APO04-P05-A03', 'APO04-P05', 'Analizar y comunicar las razones de las iniciativas de prueba de concepto rechazadas.', 3, 'GLPI', 'Se pueden registrar motivos de rechazo en los tickets cerrados.', 'Útil si se estructura correctamente.', '-'),

('APO04-P05-A04', 'APO04-P05', 'Dar seguimiento a las iniciativas de prueba de concepto para medir la inversión real.', 4, 'GLPI', 'Puede usarse para hacer seguimiento de recursos invertidos vía tareas.', 'Limitado, no financiero formal.', '-'),

('APO04-P06-A01', 'APO04-P06', 'Capturar lecciones aprendidas y oportunidades de mejora.', 3, 'GLPI', 'Permite documentar incidentes, tareas y retroalimentación de proyectos.', 'Puede registrar lecciones aprendidas y mejoras.', '-'),

('APO04-P06-A02', 'APO04-P06', 'Asegurar que las iniciativas de innovación se alineen con la estrategia empresarial y de I&T. Supervisar la alineación continuamente. Ajustar el plan de innovación, si es necesario.', 3, 'Collabtive', 'Puede vincular tareas con objetivos, aunque sin trazabilidad estratégica.', 'Puede modelarse de forma limitada.', '-'),

('APO04-P06-A03', 'APO04-P06', 'Evaluar las nuevas tecnologías o innovaciones de TI implementadas como parte de la estrategia de TI y el desarrollo de la arquitectura empresarial. Evaluar el nivel de adopción durante la gestión de programas de iniciativas.', 4, 'Issabel', 'Puede monitorear uso de nuevas tecnologías implementadas en call center.', 'Útil para analizar adopción operativa.', '-'),

('APO04-P06-A04', 'APO04-P06', 'Identificar y evaluar el valor potencial de la innovación.', 4, NULL, 'La herramienta Apache Open, herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('APO05-P01-A01', 'APO05-P01', 'Comprender la disponibilidad actual y el compromiso de fondos, el gasto aprobado actual y el gasto real hasta la fecha.', 2, 'GLPI', 'GLPI permite registrar gastos, contratos, y asignaciones presupuestarias básicas.', 'Necesita configuración avanzada para control de fondos.', 'Financial Reports'),

('APO05-P01-A02', 'APO05-P01', 'Identificar opciones para financiación adicional de inversiones habilitadas para I+T, considerando fuentes tanto internas como externas.', 2, NULL, 'La herramienta Apache Open, herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('APO05-P01-A03', 'APO05-P01', 'Determinar las implicaciones de la fuente de financiamiento en las expectativas de retorno de la inversión.', 2, NULL, 'La herramienta Apache Open, herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('APO05-P02-A01', 'APO05-P02', 'Identificar y clasificar las oportunidades de inversión según las categorías de la cartera de inversión. Especificar los resultados empresariales esperados, las iniciativas necesarias para lograrlos, los costos generales, las dependencias y el riesgo. Especificar la metodología para medir los resultados, los costos y el riesgo.', 2, 'GLPI', 'Permite documentar proyectos, riesgos y costos básicos.', 'No clasifica inversiones ni aplica metodologías financieras.', 'Financial Reports'),

('APO05-P02-A02', 'APO05-P02', 'Realizar una evaluación detallada de todos los casos de negocio del programa. Evaluar la alineación estratégica, los beneficios empresariales, los riesgos y la disponibilidad de recursos.', 3, 'GLPI', 'Pueden documentarse casos de negocio como proyectos, sin motor de evaluación.', 'No hace scoring estratégico ni evaluación comparativa.', 'Generic Object Management'),

('APO05-P02-A03', 'APO05-P02', 'Evaluar el impacto de agregar programas potenciales en la cartera general de inversiones, incluidos los cambios que podrían requerirse en otros programas.', 3, NULL, 'La herramienta Apache Open, herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('APO05-P02-A04', 'APO05-P02', 'Decida qué programas candidatos deben transferirse a la cartera de inversión activa. Determine si los programas rechazados deben conservarse para su posterior consideración o recibir financiación inicial para determinar si se puede mejorar el modelo de negocio o descartarlos.', 3, NULL, 'La herramienta Apache Open, herramienta documental, puede servir para reportar los hallazgos', 'Debido a la caracteristica de la actividad, no existe una herramienta que pueda cumplirla, es solo una solución documental', '-'),

('APO05-P02-A05', 'APO05-P02', 'Determinar los hitos necesarios para el ciclo de vida económico completo de cada programa seleccionado. Asignar y reservar el financiamiento total del programa por hito. Incorporar el programa a la cartera de inversión activa.', 3, 'GLPI', 'Puede asociar tareas por hitos, con asignación de responsables y recursos.', 'Sin control de ciclo económico completo.', 'Gantt, GLPI Projects'),

('APO05-P02-A06', 'APO05-P02', 'Establecer procedimientos para comunicar los aspectos relacionados con costos, beneficios y riesgos de las carteras para su consideración en los procesos de priorización presupuestaria, gestión de costos y gestión de beneficios.', 3, 'GLPI', 'Permite documentar, estructurar y comunicar información de cartera. Necesita plugin financiero.', 'Gestiona costos y riesgos. Para beneficios, se requiere plugin.', 'Plugin: "Data Injection" + "Fields" para estructurar campos de costos y beneficios'),

('APO05-P03-A01', 'APO05-P03', 'Revisar la cartera periódicamente para identificar y aprovechar sinergias, eliminar la duplicación entre programas e identificar y mitigar riesgos.', 3, 'GLPI', 'Administra múltiples proyectos y recursos. Permite detectar redundancias.', 'Se recomienda definir tipologías para detectar duplicidades.', '-'),

('APO05-P03-A02', 'APO05-P03', 'Cuando se produzcan cambios, reevaluar y reordenar la cartera para garantizar su alineación con la estrategia de negocio y de I&T. Mantener la combinación de inversiones objetivo para que la cartera optimice el valor general. Se pueden modificar, aplazar o retirar programas, y se pueden iniciar nuevos, para reequilibrar y optimizar la cartera.', 3, 'GLPI', 'Proporciona seguimiento a estado de programas. Permite reevaluación y replanificación.', 'Requiere coordinación con responsables del portafolio.', '-'),

('APO05-P03-A03', 'APO05-P03', 'Ajustar los objetivos, pronósticos, presupuestos y, si es necesario, el nivel de monitoreo de la empresa para reflejar los gastos y beneficios empresariales atribuibles a los programas de la cartera de inversión activa. Repercutir los gastos del programa. Establecer procesos presupuestarios flexibles para que los proyectos prometedores obtengan recursos para escalar rápidamente.', 3, 'GLPI', 'Soporta ajustes presupuestarios y escalamiento mediante modificación de proyectos.', 'Para control detallado de presupuesto se requiere plugin. Plugin: "Financial Plugin"', 'Plugin: "Financial Plugin"'),

('APO05-P03-A04', 'APO05-P03', 'Desarrollar métricas para medir la contribución de I&T a la empresa. Establecer objetivos de rendimiento adecuados que reflejen los objetivos de I&T y de capacidad empresarial requeridos. Utilizar la orientación de expertos externos y datos de referencia para desarrollar métricas.', 4, 'Zabbix', 'Define KPIs técnicos de capacidad TI, disponibilidad, rendimiento.', '-', '-'),

('APO05-P03-A05', 'APO05-P03', 'Proporcionar una visión precisa del rendimiento de la cartera de inversiones a todas las partes interesadas.', 4, 'GLPI', 'Informa sobre estado de ejecución, hitos y KPIs definidos por proyecto.', 'Se puede personalizar por tipo de stakeholder.', '-'),

('APO05-P03-A06', 'APO05-P03', 'Proporcionar informes para la revisión de la alta gerencia sobre el progreso de la empresa hacia los objetivos identificados, indicando lo que aún se necesita gastar y lograr en los plazos determinados.', 4, 'GLPI', 'Permite reportes periódicos con seguimiento de objetivos y tiempos.', 'Se pueden programar alertas.', '-'),

('APO05-P03-A07', 'APO05-P03', 'En el seguimiento periódico del desempeño, incluir información sobre en qué medida se han alcanzado los objetivos planificados, se han mitigado los riesgos, se han creado capacidades, se han obtenido los resultados y se han cumplido los objetivos de desempeño.', 4, 'Zabbix', 'Ideal para monitoreo continuo del estado técnico y alertas de desempeño.', 'Métricas configurables por servicio y aplicación.', '-'),

('APO05-P03-A08', 'APO05-P03', 'Identificar las desviaciones entre el presupuesto y el gasto real y el ROI esperado de las inversiones.', 4, 'GLPI', 'Gestión de presupuesto con registro de avances. Necesita plugin financiero para ROI.', 'Para ROI, se requiere campo personalizado y análisis.', 'Plugin: Financial Plugin'),

('APO05-P04-A01', 'APO05-P04', 'Crear y mantener carteras de programas de inversión habilitados para I&T, servicios de I&T y activos de I&T, que formen la base del presupuesto actual de I&T y respalden los planes tácticos y estratégicos de I&T.', 3, 'GLPI', 'Permite definir y mantener proyectos, servicios y activos en módulos separados', 'Soporta planificación táctica y estratégica de I&T con vistas personalizadas', '-'),

('APO05-P04-A02', 'APO05-P04', 'Colaborar con los gerentes de prestación de servicios para mantener las carteras de servicios. Colaborar con los gerentes de operaciones, gerentes de producto y arquitectos para mantener las carteras de activos. Priorizar las carteras para respaldar las decisiones de inversión.', 3, 'GLPI', 'Integra módulos de servicio, activos y tickets. Facilita priorización por reglas y flujos', 'Requiere coordinación intermodular y flujos de aprobación definidos', '-'),

('APO05-P04-A03', 'APO05-P04', 'Retirar un programa de la cartera de inversiones activas cuando se hayan logrado los beneficios empresariales deseados o cuando esté claro que no se lograrán beneficios dentro de los criterios de valor establecidos para el programa.', 3, 'GLPI', 'Permite cerrar proyectos y documentar resultados/razones. Historial queda trazable', 'Puede automatizar cierre si se definen condiciones de cumplimiento', '-'),

('APO05-P05-A01', 'APO05-P05', 'Utilizar las métricas acordadas y dar seguimiento a la obtención de beneficios, su evolución a lo largo del ciclo de vida de los programas y proyectos, su entrega a través de los productos y servicios de I&T, y su comparación con los parámetros de referencia internos y del sector. Comunicar los resultados a las partes interesadas.', 4, 'GLPI', 'Zabbix mide resultados operativos y técnicos; GLPI comunica y compara contra KPIs', 'Juntos cubren monitoreo técnico y resultados de negocio', 'Zabbix'),

('APO05-P05-A02', 'APO05-P05', 'Implementar medidas correctivas cuando los beneficios obtenidos se desvíen significativamente de los esperados. Actualizar el análisis de viabilidad para nuevas iniciativas e implementar mejoras en los procesos y servicios según sea necesario.', 5, 'GLPI', 'Permite gestionar desviaciones vía control de proyecto, tickets y workflows', 'Soporta rediseño de servicios y replanificación si se integra correctamente', '-'),

('APO05-P05-A03', 'APO05-P05', 'Considere obtener orientación de expertos externos, líderes de la industria y datos comparativos de referencia para probar y mejorar las métricas y los objetivos.', 5, 'GLPI', 'Permite almacenar benchmarks, adaptar campos e indicadores, integrar referencias', 'Puede registrar información externa como parte del ciclo de vida', '-'),

('APO06-P01-A01', 'APO06-P01', 'Definir los procesos, las entradas, las salidas y las responsabilidades para la gestión financiera y contable de I&T, en consonancia con las políticas y el enfoque de presupuestación y contabilidad de costes de la empresa. Definir cómo analizar e informar (a quién y cómo) sobre el proceso de control presupuestario de I&T.', 2, 'Apache OFBiz', 'Permite modelar procesos contables alineados con políticas corporativas y definir entradas/salidas', 'Muy configurable; admite control presupuestario, informes y seguimiento', '-'),

('APO06-P01-A02', 'APO06-P01', 'Defina un esquema de clasificación para identificar todos los elementos de costo relacionados con I&T (gastos de capital [capex] vs. gastos operativos [opex], hardware, software, personal, etc.). Identifique cómo se registran.', 2, 'Apache OFBiz', 'Soporta clasificación de costos por tipo (CAPEX/OPEX, hardware, software, personal, etc.)', 'Admite registros contables y categorización detallada', '-'),

('APO06-P01-A03', 'APO06-P01', 'Utilizar información financiera para proporcionar información a los estudios de mercado para nuevas inversiones en activos y servicios de I&T.', 3, 'Apache OFBiz', 'Proporciona reportes y análisis de costos útiles para tomar decisiones de inversión', 'Información estructurada para estudios de mercado', '-'),

('APO06-P01-A04', 'APO06-P01', 'Asegurarse de que los costos se mantengan en las carteras de activos y servicios de I&T.', 3, 'GLPI', 'Permite asociar costos a servicios, contratos, equipos y software', 'Requiere tener activo el módulo financiero', '-'),

('APO06-P01-A05', 'APO06-P01', 'Establecer y mantener prácticas de planificación financiera y optimización de costos operativos recurrentes para brindar el máximo valor a la empresa con el menor gasto.', 4, 'Apache OFBiz', 'Tiene funciones para presupuestación, seguimiento de gastos y planificación de recursos', 'Optimiza el gasto alineado al valor empresarial', '-'),

('APO06-P02-A01', 'APO06-P02', 'Clasifique todas las iniciativas de I&T y las solicitudes de presupuesto según los análisis de negocio y las prioridades estratégicas y tácticas. Establezca procedimientos para determinar las asignaciones presupuestarias y el límite de presupuesto.', 2, 'JFire', 'Permite gestionar iniciativas y clasificarlas según objetivos estratégicos', 'Muy útil para decisiones estratégicas', '-'),

('APO06-P02-A02', 'APO06-P02', 'Asignar recursos empresariales y de TI (incluidos proveedores de servicios externos) dentro de las asignaciones presupuestarias generales para programas, servicios y activos de TI. Considerar las opciones para comprar o desarrollar activos y servicios capitalizados frente a activos y servicios utilizados externamente con un sistema de pago por uso.', 2, 'JFire', 'Administra recursos humanos y financieros, internos y externos', 'Admite reglas de asignación complejas', '-'),

('APO06-P02-A03', 'APO06-P02', 'Establecer un procedimiento para comunicar las decisiones presupuestarias y revisarlas con los responsables del presupuesto de las unidades de negocio.', 2, 'GLPI', 'Permite flujos de trabajo, notificaciones automáticas y comunicación con responsables', 'Útil si ya se usa para soporte o catálogo de servicios', '-'),

('APO06-P02-A04', 'APO06-P02', 'Identificar, comunicar y resolver los impactos significativos de las decisiones presupuestarias en los análisis de negocio, las carteras y los planes estratégicos. Por ejemplo, esto puede ocurrir cuando los presupuestos requieren una revisión debido a cambios en las circunstancias empresariales o cuando no son suficientes para respaldar los objetivos estratégicos o los objetivos del análisis de negocio.', 2, 'JFire', 'Visualiza y ajusta el presupuesto según cambios o riesgos estratégicos', 'Facilita simulaciones de impacto', '-'),

('APO06-P02-A05', 'APO06-P02', 'Obtener la ratificación del comité ejecutivo sobre las implicaciones presupuestarias de I&T que afecten negativamente los planes estratégicos o tácticos de la entidad. Sugerir medidas para solucionar estos impactos.', 3, 'Collabtive', 'Permite documentar decisiones de alto nivel y seguimiento de acciones aprobadas', 'Útil para trazabilidad de acuerdos y revisión ejecutiva', '-'),

('APO06-P03-A01', 'APO06-P03', 'Implementar un presupuesto formal de I&T, que incluya todos los costos de I&T previstos para los programas, servicios y activos habilitados por I&T.', 2, 'Apache OFBiz', 'Posee funciones de planificación y ejecución presupuestaria, adaptable al entorno I&T', 'Ideal para gestionar presupuestos formales completos', '-'),

('APO06-P03-A02', 'APO06-P03', 'Al elaborar el presupuesto, considere los siguientes componentes: alineación con el negocio; alineación con la estrategia de abastecimiento; fuentes de financiamiento autorizadas; costos de recursos internos, incluyendo personal, activos de información y alojamiento; costos de terceros, incluyendo contratos de externalización, consultores y proveedores de servicios; gastos de capital y operativos; y elementos de costo que dependen de la carga de trabajo.', 2, 'Apache OFBiz', 'Permite integrar múltiples componentes de costos: internos, externos, capex/opex', 'Admite costos según carga de trabajo y proveedores', '-'),

('APO06-P03-A03', 'APO06-P03', 'Documentar las razones para justificar las contingencias y revisarlas periódicamente.', 2, 'Apache OFBiz', 'Permite registrar comentarios y justificaciones asociadas a partidas presupuestarias', 'Las revisiones se pueden auditar y versionar', '-'),

('APO06-P03-A04', 'APO06-P03', 'Instruir a los propietarios de procesos, servicios y programas, así como a los gerentes de proyectos y activos, para que planifiquen presupuestos.', 2, 'Collabtive', 'Facilita comunicación de responsabilidades y planificación colaborativa', 'Útil para distribuir tareas presupuestarias', '-'),

('APO06-P03-A05', 'APO06-P03', 'Revisar los planes presupuestarios y tomar decisiones sobre las asignaciones presupuestarias. Elaborar y ajustar el presupuesto según las necesidades cambiantes de la empresa y las consideraciones financieras.', 3, 'Apache OFBiz', 'Soporta revisiones de presupuestos y escenarios ajustables con reestimaciones', 'Puede ajustarse al cambio estratégico o financiero', '-'),

('APO06-P03-A06', 'APO06-P03', 'Registrar, mantener y comunicar el presupuesto vigente de I&T, incluyendo los gastos comprometidos y los gastos corrientes, considerando los proyectos de I&T registrados en las carteras de inversión habilitadas para I&T y la operación y mantenimiento de las carteras de activos y servicios.', 3, 'Apache OFBiz', 'Mantiene historial de presupuesto, gastos comprometidos y operación de activos', 'Compatible con planes de inversión I&T y operaciones', '-'),

('APO06-P03-A07', 'APO06-P03', 'Monitorear la efectividad de los diferentes aspectos del presupuesto.', 4, 'Zabbix', 'Puede integrar alertas y monitoreo financiero si se conecta a KPIs de gasto', 'Se requiere integración con datos financieros, como fuente de datos Apache OFBiz', 'Apache OfBiz'),

('APO06-P03-A08', 'APO06-P03', 'Utilizar los resultados del seguimiento para implementar mejoras y garantizar que los presupuestos futuros sean más precisos, fiables y rentables.', 5, 'Apache OFBiz', 'Permite retroalimentar presupuestos con datos históricos y seguimiento de ejecución', 'Mejora precisión de presupuestos futuros', '-'),

('APO06-P04-A01', 'APO06-P04', 'Definir un modelo de asignación de costos que permita una asignación justa, transparente, repetible y comparable de los costos de I&T a los usuarios. Un ejemplo básico de modelo de asignación es la distribución equitativa de los costos compartidos de I&T. Este es un modelo de asignación muy simple y fácil de aplicar; sin embargo, dependiendo del contexto de la empresa, a menudo se considera injusto y no fomenta el uso responsable de los recursos. Un sistema de costeo basado en actividades, en el que los costos se asignan a los servicios de TI y se facturan a los usuarios de estos servicios, permite una asignación de costos más transparente y comparable.', 3, 'Apache OFBiz', 'Permite aplicar reglas personalizadas de costeo: ABC, reparto proporcional, etc.', 'Admite integración con servicios y facturación interna', '-'),

('APO06-P04-A02', 'APO06-P04', 'Inspeccionar los catálogos de definición de servicios para identificar los servicios sujetos a contracargos a los usuarios y aquellos que son servicios compartidos.', 3, 'GLPI', 'Catálogo de servicios con posibilidad de incluir precios, cargos y niveles de servicio', '-', '-'),

('APO06-P04-A03', 'APO06-P04', 'Diseñe el modelo de costos con la transparencia necesaria para que los usuarios puedan identificar su uso y cargos reales mediante categorías y factores de costo que les resulten relevantes (p. ej., costo por llamada al servicio de asistencia, costo por licencia de software). Esto permitirá una mejor previsibilidad de los costos de TI y una utilización eficiente y eficaz de los recursos de TI. Analice los factores de costo (tiempo dedicado a cada actividad, gastos, proporción de costos fijos y variables, etc.). Determine la diferenciación adecuada (p. ej., diferentes categorías de usuarios con diferentes ponderaciones) y utilice aproximaciones o promedios de costos cuando los costos reales sean muy variables.', 3, 'Apache OFBiz', 'Permite desglose de costos por categoría, actividad, tiempo, etc.', 'Soporta diferenciación de categorías de usuarios', '-'),

('APO06-P04-A04', 'APO06-P04', 'Explicar los principios y resultados del modelo de costos a las principales partes interesadas. Obtener su opinión para perfeccionar el modelo y lograr un modelo transparente e integral.', 3, 'Collabtive', 'Facilita comunicación, documentación de decisiones y colaboración', 'Útil para validaciones internas con partes interesadas', '-'),

('APO06-P04-A05', 'APO06-P04', 'Obtener la aprobación de las partes interesadas clave y comunicar el modelo de costos de I&T a la gerencia de los departamentos usuarios.', 3, 'Collabtive', 'Permite trazabilidad de aprobaciones y comunicación formal con usuarios clave', '-', '-'),

('APO06-P04-A06', 'APO06-P04', 'Comunicar cambios importantes en los principios del modelo de costos/contracargos a las partes interesadas clave y a la gerencia de los departamentos usuarios.', 3, 'GLPI', 'Módulo de notificaciones para informar cambios a departamentos y responsables', '-', '-'),

('APO06-P05-A01', 'APO06-P05', 'Obtener la aprobación de las partes interesadas clave y comunicar el modelo de costos de I&T a la gerencia de los departamentos usuarios.', 2, 'Collabtive', 'Permite gestión de aprobación, trazabilidad documental y comunicación a múltiples actores', 'Ideal para validar modelos con departamentos usuarios', '-'),

('APO06-P05-A02', 'APO06-P05', 'Establecer escalas de tiempo para la operación del proceso de gestión de costos de acuerdo con los requerimientos presupuestarios y contables y el cronograma.', 2, 'Apache OFBiz', 'Soporta planificación y control de procesos financieros según ciclos presupuestarios', 'Se adapta a cronogramas definidos por la empresa', '-'),

('APO06-P05-A03', 'APO06-P05', 'Definir un método para la recopilación de datos relevantes para identificar desviaciones entre el presupuesto y los valores reales, el ROI de la inversión, las tendencias de los costos del servicio, etc.', 2, 'Zabbix', 'Monitorea indicadores clave de rendimiento y puede vincularse a datos financieros y de ROI', 'Debe integrarse con sistema de costos como OFBiz', 'Apache OFBiz'),

('APO06-P05-A04', 'APO06-P05', 'Definir cómo se consolidan los costos para los niveles correspondientes de la empresa (TI central vs. presupuesto de TI dentro de los departamentos de la empresa) y cómo se presentarán a las partes interesadas. Los informes proporcionan información sobre los costos por categoría, el estado del presupuesto vs. el real, los gastos principales, etc., para permitir la identificación oportuna de las acciones correctivas necesarias.', 3, 'Apache OFBiz', 'Ofrece estructuras contables por centros de costo, categorías y consolidación por unidad', 'Permite reportes dinámicos y análisis financiero multicapas', '-'),

('APO06-P05-A05', 'APO06-P05', 'Instruir a los responsables de la gestión de costes para que capturen, recopilen y consoliden los datos, y los presenten e informen a los responsables del presupuesto correspondientes. Los analistas y responsables del presupuesto analizan conjuntamente las desviaciones y comparan el rendimiento con los parámetros internos y del sector. Deben establecer y mantener el método de asignación de gastos generales. El resultado del análisis proporciona una explicación de las desviaciones significativas y las medidas correctivas sugeridas.', 3, 'Collabtive', 'Permite asignar tareas, gestionar responsables y hacer seguimiento a la recolección y análisis', 'Apoya trabajo conjunto de analistas y responsables de presupuestos. se puede integrar con Apache OFBiz para los datos de costos', 'Apache OFBiz'),

('APO06-P05-A06', 'APO06-P05', 'Asegurarse de que los niveles apropiados de gestión revisen los resultados del análisis y aprueben las acciones correctivas sugeridas.', 3, 'Collabtive', 'Proporciona trazabilidad y validación de decisiones mediante flujos colaborativos', 'Garantiza participación activa de la gerencia en decisiones financieras', '-'),

('APO06-P05-A07', 'APO06-P05', 'Asegúrese de que se identifiquen los cambios en las estructuras de costos y las necesidades de la empresa y de que los presupuestos y pronósticos se revisen según sea necesario.', 4, 'Apache OFBiz', 'Ofrece visibilidad total de las estructuras de costos y facilita actualización presupuestaria', 'Soporta ajustes en tiempo real ante nuevas necesidades', '-'),

('APO06-P05-A08', 'APO06-P05', 'A intervalos regulares, y especialmente cuando se recortan los presupuestos debido a restricciones financieras, identificar formas de optimizar costos e introducir eficiencias sin poner en peligro los servicios.', 5, 'Zabbix', 'Permite identificar consumos anómalos, tendencias de gasto y oportunidades de eficiencia', '-', '-'),

('APO07-P01-A01', 'APO07-P01', 'Evaluar las necesidades de personal periódicamente o ante cambios importantes. Asegurarse de que tanto la empresa como el departamento de TI cuenten con recursos suficientes para respaldar las metas y objetivos empresariales, los procesos y controles de negocio, y las iniciativas basadas en I&T de forma adecuada y apropiada.', 2, 'GLPI', 'Permite registrar, planificar y hacer seguimiento de los recursos humanos asignados a proyectos y servicios relacionados con información y tecnología (I&T).', 'Aunque no es un sistema de gestión de recursos humanos completo, permite vincular personal con necesidades operativas.', '-'),

('APO07-P01-A02', 'APO07-P01', 'Mantener los procesos de reclutamiento y retención de personal de negocios y de TI en línea con las políticas y procedimientos generales de personal de la empresa.', 2, 'JFire', 'Incluye funcionalidades para la gestión de recursos humanos como parte del sistema de planificación de recursos empresariales (ERP).', 'Facilita el seguimiento de candidatos, contrataciones y retención.', '-'),

('APO07-P01-A03', 'APO07-P01', 'Establecer acuerdos de recursos flexibles, como el uso de transferencias, contratistas externos y acuerdos de servicios de terceros, para respaldar las necesidades comerciales cambiantes.', 2, 'JFire', 'Permite definir relaciones laborales externas, contratistas y contratos temporales desde el sistema ERP.', 'Ideal para esquemas de servicios de terceros y personal externo.', '-'),

('APO07-P01-A04', 'APO07-P01', 'Incluir verificaciones de antecedentes en el proceso de selección de personal de TI para empleados, contratistas y proveedores. El alcance y la frecuencia de estas verificaciones deben depender de la sensibilidad o criticidad de la función.', 3, 'Eramba', 'Documenta procesos de seguridad del personal, incluyendo controles, validaciones y cumplimiento regulatorio.', 'Especialmente útil en funciones críticas o sensibles.', '-'),

('APO07-P02-A01', 'APO07-P02', 'Como medida de seguridad, proporcionar pautas sobre el tiempo mínimo de vacaciones anuales que deben tomar las personas clave.', 2, 'GLPI', 'Se pueden configurar políticas internas, incluyendo días de descanso y programación de vacaciones del personal clave.', 'Permite asegurar separación temporal de funciones sensibles.', '-'),

('APO07-P02-A02', 'APO07-P02', 'Tomar las medidas apropiadas con respecto a los cambios de trabajo, especialmente las terminaciones laborales.', 2, 'JFire', 'Gestión completa de personal con posibilidad de registrar movimientos, terminaciones y traspasos.', 'Soporta la trazabilidad de movimientos de personal.', '-'),

('APO07-P02-A03', 'APO07-P02', 'Utilizar la captura de conocimientos (documentación), el intercambio de conocimientos, la planificación de la sucesión, el respaldo del personal, la capacitación cruzada y las iniciativas de rotación laboral para minimizar la dependencia de que una sola persona realice una función laboral crítica.', 2, 'Moodle', 'Plataforma de aprendizaje (sistema de gestión del aprendizaje û LMS) que facilita documentación, capacitación cruzada y respaldo de personal.', 'Muy útil para reducir dependencia de personas específicas.', '-'),

('APO07-P02-A04', 'APO07-P02', 'Pruebe periódicamente los planes de respaldo del personal.', 3, 'GLPI', 'Permite asignar funciones críticas y escenarios alternos de personal para validar continuidad.', 'Recomendado con roles bien definidos por usuario.', '-'),

('APO07-P03-A01', 'APO07-P03', 'Identificar las habilidades y competencias actualmente disponibles de los recursos internos y externos.', 2, 'Eramba', 'Permite mantener y auditar registros de competencias del personal interno y externo como parte del cumplimiento.', 'Permite trazabilidad con requisitos normativos.', '-'),

('APO07-P03-A02', 'APO07-P03', 'Identificar las brechas entre las habilidades requeridas y las disponibles. Desarrollar planes de acción, como capacitación (habilidades técnicas y conductuales), reclutamiento, redistribución y cambios en las estrategias de contratación, para abordar las brechas de forma individual y colectiva.', 2, 'Moodle', 'Ideal para implementar planes de mejora de habilidades técnicas y conductuales por medio de programas formativos.', 'Admite seguimiento personalizado por empleado.', '-'),

('APO07-P03-A03', 'APO07-P03', 'Revisar periódicamente los materiales y programas de capacitación. Asegurarse de que se ajusten a los cambios en los requisitos de la empresa y su impacto en los conocimientos, habilidades y capacidades necesarios.', 3, 'Moodle', 'Permite actualizar contenidos educativos y mantener la alineación con los objetivos estratégicos.', 'Puede conectarse a necesidades específicas del negocio.', '-'),

('APO07-P03-A04', 'APO07-P03', 'Proporcionar acceso a repositorios de conocimiento para apoyar el desarrollo de habilidades y competencias.', 3, 'Moodle', 'Facilita el acceso y la consulta de documentos clave, manuales y módulos de aprendizaje.', 'Compatible con múltiples formatos multimedia.', '-'),

('APO07-P03-A05', 'APO07-P03', 'Desarrollar e impartir programas de capacitación basados en los requisitos organizacionales y de procesos, incluidos los requisitos de conocimiento empresarial, control interno, conducta ética, seguridad y privacidad.', 3, 'Moodle', 'Soporta el desarrollo, asignación y seguimiento de programas de formación ética, técnica y legal.', 'Útil para cumplimiento normativo y habilidades blandas.', '-'),

('APO07-P03-A06', 'APO07-P03', 'Realizar revisiones periódicas para evaluar la evolución de las habilidades y competencias de los recursos internos y externos. Revisar la planificación de la sucesión.', 4, 'GLPI', 'Ofrece trazabilidad en la relación entre competencias del personal y su desempeño dentro de servicios y proyectos.', 'Se puede complementar con informes desde Moodle.', '-'),

('APO07-P04-A01', 'APO07-P04', 'Considere los objetivos funcionales/empresariales como el contexto para establecer objetivos individuales.', 2, 'JFire', 'JFire (ERP) permite establecer metas de desempeño ligadas a objetivos estratégicos empresariales e individuales.', 'Puede integrar metas SMART por empleado.', '-'),

('APO07-P04-A02', 'APO07-P04', 'Establecer objetivos individuales alineados con los objetivos relevantes de I&T y de la empresa. Fundamentar los objetivos en objetivos específicos, medibles, alcanzables, relevantes y con plazos definidos (SMART) que reflejen las competencias clave, los valores de la empresa y las habilidades requeridas para el/los puesto(s).', 2, 'JFire', 'Se pueden configurar objetivos individuales dentro del módulo de desempeño del ERP con criterios SMART.', 'Adecuado para reflejar competencias y valores corporativos.', '-'),

('APO07-P04-A03', 'APO07-P04', 'Proporcionar retroalimentación oportuna sobre el desempeño en relación con los objetivos del individuo.', 2, 'Znuny', 'Permite crear y gestionar tickets personalizados de retroalimentación y seguimiento por supervisor o líder.', 'Útil para retroalimentación estructurada.', '-'),

('APO07-P04-A04', 'APO07-P04', 'Proporcionar instrucciones específicas para el uso y almacenamiento de la información personal en el proceso de evaluación, en cumplimiento de la legislación aplicable en materia de datos personales y laboral.', 2, 'Eramba', 'Plataforma especializada en gestión de riesgos y cumplimiento; controla uso de datos personales conforme a normativas.', 'Cumple RGPD/Ley de Protección de Datos.', '-'),

('APO07-P04-A05', 'APO07-P04', 'Recopilar resultados de la evaluación del desempeño de 360 grados.', 3, 'Moodle', 'Soporta evaluaciones 360░, encuestas y evaluaciones cruzadas en su LMS.', 'Muy usado para feedback multifuente.', '-'),

('APO07-P04-A06', 'APO07-P04', 'Proporcionar planes formales de planificación de carrera y desarrollo profesional basados en los resultados del proceso de evaluación para fomentar el desarrollo de competencias y las oportunidades de desarrollo personal, y reducir la dependencia de personas clave. Brindar capacitación a los empleados sobre desempeño y conducta cuando corresponda.', 3, 'Moodle', 'Diseñado para la formación y desarrollo profesional individual basado en resultados previos.', 'Ideal para reducir dependencia de personal clave.', '-'),

('APO07-P04-A07', 'APO07-P04', 'Implementar un proceso de remuneración y reconocimiento que recompense el compromiso adecuado, el desarrollo de competencias y el logro de los objetivos de desempeño. Asegurar que el proceso se aplique de forma coherente y conforme a las políticas de la organización.', 3, 'JFire', 'Permite configurar escalas salariales, bonificaciones y recompensas con base en desempeño.', 'Puede integrar políticas organizacionales.', '-'),

('APO07-P04-A08', 'APO07-P04', 'Implementar y comunicar un proceso disciplinario.', 3, 'Znuny', 'Permite estructurar y evidenciar casos disciplinarios con historial detallado.', 'Adaptable al reglamento interno de trabajo.', '-'),

('APO07-P05-A01', 'APO07-P05', 'Crear y mantener un inventario de recursos humanos del negocio y de TI.', 2, 'GLPI', 'GLPI gestiona inventarios completos, incluyendo recursos humanos vinculados a activos de TI.', 'Puede diferenciar roles de negocio y técnicos.', '-'),

('APO07-P05-A02', 'APO07-P05', 'Comprender la demanda actual y futura de recursos humanos para apoyar el logro de los objetivos de I&T y brindar servicios y soluciones basados en la cartera de iniciativas actuales relacionadas con I&T, la cartera de inversiones futuras y las necesidades operativas diarias.', 3, 'Collabtive', 'Herramienta de gestión colaborativa con vista de cargas de trabajo actuales y futuras.', 'Muestra capacidad futura por iniciativa.', '-'),

('APO07-P05-A03', 'APO07-P05', 'Identificar las deficiencias y aportar información a los planes de contratación, así como a los procesos de contratación empresarial y de TI. Crear y revisar el plan de dotación de personal, haciendo un seguimiento del uso real.', 3, 'JFire', 'Desde el módulo de recursos humanos del ERP permite identificar brechas y vincularlas a procesos de contratación.', 'Puede configurarse para alimentar planes de dotación.', '-'),

('APO07-P05-A04', 'APO07-P05', 'Mantener información adecuada del tiempo dedicado a las diferentes tareas, asignaciones, servicios o proyectos.', 4, 'Collabtive', 'Collabtive permite realizar seguimiento detallado del tiempo trabajado por tarea, proyecto o usuario. Ofrece módulos de control horario (time tracking), asignación de tareas y generación de reportes. Esto facilita mantener registros claros y precisos del uso del recurso humano en TI.', 'La herramienta cubre completamente la trazabilidad del tiempo invertido por tarea y proyecto, incluyendo su asignación a servicios o responsables.', '-'),

('APO07-P06-A01', 'APO07-P06', 'Implementar políticas y procedimientos para el personal contratado.', 2, 'Eramba', 'Eramba permite documentar, mantener y comunicar políticas y procedimientos de cumplimiento y seguridad, útiles para gestionar personal externo', 'Ideal para entornos con cumplimiento normativo', '-'),

('APO07-P06-A02', 'APO07-P06', 'Al inicio del contrato, obtener un acuerdo formal de los contratistas de que están obligados a cumplir con el marco de control de I&T de la empresa, como políticas de autorización de seguridad, control de acceso físico y lógico, uso de instalaciones, requisitos de confidencialidad de la información y acuerdos de confidencialidad.', 2, 'Eramba', 'Permite generar y gestionar acuerdos de cumplimiento firmados digitalmente, incluyendo control de accesos y confidencialidad', 'Alineado con marcos ISO 27001/COBIT', '-'),

('APO07-P06-A03', 'APO07-P06', 'Informe a los contratistas que la gerencia se reserva el derecho de monitorear e inspeccionar todo uso de los recursos de TI, incluido el correo electrónico, las comunicaciones de voz y todos los programas y archivos de datos.', 2, 'Znuny', 'Permite comunicar y registrar acuses de recibo, alertas, políticas, e integrarlo con gestión de tickets', 'Es trazable y auditable', '-'),

('APO07-P06-A04', 'APO07-P06', 'Como parte de sus contratos, proporcionar a los contratistas una definición clara de sus funciones y responsabilidades, incluidos requisitos explícitos para documentar su trabajo según los estándares y formatos acordados.', 2, 'Eramba', 'Ofrece plantillas estructuradas y gestión documental para definir funciones y responsabilidades en contratos', 'Incluye definición de roles', '-'),

('APO07-P06-A05', 'APO07-P06', 'Revisar el trabajo de los contratistas y basar la aprobación de los pagos en los resultados.', 2, 'GLPI', 'Permite seguimiento de tareas, incidencias y entregables por usuario, útil para asociar resultados a pagos', 'Requiere configuración de roles y validación', '-'),

('APO07-P06-A06', 'APO07-P06', 'En contratos formales e inequívocos, definir todo el trabajo realizado por partes externas.', 3, 'Eramba', 'Permite formalizar el alcance del trabajo mediante contratos documentados y controlados', 'Puede integrarse con repositorios externos', '-'),

('APO07-P06-A07', 'APO07-P06', 'Realizar revisiones periódicas para garantizar que el personal contratado haya firmado y aceptado todos los acuerdos necesarios.', 4, 'Eramba', 'Mantiene registro y verificación de aceptación de políticas, términos y condiciones', 'Puede programar revisiones periódicas', '-'),

('APO07-P06-A08', 'APO07-P06', 'Realizar revisiones periódicas para garantizar que los roles y los derechos de acceso de los contratistas sean apropiados y estén en línea con los acuerdos.', 4, 'GLPI', 'Permite controlar accesos, roles y permisos de usuarios, incluyendo externos', 'Integrable con LDAP o FreeIPA para mayor control', '-'),

('APO08-P01-A01', 'APO08-P01', 'Identificar a los grupos de interés del negocio, sus intereses y sus áreas de responsabilidad.', 2, 'GLPI', 'Permite gestionar relaciones, registrar roles y responsabilidades de usuarios clave en la organización.', 'Configuración flexible para modelar diferentes grupos de interés', '-'),

('APO08-P01-A02', 'APO08-P01', 'Revisar la dirección actual de la empresa, los problemas, los objetivos estratégicos y la alineación con la arquitectura empresarial.', 2, 'Eramba', 'Permite integrar procesos de gobierno, riesgo y cumplimiento (GRC), ideal para analizar estrategias alineadas a estructuras empresariales.', 'Apoya en el monitoreo continuo del alineamiento estratégico', '-'),

('APO08-P01-A03', 'APO08-P01', 'Comprender el entorno empresarial actual, las limitaciones o problemas de los procesos, la expansión o contracción geográfica y los impulsores industriales y regulatorios.', 2, 'Eramba', 'Brinda visibilidad del entorno normativo, de procesos y marcos regulatorios.', 'Incluye trazabilidad documental y alertas', '-'),

('APO08-P01-A04', 'APO08-P01', 'Mantenerse al tanto de los procesos de negocio y las actividades asociadas. Comprender los patrones de demanda relacionados con el volumen y el uso del servicio.', 2, 'GLPI', 'A través del módulo de gestión de servicios (tickets, solicitudes), permite monitorear volúmenes de demanda y áreas de negocio.', 'Permite visualizar carga operativa y demanda', '-'),

('APO08-P01-A05', 'APO08-P01', 'Gestionar las expectativas asegurándose de que las unidades de negocio comprendan las prioridades, las dependencias, las limitaciones financieras y la necesidad de programar las solicitudes.', 3, 'Zammad', 'Permite implementar flujos de comunicación claros entre TI y las unidades de negocio con reglas de escalamiento.', 'Flexible en reglas de negocio y automatización', '-'),

('APO08-P01-A06', 'APO08-P01', 'Aclarar las expectativas empresariales para los servicios y soluciones basados en I&T. Asegurarse de que los requisitos estén definidos con los criterios y métricas de aceptación empresarial correspondientes.', 4, 'GLPI', 'Posibilita definir acuerdos de nivel de servicio (SLA) y registrar criterios de aceptación y cumplimiento.', 'Alineado con prácticas ITIL para requerimientos', '-'),

('APO08-P01-A07', 'APO08-P01', 'Confirmar que exista un acuerdo entre TI y todos los departamentos de la empresa sobre las expectativas y cómo se medirán. Asegurarse de que este acuerdo sea confirmado por todas las partes interesadas.', 4, 'GLPI', 'Registra compromisos entre TI y áreas de negocio (SLAs, tareas, documentación).', 'Seguimiento con trazabilidad de validaciones', '-'),

('APO08-P02-A01', 'APO08-P02', 'Posicionar a TI como socio del negocio. Desempeñar un papel proactivo en la identificación y comunicación con las partes interesadas clave sobre oportunidades, riesgos y limitaciones. Esto incluye tecnologías, servicios y modelos de procesos de negocio actuales y emergentes.', 3, 'Eramba', 'Integra la gestión de riesgos, oportunidades y evaluaciones que pueden compartirse con partes interesadas.', 'Soporta matrices de riesgo y tableros de control', '-'),

('APO08-P02-A02', 'APO08-P02', 'Colaborar en nuevas iniciativas importantes con la gestión de portafolios, programas y proyectos. Garantizar la participación de la organización de TI desde el inicio de una nueva iniciativa, proporcionando asesoramiento y recomendaciones de valor añadido (p. ej., para el desarrollo de casos de negocio, la definición de requisitos y el diseño de soluciones) y asumiendo la responsabilidad de los flujos de trabajo de I&T.', 3, 'GLPI', 'Permite seguimiento desde el inicio de iniciativas, con gestión de proyectos, tareas, documentación y flujo de aprobación.', 'Apoya definición de casos de negocio y seguimiento', '-'),

('APO08-P03-A01', 'APO08-P03', 'Asignar un gerente de relaciones como punto de contacto único para cada unidad de negocio significativa. Asegurarse de que se identifique una única contraparte en la organización empresarial y que esta tenga conocimiento del negocio, suficiente conocimiento tecnológico y el nivel de autoridad adecuado.', 3, 'GLPI', 'Permite registrar responsables por unidad de negocio y asociarlos con servicios, contratos y activos específicos.', 'Soporta la trazabilidad de roles y asignaciones', '-'),

('APO08-P03-A02', 'APO08-P03', 'Gestionar la relación de una manera formalizada y transparente que garantice un enfoque en el logro de un objetivo común y compartido de resultados empresariales exitosos en apoyo de los objetivos estratégicos y dentro de las limitaciones de los presupuestos y la tolerancia al riesgo.', 3, 'Znuny', 'Permite establecer flujos de trabajo, reglas y acuerdos de nivel de servicio (SLA) para garantizar cumplimiento de metas conjuntas.', 'Proporciona visibilidad de cumplimiento por unidad', '-'),

('APO08-P03-A03', 'APO08-P03', 'Definir y comunicar un procedimiento de quejas y escalamiento para resolver cualquier problema de relación.', 3, 'Znuny', 'Ofrece configuración flexible de escalamientos, tipos de tickets y seguimiento de quejas con trazabilidad completa.', 'Permite automatizar y auditar el proceso', '-'),

('APO08-P03-A04', 'APO08-P03', 'Asegúrese de que las decisiones clave sean acordadas y aprobadas por las partes interesadas responsables pertinentes.', 3, 'GLPI', 'Permite registrar validaciones y documentación formal sobre decisiones clave asociadas a proyectos y contratos.', 'Asociable a flujos de aprobación internos', '-'),

('APO08-P03-A05', 'APO08-P03', 'Planificar interacciones y cronogramas específicos basados en objetivos mutuamente acordados y un lenguaje común (reuniones de revisión de servicios y desempeño, revisión de nuevas estrategias o planes, etc.).', 4, 'GLPI', 'Soporta planificación de reuniones, tareas, revisiones y calendarios con entidades del negocio.', 'Integración con agenda colaborativa', '-'),

('APO08-P04-A01', 'APO08-P04', 'Coordinar y comunicar cambios y actividades de transición, tales como planes de proyecto o cambio, cronogramas, políticas de lanzamiento, errores conocidos de lanzamiento y concientización sobre capacitación.', 2, 'Znuny', 'Administra la comunicación y flujo de cambios, incidentes y errores conocidos.', 'Soporte para avisos masivos y gestión de versiones', '-'),

('APO08-P04-A02', 'APO08-P04', 'Coordinar y comunicar actividades operativas, roles y responsabilidades, incluyendo la definición de tipos de solicitudes, escalamiento jerárquico, interrupciones importantes (planificadas y no planificadas) y contenido y frecuencia de los informes de servicio.', 2, 'GLPI', 'Permite definir tipos de solicitud, flujos, jerarquías, interrupciones y sus reportes asociados.', 'Puede integrarse con monitoreo para alertas', '-'),

('APO08-P04-A03', 'APO08-P04', 'Asumir la responsabilidad de la respuesta a la empresa ante eventos importantes que puedan afectar la relación con ella. Brindar apoyo directo si es necesario.', 2, 'Znuny', 'Gestión proactiva de eventos mayores y protocolos de respuesta con soporte a múltiples canales de comunicación.', 'Escalamiento y seguimiento automático', '-'),

('APO08-P04-A04', 'APO08-P04', 'Mantener un plan de comunicación de extremo a extremo que defina el contenido, la frecuencia y los destinatarios de la información sobre la prestación del servicio, incluido el estado del valor entregado y cualquier riesgo identificado.', 3, 'GLPI', 'Permite construir y distribuir reportes periódicos de servicio, cumplimiento, riesgos y valor entregado.', 'Puede exportar informes periódicos a responsables', '-'),

('APO08-P05-A01', 'APO08-P05', 'Realizar análisis de satisfacción de clientes y proveedores. Asegurarse de que se solucionen los problemas; informar los resultados y el estado.', 4, 'GLPI', 'Permite integrar encuestas de satisfacción post-servicio y hacer seguimiento a resultados.', 'Soporta reportes de satisfacción por servicio o cliente', '-'),

('APO08-P05-A02', 'APO08-P05', 'Trabajar juntos para identificar, comunicar e implementar iniciativas de mejora.', 5, 'Znuny', 'Facilita el ciclo de mejora continua mediante seguimiento de acciones correctivas y mejoras propuestas.', 'Se pueden clasificar y priorizar propuestas de mejora', '-'),

('APO08-P05-A03', 'APO08-P05', 'Trabajar con la gestión de servicios y los propietarios de procesos para garantizar que los servicios habilitados por I&T y los procesos de gestión de servicios se mejoren continuamente y que se identifiquen y resuelvan las causas fundamentales de cualquier problema.', 5, 'GLPI', 'Integra gestión de procesos de servicios y permite el registro de causas raíz, problemas recurrentes y acciones preventivas.', 'Compatible con gestión de SLAs y análisis de fallos', '-'),

('APO09-P01-A01', 'APO09-P01', 'Evaluar los servicios y niveles de servicio de I&T actuales para identificar las brechas entre los servicios existentes y las actividades empresariales que respaldan. Identificar áreas de mejora en los servicios existentes y las opciones de nivel de servicio.', 2, 'GLPI', 'Permite gestionar y analizar servicios actuales mediante su módulo de gestión de servicios (ITSM), permitiendo detectar brechas y necesidades de mejora.', 'Se puede extender con plugins ITIL.', '-'),

('APO09-P01-A02', 'APO09-P01', 'Analizar, estudiar y estimar la demanda futura y confirmar la capacidad de los servicios existentes habilitados por I&T.', 2, 'GLPI', 'GLPI permite revisar demanda y capacidad futura usando tickets, planificación de capacidades y gestión de activos relacionados con servicios.', 'Es recomendable usarlo con datos históricos de uso.', '-'),

('APO09-P01-A03', 'APO09-P01', 'Analizar las actividades del proceso de negocio para identificar la necesidad de servicios de I&T nuevos o rediseñados.', 3, 'GLPI', 'Soporta análisis de procesos mediante la documentación de solicitudes frecuentes y necesidades no cubiertas.', 'Permite mapeo funcional a necesidades nuevas.', '-'),

('APO09-P01-A04', 'APO09-P01', 'Compare los requisitos identificados con los componentes de servicio existentes en la cartera. Si es posible, integre los componentes de servicio existentes (servicios de I&T, opciones de nivel de servicio y paquetes de servicios) en nuevos paquetes de servicios para satisfacer los requisitos de negocio identificados.', 3, 'GLPI', 'Facilita comparación entre requerimientos y servicios existentes mediante su estructura de catálogos y plantillas.', 'Ideal para modelar nuevos servicios reutilizando existentes.', '-'),

('APO09-P01-A05', 'APO09-P01', 'Revisar periódicamente la cartera de servicios de I&T con la gerencia de cartera y la gestión de relaciones comerciales para identificar servicios obsoletos. Acordar su retirada y proponer cambios.', 3, 'GLPI', 'Permite revisión periódica de servicios en cartera, incluyendo su obsolescencia y ajustes.', 'Se puede automatizar con cronjobs o notificaciones internas.', '-'),

('APO09-P01-A06', 'APO09-P01', 'Siempre que sea posible, adecue las demandas a los paquetes de servicios y cree servicios estandarizados para obtener eficiencias generales.', 4, 'GLPI', 'Se pueden estandarizar servicios desde el catálogo, aplicando configuraciones repetibles para demanda.', 'Reduce variabilidad y asegura consistencia.', '-'),

('APO09-P02-A01', 'APO09-P02', 'Publicar en catálogos servicios relevantes en vivo habilitados por I&T, paquetes de servicios y opciones de niveles de servicio de la cartera.', 2, 'GLPI', 'Permite publicar servicios activos en su catálogo accesible por usuarios y técnicos.', 'Altamente configurable y visible en el portal de usuario.', '-'),

('APO09-P02-A02', 'APO09-P02', 'Asegurarse continuamente de que los componentes de servicios de la cartera y los catálogos de servicios relacionados estén completos y actualizados.', 3, 'GLPI', 'Actualizaciones continuas del catálogo a través del mantenimiento de servicios y automatizaciones.', 'Se pueden vincular con cambios e incidencias.', '-'),

('APO09-P02-A03', 'APO09-P02', 'Informar a la gestión de relaciones comerciales sobre cualquier actualización de los catálogos de servicios.', 3, 'GLPI', 'Se puede informar y notificar automáticamente a la gestión de relaciones vía correos y reglas.', 'Muy útil si se define protocolo de actualización.', '-'),

('APO09-P03-A01', 'APO09-P03', 'Analice los requisitos para los acuerdos de servicio nuevos o modificados recibidos de la gestión de relaciones comerciales para garantizar su cumplimiento. Considere aspectos como los tiempos de servicio, la disponibilidad, el rendimiento, la capacidad, la seguridad, la privacidad, la continuidad, el cumplimiento normativo, la usabilidad, las limitaciones de la demanda y la calidad de los datos.', 2, 'GLPI', 'Permite documentar y validar requisitos funcionales, técnicos y de soporte en solicitudes de servicio.', 'Útil para validar criterios de servicio antes de acuerdos.', '-'),

('APO09-P03-A02', 'APO09-P03', 'Redactar acuerdos de servicio al cliente basados en los servicios, paquetes de servicios y opciones de niveles de servicio incluidos en los catálogos de servicios pertinentes.', 2, 'GLPI', 'Facilita la redacción de acuerdos basados en servicios estandarizados.', 'Compatible con enfoques ITIL.', '-'),

('APO09-P03-A03', 'APO09-P03', 'Finalizar los acuerdos de servicio al cliente con la gestión de relaciones comerciales.', 2, 'GLPI', 'Posibilita formalizar acuerdos mediante funciones de validación, firma y comunicación con usuarios clave.', 'Requiere definir jerarquías y responsables.', '-'),

('APO09-P03-A04', 'APO09-P03', 'Determinar, acordar y documentar los acuerdos operativos internos que respalden los acuerdos de servicio al cliente, si corresponde.', 3, 'GLPI', 'Permite definir acuerdos internos entre áreas (OLAs - Operational Level Agreements) como soporte de SLAs.', 'Necesita configuración previa.', '-'),

('APO09-P03-A05', 'APO09-P03', 'Establecer vínculos con la administración de proveedores para garantizar que los contratos comerciales adecuados con proveedores de servicios externos respalden los acuerdos de servicio al cliente, si corresponde.', 3, 'GLPI', 'Se puede integrar la gestión de proveedores y contratos para garantizar respaldo externo a SLAs.', 'Puede usarse junto con módulo de compras y proveedores.', '-'),

('APO09-P04-A01', 'APO09-P04', 'Establecer y mantener medidas para monitorear y recopilar datos sobre el nivel de servicio.', 4, 'GLPI', 'Permite configurar SLAs con métricas claras y establecer tiempos objetivos para servicios.', 'Las métricas pueden enlazarse con tipos de solicitud y prioridades.', '-'),

('APO09-P04-A02', 'APO09-P04', 'Evaluar el desempeño y proporcionar informes periódicos y formales sobre el cumplimiento del contrato de servicio, incluyendo las desviaciones respecto a los valores acordados. Distribuir este informe a la gerencia de relaciones comerciales.', 4, 'GLPI', 'Genera reportes automáticos de cumplimiento SLA, incidencias y tiempos de atención para cada contrato.', 'Se pueden automatizar reportes mensuales para dirección.', '-'),

('APO09-P04-A03', 'APO09-P04', 'Realizar revisiones periódicas para pronosticar e identificar tendencias en el rendimiento del nivel de servicio. Incorporar prácticas de gestión de calidad en la supervisión del servicio.', 4, 'GLPI', 'Ofrece estadísticas e historial de rendimiento que ayudan a prever tendencias y evaluar desviaciones.', 'Puede usarse junto con herramientas gráficas externas (como Grafana) para análisis visual.', '-'),

('APO09-P04-A04', 'APO09-P04', 'Proporcionar la información de gestión adecuada para facilitar la gestión del rendimiento.', 4, 'GLPI', 'Permite compartir dashboards y reportes con responsables de áreas, visualizando desempeño por servicio.', 'Requiere definir vistas por tipo de responsable.', '-'),

('APO09-P04-A05', 'APO09-P04', 'Acordar planes de acción y soluciones para cualquier problema de desempeño o tendencias negativas.', 4, 'GLPI', 'Permite seguimiento a problemas recurrentes y acciones correctivas a través de su módulo de problemas e incidencias.', 'Las acciones correctivas pueden estar vinculadas al SLA.', '-'),

('APO09-P05-A01', 'APO09-P05', 'Revisar periódicamente los contratos de servicio según los términos acordados para garantizar su eficacia y actualización. Cuando corresponda, tener en cuenta los cambios en los requisitos, los servicios de I+T, los paquetes de servicios o las opciones de nivel de servicio.', 3, 'GLPI', 'Permite registrar y versionar acuerdos de servicio (SLA) y contratos, incluyendo fechas de vigencia.', 'Puede generar alertas antes de la expiración de contratos.', '-'),

('APO09-P05-A02', 'APO09-P05', 'Cuando sea necesario, revise el contrato de servicio vigente con el proveedor. Acuerde y actualice los acuerdos operativos internos.', 4, 'GLPI', 'Permite registrar cambios y condiciones actualizadas en contratos con proveedores.', 'Puede incluir adjuntos y validaciones por parte de responsables.', '-'),

('APO10-P01-A01', 'APO10-P01', 'Analizar continuamente el panorama empresarial en busca de nuevos socios y proveedores que puedan proporcionar capacidades complementarias y respaldar la realización de la estrategia de I&T, la hoja de ruta y los objetivos empresariales.', 3, NULL, 'La herramienta Eramba, permite registrar terceros y asociarlos a controles estratégicos, pero el análisis de mercado externo debe hacerse fuera del sistema.', 'Requiere apoyo analítico externo, NO CUBRE AL 100%', '-'),

('APO10-P01-A02', 'APO10-P01', 'Establecer y mantener criterios relacionados con el tipo, la importancia y la criticidad de los proveedores y los contratos con ellos, permitiendo centrarse en los proveedores preferidos e importantes.', 3, 'GLPI', 'GLPI permite clasificación por tipo e importancia. Eramba permite establecer niveles de criticidad y riesgos asociados.', 'Se complementan bien', '-'),

('APO10-P01-A03', 'APO10-P01', 'Identificar, registrar y categorizar a los proveedores y contratos existentes según criterios definidos para mantener un registro detallado de los proveedores preferidos que deben gestionarse con cuidado.', 3, 'GLPI', 'Módulo de proveedores y contratos configurable con criterios propios', 'Permite adjuntar contratos, responsables y vigencias', '-'),

('APO10-P01-A04', 'APO10-P01', 'Establecer y mantener criterios de evaluación de proveedores y contratos para permitir la revisión y comparación general del desempeño de los proveedores de manera consistente.', 4, 'Eramba', 'Permite definir y aplicar criterios de evaluación periódicos mediante formularios, escalas y riesgos', 'No automatiza alertas, pero sí puntuación por cuestionarios', '-'),

('APO10-P01-A05', 'APO10-P01', 'Evaluar y comparar periódicamente el desempeño de los proveedores existentes y alternativos para identificar oportunidades o una necesidad imperiosa de reconsiderar los contratos con los proveedores actuales.', 5, 'Eramba', 'Ofrece módulos de evaluación, revisión y reportes de desempeño con trazabilidad', 'Ideal para comparativas de proveedores críticos', '-'),

('APO10-P02-A01', 'APO10-P02', 'Revise todas las solicitudes de información (RFI) y solicitudes de propuestas (RFP) para garantizar que definan claramente los requisitos (p. ej., requisitos empresariales de seguridad y privacidad de la información, requisitos operativos de procesamiento de negocios y de TI, prioridades para la prestación de servicios) e incluyan un procedimiento para aclarar los requisitos. Las RFI y las RFP deben conceder a los proveedores tiempo suficiente para preparar sus propuestas y definir claramente los criterios de adjudicación y el proceso de decisión.', 2, 'Eramba', 'Puede documentar requisitos y flujos aprobatorios, pero no gestiona el ciclo formal de adquisiciones', 'Solo útil como repositorio estructurado', '-'),

('APO10-P02-A02', 'APO10-P02', 'Evaluar las solicitudes de información (RFI) y de propuesta (RFP) de acuerdo con el proceso y los criterios de evaluación aprobados y conservar la documentación correspondiente. Verificar las referencias de los proveedores candidatos.', 2, 'Eramba', 'Permite registrar criterios de evaluación pero no gestiona ciclo completo ni referencias automáticamente', 'No centraliza el flujo de propuestas', '-'),

('APO10-P02-A03', 'APO10-P02', 'Seleccione al proveedor que mejor se adapte a la solicitud de propuesta. Documente y comunique la decisión, y firme el contrato.', 2, 'GLPI', 'Permite registrar decisión, cargar contrato, asignar responsables, fechas y seguimiento', 'No incluye firma electrónica nativa', '-'),

('APO10-P02-A04', 'APO10-P02', 'En el caso específico de la adquisición de software, incluir y hacer cumplir los derechos y obligaciones de todas las partes en los términos contractuales. Estos derechos y obligaciones pueden incluir la propiedad y la licencia de propiedad intelectual; el mantenimiento; las garantías; los procedimientos de arbitraje; las condiciones de actualización; y la idoneidad para el fin previsto, incluyendo la seguridad, la privacidad, el depósito en garantía y los derechos de acceso.', 3, NULL, 'Ninguna herramienta soporta redacción o validación jurídica de contratos de software', 'Actividad fuera del alcance técnico de las herramientas listadas', '-'),

('APO10-P02-A05', 'APO10-P02', 'En el caso específico de la adquisición de recursos de desarrollo, incluir y hacer cumplir los derechos y obligaciones de todas las partes en los términos contractuales. Estos derechos y obligaciones pueden incluir la propiedad y la concesión de licencias de propiedad intelectual; la idoneidad para el fin previsto, incluidas las metodologías de desarrollo; las pruebas; los procesos de gestión de calidad, incluidos los criterios de rendimiento requeridos; las evaluaciones de rendimiento; la base de pago; las garantías; los procedimientos de arbitraje; la gestión de recursos humanos; y el cumplimiento de las políticas de la empresa.', 3, NULL, 'No se gestionan contratos con cláusulas técnicas detalladas, metodologías, propiedad intelectual, etc.', 'No se cubre con herramientas actuales', '-'),

('APO10-P02-A06', 'APO10-P02', 'Obtener asesoramiento legal sobre acuerdos de adquisición de desarrollo de recursos en relación con la propiedad y licencias de propiedad intelectual.', 3, NULL, 'Se trata de una actividad jurídica especializada que no es automatizable por software open source', 'Requiere intervención legal externa', 'Asesoría legal externa'),

('APO10-P02-A07', 'APO10-P02', 'En el caso específico de la adquisición de infraestructura, instalaciones y servicios relacionados, incluir y hacer cumplir los derechos y obligaciones de todas las partes en los términos contractuales. Estos derechos y obligaciones pueden incluir niveles de servicio, procedimientos de mantenimiento, controles de acceso, seguridad, privacidad, evaluación del rendimiento, base de pago y procedimientos de arbitraje.', 3, NULL, 'La herramienta Eramba, permite registrar contratos con condiciones de seguridad, acceso, mantenimiento y evaluación de riesgo, pero no ejecuta validaciones legales ni redacta cláusulas contractuales', 'No valida legalidad ni asegura cumplimiento normativo de cláusulas', 'Apoyo legal y plantilla externa de contrato'),

('APO10-P03-A01', 'APO10-P03', 'Asignar propietarios de relaciones para todos los proveedores y hacerlos responsables de la calidad de los servicios prestados.', 3, 'Eramba', 'Permite asignar responsables por proveedor y seguir métricas de cumplimiento y riesgo asociado', 'Asignación clara de responsables documentada', '-'),

('APO10-P03-A02', 'APO10-P03', 'Especifique un proceso formal de comunicación y revisión, incluidas las interacciones y los cronogramas con los proveedores.', 3, 'GLPI', 'Permite definir flujos de interacción con terceros y mantener historial, pero no estructuran cronogramas ni acuerdos como lo haría una herramienta de gestión contractual', 'Requiere configuración detallada', 'Integración con ERP o herramientas de gestión de proyectos (como Odoo u OpenProject)'),

('APO10-P03-A03', 'APO10-P03', 'Acordar, gestionar, mantener y renovar contratos formales con el proveedor. Asegurarse de que los contratos cumplan con los estándares empresariales y los requisitos legales y regulatorios.', 3, 'Eramba', 'Permite registrar contratos, fechas y responsables, pero no valida su cumplimiento legal ni tiene alertas automáticas de expiración o renovación', 'Se puede complementar con flujos personalizados o alertas externas', 'Revisión legal periódica'),

('APO10-P03-A04', 'APO10-P03', 'Incluir disposiciones en los contratos con los principales proveedores de servicios para la revisión de las instalaciones del proveedor y de las prácticas y controles internos por parte de la gerencia o de terceros independientes. Acordar controles independientes de auditoría y aseguramiento de los entornos operativos de los proveedores que prestan servicios externalizados para confirmar que se están cumpliendo adecuadamente los requisitos acordados.', 3, NULL, 'Requiere cláusulas legales y acuerdos de auditoría externa que no se automatizan desde herramientas open source', 'No ejecuta ni documenta auditorías de proveedores externas', 'Auditoría externa (manual/documentada)'),

('APO10-P03-A05', 'APO10-P03', 'Utilice los procedimientos establecidos para resolver disputas contractuales. Siempre que sea posible, utilice primero relaciones y comunicaciones efectivas para resolver los problemas de servicio.', 3, NULL, 'Es un proceso legal y de gestión que debe manejarse fuera del sistema (comunicación, mediación, arbitraje)', 'No hay soporte funcional para este proceso', 'Intervención legal o conciliatoria'),

('APO10-P03-A06', 'APO10-P03', 'Defina y formalice las funciones y responsabilidades de cada proveedor de servicios. Si varios proveedores se combinan para prestar un servicio, considere asignarle un rol de contratista principal a uno de ellos para que se encargue de todo el contrato.', 3, 'Eramba', 'Permite documentar funciones específicas de proveedores y establecer roles por contrato o tercero', 'Requiere configuración por contrato', '-'),

('APO10-P03-A07', 'APO10-P03', 'Evaluar la efectividad de la relación e identificar las mejoras necesarias.', 4, 'Eramba', 'Se pueden establecer métricas, evaluaciones de desempeño y revisiones periódicas para cada proveedor', 'Soporta múltiples criterios de evaluación', '-'),

('APO10-P03-A08', 'APO10-P03', 'Definir, comunicar y acordar formas de implementar las mejoras necesarias en la relación.', 5, 'Eramba', 'Permite registrar planes de acción y seguimiento, pero no asegura implementación directa sin integración con un sistema de gestión de proyectos', 'Requiere trabajo complementario fuera del sistema', 'Herramienta de gestión de tareas (como Redmine, OpenProject)'),

('APO10-P04-A01', 'APO10-P04', 'Al preparar el contrato, prevea los posibles riesgos del servicio definiendo claramente los requisitos del mismo, incluidos los acuerdos de depósito de software, los acuerdos con proveedores alternativos o de reserva para mitigar posibles fallos del proveedor; la seguridad y protección de la propiedad intelectual; la privacidad; y cualquier requisito legal o reglamentario.', 3, 'Eramba', 'Permite definir requisitos contractuales, cláusulas de privacidad, propiedad intelectual y acuerdos complementarios. Sin embargo, no ejecuta análisis legal de depósito de software ni reserva de proveedores.', 'Requiere documentación legal externa y acuerdos de respaldo externos', 'Asesoría legal / Documentación firmada externa'),

('APO10-P04-A02', 'APO10-P04', 'Identificar, supervisar y, cuando corresponda, gestionar los riesgos relacionados con la capacidad del proveedor para prestar servicios de forma eficiente, eficaz, segura, confidencial, fiable y continua. Integrar los procesos críticos de gestión interna de TI con los de los proveedores de servicios externalizados, abarcando, por ejemplo, la planificación del rendimiento y la capacidad, la gestión de cambios y la gestión de la configuración.', 4, 'Eramba', 'Cuenta con módulo de gestión de riesgos, evaluación de impacto y planificación de mitigación integrada con terceros y servicios', 'Permite gestión proactiva e integración de actividades de monitoreo con métricas y controles', 'û'),

('APO10-P04-A03', 'APO10-P04', 'Evaluar el ecosistema más amplio del proveedor e identificar, monitorear y, cuando corresponda, gestionar el riesgo relacionado con los subcontratistas y proveedores ascendentes que influyen en la capacidad del proveedor para brindar el servicio de manera eficiente, eficaz, segura, confiable y continua.', 4, 'Eramba', 'Se pueden registrar relaciones jerárquicas entre proveedores y mapear sus riesgos indirectos, pero el monitoreo requiere insumos externos y validación periódica manual', 'La herramienta no realiza auditorías automáticas ni seguimiento activo de proveedores ascendentes', 'Apoyo documental / revisión externa manual'),

('APO10-P05-A01', 'APO10-P05', 'Solicitar revisiones independientes de las prácticas y controles internos del proveedor, si es necesario.', 3, 'Eramba', 'Permite gestionar proveedores, programar revisiones periódicas, asignar revisores externos y documentar evidencias de controles internos y cumplimiento.', 'Diseñada específicamente para gestión de cumplimiento y riesgos relacionados con terceros.', 'Compatible vía API con plataformas externas de evaluación.'),

('APO10-P05-A02', 'APO10-P05', 'Definir y documentar los criterios para supervisar el desempeño del proveedor, en consonancia con los acuerdos de nivel de servicio. Asegurarse de que el proveedor informe de forma regular y transparente sobre los criterios acordados.', 4, 'GLPI', 'Permite registrar y documentar acuerdos con proveedores, gestionar SLAs y asociar criterios de evaluación de desempeño a través de contratos y tickets.', 'Requiere configurar plantillas de contrato y usar complementos para informes periódicos.', 'Plugin SLAs + dashboards o plugins como Reports.'),

('APO10-P05-A03', 'APO10-P05', 'Supervisar y revisar la prestación del servicio para garantizar que el proveedor esté proporcionando una calidad de servicio aceptable, cumpliendo los requisitos y adhiriendo a las condiciones del contrato.', 4, 'GLPI', 'Supervisa tickets, incidencias y cumplimiento de SLAs. Permite generar informes de calidad del servicio entregado por proveedor.', 'Adecuado para monitoreo continuo con métricas de cumplimiento y tiempo de respuesta.', 'Compatible con plugins como FusionInventory y Formcreator.'),

('APO10-P05-A04', 'APO10-P05', 'Analice el rendimiento y la relación calidad-precio del proveedor. Asegúrese de que sea confiable y competitivo, en comparación con otros proveedores y las condiciones del mercado.', 4, 'Eramba', 'Su módulo de gestión de terceros permite evaluar desempeño de proveedores y asociar valor de riesgo residual o económico.', 'Puede vincular desempeño con análisis de costo-riesgo.', 'API para exportación a herramientas de BI.'),

('APO10-P05-A05', 'APO10-P05', 'Monitorear y evaluar la información disponible externamente sobre el proveedor y su cadena de suministro.', 4, 'Eramba', 'Permite incluir evaluaciones de terceros, documentación externa y monitoreo de riesgos de proveedores mediante adjuntos o formularios configurables.', 'Puede incorporar información de fuentes externas en evaluaciones.', 'API para conexión con fuentes externas o herramientas GRC.'),

('APO10-P05-A06', 'APO10-P05', 'Registrar y evaluar periódicamente los resultados de la revisión y discutirlos con el proveedor para identificar necesidades y oportunidades de mejora.', 5, 'GLPI', 'Permite registrar comentarios, informes de desempeño y seguimiento mediante tickets o contratos asociados al proveedor.', 'Requiere proceso manual de reuniones o informes externos.', 'Formcreator para seguimiento y encuestas.'),

('APO11-P01-A01', 'APO11-P01', 'Asegurar que el marco de control de I&T y los procesos de negocio y de TI incluyan un enfoque estándar, formal y continuo para la gestión de la calidad, alineado con los requisitos de la empresa. Dentro del marco de control de I&T y los procesos de negocio y de TI, identificar los requisitos y criterios de calidad (p. ej., basados en requisitos legales y de los clientes).', 3, 'Eramba', 'Permite establecer controles, políticas y procesos documentados para el aseguramiento de calidad y cumplimiento. Puede mapearse a marcos como ISO 9001.', 'Soporta estructuras de control formalizadas y revisiones.', 'APIs para integrarse con herramientas externas de cumplimiento.'),

('APO11-P01-A02', 'APO11-P01', 'Definir roles, tareas, derechos de decisión y responsabilidades para la gestión de la calidad en la estructura organizacional.', 3, 'Eramba', 'Permite asignar responsabilidades específicas a usuarios para controles, políticas, revisiones y excepciones.', 'Puede reflejar jerarquías y flujos de aprobación.', 'Integración con LDAP/AD o plataformas de autenticación.'),

('APO11-P01-A03', 'APO11-P01', 'Obtener aportaciones de la dirección y de las partes interesadas externas e internas sobre la definición de los requisitos de calidad y los criterios de gestión de la calidad.', 3, 'GLPI', 'A través de formularios y tickets configurables se pueden recopilar comentarios y requerimientos de partes interesadas.', 'Requiere configuración previa de flujos de retroalimentación.', 'Formcreator, Notificaciones vía correo o plugins.'),

('APO11-P01-A04', 'APO11-P01', 'Supervisar y revisar periódicamente el SGC según los criterios de aceptación acordados. Incluir la retroalimentación de clientes, usuarios y dirección.', 4, 'Eramba', 'Permite configurar revisiones periódicas del sistema de gestión, establecer criterios de aceptación y documentar feedback.', 'Automatiza ciclos de revisión y auditoría del SGC.', 'Exportación de informes y sincronización con herramientas externas.'),

('APO11-P01-A05', 'APO11-P01', 'Responder a las discrepancias en los resultados de la revisión para mejorar continuamente el SGC.', 5, 'Eramba', 'Permite gestionar planes de mejora, acciones correctivas y revisión de controles con trazabilidad completa.', 'Incluye seguimiento del estado de las acciones.', 'Compatible con herramientas de gestión de proyectos para implementación de mejoras.'),

('APO11-P02-A01', 'APO11-P02', 'Centrar la gestión de calidad en los clientes, determinando sus requisitos internos y externos y garantizando la alineación con los estándares y prácticas de I&T. Definir y comunicar las funciones y responsabilidades en la resolución de conflictos entre el usuario/cliente y la organización de TI.', 3, 'Eramba', 'Permite definir responsabilidades, asignar dueños de controles, y documentar expectativas y criterios alineados con prácticas estándares (ej. ISO 9001/27001).', 'Soporta gestión formal de funciones y responsabilidades.', 'Puede integrarse con sistemas de gestión documental y autenticación.'),

('APO11-P02-A02', 'APO11-P02', 'Gestionar las necesidades y expectativas del negocio para cada proceso, servicio operativo de TI y nuevas soluciones. Mantener sus criterios de calidad.', 3, 'GLPI', 'Permite configurar SLAs, gestionar servicios, mantener criterios de calidad, vincular requerimientos del negocio y realizar trazabilidad.', 'Flexible para integrar criterios por servicio y procesos.', 'SLA plugin, Formcreator para recolección de información.'),

('APO11-P02-A03', 'APO11-P02', 'Comunicar los requisitos y expectativas del cliente a toda la empresa y la organización de TI.', 3, 'GLPI', 'Se puede usar la funcionalidad de notificaciones automáticas y formularios para comunicar requisitos entre áreas y equipos técnicos.', 'La comunicación puede automatizarse según flujos de trabajo.', 'Integración con correo, LDAP y sistemas externos vía API.'),

('APO11-P02-A04', 'APO11-P02', 'Obtener periódicamente la opinión de los clientes sobre los procesos de negocio y la prestación de servicios, así como sobre la entrega de soluciones de TI. Determinar el impacto en los estándares y prácticas de TI y garantizar que se cumplan y se implementen las expectativas de los clientes.', 4, 'GLPI', 'Permite recolectar feedback mediante formularios personalizados, encuestas y seguimiento de tickets.', 'Se pueden crear formularios periódicos con criterios definidos.', 'Email, plugins de reportes, sistemas externos vía API.'),

('APO11-P02-A05', 'APO11-P02', 'Capturar criterios de aceptación de calidad para su inclusión en los SLA.', 4, 'GLPI', 'Permite definir SLA específicos por tipo de servicio, ticket o requerimiento, incluyendo criterios de calidad.', 'Admite configuración de múltiples criterios de aceptación.', 'SLA plugin, Workflows, campos personalizados.'),

('APO11-P03-A01', 'APO11-P03', 'Definir los estándares, prácticas y procedimientos de gestión de calidad en línea con los requisitos del marco de control de I&T y los criterios y políticas de gestión de calidad de la empresa.', 2, 'Eramba', 'Permite establecer políticas, controles y procedimientos de calidad alineados con marcos de control (ej. ISO, COBIT, NIST).', 'Admite versiones, responsables, y revisión periódica de procedimientos.', 'Integración con LDAP, sistemas de ticket o GRC externos.'),

('APO11-P03-A02', 'APO11-P03', 'Integrar las prácticas de gestión de calidad requeridas en los procesos y soluciones clave de toda la organización.', 3, 'Eramba', 'Soporta integración directa de controles y prácticas de calidad con procesos empresariales y activos críticos.', 'Permite seguimiento y cumplimiento por proceso.', 'Integración con herramientas de seguimiento y cumplimiento.'),

('APO11-P03-A03', 'APO11-P03', 'Considere los beneficios y costos de las certificaciones de calidad.', 3, 'Eramba', 'Permite realizar análisis de cumplimiento con estándares de calidad y gestionar proyectos para lograr certificaciones (ej. ISO 27001).', 'Admite evaluación de cumplimiento y documentación asociada.', 'Integrable con plataformas de evaluación externa o de auditoría.'),

('APO11-P03-A04', 'APO11-P03', 'Comunicar eficazmente el enfoque de gestión de calidad (por ejemplo, a través de programas regulares y formales de capacitación sobre calidad).', 3, 'GLPI', 'A través de módulos como "Base de conocimientos" y "Formcreator", se pueden estructurar y difundir contenidos de capacitación.', 'Admite documentación, encuestas y material formativo.', 'Integrable con sistemas LMS o correo electrónico para difusión.'),

('APO11-P03-A05', 'APO11-P03', 'Registrar y supervisar los datos de calidad. Utilizar las buenas prácticas del sector como referencia para mejorar y adaptar las prácticas de calidad de la empresa.', 4, 'Zabbix', 'Permite recolectar, supervisar y analizar métricas de calidad de servicios, rendimiento y disponibilidad.', 'Es útil para datos cuantitativos de calidad de TI.', 'Integración con GLPI, bases de datos, o APIs externas.'),

('APO11-P03-A06', 'APO11-P03', 'Revisar periódicamente la pertinencia, eficiencia y eficacia continuas de los procesos específicos de gestión de la calidad. Supervisar el cumplimiento de los objetivos de calidad.', 4, 'Eramba', 'Permite revisión continua de procesos de calidad mediante auditorías internas, evaluaciones y seguimiento de controles.', 'Admite revisión programada y documentación de hallazgos.', 'Compatible con exportación de reportes y seguimiento por tareas.'),

('APO11-P04-A01', 'APO11-P04', 'Preparar y realizar revisiones de calidad para procesos y soluciones organizacionales clave.', 3, 'Eramba', 'Eramba permite planificar y ejecutar auditorías internas y revisiones de calidad sobre procesos, controles y políticas.', 'Soporta revisiones periódicas documentadas con hallazgos y responsables.', 'Integrable con herramientas de notificación por correo o LDAP.'),

('APO11-P04-A02', 'APO11-P04', 'Para estos procesos y soluciones organizacionales clave, monitoree las métricas de calidad orientadas a objetivos alineadas con los objetivos generales de calidad.', 4, 'Zabbix', 'Zabbix permite definir y monitorear métricas (KPIs) asociadas a calidad del servicio, disponibilidad y rendimiento.', 'Ideal para métricas técnicas cuantificables.', 'Integración con GLPI, bases de datos externas, Prometheus.'),

('APO11-P04-A03', 'APO11-P04', 'Asegúrese de que la gerencia y los propietarios de procesos revisen periódicamente el desempeño de la gestión de calidad en comparación con las métricas de calidad definidas.', 4, 'GLPI', 'Permite programar revisiones, registrar comentarios, generar informes de desempeño y asignar responsables mediante su módulo de gestión de tareas.', 'Apoya reuniones periódicas de revisión mediante reportes configurables.', 'Integración con Zabbix, dashboards o Google Workspace.'),

('APO11-P04-A04', 'APO11-P04', 'Analizar los resultados generales del desempeño de la gestión de la calidad.', 4, 'Eramba', 'Provee vistas y reportes para analizar resultados de auditorías y desempeño de controles.', 'Ofrece informes por periodo y seguimiento por responsables.', 'Exportación a Excel, integración con sistemas de ticketing o BI.'),

('APO11-P04-A05', 'APO11-P04', 'Informar los resultados de la revisión del desempeño de la gestión de calidad e iniciar mejoras cuando sea apropiado.', 5, 'GLPI', 'Permite documentar informes, asignar tareas correctivas, y enviar notificaciones de seguimiento.', 'Se puede vincular a auditorías y revisiones de calidad.', 'Uso de plugin Formcreator para estructurar flujos.'),

('APO11-P05-A01', 'APO11-P05', 'Establecer una plataforma para compartir buenas prácticas y capturar información sobre defectos y errores para permitir aprender de ellos.', 2, 'GLPI', 'GLPI permite registrar incidentes, errores y defectos, mantener una base de conocimientos y compartir buenas prácticas.', 'Soporta la documentación colaborativa y el aprendizaje organizacional.', 'Formcreator para flujos de reporte estructurado.'),

('APO11-P05-A02', 'APO11-P05', 'Identifique ejemplos de procesos de entrega de excelente calidad que puedan beneficiar a otros servicios o proyectos. Compártalos con los equipos de servicios y proyectos para fomentar la mejora.', 3, 'GLPI', 'Documentación de proyectos, informes y procedimientos puede compartirse entre equipos mediante la base de conocimientos y los módulos de proyectos.', 'Permite replicar prácticas entre equipos y servicios.', 'Se puede integrar con Zabbix para análisis de rendimiento.'),

('APO11-P05-A03', 'APO11-P05', 'Identificar ejemplos recurrentes de defectos de calidad. Determinar su causa raíz, evaluar su impacto y resultados, y acordar acciones de mejora con los equipos de servicio y/o ejecución del proyecto.', 3, 'Eramba', 'Ofrece análisis de incidentes, evaluación de riesgos e impacto, y definición de acciones correctivas sobre procesos de calidad y control.', 'Ideal para gestión estructurada de causas raíz y acciones.', 'Puede exportar reportes para integrarse con GLPI o sistemas de BI.'),

('APO11-P05-A04', 'APO11-P05', 'Proporcionar a los empleados capacitación en los métodos y herramientas de mejora continua.', 3, 'GLPI', 'Se pueden documentar programas de capacitación, registrar asistencia y compartir materiales a través de formularios y la base de conocimientos.', 'Requiere configuración personalizada para temas formativos.', 'Integración con GSuite o LMS externos para seguimiento más completo.'),

('APO11-P05-A05', 'APO11-P05', 'Compare los resultados de las revisiones de calidad con datos históricos internos, pautas de la industria, estándares y datos de tipos similares de empresas.', 4, 'Eramba', 'Ofrece seguimiento de revisiones internas y comparación con estándares (ISO, NIST, etc.). Permite importar controles y configurar revisiones periódicas.', 'Útil para cumplimiento normativo y benchmarking interno.', 'Exporta a Excel y se puede enlazar con herramientas de BI.'),

('APO12-P01-A01', 'APO12-P01', 'Establecer y mantener un método para la recopilación, clasificación y análisis de datos relacionados con el riesgo de I&T.', 2, 'Eramba', 'Proporciona métodos estructurados para clasificar y analizar riesgos mediante taxonomías personalizables, plantillas de evaluación, scoring y mapeo de controles.', 'Incluye gestión completa del ciclo de vida del riesgo.', 'Se integra con herramientas de monitoreo o ticketing como Zabbix o GLPI.'),

('APO12-P01-A02', 'APO12-P01', 'Registrar datos relevantes y significativos relacionados con el riesgo de I&T en el entorno operativo interno y externo de la empresa.', 2, 'Eramba', 'Permite registrar riesgos detectados tanto en entornos internos como externos y asociarlos con activos, procesos o proyectos.', 'Permite relacionar eventos y evidencias de múltiples fuentes.', 'Compatible con fuentes externas vía API o integración con SIEM.'),

('APO12-P01-A03', 'APO12-P01', 'Adoptar o definir una taxonomía de riesgos para obtener definiciones consistentes de escenarios de riesgo y categorías de impacto y probabilidad.', 3, 'Eramba', 'Ofrece soporte completo para la definición de taxonomías de riesgos, criterios de impacto/probabilidad y plantillas de evaluación estandarizadas.', 'Permite configurar diferentes métodos (custom, ISO, FAIR, etc.).', 'Exportable y compatible con normativas externas.'),

('APO12-P01-A04', 'APO12-P01', 'Registrar datos sobre eventos de riesgo que hayan causado o puedan causar impactos en el negocio, según las categorías de impacto definidas en la taxonomía de riesgos. Obtener datos relevantes de problemas, incidentes, problemas e investigaciones relacionados.', 3, 'GLPI', 'Permite registrar y documentar eventos de incidentes y problemas, los cuales pueden asociarse a impactos operativos y riesgos identificados.', 'Puede actuar como base de datos de eventos reales para alimentar el análisis de riesgos.', 'Integrable con Eramba para alimentar automáticamente su base de datos de riesgos.'),

('APO12-P01-A05', 'APO12-P01', 'Examinar y analizar los datos históricos de riesgo de I&T y la experiencia de pérdidas a partir de datos y tendencias disponibles externamente, pares de la industria a través de registros de eventos basados en la industria, bases de datos y acuerdos de la industria para la divulgación de eventos comunes.', 4, 'Eramba', 'Permite importar datos históricos y analizar la experiencia de pérdidas mediante registros de eventos y reportes consolidados. Soporta análisis de tendencias y eventos a partir de fuentes externas.', 'Soporta análisis comparativos de industria y personalización de criterios de evaluación.', 'Puede conectarse vía API a fuentes externas o integrarse con GLPI para incidentes.'),

('APO12-P01-A06', 'APO12-P01', 'Para clases de eventos similares, organice los datos recopilados y destaque los factores contribuyentes. Determine los factores contribuyentes comunes en varios eventos.', 4, 'Eramba', 'Permite agrupar eventos de riesgo por tipo y registrar causas raíz, factores contribuyentes y planes de tratamiento. Soporta taxonomía para clasificaciones.', 'Permite identificar patrones y consolidar eventos.', 'Puede alimentarse de tickets/incidentes GLPI o eventos desde SIEM vía API.'),

('APO12-P01-A07', 'APO12-P01', 'Determinar las condiciones específicas que existían o estaban ausentes cuando ocurrieron los eventos de riesgo y la forma en que las condiciones afectaron la frecuencia de los eventos y la magnitud de la pérdida.', 4, 'Open Source Risk Engine', 'Permite análisis de escenarios y simulación de condiciones de riesgo para evaluar el impacto de factores contextuales sobre la pérdida y frecuencia.', 'Específico para modelado financiero y análisis cuantitativo de riesgos.', 'Puede usar datos exportados desde Eramba o GLPI como entrada para escenarios.'),

('APO12-P01-A08', 'APO12-P01', 'Realizar análisis periódicos de eventos y factores de riesgo para identificar problemas de riesgo nuevos o emergentes y obtener una comprensión de los factores de riesgo internos y externos asociados.', 4, 'Zabbix', 'Realiza monitoreo proactivo de condiciones internas (infraestructura, red, aplicaciones) que puede alertar sobre riesgos emergentes. Permite establecer correlaciones de eventos e indicadores.', 'Ideal para detectar patrones técnicos de riesgo emergente.', 'Puede integrarse con Eramba para actualizar el registro de riesgos de forma automatizada.'),

('APO12-P02-A01', 'APO12-P02', 'Definir el alcance apropiado de los esfuerzos de análisis de riesgos, considerando todos los factores de riesgo y/o la criticidad comercial de los activos.', 3, 'Eramba', 'Permite definir y categorizar activos críticos, evaluar su valor para el negocio y establecer alcance y parámetros de análisis de riesgos asociados.', 'Soporta taxonomía de activos y criticidad según valor de negocio.', 'Puede integrarse con GLPI para importar activos o con CMDB externas.'),

('APO12-P02-A02', 'APO12-P02', 'Desarrollar y actualizar periódicamente escenarios de riesgo de TI; exposiciones a pérdidas relacionadas con TI; y escenarios de riesgo reputacional, incluyendo escenarios compuestos de amenazas y eventos en cascada o coincidentes. Desarrollar expectativas para actividades de control específicas y capacidades de detección.', 3, 'Eramba', 'Ofrece herramientas para crear, modelar y mantener escenarios de riesgo, incluyendo amenazas múltiples, impacto reputacional y asignación de controles.', 'Permite seguimiento de controles específicos para cada escenario.', 'Puede integrarse con Zabbix para detectar condiciones activadoras.'),

('APO12-P02-A03', 'APO12-P02', 'Estime la frecuencia (o probabilidad) y la magnitud de las pérdidas o ganancias asociadas con los escenarios de riesgo de I&T. Considere todos los factores de riesgo aplicables y evalúe los controles operativos conocidos.', 3, 'Open Source Risk Engine', 'Permite análisis cuantitativo del riesgo: calcula probabilidad y pérdida esperada mediante simulaciones, valor en riesgo (VaR) y medidas estadísticas.', 'Altamente orientado a análisis financiero y probabilístico.', 'Puede tomar como entrada escenarios exportados desde Eramba'),

('APO12-P02-A04', 'APO12-P02', 'Compare el riesgo actual (exposición a pérdidas relacionadas con I&T) con el apetito de riesgo y la tolerancia al riesgo aceptable. Identifique el riesgo inaceptable o elevado.', 3, 'Eramba', 'Permite comparar el riesgo inherente y residual contra matrices configurables de apetito y tolerancia. Alerta automáticamente si el riesgo excede niveles aceptables.', 'Genera reportes de desviación y recomendaciones automáticas.', 'Complementa modelos de ORE; puede recibir entradas de monitoreo como Zabbix.'),

('APO12-P02-A05', 'APO12-P02', 'Proponer respuestas al riesgo que excedan los niveles de apetito y tolerancia al riesgo.', 3, 'Eramba', 'Permite definir respuestas específicas para riesgos fuera del umbral, clasificadas como mitigación, transferencia, aceptación o evitación. Estas respuestas se relacionan con controles activos o pendientes.', 'Las respuestas pueden configurarse para revisión y validación por responsables.', 'Puede complementarse con Zabbix para correlacionar incidentes que activan respuestas.'),

('APO12-P02-A06', 'APO12-P02', 'Especifique los requisitos generales para los proyectos o programas que implementarán las respuestas a los riesgos seleccionados. Identifique los requisitos y las expectativas para los controles clave adecuados para las respuestas de mitigación de riesgos.', 3, 'Eramba', 'Permite vincular proyectos de tratamiento a riesgos identificados, especificar controles requeridos, documentar requisitos y programar tareas de implementación.', 'Soporta evaluación periódica del estado de implementación de controles asociados.', 'Puede integrarse con herramientas de gestión de proyectos externas como Jira mediante API.'),

('APO12-P02-A07', 'APO12-P02', 'Valide los resultados del análisis de riesgos y del análisis de impacto en el negocio (BIA) antes de utilizarlos en la toma de decisiones. Confirme que el análisis se ajuste a los requisitos de la empresa y verifique que las estimaciones se hayan calibrado correctamente y se hayan analizado cuidadosamente para detectar sesgos.', 4, 'Open Source Risk Engine', 'Ofrece validación cuantitativa de modelos de riesgo mediante simulación Monte Carlo, VaR y análisis de sensibilidad. Permite verificar si las estimaciones se ajustan a distribuciones esperadas y escenarios definidos.', 'Es más potente en análisis estadístico que cualitativo.', 'Puede usar insumos exportados desde Eramba o CMDBs.'),

('APO12-P02-A08', 'APO12-P02', 'Analice la relación costo-beneficio de las posibles opciones de respuesta al riesgo, como evitar, reducir/mitigar, transferir/compartir, y aceptar y aprovechar/aprovechar. Confirme la respuesta óptima al riesgo.', 5, 'Open Source Risk Engine', 'Permite comparar escenarios de riesgo con y sin controles aplicados, estimar impacto financiero esperado, y calcular relación costo-beneficio para cada respuesta.', 'Ofrece análisis detallado de eficiencia de mitigación con base cuantitativa.', 'Complementa Eramba exportando y analizando planes de tratamiento.'),

('APO12-P03-A01', 'APO12-P03', 'Inventariar los procesos de negocio y documentar su dependencia de los procesos de gestión de servicios de TI y de los recursos de infraestructura de TI. Identificar el personal de apoyo, las aplicaciones, la infraestructura, las instalaciones, los registros manuales críticos, los proveedores y los subcontratistas.', 2, 'GLPI', 'Permite mantener un inventario detallado de procesos, infraestructura, personal, proveedores y relaciones de dependencia mediante objetos enlazados y campos personalizados.', 'Requiere modelar relaciones entre elementos con lógica de dependencias.', 'Puede integrarse con plugins como DataInjection para carga masiva de procesos o dependencias.'),

('APO12-P03-A02', 'APO12-P03', 'Determinar y acordar qué servicios de TI y recursos de infraestructura de TI son esenciales para el funcionamiento de los procesos de negocio. Analizar las dependencias e identificar los puntos débiles.', 2, 'GLPI', 'Permite vincular servicios de TI con elementos críticos de infraestructura y procesos, identificando relaciones de dependencia y riesgos asociados.', 'Requiere estructurar correctamente relaciones entre activos y procesos para análisis efectivo.', 'Se puede integrar con Zabbix para detectar puntos débiles en la infraestructura monitoreada.'),

('APO12-P03-A03', 'APO12-P03', 'Agregue los escenarios de riesgo actuales por categoría, línea de negocio y área funcional.', 2, 'Eramba', 'Permite clasificar escenarios de riesgo según múltiples dimensiones (categoría, proceso, unidad de negocio, área funcional) y analizarlos desde cada perspectiva.', 'Soporta análisis consolidado y por vista individual.', 'Exportable a herramientas de BI o análisis estadístico externo.'),

('APO12-P03-A04', 'APO12-P03', 'Capturar periódicamente toda la información del perfil de riesgo y consolidarla en un perfil de riesgo agregado.', 3, 'Eramba', 'Facilita la recopilación y consolidación de escenarios, planes, métricas, controles y tratamientos en un perfil de riesgo agregado.', 'Se puede programar exportaciones periódicas en formatos estructurados.', 'Puede integrarse con herramientas de visualización como Grafana o Power BI.'),

('APO12-P03-A05', 'APO12-P03', 'Capturar información sobre el estado del plan de acción de riesgos para su inclusión en el perfil de riesgo de I&T de la empresa.', 3, 'Eramba', 'Incluye seguimiento del estado de tratamiento de riesgos, asignación de responsables, cronograma, porcentaje de avance y alertas por vencimiento.', 'Vista integrada con el perfil de riesgo para análisis de cumplimiento.', 'Posibilidad de exportación o visualización a través de API REST.'),

('APO12-P03-A06', 'APO12-P03', 'Con base en todos los datos del perfil de riesgo, definir un conjunto de indicadores de riesgo que permitan la rápida identificación y seguimiento del riesgo actual y las tendencias de riesgo.', 4, 'Eramba', 'Permite definir Key Risk Indicators (KRI), establecer umbrales, adjuntar evidencia y automatizar alertas por desviación.', 'Incluye seguimiento automático del cumplimiento de KRIs definidos.', 'Puede integrarse con Zabbix para alimentar KRIs desde eventos reales.'),

('APO12-P03-A07', 'APO12-P03', 'Capturar información sobre eventos de riesgo de I&T que se hayan materializado para su inclusión en el perfil de riesgo de TI de la empresa.', 4, 'Eramba', 'Registra incidentes relacionados con riesgos identificados y los asocia directamente al escenario de riesgo afectado, actualizando el perfil.', 'Soporta carga manual o automática de eventos con clasificación.', 'Puede integrarse con herramientas de monitoreo como Snort para importar eventos críticos.'),

('APO12-P04-A01', 'APO12-P04', 'Informar a todas las partes interesadas sobre los resultados del análisis de riesgos en términos y formatos útiles para fundamentar las decisiones empresariales. Siempre que sea posible, incluir probabilidades y rangos de pérdida o ganancia, junto con los niveles de confianza, para que la gerencia pueda equilibrar la rentabilidad del riesgo.', 3, 'Eramba', 'Permite generar reportes personalizables de riesgos con rangos de probabilidad, impacto y niveles de confianza, configurables para distintas audiencias.', 'Puede exportar informes en formatos visuales y compartibles (PDF, Excel).', 'Compatible con herramientas externas vía API para difusión o integración en dashboards empresariales.'),

('APO12-P04-A02', 'APO12-P04', 'Proporcionar a los tomadores de decisiones una comprensión de los escenarios más probables y peores, las exposiciones a pérdidas relacionadas con I&T y las consideraciones significativas de reputación, legales y regulatorias, o cualquier otra categoría de impacto según la taxonomía de riesgos.', 3, 'Eramba', 'Soporta la configuración de múltiples escenarios de riesgo incluyendo riesgos reputacionales, regulatorios y legales. Visualización clara para decisiones estratégicas.', 'Se pueden definir distintos tipos de impacto y niveles de gravedad por categoría.', 'Integrable con herramientas BI para presentación ejecutiva.'),

('APO12-P04-A03', 'APO12-P04', 'Informar sobre el perfil de riesgo actual a todas las partes interesadas. Incluir información sobre la eficacia del proceso de gestión de riesgos, la eficacia de los controles, las brechas, las inconsistencias, las redundancias, el estado de las remediaciones y su impacto en el perfil de riesgo.', 3, 'Eramba', 'Permite visualizar el perfil de riesgo consolidado, incluyendo brechas, estado de planes de acción, eficacia de controles y remediaciones.', 'El sistema ofrece vistas dinámicas de evolución del riesgo y seguimiento.', 'Compatible con sistemas de auditoría y revisión mediante registros históricos.'),

('APO12-P04-A04', 'APO12-P04', 'Periódicamente, en áreas con riesgo relativo y paridad de capacidad de riesgo, identificar oportunidades relacionadas con I&T que permitan la aceptación de un mayor riesgo y un mejor crecimiento y retorno.', 3, 'Eramba', 'Permite asociar riesgos a oportunidades estratégicas, evaluando impacto positivo si el riesgo es aceptado conscientemente.', 'Esta funcionalidad permite alineación con objetivos de crecimiento estratégico.', 'Puede combinarse con análisis externo de mercado para mejorar decisiones.'),

('APO12-P04-A05', 'APO12-P04', 'Revise los resultados de las evaluaciones objetivas de terceros, las auditorías internas y las revisiones de control de calidad. Incluya estos resultados en el perfil de riesgos. Revise las brechas identificadas y las exposiciones a pérdidas relacionadas con I&T para determinar la necesidad de un análisis de riesgos adicional.', 4, 'Eramba', 'Tiene soporte para registrar hallazgos de auditoría interna y externa, asociarlos a riesgos existentes y actualizar el perfil.', 'Posibilidad de seguimiento por acción correctiva o reevaluación.', 'Puede integrarse con GLPI para registrar tickets correctivos si se requiere.'),

('APO12-P05-A01', 'APO12-P05', 'Mantener un inventario de las actividades de control implementadas para mitigar el riesgo y que permitan asumirlo conforme a la tolerancia al riesgo. Clasificar las actividades de control y asignarlas a escenarios de riesgo de I&T específicos y a conjuntos de escenarios de riesgo de I&T.', 2, 'Eramba', 'Eramba permite definir, mantener y clasificar controles vinculados a escenarios de riesgo específicos, con categorización por tipo y evaluación de efectividad.', 'Los controles pueden ser mapeados a múltiples escenarios de riesgo con facilidad.', 'Integrable con sistemas externos mediante su API REST para trazabilidad.'),

('APO12-P05-A02', 'APO12-P05', 'Determinar si cada entidad organizacional monitorea el riesgo y acepta la responsabilidad de operar dentro de sus niveles de tolerancia individuales y de cartera.', 3, 'Eramba', 'Permite asignar ownership de riesgos y controles por unidad organizacional, con definición de tolerancias por entidad y visibilidad segmentada.', 'Permite ver si los responsables actúan dentro de márgenes definidos.', 'Puede integrarse con herramientas de compliance o seguimiento (GLPI, Jira).'),

('APO12-P05-A03', 'APO12-P05', 'Definir un conjunto equilibrado de propuestas de proyectos diseñados para reducir el riesgo y/o proyectos que posibiliten oportunidades empresariales estratégicas, considerando costos, beneficios, efecto sobre el perfil de riesgo actual y regulaciones.', 3, 'Eramba', 'Permite asociar planes de acción a riesgos y evaluar su impacto potencial, costo, y alineación con objetivos estratégicos de negocio y cumplimiento.', 'Los proyectos pueden incluir acciones de mitigación o capitalización de oportunidades.', 'Integración con herramientas de gestión de proyectos como Jira o MS Project vía API.'),

('APO12-P06-A01', 'APO12-P06', 'Preparar, mantener y probar planes que documenten los pasos específicos a seguir cuando un evento de riesgo pueda causar un incidente operativo o de desarrollo significativo con un impacto grave en el negocio. Asegurar que los planes incluyan vías de escalamiento en toda la empresa.', 3, 'Eramba', 'Permite documentar, asignar responsables y establecer workflows de planes de tratamiento del riesgo, incluyendo rutas de escalamiento.', 'Incluye ciclos de revisión, documentación y pruebas de los planes.', 'Se integra con sistemas externos por API para automatizar procesos de respuesta.'),

('APO12-P06-A02', 'APO12-P06', 'Aplicar el plan de respuesta adecuado para minimizar el impacto cuando ocurran incidentes de riesgo.', 3, 'Eramba', 'Los planes de respuesta pueden ser activados manual o automáticamente; se registran las acciones realizadas, responsables y evidencias.', 'Compatible con flujos de ejecución y seguimiento de cumplimiento.', 'Se puede integrar con GLPI, Jira o sistemas de ticketing para activar tareas.'),

('APO12-P06-A03', 'APO12-P06', 'Clasifique los incidentes y compare la exposición a pérdidas relacionadas con I&T con los umbrales de tolerancia al riesgo. Comunique los impactos en el negocio a los responsables de la toma de decisiones como parte de los informes y actualice el perfil de riesgo.', 4, 'Eramba', 'Soporta clasificación de incidentes por tipo de riesgo, categoría de impacto y tolerancia definida. Puede actualizar automáticamente el perfil de riesgo.', 'Permite establecer umbrales y alertas de tolerancia.', 'Integrable con sistemas de monitoreo o seguridad (Snort, Zabbix).'),

('APO12-P06-A04', 'APO12-P06', 'Examinar los eventos/pérdidas adversos y las oportunidades perdidas del pasado y determinar las causas fundamentales.', 4, 'Eramba', 'Permite realizar análisis de causa raíz y documentar hallazgos como parte de un ciclo de mejora de gestión de riesgos.', 'Incluye campos para registrar análisis detallados y acciones correctivas.', 'Exporta información para reportes y seguimiento externo.'),

('APO12-P06-A05', 'APO12-P06', 'Comunicar la causa raíz, los requisitos adicionales de respuesta a riesgos y las mejoras de procesos a los responsables de la toma de decisiones. Asegurar que la causa, los requisitos de respuesta y las mejoras de procesos se incluyan en los procesos de gobernanza de riesgos.', 5, 'Eramba', 'Genera informes sobre hallazgos, causas raíz, y mejoras recomendadas con rutas de aprobación. Compatible con procesos de gobernanza.', 'Soporta auditorías internas y revisiones ejecutivas.', 'Puede integrarse con herramientas de reporting externas (Power BI, Tableau).'),

('APO13-P01-A01', 'APO13-P01', 'Defina el alcance y los límites del sistema de gestión de seguridad de la información (SGSI) en función de las características de la empresa, la organización, su ubicación, sus activos y su tecnología. Incluya detalles y justifique cualquier exclusión del alcance.', 2, 'Eramba', 'Permite definir el alcance del SGSI incluyendo ubicaciones, activos, tecnologías, justificando exclusiones de forma documentada.', 'Se puede documentar detalladamente el contexto organizacional y alcance.', 'Exportable a PDF o Excel para auditorías externas.'),

('APO13-P01-A02', 'APO13-P01', 'Definir un SGSI de acuerdo con la política empresarial y el contexto en el que opera la empresa.', 2, 'Eramba', 'Permite la creación de políticas, objetivos de control y definición de contexto organizacional que sustentan el SGSI.', 'Compatible con ISO/IEC 27001 y personalizable según necesidades.', 'Se puede vincular a controles, riesgos y auditorías internas.'),

('APO13-P01-A03', 'APO13-P01', 'Alinear el SGSI con el enfoque global de la empresa para la gestión de la seguridad.', 2, 'Eramba', 'El sistema permite mapear controles de seguridad y objetivos organizacionales, manteniendo la trazabilidad.', 'Alineación con marco global de seguridad y políticas empresariales.', 'Exportable para auditoría o revisión de terceros.'),

('APO13-P01-A04', 'APO13-P01', 'Obtener la autorización de la dirección para implementar y operar o cambiar el SGSI.', 2, 'Eramba', 'Incluye funciones de aprobación y seguimiento para políticas y cambios en el SGSI, con trazabilidad de firmas y fechas.', 'Permite registrar evidencia de aprobación por parte de la alta dirección.', 'Se puede conectar con sistemas de firma digital o correo electrónico.'),

('APO13-P01-A05', 'APO13-P01', 'Preparar y mantener una declaración de aplicabilidad que describa el alcance del SGSI.', 2, 'Eramba', 'Soporta la generación de declaraciones de aplicabilidad vinculadas a controles activos/inactivos.', 'Compatible con normativas como ISO/IEC 27001.', 'Permite versión controlada para revisiones y auditorías.'),

('APO13-P01-A06', 'APO13-P01', 'Definir y comunicar las funciones y responsabilidades de la gestión de la seguridad de la información.', 2, 'Eramba', 'Se pueden asignar roles y responsables para cada control, política o proceso de seguridad.', 'Registro claro de responsables y validación de tareas.', 'Puede integrarse con directorios organizacionales o herramientas ITSM.'),

('APO13-P01-A07', 'APO13-P01', 'Comunicar el enfoque del SGSI.', 2, 'Eramba', 'Soporta difusión de políticas, manuales del SGSI y presentaciones por medio de workflows y notificaciones.', 'Puede evidenciar aceptación por parte de usuarios o partes interesadas.', 'Integración con email corporativo y panel de usuarios.'),

('APO13-P02-A01', 'APO13-P02', 'Formular y mantener un plan de gestión de riesgos de seguridad de la información alineado con el objetivo estratégico y la arquitectura empresarial. Asegurarse de que el plan identifique las prácticas de gestión y las soluciones de seguridad óptimas y adecuadas, junto con los recursos, las responsabilidades y las prioridades correspondientes para gestionar los riesgos de seguridad de la información identificados.', 3, 'Eramba', 'Permite definir y mantener planes de tratamiento de riesgos de seguridad alineados con objetivos estratégicos, asignando responsables, fechas y prioridades.', 'Cumple estándares como ISO 27001 y soporta flujo de aprobaciones.', 'Exporta reportes PDF o Excel, puede conectarse con ITSM externo.'),

('APO13-P02-A02', 'APO13-P02', 'Mantener como parte de la arquitectura empresarial un inventario de los componentes de la solución que están en funcionamiento para gestionar el riesgo relacionado con la seguridad.', 3, 'Eramba', 'Permite inventariar activos relacionados con la seguridad, asociarlos a riesgos, controles, y procesos empresariales.', 'Visibilidad de componentes clave dentro del marco de riesgo.', 'Posible integración con herramientas CMDB externas vía API.'),

('APO13-P02-A03', 'APO13-P02', 'Desarrollar propuestas para implementar el plan de tratamiento de riesgos de seguridad de la información, respaldadas por casos de negocios adecuados que incluyan la consideración del financiamiento y la asignación de funciones y responsabilidades.', 3, 'Eramba', 'Soporta la documentación estructurada de iniciativas de tratamiento de riesgos, con casos de negocio, presupuesto, responsables y métricas.', 'Permite seguimiento del avance del plan con evidencias.', 'Integrable con herramientas financieras o de gestión de proyectos.'),

('APO13-P02-A04', 'APO13-P02', 'Proporcionar información para el diseño y desarrollo de prácticas y soluciones de gestión seleccionadas del plan de tratamiento de riesgos de seguridad de la información.', 3, 'Eramba', 'Incluye trazabilidad entre amenazas, riesgos, controles y soluciones. Facilita retroalimentación y documentación para su diseño e implementación.', 'Información accesible desde interfaz para gestión de cambios y toma de decisiones.', 'Compatible con exportación e integración con gestores de proyectos.'),

('APO13-P02-A05', 'APO13-P02', 'Implementar programas de capacitación y concientización sobre seguridad y privacidad de la información.', 3, 'Eramba', 'Permite crear y gestionar campañas de concientización en seguridad, incluyendo asignación de participantes y seguimiento del cumplimiento.', 'Notificaciones por correo, control de participación, auditoría de cumplimiento.', 'Posibilidad de integración con LMS o correo corporativo vía API.'),

('APO13-P02-A06', 'APO13-P02', 'Integrar la planificación, el diseño, la implementación y el seguimiento de los procedimientos de seguridad y privacidad de la información y otros controles capaces de permitir la pronta prevención, detección de eventos de seguridad y respuesta a incidentes de seguridad.', 3, 'Eramba', 'Permite definir controles de seguridad, enlazarlos a amenazas y riesgos, y hacer seguimiento de su efectividad.', 'Proporciona trazabilidad entre incidentes, controles y riesgos. Seguimiento a acciones correctivas.', 'Integrable con SIEM externos o herramientas de ticketing.'),

('APO13-P02-A07', 'APO13-P02', 'Defina cómo medir la eficacia de las prácticas de gestión seleccionadas. Especifique cómo se utilizarán estas mediciones para evaluar la eficacia y obtener resultados comparables y reproducibles.', 4, 'Eramba', 'Soporta la definición de métricas (KPIs/KRIs) para cada control, tratamiento o riesgo, y permite establecer umbrales.', 'Medición periódica, generación de evidencias y gráficos para comparación.', 'Exportación de resultados a Excel o API para dashboards externos.'),

('APO13-P03-A01', 'APO13-P03', 'Realizar revisiones periódicas de la eficacia del SGSI. Esto incluye el cumplimiento de la política y los objetivos del SGSI, así como la revisión de las prácticas de seguridad y privacidad.', 4, 'Eramba', 'Permite gestionar, programar y ejecutar revisiones periódicas de seguridad, incluyendo evaluación de cumplimiento de políticas y objetivos del SGSI.', 'Eramba ofrece flujos de trabajo específicos para revisión y seguimiento.', 'No requiere integración'),

('APO13-P03-A02', 'APO13-P03', 'Realizar auditorías del SGSI a intervalos planificados.', 4, 'Eramba', 'Soporta auditorías formales, estableciendo planificaciones, checklists, responsables y evidencias.', 'Incorpora gestión de hallazgos, informes y seguimiento.', 'No requiere integración'),

('APO13-P03-A03', 'APO13-P03', 'Realizar periódicamente una revisión de la gestión del SGSI para garantizar que el alcance siga siendo adecuado y que se identifiquen mejoras en el proceso del SGSI.', 4, 'Eramba', 'Permite planificar y documentar revisiones de gestión sobre políticas, alcance, eficacia y oportunidades de mejora del SGSI.', 'Soporta tareas recurrentes, responsables y revisiones aprobadas.', 'No requiere integración'),

('APO13-P03-A04', 'APO13-P03', 'Registrar acciones y eventos que podrían tener un impacto en la efectividad o el desempeño del SGSI.', 4, 'Eramba', 'Gestiona eventos, incidentes, hallazgos y registros de auditoría que pueden impactar el SGSI, permitiendo rastreo y análisis.', 'Permite trazabilidad completa y conexión con políticas, controles y auditorías.', 'No requiere integración'),

('APO13-P03-A05', 'APO13-P03', 'Proporcionar información para el mantenimiento de los planes de seguridad para tomar en cuenta los hallazgos de las actividades de monitoreo y revisión.', 5, 'Eramba', 'Relaciona los hallazgos y resultados de monitoreo con políticas de seguridad, controles y planes de tratamiento.', 'Información disponible para alimentar planes de seguridad actualizados.', 'No requiere integración'),

('APO14-P01-A01', 'APO14-P01', 'Establecer una función de gestión de datos con la responsabilidad de gestionar las actividades que respaldan los objetivos de gestión de datos.', 2, 'Alfresco', 'Permite crear flujos documentales con estructura jerárquica y asignación de responsabilidades sobre gestión de información y datos empresariales.', 'Soporta estructuras organizativas y funciones de control documental alineadas a la gestión de datos.', 'No requiere integración'),

('APO14-P01-A02', 'APO14-P01', 'Especificar roles y responsabilidades para apoyar la gestión de datos y la interacción entre la gobernanza y la función de gestión de datos.', 2, 'Alfresco', 'Permite asignar permisos granulares y gestionar roles por usuario o grupo, con trazabilidad de acciones sobre la información.', 'Compatible con políticas de acceso y roles dentro de procesos de gobernanza de datos.', 'No requiere integración'),

('APO14-P01-A03', 'APO14-P01', 'Asegurar que el área de negocio y tecnología desarrollen conjuntamente la estrategia de gestión de datos de la organización. Asegurarse de que los objetivos, prioridades y alcance de la gestión de datos reflejen los objetivos de la empresa, sean coherentes con las políticas y normativas de gestión de datos, y cuenten con la aprobación de todas las partes interesadas.', 3, 'Alfresco', 'Permite colaboración entre áreas mediante flujos de trabajo compartidos y control de versiones, promoviendo participación en desarrollo estratégico.', 'Facilita la definición colaborativa de políticas y objetivos de datos.', 'No requiere integración'),

('APO14-P01-A04', 'APO14-P01', 'Comunicar los objetivos, prioridades y alcance de la gestión de datos y ajustarlos según sea necesario, en función de la retroalimentación.', 3, 'Alfresco', 'Publicación y distribución de políticas y estrategias documentales a través de portales internos, con mecanismos de retroalimentación.', 'Permite actualización controlada de documentos estratégicos y su redistribución.', 'No requiere integración'),

('APO14-P01-A05', 'APO14-P01', 'Utilizar métricas para evaluar y monitorear el logro de los objetivos de gestión de datos.', 4, 'Alfresco', 'Permite generación de reportes sobre actividad de datos, cumplimiento de flujos de aprobación y gestión documental, útiles como métricas indirectas.', 'Las métricas son operativas; para analítica avanzada puede complementarse con herramientas BI.', 'Posible con Power BI, Tableau'),

('APO14-P01-A06', 'APO14-P01', 'Supervisar el plan secuencial para la implementación de la estrategia de gestión de datos. Actualizarlo según sea necesario, en función de las revisiones de progreso.', 4, 'Alfresco', 'Permite planificar y supervisar la ejecución de tareas mediante flujos de trabajo versionados y auditables, facilitando el seguimiento de planes estratégicos.', 'Ofrece trazabilidad sobre el avance e hitos del plan estratégico de datos.', 'No requiere integración'),

('APO14-P01-A07', 'APO14-P01', 'Utilizar técnicas estadísticas y cuantitativas para evaluar la eficacia de los objetivos estratégicos de gestión de datos para alcanzar los objetivos de negocio. Realizar las modificaciones necesarias, según las métricas.', 4, 'Anaconda', 'Suite analítica avanzada que incluye librerías como Pandas, NumPy y SciPy, apta para aplicar modelos estadísticos y cuantitativos sobre métricas de gestión de datos.', 'Necesita conexión con bases de datos u origen de métricas.', 'Compatible con MySQL, Hive, Alfresco'),

('APO14-P01-A08', 'APO14-P01', 'Asegúrese de que la organización investigue los procesos comerciales innovadores y los requisitos regulatorios emergentes para garantizar que el programa de gestión de datos sea compatible con las necesidades comerciales futuras.', 5, 'Alfresco', 'Permite almacenar, categorizar y actualizar regulaciones, informes sectoriales y estrategias. Facilita acceso compartido entre áreas técnicas y legales.', 'Ideal para investigación documental colaborativa sobre regulaciones emergentes.', 'No requiere integración'),

('APO14-P01-A09', 'APO14-P01', 'Hacer contribuciones a las mejores prácticas de la industria para el desarrollo e implementación de estrategias de gestión de datos.', 5, 'Alfresco', 'Soporta la creación, versionado y publicación de guías, políticas y procedimientos sobre mejores prácticas. Puede usarse como repositorio interno de conocimiento.', 'Permite compartir y actualizar mejores prácticas alineadas con la industria.', 'No requiere integración'),

('APO14-P02-A01', 'APO14-P02', 'Asegúrese de que los términos comerciales estándar estén fácilmente disponibles y se comuniquen a las partes interesadas relevantes.', 2, 'Alfresco', 'Permite publicar documentos estructurados y catálogos accesibles por grupos definidos de usuarios. Facilita comunicación estandarizada a múltiples actores.', 'Se puede controlar la visibilidad por roles.', 'No requiere integración'),

('APO14-P02-A02', 'APO14-P02', 'Asegúrese de que cada término comercial agregado al glosario comercial tenga un nombre único y una definición única.', 2, 'Alfresco', 'El control de versiones, validaciones de formularios y flujo de aprobación aseguran unicidad y trazabilidad de términos dentro del repositorio.', 'Requiere política clara para mantener consistencia.', 'No requiere integración'),

('APO14-P02-A03', 'APO14-P02', 'Utilice términos y definiciones comerciales estándar de la industria, según corresponda, en el glosario comercial.', 2, 'Alfresco', 'Puede incorporar definiciones estandarizadas desde fuentes externas mediante carga de documentos y metadatos adjuntos.', 'Es compatible con estándares sectoriales que se carguen manualmente.', 'Compatible con Apache Hive / MySQL'),

('APO14-P02-A04', 'APO14-P02', 'Establecer, documentar y seguir un proceso para definir, gestionar, utilizar y mantener el glosario empresarial. Por ejemplo, las nuevas iniciativas deben aplicar términos empresariales estándar como parte del proceso de definición de requisitos de datos para garantizar la coherencia del lenguaje. Esto contribuirá a la comparabilidad del contenido y facilitará el intercambio de datos en toda la organización.', 3, 'Alfresco', 'Soporta flujos de trabajo formalizados para establecer y mantener procesos, incluyendo ciclos de revisión y aprobación.', 'Puede auditar cambios y mantener trazabilidad.', 'No requiere integración'),

('APO14-P02-A05', 'APO14-P02', 'Asegúrese de que los nuevos esfuerzos de desarrollo, integración de datos y consolidación de datos apliquen términos comerciales estándar como parte del proceso de definición de requisitos de datos.', 3, 'Alfresco', 'Facilita la centralización del glosario y su consulta desde distintas áreas, ayudando a estandarizar los términos desde fases tempranas del diseño de soluciones.', 'Puede usarse como referencia única para proyectos nuevos.', 'Integración posible vía API o API REST'),

('APO14-P02-A06', 'APO14-P02', 'Integrar el glosario empresarial en el repositorio de metadatos de la organización, con los permisos de acceso adecuados.', 3, 'Apache Hive', 'Hive permite manejar un repositorio de metadatos estructurados que puede incluir el glosario empresarial como base de consulta técnica para los datos.', 'Requiere sincronización o importación desde herramientas como Alfresco u hojas de datos.', 'Integración con Alfresco o MySQL'),

('APO14-P03-A01', 'APO14-P03', 'Establecer y seguir un proceso de gestión de metadatos.', 2, 'Apache Hive', 'Hive actúa como un metastore distribuido que permite crear y mantener estructuras de metadatos centralizadas sobre grandes volúmenes de datos.', 'Facilita gestión y trazabilidad de metadatos sobre entornos Hadoop y big data.', 'Compatible con MySQL como base de metastore y con herramientas BI.'),

('APO14-P03-A02', 'APO14-P03', 'Asegúrese de que la documentación de metadatos capture las interdependencias de los datos.', 2, 'Apache Hive', 'Permite definir relaciones entre tablas, vistas, esquemas y columnas, lo que facilita identificar interdependencias y trazabilidad.', 'Las dependencias pueden ser inferidas desde las definiciones SQL y relaciones de datos.', 'Puede integrarse con soluciones como Superset o Metacat para visualización.'),

('APO14-P03-A03', 'APO14-P03', 'Establecer y seguir categorías, propiedades y estándares de metadatos.', 2, 'Apache Hive', 'Hive permite extender metadatos mediante propiedades y estructuras adicionales. Apoya estándares como Avro, ORC y Parquet.', 'Requiere políticas organizacionales para su formalización.', 'Integración con Avro, Atlas (para gobernanza), y MySQL como backend.'),

('APO14-P03-A04', 'APO14-P03', 'Desarrollar y utilizar metadatos para realizar análisis de impacto sobre posibles cambios en los datos.', 3, 'Apache Hive', 'Los metadatos de Hive permiten evaluar impacto mediante dependencias de columnas y tablas (lineage analysis), útil para modelado de cambios.', 'Requiere herramientas externas para visualización del análisis de impacto.', 'Se recomienda integrar con Apache Atlas.'),

('APO14-P03-A05', 'APO14-P03', 'Complete el repositorio de metadatos de la organización con categorías y clasificaciones adicionales de metadatos según un plan de implementación por fases. Vincúlelo con las capas de arquitectura.', 3, 'Apache Hive', 'Hive soporta clasificación de metadatos por esquema, base de datos, tabla y columna, y permite expansión incremental.', 'Puede integrarse con capas de arquitectura mediante APIs o controladores ODBC/JDBC.', 'Integración recomendada con Apache Atlas y Archi para vistas de arquitectura.'),

('APO14-P03-A06', 'APO14-P03', 'Validar los metadatos y cualquier cambio en los metadatos frente a la arquitectura existente.', 3, 'Apache Hive', 'Hive permite rastrear metadatos mediante estructuras relacionales; validación frente a arquitectura se logra cruzando con herramientas externas.', 'Para validación contra arquitectura, se sugiere integración con Apache Atlas o Archi.', 'Puede integrarse con Archi (modelado de arquitectura) vía exportaciones o APIs.'),

('APO14-P03-A07', 'APO14-P03', 'Asegúrese de que la organización haya desarrollado un metamodelo integrado implementado en todas las plataformas.', 3, 'Apache Hive', 'Hive permite estructurar un metamodelo de metadatos coherente, reutilizable y extensible en ecosistemas Hadoop o SQL.', 'Puede actuar como base para metamodelos integrados cuando se sincroniza con otras plataformas.', 'Integración recomendada con Apache Atlas para alineación semántica.'),

('APO14-P03-A08', 'APO14-P03', 'Asegúrese de que los tipos de metadatos y las definiciones de datos admitan prácticas consistentes de importación, suscripción y consumo.', 3, 'Apache Hive', 'Hive soporta múltiples formatos de datos y metadatos (Avro, Parquet, ORC) y es compatible con mecanismos de lectura/suscripción estándar como JDBC/ODBC.', 'La interoperabilidad con herramientas ETL, BI y almacenamiento permite modelos consistentes.', 'Compatible con Spark, Presto, Tableau, Talend, Apache Nifi, entre otros.'),

('APO14-P03-A09', 'APO14-P03', 'Utilizar medidas y métricas para evaluar la precisión y la adopción de metadatos.', 4, 'Apache Hive', 'Aunque Hive no tiene métricas nativas, se pueden desarrollar métricas personalizadas sobre el uso del metastore (consultas, cambios, acceso).', 'Requiere herramientas complementarias para generar dashboards o informes.', 'Se recomienda usar con Apache Superset o Prometheus para monitoreo.'),

('APO14-P03-A10', 'APO14-P03', 'Evaluar el impacto de los cambios planificados en los datos en el repositorio de metadatos. Mejorar continuamente los procesos de captura, modificación y refinamiento de metadatos.', 5, 'Apache Hive', 'Hive soporta cambios estructurales y captura de metadatos dinámicos, permitiendo evaluar impacto con herramientas como lineage analysis.', 'Análisis de impacto puede automatizarse integrando Atlas o herramientas de gobernanza.', 'Integración ideal con Apache Atlas o DataHub.'),

('APO14-P04-A01', 'APO14-P04', 'Definir una estrategia de calidad de datos en colaboración con las partes interesadas del negocio y la tecnología, aprobada por la dirección ejecutiva y gestionada. La estrategia debe facilitar la transición del estado actual al objetivo. Además, debe estar alineada explícitamente con los objetivos del negocio y la estrategia de gestión de datos de la organización.', 3, 'Alfresco', 'Alfresco permite modelar, documentar y versionar estrategias, políticas y procesos empresariales. Su soporte para colaboración permite el trabajo conjunto entre áreas.', 'Se requiere modelar la estrategia como parte de un repositorio documental estructurado.', 'Puede integrarse con Archi para alinear con arquitectura empresarial.'),

('APO14-P04-A02', 'APO14-P04', 'Asegúrese de que la estrategia de calidad de datos se siga en toda la organización y esté acompañada de políticas, procesos y directrices correspondientes.', 3, 'Alfresco', 'Soporta publicación, control de versiones y acceso controlado a políticas organizacionales, asegurando la diseminación efectiva.', 'Soporta flujos de aprobación y cumplimiento normativo.', 'Compatible con LDAP/AD para control de accesos y auditoría.'),

('APO14-P04-A03', 'APO14-P04', 'Integrar las políticas, los procesos y la gobernanza de la estrategia de calidad de datos a lo largo de todo el ciclo de vida de los datos. Imponer los procesos correspondientes en la metodología del ciclo de vida del desarrollo del sistema.', 3, 'Alfresco', 'Puede modelar reglas, procesos y documentación asociada a cada etapa del ciclo de vida de los datos.', 'Puede integrarse con flujos BPMN para seguimiento.', 'Integra con herramientas de BPM o DMS externas.'),

('APO14-P04-A04', 'APO14-P04', 'Desarrollar, supervisar y mantener un plan secuencial para los esfuerzos de mejora de la calidad de los datos en toda la organización.', 3, 'Alfresco', 'Alfresco permite la definición de planes y tareas mediante workflows, así como la trazabilidad del avance.', 'Admite asignación de responsables, notificaciones y seguimiento.', 'Puede integrarse con JIRA o sistemas BPM para planes complejos.'),

('APO14-P04-A05', 'APO14-P04', 'Evaluar el progreso, monitorear los planes para cumplir las metas y objetivos de la estrategia de calidad de datos.', 4, 'Alfresco', 'Permite anexar métricas, tableros o documentos de seguimiento en cada hito del plan de calidad.', 'Para tableros visuales se recomienda integración adicional.', 'Puede integrarse con herramientas BI como Superset o Metabase.'),

('APO14-P04-A06', 'APO14-P04', 'Recopilar sistemáticamente los informes de las partes interesadas sobre los problemas de calidad de los datos. Incluir sus expectativas de mejora en la estrategia de calidad de los datos. Medirlas y monitorizarlas.', 4, 'Alfresco', 'Soporta formularios personalizados, buzones de retroalimentación y flujos de revisión.', 'Permite capturar mejoras y reenviarlas a responsables.', 'Compatible con Form.io o plugins de formularios personalizados.'),

('APO14-P05-A01', 'APO14-P05', 'Definir y estandarizar las metodologías, procesos, prácticas, herramientas y plantillas de resultados para el perfilado de datos. Garantizar que los procesos de perfilado sean reutilizables y se puedan aprovechar en múltiples almacenes de datos y repositorios de datos compartidos.', 3, 'Anaconda', 'Anaconda proporciona un entorno robusto para definir y ejecutar procesos estandarizados de perfilado de datos mediante Python, Pandas, Dask, y librerías como pandas-profiling o ydata-profiling.', 'No ofrece GUI empresarial por defecto, pero permite total personalización.', 'Puede integrarse con Apache Hive, MySQL u otros orígenes mediante conectores.'),

('APO14-P05-A02', 'APO14-P05', 'Involucrar a la gestión de datos para identificar conjuntos de datos compartidos centrales que se perfilan y monitorean periódicamente.', 4, 'Anaconda', 'Permite programar scripts o notebooks para revisar esquemas de bases de datos y explorar sus tablas clave mediante conexiones JDBC o SQLAlchemy.', 'Permite incorporar criterios de negocio en el script y documentación en notebook.', 'Integrable con Archi para vincular con arquitectura de datos.'),

('APO14-P05-A03', 'APO14-P05', 'En los esfuerzos de elaboración de perfiles de datos, incluir la evaluación de la conformidad del contenido de los datos con sus metadatos y estándares aprobados.', 4, 'Anaconda', 'A través de validadores como Great Expectations, se puede verificar si los datos cumplen sus definiciones de tipo, formato y reglas de calidad definidas.', 'Puede conectarse con repositorios de metadatos definidos en Hive o Alfresco.', 'Alta compatibilidad con sistemas de metadatos externos.'),

('APO14-P05-A04', 'APO14-P05', 'Durante una actividad de elaboración de perfiles de datos, compare los problemas reales con los problemas previstos estadísticamente, basándose en los resultados históricos de elaboración de perfiles.', 4, 'Anaconda', 'Permite modelar perfiles históricos y generar comparaciones estadísticas utilizando bibliotecas como SciPy, statsmodels, etc.', 'Requiere almacenamiento previo de perfiles, pero se puede automatizar.', 'Puede usar bases como MySQL o Apache Hive para almacenar perfiles anteriores.'),

('APO14-P05-A05', 'APO14-P05', 'Garantizar que los resultados se almacenen centralmente, se supervisen sistemáticamente y se analicen con respecto a estadísticas y métricas. Proporcionar la información resultante para mejorar la calidad de los datos a lo largo del tiempo.', 4, 'Anaconda', 'Los resultados de análisis pueden almacenarse automáticamente y someterse a análisis agregados con dashboards simples usando Plotly, Dash, Streamlit.', 'Se recomienda integración con herramientas BI para análisis avanzados.', 'Integrable con Metabase, Superset o Hive para dashboards.'),

('APO14-P05-A06', 'APO14-P05', 'Cree informes de perfiles automatizados en tiempo real o casi en tiempo real para todas las fuentes y repositorios de datos críticos.', 5, 'Anaconda', 'Con el uso de librerías como Streamlit, Dash, o notebooks parametrizados, es posible automatizar la generación continua de perfiles desde múltiples orígenes.', 'Requiere configuración técnica inicial, pero es altamente adaptable.', 'Se puede integrar con orígenes SQL, Hive, REST APIs, etc.'),

('APO14-P06-A01', 'APO14-P06', 'Realizar evaluaciones periódicas de la calidad de los datos, según la frecuencia aprobada por la política de evaluación de la calidad de los datos. Asegurar que la gobernanza de datos determine el conjunto clave de atributos por área temática para las evaluaciones de la calidad de los datos.', 4, 'Anaconda', 'Permite ejecutar análisis periódicos mediante scripts de validación, evaluando atributos definidos (por ejemplo: completitud, unicidad, precisión) con librerías como pandas-profiling, ydata-profiling, Great Expectations.', 'Altamente configurable; requiere configuración inicial técnica.', 'Integrable con Apache Hive, MySQL, etc. para extraer datos de áreas temáticas.'),

('APO14-P06-A02', 'APO14-P06', 'Incluir recomendaciones de remediación, con justificación de apoyo, en los resultados de la evaluación de la calidad de los datos.', 4, 'Anaconda', 'Los scripts pueden generar recomendaciones automatizadas basadas en reglas (ej.: reemplazar nulos, corregir formatos, eliminar duplicados) y documentarlas junto al análisis.', 'Permite personalizar criterios de remediación.', 'Compatible con sistemas de gestión documental como Alfresco.'),

('APO14-P06-A03', 'APO14-P06', 'Evaluar la calidad de los datos, utilizando umbrales y objetivos establecidos para cada dimensión de calidad seleccionada.', 4, 'Anaconda', 'Herramientas como Great Expectations permiten definir umbrales (porcentaje mínimo aceptable, rangos, etc.) y compararlos automáticamente con los datos reales.', 'Automatizable y auditable.', 'Puede enviar resultados a dashboards externos (Superset, PowerBI, etc.).'),

('APO14-P06-A04', 'APO14-P06', 'Generar sistemáticamente informes de medición de la calidad de los datos, basados en la criticidad de los atributos y la volatilidad de los datos.', 4, 'Anaconda', 'Se puede automatizar la priorización de atributos según criticidad y volatilidad, y generar reportes en HTML, PDF o dashboards web usando Streamlit, Dash, nbconvert.', 'Requiere definición previa de criticidad/volatilidad por atributo.', 'Integración con Apache Hive o MySQL para datos; Archi para relacionar con procesos.'),

('APO14-P06-A05', 'APO14-P06', 'Revisar y mejorar continuamente los procesos de evaluación y presentación de informes de la calidad de los datos.', 5, 'Anaconda', 'Al ser un entorno abierto y reproducible, permite iterar y versionar los métodos de evaluación, aplicando métricas de efectividad y ajustes en las pruebas.', 'Soporta notebooks con control de versiones (ej. con Git).', 'Puede integrarse con sistemas de documentación (Alfresco, GitLab).'),

('APO14-P07-A01', 'APO14-P07', 'Establecer y mantener una política de limpieza de datos.', 2, 'Alfresco', 'Permite gestionar, almacenar y versionar documentos formales como políticas de calidad y limpieza de datos. Controla flujos de aprobación y acceso.', 'Ideal para asegurar trazabilidad y acceso controlado a la política.', 'Integrable con sistemas de metadatos o repositorios técnicos (Apache Hive, Archi).'),

('APO14-P07-A02', 'APO14-P07', 'Mantener el historial de cambios de datos mediante actividades de limpieza.', 3, 'MySQL', 'Soporta activación de logs de cambios mediante triggers o auditoría nativa. Puede registrar los cambios en tablas auxiliares que documenten la limpieza.', 'Requiere diseño técnico, pero brinda trazabilidad detallada.', 'Compatible con Apache Hive y Anaconda para procesamiento adicional.'),

('APO14-P07-A03', 'APO14-P07', 'Establecer métodos para corregir los datos y definirlos en un plan. Los métodos pueden incluir la comparación de múltiples repositorios, la verificación con una fuente válida, las comprobaciones lógicas, la integridad referencial o la tolerancia de rango.', 4, 'Anaconda', 'Permite crear scripts automatizados de limpieza con reglas personalizadas (verificación cruzada, lógica condicional, integridad referencial). Usa librerías como pandas, pyjanitor, great_expectations.', 'Se pueden generar reportes del proceso de limpieza y plan de ejecución.', 'Extrae datos de MySQL o Hive y puede reportar en dashboards.'),

('APO14-P07-A04', 'APO14-P07', 'En los acuerdos de nivel de servicio, incluir criterios de calidad de datos para responsabilizar a los proveedores de datos por los datos limpios.', 4, 'Alfresco', 'Puede gestionar contratos, acuerdos y sus anexos (incluyendo los SLA con criterios de calidad definidos). También mantiene versiones firmadas y flujos de aprobación.', 'Aporta trazabilidad legal y administrativa.', 'Integrable con GLPI para seguimiento de cumplimiento o alertas.'),

('APO14-P08-A01', 'APO14-P08', 'Mapear y alinear los requisitos de los consumidores y productores de datos.', 2, 'Archi', 'Permite modelar arquitecturas empresariales, incluidos productores/consumidores de datos, flujos y componentes. Utiliza el estándar ArchiMate.', 'Proporciona trazabilidad visual y lógica entre productores y consumidores.', 'Se puede complementar con Apache Hive para seguimiento de fuentes técnicas.'),

('APO14-P08-A02', 'APO14-P08', 'Defina las asignaciones de procesos de negocio a datos. Manténgalas y revíselas periódicamente para garantizar su cumplimiento.', 3, 'Archi', 'Facilita el modelado de asignaciones entre procesos y datos (por ejemplo, qué datos soportan qué procesos) y permite revisiones periódicas.', 'Útil para mantener alineación entre gobernanza de procesos y datos.', 'Compatible con otros modelos BPMN o de arquitectura.'),

('APO14-P08-A03', 'APO14-P08', 'Seguir un proceso definido para acuerdos de colaboración con respecto a los datos compartidos y el uso de datos dentro de los procesos de negocio.', 3, 'Alfresco', 'Soporta gestión documental de acuerdos, firmas, flujos de aprobación y revisiones. Ideal para almacenar y mantener acuerdos de uso de datos.', 'Asegura trazabilidad formal y control de acceso.', 'Integrable con GLPI o plataformas BPM para seguimiento.'),

('APO14-P08-A04', 'APO14-P08', 'Implementar flujos de datos y mapas completos del ciclo de vida de los datos a los procesos para los datos compartidos para cada proceso de negocio principal a nivel organizacional.', 3, 'Archi', 'Ofrece modelado visual del ciclo de vida de datos y cómo estos se relacionan con procesos, sistemas y actores.', 'Alta capacidad de documentación gráfica y lógica.', 'Complemento útil para modelos de metadatos (Apache Hive).'),

('APO14-P08-A05', 'APO14-P08', 'Asegúrese de que los cambios en los conjuntos de datos compartidos o conjuntos de datos objetivo para un propósito comercial específico sean gestionados por estructuras de gobernanza de datos, con la participación de las partes interesadas pertinentes.', 3, 'Alfresco', 'Permite versionamiento de documentación, flujo de trabajo de aprobación, y visibilidad para múltiples partes interesadas.', 'Asegura trazabilidad y cumplimiento de gobernanza.', 'Integrable con herramientas de modelado o sistemas de gestión de calidad.'),

('APO14-P08-A06', 'APO14-P08', 'Utilice métricas para ampliar la reutilización de datos compartidos aprobados y eliminar la redundancia de procesos.', 4, 'Apache Hive', 'Capacidad de consulta y análisis de grandes volúmenes de datos. Permite identificar patrones de reutilización y redundancia a través de SQL distribuido.', 'Necesita integración con procesos ETL o almacenamiento de datos estructurados.', 'Puede integrarse con Anaconda para visualización o reporting de métricas.'),

('APO14-P09-A01', 'APO14-P09', 'Garantizar que las políticas exijan la gestión del historial de datos, incluidos los requisitos de retención, destrucción y registro de auditoría.', 2, 'Alfresco', 'ermite definir políticas de retención documental, ciclos de vida de archivo y destrucción segura, con trazabilidad y cumplimiento normativo.', 'Soporte completo para políticas de archivado conforme a marcos regulatorios como GDPR o ISO.', 'Puede integrarse con GLPI o motores BPM para ejecución de flujos de aprobación.'),

('APO14-P09-A02', 'APO14-P09', 'Garantizar la existencia de un método definido que garantice la accesibilidad a los datos históricos necesarios para apoyar las necesidades del negocio.', 2, 'Apache Hive', 'Permite almacenar y consultar grandes volúmenes de datos históricos estructurados mediante SQL distribuido, ideal para análisis retrospectivo.', 'Requiere entorno Hadoop/HDFS, pero es altamente escalable para necesidades de negocio complejas.', 'Puede integrarse con Anaconda para análisis y dashboards.'),

('APO14-P09-A03', 'APO14-P09', 'Utilizar políticas y procesos para controlar el acceso, la transmisión y las modificaciones de los datos históricos y archivados.', 2, 'Alfresco', 'Soporta control granular de acceso (ACLs), versionamiento, y monitoreo de modificaciones, con trazabilidad completa.', 'Asegura cumplimiento normativo y control de modificaciones sobre los datos archivados.', 'Complementa a Hive como almacenamiento de metadatos y documentación.'),

('APO14-P09-A04', 'APO14-P09', 'Asegúrese de que la organización tenga un repositorio de almacenamiento de datos prescrito que proporcione acceso a datos históricos para satisfacer las necesidades de análisis que respaldan los procesos comerciales.', 3, 'Apache Hive', 'Hive funciona como repositorio centralizado estructurado, ideal para mantener datos históricos consultables y procesables para BI y análisis de negocio.', 'Su robustez lo hace ideal para procesos analíticos complejos en grandes organizaciones.', 'Integración natural con Anaconda, Apache Spark y herramientas de visualización.'),

('APO14-P10-A01', 'APO14-P10', 'Definir un cronograma para asegurar el correcto respaldo de todos los datos críticos, teniendo en cuenta la frecuencia, el tipo de respaldo, la seguridad, la privacidad y otros criterios.', 2, 'Issabel', 'Issabel permite programar respaldos automáticos del sistema, correos, bases de datos y configuración de PBX con opciones de cifrado y periodicidad.', 'Adecuado para entornos TI que requieran respaldo sistemático con control de frecuencia y seguridad.', 'Puede conectarse con almacenamiento externo y otras plataformas de respaldo (NFS, FTP).'),

('APO14-P10-A02', 'APO14-P10', 'Definir los requisitos para el almacenamiento local y externo de los datos de respaldo, teniendo en cuenta el volumen, la capacidad y el período de retención, en consonancia con los requisitos del negocio.', 2, 'Alfresco', 'Alfresco permite definir políticas de almacenamiento, archivado y retención, gestionando múltiples repositorios y almacenamientos (on-premise o cloud).', 'Permite separación de contenidos por criticidad y aplicación de reglas de retención.', 'Integración con sistemas de almacenamiento cloud y bases de datos para respaldo de documentos críticos.'),

('APO14-P10-A03', 'APO14-P10', 'Establezca un cronograma de pruebas para los datos de respaldo. Asegúrese de que los datos se puedan restaurar correctamente sin afectar drásticamente el negocio.', 2, 'Issabel', 'Issabel permite restaurar configuraciones completas en entornos controlados. Las pruebas de restauración pueden realizarse manual o automáticamente sin afectar el entorno productivo.', 'Útil en validación de planes de contingencia y pruebas de recuperación.', 'Complementable con GLPI para registrar cronogramas y evidencias de las pruebas.'),

('MEA01-P01-A01', 'MEA01-P01', 'Identificar a las partes interesadas (por ejemplo, dirección, propietarios de procesos y usuarios).', 2, 'Eramba', 'Soporta gestión estructurada de partes interesadas con roles definidos.', 'Muy sólido para entornos de cumplimiento. Permite clasificación y trazabilidad de interesados.', '-'),

('MEA01-P01-A02', 'MEA01-P01', 'Interactuar con las partes interesadas y comunicar los requisitos y objetivos de la empresa en materia de seguimiento, agregación e informes, utilizando definiciones comunes (por ejemplo, glosario empresarial, metadatos y taxonomía), líneas de base y evaluación comparativa.', 2, 'Eramba', 'Soporta definición de requisitos, plantillas y glosarios empresariales.', 'Ideal para entornos GRC. Alineado con estándares como COBIT 2019', '-'),

('MEA01-P01-A03', 'MEA01-P01', 'Alinear y mantener continuamente el enfoque de monitoreo y evaluación con el enfoque empresarial y las herramientas que se utilizarán para la recopilación de datos y la generación de informes empresariales (por ejemplo, aplicaciones de inteligencia empresarial).', 2, 'Eramba', 'Permite crear marcos de monitoreo alineados con objetivos estratégicos.', 'Alta integración con objetivos de cumplimiento y control. Automatización incluida.', '-'),

('MEA01-P01-A04', 'MEA01-P01', 'Acordar los tipos de objetivos y métricas (por ejemplo, conformidad, rendimiento, valor, riesgo), taxonomía (clasificación y relaciones entre objetivos y métricas) y retención de datos (evidencia).', 2, 'Eramba', 'Permite definir objetivos, tipos de métricas, evidencias y su retención.', 'Permite organizar métricas por tipo, frecuencia, prioridad y criticidad.', '-'),

('MEA01-P01-A05', 'MEA01-P01', 'Solicitar, priorizar y asignar recursos para el seguimiento, considerando pertinencia, eficiencia, eficacia y confidencialidad.', 2, 'Eramba', 'Asignación de responsables con criterios de pertinencia y control.', 'Roles y responsabilidades claramente distribuidos por módulo. Soporta priorización.', '-'),

('MEA01-P01-A06', 'MEA01-P01', 'Validar periódicamente el enfoque utilizado e identificar partes interesadas, requisitos y recursos nuevos o modificados.', 3, 'Eramba', 'Tiene flujo de revisión y actualización del enfoque de monitoreo.', 'Automatización de revisiones con trazabilidad clara. Enfoque estructurado para mejora continua.', '-'),

('MEA01-P01-A07', 'MEA01-P01', 'Acordar un proceso de gestión del ciclo de vida y control de cambios para la supervisión y la generación de informes. Incluir oportunidades de mejora para la generación de informes, métricas, enfoque, línea base y evaluación comparativa.', 3, 'Eramba', 'Soporta ciclo completo: mejora, control de cambios y gestión de reportes.', 'Puede exportar informes para auditoría.', '-'),

('MEA01-P02-A01', 'MEA01-P02', 'Defina los objetivos y las métricas. Revíselos periódicamente con las partes interesadas para identificar cualquier elemento faltante significativo y definir la razonabilidad de los objetivos y las tolerancias.', 2, 'Eramba', 'Permite definir métricas alineadas a políticas, establecer tolerancias y validarlas con stakeholders definidos.', 'Estructura clara de roles, objetivos, métricas y responsables. Ideal para revisiones periódicas.', '-'),

('MEA01-P02-A02', 'MEA01-P02', 'Evaluar si los objetivos y las métricas son adecuados, es decir, específicos, medibles, alcanzables, relevantes y limitados en el tiempo (SMART).', 2, 'Eramba', 'Permite definir propiedades como periodicidad, metas, umbrales y responsables, lo que habilita evaluación bajo el criterio SMART.', 'Ofrece estructura para definir cada aspecto de la métrica. Puede generar informes detallados.', '-'),

('MEA01-P02-A03', 'MEA01-P02', 'Comunicar los cambios propuestos a los objetivos de desempeño y conformidad y las tolerancias (relacionadas con las métricas) con las principales partes interesadas en la debida diligencia (por ejemplo, legal, auditoría, RR.HH., ética, cumplimiento, finanzas).', 2, 'Eramba', 'Los cambios en métricas u objetivos generan alertas, solicitudes de revisión y notificaciones a los interesados designados.', 'Automatiza flujos de revisión y validación. Trazabilidad asegurada.', '-'),

('MEA01-P02-A04', 'MEA01-P02', 'Publicar los objetivos y tolerancias modificados para los usuarios de esta información.', 2, 'Eramba', 'Publica cambios validados, asociándolos a políticas, riesgos o planes. Control de versiones y auditoría.', 'Ideal para entornos que requieren evidencia formal de comunicación y versión de objetivos.', '-'),

('MEA01-P03-A01', 'MEA01-P03', 'Recopilar datos de procesos definidos (automatizados, cuando sea posible).', 2, 'Eramba', 'Eramba permite la automatización parcial del registro de cumplimiento, revisiones, controles y hallazgos.', '-', '-'),

('MEA01-P03-A02', 'MEA01-P03', 'Evaluar la eficiencia (esfuerzo en relación con la información proporcionada) y la idoneidad (utilidad y significado) de los datos recopilados y validar la integridad de los datos (precisión e integridad).', 2, 'Eramba', 'Las revisiones permiten validar si los datos son pertinentes, completos y útiles para el análisis.', 'Estructura integrada de verificación y control. Registra trazabilidad completa.', '-'),

('MEA01-P03-A03', 'MEA01-P03', 'Datos agregados para respaldar la medición de las métricas acordadas.', 2, 'Eramba', 'Permite consolidar datos por control, riesgo o política, y vincularlos con métricas específicas.', 'Adecuado para construcción de indicadores de cumplimiento y rendimiento.', '-'),

('MEA01-P03-A04', 'MEA01-P03', 'Alinear los datos agregados con el enfoque y los objetivos de informes empresariales.', 3, 'Eramba', 'Relaciona cada métrica con una política, objetivo estratégico o componente de riesgo.', 'Permite alineación directa con estructuras organizacionales y de negocio.', '-'),

('MEA01-P03-A05', 'MEA01-P03', 'Utilizar herramientas y sistemas adecuados para el procesamiento y análisis de datos.', 4, 'Eramba', 'Proporciona herramientas de análisis interno y exportación para herramientas como Power BI.', 'Soporta visualización y análisis cruzado. Admite personalización de informes.', '-'),

('MEA01-P04-A01', 'MEA01-P04', 'Diseñar informes de rendimiento de procesos concisos, fáciles de entender y adaptados a las diversas necesidades de gestión y audiencias. Facilitar la toma de decisiones eficaz y oportuna (p. ej., cuadros de mando, informes de semáforo). Asegurar que la relación causa-efecto entre los objetivos y las métricas se comunique de forma comprensible.', 3, 'Eramba', 'Ofrece paneles configurables por control, riesgo, políticas, con soporte para semáforos, umbrales y visualizaciones claras.', 'Excelente capacidad de personalización. Apto para audiencias de negocio y técnica.', '-'),

('MEA01-P04-A02', 'MEA01-P04', 'Distribuir informes a las partes interesadas pertinentes.', 3, 'Eramba', 'Permite configurar destinatarios por tipo de reporte, revisión, métrica o política.', 'Alta trazabilidad y control de envíos. Se puede automatizar por evento o ciclo.', '-'),

('MEA01-P04-A03', 'MEA01-P04', 'Analizar la causa de las desviaciones respecto a los objetivos, implementar medidas correctivas, asignar responsabilidades para la corrección y dar seguimiento. Revisar todas las desviaciones en el momento oportuno y buscar las causas raíz, cuando sea necesario. Documentar los problemas para obtener más orientación si el problema persiste. Documentar los resultados.', 4, 'Eramba', 'Eramba tiene flujo completo: identifica desviación, asigna responsables, permite seguimiento y documentación.', 'Soporta análisis de causa raíz y permite incorporar resultados como evidencia.', '-'),

('MEA01-P04-A04', 'MEA01-P04', 'Cuando sea posible, integrar el desempeño y el cumplimiento en los objetivos de desempeño de cada miembro del personal y vincular el logro de los objetivos de desempeño con el sistema de compensación de recompensas de la organización.', 4, 'JFire', 'JFire permite crear perfiles de usuario, roles y reglas, y asociarlos con procesos de negocio. Puede integrarse con módulos de RR.HH. o KPIs, permitiendo vincular logros a recompensas si se personaliza.', 'Requiere configuración avanzada o integración externa, pero es factible en entornos administrativos o comerciales.', '-'),

('MEA01-P04-A05', 'MEA01-P04', 'Comparar los valores de desempeño con los objetivos y puntos de referencia internos y, cuando sea posible, con puntos de referencia externos (industria y competidores clave).', 4, 'Anaconda', 'Permite comparar datos con valores de referencia internos o externos, usando análisis estadístico y visualizaciones.', 'Entorno para análisis de datos, incluye Python, Jupyter, Pandas, entre otras. No tiene interfaz de gestión empresarial prediseñada.', 'Requiere libreria para analisis de datos: Pandas, Matplotlib, Scikit, Plotly'),

('MEA01-P04-A06', 'MEA01-P04', 'Analizar las tendencias en rendimiento y cumplimiento y tomar las medidas apropiadas.', 4, 'Eramba', 'Presenta históricos, tendencias visuales y permite acciones correctivas.', 'Soporta análisis cruzado entre diferentes ciclos y métricas.', '-'),

('MEA01-P04-A07', 'MEA01-P04', 'Recomendar cambios en los objetivos y métricas, cuando sea apropiado.', 5, 'Eramba', 'Tiene un módulo de mejora continua que permite revisar, ajustar y validar nuevas métricas.', 'Soporta flujo de revisión colaborativa. Registro histórico de cada cambio.', '-'),

('MEA01-P05-A01', 'MEA01-P05', 'Revisar las respuestas, opciones y recomendaciones de la gerencia para abordar los problemas y las principales desviaciones.', 2, 'Eramba', 'Cada hallazgo o desviación tiene espacio para documentar decisiones gerenciales y recomendaciones específicas.', 'Flujo bien estructurado, con revisión, validación y trazabilidad.', '-'),

('MEA01-P05-A02', 'MEA01-P05', 'Asegurarse de que se mantenga la asignación de responsabilidad para las acciones correctivas.', 2, 'Eramba', 'Se pueden asignar responsables por hallazgo, por acción correctiva, y se notifica automáticamente.', '-', '-'),

('MEA01-P05-A03', 'MEA01-P05', 'Realizar seguimiento a los resultados de las acciones realizadas.', 2, 'Eramba', 'Ofrece seguimiento por fechas, progreso y estatus de cada acción. Relacionado a métricas y riesgos.', 'Ideal para auditoría, cumplimiento y mejoras correctivas.', '-'),

('MEA01-P05-A04', 'MEA01-P05', 'Informar los resultados a las partes interesadas.', 2, 'Eramba', 'Permite informes personalizables por hallazgo, control o estado. Se puede enviar a partes interesadas específicas.', 'Soporta distribución por correo o como parte de revisiones programadas.', '-'),

('MEA02-P01-A01', 'MEA02-P01', 'Identifique los límites del sistema de control interno. Por ejemplo, considere cómo los controles internos de la organización consideran las actividades de desarrollo o producción externalizadas o en el extranjero.', 3, 'GLPI', 'Permite documentar relaciones con terceros y servicios externalizados, pero sin mapeo formal de límites de control.', 'Puede representar contratos o servicios, pero no delimita controles', '-'),

('MEA02-P01-A02', 'MEA02-P01', 'Evaluar el estado de los controles internos de los proveedores de servicios externos. Confirmar que los proveedores de servicios cumplen con los requisitos legales y reglamentarios, así como con sus obligaciones contractuales.', 3, 'Anaconda', 'Puede analizar datos de cumplimiento de terceros si se dispone de ellos.', 'Necesita integración de fuentes y diseño manual.', 'Pandas'),

('MEA02-P01-A03', 'MEA02-P01', 'Realizar actividades de monitoreo y evaluación del control interno con base en las normas de gobernanza organizacional y los marcos y prácticas aceptados por la industria. También incluirá el monitoreo y la evaluación de la eficiencia y eficacia de las actividades de supervisión gerencial.', 3, 'GLPI', 'Se pueden registrar hallazgos o tareas, pero no hay alineación nativa con marcos de control reconocidos.', 'Necesita pluggins para completar la actividad. Puede servir como soporte documental, pero necesita una guía externa.', 'Formcreator, changes'),

('MEA02-P01-A04', 'MEA02-P01', 'Garantizar que las excepciones de control se informen, se les dé seguimiento y se analicen con prontitud, y que se prioricen e implementen las acciones correctivas apropiadas de acuerdo con el perfil de gestión de riesgos (por ejemplo, clasificar ciertas excepciones como un riesgo clave y otras como un riesgo no clave).', 3, 'GLPI', 'Puede registrar excepciones, asignar responsables y hacer seguimiento.', 'Útil para respuesta táctica. Requiere clasificación manual de riesgos.', 'Changes, Notifications'),

('MEA02-P01-A05', 'MEA02-P01', 'Considere evaluaciones independientes del sistema de control interno (por ejemplo, por auditoría interna o pares).', 3, NULL, 'La herramienta GLPI, debido a la naturaleza externa de esta actividad, no se espera que una herramienta ejecute directamente la evaluación independiente.', 'Herramientas como GLPI, si están adecuadamente configuradas, pueden facilitar la gestión, documentación y seguimiento de estas evaluaciones, permitiendo que los actores externos accedan a información relevante, registros históricos y resultados de desempeño para emitir sus juicios.', '-'),

('MEA02-P01-A06', 'MEA02-P01', 'Mantener el sistema de control interno, considerando los cambios continuos en los riesgos de negocio y de I&T, el entorno de control organizacional y los procesos de negocio y de I&T relevantes. Si existen deficiencias, evaluar y recomendar cambios.', 4, 'Anaconda', 'Se puede adaptar el modelo analítico según cambien los riesgos y controles.', 'Ideal para mejora continua si se dispone de analista', '-'),

('MEA02-P01-A07', 'MEA02-P01', 'Evaluar periódicamente el desempeño del marco de control, comparándolo con las normas y buenas prácticas aceptadas por la industria. Considerar la adopción formal de un enfoque de mejora continua para la supervisión del control interno.', 5, 'Anaconda', 'Puede construir indicadores alineados a marcos de control y compararlos en el tiempo.', 'Muy potente si se tiene acceso a KPIs y métricas históricas.', '-'),

('MEA02-P02-A01', 'MEA02-P02', 'Comprender y priorizar el riesgo para los objetivos organizacionales.', 3, 'Open Source Risk Engine', 'Permite modelar exposición al riesgo financiero y priorizar por impacto en objetivos estratégicos.', 'Altamente útil en organizaciones financieras. Limitado fuera de ese dominio.', '-'),

('MEA02-P02-A02', 'MEA02-P02', 'Identificar los controles clave y desarrollar una estrategia adecuada para validar los controles.', 3, NULL, 'La herramienta GLPI, se puede documentar qué acciones se consideran controles y hacer seguimiento a su ejecución, pero no se valida su efectividad automáticamente.', 'Útil si se define un flujo manual. No automatiza validación ni mide eficacia.', 'Formcreator, Changes'),

('MEA02-P02-A03', 'MEA02-P02', 'Identificar información que indique si el entorno de control interno está funcionando eficazmente.', 3, 'Open Source Risk Engine', 'Puede simular múltiples escenarios y su efecto en la estructura de riesgo, lo cual es evidencia de la efectividad de medidas.', 'Enfocado en modelos cuantitativos. No evalúa controles administrativos.', '-'),

('MEA02-P02-A04', 'MEA02-P02', 'Mantener evidencia de la efectividad del control.', 4, 'Open Source Risk Engine', 'Open Source Risk Engine (OSRE) permite registrar pruebas de control, evaluaciones de cumplimiento y adjuntar documentación que respalda la efectividad del control en procesos críticos.', 'Soporta trazabilidad histórica y vinculación con marcos como Basel II/III. La evidencia puede ser reutilizada para auditorías internas o externas.', '-'),

('MEA02-P02-A05', 'MEA02-P02', 'Desarrollar e implementar procedimientos rentables para obtener esta información de acuerdo con los criterios de calidad de la información aplicables.', 4, 'GLPI', 'GLPI permite modelar y documentar procedimientos internos, mientras que OSRE aporta criterios de calidad sobre el riesgo y control. Juntas facilitan la implementación y evaluación de procedimientos que recojan la información necesaria.', 'No hay una función específica para calcular rentabilidad automáticamente, pero pueden generarse reportes con tiempos, esfuerzo y trazabilidad. Puede complementarse con Anaconda para modelar procedimientos optimizados y simular su efectividad en términos de costo-beneficio.', 'Anaconda'),

('MEA02-P03-A01', 'MEA02-P03', 'Definir un enfoque acordado y consistente para realizar autoevaluaciones de control y coordinar con los auditores internos y externos.', 3, 'Open Source Risk Engine', 'OSRE permite definir metodologías de evaluación, criterios y plantillas consistentes con normas como ISO 31000 o COSO.', 'Tiene soporte para definir roles y responsabilidades de auditores internos y externos.', '-'),

('MEA02-P03-A02', 'MEA02-P03', 'Mantener los planes de evaluación, así como el alcance e identificar los criterios de evaluación para realizar las autoevaluaciones. Planificar la comunicación de los resultados del proceso de autoevaluación a la gerencia de negocio, TI, la gerencia general y el consejo de administración. Considerar las normas de auditoría interna en el diseño de las autoevaluaciones.', 3, 'GLPI', 'Documenta planes de trabajo, alcance, criterios y permite registrar entregables por cada evaluación.', 'Permite programar actividades y distribuir informes a múltiples áreas.', '-'),

('MEA02-P03-A03', 'MEA02-P03', 'Determinar la frecuencia de las autoevaluaciones periódicas, considerando la eficacia y eficiencia generales del monitoreo continuo.', 3, 'Open Source Risk Engine', 'Permite definir ciclos, frecuencias y alertas para cada tipo de evaluación, basadas en el nivel de riesgo.', 'Se puede configurar para realizar evaluaciones trimestrales, anuales o por nivel de riesgo.', '-'),

('MEA02-P03-A04', 'MEA02-P03', 'Asignar la responsabilidad de la autoevaluación a las personas adecuadas para garantizar la objetividad y la competencia.', 3, 'GLPI', 'Permite delegar tareas, definir roles responsables por evaluación y controlar la trazabilidad de las asignaciones.', 'El historial de quién evaluó qué es rastreable y auditable.', '-'),

('MEA02-P03-A05', 'MEA02-P03', 'Prever revisiones independientes para garantizar la objetividad de la autoevaluación y permitir el intercambio de buenas prácticas de control interno de otras empresas.', 3, 'Open Source Risk Engine', 'Registra controles cruzados, permite agregar observaciones de terceros e incluye campos para buenas prácticas.', 'Permite incluir evaluaciones independientes como parte del flujo.', '-'),

('MEA02-P03-A06', 'MEA02-P03', 'Compare los resultados de las autoevaluaciones con los estándares de la industria y las buenas prácticas.', 4, 'Open Source Risk Engine', 'Tiene soporte para modelos de control basados en estándares (ISO, Basel, etc.), y puede hacer comparaciones con puntos de control externos.', 'Permite cargar estándares personalizados para benchmarking.', '-'),

('MEA02-P03-A07', 'MEA02-P03', 'Resumir e informar los resultados de las autoevaluaciones y la evaluación comparativa para la adopción de medidas correctivas.', 5, 'GLPI', 'Permite elaborar informes, definir planes de acción y asociarlos a problemas o no conformidades.', 'Muy útil para cerrar el ciclo de mejora continua basado en las autoevaluaciones.', '-'),

('MEA02-P04-A01', 'MEA02-P04', 'Comunicar los procedimientos para la escalada de excepciones de control, análisis de causa raíz e informes a los propietarios de procesos y las partes interesadas de I&T.', 3, 'GLPI', 'Permite documentar y comunicar flujos de escalado, análisis RCA y asignaciones de tareas.', 'Soporta plantillas y comunicación dirigida a responsables.', '-'),

('MEA02-P04-A02', 'MEA02-P04', 'Considere el riesgo empresarial relacionado para establecer umbrales para la escalada de excepciones y fallas de control.', 3, 'Open Source Risk Engine', 'OSRE permite modelar umbrales de riesgo y configurar disparadores de control según impacto.', 'Relaciona automáticamente deficiencias con niveles de riesgo aceptable.', '-'),

('MEA02-P04-A03', 'MEA02-P04', 'Identificar, reportar y registrar las excepciones de control. Asignar la responsabilidad de resolverlas e informar sobre su estado.', 3, 'GLPI', 'Registra excepciones como tickets, asigna responsables y permite seguimiento de estado.', 'Aporta trazabilidad completa del ciclo de vida de cada excepción.', '-'),

('MEA02-P04-A04', 'MEA02-P04', 'Decida qué excepciones de control deben comunicarse al responsable de la función y cuáles deben escalarse. Informe a los responsables y partes interesadas del proceso afectado.', 3, 'GLPI', 'Soporta reglas de decisión mediante categorías, prioridad y flujo de aprobación para escalamientos.', 'Permite configurar reglas para escalar automáticamente ciertos tipos de excepciones.', '-'),

('MEA02-P04-A05', 'MEA02-P04', 'Realizar un seguimiento de todas las excepciones para garantizar que se hayan abordado las acciones acordadas.', 4, 'GLPI', 'Realiza seguimiento con estados, fechas límite, responsables y alertas de incumplimiento.', 'Se pueden generar informes de seguimiento automático.', '-'),

('MEA02-P04-A06', 'MEA02-P04', 'Identificar, iniciar, dar seguimiento e implementar acciones correctivas derivadas de las evaluaciones de control y los informes.', 5, 'Open Source Risk Engine', 'Vincula acciones correctivas a controles fallidos y gestiona su ciclo completo.', 'Se puede generar evidencia de cierre por control específico.', '-'),

('MEA03-P01-A01', 'MEA03-P01', 'Asignar la responsabilidad de identificar y monitorear cualquier cambio en los requisitos legales, reglamentarios y otros requisitos contractuales externos relevantes para el uso de los recursos de TI y el procesamiento de la información dentro del negocio y las operaciones de TI de la empresa.', 2, 'GLPI', 'GLPI permite asignar usuarios responsables mediante tareas, recordatorios y planificación.', 'Se puede programar revisiones periódicas.', '-'),

('MEA03-P01-A02', 'MEA03-P01', 'Identificar y evaluar todos los requisitos de cumplimiento potenciales y el impacto en las actividades de I&T en áreas como flujo de datos, privacidad, controles internos, informes financieros, regulaciones específicas de la industria, propiedad intelectual, salud y seguridad.', 2, 'GLPI', 'Se puede documentar el análisis de requisitos mediante tickets o campos personalizados.', 'Ideal para organizaciones pequeñas y medianas. se puede agregar el Plugin: Form Creator para estructurar entradas y análisis', 'Plugin Form Creator'),

('MEA03-P01-A03', 'MEA03-P01', 'Evaluar el impacto de los requisitos legales y reglamentarios relacionados con I&T en los contratos de terceros relacionados con operaciones de TI, proveedores de servicios y socios comerciales.', 2, 'GLPI', 'Permite registrar documentos contractuales, tareas vinculadas y responsables.', 'Apta para trazar cumplimiento y revisiones.con el Plugin: Data Injection (para cargar y actualizar masivamente datos de contratos si son muchos)', 'Plugin Data Injection'),

('MEA03-P01-A04', 'MEA03-P01', 'Definir las consecuencias del incumplimiento.', 2, 'GLPI', 'Se puede definir como parte de planes de acción o riesgos asociados a requisitos no cumplidos.', 'Puede documentarse dentro de cada ítem de cumplimiento.', '-'),

('MEA03-P01-A05', 'MEA03-P01', 'Obtener asesoramiento independiente, cuando corresponda, sobre cambios en las leyes, regulaciones y normas aplicables.', 3, 'GLPI', 'Se puede registrar solicitudes de consultoría y seguimiento de respuestas.', 'Solo seguimiento interno, no conexión legal externa.', '-'),

('MEA03-P01-A06', 'MEA03-P01', 'Mantener un registro actualizado de todos los requisitos legales, reglamentarios y contractuales pertinentes; su impacto y las acciones requeridas.', 3, 'GLPI', 'Puede usarse como repositorio central con seguimiento de cumplimiento y planes relacionados.', 'Requiere control manual para actualizaciones periódicas. Con el Plugin: Form Creator para organizar estructura de ingreso y control', 'Plugin Form Creator'),

('MEA03-P01-A07', 'MEA03-P01', 'Mantener un registro general armonizado e integrado de los requisitos de cumplimiento externo de la empresa.', 3, 'GLPI', 'Permite consolidar toda la documentación, tareas, responsables y acciones bajo una estructura unificada.', 'Facilita la trazabilidad y auditoría.', '-'),

('MEA03-P02-A01', 'MEA03-P02', 'Revisar y ajustar periódicamente las políticas, principios, normas, procedimientos y metodologías para garantizar su eficacia, garantizando el cumplimiento necesario y abordando el riesgo empresarial. Recurrir a expertos internos y externos, según sea necesario.', 3, 'GLPI', 'Permite asignar tareas de revisión, documentar versiones y responsables, e integrar a asesores externos vía gestión de proveedores.', 'Puede planificarse revisión periódica por roles.', '-'),

('MEA03-P02-A02', 'MEA03-P02', 'Comunicar los requisitos nuevos y modificados a todo el personal relevante.', 3, 'GLPI', 'Puede enviar notificaciones automáticas y gestionar tareas dirigidas por perfil o departamento.', 'Útil para trazabilidad de entregas y cambios. se le peude agregar Plugin: Notifications (para ampliar los métodos de comunicación)', 'Plugin Notifications'),

('MEA03-P03-A01', 'MEA03-P03', 'Evaluar periódicamente las políticas, estándares, procedimientos y metodologías organizacionales en todas las funciones de la empresa para asegurar el cumplimiento de los requisitos legales y reglamentarios pertinentes en relación con el procesamiento de la información.', 3, 'GLPI', 'Se pueden registrar evaluaciones en formularios, tareas y auditorías periódicas.', 'Soporte adecuado con uso disciplinado del sistema.', 'Plugin: Form Creator'),

('MEA03-P03-A02', 'MEA03-P03', 'Abordar oportunamente las brechas de cumplimiento en políticas, normas y procedimientos.', 3, 'GLPI', 'Ideal para registrar hallazgos, asignar responsables, dar seguimiento y cerrar tareas.', 'Alta trazabilidad y seguimiento de acciones correctivas.', '-'),

('MEA03-P03-A03', 'MEA03-P03', 'Evaluar periódicamente los procesos y actividades del negocio y de TI para garantizar el cumplimiento de los requisitos legales, reglamentarios y contractuales aplicables.', 3, 'GLPI', 'Compatible con seguimiento de procesos mediante auditorías internas o evaluación manual.', 'Es configurable y escalable con personalización.', '-'),

('MEA03-P03-A04', 'MEA03-P03', 'Revisar periódicamente los patrones recurrentes de fallas de cumplimiento y evaluar las lecciones aprendidas.', 4, 'GLPI', 'Puede configurarse para visualizar patrones mediante reportes de auditoría y repetición de tickets.', 'Permite análisis comparativo entre ciclos. se le puede agregar el Plugin: Reports (para exportar y visualizar patrones)', 'Plugin Reports'),

('MEA03-P03-A05', 'MEA03-P03', 'Con base en la revisión y las lecciones aprendidas, mejorar las políticas, estándares, procedimientos, metodologías y procesos y actividades asociados.', 5, 'GLPI', 'Permite actualizar documentos y tareas en versiones, con seguimiento de revisiones aprobadas.', 'Flujo de aprobación interno con registros.', '-'),

('MEA03-P04-A01', 'MEA03-P04', 'Obtener confirmación periódica del cumplimiento de las políticas internas por parte de los propietarios de procesos comerciales y de TI y los jefes de unidad.', 2, 'GLPI', 'Permite asignar tareas de verificación periódica a responsables de procesos, dejar constancia y programar alertas de revisión.', 'Muy útil para mantener evidencias por usuario o unidad.', '-'),

('MEA03-P04-A02', 'MEA03-P04', 'Realizar revisiones internas y externas periódicas (y, cuando corresponda, independientes) para evaluar los niveles de cumplimiento.', 2, 'GLPI', 'Soporta la gestión de auditorías internas y el registro de auditorías externas con seguimiento.', 'Puede acompañarse de control documental de hallazgos. se le puede agregar el Plugin: Form Creator (para estructurar formatos de auditoría)', 'Plugin Form Creator'),

('MEA03-P04-A03', 'MEA03-P04', 'Si es necesario, obtener afirmaciones de proveedores externos de servicios de I&T sobre sus niveles de cumplimiento con las leyes y regulaciones aplicables.', 2, 'GLPI', 'Registra relaciones con proveedores y permite adjuntar documentación de cumplimiento de forma segura.', 'Puede documentarse como parte de las obligaciones contractuales.', '-'),

('MEA03-P04-A04', 'MEA03-P04', 'De ser necesario, obtener afirmaciones de los socios comerciales sobre sus niveles de cumplimiento con las leyes y regulaciones aplicables en relación con las transacciones electrónicas entre empresas.', 2, 'GLPI', 'Similar al punto anterior, puede registrar las evidencias y compromisos documentales de socios.', 'Compatible con auditoría y revisión por unidad de negocio.', '-'),

('MEA03-P04-A05', 'MEA03-P04', 'Integrar la elaboración de informes sobre requisitos legales, reglamentarios y contractuales a nivel de toda la empresa, involucrando a todas las unidades de negocio.', 3, 'GLPI', 'Permite consolidar informes desde distintas unidades usando categorías, etiquetas y permisos por perfil.', 'Aporta trazabilidad y segmentación por unidad de negocio.', 'Plugin Reports'),

('MEA03-P04-A06', 'MEA03-P04', 'Monitorear e informar sobre problemas de incumplimiento y, cuando sea necesario, investigar la causa raíz.', 4, 'GLPI', 'Registra problemas/incidentes de cumplimiento, asigna responsables y permite documentar el análisis de causa raíz.', 'Soporte completo para ciclo de hallazgo-corrección.', '-'),

('MEA04-P01-A01', 'MEA04-P01', 'Establecer la adhesión a los códigos de ética y estándares aplicables (por ejemplo, el Código de ╔tica Profesional de ISACA) y los estándares de aseguramiento (específicos de la industria y la geografía) (por ejemplo, los Estándares de Auditoría y Aseguramiento de TI de ISACA y el Marco Internacional para Compromisos de Aseguramiento [Marco de Aseguramiento del IAASB] del Consejo de Normas Internacionales de Auditoría y Aseguramiento [IAASB]).', 2, 'Alfresco', 'Alfresco permite centralizar políticas, códigos de ética y estándares, controlar versiones, gestionar aprobaciones, auditar el acceso y asegurar la trazabilidad documental según normas regulatorias.', 'Ideal para gestionar cumplimiento formal con normas como ISACA, IAASB, ISO, etc. Soporta requisitos legales y geográficos.', '-'),

('MEA04-P01-A02', 'MEA04-P01', 'Establecer la independencia de los proveedores de garantía.', 2, 'GLPI', 'Permite documentar y registrar relaciones contractuales, asignaciones y restricciones de acceso que evidencien la independencia del proveedor frente a las áreas evaluadas.', 'Requiere configurar perfiles y roles que reflejen independencia. Se complementa con auditoría interna.', 'Plugin: Data Injection o Formcreator para estructurar formularios de evaluación y documentación.'),

('MEA04-P01-A03', 'MEA04-P01', 'Establecer la competencia y calificación de los proveedores de aseguramiento.', 2, 'GLPI', 'Permite registrar y mantener información sobre la formación, certificaciones y experiencia de los proveedores a través de módulos de gestión de personal y proveedores.', 'Puede complementarse con documentación de soporte y evaluaciones internas.', 'Plugin: Certifications (o personalización del módulo de proveedores)'),

('MEA04-P02-A01', 'MEA04-P02', 'Comprender la estrategia y las prioridades de la empresa.', 2, 'Alfresco', 'Permite gestionar y acceder a documentos estratégicos relevantes de la empresa, planes corporativos y políticas internas, centralizando la información.', 'Requiere configuración adecuada de flujos documentales y permisos.', 'Puede integrarse con GLPI si se usa para seguimiento de planes.'),

('MEA04-P02-A02', 'MEA04-P02', 'Comprender el contexto interno de la empresa. Esta comprensión ayudará al profesional de auditoría a evaluar mejor los objetivos empresariales y la importancia relativa de los objetivos empresariales y de alineación, así como las amenazas más importantes para estos objetivos. A su vez, esto ayudará a definir un alcance más preciso y relevante para el trabajo de auditoría.', 2, 'Alfresco', 'Facilita el almacenamiento estructurado de políticas internas, descripciones de procesos, organigramas y análisis de riesgo internos.', 'Su efectividad depende de una adecuada clasificación documental.', 'Puede integrarse con motores BPM externos como BonitaSoft para procesos.'),

('MEA04-P02-A03', 'MEA04-P02', 'Comprender el contexto externo de la empresa. Esta comprensión ayudará al profesional de auditoría a comprender mejor los objetivos de la empresa y la importancia relativa de los objetivos de la empresa y de alineación, así como las amenazas más importantes para estos objetivos. A su vez, esto ayudará a definir un alcance más preciso y relevante para el trabajo de auditoría.', 2, 'Alfresco', 'Permite centralizar normativa externa, análisis de mercado, benchmarking y amenazas regulatorias, lo cual facilita el análisis externo desde un punto documental.', 'Puede incorporar alertas o flujos de revisión para nueva normativa.', 'Puede integrarse con herramientas de cumplimiento externo si se requiere automatización.'),

('MEA04-P02-A04', 'MEA04-P02', 'Desarrollar un plan anual general para iniciativas de aseguramiento que contenga los objetivos de aseguramiento consolidados.', 3, 'GLPI', 'A través del módulo de proyectos y tareas, permite planificar, registrar, asignar y hacer seguimiento a iniciativas de auditoría o aseguramiento.', 'Puede complementarse con formularios y documentos adjuntos.', 'Plugin: Formcreator para diseñar el plan anual de aseguramiento como formulario o flujo estructurado.'),

('MEA04-P03-A01', 'MEA04-P03', 'Definir el objetivo de aseguramiento de la iniciativa de aseguramiento identificando a las partes interesadas de la iniciativa de aseguramiento y sus intereses.', 2, 'GLPI', 'Mediante el módulo de proyectos y la gestión de tareas y grupos, se puede definir el alcance de iniciativas y asociar actores responsables (usuarios o grupos).', 'Permite asignar roles y documentar requerimientos en tareas o tickets.', 'Se puede complementar con Formcreator para capturar intereses o necesidades mediante formularios.'),

('MEA04-P03-A02', 'MEA04-P03', 'Acordar los objetivos de alto nivel y los límites organizacionales del trabajo de aseguramiento.', 2, 'GLPI', 'Se pueden definir hitos y delimitaciones de proyectos mediante planificación y asignación de tareas con alcance limitado por entidades o áreas.', 'Se recomienda usar las entidades de GLPI para representar límites organizacionales.', 'Integración con Planificación y Formcreator para formalizar acuerdos.'),

('MEA04-P03-A03', 'MEA04-P03', 'Considere el uso de la Cascada de Objetivos COBIT y sus diferentes niveles para expresar el objetivo de aseguramiento.', 3, 'Alfresco', 'Permite almacenar y organizar documentos relacionados con marcos de referencia como COBIT, y vincularlos a iniciativas.', 'Permite organizar versiones, referencias cruzadas y documentación normativa.', 'Puede integrarse con herramientas externas de modelado como ArchiMate o BPMN para visualización.'),

('MEA04-P03-A04', 'MEA04-P03', 'Asegúrese de que los objetivos del trabajo de aseguramiento consideren los tres componentes del objetivo de valor: brindar beneficios que respalden los objetivos estratégicos, optimizar el riesgo de que no se alcancen los objetivos estratégicos y optimizar los niveles de recursos necesarios para alcanzar los objetivos estratégicos.', 3, 'GLPI', 'A través de sus módulos de proyectos, gestión de riesgos (con plugin), y seguimiento de tareas, permite integrar aspectos estratégicos, riesgos y asignación de recursos.', 'Cumple parcialmente, requiere plugins y diseño de estructura de proyecto adecuada.', 'Plugins recomendados: Risk Management, Formcreator y Dashboards.'),

('MEA04-P04-A01', 'MEA04-P04', 'Definir todos los componentes de gobernanza incluidos en el alcance de la revisión, es decir, los principios, políticas y marcos; procesos; estructuras organizativas; cultura, ética y comportamiento; información; servicios, infraestructura y aplicaciones; personas, habilidades y competencias.', 2, 'Alfresco', 'Permite estructurar y documentar cada componente de gobernanza a través de repositorios organizados y metadatos.', 'Soporta clasificación de información por tipo de componente, políticas y estructuras.', 'Se puede integrar con modeladores BPMN o ArchiMate para vincular arquitectura y documentación.'),

('MEA04-P04-A02', 'MEA04-P04', 'Con base en la definición del alcance, definir un plan de involucramiento, considerando la información a recolectar y los grupos de interés a entrevistar.', 3, 'GLPI', 'El módulo de proyectos junto con tareas y seguimiento permite planear el involucramiento de partes interesadas y recolectar información.', 'Puede definirse el plan como proyecto con tareas para entrevistas y recolección.', 'Plugin Formcreator puede apoyar la recolección de datos de partes interesadas.'),

('MEA04-P04-A03', 'MEA04-P04', 'Confirmar y refinar el alcance basándose en la comprensión de la arquitectura empresarial.', 3, 'Alfresco', 'Facilita la gestión de versiones, trazabilidad de documentos y asociación con modelos de arquitectura organizativa.', 'Puede complementarse con documentos provenientes de arquitecturas empresariales.', 'Puede integrarse con modeladores externos y herramientas BPM/EA.'),

('MEA04-P04-A04', 'MEA04-P04', 'Refinar el alcance del trabajo de aseguramiento, basándose en los recursos disponibles.', 3, 'GLPI', 'Permite ajustar cronogramas y recursos asignados en proyectos activos según disponibilidad o cargas de trabajo.', 'La reasignación de tareas y carga por técnico permite balancear el uso de recursos.', 'Complemento útil: Dashboards para visualizar sobrecarga de recursos.'),

('MEA04-P05-A01', 'MEA04-P05', 'Defina los pasos detallados para recopilar y evaluar la información de los controles de gestión dentro del alcance. Céntrese en evaluar la definición y aplicación de buenas prácticas relacionadas con el diseño de controles y el logro de los objetivos de control, en relación con su eficacia.', 2, 'Alfresco', 'Permite estructurar procedimientos, checklists y formularios para recolección y evaluación documental.', 'Facilita el seguimiento de la eficacia de controles a través de flujos documentales.', 'Se puede complementar con herramientas BPM para modelar flujos de control.'),

('MEA04-P05-A02', 'MEA04-P05', 'Comprender el contexto de los objetivos de gestión y los controles de gestión de apoyo implementados. Comprender cómo estos controles de gestión contribuyen al logro de los objetivos de alineación y los objetivos empresariales.', 2, 'GLPI', 'A través del módulo de proyectos y base de conocimientos se puede documentar el contexto y vincularlo a activos y procesos.', 'Requiere estructuración previa de objetivos y controles como entradas.', 'Puede complementarse con plugin Data Injection para relacionar activos y controles.'),

('MEA04-P05-A03', 'MEA04-P05', 'Comprender a todas las partes interesadas y sus intereses.', 2, 'GLPI', 'Permite asociar usuarios, perfiles y roles a los proyectos o tareas de auditoría.', 'Los stakeholders pueden ser mapeados en perfiles y grupos con roles definidos.', 'Integración posible con LDAP o directorios externos.'),

('MEA04-P05-A04', 'MEA04-P05', 'Acordar las buenas prácticas esperadas para los controles de gestión.', 3, 'Alfresco', 'Sirve como repositorio normativo donde pueden almacenarse marcos de referencia, guías y políticas de buenas prácticas.', 'Se pueden clasificar y versionar documentos como COBIT, ISO, NIST, etc.', 'Integra con control de versiones y permisos por documento.'),

('MEA04-P05-A05', 'MEA04-P05', 'En caso de que el control de gestión sea débil, definir prácticas para identificar el riesgo residual (en preparación para el informe).', 3, 'Alfresco', 'Permite documentar matrices de riesgo, evidencias y respuestas ante debilidades en controles.', 'No cuantifica el riesgo pero sirve como evidencia del análisis y mitigación.', 'Puede integrarse con hojas de cálculo externas o software de ERM.'),

('MEA04-P05-A06', 'MEA04-P05', 'Comprender la etapa del ciclo de vida de los controles de gestión y acordar los valores esperados.', 3, 'GLPI', 'A través del ciclo de vida de activos y tareas en proyectos se puede modelar parcialmente la madurez de controles.', 'Limitado, pero permite establecer etapas como planeación, implementación, revisión.', 'Requiere diseño previo de estructura de trabajo por fases.'),

('MEA04-P06-A01', 'MEA04-P06', 'Perfeccionar la comprensión del tema de aseguramiento de TI.', 2, 'Alfresco', 'Permite centralizar la documentación, evidencias previas y referencias normativas necesarias para comprender el contexto de aseguramiento.', 'Soporta la trazabilidad y reutilización de documentos técnicos y de gobernanza.', 'Puede integrarse con software de modelado o frameworks de control externo.'),

('MEA04-P06-A02', 'MEA04-P06', 'Refinar el alcance del tema de aseguramiento de TI.', 2, 'GLPI', 'Permite detallar alcance en términos de procesos, activos o servicios mediante su módulo de proyectos y tareas.', 'Requiere estructuración previa con taxonomía adecuada.', 'Puede complementarse con el plugin Fields para personalizar formularios.'),

('MEA04-P06-A03', 'MEA04-P06', 'Observar, inspeccionar y revisar el enfoque de control de gestión. Validar el diseño con el responsable del control para garantizar su integridad, relevancia, puntualidad y mensurabilidad.', 3, 'Alfresco', 'Permite configurar flujos de revisión y validación documental con responsables asignados.', 'Ideal para validar controles y mantener evidencia firmada.', 'Soporta firmas electrónicas e historial de versiones.'),

('MEA04-P06-A04', 'MEA04-P06', 'Pregunte al responsable del control si se han asignado las responsabilidades del componente de gobernanza y la rendición de cuentas general. Confirme la respuesta. Compruebe si se comprenden y aceptan las responsabilidades y la rendición de cuentas. Verifique que se disponga de las habilidades y los recursos necesarios.', 3, 'GLPI', 'Permite mapear responsables de controles mediante la asignación de roles y tareas por usuario.', 'Aplica si los controles han sido definidos como proyectos o tareas.', 'Puede integrarse con directorios como LDAP para control de perfiles.'),

('MEA04-P06-A05', 'MEA04-P06', 'Reconsiderar el equilibrio entre los tipos de actividades de control de gestión de prevención frente a detección y corrección.', 3, 'Alfresco', 'Posibilita documentar y versionar estrategias de control clasificadas en tipos (preventivas, correctivas, etc.).', 'Apoya solo desde el punto documental y de evidencia.', 'Puede usarse junto con ERPs o software de GRC para seguimiento cuantitativo.'),

('MEA04-P06-A06', 'MEA04-P06', 'Considere el esfuerzo invertido en mantener los controles de gestión y la relación coste-eficacia asociada.', 3, 'GLPI', 'A través de sus módulos de tickets, tareas y seguimiento de tiempos se puede estimar el esfuerzo operativo.', 'No calcula costos directamente pero sirve de base para análisis de esfuerzo.', 'Puede integrarse con módulos financieros externos para análisis de costos.'),

('MEA04-P07-A01', 'MEA04-P07', 'Evaluar si se alcanzan los resultados esperados para cada uno de los controles de gestión dentro del alcance. Es decir, evaluar la eficacia del control de gestión (eficacia del control).', 3, 'GLPI', 'Permite hacer seguimiento al cumplimiento de tareas y controles definidos en proyectos, lo que puede usarse para verificar resultados esperados.', 'Aporta evidencia de ejecución, no mide impacto automáticamente.', 'Puede integrarse con plugins de seguimiento como Reports o Dashboards.'),

('MEA04-P07-A02', 'MEA04-P07', 'Asegurar que el profesional de aseguramiento compruebe el resultado o la eficacia del control de gestión buscando evidencia directa e indirecta de su impacto en los objetivos de control de gestión. Esto implica la justificación directa e indirecta de la contribución medible de los objetivos de gestión a los objetivos de alineación, registrando así evidencia directa e indirecta del logro efectivo de los resultados esperados.', 3, 'Alfresco', 'Soporta evidencia documental directa (informes, formularios) e indirecta (anexos, actas) asociada a procesos de control.', 'Ideal para centralizar la trazabilidad y consolidar hallazgos.', 'Compatible con sistemas de firmas digitales para validar evidencia.'),

('MEA04-P07-A03', 'MEA04-P07', 'Determinar si el profesional de auditoría obtiene evidencia directa o indirecta para partidas/periodos seleccionados mediante la aplicación de diversas técnicas de prueba para garantizar la eficacia del control de gestión bajo revisión. Asegurarse de que el profesional de auditoría también realice una revisión limitada de la idoneidad de los resultados del control de gestión y determine el nivel de pruebas sustantivas y trabajo adicional necesario para garantizar que el control de gestión sea adecuado.', 3, 'Alfresco', 'Facilita organizar y almacenar evidencia auditada, gestionar muestras y registros asociados a periodos y procesos.', 'Puede usarse para almacenar y auditar planes de muestreo o resultados de pruebas.', 'Puede integrarse con suites de BI o ERP para análisis cuantitativo.'),

('MEA04-P07-A04', 'MEA04-P07', 'Investigar si un control de gestión puede hacerse más eficiente y si su diseño puede ser más efectivo optimizando pasos o buscando sinergias con otros controles de gestión.', 3, 'GLPI', 'A través del seguimiento de tickets/tareas y la documentación de procesos es posible detectar redundancias o mejoras.', 'El análisis depende de la revisión manual, pero se puede soportar en la trazabilidad del sistema.', 'Se recomienda complementar con herramientas de análisis de procesos.'),

('MEA04-P08-A01', 'MEA04-P08', 'Documentar el impacto de las debilidades de control.', 2, 'Alfresco', 'Permite documentar hallazgos y debilidades mediante informes y adjuntos, manteniendo la trazabilidad y clasificación.', 'Aporta control de versiones y seguimiento de cambios.', 'Puede integrarse con soluciones de firma electrónica o flujos BPMN.'),

('MEA04-P08-A02', 'MEA04-P08', 'Comunicarse con la gerencia durante la ejecución de la iniciativa para que haya una comprensión clara del trabajo realizado y un acuerdo y aceptación de las conclusiones y recomendaciones preliminares.', 2, 'GLPI', 'A través de tareas, notas y flujos de trabajo, permite mantener comunicación con responsables y registrar decisiones.', 'Puede integrarse a correos electrónicos y calendario.', 'Puede complementarse con plugin Behaviors para flujos más detallados.'),

('MEA04-P08-A03', 'MEA04-P08', 'Proporcionar a la administración un informe (alineado con los términos de referencia, el alcance y los estándares de informes acordados) que respalde los resultados de la iniciativa y permita un enfoque claro en cuestiones clave y acciones importantes.', 3, 'Alfresco', 'Permite generar informes documentales estandarizados, accesibles y versionados, alineados con formatos predefinidos.', 'Asegura consistencia documental y cumplimiento de plantillas.', 'Compatible con integración a suites ofimáticas y BI externas.'),

('MEA04-P08-A04', 'MEA04-P08', 'Supervisar las actividades de aseguramiento y asegurarse de que el trabajo realizado esté completo, cumpla los objetivos y tenga una calidad aceptable. Revisar el enfoque o los pasos detallados si se detectan deficiencias de calidad.', 4, 'GLPI', 'Permite registrar auditorías internas de calidad, asignar responsables, fechas límite y documentación de resultados.', 'Soporta seguimiento en paneles e informes de avance.', 'Puede usarse con plugin Dashboards o Reports para mayor visualización.'),

('MEA04-P09-A01', 'MEA04-P09', 'Acordar e implementar internamente, dentro de la organización, las acciones necesarias que deben adoptarse para resolver las debilidades y brechas identificadas.', 2, 'GLPI', 'Permite registrar acciones correctivas como tareas dentro de proyectos o incidentes, asignarlas a responsables, y establecer fechas límite y estados de avance.', 'Requiere configuración de flujos o uso de plugin para seguimiento específico de auditorías.', 'Plugin Behaviors o Checklist para definición y seguimiento de pasos de corrección.'),

('MEA04-P09-A02', 'MEA04-P09', 'Realizar seguimiento, dentro de la organización, para determinar si se tomaron acciones correctivas y se resolvieron las debilidades del control interno.', 2, 'Alfresco', 'Permite almacenar y auditar documentación de evidencias de cierre de acciones, controlar versiones y asegurar la trazabilidad del proceso.', 'Ideal para entornos donde se requiera validación documental de cumplimiento.', 'Puede integrarse con herramientas de flujo de trabajo (BPM) o con GLPI para tareas.'),

('EDM01-P01-A01', 'EDM01-P01', 'Analizar e identificar los factores ambientales internos y externos (obligaciones legales, regulatorias y contractuales) y las tendencias en el entorno empresarial que puedan influir en el diseño de la gobernanza.', 2, NULL, 'La herramienta Apache Open, puede documentarse en texto o tablas. Herramienta de soporte manual.', 'Herramienta de apoyo documental, no ejecuta la acción.', '-'),

('EDM01-P01-A02', 'EDM01-P01', 'Determinar la importancia de I&T y su papel con respecto al negocio.', 2, 'Apache Open', 'Se puede redactar, justificar y estructurar la información en documentos.', 'Herramienta de apoyo documental, no ejecuta la acción.', '-'),

('EDM01-P01-A03', 'EDM01-P01', 'Considerar las regulaciones externas, las leyes y las obligaciones contractuales y determinar cómo deben aplicarse dentro de la gobernanza de la I&T empresarial.', 2, 'Apache Open', 'Permite registrar y analizar requisitos regulatorios en documentos.', 'Herramienta de apoyo documental, no ejecuta la acción.', '-'),

('EDM01-P01-A04', 'EDM01-P01', 'Determinar las implicaciones del entorno de control general de la empresa con respecto a I&T.', 2, NULL, 'La herramienta Apache Open, se pueden modelar escenarios de control mediante textos o tablas.', 'Herramienta de apoyo documental, no ejecuta la acción.', '-'),

('EDM01-P01-A05', 'EDM01-P01', 'Alinear el uso y procesamiento ético de la información y su impacto en la sociedad, el medio ambiente natural y los intereses de las partes interesadas internas y externas con la dirección, las metas y los objetivos de la empresa.', 3, NULL, 'La herramienta Apache Open, ideal para formular políticas éticas y vincularlas a objetivos.', 'Herramienta de apoyo documental, no ejecuta la acción.', '-'),

('EDM01-P01-A06', 'EDM01-P01', 'Articular principios que guiarán el diseño de la gobernanza y la toma de decisiones de I&T.', 3, NULL, 'La herramienta Apache Open, se pueden redactar y comunicar principios de decisión.', 'Herramienta de apoyo documental, no ejecuta la acción.', '-'),

('EDM01-P01-A07', 'EDM01-P01', 'Determinar el modelo de toma de decisiones óptimo para I&T.', 3, NULL, 'La herramienta Apache Open, pueden establecerse estructuras jerárquicas en textos, diagramas o tablas.', 'Herramienta de apoyo documental, no ejecuta la acción.', '-'),

('EDM01-P01-A08', 'EDM01-P01', 'Determinar los niveles apropiados de delegación de autoridad, incluidas las reglas de umbral, para las decisiones de I&T.', 3, NULL, 'La herramienta Apache Open, se puede documentar una matriz RACI o reglas de escalamiento.', 'Herramienta de apoyo documental, no ejecuta la acción.', '-'),

('EDM01-P02-A01', 'EDM01-P02', 'Comunicar los principios de gobernanza de I&T y acordar con la dirección ejecutiva la forma de establecer un liderazgo informado y comprometido.', 2, NULL, 'La herramienta Apache Open, se pueden crear presentaciones, documentos estratégicos y comunicados.', 'Herramienta de apoyo documental, no ejecuta la acción.', '-'),

('EDM01-P02-A02', 'EDM01-P02', 'Establecer o delegar el establecimiento de estructuras, procesos y prácticas de gobernanza en consonancia con los principios de diseño acordados.', 2, 'Archi', 'Permite modelar estructuras, procesos y prácticas.', 'Adecuado para visualizar relaciones y dependencias.', '-'),

('EDM01-P02-A03', 'EDM01-P02', 'Establecer una junta directiva de I+T (o equivalente). Esta junta debe garantizar que la gobernanza de la información y la tecnología, como parte de la gobernanza empresarial, se aborde adecuadamente; asesorar sobre la dirección estratégica; y determinar la priorización de los programas de inversión en I+T, de acuerdo con la estrategia y las prioridades de la empresa.', 2, NULL, 'La herramienta Archi, puedes representar la junta como nodo organizacional.', 'Puede representar pero no gestionar la junta.', '-'),

('EDM01-P02-A04', 'EDM01-P02', 'Asignar responsabilidad, autoridad y rendición de cuentas por las decisiones de I&T de acuerdo con los principios de diseño de gobernanza acordados, los modelos de toma de decisiones y la delegación.', 3, NULL, 'La herramienta Archi, soporta modelado de autoridad, responsabilidad y estructuras jerárquicas.', 'Se puede modelar la asignación, no gestionarla.', '-'),

('EDM01-P02-A05', 'EDM01-P02', 'Garantizar que los mecanismos de comunicación y presentación de informes proporcionen a los responsables de la supervisión y la toma de decisiones la información adecuada.', 3, 'Apache Open', 'Writer o Calc permite crear informes que pueden distribuirse manualmente.', 'Generación manual de reportes, no automatizada.', '-'),

('EDM01-P02-A06', 'EDM01-P02', 'Ordenar que el personal siga las pautas pertinentes para el comportamiento ético y profesional y garantizar que las consecuencias del incumplimiento se conozcan y se apliquen.', 3, 'Apache Open', 'Se pueden redactar políticas y distribuirlas internamente.', 'Ideal para redactar código de conducta y sanciones.', '-'),

('EDM01-P02-A07', 'EDM01-P02', 'Dirigir el establecimiento de un sistema de recompensas para promover el cambio cultural deseable.', 3, 'Apache Open', 'Se puede estructurar el plan de incentivos y comunicarlo.', 'Solo apoya el diseño y documentación del sistema.', '-'),

('EDM01-P03-A01', 'EDM01-P03', 'Evaluar la eficacia y el desempeño de aquellas partes interesadas a quienes se les ha delegado responsabilidad y autoridad para la gobernanza de la I&T empresarial.', 3, 'Apache Open', 'Permite registrar evaluaciones de desempeño delegadas.', 'Solo apoya la documentación y análisis manual.', '-'),

('EDM01-P03-A02', 'EDM01-P03', 'Evaluar periódicamente si los mecanismos acordados de gobernanza de I&T (estructuras, principios, procesos, etc.) están establecidos y funcionan eficazmente.', 4, 'Archi', 'Se puede modelar si los componentes de gobierno existen.', 'Útil para validación estructural desde lo visual.', '-'),

('EDM01-P03-A03', 'EDM01-P03', 'Evaluar la eficacia del diseño de gobernanza e identificar acciones para rectificar cualquier desviación encontrada.', 4, 'Apache Open', 'Puede registrar los resultados de análisis y plan de acción.', 'Apoya el seguimiento y corrección documental.', '-'),

('EDM01-P03-A04', 'EDM01-P03', 'Mantener la supervisión del grado en que I&T cumple con las obligaciones (regulatorias, legislativas, de derecho consuetudinario, contractuales), las políticas internas, los estándares y las pautas profesionales.', 4, 'Apache Open', 'Puede documentar controles y verificar cumplimiento.', 'Funciona para consolidar resultados y observaciones.', '-'),

('EDM01-P03-A05', 'EDM01-P03', 'Proporcionar supervisión de la eficacia y el cumplimiento del sistema de control de la empresa.', 4, 'Apache Open', 'Puede usarse para redactar reportes sobre controles internos.', 'Herramienta de apoyo para auditoría interna.', '-'),

('EDM01-P03-A06', 'EDM01-P03', 'Supervisar los mecanismos regulares y rutinarios para garantizar que el uso de I&T cumple con las obligaciones pertinentes (regulatorias, legislativas, de derecho consuetudinario, contractuales), estándares y directrices.', 4, 'Apache Open', 'Permite hacer checklists, reportes de cumplimiento.', 'Apoyo documental; no realiza seguimiento automático.', '-'),

('EDM02-P01-A01', 'EDM02-P01', 'Crear y mantener carteras de programas de inversión habilitados para I&T, servicios de TI y activos de TI, que formen la base del presupuesto de TI actual y respalden los planes tácticos y estratégicos de I&T.', 2, NULL, 'La herramienta Archi, permite modelar carteras, servicios, activos y planes estratégicos de I&T.', 'Útil para visualizar la alineación entre inversiones y arquitectura empresarial.', '-'),

('EDM02-P01-A02', 'EDM02-P01', 'Obtener un entendimiento común entre TI y las demás funciones del negocio sobre las oportunidades potenciales para que TI habilite y contribuya a la estrategia empresarial.', 2, 'Archi', 'Facilita la representación de relaciones entre funciones TI y negocio.', 'Sirve para generar entendimiento común entre dominios a nivel visual.', '-'),

('EDM02-P01-A03', 'EDM02-P01', 'Identificar las categorías amplias de sistemas de información, aplicaciones, datos, servicios de TI, infraestructura, activos de I&T, recursos, habilidades, prácticas, controles y relaciones necesarias para respaldar la estrategia empresarial.', 2, 'Archi', 'Modela elementos de I&T y su relación con la estrategia.', 'Puede representar las categorías necesarias para el soporte estratégico.', '-'),

('EDM02-P01-A04', 'EDM02-P01', 'Acordar los objetivos de I&T, considerando las interrelaciones entre la estrategia empresarial y los servicios, activos y otros recursos de I&T. Identificar y aprovechar las sinergias posibles.', 2, 'Archi', 'Relaciona objetivos de I&T con componentes empresariales.', 'Aporta claridad estructural para la definición de objetivos alineados.', '-'),

('EDM02-P01-A05', 'EDM02-P01', 'Definir una combinación de inversiones que logre el equilibrio adecuado entre varias dimensiones, incluido un equilibrio apropiado entre rendimientos a corto y largo plazo, beneficios financieros y no financieros e inversiones de alto y bajo riesgo.', 3, 'Open Source Risk Engine', 'Calcula combinaciones de riesgo-retorno entre inversiones.', 'Ideal para evaluar portafolio balanceado (si se adapta a TI).', '-'),

('EDM02-P02-A01', 'EDM02-P02', 'Comprender los requisitos de las partes interesadas; los problemas estratégicos de I&T, como la dependencia de I&T; y los conocimientos y capacidades tecnológicas relacionados con la importancia real y potencial de I&T para la estrategia de la empresa.', 2, 'Archi', 'Permite modelar relaciones entre I&T, capacidades, estrategia y partes interesadas.', 'Útil para visualizar dependencias estratégicas entre negocio y TI.', '-'),

('EDM02-P02-A02', 'EDM02-P02', 'Comprender los elementos clave de gobernanza necesarios para la entrega confiable, segura y rentable de valor óptimo a partir del uso de servicios, activos y recursos de I&T existentes y nuevos.', 3, 'Archi', 'Modela elementos de gobernanza vinculados a recursos de I&T.', 'Sirve para mapear elementos clave que habilitan valor.', '-'),

('EDM02-P02-A03', 'EDM02-P02', 'Comprender y discutir periódicamente las oportunidades que podrían surgir para la empresa a partir de los cambios posibilitados por las tecnologías actuales, nuevas o emergentes, y optimizar el valor creado a partir de esas oportunidades.', 3, 'Archi', 'Facilita la exploración visual de nuevos escenarios tecnológicos y su impacto.', 'Soporta análisis de impacto de nuevas tecnologías con base en arquitectura.', '-'),

('EDM02-P02-A04', 'EDM02-P02', 'Comprender qué constituye valor para la empresa y considerar qué tan bien se comunica, se entiende y se aplica en todos los procesos de la empresa.', 3, 'Archi', 'Archi permite modelar el negocio y TI con ArchiMate, facilitando la representación de cómo se crea y comunica valor en la organización.', 'Útil para comunicar visualmente cómo se genera y gestiona el valor.', '-'),

('EDM02-P02-A05', 'EDM02-P02', 'Evaluar la eficacia con la que las estrategias empresariales y de I&T se han integrado y alineado dentro de la empresa y con los objetivos empresariales para generar valor.', 4, 'Archi', 'Archi facilita el análisis de alineación estratégica a través de modelos que integran objetivos, capacidades de TI y metas organizacionales.', 'Permite visualizar brechas y oportunidades en la integración.', '-'),

('EDM02-P02-A06', 'EDM02-P02', 'Comprender y considerar cuán efectivos son los roles, responsabilidades, rendición de cuentas y órganos de toma de decisiones actuales para garantizar la creación de valor a partir de inversiones, servicios y activos habilitados por I&T.', 4, 'Collabtive', 'Collabtive permite documentar, asignar y rastrear roles y responsabilidades dentro de iniciativas y servicios habilitados por I&T.', 'Útil para seguimiento organizacional y trazabilidad de decisiones.', '-'),

('EDM02-P02-A07', 'EDM02-P02', 'Considere qué tan bien se alinea la gestión de inversiones, servicios y activos habilitados por I&T con la gestión del valor empresarial y las prácticas de gestión financiera.', 4, 'Open Source Risk Engine', 'Permite analizar activos desde una perspectiva financiera, simulando riesgos, rendimiento y costo-beneficio.', 'Se requiere conocimiento financiero/técnico para su correcta configuración.', '-'),

('EDM02-P02-A08', 'EDM02-P02', 'Evaluar la cartera de inversiones, servicios y activos para su alineación con los objetivos estratégicos de la empresa; el valor de la empresa, tanto financiero como no financiero; el riesgo, tanto el riesgo de entrega como el riesgo de beneficios; la alineación de los procesos de negocio; la eficacia en términos de usabilidad, disponibilidad y capacidad de respuesta; y la eficiencia en términos de coste, redundancia y salud técnica.', 4, 'Open Source Risk Engine', 'Ideal para evaluar portafolios considerando riesgo, rentabilidad, valor estratégico, eficiencia y redundancia.', 'Cubre integralmente el análisis técnico-financiero de portafolios I&T.', '-'),

('EDM02-P03-A01', 'EDM02-P03', 'Definir y comunicar los tipos de cartera e inversión, las categorías, los criterios y las ponderaciones relativas a los criterios para permitir puntuaciones generales de valor relativo.', 2, 'Open Source Risk Engine', 'Permite estructurar portafolios con criterios financieros, categorías, y pesos para evaluar el valor relativo de iniciativas I&T.', 'Excelente para definir tipos de inversión y evaluar impacto.', '-'),

('EDM02-P03-A02', 'EDM02-P03', 'Definir requisitos para las etapas de evaluación y otras revisiones en cuanto a la importancia de la inversión para la empresa y el riesgo asociado, los cronogramas del programa, los planes de financiamiento y la entrega de capacidades y beneficios clave y la contribución continua al valor.', 3, 'Open Source Risk Engine', 'Facilita la evaluación completa del ciclo de vida de las inversiones: riesgo, cronogramas, beneficios esperados y financiamiento.', 'Brinda soporte robusto a la toma de decisiones estratégicas.', '-'),

('EDM02-P03-A03', 'EDM02-P03', 'Dirigir a la gerencia para que considere posibles usos innovadores de I&T que permitan a la empresa responder a nuevas oportunidades o desafíos, emprender nuevos negocios, aumentar la competitividad o mejorar los procesos.', 3, 'Archi', 'Archi permite mapear nuevas iniciativas tecnológicas e innovaciones alineadas con oportunidades de negocio.', 'Es clave para representar visualmente ideas transformadoras.', '-'),

('EDM02-P03-A04', 'EDM02-P03', 'Dirigir cualquier cambio necesario en la asignación de responsabilidades y rendición de cuentas para ejecutar la cartera de inversiones y entregar valor a partir de los procesos y servicios comerciales.', 3, 'Collabtive', 'Permite asignar tareas, roles y responsables, y seguir su cumplimiento, promoviendo la transparencia.', 'Útil para documentar y ajustar gobernanza operativa.', '-'),

('EDM02-P03-A05', 'EDM02-P03', 'Orientar cualquier cambio necesario en la cartera de inversiones y servicios para realinearla con los objetivos y/o limitaciones empresariales actuales y esperados.', 3, 'Open Source Risk Engine', 'Ofrece análisis dinámico de la cartera y puede adaptarse fácilmente a cambios en objetivos o limitaciones.', 'Permite evaluar y reequilibrar en tiempo real.', '-'),

('EDM02-P03-A06', 'EDM02-P03', 'Recomendar la consideración de posibles innovaciones, cambios organizacionales o mejoras operativas que podrían generar mayor valor para la empresa a partir de iniciativas basadas en I&T.', 3, 'Archi', 'Permite analizar y representar innovaciones en estructura organizacional o procesos mediante modelos de arquitectura.', 'Soporta análisis de valor de nuevas propuestas de cambio.', '-'),

('EDM02-P03-A07', 'EDM02-P03', 'Definir y comunicar objetivos de entrega de valor a nivel empresarial y medidas de resultados para permitir un seguimiento efectivo.', 4, 'Archi', 'Archi permite vincular objetivos estratégicos a métricas clave mediante modelos de motivación y valor.', 'Asegura trazabilidad visual entre acciones y resultados.', '-'),

('EDM02-P04-A01', 'EDM02-P04', 'Definir un conjunto equilibrado de objetivos de desempeño, métricas, metas y puntos de referencia. Las métricas deben abarcar medidas de actividad y resultados, incluyendo indicadores de avance y de retraso, así como un equilibrio adecuado entre medidas financieras y no financieras. Revisarlas y acordarlas con el departamento de TI y otras funciones del negocio, así como con otras partes interesadas relevantes.', 4, 'Open Source Risk Engine', 'Permite establecer objetivos financieros y no financieros, métricas clave e indicadores balanceados con criterios técnicos y de riesgo.', 'Ideal para generar indicadores adelantados y rezagados con trazabilidad.', '-'),

('EDM02-P04-A02', 'EDM02-P04', 'Recopilar datos relevantes, oportunos, completos, creíbles y precisos para informar sobre el progreso en la entrega de valor con respecto a los objetivos. Obtener una visión concisa, completa y completa del desempeño de la cartera, el programa y las capacidades técnicas y operativas (I&T) que respalde la toma de decisiones. Asegurar el logro de los resultados esperados.', 4, 'Open Source Risk Engine', 'Recoge y organiza datos cuantitativos y cualitativos de desempeño técnico y de negocio para análisis estratégico.', 'Aporta una visión integral para soporte de decisiones.', '-'),

('EDM02-P04-A03', 'EDM02-P04', 'Obtener informes periódicos y relevantes sobre el desempeño de la cartera, los programas y las tecnologías de la información y las comunicaciones (TI) (tecnológicas y funcionales). Revisar el progreso de la empresa hacia las metas identificadas y el grado de cumplimiento de los objetivos planificados, la obtención de los entregables, el cumplimiento de los objetivos de rendimiento y la mitigación de riesgos.', 4, 'Open Source Risk Engine', 'Genera informes periódicos detallados con seguimiento de objetivos, entregables, cumplimiento de KPIs y mitigación de riesgos.', 'Excelente para gobernanza por resultados.', '-'),

('EDM02-P04-A04', 'EDM02-P04', 'Tras revisar los informes, garantizar que se inicien y controlen las medidas correctivas de gestión adecuadas.', 5, 'MantisBT', 'Permite registrar, asignar, rastrear y cerrar acciones correctivas derivadas de análisis de desempeño.', 'Útil para garantizar ejecución de mejoras a tiempo.', '-'),

('EDM02-P04-A05', 'EDM02-P04', 'Tras revisar los informes, tomar las medidas de gestión adecuadas según sea necesario para garantizar que se optimice el valor.', 5, 'Open Source Risk Engine', 'Evalúa impacto de acciones de gestión propuestas sobre el valor empresarial, reequilibrando cartera o ajustando procesos.', 'Herramienta clave para cerrar ciclo de optimización.', '-'),

('EDM03-P01-A01', 'EDM03-P01', 'Comprender la organización y su contexto relacionado con el riesgo de I&T.', 2, 'Eramba', 'Permite mapear procesos de negocio, activos, amenazas y vulnerabilidades, contextualizando el riesgo en toda la organización.', 'Facilita la visualización de relaciones entre procesos, activos, amenazas y controles.', '-'),

('EDM03-P01-A02', 'EDM03-P01', 'Determinar el apetito de riesgo de la organización, es decir, el nivel de riesgo relacionado con I&T que la empresa está dispuesta a asumir en la consecución de sus objetivos empresariales.', 2, 'Eramba', 'Soporta la configuración de niveles aceptables de exposición al riesgo y permite definir el apetito de riesgo según objetivos estratégicos.', 'Ayuda a controlar qué riesgos son aceptables y cuáles deben tratarse.', '-'),

('EDM03-P01-A03', 'EDM03-P01', 'Determinar los niveles de tolerancia al riesgo frente al apetito por el riesgo, es decir, desviaciones temporalmente aceptables del apetito por el riesgo.', 2, 'Eramba', 'Permite establecer y monitorear umbrales de tolerancia. Genera alertas cuando se superan los niveles definidos.', 'Soporta evaluaciones cuantitativas y cualitativas.', '-'),

('EDM03-P01-A04', 'EDM03-P01', 'Determinar el grado de alineación de la estrategia de riesgo de I&T con la estrategia de riesgo empresarial y garantizar que el apetito por el riesgo esté por debajo de la capacidad de riesgo de la organización.', 2, 'Eramba', 'Integra políticas, objetivos, riesgos y controles para garantizar coherencia estratégica.', 'Facilita auditorías cruzadas y visualización de cumplimiento.', '-'),

('EDM03-P01-A05', 'EDM03-P01', 'Evaluar proactivamente los factores de riesgo de I&T antes de las decisiones empresariales estratégicas pendientes y garantizar que las consideraciones de riesgo sean parte del proceso de decisión empresarial estratégica.', 3, 'Eramba', 'Permite realizar análisis proactivos de riesgo antes de eventos estratégicos o cambios importantes.', 'Soporta ciclos de evaluación periódica y por evento.', '-'),

('EDM03-P01-A06', 'EDM03-P01', 'Evaluar las actividades de gestión de riesgos para garantizar la alineación con la capacidad de la empresa para afrontar pérdidas relacionadas con I&T y la tolerancia del liderazgo al respecto.', 3, 'Open Source Risk Engine', 'Permite cuantificar riesgos financieros con modelos avanzados y evaluar el impacto económico de escenarios de pérdida.', 'Ideal para empresas que requieren análisis financiero profundo del riesgo. Eramba, para vincular con políticas, activos y controles', 'Eramba'),

('EDM03-P01-A07', 'EDM03-P01', 'Atraer y mantener las habilidades y el personal necesarios para la gestión de riesgos de I&T', 3, 'phpBB', 'Se puede usar como portal de discusión, comunidad de práctica y capacitación interna.', 'No es una herramienta de riesgos, pero sirve para documentar buenas prácticas y compartir conocimiento.Eramba, para registrar habilidades, roles y asignaciones por riesgo', 'Eramba'),

('EDM03-P02-A01', 'EDM03-P02', 'Dirigir la traducción e integración de la estrategia de riesgo de I&T en las prácticas de gestión de riesgos y las actividades operativas.', 2, 'Eramba', 'Integra estrategias, políticas y planes de acción de riesgo con procesos operativos mediante controles vinculados.', 'Permite documentar relaciones entre estrategia y operaciones, asignar responsables y monitorear implementación.', '-'),

('EDM03-P02-A02', 'EDM03-P02', 'Dirigir el desarrollo de planes de comunicación de riesgos (que cubran todos los niveles de la empresa).', 2, 'Eramba', 'Permite definir flujos de trabajo, alertas, asignaciones y documentación asociada a la comunicación de riesgos.', 'Ofrece visibilidad de procesos de comunicación y escalamiento.', '-'),

('EDM03-P02-A03', 'EDM03-P02', 'Implementación directa de los mecanismos apropiados para responder rápidamente a los riesgos cambiantes e informar inmediatamente a los niveles apropiados de gestión, respaldados por principios acordados de escalada (qué informar, cuándo, dónde y cómo).', 2, 'Eramba', 'Dispone de workflows, políticas y alertas automáticas para riesgos nuevos o cambiantes.', 'Permite definir reglas de escalamiento automáticas por nivel de riesgo.', '-'),

('EDM03-P02-A04', 'EDM03-P02', 'Instruir que cualquier persona pueda identificar y reportar riesgos, oportunidades, problemas e inquietudes a la parte correspondiente en cualquier momento. El riesgo debe gestionarse de acuerdo con las políticas y procedimientos publicados y escalarse a los responsables de la toma de decisiones.', 2, 'phpBB', 'Puede usarse como canal colaborativo para registro libre de preocupaciones o hallazgos por parte del personal.', 'Necesita integración con un flujo de gestión formal. Eramba, para la gestión formal de los reportes recibidos', 'Eramba'),

('EDM03-P02-A05', 'EDM03-P02', 'Identificar los objetivos y métricas clave de los procesos de gobernanza y gestión de riesgos que se monitorearán, y aprobar los enfoques, métodos, técnicas y procesos para capturar y reportar la información de medición.', 3, 'Zabbix', 'Permite definir KPIs y monitorear métricas en tiempo real asociadas a infraestructura crítica.', 'Ideal para métricas técnicas; necesita complementar con visión de gobernanza. Eramba, para registrar métricas estratégicas y decisiones de gestión', 'Eramba'),

('EDM03-P03-A01', 'EDM03-P03', 'Informar sobre cualquier problema de gestión de riesgos a la junta directiva o al comité ejecutivo.', 2, 'Znuny', 'Permite la generación de reportes personalizados y el envío automático de notificaciones sobre incidentes o problemas de riesgo.', 'Se requiere configuración de flujos y reportes', 'No necesaria'),

('EDM03-P03-A02', 'EDM03-P03', 'Supervisar hasta qué punto el perfil de riesgo se gestiona dentro de los umbrales de tolerancia y apetito de riesgo de la empresa.', 3, 'Open Source Risk Engine', 'Permite modelar y monitorear perfiles de riesgo, definir métricas, escenarios y analizar exposiciones.', 'Alta especialización en riesgos financieros y cuantitativos', 'No necesaria'),

('EDM03-P03-A03', 'EDM03-P03', 'Monitorear los objetivos y métricas clave de los procesos de gobernanza y gestión de riesgos en relación con los objetivos, analizar la causa de cualquier desviación e iniciar acciones correctivas para abordar las causas subyacentes.', 4, 'Collabtive', 'Permite gestionar objetivos, tareas y métricas asociadas a proyectos o procesos, con seguimiento de avance.', 'No es específico de riesgos, pero adaptable con buena documentación.', 'Puede integrarse con soluciones de BI como Metabase'),

('EDM03-P03-A04', 'EDM03-P03', 'Permitir que las partes interesadas clave revisen el progreso de la empresa hacia los objetivos identificados.', 4, 'Collabtive', 'Proporciona paneles de seguimiento de tareas y reportes visuales accesibles por usuarios autorizados.', 'Interface web intuitiva para stakeholders', 'Puede usarse junto con Nextcloud para compartir reportes'),

('EDM04-P01-A01', 'EDM04-P01', 'A partir de las estrategias actuales y futuras, examinar las opciones potenciales para proporcionar recursos relacionados con I&T (tecnología, recursos financieros y humanos) y desarrollar capacidades para satisfacer las necesidades actuales y futuras (incluidas las opciones de abastecimiento).', 2, 'Archi', 'Permite modelar estrategias de arquitectura empresarial, incluyendo capacidades futuras, abastecimiento y análisis de opciones tecnológicas y de negocio.', 'Cumple con enfoque estructurado usando ArchiMate', 'No necesaria'),

('EDM04-P01-A02', 'EDM04-P01', 'Definir los principios clave para la asignación y gestión de recursos y capacidades, de modo que I&T pueda satisfacer las necesidades de la empresa según las prioridades acordadas y las limitaciones presupuestarias. Por ejemplo, definir las opciones de abastecimiento preferidas para ciertos servicios y los límites financieros para cada opción.', 2, 'Archi', 'Archi permite documentar principios de gestión, asignación de recursos y capacidades usando vistas estructuradas por capas y relaciones.', 'Puede representarse gráficamente con trazabilidad completa', 'No necesaria'),

('EDM04-P01-A03', 'EDM04-P01', 'Revisar y aprobar el plan de recursos y las estrategias de arquitectura empresarial para entregar valor y mitigar el riesgo con los recursos asignados.', 2, 'Archi', 'Archi permite representar planes de recursos y verificar la alineación con estrategia, capacidades, procesos y riesgos empresariales.', 'Puede exportarse a formatos revisables para aprobación', 'No necesaria'),

('EDM04-P01-A04', 'EDM04-P01', 'Comprender los requisitos para alinear la gestión de recursos de I&T con la planificación financiera y de recursos humanos (RR.HH.) de la empresa.', 2, 'Collabtive', 'Permite planificar recursos humanos y tareas, asignar presupuestos y visualizar cronogramas, aunque no está centrado en TI.', 'Funcionalidad general, requiere adaptaciones para TI', 'Puede integrarse con herramientas contables o ERP'),

('EDM04-P01-A05', 'EDM04-P01', 'Definir principios para la gestión y control de la arquitectura empresarial.', 3, 'Archi', 'Permite definir principios, vistas y reglas para controlar la arquitectura empresarial, según marcos como TOGAF o ArchiMate.', 'Documentación formal compatible con buenas prácticas', 'No necesaria'),

('EDM04-P02-A01', 'EDM04-P02', 'Asignar responsabilidades para ejecutar la gestión de recursos.', 2, 'Collabtive', 'Permite asignar tareas, responsables, fechas y seguimiento de cumplimiento, facilitando la ejecución operativa de gestión de recursos.', 'Adecuado para asignar responsabilidades de forma sencilla.', 'No necesaria'),

('EDM04-P02-A02', 'EDM04-P02', 'Establecer principios relacionados con la salvaguarda de los recursos.', 2, 'Archi', 'Permite documentar principios de arquitectura relacionados con seguridad, gestión de activos y salvaguarda de recursos usando vistas formales.', 'Permite estructurar y vincular principios con capacidades y procesos.', 'No necesaria'),

('EDM04-P02-A03', 'EDM04-P02', 'Comunicar e impulsar la adopción de las estrategias de gestión de recursos, los principios y el plan de recursos acordado y las estrategias de arquitectura empresarial.', 3, 'Archi', 'Facilita la documentación estructurada y visual de estrategias, arquitecturas y planes que pueden ser compartidos y revisados por los actores involucrados.', 'Puede generar documentación formal para socialización.', 'No necesaria'),

('EDM04-P02-A04', 'EDM04-P02', 'Alinear la gestión de recursos con la planificación financiera y de recursos humanos de la empresa.', 3, 'Collabtive', 'Permite programar recursos humanos y registrar tiempos, lo cual se puede usar para alinearse con proyecciones financieras y capacidades de RR.HH.', 'Puede ser complementado con sistemas financieros para integración completa.', 'Integrable con herramientas externas (ERP)'),

('EDM04-P02-A05', 'EDM04-P02', 'Definir objetivos, medidas y métricas clave para la gestión de recursos.', 4, 'Archi', 'Permite establecer objetivos, relacionarlos con recursos, procesos y principios. Compatible con modelado de métricas en vistas personalizadas.', 'Documentación útil para auditorías y revisión de cumplimiento.', 'No necesaria'),

('EDM04-P03-A01', 'EDM04-P03', 'Monitorear la asignación y optimización de recursos de acuerdo con los objetivos y prioridades de la empresa utilizando metas y métricas acordadas.', 4, 'Zabbix', 'Permite monitorear el uso de recursos de TI (CPU, memoria, red, etc.), establecer umbrales y alertas, y comparar contra metas y KPIs definidos.', 'Requiere parametrización específica para alinearse con prioridades empresariales.', 'Puede integrarse con GLPI o Grafana'),

('EDM04-P03-A02', 'EDM04-P03', 'Supervisar las estrategias de abastecimiento relacionadas con I&T, las estrategias de arquitectura empresarial y las capacidades y recursos relacionados con el negocio y la TI para garantizar que se puedan satisfacer las necesidades y los objetivos actuales y futuros de la empresa.', 4, 'Archi', 'Permite visualizar y supervisar las estrategias de arquitectura empresarial y abastecimiento con sus relaciones hacia capacidades y recursos.', 'Documentación visual útil para revisión ejecutiva y supervisión estratégica.', 'No necesaria'),

('EDM04-P03-A03', 'EDM04-P03', 'Supervisar el rendimiento de los recursos en relación con los objetivos, analizar la causa de las desviaciones e iniciar acciones correctivas para abordar las causas subyacentes.', 4, 'Zabbix', 'Permite seguimiento detallado del rendimiento de recursos con alertas configurables y generación de reportes para análisis de desviaciones.', 'Las acciones correctivas deben ser manuales o integradas con otras herramientas como GLPI o scripts.', 'Integrable con GLPI, Grafana, scripts'),

('EDM05-P01-A01', 'EDM05-P01', 'Identifique a todas las partes interesadas relevantes de I&T, tanto dentro como fuera de la empresa. Agrupe a las partes interesadas en categorías con requisitos similares.', 2, 'Collabtive', 'Permite registrar usuarios y colaboradores, clasificarlos por grupos de trabajo o categorías, asignar proyectos y roles según su interés o responsabilidad.', 'No es un sistema especializado en gobierno, pero permite estructurar grupos de interés según proyectos.', 'No requerida'),

('EDM05-P01-A02', 'EDM05-P01', 'Examinar y emitir un juicio sobre los requisitos de información obligatoria actuales y futuros relacionados con el uso de I&T dentro de la empresa (reglamentación, legislación, derecho consuetudinario, contractual), incluidos el alcance y la frecuencia.', 2, 'Collabtive', 'Perrmite centralizar documentos normativos y legales en repositorios de proyectos, facilitando su acceso al equipo de gobierno de TI. La herramienta soporta compartición de archivos, comentarios y control de versiones básicos, lo que permite discutir, analizar y emitir juicios colectivos sobre el cumplimiento regulatorio.', 'Collabtive no ofrece módulos especializados de compliance o análisis legal, pero sirve como soporte colaborativo para revisión conjunta y registro de acuerdos relacionados con requisitos regulatorios.', 'No requerida'),

('EDM05-P01-A03', 'EDM05-P01', 'Examinar y emitir un juicio sobre los requisitos actuales y futuros de comunicación e informes para otras partes interesadas en relación con el uso de I&T dentro de la empresa, incluido el nivel requerido de participación/consulta y el alcance de la comunicación/nivel de detalle y las condiciones.', 2, 'Collabtive', 'Collabtive soporta la comunicación estructurada entre las partes interesadas mediante foros, mensajes internos, comentarios en tareas y la posibilidad de adjuntar documentos. Se pueden definir niveles de visibilidad por usuario o rol, lo que permite adaptar la participación de stakeholders internos.', 'No cuenta con un sistema avanzado de reporting corporativo, pero puede servir para documentar y compartir decisiones, informes en archivos adjuntos y discusiones registradas. Requiere complementar con otra herramienta de reporting para mayor robustez.', '-'),

('EDM05-P01-A04', 'EDM05-P01', 'Mantener principios para la comunicación con las partes interesadas externas e internas, incluidos los formatos y canales de comunicación, y para la aceptación y aprobación de los informes por parte de las partes interesadas.', 3, 'Znuny', 'Permite configurar flujos de comunicación, plantillas, respuestas automáticas y gestionar formatos y canales de atención a usuarios o partes interesadas.', 'Se debe adaptar a contextos no técnicos para comunicación empresarial o con stakeholders.', 'Integrable con CRM o correo electrónico'),

('EDM05-P02-A01', 'EDM05-P02', 'Dirigir el establecimiento de la estrategia de consulta y comunicación para los grupos de interés externos e internos.', 2, 'Collabtive', 'Permite establecer canales de comunicación internos entre usuarios y asignar responsables por proyecto, útil para estructurar una estrategia de consulta básica.', 'Funcionalidad limitada a proyectos; no permite diseñar estrategias formales de consulta complejas.', 'No requerida'),

('EDM05-P02-A02', 'EDM05-P02', 'Dirigir la implementación de mecanismos para garantizar que la información cumpla con todos los criterios para los requisitos obligatorios de informes de I&T para la empresa.', 2, 'Znuny', 'Znuny ofrece gestión de tickets con reglas de negocio, flujos de aprobación y trazabilidad, lo que permite estructurar mecanismos formales para asegurar que los reportes obligatorios cumplan con criterios definidos (regulatorios, contractuales o internos). Esto da mayor robustez frente a auditorías.', 'Se adapta mejor a entornos donde los informes deben cumplir criterios obligatorios y auditables, lo cual hace más apropiado su uso para esta actividad.', 'No requerida'),

('EDM05-P02-A03', 'EDM05-P02', 'Establecer mecanismos de validación y aprobación de los informes obligatorios.', 2, 'Znuny', 'Permite configurar flujos de aprobación mediante tickets, asignación jerárquica y seguimiento de cambios en las comunicaciones o informes gestionados por el sistema.', 'Puede adaptarse como sistema de validación por flujo de trabajo.', 'Integración con LDAP o gestores documentales'),

('EDM05-P02-A04', 'EDM05-P02', 'Establecer mecanismos de escalamiento de informes.', 3, 'Znuny', 'Soporta reglas de escalamiento automatizadas, reenvío de tickets y alertas según tiempos de espera o criticidad del informe.', 'Requiere configuración avanzada para informes no técnicos.', 'Integración con correo, SLA, notificaciones'),

('EDM05-P03-A01', 'EDM05-P03', 'Evaluar periódicamente la eficacia de los mecanismos para garantizar la exactitud y fiabilidad de los informes obligatorios.', 4, 'Znuny', 'Znuny permite recolectar evidencias del proceso de generación de reportes, establecer métricas (KPIs) y automatizar evaluaciones periódicas mediante reportes internos. Esto facilita analizar si los mecanismos realmente garantizan exactitud y fiabilidad.', 'Znuny resultaadecuado porque aporta trazabilidad, auditoría y la capacidad de evaluar periódicamente la eficacia de los mecanismos implementados.', 'No requerida'),

('EDM05-P03-A02', 'EDM05-P03', 'Evaluar periódicamente la eficacia de los mecanismos y los resultados de la participación y la comunicación con las partes interesadas externas e internas.', 4, 'Collabtive', 'Permite seguimiento de tareas y mensajes en proyectos, útil para observar interacciones y colaboración entre stakeholders.', 'Evaluación subjetiva; no hay módulo de análisis formal de participación.', 'No requerida'),

('EDM05-P03-A03', 'EDM05-P03', 'Determinar si se cumplen los requisitos de las diferentes partes interesadas y evaluar los niveles de participación de las partes interesadas.', 4, 'Znuny', 'Permite levantar y dar seguimiento a solicitudes, preguntas y reclamos mediante tickets, lo cual puede asociarse al cumplimiento de requerimientos de stakeholders.', 'Requiere personalización para categorizar partes interesadas y seguimiento por tipo de requerimiento.', 'Integración con base de datos o CRM externo');
