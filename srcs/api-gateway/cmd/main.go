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
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	port := os.Getenv("API_GATEWAY_PORT")
	inventoryAPIURL := os.Getenv("INVENTORY_API_URL")
	rabbitMQURL := os.Getenv("RABBITMQ_URL")

	rabbitMQService, err := services.NewRabbitMQService(rabbitMQURL)
	if err != nil {
		log.Fatalf("Failed to connect to RabbitMQ: %v", err)
	}
	defer rabbitMQService.Close()

	router := mux.NewRouter()

	router.PathPrefix("/api/movies").Handler(handlers.NewInventoryHandler(inventoryAPIURL))
	router.HandleFunc("/api/billing", handlers.NewBillingHandler(rabbitMQService)).Methods("POST")

	fmt.Printf("Gateway API is running on port %s\n", port)
	log.Fatal(http.ListenAndServe(":" + port, router))
}
