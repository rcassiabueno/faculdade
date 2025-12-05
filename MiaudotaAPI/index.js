import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import dotenv from "dotenv";

import usersRoutes from "./src/routes/users.routes.js";
import petsRoutes from "./src/routes/pets.routes.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// permitir JSON no body
app.use(express.json({ limit: "5mb" }));
app.use(express.urlencoded({ extended: true }));

// disponibiliza imagens no navegador
app.use("/uploads", express.static(path.join(__dirname, "src", "uploads")));

// rotas
app.use("/users", usersRoutes);
app.use("/pets", petsRoutes);

// rota de teste
app.get("/", (req, res) => {
  res.send("API Miaudota OK!");
});

// 🔴 middleware global de erro
app.use((err, req, res, next) => {
  console.error("ERRO GLOBAL:", err);
  if (res.headersSent) return next(err);
  return res.status(500).json({
    error: err.message || "Erro interno no servidor",
  });
});

// fallback 404
app.use((req, res) => {
  res.status(404).json({ error: "Rota não encontrada" });
});

// iniciar servidor
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
