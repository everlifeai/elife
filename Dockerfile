FROM node:8.12.0-jessie
RUN cd /root && \
    wget http://download.redis.io/releases/redis-4.0.11.tar.gz && \
    tar xzf redis-4.0.11.tar.gz && \
    cd redis-4.0.11 && \
    make
