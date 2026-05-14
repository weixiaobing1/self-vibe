<p align="center">
  <h1 align="center">MindFlow AI</h1>
  <p align="center">AI 驱动的学习助手 — 记录、整理、复习、面试，一站式知识管理</p>
</p>

---

## 简介

MindFlow 帮助程序员和大学生将零散的学习内容转化为结构化知识：

- **AI 自动总结** — 输入学习内容，AI 提取知识点、分类、打标签
- **AI 面试题生成** — 根据知识点自动生成面试题和参考答案
- **AI 代码解释** — 上传代码，AI 分析逻辑并提供优化建议
- **智能复习计划** — 基于艾宾浩斯遗忘曲线自动安排复习
- **学习统计** — 可视化学习时长、趋势、技术栈分布
- **移动端 APP** — Flutter 构建，一套代码同时运行 Android / iOS

## 技术栈

| 层 | 技术 |
|---|------|
| 后端 | Java 17, Spring Boot 3.2, MyBatis Plus, Spring AI |
| 前端 | Flutter 3.x (Android + iOS + Web) |
| 数据库 | MySQL 8.0 |
| 缓存 | Redis 7 |
| AI | DeepSeek API (兼容 OpenAI) |
| 鉴权 | JWT (Access + Refresh Token) |
| 部署 | Docker + Docker Compose |

## 项目结构

```
├── backend/              # Spring Boot 后端
│   ├── src/main/java/com/mindflow/
│   │   ├── controller/   # REST 控制器
│   │   ├── service/      # 业务逻辑
│   │   ├── mapper/       # MyBatis 数据访问
│   │   ├── entity/       # 数据库实体
│   │   ├── dto/          # 请求参数
│   │   ├── config/       # Spring 配置
│   │   ├── utils/        # 工具类 (JWT, Redis, 复习算法)
│   │   └── common/       # 统一返回、错误码、异常
│   ├── Dockerfile
│   └── pom.xml
├── frontend/             # Flutter 移动端
│   ├── lib/
│   │   ├── pages/        # 页面
│   │   ├── models/       # 数据模型
│   │   ├── services/     # API 调用
│   │   └── config/       # 主题、API 配置
│   ├── Dockerfile
│   └── nginx.conf
├── docker/               # Docker Compose 编排
│   └── docker-compose.yml
├── deploy.sh             # 服务器一键部署脚本
└── .env.example          # 环境变量模板
```

## 本地开发

### 前置条件

- JDK 17+
- Maven 3.9+
- Flutter 3.x
- Docker Desktop（MySQL + Redis）

### 启动数据库

```bash
docker compose -f docker/docker-compose.yml up -d mysql redis
```

### 启动后端

```bash
cd backend
mvn spring-boot:run
```

后端启动后访问 http://localhost:8080/swagger-ui.html 查看 API 文档。

### 启动前端

```bash
cd frontend
flutter pub get
flutter run -d chrome        # Web 模式
# flutter run -d <device-id> # 真机模式
```

## 服务器部署

服务器要求：Ubuntu 22.04+，2核2G+

```bash
# 1. 克隆项目
git clone https://github.com/weixiaobing1/self-vibe.git
cd self-vibe

# 2. 配置环境变量
cp .env.example docker/.env
vim docker/.env    # 填入 AI_API_KEY 和 JWT_SECRET

# 3. 一键部署
bash deploy.sh
```

## API 概览

| 模块 | 接口 | 说明 |
|------|------|------|
| 用户 | `POST /api/user/register` | 注册 |
| 用户 | `POST /api/user/login` | 登录（返回 JWT） |
| 笔记 | `POST /api/note/create` | 创建笔记（AI 自动总结） |
| 笔记 | `GET /api/note/list` | 笔记列表（支持分页、搜索） |
| AI | `POST /api/ai/chat` | AI 对话（带上下文） |
| AI | `POST /api/ai/summarize` | AI 总结笔记 |
| AI | `POST /api/ai/generate-interview` | 生成面试题 |
| 复习 | `GET /api/review/today` | 今日复习任务 |
| 复习 | `POST /api/review/complete` | 完成复习 |

完整 API 文档：启动后访问 `/swagger-ui.html`

## License

MIT
