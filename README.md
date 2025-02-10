# 智能记账系统

[![Docker Build Status](https://img.shields.io/docker/cloud/build/username/finance-app)](https://hub.docker.com/r/username/finance-app)
[![Shiny Version](https://img.shields.io/badge/Shiny-1.8.0-blue)](https://shiny.rstudio.com/)

基于 R Shiny 框架开发的现代记账应用，支持 Docker 容器化部署，提供完整的财务管理和可视化分析功能。

![仪表盘截图](screenshot.png) <!-- 用户可自行添加截图 -->

## 功能特性

### 核心功能
- 💸 收支记录管理（增删改查）
- 📊 实时财务仪表盘
- 📁 CSV 数据导入/导出
- 🗓️ 日期范围智能过滤
- 🏷️ 自定义分类标签

### 统计分析
- 📈 分类消费趋势图
- 🥇 消费类别排行榜
- 💹 收支平衡预测
- 📉 月度对比分析

### 高级特性
- 🔄 数据自动持久化
- 🌍 多语言支持（当前支持中文）
- 📱 响应式布局
- 🔒 数据加密存储

## 技术栈

| 组件           | 说明              |
|--------------|-------------------|
| **前端框架**   | R Shiny           |
| **可视化**     | ggplot2           |
| **数据表格**   | DT 包             |
| **数据处理**   | dplyr + lubridate |
| **容器化**     | Docker            |
| **持久化存储** | CSV + 数据卷      |

## 快速开始

### 前置要求
- R ≥ 4.0
- RStudio ≥ 2023.03
- 或 Docker ≥ 20.10

### 本地运行
```bash
# 安装依赖
install.packages(c("shiny", "shinydashboard", "DT", "ggplot2", "dplyr", "lubridate"))

# 启动应用
shiny::runApp()
```

### Docker 部署
```bash
# 构建镜像
docker build -t finance-app .

# 运行容器（基础版）
docker run -d -p 8080:3838 --name finance-app finance-app

# 运行容器（生产版 - 含数据持久化）
docker run -d \
  -p 8080:3838 \
  --name finance-app \
  -v /host/data:/app/data \
  -e TZ=Asia/Shanghai \
  finance-app
```

## 配置选项

通过环境变量定制应用行为：

| 变量名       | 默认值    | 说明             |
|--------------|-----------|----------------|
| `APP_PORT`   | 3838      | 容器内部端口     |
| `DATA_PATH`  | /app/data | 数据存储路径     |
| `TZ`         | UTC       | 时区设置         |
| `CACHE_SIZE` | 100       | 内存缓存记录数量 |

## 文件结构

```
finance-app/
├── app.R            # 主应用文件
├── Dockerfile       # 容器构建文件
├── data/            # 数据存储目录
│   └── data.csv     # 核心数据文件
├── README.md        # 本文档
└── resources/       # 可选资源文件
    └── custom.css   # 自定义样式表
```

## 使用指南

### 1. 新增记录
1. 选择日期（默认当天）
2. 选择类型（收入/支出）
3. 选择对应分类
4. 输入金额（支持小数点）
5. 填写备注（可选）
6. 点击"提交记录"

### 2. 数据管理
- **批量删除**：勾选表格左侧复选框，点击删除按钮
- **数据导出**：点击右上角"导出数据"按钮
- **数据恢复**：直接编辑 data.csv 文件

### 3. 统计分析
- **分类统计**：自动生成交互式柱状图
- **财务概览**：实时显示三项核心指标
- **趋势分析**：横轴时间维度动态聚合

## 开发指南

### 扩展分类
修改 `app.R` 中以下部分：
```r
selectInput("category", "分类",
  choices = list(
    "支出" = c("餐饮", "购物", "住房", "交通", "娱乐"),
    "收入" = c("工资", "投资", "奖金", "其他收入")
  ))
```

### 自定义样式
1. 创建 `resources/custom.css`
2. 在 UI 中添加：
```r
tags$head(
  includeCSS("resources/custom.css")
)
```

### 数据迁移
```bash
# 从旧版本导出
docker exec finance-app cp /app/data/data.csv /backup/

# 导入新容器
docker cp ./data.csv finance-app:/app/data/
```

## 最佳实践

1. **定期备份**：建议每天备份 data.csv 文件
2. **访问控制**：配合 Nginx 添加基础认证
3. **性能优化**：当记录超过 10,000 条时启用数据库模式
4. **安全更新**：每月重建 Docker 镜像获取安全补丁

## 贡献指南

欢迎通过 Issue 和 PR 参与贡献：
1. 报告问题请提供复现步骤和截图
2. 新功能开发请先创建 Feature Request
3. 代码提交遵循 Google R Style Guide
