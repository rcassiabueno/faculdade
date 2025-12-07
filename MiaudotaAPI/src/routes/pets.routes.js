import { Router } from "express";
import multer from "multer";
import path from "path";
import { fileURLToPath } from "url";
import fs from "fs";

import { db } from "../database/database.js";           // 👈 ADICIONE ISTO
import { index, store, update } from "../controllers/pets.controller.js";

const router = Router();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const uploadDir = path.resolve(__dirname, "..", "uploads");

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

const upload = multer({ storage });

// Rotas principais
router.get("/", index);
router.post("/", upload.single("foto"), store);
router.put("/:id", upload.single("foto"), update);

// ===================================================
// 🔥 ROTA TEMPORÁRIA — REMOVER TOM E JANE
// ===================================================
router.delete("/delete-seed", (req, res) => {
  db.run("DELETE FROM pets WHERE nome IN ('Tom', 'Jane')", [], (err) => {
    if (err) {
      console.error("Erro ao remover seed:", err.message);
      return res.status(500).json({ error: err.message });
    }
    return res.json({ message: "Tom e Jane removidos!" });
  });
});

export default router;
