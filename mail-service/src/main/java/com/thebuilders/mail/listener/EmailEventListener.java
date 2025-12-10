package com.thebuilders.mail.listener;

import com.thebuilders.common.event.PasswordResetEvent;
import com.thebuilders.common.event.UserRegisteredEvent;
import com.thebuilders.mail.service.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class EmailEventListener {

    private final EmailService emailService;

    @RabbitListener(queues = "${rabbitmq.queue.email}")
    public void handleUserRegisteredEvent(UserRegisteredEvent event) {
        log.info("Received UserRegisteredEvent for: {}", event.getEmail());
        
        emailService.sendVerificationEmail(
                event.getEmail(),
                event.getFirstName(),
                event.getVerificationToken()
        );
    }

    @RabbitListener(queues = "${rabbitmq.queue.email}")
    public void handlePasswordResetEvent(PasswordResetEvent event) {
        log.info("Received PasswordResetEvent for: {}", event.getEmail());
        
        emailService.sendPasswordResetEmail(
                event.getEmail(),
                event.getFirstName(),
                event.getResetToken()
        );
    }
}
