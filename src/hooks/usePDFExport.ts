"use client";

import jsPDF from "jspdf";
import { TablaCobitRow } from "./useCobitTable";

// Tipo extendido para jsPDF con autoTable
interface AutoTableOptions {
  head: string[][];
  body: (string | number)[][];
  startY: number;
  styles?: Record<string, unknown>;
  headStyles?: Record<string, unknown>;
  alternateRowStyles?: Record<string, unknown>;
  margin?: Record<string, number>;
  tableWidth?: string | number;
  columnStyles?: Record<number, Record<string, unknown>>;
  pageBreak?: string;
  showHead?: string;
  theme?: string;
  addPageContent?: () => void;
  didParseCell?: (data: { row: { index: number }; cell: { styles: Record<string, unknown> } }) => void;
}

interface jsPDFWithAutoTable extends jsPDF {
  autoTable: (options: AutoTableOptions) => void;
  lastAutoTable: {
    finalY: number;
  };
}

// Importar autoTable dinámicamente para evitar problemas de SSR
let autoTableLoaded = false;

const loadAutoTable = async () => {
  if (!autoTableLoaded && typeof window !== 'undefined') {
    const autoTable = await import("jspdf-autotable");
    autoTableLoaded = true;
    return autoTable.default;
  }
  return null;
};

interface FilterState {
  dominio: string;
  objetivo: string;
  herramienta: string;
}

interface SelectedObjective {
  code: string;
  level: number;
}

interface ExportData {
  tableData: TablaCobitRow[];
  filters: FilterState;
  selectedObjectives?: SelectedObjective[];
  isSpecificMode?: boolean;
}

