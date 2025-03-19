import amqp from "amqplib";
import db from "../models/index.js";
import dotenv from "dotenv";

dotenv.config();
const Order = db.orders;

async function consumeMessages() {
  try {
    const connection = await amqp.connect(process.env.RABBITMQ_URL);
    const channel = await connection.createChannel();
    await channel.assertQueue(process.env.RABBITMQ_QUEUE, { durable: true });

    console.log("Waiting for messages in", process.env.RABBITMQ_QUEUE);

    channel.consume(process.env.RABBITMQ_QUEUE, async (msg) => {
      if (msg !== null) {
        try {
          const orderData = JSON.parse(msg.content.toString());
          console.log("Received:", orderData);

          await Order.create({
            user_id: parseInt(orderData.user_id, 10),
            number_of_items: parseInt(orderData.number_of_items, 10),
            total_amount: parseInt(orderData.total_amount),
          });

          channel.ack(msg);
          console.log("Order saved to database");
        } catch (error) {
          console.error("Error processing order:", error);
        }
      }
    });
  } catch (error) {
    console.error("Error connecting to RabbitMQ:", error);
  }
}

export default consumeMessages;
