import express from "express";
import dotenv from "dotenv";
import { createProxyMiddleware } from "http-proxy-middleware";
import { sendToBillingQueue } from "./app/services/rabbitmqService.js";

dotenv.config();

const app = express();
app.use(express.json());

app.use("/api/movies", createProxyMiddleware({
  target: process.env.INVENTORY_API_URL,
  changeOrigin: true,
  onProxyReq: (proxyReq, req) => {
    if (req.body) {
      const bodyData = JSON.stringify(req.body);

      console.log("Request body:", bodyData);
      
      proxyReq.setHeader('Content-Type', 'application/json');
      proxyReq.setHeader('Content-Length', Buffer.byteLength(bodyData));
      
      proxyReq.write(bodyData);
    }
  },
  timeout: 10000,
  proxyTimeout: 10000,
}));

app.post("/api/billing", async (req, res) => {
  const { user_id, number_of_items, total_amount } = req.body;

  if (!user_id || !number_of_items || !total_amount) {
    return res
      .status(400)
      .json({
        error:
          "All fields are required: user_id, number_of_items, total_amount",
      });
  }

  try {
    await sendToBillingQueue(req.body);
    res.status(200).json({ message: "Order request received successfully!" });
  } catch (error) {
    console.error("Error sending message to RabbitMQ:", error);
    res.status(500).json({ error: "Failed to process order request" });
  }
});

const PORT = process.env.API_GATEWAY_PORT || 3000;
app.listen(PORT, () => {
  console.log(`Gateway API running on port ${PORT}`);
});
