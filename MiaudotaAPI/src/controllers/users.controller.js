import { db } from "../database/database.js";
import bcrypt from "bcrypt";

// POST /users/register
export const register = (req, res) => {
  console.log("📦 Body recebido no /users/register:", req.body);

  let { nome, email, senha, cpf, cnpj, telefone, isPessoaJuridica } = req.body;

  // campos obrigatórios base
  if (!nome || !email || !senha) {
    return res.status(400).json({
      error: "nome, email e senha são obrigatórios",
    });
  }

  // descobre se é PJ
  const isPJ = isPessoaJuridica === true || isPessoaJuridica === "true";

  // valida documento conforme o tipo
  if (isPJ) {
    if (!cnpj) {
      return res
        .status(400)
        .json({ error: "CNPJ é obrigatório para pessoa jurídica" });
    }
  } else {
    if (!cpf) {
      return res
        .status(400)
        .json({ error: "CPF é obrigatório para pessoa física" });
    }
  }

  // normaliza documentos (só dígitos)
  if (cpf) cpf = cpf.replace(/\D/g, "");
  if (cnpj) cnpj = cnpj.replace(/\D/g, "");

  const senhaHash = bcrypt.hashSync(senha, 10);

  const sql = `
    INSERT INTO usuarios (
      nome,
      cpf,
      cnpj,
      is_pessoa_juridica,
      email,
      telefone,
      senha_hash
    )
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `;

  db.run(
    sql,
    [
      nome,
      cpf || null,
      cnpj || null,
      isPJ ? 1 : 0,
      email,
      telefone || "",
      senhaHash,
    ],
    function (err) {
      if (err) {
        console.error("❌ Erro ao registrar usuário:", err);

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
          cnpj,
          isPessoaJuridica: isPJ,
          email,
          telefone,
        },
      });
    }
  );
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
    SELECT *
    FROM usuarios
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

    // monta no formato que o app espera
    const usuarioResposta = {
      id: usuario.id,
      nome: usuario.nome,
      cpf: usuario.cpf,
      cnpj: usuario.cnpj,
      isPessoaJuridica: !!usuario.is_pessoa_juridica,
      email: usuario.email,
      telefone: usuario.telefone,
      estado: usuario.estado,
      cidade: usuario.cidade,
      bairro: usuario.bairro,
    };

    return res.json({
      message: "Login bem-sucedido",
      usuario: usuarioResposta,
    });
  });
};


// POST /users/reset-password
// Redefine a senha usando email + CPF ou CNPJ + novaSenha
export const resetPassword = (req, res) => {
  let { email, cpf, cnpj, novaSenha } = req.body;

  if (!email || !novaSenha) {
    return res
      .status(400)
      .json({ error: "email e novaSenha são obrigatórios" });
  }

  if (!cpf && !cnpj) {
    return res
      .status(400)
      .json({ error: "Informe CPF ou CNPJ para redefinir a senha." });
  }

  // normaliza documentos
  if (cpf) cpf = cpf.replace(/\D/g, "");
  if (cnpj) cnpj = cnpj.replace(/\D/g, "");

  const documento = cpf || cnpj;
  const colunaDocumento = cpf ? "cpf" : "cnpj";

  const sqlSelect = `
    SELECT *
      FROM usuarios
     WHERE email = ?
       AND ${colunaDocumento} = ?
     LIMIT 1
  `;

  db.get(sqlSelect, [email, documento], (err, usuario) => {
    if (err) {
      console.error("❌ Erro ao buscar usuário para reset de senha:", err);
      return res.status(500).json({ error: "Erro interno ao buscar usuário" });
    }

    if (!usuario) {
      return res.status(404).json({
        error: "Nenhum usuário encontrado com esse e-mail e documento.",
      });
    }

    const senhaHash = bcrypt.hashSync(novaSenha, 10);

    const sqlUpdate = `
      UPDATE usuarios
         SET senha_hash = ?
       WHERE id = ?
    `;

    db.run(sqlUpdate, [senhaHash, usuario.id], function (err2) {
      if (err2) {
        console.error("❌ Erro ao atualizar senha:", err2);
        return res
          .status(500)
          .json({ error: "Erro ao atualizar senha", detalhes: err2.message });
      }

      return res.json({ message: "Senha redefinida com sucesso!" });
    });
  });
};


// PUT /users/profile/:id

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
    if ((process.env.NODE_ENV || 'development') === 'production') {
      return res.status(403).json({ error: 'Endpoint disabled in production' });
    }
    const { email, cpf, novaSenha } = req.body;

    if (!email || !cpf || !novaSenha) {
      return res.status(400).json({ error: 'email, cpf e novaSenha são obrigatórios' });
    }

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


