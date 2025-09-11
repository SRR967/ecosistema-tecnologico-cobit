"use client";

import { useEffect, useRef } from "react";
import * as d3 from "d3";
import {
  useCobitGraph,
  GraphFilters,
  SelectedObjective,
  GrafoNode,
  GrafoLink,
} from "../../hooks/useCobitGraph";
import { D3SimulationNode, D3SimulationLink } from "../../types/database";

interface CobitGraphProps {
  filters: GraphFilters;
  selectedObjectives?: SelectedObjective[];
  className?: string;
}

// Función para mapear ID de herramienta con nombre de imagen
function getImageName(toolId: string): string {
  // Mapeo de IDs de herramientas con nombres de archivos (exactos)
  const imageMap: { [key: string]: string } = {
    Alfresco: "Alfresco.png",
    Anaconda: "Anaconda.png",
    Ansible: "Ansible.png",
    "Apache Dubbo": "Apache Dubbo.png",
    "Apache Hive": "Apache Hive.png",
    "Apache JMeter": "Apache JMeter.png",
    "Apache OFBiz": "Apache OFBiz.png",
    "Apache Open": "Apache Open.png",
    Archi: "Archi.png",
    Collabtive: "Collabtive.png",
    Eramba: "Eramba.png",
    GitHub: "GitHub.png",
    GLPI: "GLPI.png",
    GPG: "GPG.png",
    Grafana: "Grafana.png",
    HAProxy: "HAProxy.png",
    Huggin: "Huggin.png",
    Issabel: "Issabel.png",
    iTop: "iTop.png",
    JFire: "JFire.png",
    "Kali Linux": "Kali Linux.png",
    MantisBT: "MantisBT.png",
    Moodle: "Moodle.png",
    MySQL: "MySQL.png",
    "Open Audit": "Open Audit.png",
    "Open Source Risk Engine": "Open Source Risk Engine.png",
    OpenScap: "OpenScap.png",
    OpenSSH: "OpenSSH.png",
    OrangeHRM: "OrangeHRM.png",
    "OWASP zap": "OWASP zap.png",
    pfSense: "pfSense.png",
    phpBB: "phpBB.png",
    "Proxmox Mail Gateway": "Proxmox Mail Gateway.png",
    Proxmox: "Proxmox.png",
    Ralph: "Ralph.png",
    "Rocket Chat": "Rocket Chat.png",
    SnipeIT: "SnipeIT.png",
    Snort: "Snort.png",
    "Tactical RMM": "Tactical RMM.png",
    Wazuh: "Wazuh.png",
    WireShark: "WireShark.png",
    Zabbix: "Zabbix.png",
    Zammad: "Zammad.png",
    Znuny: "Znuny.png",
  };

  // Buscar imagen exacta primero
  if (imageMap[toolId]) {
    return imageMap[toolId];
  }

  // Fallback: buscar por coincidencia parcial
  const keys = Object.keys(imageMap);
  const partialMatch = keys.find(
    (key) =>
      key.toLowerCase().includes(toolId.toLowerCase()) ||
      toolId.toLowerCase().includes(key.toLowerCase())
  );

  if (partialMatch) {
    return imageMap[partialMatch];
  }

  // Si no encontramos nada, intentar con el nombre + .png directamente
  return `${toolId}.png`;
}

