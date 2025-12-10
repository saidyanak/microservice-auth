# Microservice Auth System - Makefile
# Production-ready authentication microservices

.PHONY: all build clean start stop restart status logs \
        start-infra stop-infra \
        start-discovery start-gateway start-auth start-mail \
        stop-discovery stop-gateway stop-auth stop-mail \
        test install help

# Renkler
GREEN := \033[0;32m
RED := \033[0;31m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# PID dosyaları
PID_DIR := .pids
DISCOVERY_PID := $(PID_DIR)/discovery.pid
GATEWAY_PID := $(PID_DIR)/gateway.pid
AUTH_PID := $(PID_DIR)/auth.pid
MAIL_PID := $(PID_DIR)/mail.pid

# Portlar
DISCOVERY_PORT := 8761
GATEWAY_PORT := 8080
AUTH_PORT := 8081
MAIL_PORT := 8082

# ============================================
# ANA KOMUTLAR
# ============================================

help: ## Yardım menüsü
	@echo ""
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║     Career Portal Backend - Komut Listesi                  ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Ana Komutlar:$(NC)"
	@echo "  make start          - Tüm servisleri başlat (infra + apps)"
	@echo "  make stop           - Tüm servisleri durdur"
	@echo "  make restart        - Tüm servisleri yeniden başlat"
	@echo "  make status         - Servis durumlarını göster"
	@echo ""
	@echo "$(GREEN)Build Komutları:$(NC)"
	@echo "  make build          - Tüm modülleri derle"
	@echo "  make install        - Tüm modülleri derle ve yükle"
	@echo "  make clean          - Build dosyalarını temizle"
	@echo "  make test           - Testleri çalıştır"
	@echo ""
	@echo "$(GREEN)Altyapı Komutları:$(NC)"
	@echo "  make start-infra    - Docker altyapısını başlat (DB, RabbitMQ, MailHog)"
	@echo "  make stop-infra     - Docker altyapısını durdur"
	@echo ""
	@echo "$(GREEN)Bireysel Servis Komutları:$(NC)"
	@echo "  make start-discovery  - Discovery Server başlat"
	@echo "  make start-gateway    - API Gateway başlat"
	@echo "  make start-auth       - Auth Service başlat"
	@echo "  make start-mail       - Mail Service başlat"
	@echo ""
	@echo "  make stop-discovery   - Discovery Server durdur"
	@echo "  make stop-gateway     - API Gateway durdur"
	@echo "  make stop-auth        - Auth Service durdur"
	@echo "  make stop-mail        - Mail Service durdur"
	@echo ""
	@echo "$(GREEN)Log Komutları:$(NC)"
	@echo "  make logs           - Tüm logları göster"
	@echo "  make logs-auth      - Auth Service loglarını göster"
	@echo "  make logs-mail      - Mail Service loglarını göster"
	@echo "  make logs-errors    - Error loglarını göster"
	@echo ""
	@echo "$(GREEN)Monitoring Komutları:$(NC)"
	@echo "  make start-monitoring - Grafana + Loki başlat"
	@echo "  make stop-monitoring  - Grafana + Loki durdur"
	@echo ""
	@echo "$(YELLOW)Erişim URL'leri:$(NC)"
	@echo "  Eureka Dashboard:   http://localhost:8761"
	@echo "  API Gateway:        http://localhost:8080"
	@echo "  RabbitMQ:           http://localhost:15672 (guest/guest)"
	@echo "  MailHog:            http://localhost:8025"
	@echo "  Grafana:            http://localhost:3001 (admin/admin123)"
	@echo ""

all: build ## Derle

# ============================================
# BUILD KOMUTLARI
# ============================================

build: ## Tüm modülleri derle
	@echo "$(BLUE)► Proje derleniyor...$(NC)"
	@mvn clean compile -DskipTests
	@echo "$(GREEN)✓ Derleme tamamlandı$(NC)"

install: ## Tüm modülleri derle ve local repo'ya yükle
	@echo "$(BLUE)► Proje derleniyor ve yükleniyor...$(NC)"
	@mvn clean install -DskipTests
	@echo "$(GREEN)✓ Yükleme tamamlandı$(NC)"

clean: ## Build dosyalarını temizle
	@echo "$(BLUE)► Temizleniyor...$(NC)"
	@mvn clean
	@rm -rf $(PID_DIR)
	@echo "$(GREEN)✓ Temizlendi$(NC)"

test: ## Testleri çalıştır
	@echo "$(BLUE)► Testler çalıştırılıyor...$(NC)"
	@mvn test
	@echo "$(GREEN)✓ Testler tamamlandı$(NC)"

# ============================================
# ALTYAPI KOMUTLARI
# ============================================

start-infra: ## Docker altyapısını başlat
	@echo "$(BLUE)► Docker altyapısı başlatılıyor...$(NC)"
	@docker-compose -f docker-compose.dev.yml up -d auth-db rabbitmq mailhog
	@echo "$(GREEN)✓ PostgreSQL, RabbitMQ, MailHog başlatıldı$(NC)"
	@sleep 3
	@make infra-status

stop-infra: ## Docker altyapısını durdur
	@echo "$(BLUE)► Docker altyapısı durduruluyor...$(NC)"
	@docker-compose -f docker-compose.dev.yml down
	@echo "$(GREEN)✓ Altyapı durduruldu$(NC)"

# ============================================
# MONITORING KOMUTLARI (Grafana + Loki)
# ============================================

start-monitoring: ## Grafana + Loki monitoring başlat
	@echo "$(BLUE)► Monitoring stack başlatılıyor...$(NC)"
	@mkdir -p logs
	@docker-compose -f docker-compose.dev.yml up -d loki promtail grafana
	@echo "$(GREEN)✓ Loki, Promtail, Grafana başlatıldı$(NC)"
	@echo ""
	@echo "$(YELLOW)Grafana: http://localhost:3001$(NC)"
	@echo "$(YELLOW)Kullanıcı: admin / Şifre: admin123$(NC)"

stop-monitoring: ## Grafana + Loki monitoring durdur
	@echo "$(BLUE)► Monitoring stack durduruluyor...$(NC)"
	@docker stop grafana promtail loki 2>/dev/null || true
	@docker rm grafana promtail loki 2>/dev/null || true
	@echo "$(GREEN)✓ Monitoring durduruldu$(NC)"

monitoring-status: ## Monitoring durumunu göster
	@echo ""
	@echo "$(BLUE)Monitoring Durumu:$(NC)"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "loki|promtail|grafana|NAMES" || echo "  Monitoring çalışmıyor"
	@echo ""

infra-status: ## Docker container durumları
	@echo ""
	@echo "$(BLUE)Docker Container Durumları:$(NC)"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "auth-db|rabbitmq|mailhog|NAMES" || echo "  Çalışan container yok"
	@echo ""

# ============================================
# PID KLASÖRÜ
# ============================================

$(PID_DIR):
	@mkdir -p $(PID_DIR)

# ============================================
# SERVİS BAŞLATMA
# ============================================

start-discovery: $(PID_DIR) ## Discovery Server başlat
	@if [ -f $(DISCOVERY_PID) ] && kill -0 $$(cat $(DISCOVERY_PID)) 2>/dev/null; then \
		echo "$(YELLOW)⚠ Discovery Server zaten çalışıyor (PID: $$(cat $(DISCOVERY_PID)))$(NC)"; \
	else \
		echo "$(BLUE)► Discovery Server başlatılıyor (port $(DISCOVERY_PORT))...$(NC)"; \
		cd discovery-server && mvn spring-boot:run -Dspring-boot.run.jvmArguments="-DLOG_PATH=../logs" > /dev/null 2>&1 & echo $$! > $(DISCOVERY_PID); \
		sleep 5; \
		if curl -s http://localhost:$(DISCOVERY_PORT) > /dev/null 2>&1; then \
			echo "$(GREEN)✓ Discovery Server başlatıldı (PID: $$(cat $(DISCOVERY_PID)))$(NC)"; \
		else \
			echo "$(YELLOW)⏳ Discovery Server başlatılıyor... (PID: $$(cat $(DISCOVERY_PID)))$(NC)"; \
		fi \
	fi

start-gateway: $(PID_DIR) ## API Gateway başlat
	@if [ -f $(GATEWAY_PID) ] && kill -0 $$(cat $(GATEWAY_PID)) 2>/dev/null; then \
		echo "$(YELLOW)⚠ API Gateway zaten çalışıyor (PID: $$(cat $(GATEWAY_PID)))$(NC)"; \
	else \
		echo "$(BLUE)► API Gateway başlatılıyor (port $(GATEWAY_PORT))...$(NC)"; \
		cd api-gateway && mvn spring-boot:run -Dspring-boot.run.jvmArguments="-DLOG_PATH=../logs" > /dev/null 2>&1 & echo $$! > $(GATEWAY_PID); \
		sleep 5; \
		if curl -s http://localhost:$(GATEWAY_PORT)/actuator/health > /dev/null 2>&1; then \
			echo "$(GREEN)✓ API Gateway başlatıldı (PID: $$(cat $(GATEWAY_PID)))$(NC)"; \
		else \
			echo "$(YELLOW)⏳ API Gateway başlatılıyor... (PID: $$(cat $(GATEWAY_PID)))$(NC)"; \
		fi \
	fi

start-auth: $(PID_DIR) ## Auth Service başlat
	@if [ -f $(AUTH_PID) ] && kill -0 $$(cat $(AUTH_PID)) 2>/dev/null; then \
		echo "$(YELLOW)⚠ Auth Service zaten çalışıyor (PID: $$(cat $(AUTH_PID)))$(NC)"; \
	else \
		echo "$(BLUE)► Auth Service başlatılıyor (port $(AUTH_PORT))...$(NC)"; \
		cd auth-service && mvn spring-boot:run -Dspring-boot.run.jvmArguments="-DLOG_PATH=../logs" > /dev/null 2>&1 & echo $$! > $(AUTH_PID); \
		sleep 5; \
		if curl -s http://localhost:$(AUTH_PORT)/actuator/health > /dev/null 2>&1; then \
			echo "$(GREEN)✓ Auth Service başlatıldı (PID: $$(cat $(AUTH_PID)))$(NC)"; \
		else \
			echo "$(YELLOW)⏳ Auth Service başlatılıyor... (PID: $$(cat $(AUTH_PID)))$(NC)"; \
		fi \
	fi

start-mail: $(PID_DIR) ## Mail Service başlat
	@if [ -f $(MAIL_PID) ] && kill -0 $$(cat $(MAIL_PID)) 2>/dev/null; then \
		echo "$(YELLOW)⚠ Mail Service zaten çalışıyor (PID: $$(cat $(MAIL_PID)))$(NC)"; \
	else \
		echo "$(BLUE)► Mail Service başlatılıyor (port $(MAIL_PORT))...$(NC)"; \
		cd mail-service && mvn spring-boot:run -Dspring-boot.run.jvmArguments="-DLOG_PATH=../logs" > /dev/null 2>&1 & echo $$! > $(MAIL_PID); \
		sleep 5; \
		if curl -s http://localhost:$(MAIL_PORT)/actuator/health > /dev/null 2>&1; then \
			echo "$(GREEN)✓ Mail Service başlatıldı (PID: $$(cat $(MAIL_PID)))$(NC)"; \
		else \
			echo "$(YELLOW)⏳ Mail Service başlatılıyor... (PID: $$(cat $(MAIL_PID)))$(NC)"; \
		fi \
	fi

# ============================================
# SERVİS DURDURMA
# ============================================

stop-discovery: ## Discovery Server durdur
	@if [ -f $(DISCOVERY_PID) ]; then \
		echo "$(BLUE)► Discovery Server durduruluyor...$(NC)"; \
		kill $$(cat $(DISCOVERY_PID)) 2>/dev/null || true; \
		rm -f $(DISCOVERY_PID); \
		echo "$(GREEN)✓ Discovery Server durduruldu$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Discovery Server zaten çalışmıyor$(NC)"; \
	fi

stop-gateway: ## API Gateway durdur
	@if [ -f $(GATEWAY_PID) ]; then \
		echo "$(BLUE)► API Gateway durduruluyor...$(NC)"; \
		kill $$(cat $(GATEWAY_PID)) 2>/dev/null || true; \
		rm -f $(GATEWAY_PID); \
		echo "$(GREEN)✓ API Gateway durduruldu$(NC)"; \
	else \
		echo "$(YELLOW)⚠ API Gateway zaten çalışmıyor$(NC)"; \
	fi

stop-auth: ## Auth Service durdur
	@if [ -f $(AUTH_PID) ]; then \
		echo "$(BLUE)► Auth Service durduruluyor...$(NC)"; \
		kill $$(cat $(AUTH_PID)) 2>/dev/null || true; \
		rm -f $(AUTH_PID); \
		echo "$(GREEN)✓ Auth Service durduruldu$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Auth Service zaten çalışmıyor$(NC)"; \
	fi

stop-mail: ## Mail Service durdur
	@if [ -f $(MAIL_PID) ]; then \
		echo "$(BLUE)► Mail Service durduruluyor...$(NC)"; \
		kill $$(cat $(MAIL_PID)) 2>/dev/null || true; \
		rm -f $(MAIL_PID); \
		echo "$(GREEN)✓ Mail Service durduruldu$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Mail Service zaten çalışmıyor$(NC)"; \
	fi

# ============================================
# TOPLU KOMUTLAR
# ============================================

start: install start-infra ## Tüm sistemi başlat
	@echo ""
	@echo "$(BLUE)═══════════════════════════════════════════$(NC)"
	@echo "$(BLUE)       Servisler Başlatılıyor...           $(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════$(NC)"
	@echo ""
	@mkdir -p logs
	@make start-discovery
	@echo "$(YELLOW)⏳ Discovery Server'ın hazır olması bekleniyor...$(NC)"
	@sleep 10
	@make start-gateway
	@sleep 5
	@make start-auth
	@sleep 5
	@make start-mail
	@echo ""
	@echo "$(GREEN)═══════════════════════════════════════════$(NC)"
	@echo "$(GREEN)       Tüm Servisler Başlatıldı!           $(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════$(NC)"
	@echo ""
	@sleep 5
	@make status

stop: ## Tüm servisleri durdur
	@echo ""
	@echo "$(BLUE)═══════════════════════════════════════════$(NC)"
	@echo "$(BLUE)       Servisler Durduruluyor...           $(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════$(NC)"
	@echo ""
	@make stop-mail
	@make stop-auth
	@make stop-gateway
	@make stop-discovery
	@pkill -f "spring-boot:run" 2>/dev/null || true
	@echo ""
	@echo "$(GREEN)✓ Tüm Spring Boot servisleri durduruldu$(NC)"
	@echo ""

stop-all: stop stop-infra ## Tüm sistemi durdur (servisler + altyapı)
	@echo "$(GREEN)✓ Tüm sistem durduruldu$(NC)"

restart: stop start ## Tüm servisleri yeniden başlat

# ============================================
# DURUM KONTROLÜ
# ============================================

status: ## Servis durumlarını göster
	@echo ""
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║                   SERVİS DURUMLARI                         ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(BLUE)Spring Boot Servisleri:$(NC)"
	@echo "─────────────────────────────────────────────────────────────────"
	@printf "  %-20s " "Discovery Server:"; \
	if curl -s http://localhost:$(DISCOVERY_PORT) > /dev/null 2>&1; then \
		echo "$(GREEN)✅ Çalışıyor$(NC) (http://localhost:$(DISCOVERY_PORT))"; \
	else \
		echo "$(RED)❌ Çalışmıyor$(NC)"; \
	fi
	@printf "  %-20s " "API Gateway:"; \
	if curl -s http://localhost:$(GATEWAY_PORT)/actuator/health > /dev/null 2>&1; then \
		echo "$(GREEN)✅ Çalışıyor$(NC) (http://localhost:$(GATEWAY_PORT))"; \
	else \
		echo "$(RED)❌ Çalışmıyor$(NC)"; \
	fi
	@printf "  %-20s " "Auth Service:"; \
	if curl -s http://localhost:$(AUTH_PORT)/actuator/health > /dev/null 2>&1; then \
		echo "$(GREEN)✅ Çalışıyor$(NC) (http://localhost:$(AUTH_PORT))"; \
	else \
		echo "$(RED)❌ Çalışmıyor$(NC)"; \
	fi
	@printf "  %-20s " "Mail Service:"; \
	if curl -s http://localhost:$(MAIL_PORT)/actuator/health > /dev/null 2>&1; then \
		echo "$(GREEN)✅ Çalışıyor$(NC) (http://localhost:$(MAIL_PORT))"; \
	else \
		echo "$(RED)❌ Çalışmıyor$(NC)"; \
	fi
	@echo ""
	@make infra-status

# ============================================
# LOG KOMUTLARI
# ============================================

logs: ## Tüm logları göster
	@echo "$(BLUE)► Son loglar:$(NC)"
	@echo ""
	@echo "$(YELLOW)=== Discovery Server ===$(NC)"
	@tail -30 logs/discovery-server.log 2>/dev/null || echo "Log dosyası bulunamadı"
	@echo ""
	@echo "$(YELLOW)=== API Gateway ===$(NC)"
	@tail -30 logs/api-gateway.log 2>/dev/null || echo "Log dosyası bulunamadı"
	@echo ""
	@echo "$(YELLOW)=== Auth Service ===$(NC)"
	@tail -30 logs/auth-service.log 2>/dev/null || echo "Log dosyası bulunamadı"
	@echo ""
	@echo "$(YELLOW)=== Mail Service ===$(NC)"
	@tail -30 logs/mail-service.log 2>/dev/null || echo "Log dosyası bulunamadı"

logs-discovery: ## Discovery Server loglarını takip et
	@tail -f logs/discovery-server.log

logs-gateway: ## API Gateway loglarını takip et
	@tail -f logs/api-gateway.log

logs-auth: ## Auth Service loglarını takip et
	@tail -f logs/auth-service.log

logs-mail: ## Mail Service loglarını takip et
	@tail -f logs/mail-service.log

logs-errors: ## Tüm error loglarını göster
	@echo "$(RED)=== Error Logs ===$(NC)"
	@echo ""
	@echo "$(YELLOW)--- Discovery Server Errors ---$(NC)"
	@tail -20 logs/discovery-server-error.log 2>/dev/null || echo "Error log yok"
	@echo ""
	@echo "$(YELLOW)--- API Gateway Errors ---$(NC)"
	@tail -20 logs/api-gateway-error.log 2>/dev/null || echo "Error log yok"
	@echo ""
	@echo "$(YELLOW)--- Auth Service Errors ---$(NC)"
	@tail -20 logs/auth-service-error.log 2>/dev/null || echo "Error log yok"
	@echo ""
	@echo "$(YELLOW)--- Mail Service Errors ---$(NC)"
	@tail -20 logs/mail-service-error.log 2>/dev/null || echo "Error log yok"

logs-clean: ## Eski log dosyalarını temizle
	@echo "$(BLUE)► Log dosyaları temizleniyor...$(NC)"
	@rm -f logs/*.log logs/*.log.gz
	@echo "$(GREEN)✓ Log dosyaları temizlendi$(NC)"

# ============================================
# HIZLI BAŞLATMA (sadece servisler - altyapı hazır varsayılır)
# ============================================

quick-start: $(PID_DIR) ## Hızlı başlat (build + altyapı olmadan)
	@mkdir -p logs
	@echo "$(BLUE)► Servisler hızlı başlatılıyor...$(NC)"
	@make start-discovery
	@sleep 8
	@make start-gateway
	@sleep 3
	@make start-auth
	@sleep 3
	@make start-mail
	@sleep 3
	@make status

# ============================================
# DEVELOPMENT
# ============================================

dev: start-infra quick-start ## Development modu (altyapı + servisler)
	@echo "$(GREEN)✓ Development ortamı hazır!$(NC)"
