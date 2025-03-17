import { Router } from "express";
import {
  create,
  findAll,
  findOne,
  update,
  deleteMovie,
  deleteAll,
} from "../controllers/movie.controller.js";

const router = Router();

router.post("/", create);
router.get("/", findAll);
router.get("/:id", findOne);
router.put("/:id", update);
router.delete("/:id", deleteMovie);
router.delete("/", deleteAll);

export default (app) => {
    app.use("/api/movies", router);
};
