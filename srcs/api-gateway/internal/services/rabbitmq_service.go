package services

import (
	"fmt"
	"log"
	"os"

	"github.com/streadway/amqp"
)

type RabbitMQService struct {
	connection *amqp.Connection
	channel    *amqp.Channel
	queueName  string
}

// NewRabbitMQService initializes a RabbitMQ connection and declares the queue
func NewRabbitMQService(rabbitMQURL string) (*RabbitMQService, error) {
	conn, err := amqp.Dial(rabbitMQURL)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to RabbitMQ: %v", err)
	}

	ch, err := conn.Channel()
	if err != nil {
		conn.Close()
		return nil, fmt.Errorf("failed to open a channel: %v", err)
	}

	queueName := os.Getenv("RABBITMQ_QUEUE")
	_, err = ch.QueueDeclare(
		queueName,
		true,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		conn.Close()
		return nil, fmt.Errorf("failed to declare queue: %v", err)
	}

	return &RabbitMQService{
		connection: conn,
		channel:    ch,
		queueName:  queueName,
	}, nil
}

// Publish sends a message to the billing queue
func (r *RabbitMQService) Publish(message string) error {
	err := r.channel.Publish(
		"",
		r.queueName,
		false,
		false,
		amqp.Publishing{
			ContentType: "application/json",
			Body:        []byte(message),
		},
	)
	if err != nil {
		return fmt.Errorf("failed to publish message: %v", err)
	}
	log.Printf("Message sent to %s: %s", r.queueName, message)
	return nil
}

// Close gracefully closes the RabbitMQ connection
func (r *RabbitMQService) Close() {
	if r.channel != nil {
		_ = r.channel.Close()
	}
	if r.connection != nil {
		_ = r.connection.Close()
	}
}
