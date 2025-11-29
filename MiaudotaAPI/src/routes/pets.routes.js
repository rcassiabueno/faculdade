// src/routes/pets.routes.js
import { Router } from "express";
import { listarPets, createPet } from "../controllers/pets.controller.js";
import upload from "../config/upload.js";

const router = Router();

router.get("/", listarPets);


router.post("/", upload.single("foto"), createPet);

export default router;
