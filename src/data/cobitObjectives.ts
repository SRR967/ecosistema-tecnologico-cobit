export interface CobitObjective {
  code: string;
  title: string;
  domain: 'EDM' | 'APO' | 'BAI' | 'DSS' | 'MEA';
}

// Interface compatible con la base de datos
export interface OGGObjective {
  id: string;           // Código del objetivo (ej: APO01)
  nombre: string;       // Nombre del objetivo
  descripcion: string;  // Descripción
  proposito: string;    // Propósito
}

// Función para convertir OGG de BD a CobitObjective
export function oggToCobitObjective(ogg: OGGObjective): CobitObjective {
  const domain = ogg.id.substring(0, 3) as 'EDM' | 'APO' | 'BAI' | 'DSS' | 'MEA';
  return {
    code: ogg.id,
    title: ogg.nombre,
    domain: domain
  };
}

export const cobitObjectives: CobitObjective[] = [
  // EDM - Evaluate, Direct and Monitor
  { code: 'EDM01', title: 'Ensured Governance Framework Setting and Maintenance', domain: 'EDM' },
  { code: 'EDM02', title: 'Ensured Benefits Delivery', domain: 'EDM' },
  { code: 'EDM03', title: 'Ensured Risk Optimization', domain: 'EDM' },
  { code: 'EDM04', title: 'Ensured Resource Optimization', domain: 'EDM' },
  { code: 'EDM05', title: 'Ensured Stakeholder Engagement', domain: 'EDM' },

  // APO - Align, Plan and Organize
  { code: 'APO01', title: 'Managed I&T Management Framework', domain: 'APO' },
  { code: 'APO02', title: 'Managed Strategy', domain: 'APO' },
  { code: 'APO03', title: 'Managed Enterprise Architecture', domain: 'APO' },
  { code: 'APO04', title: 'Managed Innovation', domain: 'APO' },
  { code: 'APO05', title: 'Managed Portfolio', domain: 'APO' },
  { code: 'APO06', title: 'Managed Budget and Costs', domain: 'APO' },
  { code: 'APO07', title: 'Managed Human Resources', domain: 'APO' },
  { code: 'APO08', title: 'Managed Relationships', domain: 'APO' },
  { code: 'APO09', title: 'Managed Service Agreements', domain: 'APO' },
  { code: 'APO10', title: 'Managed Vendors', domain: 'APO' },
  { code: 'APO11', title: 'Managed Quality', domain: 'APO' },
  { code: 'APO12', title: 'Managed Risk', domain: 'APO' },
  { code: 'APO13', title: 'Managed Security', domain: 'APO' },
  { code: 'APO14', title: 'Managed Data', domain: 'APO' },

  // BAI - Build, Acquire and Implement
  { code: 'BAI01', title: 'Managed Programs', domain: 'BAI' },
  { code: 'BAI02', title: 'Managed Requirements Definition', domain: 'BAI' },
  { code: 'BAI03', title: 'Managed Solutions Identification and Build', domain: 'BAI' },
  { code: 'BAI04', title: 'Managed Availability and Capacity', domain: 'BAI' },
  { code: 'BAI05', title: 'Managed Organizational Change', domain: 'BAI' },
  { code: 'BAI06', title: 'Managed IT Changes', domain: 'BAI' },
  { code: 'BAI07', title: 'Managed IT Change Acceptance and Transitioning', domain: 'BAI' },
  { code: 'BAI08', title: 'Managed Knowledge', domain: 'BAI' },
  { code: 'BAI09', title: 'Managed Assets', domain: 'BAI' },
  { code: 'BAI10', title: 'Managed Configuration', domain: 'BAI' },
  { code: 'BAI11', title: 'Managed Projects', domain: 'BAI' },

  // DSS - Deliver, Service and Support
  { code: 'DSS01', title: 'Managed Operations', domain: 'DSS' },
  { code: 'DSS02', title: 'Managed Service Requests and Incidents', domain: 'DSS' },
  { code: 'DSS03', title: 'Managed Problems', domain: 'DSS' },
  { code: 'DSS04', title: 'Managed Continuity', domain: 'DSS' },
  { code: 'DSS05', title: 'Managed Security Services', domain: 'DSS' },
  { code: 'DSS06', title: 'Managed Business Process Controls', domain: 'DSS' },

  // MEA - Monitor, Evaluate and Assess
  { code: 'MEA01', title: 'Managed Performance and Conformance Monitoring', domain: 'MEA' },
  { code: 'MEA02', title: 'Managed System of Internal Control', domain: 'MEA' },
  { code: 'MEA03', title: 'Managed Compliance With External Requirements', domain: 'MEA' },
  { code: 'MEA04', title: 'Managed Assurance', domain: 'MEA' },
];

export const getDomainObjectives = (domain: 'EDM' | 'APO' | 'BAI' | 'DSS' | 'MEA') => {
  return cobitObjectives.filter(obj => obj.domain === domain);
};

export const getDomainTitle = (domain: 'EDM' | 'APO' | 'BAI' | 'DSS' | 'MEA') => {
  switch (domain) {
    case 'EDM': return 'EDM - Evaluate, Direct and Monitor';
    case 'APO': return 'APO - Align, Plan and Organize';
    case 'BAI': return 'BAI - Build, Acquire and Implement';
    case 'DSS': return 'DSS - Deliver, Service and Support';
    case 'MEA': return 'MEA - Monitor, Evaluate and Assess';
    default: return '';
  }
};
