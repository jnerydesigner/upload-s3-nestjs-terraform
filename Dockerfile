# Stage 1: Install dependencies
FROM node:current-alpine3.22 AS deps

RUN apk update && apk upgrade

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile

# Stage 2: Build Image
FROM node:current-alpine3.22

COPY --from=deps /app/node_modules ./node_modules

COPY package.json yarn.lock ./

COPY . .

RUN yarn build

EXPOSE 3388

CMD ["yarn", "start:prod"]

