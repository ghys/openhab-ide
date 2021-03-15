FROM node:12
WORKDIR /app
COPY package.json .

# Install gen-http-proxy for HTTPS access
RUN npm install -g gen-http-proxy
COPY ssl_theia.sh . 

ARG LISTEN_PORT=10443

# Set the parameters for the gen-http-proxy
ENV staticfolder /usr/local/lib/node_modules/gen-http-proxy/static 
ENV server :$LISTEN_PORT
ENV target localhost:3000
ENV secure 1

# Install & dependencies
RUN yarn

# Build Theia & install gen-http-proxy
RUN yarn run clean && \
    yarn run build && \
    yarn theia download:plugins

RUN chmod +x /app/ssl_theia.sh

ENTRYPOINT [ "/app/ssl_theia.sh" ]
