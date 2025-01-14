# 第一阶段: 构建 Vue.js 应用
FROM node:18 AS build-stage

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 package-lock.json 到工作目录
COPY package*.json ./


# 复制应用代码
COPY . .

# 删除 node_modules 和 package-lock.json 以避免缓存问题
RUN rm -rf node_modules package-lock.json

# 安装依赖
RUN npm install --production=false

# 构建 Vue.js 应用
RUN npm run build

# 第二阶段: 使用 nginx 来服务 Vue.js 应用
FROM nginxinc/nginx-unprivileged:alpine

# 设置工作目录
WORKDIR /app

# 删除默认的 nginx html 文件夹，并将 Vue.js 应用复制到 nginx 的默认目录中
COPY --from=build-stage /app/dist /usr/share/nginx/html

# 暴露 3600 端口
EXPOSE 3600

# 确保 nginx 配置文件正确
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# 启动 nginx
CMD ["nginx", "-g", "daemon off;"]
