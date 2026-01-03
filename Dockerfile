# -----------------------------------------------------------------------------
# BASE
# -----------------------------------------------------------------------------
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Instalar dependencias del sistema (incluimos curl aquí para que esté disponible si hace falta)
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
ENV NODE_ENV=production
RUN pnpm run build
RUN pnpm prune --prod

# -----------------------------------------------------------------------------
# RUNNER STAGE
# -----------------------------------------------------------------------------
FROM base AS runner
ENV NODE_ENV=production

# 1. Copiamos node_modules y dist
COPY --from=build /opt/app/node_modules ./node_modules
COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/package.json ./package.json
COPY --from=build /opt/app/favicon.png ./favicon.png

# 2. Copiamos config compilada (.js)
COPY --from=build /opt/app/dist/config ./config

# 3. Copiamos src
COPY --from=build /opt/app/src ./src

# 4. INSTALAR CURL (La solución a tu advertencia)
# Alpine necesita esto para que Coolify pueda hacer el healthcheck
RUN apk add --no-cache curl

# 5. Crear carpeta uploads
RUN mkdir -p public/uploads

EXPOSE 1337
CMD ["pnpm", "run", "start"]