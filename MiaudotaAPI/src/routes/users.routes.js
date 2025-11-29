// src/routes/users.routes.js
import { Router } from "express";
import {
  register,
  login,
  forgotPassword,
  resetPassword,
  updateProfile,
  deleteUser,   // 👈 importa aqui
  resetPasswordByCpf,
} from "../controllers/users.controller.js";

const router = Router();

router.post("/register", register);
router.post("/login", login);
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", resetPassword);
router.post("/reset-password/by-cpf", resetPasswordByCpf);
router.put("/profile/:id", updateProfile);
router.delete("/:id", deleteUser);

export default router;
