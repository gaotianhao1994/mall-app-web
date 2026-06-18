# ============================================================
#  mall-app-web 前端 Dockerfile
#
#  多阶段构建：
#    Stage 1: 用 Node.js 构建前端静态文件
#    Stage 2: 用 Nginx 服务静态文件
# ============================================================

# Stage 1: 构建
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install --registry=https://registry.npmmirror.com

COPY . .
RUN npm run build:h5

# Stage 2: 运行
FROM nginx:1.22

# 复制构建产物到 Nginx 静态目录
COPY --from=builder /app/dist/build/h5 /usr/share/nginx/html

# 复制 Nginx 配置
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:80/ || exit 1
