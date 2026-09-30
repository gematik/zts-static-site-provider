FROM nginx:1.31.6-alpine3.24-slim@sha256:f761b94f2cb9e8e05e2943d5f773609596113ef69b54e2433a996d109a8f78b7

# The STOPSIGNAL instruction sets the system call signal that will be sent to the container to exit
# SIGTERM = 15 - https://de.wikipedia.org/wiki/Signal_(Unix)
STOPSIGNAL SIGTERM

# Define the exposed port or range of ports for the service
EXPOSE 8080

ENV CSP_HOSTNAME=HOST_NOT_SET

# Defining Healthcheck
HEALTHCHECK --interval=15s \
    --timeout=10s \
    --start-period=30s \
    --retries=3 \
    CMD ["/usr/bin/wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/"]

# Copy required files
COPY --chown=nginx:nginx ./config/docker /

USER root

## Add permissions
RUN chmod +x /docker-entrypoint.d/*.sh

## switch to non-root user
USER nginx

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["nginx", "-c", "/tmp/nginx.conf", "-g", "daemon off;"]

###########################
# Labels
###########################

ARG COMMIT_HASH
ARG VERSION

LABEL de.gematik.commit-sha=$COMMIT_HASH \
    de.gematik.version=$VERSION \
    de.gematik.vendor="gematik GmbH" \
    maintainer="zts@gematik.de" \
    de.gematik.app="ZTS Static Site Provider" \
    de.gematik.git-repo-name="https://gitlab.prod.ccs.gematik.solutions/zts/frontend/static_site_provider.git"
