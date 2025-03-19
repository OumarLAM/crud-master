import db from '../models/index.js';

const Order = db.orders;

// Get all orders
export const findAll = async (req, res) => {
  try {
    const orders = await Order.findAll();
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get an order by ID
export const findOne = async (req, res) => {
  try {
    const order = await Order.findByPk(req.params.id);
    if (order) res.json(order);
    else res.status(404).json({ message: 'Order not found' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Delete an order by ID
export const deleteOrder = async (req, res) => {
  try {
    const deleted = await Order.destroy({ where: { id: req.params.id } });
    if (deleted) res.json({ message: 'Order deleted' });
    else res.status(404).json({ message: 'Order not found' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
