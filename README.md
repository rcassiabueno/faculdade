# Projetos da Faculdade
# faculdade

# Miaudota - Aplicativo de Adoção de Animais

Este projeto foi desenvolvido como parte da disciplina HOW IX, com o objetivo de criar uma solução tecnológica para promover a adoção responsável de animais.

## Objetivo

O Miaudota busca facilitar a conexão entre:
- Adotantes
- Protetores independentes
- Abrigos de animais

Através de uma aplicação mobile simples, intuitiva e acessível.

## Funcionalidades principais

- Cadastro de animais para adoção
- Listagem com filtros de busca
- Visualização de detalhes dos pets
- Contato direto via WhatsApp
- Cadastro e gerenciamento de usuários

## Metodologia

O projeto foi desenvolvido utilizando:
- Scrum (organização em sprints)
- TDD (Test-Driven Development)
- Prototipação com Figma

## Tecnologias utilizadas

- Flutter (Frontend Mobile)
- Node.js (Backend)
- SQLite (Banco de dados)
- GitHub (Versionamento)

## Como executar o projeto

### Backend
1. Acesse a pasta `MiaudotaAPI`
2. Instale as dependências:
	npm install
3. Execute:
   	npm start


### Mobile
1. Acesse a pasta `miaudotaApp`
2. Execute:
	flutter pub get
	flutter run

## 📦 Arquivo executável

O APK do aplicativo foi gerado para testes e pode ser disponibilizado conforme necessidade.

## 🔗 Links do projeto

- 📊 Gestão do projeto (Notion): https://www.notion.so/Scrum-Projeto-Miaudota-d2a29e98d32482ea866f81e99bd8fae8?source=copy_link
- 🎥 Vídeo de apresentação: https://www.youtube.com/watch?v=RUMyetVzwhI

## MiaudotaAPI - Dev notes

- The API provides two ways to reset a user password:
	- POST `/users/forgot-password`: sends a reset link by e-mail (recommended for production).
	- POST `/users/reset-password/by-cpf`: for **development only**, allows resetting a user's password by supplying `email`, `cpf` and `novaSenha`. This endpoint returns 403 if `NODE_ENV === 'production'`.

- SMTP configuration (for email delivery) lives in `MiaudotaAPI/.env` with:
	- `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_SECURE`, `EMAIL_USER`, `EMAIL_PASS`, `EMAIL_FROM`

- During development, if SMTP credentials are missing or invalid the server falls back to an Ethereal test account (nodemailer), so you can inspect message previews in dev without sending real e-mails.

---

Desenvolvido por:
- Rita de Cássia Bueno
- Hugo Guedes Bonsanto
