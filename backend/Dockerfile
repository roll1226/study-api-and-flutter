FROM node:18.18.0

# 作業ディレクトリを設定
WORKDIR /backend

COPY package*.json ./
RUN npm install

COPY . .

CMD ["npm", "run", "dev"]

EXPOSE 3000
