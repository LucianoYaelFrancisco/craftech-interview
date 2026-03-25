# DOCKERFILE PARA FRONTEND REACT
# Este archivo define cómo construir la imagen Docker para la aplicación React
# Usa multi-stage build para optimizar tamaño final de la imagen

# STAGE 1: BUILD
# Se llama "build" para reutilizar los artifacts en el siguiente stage
# Imagen: node:16-alpine (Node.js 16 en Alpine Linux - lightweight)
# Fuente: https://hub.docker.com/_/node
FROM node:16-alpine as build

# Define directorio de trabajo
WORKDIR /app

# COPY package*.json ./
# Copia tanto package.json como package-lock.json (si existe)
# El asterisco (*) es un wildcard que permite ambos archivos
# Se copian primero para aprovechar cache de Docker (si no cambian deps, no se reinstala)
COPY package*.json ./

# npm install: instala todas las dependencias listadas en package.json
# Fuente: https://docs.npmjs.com/cli/v8/commands/npm-install
RUN npm install

# Copia código fuente de React
COPY . .

# npm run build: compilación de producción de React
# Genera carpeta /app/build con archivos HTML/CSS/JS optimizados
# Fuente: https://create-react-app.dev/docs/production-build/
RUN npm run build

# STAGE 2: PRODUCTION
# Nueva imagen limpia (no incluye código fuente, solo archivos compilados)
# Reduce significativamente el tamaño final de la imagen
FROM node:16-alpine

WORKDIR /app

# npm install -g serve: instala "serve" globalmente
# "serve" es un servidor HTTP simple que sirve archivos estáticos
# Se usa en producción para servir aplicaciones React compiladas
# Fuente: https://www.npmjs.com/package/serve
RUN npm install -g serve

# COPY --from=build: copia archivos SOLO del stage anterior (build)
# /app/build es la carpeta compilada de React (HTML, CSS, JS optimizados)
# Se copia a ./build en el contenedor de producción
COPY --from=build /app/build ./build

# Puerto en el que escucha la aplicación React
EXPOSE 3000

# CMD ejecuta "serve"
# -s build: sirve la carpeta "build" como aplicación SPA (Single Page App)
# -l 3000: escucha en el puerto 3000
# Fuente: https://github.com/vercel/serve
CMD ["serve", "-s", "build", "-l", "3000"]
