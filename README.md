# Movie Streaming Platform - Microservices Architecture

A cloud-native movie streaming platform built with a microservices architecture, featuring an API Gateway connected to Inventory and Billing services, each with its own database.

## Architecture Overview

The system consists of three main components:
- **API Gateway**: Routes requests to appropriate services using HTTP and RabbitMQ
- **Inventory API**: Manages movie information with a PostgreSQL database
- **Billing API**: Processes payments through message queuing with RabbitMQ

### Communication Patterns
- API Gateway → Inventory API: HTTP REST
- API Gateway → Billing API: Asynchronous messaging via RabbitMQ

## Tech Stack

- **API Gateway**: Go
- **Inventory API**: Node.js with Express and Sequelize
- **Billing API**: Node.js with Express, Sequelize, and amqplib
- **Databases**: PostgreSQL (separate instances for Inventory and Billing)
- **Message Queue**: RabbitMQ
- **Process Manager**: PM2
- **Virtualization**: Vagrant with VirtualBox
- **API Documentation**: OpenAPI/Swagger (TODO)

## Project Structure

```
.
├── README.md
├── .env                     # Environment variables
├── scripts/                 # VM provisioning scripts
├── srcs/
│   ├── api-gateway/         # Go-based API Gateway
│   ├── inventory-app/       # Node.js Inventory service
│   └── billing-app/         # Node.js Billing service
└── Vagrantfile              # VM configuration
```

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/OumarLAM/crud-master.git
cd crud-master
```

### 2. Configure environment variables

The `.env` file contains all necessary credentials. For a development environment, the file is included in the repository:

```
# API Gateway Configuration
API_GATEWAY_PORT=3000

# Inventory API Configuration
INVENTORY_API_PORT=8080
INVENTORY_API_HOST=192.168.100.201
INVENTORY_API_URL=http://192.168.100.201:8080

# Billing API Configuration
BILLING_API_PORT=8081
BILLING_API_HOST=192.168.100.202

# PostgreSQL Configuration - Inventory
POSTGRES_INVENTORY_USER=postgres
POSTGRES_INVENTORY_PASSWORD=postgres
POSTGRES_INVENTORY_DB=movies
POSTGRES_INVENTORY_HOST=localhost

# PostgreSQL Configuration - Billing
POSTGRES_BILLING_USER=postgres
POSTGRES_BILLING_PASSWORD=postgres
POSTGRES_BILLING_DB=orders
POSTGRES_BILLING_HOST=localhost

# RabbitMQ Configuration
RABBITMQ_USER=oulam
RABBITMQ_PASSWORD=oulam
RABBITMQ_URL=amqp://oulam:oulam@192.168.100.202:5672
RABBITMQ_QUEUE=billing_queue
```

### 3. Start the virtual machines

```bash
vagrant up
```

This command will:
- Create three virtual machines: gateway-vm, inventory-vm, and billing-vm
- Install necessary dependencies via scripts under scripts/
- Set up the databases and initialize the services
- Start all services using PM2

### 4. Verify services are running

```bash
vagrant status
```

You can SSH into any VM to check the status of services:

```bash
vagrant ssh gateway-vm
pm2 list
```

## API Endpoints

### API Gateway (http://192.168.100.200:3000)

#### Movie Management (proxied to Inventory API)
- `GET /api/movies` - Get all movies
- `GET /api/movies?title=[name]` - Search movies by title
- `POST /api/movies` - Add a new movie
- `DELETE /api/movies` - Delete all movies
- `GET /api/movies/:id` - Get movie by ID
- `PUT /api/movies/:id` - Update movie by ID
- `DELETE /api/movies/:id` - Delete movie by ID

#### Billing (sending to RabbitMQ queue)
- `POST /api/billing` - Create new order

Example request body:
```json
{
  "user_id": "3",
  "number_of_items": "5",
  "total_amount": "180"
}
```

## Testing the System

### Using Postman

1. Import the provided Postman collection from `testing/postman_collection.json`
2. Run the collection to test all endpoints

## Implementation Details

### API Gateway (Go)

The API Gateway is implemented in Go for high performance. It uses the standard `net/http` package for handling HTTP requests and the `github.com/streadway/amqp` package for RabbitMQ communication.

Key features:
- HTTP proxy for Inventory API requests
- RabbitMQ publisher for Billing requests
- Logging and monitoring

### Inventory API (Node.js)

A RESTful CRUD API using:
- Express.js for routing
- Sequelize ORM for database operations
- PostgreSQL for data storage

### Billing API (Node.js)

An asynchronous message processing service using:
- amqplib for RabbitMQ communication
- Express.js for the application framework
- Sequelize ORM for database operations
- PostgreSQL for order storage

## Author

👤 **Oumar LAM**

- Github: [Oumar LAM](https://github.com/OumarLAM)
- Twitter: [@OumarLAM](https://twitter.com/oumarlam_fcb)

## Let's Connect! 🌐

Got questions, ideas, or just want to say hi? Reach out to me on [Twitter](https://twitter.com/OumarLAM) or by sending a mail to oumarlam154@gmail.com . I'd love to hear from you :)