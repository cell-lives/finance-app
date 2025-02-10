# Dockerfile
# 使用官方 Shiny 镜像作为基础
FROM rocker/shiny:4.3.1

# 设置中文语言环境
ENV LANG C.UTF-8

# 设置清华镜像源
RUN echo "options(repos = c(CRAN = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN/'))" >> /usr/local/lib/R/etc/Rprofile.site

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装所需 R 包
RUN R -e "install.packages(c('shinydashboard', 'DT', 'ggplot2', 'dplyr', 'lubridate'))"

# 创建应用目录
RUN mkdir -p /app/data && \
    chown -R shiny:shiny /app && \
    chmod -R 755 /app

# 复制应用文件
COPY app.R /app/

# 设置工作目录
WORKDIR /app

# 暴露 Shiny 端口
EXPOSE 3838

# 设置容器启动命令
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]
