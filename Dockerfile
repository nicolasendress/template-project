# ===== Base =====
FROM node:20-alpine AS base
ENV DIR=/app
WORKDIR $DIR

# ===== Stage de Desarrollo =====
FROM base AS development
RUN apk update && apk add --no-cache dumb-init

COPY package*.json $DIR

# (Opcional) Uso de BuildKit para secretos; si no usas npm_token, puedes omitir esta línea.
RUN --mount=type=secret,id=npm_token \
    echo "//registry.npmjs.org/:_authToken=$(cat /run/secrets/npm_token)" > .npmrc \
 && npm install \
 && rm -f .npmrc

COPY tsconfig*.json $DIR
COPY src $DIR/src

# Optimización: Usa Turbopack por defecto
ENV NEXT_DEV_TURBOPACK=1

EXPOSE $PORT

# Comando para iniciar en modo desarrollo, forzando que Next.js escuche en 0.0.0.0
CMD ["npm", "run", "start:dev", "--", "-H", "0.0.0.0"]

# ===== Stage de Build =====
FROM base AS build
RUN apk update && apk add --no-cache dumb-init

COPY package*.json $DIR

RUN --mount=type=secret,id=npm_token \
    echo "//registry.npmjs.org/:_authToken=$(cat /run/secrets/npm_token)" > .npmrc \
 && npm ci \
 && rm -f .npmrc

COPY tsconfig*.json $DIR
COPY src $DIR/src

# Copiamos el resto de archivos (incluye .dockerignore, etc.)
COPY . .

# Construimos la aplicación y eliminamos dependencias de desarrollo
RUN npm run build && npm prune --production

# ===== Stage de Producción =====
FROM base AS production
ENV USER=node

# Copiamos dumb-init y los artefactos generados en la etapa de build
COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init
COPY --from=build $DIR/package.json $DIR/package.json
COPY --from=build $DIR/node_modules $DIR/node_modules
COPY --from=build $DIR/.next $DIR/.next

ENV NODE_ENV=production
EXPOSE 3000
USER $USER

CMD ["dumb-init", "npm", "run", "start"]
