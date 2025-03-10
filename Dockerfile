# ===== Base =====
FROM node:20-alpine AS base
ENV DIR=/app
WORKDIR $DIR

FROM base AS development

# Instalar dependencias comunes (dumb-init para gestionar correctamente los procesos en el contenedor)
RUN apk update && apk add --no-cache dumb-init mysql-client

# Copia los archivos package.json y package-lock.json (o pnpm-lock.yaml si lo usas) para que npm pueda instalar las dependencias
COPY package*.json $DIR

# Usar Docker Secrets para el token de NPM, evitando almacenar el token en el Dockerfile.
RUN --mount=type=secret,id=npm_token \
    echo "//registry.npmjs.org/:_authToken=$(cat /run/secrets/npm_token)" > .npmrc \
 && npm install \
 && rm -f .npmrc  # Elimina el archivo .npmrc para evitar que contenga el token

# Copia el archivo de configuración de TypeScript y el código fuente a la imagen.
COPY tsconfig*.json $DIR
COPY src $DIR/src

# Configura la variable de entorno para habilitar TurboPack en Next.js
ENV NEXT_DEV_TURBOPACK=1

# Expone el puerto para que se pueda acceder desde fuera del contenedor
EXPOSE $PORT

# Define el comando para iniciar el servidor de desarrollo en Next.js
CMD ["npm", "run", "start:dev", "--", "-H", "0.0.0.0"]

# ===== Stage de Build =====
FROM base AS build
RUN apk update && apk add --no-cache dumb-init mysql-client

# Copia los archivos package.json y package-lock.json (o pnpm-lock.yaml) nuevamente
COPY package*.json $DIR

RUN --mount=type=secret,id=npm_token \
    echo "//registry.npmjs.org/:_authToken=$(cat /run/secrets/npm_token)" > .npmrc \
 && npm ci \
 && rm -f .npmrc  # Elimina el archivo .npmrc para evitar que contenga el token

COPY tsconfig*.json $DIR
COPY src $DIR/src
COPY . .

RUN npm run build && npm prune --production

# ===== Stage de Producción =====
FROM base AS production
ENV USER=node

COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init
COPY --from=build $DIR/package.json $DIR/package.json
COPY --from=build $DIR/node_modules $DIR/node_modules
COPY --from=build $DIR/.next $DIR/.next

ENV NODE_ENV=production
EXPOSE $PORT
USER $USER

CMD ["dumb-init", "npm", "run", "start"]
