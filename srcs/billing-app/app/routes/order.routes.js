import Router from "express";
import {
  findAll,
  findOne,
  deleteOrder,
} from "../controllers/order.controller.js";

const router = Router();

router.get("/", findAll);
router.get("/:id", findOne);
router.delete("/:id", deleteOrder);

export default router;
