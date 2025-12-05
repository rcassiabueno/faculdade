import { Router } from "express";
import multer from "multer";
import path from "path";
import { fileURLToPath } from "url";
import fs from "fs";

import { index, store, update } from "../controllers/pets.controller.js";

const router = Router();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ======================================================
// 🟧 Apenas uma declaração de uploadDir
// ======================================================
const uploadDir = path.resolve(__dirname, "..", "uploads");

// 🟧 Garante que a pasta existe
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// ======================================================
// 🟧 Configuração do Multer (uma única vez!)
// ======================================================
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

const upload = multer({ storage });

// ======================================================
// 🟧 Rotas
// ======================================================

// GET /pets
router.get("/", index);

// POST /pets
router.post("/", upload.single("foto"), store);

// PUT /pets/:id
router.put("/:id", upload.single("foto"), update);

export default router;