export function usePDFExport() {
  const generatePDF = async (data: ExportData) => {
    try {
      // Cargar autoTable dinámicamente
      await loadAutoTable();
      
      const { tableData, filters, selectedObjectives = [], isSpecificMode = false } = data;
      
      // Crear nuevo documento PDF
      const doc = new jsPDF() as jsPDFWithAutoTable;
      const pageWidth = doc.internal.pageSize.width;
      const pageHeight = doc.internal.pageSize.height;
      
      // Configurar fuentes
      doc.setFont("helvetica");
      
      // **ENCABEZADO**
      doc.setFontSize(16);
      doc.setFont("helvetica", "bold");
      doc.text("COBIT 2019 - Ecosistema Tecnológico", pageWidth / 2, 20, { align: "center" });
      
      // Fecha y hora
      const now = new Date();
      const dateString = now.toLocaleDateString("es-CO", {
        year: "numeric",
        month: "long",
        day: "numeric",
      });
      const timeString = now.toLocaleTimeString("es-CO", {
        hour: "2-digit",
        minute: "2-digit",
      });
      
      doc.setFontSize(10);
      doc.setFont("helvetica", "normal");
      doc.text(`Generado el ${dateString} a las ${timeString}`, pageWidth / 2, 28, { align: "center" });
      
      let yPosition = 45;
      
      // **TÍTULO PRINCIPAL**
      doc.setFontSize(14);
      doc.setFont("helvetica", "bold");
      doc.text("Reporte del Ecosistema Tecnológico Generado", pageWidth / 2, yPosition, { align: "center" });
      yPosition += 15;
      
      // **INTRODUCCIÓN**
      doc.setFontSize(11);
      doc.setFont("helvetica", "normal");
      const introText = [
        "Este reporte ha sido generado desde la plataforma web desarrollada como parte del proyecto",
        "de grado para la implementación de un ecosistema tecnológico basado en COBIT 2019.",
        "La plataforma permite la selección y análisis de objetivos de gobierno y gestión",
        "corporativa junto con sus respectivas herramientas tecnológicas."
      ];
      
      introText.forEach((line) => {
        doc.text(line, 20, yPosition);
        yPosition += 6;
      });
      yPosition += 10;
      
      // **FILTROS APLICADOS** (COMO TABLA)
      doc.setFontSize(12);
      doc.setFont("helvetica", "bold");
      doc.text("Filtros Aplicados:", 20, yPosition);
      yPosition += 8;
      
      // Preparar datos de filtros para tabla
      const filtrosData = [];
      
      // Modo de operación
      if (isSpecificMode && selectedObjectives.length > 0) {
        filtrosData.push(["Modo", "Objetivos específicos seleccionados"]);
        selectedObjectives.forEach((obj, index) => {
          filtrosData.push([`Objetivo ${index + 1}`, `${obj.code} (Nivel: ${obj.level})`]);
        });
      } else {
        filtrosData.push(["Modo", "Vista general del ecosistema"]);
      }
      
      // Filtros adicionales
      if (filters.dominio) {
        filtrosData.push(["Dominio", filters.dominio]);
      }
      if (filters.objetivo) {
        filtrosData.push(["Objetivo", filters.objetivo]);
      }
      if (filters.herramienta) {
        filtrosData.push(["Herramienta", filters.herramienta]);
      }
      
      if (!filters.dominio && !filters.objetivo && !filters.herramienta && (!isSpecificMode || selectedObjectives.length === 0)) {
        filtrosData.push(["Filtros", "Sin filtros específicos aplicados"]);
      }
      
      // Generar tabla de filtros
      if (typeof doc.autoTable === 'function') {
        doc.autoTable({
          head: [["Tipo de Filtro", "Valor"]],
          body: filtrosData,
          startY: yPosition,
          styles: {
            fontSize: 8,
            cellPadding: 2,
            overflow: 'linebreak',
            cellWidth: 'wrap',
          },
          headStyles: {
            fillColor: [52, 73, 94], // Gris oscuro
            textColor: 255,
            fontStyle: "bold",
          },
          alternateRowStyles: {
            fillColor: [248, 249, 250],
          },
          margin: { left: 10, right: 10, bottom: 50 },
          tableWidth: 'auto',
          columnStyles: {
            0: { cellWidth: 50 },
            1: { cellWidth: 'auto' }
          }
        });
        yPosition = doc.lastAutoTable.finalY + 15;
      } else {
        // Fallback manual para filtros
        doc.setFontSize(9);
        doc.setFont("helvetica", "bold");
        doc.setFillColor(52, 73, 94);
        doc.setTextColor(255, 255, 255);
        doc.rect(20, yPosition - 4, 150, 8, "F");
        doc.text("Tipo de Filtro", 25, yPosition);
        doc.text("Valor", 85, yPosition);
        yPosition += 10;
        
        doc.setFont("helvetica", "normal");
        doc.setTextColor(0, 0, 0);
        filtrosData.forEach((row, index) => {
          if (index % 2 === 1) {
            doc.setFillColor(248, 249, 250);
            doc.rect(20, yPosition - 4, 150, 6, "F");
          }
          doc.text(row[0], 25, yPosition);
          doc.text(row[1], 85, yPosition);
          yPosition += 6;
        });
        yPosition += 15;
      }
      
      // **MAPA DE COBERTURA POR HERRAMIENTA** (COMO TABLA)
      doc.setFontSize(12);
      doc.setFont("helvetica", "bold");
      doc.text("Mapa de Cobertura por Herramienta:", 20, yPosition);
      yPosition += 8;
      
      // Calcular cobertura por herramienta
      const herramientaMap = new Map<string, { count: number; categoria: string }>();
      tableData.forEach((row) => {
        const key = row.herramienta_id || "";
        if (!herramientaMap.has(key) && key) {
          herramientaMap.set(key, { count: 0, categoria: row.herramienta_categoria || "" });
        }
        if (key && herramientaMap.has(key)) {
          herramientaMap.get(key)!.count++;
        }
      });
      
      if (herramientaMap.size === 0) {
        doc.setFontSize(10);
        doc.setFont("helvetica", "normal");
        doc.text("No se encontraron herramientas con los filtros aplicados.", 25, yPosition);
        yPosition += 15;
      } else {
        // Preparar datos para tabla de cobertura
        const coberturaData = Array.from(herramientaMap.entries())
          .sort(([, a], [, b]) => b.count - a.count)
          .map(([herramienta, data], index) => [
            (index + 1).toString(),
            herramienta,
            data.categoria,
            data.count.toString(),
            `${((data.count / tableData.length) * 100).toFixed(1)}%`
          ]);
        
        // Agregar fila de totales
        const totalActividades = tableData.length;
        const totalHerramientas = herramientaMap.size;
        coberturaData.push([
          "TOTAL",
          `${totalHerramientas} herramienta(s)`,
          "-",
          totalActividades.toString(),
          "100%"
        ]);
        
        // Generar tabla de cobertura
        if (typeof doc.autoTable === 'function') {
          doc.autoTable({
            head: [["#", "Herramienta", "Categoría", "Actividades", "% Cobertura"]],
            body: coberturaData,
            startY: yPosition,
          styles: {
            fontSize: 7,
            cellPadding: 2,
            overflow: 'linebreak',
            cellWidth: 'wrap',
          },
            headStyles: {
              fillColor: [39, 174, 96], // Verde
              textColor: 255,
              fontStyle: "bold",
            },
            alternateRowStyles: {
              fillColor: [248, 249, 250],
            },
            columnStyles: {
              0: { cellWidth: 12, halign: 'center' },
              1: { cellWidth: 60 },
              2: { cellWidth: 40 },
              3: { cellWidth: 25, halign: 'center' },
              4: { cellWidth: 25, halign: 'center' }
            },
            margin: { left: 10, right: 10, bottom: 50 },
            tableWidth: 'auto',
            // Estilo especial para la fila de totales
            didParseCell: function (data: { row: { index: number }; cell: { styles: Record<string, unknown> } }) {
              if (data.row.index === coberturaData.length - 1) {
                data.cell.styles.fontStyle = 'bold';
                data.cell.styles.fillColor = [230, 230, 230];
              }
            }
          });
          yPosition = doc.lastAutoTable.finalY + 15;
        } else {
          // Fallback manual para cobertura
          doc.setFontSize(8);
          doc.setFont("helvetica", "bold");
          doc.setFillColor(39, 174, 96);
          doc.setTextColor(255, 255, 255);
          doc.rect(20, yPosition - 4, pageWidth - 40, 8, "F");
          doc.text("#", 25, yPosition);
          doc.text("Herramienta", 40, yPosition);
          doc.text("Categoría", 100, yPosition);
          doc.text("Act.", 140, yPosition);
          doc.text("%", 160, yPosition);
          yPosition += 10;
          
          doc.setFont("helvetica", "normal");
          doc.setTextColor(0, 0, 0);
          coberturaData.forEach((row, index) => {
            if (index % 2 === 1) {
              doc.setFillColor(248, 249, 250);
              doc.rect(20, yPosition - 4, pageWidth - 40, 6, "F");
            }
            if (index === coberturaData.length - 1) {
              doc.setFont("helvetica", "bold");
              doc.setFillColor(230, 230, 230);
              doc.rect(20, yPosition - 4, pageWidth - 40, 6, "F");
            }
            doc.text(row[0], 25, yPosition);
            doc.text(row[1].substring(0, 20), 40, yPosition);
            doc.text(row[2].substring(0, 15), 100, yPosition);
            doc.text(row[3], 140, yPosition);
            doc.text(row[4], 160, yPosition);
            yPosition += 6;
            if (index === coberturaData.length - 1) {
              doc.setFont("helvetica", "normal");
            }
          });
          yPosition += 15;
        }
      }
      
      // **TABLA DE DATOS**
      if (tableData.length > 0) {
        doc.setFontSize(12);
        doc.setFont("helvetica", "bold");
        doc.text("Detalle de Actividades y Herramientas:", 20, yPosition);
        yPosition += 10;
        
        // Preparar datos para la tabla principal
        const tableHeaders = [
          "Objetivo",
          "Práctica",
          "Actividad",
          "Nivel",
          "Herramienta",
          "Justificación",
          "Observación",
          "Integración"
        ];
        
        const tableRows = tableData.map((row) => [
          row.objetivo_id || "",
          row.practica_id || "",
          row.actividad_id || "",
          row.nivel_capacidad?.toString() || "",
          row.herramienta_id || "",
          row.justificacion || "",
          row.observaciones || "",
          row.integracion || ""
        ]);
        
        // Verificar si autoTable está disponible después de la carga dinámica
        if (typeof doc.autoTable === 'function') {
          // Generar tabla usando autoTable con configuración mejorada
          doc.autoTable({
            head: [tableHeaders],
            body: tableRows,
            startY: yPosition,
            styles: {
              fontSize: 6,
              cellPadding: 1.5,
              overflow: 'linebreak',
              valign: 'top',
              cellWidth: 'wrap',
            },
            headStyles: {
              fillColor: [41, 128, 185], // Azul COBIT
              textColor: 255,
              fontStyle: "bold",
              fontSize: 7,
              overflow: 'linebreak',
            },
            alternateRowStyles: {
              fillColor: [249, 249, 249],
            },
            columnStyles: {
              0: { cellWidth: 18 }, // Objetivo
              1: { cellWidth: 18 }, // Práctica
              2: { cellWidth: 18 }, // Actividad
              3: { cellWidth: 12, halign: 'center' }, // Nivel
              4: { cellWidth: 22 }, // Herramienta
              5: { cellWidth: 28 }, // Justificación
              6: { cellWidth: 26 }, // Observación
              7: { cellWidth: 26 }  // Integración
            },
            margin: { left: 4, right: 4, top: 10, bottom: 50 },
            tableWidth: 168, // Ancho ajustado para headers completos
            pageBreak: "auto",
            showHead: "everyPage",
            theme: 'striped',
            // Configuración adicional para el pie de página
            addPageContent: function() {
              // Esta función se ejecuta después de agregar contenido en cada página
            }
          });
        } else {
          // Fallback: crear tabla manual mejorada
          doc.setFontSize(7);
          let tableY = yPosition;
          
          // Definir anchos de columnas que caben en página A4 (210mm ≈ 595px)
          const totalWidth = 168; // Ancho que cabe cómodamente en A4
          const columnWidths = [18, 18, 18, 12, 22, 28, 26, 26]; // Total: 168
          const startX = 18;
          
          // Headers
          doc.setFontSize(6);
          doc.setFont("helvetica", "bold");
          doc.setFillColor(41, 128, 185);
          doc.rect(startX, tableY - 4, totalWidth, 8, "F");
          doc.setTextColor(255, 255, 255);
          let xPos = startX + 2;
          tableHeaders.forEach((header, index) => {
            // Calcular caracteres que caben según el ancho de columna
            const maxChars = Math.floor(columnWidths[index] / 1.8);
            const headerText = header.length > maxChars ? header.substring(0, maxChars - 1) + "." : header;
            doc.text(headerText, xPos, tableY);
            xPos += columnWidths[index];
          });
          tableY += 10;
          
          // Data rows
          doc.setFont("helvetica", "normal");
          doc.setTextColor(0, 0, 0);
          tableRows.forEach((row, rowIndex) => {
            if (rowIndex % 2 === 1) {
              doc.setFillColor(249, 249, 249);
              doc.rect(startX, tableY - 4, totalWidth, 6, "F");
            }
            xPos = startX + 2;
            let maxLinesInRow = 1;
            
            // Calcular las líneas para cada celda y encontrar el máximo
            const cellLines: string[][] = [];
            row.forEach((cell, colIndex) => {
              const cellText = cell.toString();
              const maxWidth = columnWidths[colIndex] - 2;
              
              // Dividir texto en líneas
              const words = cellText.split(' ');
              const lines = [];
              let currentLine = '';
              
              words.forEach(word => {
                const testLine = currentLine ? currentLine + ' ' + word : word;
                const textWidth = doc.getTextWidth(testLine);
                
                if (textWidth <= maxWidth) {
                  currentLine = testLine;
                } else {
                  if (currentLine) lines.push(currentLine);
                  currentLine = word;
                }
              });
              if (currentLine) lines.push(currentLine);
              
              cellLines.push(lines);
              maxLinesInRow = Math.max(maxLinesInRow, lines.length);
            });
            
            // Renderizar todas las celdas
            cellLines.forEach((lines: string[], colIndex: number) => {
              lines.forEach((line: string, lineIndex: number) => {
                doc.text(line, xPos, tableY + (lineIndex * 4));
              });
              xPos += columnWidths[colIndex];
            });
            
            // Ajustar altura de fila según número máximo de líneas
            tableY += Math.max(6, maxLinesInRow * 4 + 2);
            
            // Nueva página si es necesario (reservar espacio para pie de página)
            if (tableY > pageHeight - 50) {
              doc.addPage();
              tableY = 20;
              
              // Repetir headers en nueva página
              doc.setFont("helvetica", "bold");
              doc.setFillColor(41, 128, 185);
              doc.rect(startX, tableY - 4, totalWidth, 8, "F");
              doc.setTextColor(255, 255, 255);
              xPos = startX + 2;
              tableHeaders.forEach((header, index) => {
                doc.text(header.substring(0, 10), xPos, tableY);
                xPos += columnWidths[index];
              });
              tableY += 10;
              doc.setFont("helvetica", "normal");
              doc.setTextColor(0, 0, 0);
            }
          });
        }
      }
      
      // **PIE DE PÁGINA** (en todas las páginas)
      const addFooterToAllPages = () => {
        const pageCount = doc.internal.getNumberOfPages();
        for (let i = 1; i <= pageCount; i++) {
          doc.setPage(i);
          
          // Limpiar área del pie de página para evitar superposiciones
          doc.setFillColor(255, 255, 255);
          doc.rect(0, pageHeight - 40, pageWidth, 40, "F");
          
          // Agregar contenido del pie de página
          doc.setFontSize(8);
          doc.setFont("helvetica", "normal");
          doc.setTextColor(0, 0, 0);
          doc.text(
            "Universidad del Quindío - Proyecto de Grado Ecosistema tecnológico para la implementación de hojas de ruta de COBIT 2019",
            pageWidth / 2,
            pageHeight - 30,
            { align: "center" }
          );
          doc.text(
            "Desarrollado por: Jhoan Esteban Soler Giral, Johana Paola Palacio Osorio, Jesús Santiago Ramón Ramos",
            pageWidth / 2,
            pageHeight - 25,
            { align: "center" }
          );
          doc.text(
            "Asesor de Tesis: Luis Eduardo Sepúlveda",
            pageWidth / 2,
            pageHeight - 20,
            { align: "center" }
          );
          doc.text(
            `Página ${i} de ${pageCount}`,
            pageWidth - 20,
            pageHeight - 15,
            { align: "right" }
          );
        }
      };
      
      // Aplicar pie de página
      addFooterToAllPages();
      
      // Generar nombre del archivo
      const timestamp = now.toISOString().slice(0, 19).replace(/:/g, "-");
      const fileName = `ecosistema-cobit-${timestamp}.pdf`;
      
      // Descargar el PDF
      doc.save(fileName);
      
    } catch (error) {
      console.error("Error al generar PDF:", error);
      alert("Error al generar el PDF. Por favor, intenta de nuevo.");
    }
  };
  
  return { generatePDF };
}