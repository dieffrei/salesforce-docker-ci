FROM alpine:3.9
MAINTAINER Peter van Gulik <peter@curlybracket.nl>

# Add packages
RUN apk --no-cache add \ 
    bash \
    openssh \
    git \
    openjdk8 \
    nodejs \
    npm \
    curl \ 
    wget \
    unzip \
    nss \
    jq \
    libsecret \
    && apk add apache-ant --no-cache --update-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
    --allow-untrusted

# Copy build files
COPY build /build/

# Setup Ant
ENV ANT_HOME=/usr/share/java/apache-ant \
    PATH=$PATH:$ANT_HOME/bin \
    SFDX_USE_GENERIC_UNIX_KEYCHAIN=true \
    SFDX_AUTOUPDATE_DISABLE=true

# Install SFDX
RUN npm install sfdx-cli --global
RUN sfdx --version
RUN sfdx plugins --core

# Install JSForce
RUN npm install jsforce

# Download Sonarscanner
RUN curl -SL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492.zip -o sonar.zip \
    && unzip sonar.zip \
    && mv sonar-scanner-3.3.0.1492 sonar-scanner \
    && ln -sf /sonar-scanner/bin/sonar-scanner /usr/bin/sonar-scanner \
    && ln -sf /sonar-scanner/bin/sonar-scanner-debug /usr/bin/sonar-scanner-debug \
    && rm -rf sonar.zip

# Setup entry point to use umask 0000 and run bash
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod ugo+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
# EOF
