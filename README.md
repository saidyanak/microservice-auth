# 🔐 Microservice Auth System

[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://openjdk.org/projects/jdk/21/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.0-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Spring Cloud](https://img.shields.io/badge/Spring%20Cloud-2024.0.0-brightgreen.svg)](https://spring.io/projects/spring-cloud)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **Production-ready microservice authentication system** with JWT, Email verification, Monitoring (Grafana + Loki), and more. Clone and customize for your own projects!

## ✨ Features

- 🔐 **JWT Authentication** - Secure access & refresh token system
- 📧 **Email Verification** - Registration email verification flow
- 🔑 **Password Reset** - Forgot password with email link
- 👥 **Role-Based Access** - ADMIN / USER roles (easily extensible)
- 🌐 **API Gateway** - Single entry point with JWT validation
- 📊 **Monitoring Stack** - Grafana + Loki + Promtail for log visualization
- 📬 **Mail Service** - Async email sending via RabbitMQ
- 🔍 **Service Discovery** - Netflix Eureka for service registration
- 📝 **Swagger UI** - Interactive API documentation
- 🐳 **Docker Ready** - PostgreSQL, RabbitMQ, MailHog containers

## 🏗 Architecture

```
                                    ┌─────────────────┐
                                    │   Your Frontend │
                                    │  (React/Vue/etc)│
                                    └────────┬────────┘
                                             │
                                             ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            API Gateway (8080)                                │
│                    • JWT Validation • Rate Limiting • Routing                │
└─────────────────────────────────────┬───────────────────────────────────────┘
                                      │
                 ┌────────────────────┼────────────────────┐
                 │                    │                    │
                 ▼                    ▼                    ▼
    ┌────────────────────┐ ┌──────────────────┐ ┌──────────────────┐
    │   Auth Service     │ │   Mail Service   │ │  Your Services   │
    │      (8081)        │ │     (8082)       │ │    (Add here)    │
    │                    │ │                  │ │                  │
    │ • Register/Login   │ │ • Welcome Email  │ │ • Custom logic   │
    │ • JWT Generation   │ │ • Password Reset │ │ • Business APIs  │
    │ • Password Reset   │ │ • Notifications  │ │                  │
    └─────────┬──────────┘ └────────┬─────────┘ └──────────────────┘
              │                     │
              │     RabbitMQ        │
              ▼     (Events)        ▼
    ┌──────────────────┐  ┌──────────────────┐
    │   PostgreSQL     │  │    MailHog       │
    │   (Auth DB)      │  │  (Dev SMTP)      │
    └──────────────────┘  └──────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                    Monitoring Stack                               │
│  ┌──────────┐    ┌──────────┐    ┌──────────────────┐           │
│  │ Promtail │───▶│   Loki   │───▶│     Grafana      │           │
│  │(Collector)│   │(Storage) │    │  (Visualization) │           │
│  └──────────┘    └──────────┘    │   localhost:3001 │           │
│                                   └──────────────────┘           │
└──────────────────────────────────────────────────────────────────┘

                    ┌──────────────────────────┐
                    │   Discovery Server       │
                    │   (Eureka - 8761)        │
                    │   Service Registry       │
                    └──────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Java 21+
- Docker & Docker Compose
- Maven 3.9+

### 1. Clone & Start Infrastructure

```bash
git clone https://github.com/YOUR_USERNAME/microservice-auth.git
cd microservice-auth

# Start PostgreSQL, RabbitMQ, MailHog
make infra-start

# Start monitoring (Grafana + Loki)
make start-monitoring
```

### 2. Start Services

```bash
# Start all services (Discovery → Gateway → Auth → Mail)
make start

# Or quick start (parallel)
make quick-start
```

### 3. Access Points

| Service | URL | Description |
|---------|-----|-------------|
| **API Gateway** | http://localhost:8080 | Main API endpoint |
| **Swagger UI** | http://localhost:8080/swagger-ui.html | API Documentation |
| **Eureka Dashboard** | http://localhost:8761 | Service Registry |
| **Grafana** | http://localhost:3001 | Log Visualization (admin/admin123) |
| **MailHog** | http://localhost:8025 | Email Testing UI |
| **RabbitMQ** | http://localhost:15672 | Message Queue (guest/guest) |

## 📖 API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Register new user |
| POST | `/api/v1/auth/login` | Login and get tokens |
| POST | `/api/v1/auth/refresh` | Refresh access token |
| POST | `/api/v1/auth/logout` | Invalidate refresh token |
| GET | `/api/v1/auth/verify-email?token=xxx` | Verify email address |
| POST | `/api/v1/auth/forgot-password` | Request password reset |
| POST | `/api/v1/auth/reset-password` | Reset password with token |
| GET | `/api/v1/auth/me` | Get current user info |

### Example: Register

```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

### Example: Login

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

## 👥 Roles

By default, the system includes two roles:

```java
public enum Role {
    ADMIN,  // System administrators with full access
    USER    // Regular users with standard access
}
```

### Extending Roles

To add custom roles, edit `common/src/main/java/.../enums/Role.java`:

```java
public enum Role {
    ADMIN,
    USER,
    MODERATOR,  // Add your custom roles
    PREMIUM_USER
}
```

## 🔧 Configuration

### JWT Settings (auth-service/application.yml)

```yaml
jwt:
  secret: your-256-bit-secret-key
  access-token-expiration: 900000    # 15 minutes
  refresh-token-expiration: 604800000 # 7 days
```

### Database (auth-service/application.yml)

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/auth_db
    username: postgres
    password: postgres
```

## 📁 Project Structure

```
microservice-auth/
├── api-gateway/          # Spring Cloud Gateway
├── auth-service/         # Authentication service
├── mail-service/         # Email notification service
├── discovery-server/     # Netflix Eureka
├── common/               # Shared DTOs, Events, Enums
├── monitoring/           # Grafana, Loki, Promtail configs
├── docker-compose.dev.yml
├── Makefile              # Convenient commands
└── README.md
```

## 🛠 Make Commands

```bash
make help              # Show all commands
make start             # Start all services
make stop              # Stop all services
make restart           # Restart all services
make status            # Check service status
make logs              # View all logs
make infra-start       # Start Docker infrastructure
make start-monitoring  # Start Grafana + Loki
make clean             # Clean build artifacts
```

## 🆕 Adding New Services

1. Create new module directory
2. Add `pom.xml` with parent reference:
   ```xml
   <parent>
       <groupId>com.microservice</groupId>
       <artifactId>microservice-auth</artifactId>
       <version>1.0.0-SNAPSHOT</version>
   </parent>
   ```
3. Add module to root `pom.xml`:
   ```xml
   <modules>
       ...
       <module>your-new-service</module>
   </modules>
   ```
4. Add route in `api-gateway/application.yml`
5. Add start/stop commands in `Makefile`

## 📊 Monitoring

### Grafana Dashboard

Access Grafana at http://localhost:3001 (admin/admin123)

Pre-configured dashboard shows:
- All service logs in real-time
- Filter by service, log level
- Error tracking and alerts

### Log Query Examples (Loki)

```
# All auth-service logs
{job="app-logs", filename=~".*auth-service.*"}

# Only ERROR level
{job="app-logs"} |= "ERROR"

# Specific user actions
{job="app-logs"} |~ "User registered|User logged in"
```

## 🐳 Docker Deployment

```bash
# Build all services
mvn clean package -DskipTests

# Build Docker images
docker-compose build

# Start production stack
docker-compose up -d
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Spring Boot & Spring Cloud teams
- Netflix OSS (Eureka)
- Grafana Labs (Loki, Grafana)

---

**⭐ Star this repo if you find it useful!**
