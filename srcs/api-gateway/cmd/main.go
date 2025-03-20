package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/OumarLAM/crud-master/internal/handlers"
	"github.com/OumarLAM/crud-master/internal/services"
	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	// Load variables
	port := ":"+os.Getenv("API_GATEWAY_PORT")
	inventoryAPIURL := os.Getenv("INVENTORY_API_URL")
	rabbitMQURL := os.Getenv("RABBITMQ_URL")

	// rabbitMQURL := "amqp://guest:guest@localhost:5672/" // RabbitMQ URL

	// Initialize RabbitMQ connection
	rabbitMQService, err := services.NewRabbitMQService(rabbitMQURL)
	if err != nil {
		log.Fatalf("Failed to connect to RabbitMQ: %v", err)
	}
	defer rabbitMQService.Close()

	// Initialize router
	router := mux.NewRouter()

	// Inventory API proxy routes
	router.PathPrefix("/api/movies").Handler(handlers.NewInventoryHandler(inventoryAPIURL))

	// Billing API route
	router.HandleFunc("/api/billing", handlers.NewBillingHandler(rabbitMQService)).Methods("POST")

	// Start server
	// port := ":3000"
	fmt.Printf("Gateway API is running on port %s\n", port)
	log.Fatal(http.ListenAndServe(port, router))
}
