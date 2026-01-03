# -----------------------------------------------------------------------------
# BASE: Node 22 Alpine
# -----------------------------------------------------------------------------
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

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

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod=false

COPY . .

# Esto va a compilar src/ -> dist/src y config/ -> dist/config
ENV NODE_ENV=production
RUN pnpm run build

RUN pnpm prune --prod

# -----------------------------------------------------------------------------
# RUNNER STAGE
# -----------------------------------------------------------------------------
FROM base AS runner

ENV NODE_ENV=production

# Copiamos dependencias
COPY --from=build /opt/app/node_modules ./node_modules
COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/package.json ./package.json
COPY --from=build /opt/app/favicon.png ./favicon.png

# Copiamos source y database
COPY --from=build /opt/app/src ./src
COPY --from=build /opt/app/database ./database

# --- LA SOLUCIÓN DEFINITIVA ---
# Copiamos la configuración COMPILADA (.js) desde dist hacia la raíz.
# Strapi encontrará ./config/database.js y será feliz.
COPY --from=build /opt/app/dist/config ./config

EXPOSE 1337

CMD ["pnpm", "run", "start"]