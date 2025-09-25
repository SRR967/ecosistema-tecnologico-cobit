# Guía de Usuario - Ecosistema Tecnológico COBIT 2019

## Introducción

El Ecosistema Tecnológico para la implementación de hojas de ruta de COBIT 2019 es una aplicación web desarrollada como prototipo académico que materializa el diseño de un entorno integrado que conecta los Objetivos de Gobierno y Gestión (OGG) de COBIT 2019 con herramientas de TI específicas que facilitan su implementación práctica.

## Arquitectura de la Aplicación

La aplicación está construida siguiendo el patrón de diseño atómico, organizando los componentes en tres niveles jerárquicos:

### Componentes Atómicos (Atoms)

- **CapabilityLevelSelect**: Selector para niveles de capacidad COBIT
- **CobitObjectiveCard**: Tarjeta individual de objetivos COBIT
- **FilterSelect**: Componente base para filtros
- **Logo**: Componente del logotipo de la aplicación
- **MultiSelect**: Selector múltiple genérico
- **NavButton**: Botón de navegación
- **SelectionInfo**: Información de elementos seleccionados
- **SmartFilterSelect**: Selector inteligente con filtrado dinámico
- **ToggleButtonGroup**: Grupo de botones de alternancia
- **ToggleSwitch**: Interruptor de alternancia

### Componentes Moleculares (Molecules)

- **CapabilityModal**: Modal para selección de niveles de capacidad
- **DomainSection**: Sección de dominios COBIT
- **FilterSidebar**: Barra lateral de filtros
- **InfoSection**: Sección de información
- **NavMenu**: Menú de navegación
- **NodeDetailModal**: Modal de detalles de nodos
- **SelectedObjectivesBar**: Barra de objetivos seleccionados
- **TeamCard**: Tarjeta de información del equipo
- **ToolSummaryPills**: Píldoras resumen de herramientas

### Componentes Organizacionales (Organisms)

- **CobitBoard**: Tablero principal de objetivos COBIT
- **CobitGraph**: Visualización gráfica de relaciones
- **CobitTable**: Tabla detallada de datos
- **HeroSection**: Sección hero de la página principal
- **NavBar**: Barra de navegación principal

## Vistas y Funcionalidades

### 1. Página de Inicio (/)

**Componentes principales:**

- NavBar
- HeroSection
- InfoSection (múltiples)
- TeamCard

**Funcionalidades:**

- Presentación del ecosistema tecnológico
- Explicación del propósito del proyecto
- Información sobre la aplicación
- Detalles del equipo de desarrollo
- Navegación a otras secciones

**Contenido:**

- Descripción del ecosistema tecnológico COBIT 2019
- Propósito y objetivos del proyecto
- Información académica del equipo
- Enlaces de navegación

### 2. Vista de Ecosistema (/ecosistema)

**Componentes principales:**

- NavBar
- FilterSidebar
- CobitTable (vista lista)
- CobitGraph (vista gráfica)

**Funcionalidades:**

#### Filtrado Avanzado

- **Filtro por Dominio**: EDM, APO, BAI, DSS, MEA
- **Filtro por Objetivo**: Selección múltiple de objetivos específicos
- **Filtro por Herramienta**: Filtrado por herramientas de TI
- **Filtrado Dinámico**: Los filtros se actualizan automáticamente según las selecciones

#### Modos de Visualización

- **Vista Gráfica**: Visualización de red con nodos y conexiones
- **Vista Lista**: Tabla detallada con información estructurada

#### Funcionalidades Específicas de la Vista Gráfica

- Visualización interactiva de relaciones objetivo-herramienta
- Zoom y pan en el gráfico
- Tooltips informativos al pasar el mouse
- Modal de detalles al hacer clic en nodos
- Centrado automático en nodos seleccionados
- Imágenes de herramientas integradas

#### Funcionalidades Específicas de la Vista Lista

- Tabla paginada con 10 elementos por página
- Ordenamiento por cualquier columna
- Búsqueda en tiempo real
- Exportación a PDF
- Resumen de herramientas con contadores
- Información detallada de cada fila

#### Información Mostrada en la Tabla

- **Objetivo**: ID y nombre del objetivo COBIT
- **Práctica**: ID y nombre de la práctica
- **Actividad**: ID y descripción de la actividad
- **Nivel de Capacidad**: Nivel requerido (1-5)
- **Herramienta**: ID, nombre y categoría de la herramienta
- **Justificación**: Razón de la relación objetivo-herramienta
- **Observaciones**: Notas adicionales
- **Integración**: Información sobre integración con otras herramientas

