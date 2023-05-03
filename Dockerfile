FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN yarn install --production

RUN yarn run build

COPY . .

EXPOSE 3000

CMD ["yarn", "run", "start:prod"]
