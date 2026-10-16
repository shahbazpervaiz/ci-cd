FROM nginx:1.27-alpine

# Values passed in by Jenkins at build time
ARG BUILD_NUMBER=local
ARG GIT_COMMIT=local
ARG GIT_BRANCH=local

COPY app/ /usr/share/nginx/html/

# Write build metadata so the page can display it
RUN printf '{"build":"%s","commit":"%s","branch":"%s","builtAt":"%s"}\n' \
    "$BUILD_NUMBER" "$GIT_COMMIT" "$GIT_BRANCH" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    > /usr/share/nginx/html/build-info.json

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost/ >/dev/null || exit 1
