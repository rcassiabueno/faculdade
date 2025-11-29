# Projetos da Faculdade
# faculdade

## MiaudotaAPI - Dev notes

- The API provides two ways to reset a user password:
	- POST `/users/forgot-password`: sends a reset link by e-mail (recommended for production).
	- POST `/users/reset-password/by-cpf`: for **development only**, allows resetting a user's password by supplying `email`, `cpf` and `novaSenha`. This endpoint returns 403 if `NODE_ENV === 'production'`.

- SMTP configuration (for email delivery) lives in `MiaudotaAPI/.env` with:
	- `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_SECURE`, `EMAIL_USER`, `EMAIL_PASS`, `EMAIL_FROM`

- During development, if SMTP credentials are missing or invalid the server falls back to an Ethereal test account (nodemailer), so you can inspect message previews in dev without sending real e-mails.

