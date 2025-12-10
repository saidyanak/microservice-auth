package com.thebuilders.mail.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.nio.charset.StandardCharsets;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;

    @Value("${app.mail.from}")
    private String fromEmail;

    @Value("${app.mail.from-name}")
    private String fromName;

    @Value("${app.frontend.url}")
    private String frontendUrl;

    @Async
    public void sendVerificationEmail(String to, String firstName, String token) {
        try {
            Context context = new Context();
            context.setVariable("firstName", firstName);
            context.setVariable("verificationLink", frontendUrl + "/verify-email?token=" + token);

            String htmlContent = templateEngine.process("email-verification", context);
            sendHtmlEmail(to, "Verify Your Email - Career Portal", htmlContent);
            
            log.info("Verification email sent to: {}", to);
        } catch (Exception e) {
            log.error("Failed to send verification email to {}: {}", to, e.getMessage());
        }
    }

    @Async
    public void sendPasswordResetEmail(String to, String firstName, String token) {
        try {
            Context context = new Context();
            context.setVariable("firstName", firstName);
            context.setVariable("resetLink", frontendUrl + "/reset-password?token=" + token);

            String htmlContent = templateEngine.process("password-reset", context);
            sendHtmlEmail(to, "Reset Your Password - Career Portal", htmlContent);
            
            log.info("Password reset email sent to: {}", to);
        } catch (Exception e) {
            log.error("Failed to send password reset email to {}: {}", to, e.getMessage());
        }
    }

    @Async
    public void sendWelcomeEmail(String to, String firstName, String role) {
        try {
            Context context = new Context();
            context.setVariable("firstName", firstName);
            context.setVariable("role", role);
            context.setVariable("loginLink", frontendUrl + "/login");

            String htmlContent = templateEngine.process("welcome", context);
            sendHtmlEmail(to, "Welcome to Career Portal!", htmlContent);
            
            log.info("Welcome email sent to: {}", to);
        } catch (Exception e) {
            log.error("Failed to send welcome email to {}: {}", to, e.getMessage());
        }
    }

    private void sendHtmlEmail(String to, String subject, String htmlContent) throws MessagingException, java.io.UnsupportedEncodingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(
                message,
                MimeMessageHelper.MULTIPART_MODE_MIXED_RELATED,
                StandardCharsets.UTF_8.name()
        );

        helper.setFrom(fromEmail, fromName);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(htmlContent, true);

        mailSender.send(message);
    }
}
