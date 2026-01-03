# -----------------------------------------------------------------------------
# BASE
# -----------------------------------------------------------------------------
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Instalamos curl y dependencias de sistema
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

# Al correr build, Strapi genera:
# 1. Backend -> dist/
# 2. Admin Panel -> build/ (¡ESTA ES LA QUE FALTABA!)
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

# 2. Copiamos estáticos
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/package.json ./package.json
COPY --from=build /opt/app/favicon.png ./favicon.png

# 3. Configuración compilada
COPY --from=build /opt/app/dist/config ./config

# 4. Copiamos src
COPY --from=build /opt/app/src ./src

# 5. [SOLUCIÓN] Copiamos el build del Admin Panel
# Esto evita que Strapi busque en node_modules y falle
COPY --from=build /opt/app/build ./build

# 6. Crear carpeta uploads
RUN mkdir -p public/uploads

EXPOSE 1337
CMD ["pnpm", "run", "start"]