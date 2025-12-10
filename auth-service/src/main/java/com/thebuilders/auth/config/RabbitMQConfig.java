package com.thebuilders.auth.config;

import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    @Value("${rabbitmq.exchange.name}")
    private String exchangeName;

    @Value("${rabbitmq.queue.email}")
    private String emailQueue;

    @Value("${rabbitmq.routing-key.user-registered}")
    private String userRegisteredRoutingKey;

    @Value("${rabbitmq.routing-key.password-reset}")
    private String passwordResetRoutingKey;

    @Bean
    public TopicExchange exchange() {
        return new TopicExchange(exchangeName);
    }

    @Bean
    public Queue emailQueue() {
        return QueueBuilder.durable(emailQueue).build();
    }

    @Bean
    public Binding userRegisteredBinding(Queue emailQueue, TopicExchange exchange) {
        return BindingBuilder
                .bind(emailQueue)
                .to(exchange)
                .with(userRegisteredRoutingKey);
    }

    @Bean
    public Binding passwordResetBinding(Queue emailQueue, TopicExchange exchange) {
        return BindingBuilder
                .bind(emailQueue)
                .to(exchange)
                .with(passwordResetRoutingKey);
    }

    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        RabbitTemplate rabbitTemplate = new RabbitTemplate(connectionFactory);
        rabbitTemplate.setMessageConverter(jsonMessageConverter());
        return rabbitTemplate;
    }
}
