import dotenv from 'dotenv';
dotenv.config();

export default {
  HOST: process.env.POSTGRES_INVENTORY_HOST,
  USER: process.env.POSTGRES_INVENTORY_USER,
  PASSWORD: process.env.POSTGRES_INVENTORY_PASSWORD,
  DB: process.env.POSTGRES_INVENTORY_DB,
  dialect: "postgres",
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000,
  },
};
