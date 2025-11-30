import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import dotenv from "dotenv";

import usersRoutes from "./src/routes/users.routes.js";
import petsRoutes from "./src/routes/pets.routes.js";
// import { transporter } from "./src/services/email.service.js";  // ❌ desativado enquanto email não usado

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// permitir JSON no body
app.use(express.json({ type: "*/*", limit: "5mb" }));
app.use((req, res, next) => {
  req.setEncoding("utf8");
  next();
});

// disponibiliza imagens no navegador
app.use("/uploads", express.static(path.join(__dirname, "src", "uploads")));

// rotas
app.use("/users", usersRoutes);
app.use("/pets", petsRoutes);

// rota de teste (para abrir no navegador)
app.get("/", (req, res) => {
  res.send("API Miaudota OK!");
});

// fallback 404
app.use((req, res) => {
  res.status(404).send("Rota não encontrada");
});

// iniciar servidor
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});

/* 
// Bloqueado temporariamente: SMTP não será usado
transporter.verify()
  .then(() => console.log('SMTP transporter verified and ready.'))
  .catch((err) => console.error('SMTP transporter verification failed:', err));
*/
