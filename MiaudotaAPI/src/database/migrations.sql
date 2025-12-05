PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS pets;
DROP TABLE IF EXISTS usuarios;

CREATE TABLE IF NOT EXISTS usuarios (
  id                 INTEGER PRIMARY KEY AUTOINCREMENT,
  nome               TEXT NOT NULL,
  cpf                TEXT UNIQUE,
  cnpj               TEXT,
  is_pessoa_juridica INTEGER DEFAULT 0,
  email              TEXT NOT NULL UNIQUE,
  telefone           TEXT,
  cidade             TEXT,
  estado             TEXT,
  bairro             TEXT,
  senha_hash         TEXT NOT NULL
);

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
  usuario_id INTEGER NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);
