# 🗄️ Configuración de Base de Datos

## 📋 Configuración Rápida

### 1. Variables de Entorno

Crea el archivo de configuración local:

```bash
# Renombrar archivo de ejemplo
mv env.example .env.local

# O copiar manualmente
cp env.example .env.local
```

### 2. Editar Credenciales

Abre `.env.local` y configura tus credenciales:

```bash
# Configuración de base de datos PostgreSQL
DB_USER=postgres
DB_HOST=localhost
DB_DATABASE=cobit
DB_PASSWORD=root           # ← Cambia por tu contraseña
DB_PORT=5432
```

### 3. Verificar Conexión

Ejecuta el script de prueba:

```bash
node scripts/test-connection.js
```

### 4. Iniciar Aplicación

```bash
npm run dev
```

## 🔒 Seguridad

- ✅ **Subir a Git**: `env.example`, `src/lib/database.ts`
- ❌ **NO subir**: `.env.local` (contiene credenciales reales)
- 🛡️ **Protección**: `.gitignore` ya configurado para ignorar `.env*`

## 📊 Estructura de Datos

La aplicación se conecta automáticamente a las tablas:

- `ogg` - Objetivos COBIT 2019
- `practica` - Prácticas por objetivo
- `herramienta` - Herramientas tecnológicas
- `actividad` - Actividades específicas

## 🚀 Características

- **Carga dinámica**: Datos reales desde PostgreSQL
- **Estados de carga**: Spinners y manejo de errores
- **Filtros**: Por dominio, objetivo y herramienta
- **Tablero interactivo**: Selección de objetivos y niveles

¡La aplicación está lista para funcionar con tu base de datos COBIT! 🎉
