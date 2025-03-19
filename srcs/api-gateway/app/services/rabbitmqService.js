import amqp from 'amqplib';
import dotenv from 'dotenv';

dotenv.config();

export async function sendToBillingQueue(orderData) {
  const connection = await amqp.connect(process.env.RABBITMQ_URL);
  const channel = await connection.createChannel();
  await channel.assertQueue(process.env.RABBITMQ_QUEUE, { durable: true });

  const message = JSON.stringify(orderData);
  channel.sendToQueue(process.env.RABBITMQ_QUEUE, Buffer.from(message));

  console.log('Message sent to billing queue:', message);

  setTimeout(() => connection.close(), 500);  // Gracefully close connection
}
