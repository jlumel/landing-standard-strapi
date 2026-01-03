# -----------------------------------------------------------------------------
# BASE
# -----------------------------------------------------------------------------
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Instalamos curl y dependencias
RUN apk update && apk add --no-cache \
    build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git curl > /dev/null 2>&1

WORKDIR /opt/app

# -----------------------------------------------------------------------------
# BUILD STAGE
# -----------------------------------------------------------------------------
FROM base AS build
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod=false
COPY . .

# Compilamos
ENV NODE_ENV=production
RUN pnpm run build

# --- DEBUG: LISTAR CONTENIDO DE DIST ---
# Esto va a imprimir en el log qué carpetas se crearon.
# Buscamos algo como 'dist/admin' o 'dist/build'.
RUN echo "--- CONTENIDO DE DIST ---" && ls -R dist && echo "--- FIN CONTENIDO ---"

RUN pnpm prune --prod

# -----------------------------------------------------------------------------
# RUNNER STAGE
# -----------------------------------------------------------------------------
FROM base AS runner
ENV NODE_ENV=production

# 1. Copiamos node_modules y dist
COPY --from=build /opt/app/node_modules ./node_modules
COPY --from=build /opt/app/dist ./dist

# 2. Copiamos estáticos
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/package.json ./package.json
COPY --from=build /opt/app/favicon.png ./favicon.png

# 3. Configuración compilada
COPY --from=build /opt/app/dist/config ./config

# 4. Copiamos src
COPY --from=build /opt/app/src ./src

# 5. Crear carpeta uploads
RUN mkdir -p public/uploads

EXPOSE 1337
CMD ["pnpm", "run", "start"]