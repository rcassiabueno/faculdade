import { db } from "../database/database.js";
import bcrypt from "bcrypt";
import crypto from "crypto";
//import { transporter } from "../services/email.service.js"; inserir posteriormente quando usar email.

// POST /users/register
export const register = (req, res) => {
  console.log("📦 Body recebido no /users/register:", req.body);

  let { nome, email, senha, cpf, telefone } = req.body;

  // campos obrigatórios
  if (!nome || !email || !senha || !cpf) {
    return res.status(400).json({
      error: "nome, email, senha e cpf são obrigatórios",
    });
  }

  // deixa só os dígitos no CPF
  cpf = cpf.replace(/\D/g, "");

  const senhaHash = bcrypt.hashSync(senha, 10);

  const sql = `
    INSERT INTO usuarios (nome, cpf, email, telefone, senha_hash)
    VALUES (?, ?, ?, ?, ?)
  `;

  db.run(sql, [nome, cpf, email, telefone || "", senhaHash], function (err) {
    if (err) {
      console.error("❌ Erro ao registrar usuário:", err);

      // Tratamento para CPF/e-mail duplicados
      if (err.code === "SQLITE_CONSTRAINT") {
        if (err.message.includes("usuarios.cpf")) {
          return res.status(400).json({
            error: "CPF já cadastrado. Tente outro.",
          });
        }
        if (err.message.includes("usuarios.email")) {
          return res.status(400).json({
            error: "E-mail já cadastrado. Tente outro.",
          });
        }

        return res.status(400).json({
          error: "Dados inválidos para cadastro.",
        });
      }

      return res.status(500).json({
        error: "Erro ao registrar usuário",
        detalhes: err.message,
      });
    }

    return res.status(201).json({
      message: "Usuário registrado com sucesso!",
      usuario: {
        id: this.lastID,
        nome,
        cpf,
        email,
        telefone,
      },
    });
  });
};


export const login = (req, res) => {
  console.log("📦 Body recebido no /users/login:", req.body);

  const { email, senha } = req.body;

  if (!email || !senha) {
    return res
      .status(400)
      .json({ error: "email e senha são obrigatórios" });
  }

  const sql = `
    SELECT * FROM usuarios
    WHERE email = ?
    LIMIT 1
  `;

  db.get(sql, [email], (err, usuario) => {
    if (err) {
      console.error("❌ Erro ao buscar usuário:", err);
      return res.status(500).json({ error: "Erro interno ao buscar usuário" });
    }

    if (!usuario) {
      return res.status(401).json({ error: "Usuário ou senha inválidos" });
    }

    const senhaConfere = bcrypt.compareSync(senha, usuario.senha_hash);

    if (!senhaConfere) {
      return res.status(401).json({ error: "Usuário ou senha inválidos" });
    }

    return res.json({
      message: "Login bem-sucedido",
      usuario: {
        id: usuario.id,
        nome: usuario.nome,
        email: usuario.email,
      },
    });
  });
};


export const forgotPassword = (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ error: "E-mail é obrigatório" });
  }

  // Funcionalidade de recuperação de senha por e-mail desativada nesta versão.
  // Mantemos a rota apenas para não quebrar chamadas antigas, mas ela não
  // envia mais e-mail nem gera token.

  return res.status(503).json({
    error:
      "Recuperação de senha via e-mail está desativada nesta versão. Use a redefinição de senha pelo CPF no aplicativo.",
  });
};


export const resetPassword = (req, res) => {
  const { token, novaSenha } = req.body;
  if (!token || !novaSenha)
    return res.status(400).json({ error: "token e novaSenha são obrigatórios" });

  const sql = `
    SELECT * FROM password_reset_tokens
    WHERE token = ?
    LIMIT 1
  `;

  db.get(sql, [token], (err, tokenRow) => {
    if (err) return res.status(500).json({ error: "Erro interno" });
    if (!tokenRow) return res.status(400).json({ error: "Token inválido" });
    if (Date.now() > tokenRow.expires_at)
      return res.status(400).json({ error: "Token expirado" });

    const senhaHash = bcrypt.hashSync(novaSenha, 10);

    const sqlUpdate = `UPDATE usuarios SET senha_hash = ? WHERE id = ?`;

    db.run(sqlUpdate, [senhaHash, tokenRow.usuario_id], err => {
      if (err) return res.status(500).json({ error: "Erro ao redefinir senha" });

      db.run(`DELETE FROM password_reset_tokens WHERE id = ?`, [tokenRow.id]);

      return res.json({ message: "Senha redefinida com sucesso!" });
    });
  });
};


