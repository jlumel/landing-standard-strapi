# -----------------------------------------------------------------------------
# BASE
# -----------------------------------------------------------------------------
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Instalamos dependencias del sistema
RUN apk update && apk add --no-cache \
    build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git curl

WORKDIR /opt/app

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------
FROM base AS deps
COPY package.json pnpm-lock.yaml ./

# Usar cache de pnpm para builds más rápidos
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile

# -----------------------------------------------------------------------------
# BUILD STAGE
# -----------------------------------------------------------------------------
FROM base AS build
COPY package.json pnpm-lock.yaml ./
COPY --from=deps /opt/app/node_modules ./node_modules

# Copiamos solo lo necesario para el build (respetando .dockerignore)
COPY tsconfig.json ./
COPY config ./config
COPY src ./src
COPY types ./types
COPY public ./public
COPY favicon.png ./favicon.png

# Build de Strapi
RUN pnpm run build

# Limpiamos dependencias de desarrollo
RUN pnpm prune --prod

# -----------------------------------------------------------------------------
# RUNNER STAGE
# -----------------------------------------------------------------------------
FROM base AS runner
ENV NODE_ENV=production
WORKDIR /opt/app

# Copiamos solo lo necesario para producción
COPY --from=build /opt/app/package.json ./
COPY --from=build /opt/app/node_modules ./node_modules
COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/build ./build
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/favicon.png ./favicon.png

# Directorio para uploads (será montado como volumen en Coolify)
RUN mkdir -p public/uploads

EXPOSE 1337

CMD ["pnpm", "run", "start"]