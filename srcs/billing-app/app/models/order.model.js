export default (sequelize, Sequelize) => {
  const Order = sequelize.define(
    "order",
    {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      user_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      number_of_items: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      total_amount: {
        type: Sequelize.FLOAT,
        allowNull: false,
      },
    },
    {
      timestamps: true,
    }
  );

  return Order;
};
