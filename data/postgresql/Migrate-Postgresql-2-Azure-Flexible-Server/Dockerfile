# Use official Postgres image (change tag if you need a specific version)
FROM postgres:17

# Install envsubst for variable substitution
RUN apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*

# Environment defaults (can be overridden at runtime)
ENV POSTGRES_USER=admin \
    POSTGRES_PASSWORD=admin123 \
    POSTGRES_DB=postgres

# Copy custom entrypoint script
COPY custom-entrypoint.sh /usr/local/bin/custom-entrypoint.sh
RUN chmod +x /usr/local/bin/custom-entrypoint.sh

# Copy initialization scripts
COPY init/*.sql /docker-entrypoint-initdb.d/

# Set custom entrypoint
ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]

# Expose the default Postgres port
EXPOSE 5432
