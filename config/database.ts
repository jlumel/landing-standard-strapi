import path from 'path';

export default ({ env }) => {
  // 1. Leemos explícitamente qué cliente nos pide el entorno (Coolify)
  const client = env('DATABASE_CLIENT', 'sqlite');

  // Debug: Esto va a salir en los logs de Coolify y nos va a confirmar si carga el archivo
  console.log('------------------------------------------------');
  console.log(`[DEBUG] Database config loading... Detected client: ${client}`);
  console.log('------------------------------------------------');

  // 2. Si Coolify dice "postgres", configuramos Postgres
  if (client === 'postgres') {
    return {
      connection: {
        client: 'postgres',
        connection: {
          host: env('DATABASE_HOST', '127.0.0.1'),
          port: env.int('DATABASE_PORT', 5432),
          database: env('DATABASE_NAME', 'strapi'),
          user: env('DATABASE_USERNAME', 'strapi'),
          password: env('DATABASE_PASSWORD', 'strapi'),
          schema: env('DATABASE_SCHEMA', 'public'),
          ssl: env.bool('DATABASE_SSL', false),
        },
        // Agregamos configuración de pool para estabilidad en producción
        pool: {
          min: env.int('DATABASE_POOL_MIN', 2),
          max: env.int('DATABASE_POOL_MAX', 10),
        },
      },
    };
  }

  // 3. Fallback a SQLite (solo para local o si no hay variables)
  return {
    connection: {
      client: 'sqlite',
      connection: {
        filename: path.join(__dirname, '..', '..', env('DATABASE_FILENAME', '.tmp/data.db')),
      },
      useNullAsDefault: true,
    },
  };
};