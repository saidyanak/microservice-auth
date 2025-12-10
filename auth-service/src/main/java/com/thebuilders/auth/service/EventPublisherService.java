package com.thebuilders.auth.service;

import com.thebuilders.common.event.PasswordResetEvent;
import com.thebuilders.common.event.UserRegisteredEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class EventPublisherService {

    private final RabbitTemplate rabbitTemplate;

    @Value("${rabbitmq.exchange.name}")
    private String exchangeName;

    @Value("${rabbitmq.routing-key.user-registered}")
    private String userRegisteredRoutingKey;

    @Value("${rabbitmq.routing-key.password-reset}")
    private String passwordResetRoutingKey;

    public void publishUserRegisteredEvent(UserRegisteredEvent event) {
        try {
            rabbitTemplate.convertAndSend(exchangeName, userRegisteredRoutingKey, event);
            log.info("Published UserRegisteredEvent for: {}", event.getEmail());
        } catch (Exception e) {
            log.error("Failed to publish UserRegisteredEvent: {}", e.getMessage());
        }
    }

    public void publishPasswordResetEvent(PasswordResetEvent event) {
        try {
            rabbitTemplate.convertAndSend(exchangeName, passwordResetRoutingKey, event);
            log.info("Published PasswordResetEvent for: {}", event.getEmail());
        } catch (Exception e) {
            log.error("Failed to publish PasswordResetEvent: {}", e.getMessage());
        }
    }
}
