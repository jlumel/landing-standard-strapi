export default ({ env }) => {
    if (process.env.NODE_ENV === 'production') {
        return {
            redis: {
                config: {
                    connections: {
                        default: {
                            connection: {
                                host: env('REDIS_HOST', 'localhost'),
                                port: env.int('REDIS_PORT', 6379),
                                db: env.int('REDIS_DB', 1),
                                password: env('REDIS_PASSWORD'),
                            },
                            settings: {
                                debug: false,
                            },
                        },
                    },
                },
            },
        };
    }

    return {};
};

