FROM node:20-alpine AS build
WORKDIR /app
COPY package.json ./
COPY scripts ./scripts
COPY src ./src
RUN npm run lint && npm test && npm run build

FROM nginxinc/nginx-unprivileged:1.25-alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --retries=5 CMD wget -qO- http://127.0.0.1:8080/ >/dev/null || exit 1
