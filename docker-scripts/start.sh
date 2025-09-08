#!/bin/bash
# Script para iniciar la aplicación COBIT con Docker

echo "🐳 Iniciando aplicación COBIT con Docker..."
echo "📦 Construyendo contenedores..."

# Construir y levantar servicios
docker-compose up --build -d

echo "⏳ Esperando que la base de datos esté lista..."
sleep 10

echo "🔍 Verificando estado de los servicios..."
docker-compose ps

echo "📋 Servicios disponibles:"
echo "  🌐 Aplicación:     http://localhost:3000"
echo "  🗄️  Base de datos:  postgres://postgres:root@localhost:5432/cobit"
echo "  🔧 Adminer:       http://localhost:8080"
echo ""
echo "📝 Para ver logs:"
echo "  docker-compose logs -f app      # Logs de la aplicación"
echo "  docker-compose logs -f postgres # Logs de la base de datos"
echo ""
echo "🛑 Para detener:"
echo "  docker-compose down"
echo ""
echo "✅ ¡Aplicación iniciada correctamente!"
