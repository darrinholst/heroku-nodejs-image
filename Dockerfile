# Inherit Heroku OS
FROM heroku/heroku:18.v46

# Set the PATH for Node and any installed runnables
ENV PATH /app/heroku/node/bin/:/app/user/node_modules/.bin:$PATH

# Add gpg keys listed at https://github.com/nodejs/node#release-keys
RUN set -ex \
  && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    74F12602B6F1C4E913FAA37AD3A89613643B6201 \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

# Create Node installation directory
RUN mkdir -p /app/heroku/node

# Create Heroku setup directory
RUN mkdir -p /app/.profile.d

# Change to working directory
WORKDIR /app/user

# Install xz
RUN apt-get update && apt-get install -y xz-utils && apt-get autoremove && apt-get clean

# Set Node Version
ENV NODE_ENGINE 12.20.1

# Install Node
RUN curl -SLO "https://nodejs.org/dist/v$NODE_ENGINE/node-v$NODE_ENGINE-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_ENGINE/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_ENGINE-linux-x64.tar.xz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xJf "node-v$NODE_ENGINE-linux-x64.tar.xz" -C /app/heroku/node --strip-components=1 \
  && rm "node-v$NODE_ENGINE-linux-x64.tar.xz" SHASUMS256.txt.asc

# Make the PATH available to Heroku by export to .profile.d
RUN echo "export PATH=\"/app/heroku/node/bin:/app/user/node_modules/.bin:\$PATH\"" > /app/.profile.d/nodejs.sh

# Install Yarn
RUN npm install --global yarn@latest

RUN echo "\n \
    node: $(node --version) \n \
    npm: $(npm --version) \n \
    yarn: $(yarn --version) \n \
"
