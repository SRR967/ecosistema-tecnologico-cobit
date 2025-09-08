// Tipos para las respuestas de la base de datos

export interface DBRow {
  [key: string]: unknown;
}

export interface HerramientaRow {
  id: string;
  categoria: string;
}

export interface CobitGraphNode {
  id: string;
  name: string;
  type: 'objetivo' | 'herramienta';
  category?: string;
  x?: number;
  y?: number;
  fx?: number | null;
  fy?: number | null;
}

export interface CobitGraphLink {
  source: string;
  target: string;
}

export interface D3SimulationNode extends d3.SimulationNodeDatum {
  id: string;
  name: string;
  type: 'objetivo' | 'herramienta';
  category?: string;
  domain?: string;
  toolType?: string;
}

export interface D3SimulationLink extends d3.SimulationLinkDatum<D3SimulationNode> {
  source: string | D3SimulationNode;
  target: string | D3SimulationNode;
  count: number;
}

export interface DatabaseQueryResult {
  rows: DBRow[];
  rowCount?: number;
}
