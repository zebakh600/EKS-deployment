# 🛠️ DevOps Quiz Platform

A full-stack DevOps quiz webapp built with **Angular 19**, **.NET 8**, and **PostgreSQL** using a microservices architecture.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Angular 19 Frontend                │
│           (Nginx reverse proxy on port 4200)         │
└────────┬──────────────┬──────────────┬──────────────┘
         │              │              │
         ▼              ▼              ▼
  ┌──────────┐  ┌────────────┐  ┌────────────┐
  │  auth-   │  │   quiz-    │  │   user-    │
  │ service  │  │  service   │  │  service   │
  │ :5001    │  │  :5002     │  │  :5003     │
  └────┬─────┘  └─────┬──────┘  └─────┬──────┘
       │               │               │
       └───────────────┴───────────────┘
                       │
               ┌───────▼──────┐
               │  PostgreSQL  │
               │    :5432     │
               └──────────────┘
```

## Microservices

| Service | Port | Responsibility |
|---|---|---|
| `frontend` | 4200 | Angular 19 SPA + Nginx reverse proxy |
| `auth-service` | 5001 | JWT auth, register, login |
| `quiz-service` | 5002 | Topics, sessions, questions, leaderboard |
| `user-service` | 5003 | User profiles and stats |
| `postgres` | 5432 | Shared PostgreSQL database |

## Features

- 🔐 **JWT Authentication** - Secure login/register
- 🧠 **100 Questions** - Covering 11 DevOps topics
- ⏱️ **30s Timer** - Per-question countdown with visual ring
- 📊 **Dashboard** - Personal progress, streaks, recent sessions
- 🏆 **Global Leaderboard** - Ranked by total score + accuracy
- 📝 **Answer Review** - Correct answers + explanations after quiz
- 📈 **Prometheus-ready** - `/metrics` on all .NET services

## Topics Covered
Linux · Git · Docker · Jenkins · Kubernetes · GitHub · GitHub Actions · Ansible · Prometheus · Grafana · CI/CD

## Quick Start

```bash
# Clone and start
git clone <repo>
cd devops-quiz
docker compose up --build

# App available at:
# http://localhost:4200       → Frontend
# http://localhost:5001/swagger → Auth Service API
# http://localhost:5002/swagger → Quiz Service API
# http://localhost:5003/swagger → User Service API
```

## Adding Prometheus + Grafana Monitoring

Monitoring stubs are already built in. To enable:

1. Uncomment the `prometheus` and `grafana` services in `docker-compose.yml`
2. The `monitoring/prometheus.yml` config is pre-configured to scrape all services
3. All .NET services expose `/metrics` in Prometheus format

## API Endpoints

### Auth Service (port 5001)
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login, returns JWT
- `GET  /api/auth/me` - Get current user (JWT required)

### Quiz Service (port 5002)
- `GET  /api/quiz/topics` - List all topics
- `POST /api/quiz/sessions/start` - Start a quiz session
- `POST /api/quiz/sessions/{id}/complete` - Submit answers
- `GET  /api/quiz/leaderboard` - Global leaderboard
- `GET  /api/quiz/progress` - User progress stats

### User Service (port 5003)
- `GET  /api/users/profile` - Get profile + stats
- `PUT  /api/users/profile` - Update avatar

## Pass/Fail Threshold
Score ≥ 60% = PASSED ✅
