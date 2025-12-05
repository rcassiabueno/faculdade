import bcrypt from "bcrypt";
import { db } from "../database/database.js";

// AGORA sem e-mail nem token. Só CPF/CNPJ + e-mail + novaSenha.
export const resetPassword = (req, res) => {
  const { email, cpf, cnpj, novaSenha } = req.body;

  // validações básicas
  if (!email || !novaSenha) {
    return res.status(400).json({
      error: "E-mail e nova senha são obrigatórios.",
    });
  }

  if (!cpf && !cnpj) {
    return res.status(400).json({
      error: "Informe CPF ou CNPJ.",
    });
  }

  const documento = cpf || cnpj;
  const colunaDocumento = cpf ? "cpf" : "cnpj";

  const senhaHash = bcrypt.hashSync(novaSenha, 10);

  db.run(
    `
      UPDATE usuarios
         SET senha_hash = ?,
             reset_token = NULL,
             reset_expires = NULL
       WHERE email = ?
         AND ${colunaDocumento} = ?
    `,
    [senhaHash, email, documento],
    function (err) {
      if (err) {
        console.error("Erro ao atualizar senha:", err);
        return res.status(500).json({ error: "Erro no servidor" });
      }

      if (this.changes === 0) {
        return res.status(400).json({
          error: "Nenhum usuário encontrado com esse e-mail e documento.",
        });
      }

      return res.json({ message: "Senha atualizada com sucesso!" });
    }
  );
};

