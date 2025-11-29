import crypto from "crypto";
import { db } from "../database/database.js";
import bcrypt from "bcrypt";
import { transporter } from "../services/email.service.js";


// 1) Usuário solicita redefinição
export const requestResetPassword = (req, res) => {
  const { email } = req.body;

  const token = crypto.randomBytes(32).toString("hex");
  const expires = Date.now() + 1000 * 60 * 30; // expira em 30 min

  db.run(
    `UPDATE usuarios SET reset_token = ?, reset_expires = ? WHERE email = ?`,
    [token, expires, email],
    async function (err) {
      if (err) return res.status(500).json({ error: "Erro no servidor" });
      if (this.changes === 0)
        return res.status(200).json({
          message: "Se o e-mail estiver cadastrado, enviaremos o link.",
        });

      const resetLink = `${process.env.APP_URL}/reset-password?token=${token}`;

      try {
        await transporter.sendMail({
          from: process.env.EMAIL_FROM || process.env.EMAIL_USER,
          to: email,
          subject: "Redefinição de senha - Miaudota",
          html: `
            <p>Você pediu para redefinir sua senha.</p>
            <p>Clique no link abaixo para continuar:</p>
            <a href="${resetLink}">${resetLink}</a>
            <p>O link expira em 30 minutos.</p>
          `,
        });
      } catch (err) {
        console.error('❌ Erro ao enviar e-mail de redefinição (password.controller):', err.message || err);
        return res.status(500).json({ error: 'Erro ao enviar e-mail de redefinição' });
      }

      return res.status(200).json({
        message: "Se o e-mail estiver cadastrado, enviaremos o link.",
      });
    }
  );
};


// 2) Usuário redefine senha
export const resetPassword = (req, res) => {
  const { token, senha } = req.body;
  const senhaHash = bcrypt.hashSync(senha, 10);

  db.run(
    `UPDATE usuarios SET senha_hash = ?, reset_token = NULL, reset_expires = NULL
     WHERE reset_token = ? AND reset_expires > ?`,
    [senhaHash, token, Date.now()],
    function (err) {
      if (err) return res.status(500).json({ error: "Erro no servidor" });
      if (this.changes === 0)
        return res.status(400).json({ error: "Link inválido ou expirado" });

      return res.json({ message: "Senha atualizada com sucesso!" });
    }
  );
};
