import { Router } from "express";
import multer from "multer";
import path from "path";
import { fileURLToPath } from "url";

import { index, store, update } from "../controllers/pets.controller.js";

const router = Router();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// pasta src/uploads
const uploadDir = path.resolve(__dirname, "..", "uploads");

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

const upload = multer({ storage });

// ⚠️ IMPORTANTE: APENAS "/" AQUI, porque o index.js já faz app.use("/pets", ...)
router.get("/", index);
router.post("/", upload.single("foto"), store);
router.put("/:id", upload.single("foto"), update);

export default router;
