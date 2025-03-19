import Sequelize from 'sequelize';
import dbConfig from '../config/db.config.js';
import OrderModel from './order.model.js';

const sequelize = new Sequelize(dbConfig.DB, dbConfig.USER, dbConfig.PASSWORD, {
  host: dbConfig.HOST,
  dialect: dbConfig.dialect,
  pool: {
    max: dbConfig.pool.max,
    min: dbConfig.pool.min,
    acquire: dbConfig.pool.acquire,
    idle: dbConfig.pool.idle
  }
});

const db = {
  Sequelize,
  sequelize,
  orders: OrderModel(sequelize, Sequelize)

};

export default db;
