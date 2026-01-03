# -----------------------------------------------------------------------------
# BASE: Node 22 Alpine (Coincide con tu local)
# -----------------------------------------------------------------------------
FROM node:22-alpine AS base
# Activamos pnpm mediante Corepack (viene con Node)
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Instalar dependencias del sistema necesarias para Strapi (Sharp/SQLite/Python)
# vips-dev es CRÍTICO para el plugin de imágenes de Strapi
RUN apk update && apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    vips-dev \
    git > /dev/null 2>&1

WORKDIR /opt/app

# -----------------------------------------------------------------------------
# BUILD STAGE
# -----------------------------------------------------------------------------
FROM base AS build

# Copiamos archivos de definición de paquetes
COPY package.json pnpm-lock.yaml ./

# Instalamos dependencias
# --frozen-lockfile: Falla si el lockfile no coincide (seguridad)
# --prod=false: Instalamos TAMBIÉN las devDependencies porque Strapi las necesita para el build
RUN pnpm install --frozen-lockfile --prod=false

# Copiamos el resto del código
COPY . .

# Construimos el admin panel
ENV NODE_ENV=production
RUN pnpm run build

# Limpieza: Prune de dependencias de desarrollo para aligerar la imagen final
# (Opcional, pero recomendado si querés ahorrar espacio)
RUN pnpm prune --prod

# -----------------------------------------------------------------------------
# RUNNER STAGE (Imagen Final)
# -----------------------------------------------------------------------------
# ... (parte de arriba igual, stages base y build)

# -----------------------------------------------------------------------------
# RUNNER STAGE (Imagen Final)
# -----------------------------------------------------------------------------
FROM base AS runner

ENV NODE_ENV=production

# Copiamos desde el stage de build
COPY --from=build /opt/app/node_modules ./node_modules
COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/package.json ./package.json
COPY --from=build /opt/app/favicon.png ./favicon.png

# Copiamos source y database
COPY --from=build /opt/app/src ./src
COPY --from=build /opt/app/database ./database

# --- EL CAMBIO MAGICO ---
# 1. Copiamos la carpeta config original (para tener los .json y estructura)
COPY --from=build /opt/app/config ./config
# 2. Borramos los archivos TypeScript de esa carpeta para que no rompan en producción
RUN rm -f ./config/*.ts

EXPOSE 1337

CMD ["pnpm", "run", "start"]