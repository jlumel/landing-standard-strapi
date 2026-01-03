# -----------------------------------------------------------------------------
# BASE
# -----------------------------------------------------------------------------
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

RUN apk update && apk add --no-cache \
    build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git > /dev/null 2>&1

WORKDIR /opt/app

# -----------------------------------------------------------------------------
# BUILD
# -----------------------------------------------------------------------------
FROM base AS build
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod=false
COPY . .
ENV NODE_ENV=production
RUN pnpm run build
RUN pnpm prune --prod

# -----------------------------------------------------------------------------
# RUNNER
# -----------------------------------------------------------------------------
FROM base AS runner
ENV NODE_ENV=production

# Copiamos lo esencial
COPY --from=build /opt/app/node_modules ./node_modules
COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/package.json ./package.json
COPY --from=build /opt/app/favicon.png ./favicon.png
COPY --from=build /opt/app/src ./src

# --- CORRECCIÓN NUEVA: CREAR CARPETA UPLOADS ---
# Creamos la carpeta manualmente para que Strapi no llore al arrancar
RUN mkdir -p public/uploads

# --- INYECCIÓN DE CONFIGURACIÓN DB (LA QUE YA FUNCIONÓ) ---
RUN mkdir -p config && \
    echo "module.exports = ({ env }) => { \
      console.log('--- [DEBUG] CARGANDO CONFIGURACION INYECTADA POR DOCKER ---'); \
      return { \
        connection: { \
          client: 'postgres', \
          connection: { \
            host: env('DATABASE_HOST'), \
            port: env.int('DATABASE_PORT', 5432), \
            database: env('DATABASE_NAME'), \
            user: env('DATABASE_USERNAME'), \
            password: env('DATABASE_PASSWORD'), \
            ssl: env.bool('DATABASE_SSL', false), \
          }, \
          pool: { min: 2, max: 10 } \
        } \
      }; \
    };" > ./config/database.js

EXPOSE 1337
CMD ["pnpm", "run", "start"]