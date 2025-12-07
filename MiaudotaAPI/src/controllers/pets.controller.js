// src/controllers/pets.controller.js
import { db } from '../database/database.js';

// LISTAR PETS
export async function index(req, res) {
  db.all("SELECT * FROM pets", [], (err, rows) => {
    if (err) {
      console.error("Erro ao listar pets:", err.message);
      return res.status(500).json({ error: "Erro ao listar pets" });
    }

    return res.json(rows || []);
  });
}

// CRIAR PET
export async function store(req, res) {
  try {
    console.log('DEBUG STORE /pets V3 FOI CHAMADO');
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
      foto_url,
    } = req.body;

    // PRIORIDADE:
    // 1) se veio arquivo -> usa upload
    // 2) senão, se veio link -> usa link
    // 3) senão, null
    let fotoPath = null;

    if (req.file) {
      fotoPath = `/uploads/${req.file.filename}`;
    } else if (foto_url) {
      fotoPath = foto_url;
    }

    const sql = `
      INSERT INTO pets (
        nome, especie, raca, idade, descricao,
        cidade, estado, bairro, telefoneTutor,
        usuario_id, foto
      )
      VALUES (?,?,?,?,?,?,?,?,?,?,?)
    `;

    const params = [
      nome,
      especie,
      raca,
      idade,
      descricao,
      cidade,
      estado,
      bairro,
      telefoneTutor,
      usuario_id || null,
      fotoPath,
    ];

    console.log('DEBUG /pets - params:', params); 

    db.run(sql, params, function (err) {
      if (err) {
        console.error('ERRO SQLITE AO CADASTRAR PET:', err);
        return res.status(500).json({
          error: err.message || 'Erro ao cadastrar pet',
        });
      }

      // this.lastID = id gerado
      return res.status(201).json({
        id: this.lastID,
        nome,
        especie,
        raca,
        idade,
        descricao,
        cidade,
        estado,
        bairro,
        telefoneTutor,
        foto: fotoPath,
        usuario_id: usuario_id || null,
      });
    });
  } catch (e) {
    console.error('ERRO GERAL NO CONTROLLER /pets:', e);
    return res.status(500).json({
      error: e.message || 'Erro ao cadastrar pet',
    });
  }
}

// ATUALIZAR PET
export async function update(req, res) {
  const { id } = req.params;

  try {
    // 1) Busca o pet atual pra manter a foto se não vier nova
    db.get('SELECT * FROM pets WHERE id = ?', [id], (err, petAtual) => {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: 'Erro ao buscar pet' });
      }
      if (!petAtual) {
        return res.status(404).json({ error: 'Pet não encontrado' });
      }

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
        foto_url, 
      } = req.body;

      let fotoPath = petAtual.foto;

      if (req.file) {
        fotoPath = `/uploads/${req.file.filename}`;
      } else if (foto_url) {
        fotoPath = foto_url;
      }

      const sql = `
        UPDATE pets
        SET
          nome = ?,
          especie = ?,
          raca = ?,
          idade = ?,
          descricao = ?,
          cidade = ?,
          estado = ?,
          bairro = ?,
          telefoneTutor = ?,
          foto = ?
        WHERE id = ?
      `;

      const params = [
        nome ?? petAtual.nome,
        especie ?? petAtual.especie,
        raca ?? petAtual.raca,
        idade ?? petAtual.idade,
        descricao ?? petAtual.descricao,
        cidade ?? petAtual.cidade,
        estado ?? petAtual.estado,
        bairro ?? petAtual.bairro,
        telefoneTutor ?? petAtual.telefoneTutor,
        fotoPath,
        id,
      ];

      db.run(sql, params, function (err2) {
        if (err2) {
          console.error(err2);
          return res
            .status(500)
            .json({ error: 'Erro ao atualizar pet' });
        }

        return res.status(200).json({
          id: petAtual.id,
          nome: params[0],
          especie: params[1],
          raca: params[2],
          idade: params[3],
          descricao: params[4],
          cidade: params[5],
          estado: params[6],
          bairro: params[7],
          telefoneTutor: params[8],
          foto: fotoPath,
        });
      });
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Erro ao atualizar pet' });
  }
}
