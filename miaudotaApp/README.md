# MiaudotaApp — local dev notes

- The Forgot Password screen supports two flows:
  - Send reset link by e-mail (production-ready) — requires SMTP settings in `MiaudotaAPI/.env`
  - Local reset (email + CPF + new password) — **development** convenience only

- To re-enable e-mail sending, ensure SMTP credentials are valid and `MiaudotaAPI` can authenticate with the provider.
# Miaudota! – Aplicativo para Adoção de Pets

O **Miaudota!** é um aplicativo mobile desenvolvido com Flutter para facilitar a conexão entre pessoas interessadas em adotar animais e responsáveis que desejam encontrar um novo lar para seus pets.

O projeto foi criado com o objetivo de promover uma adoção responsável, oferecendo uma experiência simples, rápida e humanizada tanto para quem adota quanto para quem doa.

---

## Status do Projeto
- Em desenvolvimento  
- Versão atual: execução local (sem backend)  
- Dados armazenados apenas no dispositivo — não existe sincronização entre usuários ainda

---

## Funcionalidades Implementadas

### Usuário
- Criar conta
- Login
- Recuperação de senha (navegação básica)
- Edição de perfil
- Validação obrigatória do perfil para solicitar adoção ou cadastrar pets

### Pets
- Cadastro de pets para adoção
- Edição de pets cadastrados
- Exclusão de pets
- Visualização com página de detalhes

### Adoção
- Solicitação de adoção
- Sistema de solicitações pendentes
- Aprovação ou recusa por quem cadastrou o pet
- Exibição de pets adotados / aguardando aprovação

### Filtros
- Filtrar pets por espécie, raça, cidade e estado
- Modal com UI aprimorada e botões aplicar/limpar

---

## Tecnologias Utilizadas
| Categoria | Tecnologia |
|----------|------------|
| Framework | Flutter |
| Linguagem | Dart |
| Gerenciamento de estado | AppState (local) |
| UI | Material Design 3 |
| Recursos de app | Snackbar, Navigator, Dialog, Forms |

---

## Como rodar o projeto

### 1 - Pré-requisitos
- Flutter instalado
- SDK → 3.x recomendado
- Emulador Android ou smartphone via USB

### 2 - Instalar dependências
```bash
flutter pub get
```

### 3 - Executar o aplicativo
```bash
flutter run
```

#### Gerar APK (para instalar no celular)
```bash
flutter build apk --release
```

## Equipe
| Integrante                       | Função          |
| -------------------------------- | --------------- |
| **Hugo Guedes Bonsanto**         | Desenvolvimento |
| **João Victor Frota de Azevedo** | Desenvolvimento |
| **Lauren Duarte Fagundes**       | Desenvolvimento |
| **Rita de Cássia Bueno**         | Desenvolvimento |

## Roadmap — Melhorias Planejadas
| Fase    | Implementação                         |
| ------- | ------------------------------------- |
| Próxima | Upload real de imagens                |
| Futuro  | Sincronização em nuvem entre usuários |
| Futuro  | Notificações Push                     |
| Futuro  | Autenticação por rede social          |
| Futuro  | Dashboard para ONG                    |
| Futuro  | Chat Tutor ↔ Interessado              |

Opções de backend consideradas

- Firebase (Auth + Firestore + Storage)
- Node.js + Banco (PostgreSQL / MySQL / MongoDB)
- Node.js + SQLite (para implantação simples)

## Objetivo Social

O Miaudota! nasceu com propósito:
- aproximar pessoas e animais em situação de vulnerabilidade,
- incentivar adoção responsável e afetiva,
- facilitar o trabalho das ONGs e protetores independentes.

## Licença

Projeto acadêmico — uso educacional e demonstrativo.

Se precisar de ajuda para rodar o projeto, testar o APK ou contribuir, entre em contato!
Obrigada por apoiar a adoção responsável 🐶🐱💙