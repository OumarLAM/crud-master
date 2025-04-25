import Sequelize from 'sequelize';
// import dbConfig from '../config/db.config.js';
import OrderModel from './order.model.js';

const sequelize = new Sequelize('postgres://postgres:postgres@localhost:5432/orders');

const db = {
  Sequelize,
  sequelize,
  orders: OrderModel(sequelize, Sequelize)

};

export default db;
