import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Configuración para Docker
  output: 'standalone',
  // Optimizaciones adicionales
  serverExternalPackages: ['pg']
};

export default nextConfig;
