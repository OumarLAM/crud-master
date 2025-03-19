import dotenv from 'dotenv';
dotenv.config();

export default {
  HOST: process.env.POSTGRES_BILLING_HOST || 'localhost',
  USER: process.env.POSTGRES_BILLING_USER || 'postgres',
  PASSWORD: process.env.POSTGRES_BILLING_PASSWORD || 'postgres',
  DB: process.env.POSTGRES_BILLING_DB || 'orders',
  dialect: 'postgres',
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000,
  },
};