export const updateProfile = (req, res) => {
  const { id } = req.params;

  let {
    nome,
    cpf,
    cnpj,
    isPessoaJuridica,
    telefone,
    cidade,
    estado,
    bairro,
  } = req.body;

  const isPJ = isPessoaJuridica === true || isPessoaJuridica === "true";

  if (!nome || !telefone || !cidade || !estado || !bairro) {
    return res.status(400).json({
      error: "nome, telefone, cidade, estado e bairro são obrigatórios",
    });
  }

  if (isPJ) {
    // PJ → exige CNPJ
    if (!cnpj) {
      return res
        .status(400)
        .json({ error: "CNPJ é obrigatório para pessoa jurídica" });
    }
  } else {
    // PF → exige CPF
    if (!cpf) {
      return res
        .status(400)
        .json({ error: "CPF é obrigatório para pessoa física" });
    }
  }

  // normalizar documentos (deixar só dígitos)
  if (cpf) cpf = cpf.replace(/\D/g, "");
  if (cnpj) cnpj = cnpj.replace(/\D/g, "");

  const sql = `
    UPDATE usuarios
    SET 
      nome = ?, 
      cpf = ?, 
      cnpj = ?, 
      is_pessoa_juridica = ?, 
      telefone = ?, 
      cidade = ?, 
      estado = ?, 
      bairro = ?
    WHERE id = ?
  `;

  db.run(
    sql,
    [
      nome,
      cpf || null,          // se for PJ, cpf pode ficar null
      cnpj || null,         // se for PF, cnpj pode ficar null
      isPJ ? 1 : 0,         // coluna INTEGER 0/1
      telefone,
      cidade,
      estado,
      bairro,
      id,
    ],
    function (err) {
      if (err) {
        console.error("❌ Erro ao atualizar perfil:", err);
        return res
          .status(500)
          .json({ error: "Erro ao atualizar perfil", detalhes: err.message });
      }

      if (this.changes === 0) {
        return res.status(404).json({ error: "Usuário não encontrado" });
      }

      return res.json({
        message: "Perfil atualizado com sucesso",
      });
    }
  );
};
  export const deleteUser = (req, res) => {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({ error: "ID do usuário é obrigatório" });
    }

    db.run("DELETE FROM pets WHERE usuario_id = ?", [id]);
    db.run("DELETE FROM password_reset_tokens WHERE usuario_id = ?", [id]);

    const sql = `DELETE FROM usuarios WHERE id = ?`;

    db.run(sql, [id], function (err) {
      if (err) {
        console.error("❌ Erro ao excluir usuário:", err.message);
        return res
          .status(500)
          .json({ error: "Erro ao excluir usuário", detalhes: err.message });
      }

      if (this.changes === 0) {
        return res.status(404).json({ error: "Usuário não encontrado" });
      }

      return res.json({ message: "Usuário excluído com sucesso" });
    });
  };

  // POST /users/reset-password/by-cpf
  export const resetPasswordByCpf = (req, res) => {
    // Only allow this endpoint in non-production environments. In production,
    // prefer secure password reset via email with tokens.
    if ((process.env.NODE_ENV || 'development') === 'production') {
      return res.status(403).json({ error: 'Endpoint disabled in production' });
    }
    const { email, cpf, novaSenha } = req.body;

    if (!email || !cpf || !novaSenha) {
      return res.status(400).json({ error: 'email, cpf e novaSenha são obrigatórios' });
    }

    // normalizar CPF
    // NOTE: This endpoint allows resetting a user's password by POSTing the
    // email + CPF + novaSenha. This is insecure for production (anyone knowing
    // the user's email and CPF could reset the password). Use only for dev or
    // add extra identity checks (SMS, 2FA) in production.
    const cpfDigits = cpf.replace(/\D/g, '');

    const sql = `
      SELECT * FROM usuarios WHERE email = ? LIMIT 1
    `;

    db.get(sql, [email], (err, usuario) => {
      if (err) return res.status(500).json({ error: 'Erro interno' });
      if (!usuario) return res.status(404).json({ error: 'Usuário não encontrado' });

      const storedCpf = usuario.cpf ? usuario.cpf.replace(/\D/g, '') : '';
      if (!storedCpf || storedCpf !== cpfDigits) {
        return res.status(401).json({ error: 'CPF não confere' });
      }

      // Atualiza senha
      const senhaHash = bcrypt.hashSync(novaSenha, 10);
      const sqlUpdate = `UPDATE usuarios SET senha_hash = ? WHERE id = ?`;
      db.run(sqlUpdate, [senhaHash, usuario.id], function (err) {
        if (err) return res.status(500).json({ error: 'Erro ao atualizar senha' });
        return res.json({ message: 'Senha redefinida com sucesso' });
      });
    });
  };


