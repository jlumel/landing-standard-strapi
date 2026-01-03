# -----------------------------------------------------------------------------
# BASE
# -----------------------------------------------------------------------------
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

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

# Aumentamos memoria para node por las dudas, aunque el problema era disco.
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=4096"

# Compilamos
RUN pnpm run build

# --- [DETECTIVE MODE: ACTIVADO] ---
# Listamos el contenido para encontrar el index.html
RUN echo "==========================================" && \
    echo " BUSCANDO EL ADMIN PANEL... " && \
    echo "==========================================" && \
    ls -F dist && \
    echo "--- ¿HAY CARPETA BUILD DENTRO DE DIST? ---" && \
    ls -F dist/build || echo "No existe dist/build" && \
    echo "--- ¿HAY CARPETA ADMIN DENTRO DE DIST? ---" && \
    ls -F dist/admin || echo "No existe dist/admin" && \
    echo "=========================================="

RUN pnpm prune --prod

# -----------------------------------------------------------------------------
# RUNNER STAGE
# -----------------------------------------------------------------------------
FROM base AS runner
ENV NODE_ENV=production

COPY --from=build /opt/app/node_modules ./node_modules
COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/package.json ./package.json
COPY --from=build /opt/app/favicon.png ./favicon.png
COPY --from=build /opt/app/dist/config ./config
COPY --from=build /opt/app/src ./src

# Creamos uploads
RUN mkdir -p public/uploads

EXPOSE 1337
CMD ["pnpm", "run", "start"]