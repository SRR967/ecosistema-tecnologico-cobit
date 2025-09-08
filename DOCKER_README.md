# 🐳 COBIT Ecosistema - Docker Setup

## 📋 Requisitos Previos

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## 🚀 Inicio Rápido

### 1. Clonar el repositorio

```bash
git clone <tu-repositorio>
cd cobit-ecosistema
```

### 2. Iniciar la aplicación

```bash
# Opción 1: Con script automatizado
chmod +x docker-scripts/start.sh
./docker-scripts/start.sh

# Opción 2: Comando directo
docker-compose up --build -d
```

### 3. Acceder a la aplicación

- **Aplicación Web**: http://localhost:3000
- **Base de Datos**: postgres://postgres:root@localhost:5432/cobit
- **Adminer (Admin DB)**: http://localhost:8080

## 🗄️ Base de Datos

### Inicialización Automática

La base de datos PostgreSQL se inicializa automáticamente con:

- Esquema COBIT 2019
- Tablas: `ogg`, `practica`, `herramienta`, `actividad`
- Índices optimizados

### Configuración

```yaml
# docker-compose.yml
postgres:
  image: postgres:15-alpine
  environment:
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: root
    POSTGRES_DB: cobit
```

## 📦 Servicios Incluidos

### 🌐 App (Next.js)

- **Puerto**: 3000
- **Tecnología**: Next.js 14, TypeScript, Tailwind CSS
- **Base**: node:18-alpine

### 🗄️ PostgreSQL

- **Puerto**: 5432
- **Versión**: PostgreSQL 15 Alpine
- **Volumen persistente**: `postgres_data`

### 🔧 Adminer (Opcional)

- **Puerto**: 8080
- **Uso**: Administración de base de datos
- **Acceso**: usuario `postgres`, contraseña `root`

## 📋 Comandos Útiles

### Gestión de Contenedores

```bash
# Ver estado de servicios
docker-compose ps

# Ver logs
docker-compose logs -f app      # App logs
docker-compose logs -f postgres # DB logs

# Reiniciar servicio específico
docker-compose restart app

# Reconstruir imagen
docker-compose build app

# Detener servicios
docker-compose down

# Detener y eliminar volúmenes (CUIDADO: borra datos)
docker-compose down -v
```

### Base de Datos

```bash
# Conectar a PostgreSQL
docker-compose exec postgres psql -U postgres -d cobit

# Backup de la base de datos
docker-compose exec postgres pg_dump -U postgres cobit > backup.sql

# Restaurar backup
docker-compose exec -T postgres psql -U postgres cobit < backup.sql
```

### Debugging

```bash
# Entrar al contenedor de la app
docker-compose exec app sh

# Entrar al contenedor de PostgreSQL
docker-compose exec postgres sh

# Ver variables de entorno
docker-compose exec app env
```

## 🔧 Configuración Avanzada

### Variables de Entorno

```yaml
# docker-compose.yml - Servicio app
environment:
  NODE_ENV: production
  DB_HOST: postgres
  DB_PORT: 5432
  DB_USER: postgres
  DB_PASSWORD: root
  DB_DATABASE: cobit
```

### Volúmenes

```yaml
volumes:
  postgres_data: # Datos persistentes de PostgreSQL
  ./database/init: # Scripts de inicialización
```

### Red

```yaml
networks:
  cobit-network: # Red privada para comunicación entre servicios
```

## 🚀 Producción

### Build para Producción

```bash
# Build optimizado
docker-compose -f docker-compose.prod.yml up --build -d
```

### Consideraciones de Seguridad

1. **Cambiar contraseñas**: Usar contraseñas seguras en producción
2. **Variables de entorno**: Usar secrets de Docker/Kubernetes
3. **HTTPS**: Configurar reverse proxy (nginx, traefik)
4. **Backup**: Implementar backup automático de PostgreSQL

## 🐛 Troubleshooting

### Problema: Puerto en uso

```bash
# Verificar qué usa el puerto
netstat -tlnp | grep :3000

# Cambiar puerto en docker-compose.yml
ports:
  - "3001:3000"  # Puerto host:contenedor
```

### Problema: Base de datos no conecta

```bash
# Verificar logs de PostgreSQL
docker-compose logs postgres

# Verificar health check
docker-compose exec postgres pg_isready -U postgres
```

### Problema: Datos perdidos

```bash
# Verificar volúmenes
docker volume ls

# Recrear volumen (CUIDADO: borra datos)
docker-compose down -v
docker-compose up --build -d
```

## 📂 Estructura del Proyecto

```
cobit-ecosistema/
├── Dockerfile                 # Imagen de la aplicación
├── docker-compose.yml         # Configuración de servicios
├── .dockerignore              # Archivos ignorados en build
├── database/
│   └── init/
│       └── 01-init-cobit-schema.sql  # Inicialización DB
├── docker-scripts/
│   ├── start.sh               # Script de inicio
│   └── stop.sh                # Script de parada
└── src/
    └── app/api/health/        # Endpoint de salud
```

## ✅ Health Checks

### Aplicación

- **Endpoint**: http://localhost:3000/api/health
- **Respuesta**: Status de app y base de datos

### Base de Datos

- **Comando**: `pg_isready -U postgres -d cobit`
- **Intervalo**: 30 segundos

¡Tu aplicación COBIT está lista para funcionar en Docker! 🎉
