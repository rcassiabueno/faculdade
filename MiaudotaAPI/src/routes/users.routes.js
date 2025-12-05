// src/routes/users.routes.js
import { Router } from "express";
import {
  register,
  login,
  resetPassword,     // ✅ só esse para redefinir senha
  updateProfile,
  deleteUser,
} from "../controllers/users.controller.js";

const router = Router();

router.post("/register", register);
router.post("/login", login);

// fluxo novo de redefinição de senha (email + CPF/CNPJ + novaSenha)
router.post("/reset-password", resetPassword);

router.put("/profile/:id", updateProfile);
router.delete("/:id", deleteUser);

export default router;
