import sqlite3 from "sqlite3";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dbPath = path.resolve(__dirname, "miaudota.db");

export const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error("Erro ao conectar ao banco SQLite:", err.message);
  } else {
    console.log("Conectado ao banco SQLite em:", dbPath);
  }
});

db.serialize(() => {
  // Tabela de usuários
  db.run(
    `
    CREATE TABLE IF NOT EXISTS usuarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      cpf TEXT,
      cnpj TEXT,
      is_pessoa_juridica INTEGER DEFAULT 0,
      email TEXT NOT NULL UNIQUE,
      telefone TEXT,
      cidade TEXT,
      estado TEXT,
      bairro TEXT,
      senha_hash TEXT NOT NULL
    );
  `,
    (err) => {
      if (err) console.error("Erro ao criar tabela usuarios:", err.message);
      else console.log("Tabela usuarios pronta para uso");
    }
  );

  // Endereços (opcional)
  db.run(
    `
    CREATE TABLE IF NOT EXISTS enderecos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      estado TEXT NOT NULL,
      cidade TEXT NOT NULL,
      bairro TEXT NOT NULL
    );
  `,
    (err) => {
      if (err) console.error("Erro ao criar tabela enderecos:", err.message);
      else console.log("Tabela enderecos pronta para uso");
    }
  );

  // Pets
  db.run(
    `
    CREATE TABLE IF NOT EXISTS pets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      especie TEXT NOT NULL,
      raca TEXT NOT NULL,
      idade TEXT,
      descricao TEXT NOT NULL,
      cidade TEXT NOT NULL,
      estado TEXT NOT NULL,
      bairro TEXT NOT NULL,
      foto TEXT,
      telefoneTutor TEXT,
      usuario_id INTEGER,
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    );
  `,
    (err) => {
      if (err) console.error("Erro ao criar tabela pets:", err.message);
      else console.log("Tabela pets pronta para uso");
    }
  );

  // ================================
  //   INSERIR PETS INICIAIS SE VAZIO
  // ================================
  db.get("SELECT COUNT(*) AS total FROM pets", (err, row) => {
    if (err) {
      console.error("Erro ao verificar pets:", err.message);
      return;
    }

    if (row.total === 0) {
      console.log("Inserindo pets iniciais...");

      const insert = db.prepare(`
        INSERT INTO pets
        (nome, especie, raca, idade, descricao, cidade, estado, bairro, foto, telefoneTutor)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `);

      insert.run(
        "Tom",
        "Gato",
        "SDR",
        "40 dias",
        "Super brincalhão, curioso e adora explorar cada cantinho. Está em busca de uma família carinhosa e responsável para dar muito amor e atenção!",
        "Itajaí",
        "SC",
        "Itaipava",
        "tom.png",
        "47999157777"
      );

      insert.run(
        "Jane",
        "Cachorro",
        "SDR",
        "1 ano",
        "Ela é a definição de companheira leal, sempre pronta para uma aventura, seja uma longa caminhada no parque ou uma sessão de brincadeiras no quintal.",
        "Itajaí",
        "SC",
        "Itaipava",
        "jane.png",
        "47999157777"
      );

      insert.finalize(() => {
        console.log("Pets iniciais inseridos com sucesso!");
      });
    }
  });
});