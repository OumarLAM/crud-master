import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import db from './app/models/index.js';
import orderRoutes from './app/routes/order.routes.js';
import consumeMessages from './app/queue/consumer.js';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/api/billing', orderRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Billing API is running and listening for messages.' });
});

const PORT = process.env.BILLING_API_PORT;
const HOST = process.env.BILLING_API_HOST;

// Sync database and start the consumer
db.sequelize.sync().then(() => {
  console.log('Database synced');
  app.listen(PORT, HOST, () => {
    console.log(`Server is running on ${HOST}:${PORT}`);
    consumeMessages(); // Start RabbitMQ consumer
  });
});
