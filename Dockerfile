FROM node:14.16.1

EXPOSE 7766
EXPOSE 8996
EXPOSE 8997

WORKDIR /elife
COPY . .
RUN npm install --production
CMD ["npm", "start" ]
