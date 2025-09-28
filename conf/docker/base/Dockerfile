FROM bash

# Install tools
RUN apk add fio

# Setting Container
ADD ./docker-entrypoint.sh /docker-entrypoint.sh
WORKDIR /test
ENTRYPOINT ["bash", "/docker-entrypoint.sh"]
