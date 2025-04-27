import dotenv from 'dotenv';
dotenv.config();

export default {
  HOST: process.env.POSTGRES_BILLING_HOST,
  USER: process.env.POSTGRES_BILLING_USER,
  DB: process.env.POSTGRES_BILLING_DB,
  dialect: 'postgres',
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000,
  },
};
