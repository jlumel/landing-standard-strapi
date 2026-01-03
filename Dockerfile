# -----------------------------------------------------------------------------
# BASE
# -----------------------------------------------------------------------------
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Instalamos dependencias del sistema
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
RUN pnpm run build

# Limpiamos dependencias dev
RUN pnpm prune --prod

# -----------------------------------------------------------------------------
# RUNNER STAGE
# -----------------------------------------------------------------------------
FROM base AS runner
ENV NODE_ENV=production
WORKDIR /opt/app

COPY --from=build /pnpm /pnpm

COPY --from=build /opt/app/package.json ./package.json
COPY --from=build /opt/app/node_modules ./node_modules
COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/.strapi ./.strapi
COPY --from=build /opt/app/favicon.png ./favicon.png

RUN mkdir -p public/uploads

EXPOSE 1337
CMD ["pnpm", "run", "start"]