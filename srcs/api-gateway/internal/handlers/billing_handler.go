package handlers

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/OumarLAM/crud-master/internal/services"
)

// NewBillingHandler creates a handler to send billing data to RabbitMQ
func NewBillingHandler(rmqService *services.RabbitMQService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var body map[string]any

		data, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}
		defer r.Body.Close()

		if err := json.Unmarshal(data, &body); err != nil {
			http.Error(w, "Invalid JSON format", http.StatusBadRequest)
			return
		}

		message := string(data)
		if err := rmqService.Publish(message); err != nil {
			http.Error(w, fmt.Sprintf("Failed to send message: %v", err), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Order request received successfully!"))
	}
}
