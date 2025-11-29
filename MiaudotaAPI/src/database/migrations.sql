-- Ativar integridade referencial (caso o cliente SQLite suporte)
PRAGMA foreign_keys = ON;

------------------------------------------------------------
-- LIMPEZA OPCIONAL (usar apenas em ambiente de desenvolvimento)
------------------------------------------------------------
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS pets;
DROP TABLE IF EXISTS usuarios;

------------------------------------------------------------
-- TABELA DE USUÁRIOS
-- Alinhada com: database.js + users.controller.js + EditProfilePage
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
  id                 INTEGER PRIMARY KEY AUTOINCREMENT,
  nome               TEXT NOT NULL,
  cpf                TEXT UNIQUE,               -- usado no register (validação de duplicidade)
  cnpj               TEXT,                      -- para pessoa jurídica (ONG)
  is_pessoa_juridica INTEGER DEFAULT 0,         -- 0 = PF, 1 = PJ
  email              TEXT NOT NULL UNIQUE,
  telefone           TEXT,
  cidade             TEXT,                      -- usados no EditProfilePage / AppState.userProfile
  estado             TEXT,
  bairro             TEXT,
  senha_hash         TEXT NOT NULL
);

------------------------------------------------------------
-- TABELA DE PETS
-- Alinhada com: PetFormPage + PetService.createPet + AdoptionPage
------------------------------------------------------------
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

------------------------------------------------------------
-- TABELA DE TOKENS DE REDEFINIÇÃO DE SENHA
-- Alinhada com: users.controller.js (forgotPassword / resetPassword)
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  usuario_id  INTEGER NOT NULL,
  token       TEXT NOT NULL UNIQUE,
  expires_at  INTEGER NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);
