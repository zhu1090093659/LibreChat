# # v0.7.6

# # Base node image
# FROM node:20-alpine AS node

# RUN apk --no-cache add curl

# RUN mkdir -p /app && chown node:node /app
# WORKDIR /app

# USER node

# COPY --chown=node:node . .

# RUN \
#     # Allow mounting of these files, which have no default
#     touch .env ; \
#     # Create directories for the volumes to inherit the correct permissions
#     mkdir -p /app/client/public/images /app/api/logs ; \
#     npm config set fetch-retry-maxtimeout 600000 ; \
#     npm config set fetch-retries 5 ; \
#     npm config set fetch-retry-mintimeout 15000 ; \
#     npm install --no-audit; \
#     # React client build
#     NODE_OPTIONS="--max-old-space-size=2048" npm run frontend; \
#     npm prune --production; \
#     npm cache clean --force

# RUN mkdir -p /app/client/public/images /app/api/logs

# # Node API setup
# EXPOSE 3080
# ENV HOST=0.0.0.0
# CMD ["npm", "run", "backend"]

# # Optional: for client with nginx routing
# # FROM nginx:stable-alpine AS nginx-client
# # WORKDIR /usr/share/nginx/html
# # COPY --from=node /app/client/dist /usr/share/nginx/html
# # COPY client/nginx.conf /etc/nginx/conf.d/default.conf
# # ENTRYPOINT ["nginx", "-g", "daemon off;"]


# Pull the base image
FROM ghcr.io/danny-avila/librechat-dev:latest

# FROM ghcr.io/danny-avila/librechat-dev:0a1d38e3189a4f905d021be41ac2c8b5bd03d8b7


# Set environment variables
ENV HOST=0.0.0.0
ENV PORT=7860
ENV SESSION_EXPIRY=900000
ENV REFRESH_TOKEN_EXPIRY=604800000
ENV SEARCH=false
# ENV MEILI_NO_ANALYTICS=true
# ENV MEILI_HOST=https://librechat-meilisearch.hf.space

# Create necessary directories
RUN mkdir -p /app/uploads/temp
RUN mkdir -p /app/client/public/images/temp
RUN mkdir -p /app/api/logs/
RUN mkdir -p /app/data

# Give write permission to the directory
RUN chmod -R 777 /app/uploads/temp
RUN chmod -R 777 /app/client/public/images
RUN chmod -R 777 /app/api/logs/
RUN chmod -R 777 /app/data


# Copy Custom Endpoints Config
# RUN curl -o /app/librechat.yaml https://raw.githubusercontent.com/LibreChat-AI/librechat-config-yaml/main/librechat-hf.yaml
COPY librechat.yaml /app/librechat.yaml
COPY .env /app/.env


# Install dependencies
RUN cd /app/api && npm install

# Command to run on container start
CMD ["npm", "run", "backend"]
