import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import db from "./app/models/index.js";
import movieRoutes from './app/routes/movie.routes.js';

dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database
db.sequelize.sync({ force: false })
  .then(() => {
    console.log('Database connected!');
  })
  .catch((err) => {
    console.error('Failed to sync database:', err);
  });

// Routes
movieRoutes(app);

// Default route
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to the Movie Inventory API' });
});

// Start server
const PORT = process.env.INVENTORY_API_PORT;
const HOST = process.env.INVENTORY_API_HOST;

app.listen(PORT, HOST, () => {
  console.log(`Server is running on http://${HOST}:${PORT}`);
});

// export default app;