### 3. Vista de Creación de Ecosistema (/crear)

**Componentes principales:**

- NavBar
- CobitBoard
- CapabilityModal
- SelectedObjectivesBar
- FilterSidebar (en modo ecosistema creado)
- CobitTable/CobitGraph (en modo ecosistema creado)

**Funcionalidades:**

#### Fase 1: Selección de Objetivos

- **Tablero COBIT**: Visualización completa de todos los dominios y objetivos
- **Selección Interactiva**: Clic en objetivos para seleccionarlos
- **Modal de Nivel de Capacidad**: Selección del nivel requerido (1-5)
- **Barra de Objetivos Seleccionados**: Resumen de selecciones
- **Creación de Ecosistema**: Generación del ecosistema personalizado

#### Fase 2: Visualización del Ecosistema Creado

- **Modo Específico**: Filtrado automático por objetivos seleccionados
- **Filtros Dinámicos**: Herramientas filtradas según objetivos
- **Vista Dual**: Alternancia entre gráfico y tabla
- **Exportación**: Generación de PDF del ecosistema personalizado
- **Navegación**: Retorno a selección de objetivos

#### Layout del Tablero COBIT

- **EDM**: Fila superior completa (5 objetivos)
- **APO**: Segunda fila (14 objetivos en 2 sub-filas)
- **BAI**: Tercera fila (11 objetivos)
- **DSS**: Cuarta fila (6 objetivos)
- **MEA**: Columna vertical derecha (3 objetivos)

## Características Técnicas

### Sistema de Filtrado

- **Filtrado Dinámico**: Los filtros se actualizan automáticamente
- **Filtrado Selectivo**: Solo se cargan opciones relevantes
- **Persistencia**: Los filtros se mantienen durante la sesión
- **Limpieza**: Función para resetear todos los filtros

### Visualización de Datos

- **Gráfico Interactivo**: Implementado con D3.js
- **Tabla Paginada**: Navegación eficiente de grandes datasets
- **Búsqueda Global**: Búsqueda en todos los campos de la tabla
- **Ordenamiento**: Ordenamiento ascendente/descendente por columna

### Exportación

- **PDF**: Generación de reportes en formato PDF
- **Datos Filtrados**: Exportación solo de datos visibles
- **Metadatos**: Inclusión de filtros aplicados y objetivos seleccionados

### Responsive Design

- **Adaptativo**: Funciona en diferentes tamaños de pantalla
- **Sidebar Colapsible**: Menú hamburguesa en dispositivos móviles
- **Optimización**: Carga eficiente de datos según el dispositivo

## Flujo de Usuario Típico

### Para Exploración General

1. Acceder a la página de inicio para entender el proyecto
2. Navegar a "Ecosistema" para explorar datos
3. Usar filtros para refinar la búsqueda
4. Alternar entre vista gráfica y lista
5. Exportar resultados si es necesario

### Para Creación de Ecosistema Personalizado

1. Navegar a "Crear tu Ecosistema"
2. Seleccionar objetivos relevantes del tablero COBIT
3. Especificar niveles de capacidad para cada objetivo
4. Crear el ecosistema personalizado
5. Explorar el ecosistema generado
6. Exportar el ecosistema como PDF

## Consideraciones de Usabilidad

### Navegación

- **Breadcrumbs**: Indicación clara de la ubicación actual
- **Estados Activos**: Resaltado de la sección actual
- **Enlaces Directos**: Navegación rápida entre secciones

### Feedback Visual

- **Estados de Carga**: Indicadores durante operaciones
- **Mensajes de Error**: Información clara sobre problemas
- **Confirmaciones**: Feedback para acciones importantes

### Accesibilidad

- **Contraste**: Colores COBIT con buen contraste
- **Navegación por Teclado**: Soporte para navegación sin mouse
- **Tooltips**: Información adicional disponible

## Conclusión

Esta aplicación web constituye un prototipo académico que demuestra la viabilidad de traducir los lineamientos estratégicos de COBIT 2019 en soluciones digitales interactivas y comprensibles. A través de sus diferentes módulos, permite gestionar hojas de ruta personalizadas, visualizar relaciones entre objetivos y herramientas, y analizar de manera detallada cómo las actividades descritas en COBIT 2019 pueden ser respaldadas con tecnologías específicas.

El diseño modular basado en el patrón atómico facilita el mantenimiento y la extensión de la aplicación, mientras que las funcionalidades de filtrado, visualización y exportación proporcionan una experiencia de usuario completa para la exploración y análisis del ecosistema tecnológico COBIT.

