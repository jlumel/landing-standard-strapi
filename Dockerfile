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

# Creamos la carpeta uploads
RUN mkdir -p public/uploads

# --- INYECCIÓN MANUAL DE CONFIGURACIONES (DB, ADMIN, SERVER, PLUGINS) ---
RUN mkdir -p config && \
    # 1. Database Config
    echo "module.exports = ({ env }) => ({ \
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
    });" > ./config/database.js && \
    # 2. Admin Config
    echo "module.exports = ({ env }) => ({ \
      auth: { \
        secret: env('ADMIN_JWT_SECRET'), \
      }, \
      apiToken: { \
        salt: env('API_TOKEN_SALT'), \
      }, \
      transfer: { \
        token: { \
          salt: env('TRANSFER_TOKEN_SALT'), \
        }, \
      }, \
    });" > ./config/admin.js && \
    # 3. Server Config
    echo "module.exports = ({ env }) => ({ \
      host: env('HOST', '0.0.0.0'), \
      port: env.int('PORT', 1337), \
      app: { \
        keys: env.array('APP_KEYS'), \
      }, \
    });" > ./config/server.js && \
    # 4. Plugins Config (ACÁ ARREGLAMOS EL ERROR ACTUAL)
    echo "module.exports = ({ env }) => ({ \
      'users-permissions': { \
        config: { \
          jwtSecret: env('JWT_SECRET'), \
        }, \
      }, \
    });" > ./config/plugins.js

EXPOSE 1337
CMD ["pnpm", "run", "start"]