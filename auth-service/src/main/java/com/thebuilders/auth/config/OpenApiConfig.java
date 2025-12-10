package com.thebuilders.auth.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Value("${server.port:8081}")
    private String serverPort;

    @Bean
    public OpenAPI authServiceOpenAPI() {
        final String securitySchemeName = "bearerAuth";
        
        return new OpenAPI()
                .info(new Info()
                        .title("Auth Service API")
                        .description("""
                                🔐 **Career Portal - Authentication Service**
                                
                                Bu servis kullanıcı kimlik doğrulama ve yetkilendirme işlemlerini yönetir.
                                
                                ## Özellikler
                                - 👤 Kullanıcı Kaydı (Register)
                                - 🔑 Giriş Yapma (Login)
                                - 🔄 Token Yenileme (Refresh Token)
                                - 🚪 Çıkış Yapma (Logout)
                                - 👥 Kullanıcı Profili
                                
                                ## Roller
                                - **ADMIN**: Bilişim Vadisi Yöneticileri
                                - **COMPANY**: Şirket Hesapları
                                - **USER**: İş Arayanlar
                                
                                ## Authentication
                                JWT Bearer Token kullanılmaktadır. Login sonrası dönen `accessToken`'ı 
                                **Authorize** butonuna yapıştırarak korumalı endpointlere erişebilirsiniz.
                                """)
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("The Builders Team")
                                .email("team@thebuilders.com")
                                .url("https://github.com/thebuilders"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server()
                                .url("http://localhost:" + serverPort)
                                .description("Auth Service - Direct"),
                        new Server()
                                .url("http://localhost:8080")
                                .description("API Gateway")))
                .addSecurityItem(new SecurityRequirement().addList(securitySchemeName))
                .components(new Components()
                        .addSecuritySchemes(securitySchemeName,
                                new SecurityScheme()
                                        .name(securitySchemeName)
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")
                                        .description("JWT token'ı buraya girin. Örnek: `eyJhbGciOiJIUzI1NiIs...`")));
    }
}
