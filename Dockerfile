FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN yarn global add @nestjs/cli

RUN yarn install --production

COPY . .

RUN yarn run build

EXPOSE 3000

CMD ["yarn", "run", "start:prod"]
