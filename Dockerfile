FROM node:14.16.1

RUN npm install -g npm@latest

RUN apt-get update && apt-get install -y vim

WORKDIR /everlife-server-node
COPY . .
RUN npm install
CMD ["/bin/bash", "./run-linux.sh"]
