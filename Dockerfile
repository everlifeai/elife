FROM node:14.16.1

RUN npm install -g npm@latest

EXPOSE 7766
EXPOSE 8996
EXPOSE 8997

WORKDIR /elife
COPY . .
RUN npm install
CMD ["node", "run.js" ]
