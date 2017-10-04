FROM swift:3.1 

RUN apt-get -y update && apt-get -y upgrade && \
    apt-get install -y  libssl-dev uuid-dev libpq-dev libxml2-dev pkg-config && \
    mkdir -p /var/www/til 

WORKDIR /var/www/til 

ADD Package.swift Package.swift 
RUN swift package fetch 

ADD Sources Sources 
RUN swift build --configuration release 

ADD webroot webroot 

EXPOSE 8080
ENTRYPOINT ["./.build/release/til"]