export default function CobitGraph({
  filters,
  selectedObjectives,
  className = "",
}: CobitGraphProps) {
  const { data, loading, error } = useCobitGraph(filters, selectedObjectives);
  const svgRef = useRef<SVGSVGElement>(null);
  const zoomRef = useRef<d3.ZoomBehavior<SVGSVGElement, unknown> | null>(null);

  useEffect(() => {
    if (!data.nodes.length || !svgRef.current) return;

    // Variable para rastrear el nodo seleccionado
    let selectedNodeId: string | null = null;

    // Limpiar SVG anterior
    d3.select(svgRef.current).selectAll("*").remove();

    const svg = d3.select(svgRef.current);
    const width = 860;
    const height = 600;

    svg.attr("width", width).attr("height", height);

    // Crear defs para patrones de imágenes
    svg.append("defs");

    // Crear grupo principal con zoom
    const g = svg.append("g");

    // Configurar zoom
    const zoom = d3
      .zoom<SVGSVGElement, unknown>()
      .scaleExtent([0.1, 4])
      .on("zoom", (event) => {
        g.attr("transform", event.transform);
      });

    // Guardar referencia al zoom
    zoomRef.current = zoom;
    svg.call(zoom);

    // Evento para resetear selección al hacer clic en el fondo
    svg.on("click", function (event: MouseEvent) {
      const target = event.target as SVGElement;
      if (target === event.currentTarget || target.tagName === "svg") {
        selectedNodeId = null;
      }
    });

    // 📊 Sistema de Escalado Dinámico para Herramientas - CALCULAR PRIMERO
    function calculateToolSizes() {
      const connectionCounts = new Map<string, number>();

      // Calcular conexiones para cada herramienta
      data.links.forEach((link) => {
        const sourceId = link.source as string;
        const targetId = link.target as string;

        // Identificar qué nodo es herramienta y cuál es objetivo
        const sourceNode = data.nodes.find((n: GrafoNode) => n.id === sourceId);
        const targetNode = data.nodes.find((n: GrafoNode) => n.id === targetId);

        if (sourceNode?.type === "herramienta") {
          connectionCounts.set(
            sourceId,
            (connectionCounts.get(sourceId) || 0) + 1
          );
        }
        if (targetNode?.type === "herramienta") {
          connectionCounts.set(
            targetId,
            (connectionCounts.get(targetId) || 0) + 1
          );
        }
      });

      return connectionCounts;
    }

    // Calcular tamaños de herramientas basado en conectividad
    const toolConnectionCounts = calculateToolSizes();

    // 🎯 Función para obtener el tamaño dinámico de una herramienta
    function getToolNodeSize(toolId: string): number {
      const connections = toolConnectionCounts.get(toolId) || 0;

      // Escala de tamaño: 20px (base = objetivos) a 35px (máximo)
      const baseSize = 20; // Mismo tamaño base que los objetivos
      const maxSize = 35;
      const maxConnections = Math.max(
        ...Array.from(toolConnectionCounts.values())
      );

      if (maxConnections === 0) return baseSize;

      // Escalado proporcional desde el tamaño base
      const sizeRange = maxSize - baseSize;
      const connectionRatio = connections / maxConnections;
      const calculatedSize = baseSize + sizeRange * connectionRatio;

      return Math.max(baseSize, Math.min(maxSize, calculatedSize));
    }

    // Calcular tamaños de nodos de herramientas basado en conectividad
    // const sortedTools = Array.from(toolConnectionCounts.entries())
    //   .sort((a, b) => b[1] - a[1])
    //   .slice(0, 10); // Top 10

    // Configurar simulación de fuerzas
    const simulation = d3
      .forceSimulation(data.nodes as D3SimulationNode[])
      .force(
        "link",
        d3
          .forceLink(data.links)
          .id((d) => (d as D3SimulationNode).id)
          .distance(100)
      )
      .force("charge", d3.forceManyBody().strength(-300))
      .force("center", d3.forceCenter(width / 2, height / 2))
      .force(
        "collision",
        d3.forceCollide().radius((d) => {
          const node = d as D3SimulationNode;
          if (node.type === "herramienta") {
            return getToolNodeSize(node.id) + 5; // Radio dinámico + padding
          }
          return 25; // Radio fijo para objetivos (20 + padding)
        })
      );

    // Crear enlaces
    const link = g
      .append("g")
      .attr("class", "links")
      .selectAll("line")
      .data(data.links)
      .enter()
      .append("line")
      .attr("stroke", "#000000")
      .attr("stroke-opacity", 0.8)
      .attr("stroke-width", 2);

    // Crear nodos
    const node = g
      .append("g")
      .attr("class", "nodes")
      .selectAll("g")
      .data(data.nodes)
      .enter()
      .append("g")
      .attr("class", "node")
      .call(
        d3
          .drag<SVGGElement, D3SimulationNode>()
          .on("start", dragstarted)
          .on("drag", dragged)
          .on("end", dragended)
      );

    // Nodos diferenciados: círculos para objetivos, imágenes para herramientas
    node.each(function (d: GrafoNode) {
      const nodeElement = d3.select(this);

      if (d.type === "objetivo") {
        // Círculo para objetivos
        nodeElement
          .append("circle")
          .attr("r", 20)
          .attr("fill", "var(--cobit-blue)")
          .attr("stroke", "#fff")
          .attr("stroke-width", 2);
      } else {
        // Imagen para herramientas - Usando patrón con imagen de fondo
        const imageName = getImageName(d.id);

        // Crear definición de patrón único para esta imagen
        const patternId = `pattern-${d.id.replace(/\s+/g, "-")}`;

        // Usar el defs ya existente
        const existingDefs = svg.select("defs");

        // Calcular tamaño dinámico de la herramienta
        const toolSize = getToolNodeSize(d.id);

        // Solución simple y efectiva: patrón básico con imagen escalada
        const pattern = existingDefs
          .append("pattern")
          .attr("id", patternId)
          .attr("patternUnits", "userSpaceOnUse")
          .attr("width", toolSize * 2)
          .attr("height", toolSize * 2)
          .attr("x", -toolSize)
          .attr("y", -toolSize);

        // Imagen centrada que llena el patrón
        pattern
          .append("image")
          .attr("href", `/herramientas/${imageName}`)
          .attr("x", 0)
          .attr("y", 0)
          .attr("width", toolSize * 2)
          .attr("height", toolSize * 2)
          .attr("preserveAspectRatio", "xMidYMid slice");

        // Círculo que usa el patrón (automáticamente recortado por el círculo)
        nodeElement
          .append("circle")
          .attr("r", toolSize)
          .attr("fill", `url(#${patternId})`)
          .attr("stroke", "#fff")
          .attr("stroke-width", 2)
          .style("cursor", "pointer");
      }
    });

    // Etiquetas de nodos
    node
      .append("text")
      .text((d: GrafoNode) => d.id)
      .attr("font-size", "10px")
      .attr("dx", 25)
      .attr("dy", 4)
      .attr("fill", "#333");

    // Tooltip
    const tooltip = d3
      .select("body")
      .append("div")
      .attr("class", "tooltip")
      .style("opacity", 0)
      .style("position", "absolute")
      .style("background", "rgba(0, 0, 0, 0.8)")
      .style("color", "white")
      .style("padding", "8px")
      .style("border-radius", "4px")
      .style("font-size", "12px")
      .style("pointer-events", "none")
      .style("z-index", "1000");

    // Eventos de tooltip para nodos
    node
      .on("mouseover", function (event: MouseEvent, d: GrafoNode) {
        tooltip.transition().duration(200).style("opacity", 0.9);
        let content = "";

        if (d.type === "objetivo") {
          content = `<strong>${d.id}</strong><br/>${d.name}<br/>Dominio: ${d.domain}`;
        } else {
          // Tooltip simplificado para herramientas
          content = `<strong>${d.id}</strong><br/>`;
          if (d.category) content += `Categoría: ${d.category}<br/>`;
          if (d.toolType) content += `Tipo: ${d.toolType}`;
        }

        tooltip
          .html(content)
          .style("left", event.pageX + 10 + "px")
          .style("top", event.pageY - 28 + "px");
      })
      .on("mouseout", function () {
        tooltip.transition().duration(500).style("opacity", 0);
      })
      .on("click", function (event: MouseEvent, d: GrafoNode) {
        event.stopPropagation();

        // Click simple en nodos (funcionalidad de highlight removida)
        if (selectedNodeId === d.id) {
          selectedNodeId = null;
        } else {
          selectedNodeId = d.id;
        }
      });

    // Eventos de tooltip para enlaces
    link
      .on("mouseover", function (event: MouseEvent, d: D3SimulationLink) {
        tooltip.transition().duration(200).style("opacity", 0.9);
        const source = typeof d.source === "string" ? d.source : d.source.id;
        const target = typeof d.target === "string" ? d.target : d.target.id;
        tooltip
          .html(
            `<strong>${source} → ${target}</strong><br/>${d.count} actividades`
          )
          .style("left", event.pageX + 10 + "px")
          .style("top", event.pageY - 28 + "px");
      })
      .on("mouseout", function () {
        tooltip.transition().duration(500).style("opacity", 0);
      });

    // Actualizar posiciones en cada tick
    simulation.on("tick", () => {
      link
        .attr(
          "x1",
          (d: D3SimulationLink) => (d.source as D3SimulationNode).x || 0
        )
        .attr(
          "y1",
          (d: D3SimulationLink) => (d.source as D3SimulationNode).y || 0
        )
        .attr(
          "x2",
          (d: D3SimulationLink) => (d.target as D3SimulationNode).x || 0
        )
        .attr(
          "y2",
          (d: D3SimulationLink) => (d.target as D3SimulationNode).y || 0
        );

      node.attr(
        "transform",
        (d: D3SimulationNode) => `translate(${d.x || 0},${d.y || 0})`
      );
    });

    // Funciones de drag
    function dragstarted(
      event: d3.D3DragEvent<SVGGElement, D3SimulationNode, D3SimulationNode>,
      d: D3SimulationNode
    ) {
      if (!event.active) simulation.alphaTarget(0.3).restart();
      d.fx = d.x;
      d.fy = d.y;
    }

    function dragged(
      event: d3.D3DragEvent<SVGGElement, D3SimulationNode, D3SimulationNode>,
      d: D3SimulationNode
    ) {
      d.fx = event.x;
      d.fy = event.y;
    }

    function dragended(
      event: d3.D3DragEvent<SVGGElement, D3SimulationNode, D3SimulationNode>,
      d: D3SimulationNode
    ) {
      if (!event.active) simulation.alphaTarget(0);
      d.fx = null;
      d.fy = null;
    }

    // Función para obtener color por dominio (comentada - no utilizada actualmente)
    // function getDomainColor(domain?: string) {
    //   const colors: { [key: string]: string } = {
    //     EDM: "#ef4444", // rojo
    //     APO: "#3b82f6", // azul
    //     BAI: "#10b981", // verde
    //     DSS: "#f59e0b", // amarillo
    //     MEA: "#8b5cf6", // púrpura
    //   };
    //   return colors[domain || ""] || "#6b7280"; // gris por defecto
    // }

    // Código duplicado eliminado - ya está arriba

    // 🎯 Función setHighlight - Resaltar conexiones con blur
    // Función de highlight eliminada

    // Función de clearHighlight eliminada

    // Cleanup
    return () => {
      tooltip.remove();
    };
  }, [data]);

  // Funciones para manejar zoom programático
  const handleZoomIn = () => {
    if (svgRef.current && zoomRef.current) {
      const svg = d3.select(svgRef.current);
      svg.transition().duration(300).call(zoomRef.current.scaleBy, 1.5);
    }
  };

  const handleZoomOut = () => {
    if (svgRef.current && zoomRef.current) {
      const svg = d3.select(svgRef.current);
      svg.transition().duration(300).call(zoomRef.current.scaleBy, 0.67);
    }
  };

  const handleZoomReset = () => {
    if (svgRef.current && zoomRef.current) {
      const svg = d3.select(svgRef.current);
      svg
        .transition()
        .duration(500)
        .call(zoomRef.current.transform, d3.zoomIdentity);
    }
  };

  // Estado de carga
  if (loading) {
    return (
      <div className={`flex items-center justify-center h-96 ${className}`}>
        <div className="text-center">
          <div
            className="animate-spin rounded-full h-12 w-12 border-b-2 mx-auto mb-4"
            style={{ borderColor: "var(--cobit-blue)" }}
          ></div>
          <h3
            className="text-xl font-bold mb-2"
            style={{ color: "var(--cobit-blue)" }}
          >
            Generando Grafo
          </h3>
          <p className="text-gray-600 b1">
            Analizando relaciones entre objetivos y herramientas...
          </p>
        </div>
      </div>
    );
  }

  // Estado de error
  if (error) {
    return (
      <div className={`flex items-center justify-center h-96 ${className}`}>
        <div className="text-center">
          <div className="text-red-500 text-4xl mb-4">⚠️</div>
          <h3
            className="text-xl font-bold mb-2"
            style={{ color: "var(--cobit-red)" }}
          >
            Error al cargar grafo
          </h3>
          <p className="text-red-600 b1 mb-4">{error}</p>
          <button
            onClick={() => window.location.reload()}
            className="px-6 py-3 rounded-lg font-medium text-white transition-colors"
            style={{ backgroundColor: "var(--cobit-blue)" }}
          >
            Reintentar
          </button>
        </div>
      </div>
    );
  }

  // Sin datos
  if (data.nodes.length === 0) {
    const hasSelectedObjectives =
      selectedObjectives && selectedObjectives.length > 0;
    // const hasTraditionalFilters = filters.dominio || filters.herramienta;
    const isSpecificObjectiveMode = selectedObjectives !== undefined;

    return (
      <div className={`flex items-center justify-center h-96 ${className}`}>
        <div className="text-center">
          <div className="text-gray-400 text-6xl mb-4">🕸️</div>
          <h3
            className="text-xl font-bold mb-2"
            style={{ color: "var(--cobit-blue)" }}
          >
            {isSpecificObjectiveMode && !hasSelectedObjectives
              ? "Selecciona objetivos para visualizar el ecosistema"
              : "No hay relaciones disponibles"}
          </h3>
          <p className="text-gray-600 b1">
            {isSpecificObjectiveMode && !hasSelectedObjectives
              ? "Ve a 'Crear tu Ecosistema' para seleccionar objetivos COBIT con sus niveles de capacidad, o usa los filtros laterales."
              : "Ajusta los filtros para ver las conexiones entre objetivos y herramientas."}
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className={`bg-white rounded-lg border border-gray-200 ${className}`}>
      <div className="relative">
        {/* Botones de Zoom */}
        <div className="absolute right-4 bottom-4 z-10 flex flex-col space-y-2">
          <button
            onClick={handleZoomIn}
            className="w-10 h-10 bg-white border border-gray-300 rounded-lg shadow-md hover:bg-gray-50 transition-colors flex items-center justify-center"
            title="Acercar zoom"
          >
            <svg
              className="w-5 h-5 text-gray-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M12 6v6m0 0v6m0-6h6m-6 0H6"
              />
            </svg>
          </button>

          <button
            onClick={handleZoomOut}
            className="w-10 h-10 bg-white border border-gray-300 rounded-lg shadow-md hover:bg-gray-50 transition-colors flex items-center justify-center"
            title="Alejar zoom"
          >
            <svg
              className="w-5 h-5 text-gray-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M18 12H6"
              />
            </svg>
          </button>

          <button
            onClick={handleZoomReset}
            className="w-10 h-10 bg-white border border-gray-300 rounded-lg shadow-md hover:bg-gray-50 transition-colors flex items-center justify-center"
            title="Restablecer zoom"
          >
            <svg
              className="w-4 h-4 text-gray-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
              />
            </svg>
          </button>
        </div>

        {/* Grafo */}
        <div className="p-2">
          <div className="border border-gray-200 rounded-lg overflow-hidden">
            <svg ref={svgRef} className="w-full bg-gray-50"></svg>
          </div>
        </div>
      </div>
    </div>
  );
}
