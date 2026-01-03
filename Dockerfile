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

# Compilamos
ENV NODE_ENV=production
RUN pnpm run build

# --- [DETECTIVE MODE ON] ---
# Esto imprimirá en el log DÓNDE diablos está el index.html
RUN echo "==========================================" && \
    echo " BUSCANDO EL TESORO (index.html)... " && \
    echo "==========================================" && \
    echo "--- 1. BUSCANDO EN DIST ---" && \
    ls -R dist || echo "No existe dist" && \
    echo "---------------------------" && \
    echo "--- 2. BUSCANDO EN .STRAPI ---" && \
    ls -R .strapi || echo "No existe .strapi" && \
    echo "=========================================="

RUN pnpm prune --prod

# -----------------------------------------------------------------------------
# RUNNER STAGE
# -----------------------------------------------------------------------------
FROM base AS runner
ENV NODE_ENV=production

# Copiamos lo básico para que arranque (aunque sin admin panel visual por ahora)
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