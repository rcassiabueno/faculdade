// src/controllers/pets.controller.js
import { db } from "../database/database.js";

// GET /pets
export const listarPets = (req, res) => {
  db.all("SELECT * FROM pets", [], (err, rows) => {
    if (err) {
      console.error("❌ Erro ao listar pets:", err.message);
      return res.status(500).json({ error: "Erro ao listar pets" });
    }

    return res.json(rows);
  });
};

// POST /pets
export const createPet = (req, res) => {
  try {
    console.log("===== CREATE PET =====");
    console.log("BODY:", req.body);
    console.log("FILE:", req.file);

    const {
      nome,
      especie,
      raca,
      idade,
      descricao,
      cidade,
      estado,
      bairro,
      telefoneTutor,
      usuario_id,
    } = req.body;

    // caminho da foto
    let fotoPath = null;
    if (req.file) {
      fotoPath = `/uploads/${req.file.filename}`;
    } else if (req.body.foto) {
      fotoPath = req.body.foto;
    }

    // Validações básicas
    if (
      !nome ||
      !especie ||
      !raca ||
      !descricao ||
      !cidade ||
      !estado ||
      !bairro
    ) {
      return res.status(400).json({
        error:
          "Nome, espécie, raça, descrição, cidade, estado e bairro são obrigatórios",
      });
    }

    const sql = `
      INSERT INTO pets (
        nome, especie, raca, idade,
        descricao, cidade, estado, bairro,
        foto, telefoneTutor, usuario_id
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    db.run(
      sql,
      [
        nome,
        especie,
        raca,
        idade ?? null,
        descricao,
        cidade,
        estado,
        bairro,
        fotoPath,
        telefoneTutor ?? null,
        usuario_id ?? null,
      ],
      function (err) {
        if (err) {
          console.error("❌ Erro ao adicionar pet:", err.message);
          return res.status(500).json({ error: "Erro ao adicionar pet" });
        }

        console.log("✅ Pet inserido com ID:", this.lastID);

        return res.status(201).json({
          message: "Pet adicionado com sucesso!",
          id: this.lastID,
          nome,
          especie,
          raca,
          idade,
          descricao,
          cidade,
          estado,
          bairro,
          foto: fotoPath,
          telefoneTutor: telefoneTutor ?? null,
          usuario_id: usuario_id ?? null,
        });
      }
    );
  } catch (err) {
    console.error("❌ Erro inesperado ao criar pet:", err);
    return res
      .status(500)
      .json({ error: "Erro interno ao cadastrar pet." });
  }
};