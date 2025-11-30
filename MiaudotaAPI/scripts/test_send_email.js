// Script para testar o envio de email usando o serviço de email configurado. (Função desativada no momento)

import dotenv from 'dotenv';
dotenv.config();
import { transporter } from '../src/services/email.service.js';

async function run() {
  try {
    const info = await transporter.sendMail({
      from: process.env.EMAIL_FROM || process.env.EMAIL_USER,
      to: process.env.TEST_EMAIL || process.env.EMAIL_USER,
      subject: 'Teste de envio - Miaudota',
      text: 'Este é um teste de envio de e-mail.',
    });
    console.log('✅ Email enviado com sucesso:', info);
  } catch (err) {
    console.error('❌ Erro ao enviar email no script de teste:', err);
    process.exit(1);
  }
}

run();
