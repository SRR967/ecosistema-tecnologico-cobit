#!/bin/bash
# Script para detener la aplicación COBIT con Docker

echo "🛑 Deteniendo aplicación COBIT..."

# Detener y remover contenedores
docker-compose down

echo "🧹 Limpiando recursos Docker (opcional)..."
echo "Para limpiar completamente (CUIDADO: borrará datos):"
echo "  docker-compose down -v  # Incluye volúmenes"
echo "  docker system prune     # Limpia imágenes no utilizadas"
echo ""
echo "✅ Aplicación detenida correctamente!"
