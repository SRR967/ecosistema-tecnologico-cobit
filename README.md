# 🎯 COBIT Ecosistema

Sistema de gestión y visualización del framework COBIT 2019, desarrollado con Next.js 14, TypeScript y PostgreSQL. Permite explorar objetivos, prácticas, actividades y herramientas de COBIT de manera interactiva.

## 🚀 Inicio Rápido con Docker

### Prerrequisitos

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Instalación y Ejecución

1. **Clonar el repositorio**

   ```bash
   git clone <tu-repositorio>
   cd cobit-ecosistema
   ```

2. **Iniciar la aplicación con Docker**

   ```bash
   # Opción 1: Usando script automatizado
   chmod +x docker-scripts/start.sh
   ./docker-scripts/start.sh

   # Opción 2: Comando directo
   docker-compose up --build -d
   ```

3. **Acceder a la aplicación**
   - **Aplicación Web**: http://localhost:3000
   - **Base de Datos**: postgres://postgres:root@localhost:5432/cobit
   - **Adminer (Admin DB)**: http://localhost:8080

## 🐳 Configuración de Docker

### Servicios Incluidos

#### 🌐 Aplicación Next.js

- **Puerto**: 3000
- **Tecnología**: Next.js 14, TypeScript, Tailwind CSS
- **Base**: node:18-alpine
- **Health Check**: http://localhost:3000/api/health

#### 🗄️ PostgreSQL

- **Puerto**: 5432
- **Versión**: PostgreSQL 15 Alpine
- **Base de datos**: `cobit`
- **Usuario**: `postgres`
- **Contraseña**: `root`
- **Volumen persistente**: `postgres_data`

#### 🔧 Adminer (Opcional)

- **Puerto**: 8080
- **Uso**: Administración de base de datos
- **Acceso**: usuario `postgres`, contraseña `root`

### Inicialización de Base de Datos

La base de datos PostgreSQL se inicializa automáticamente con los siguientes archivos:

- `database/init/01-init-cobit-schema.sql` - Esquema principal con todas las tablas COBIT
- `database/init/02-add-indexes.sql` - Índices optimizados para consultas

**Tablas incluidas:**

- `dominio` - Dominios COBIT (EDM, APO, BAI, DSS, MEA)
- `ogg` - Objetivos de Gobierno y Gestión
- `practica` - Prácticas de gestión
- `actividad` - Actividades específicas
- `herramienta` - Herramientas y tecnologías

## 📋 Comandos Docker Útiles

### Gestión de Contenedores

```bash
# Ver estado de servicios
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f app      # Logs de la aplicación
docker-compose logs -f postgres # Logs de la base de datos

# Reiniciar servicio específico
docker-compose restart app

# Reconstruir imagen
docker-compose build app

# Detener servicios
docker-compose down

# Detener y eliminar volúmenes (¡CUIDADO: borra todos los datos!)
docker-compose down -v
```

### Base de Datos

```bash
# Conectar a PostgreSQL
docker-compose exec postgres psql -U postgres -d cobit

# Crear backup de la base de datos
docker-compose exec postgres pg_dump -U postgres cobit > backup.sql

# Restaurar backup
docker-compose exec -T postgres psql -U postgres cobit < backup.sql
```

### Debugging

```bash
# Entrar al contenedor de la aplicación
docker-compose exec app sh

# Entrar al contenedor de PostgreSQL
docker-compose exec postgres sh

# Ver variables de entorno
docker-compose exec app env
```

## 🛠️ Desarrollo Local (sin Docker)

Si prefieres ejecutar la aplicación localmente:

```bash
# Instalar dependencias
npm install

# Ejecutar servidor de desarrollo
npm run dev
# o
yarn dev
# o
pnpm dev

# Abrir http://localhost:3000
```

**Nota**: Para desarrollo local necesitarás configurar una base de datos PostgreSQL separada y ejecutar los scripts de inicialización manualmente.

## 🏗️ Arquitectura del Proyecto

### Tecnologías

- **Frontend**: Next.js 14, TypeScript, Tailwind CSS
- **Backend**: Next.js API Routes
- **Base de Datos**: PostgreSQL 15
- **Contenedores**: Docker & Docker Compose

### Estructura de Componentes (Patrón Atómico)

```
src/components/
├── atoms/          # Componentes básicos (botones, inputs, etc.)
├── molecules/      # Combinaciones de átomos (formularios, cards, etc.)
└── organisms/      # Componentes complejos (tablas, gráficos, etc.)
```

### API Endpoints

- `GET /api/cobit/dominios` - Lista todos los dominios
- `GET /api/cobit/objetivos` - Lista objetivos con filtros
- `GET /api/cobit/herramientas` - Lista herramientas disponibles
- `GET /api/cobit/grafo` - Datos para visualización en grafo
- `GET /api/health` - Estado de la aplicación

## 🔧 Configuración Avanzada

### Variables de Entorno

```bash
# Aplicación
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1

# Base de datos
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=root
DB_DATABASE=cobit
```

### Volúmenes Docker

```yaml
volumes:
  postgres_data: # Datos persistentes de PostgreSQL
  ./database/init: # Scripts de inicialización de DB
```

## 🐛 Solución de Problemas

### Puerto en uso

```bash
# Verificar qué proceso usa el puerto
netstat -tlnp | grep :3000

# Cambiar puerto en docker-compose.yml
ports:
  - "3001:3000"  # Puerto host:contenedor
```

### Base de datos no conecta

```bash
# Verificar logs de PostgreSQL
docker-compose logs postgres

# Verificar health check
docker-compose exec postgres pg_isready -U postgres
```

### Datos perdidos

```bash
# Verificar volúmenes
docker volume ls

# Recrear volumen (¡CUIDADO: borra todos los datos!)
docker-compose down -v
docker-compose up --build -d
```

Si quieres conocer un poco mas acerca del funcionamiento de la aplicacion, visita la GUIA_USUARIO_COBIT.md

¡Tu aplicación COBIT está lista para funcionar!
