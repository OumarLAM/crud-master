export default {
  HOST: process.env.POSTGRES_INVENTORY_HOST || "localhost",
  USER: process.env.POSTGRES_INVENTORY_USER || "postgres",
  PASSWORD: process.env.POSTGRES_INVENTORY_PASSWORD || "postgres",
  DB: process.env.POSTGRES_INVENTORY_DB || "movies",
  dialect: "postgres",
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000,
  },
};
