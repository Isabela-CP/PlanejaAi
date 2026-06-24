# Planeja.AI

Este é o repositório do **Planeja.AI**, contendo o aplicativo Frontend (Flutter) e o servidor Backend (Flask + PostgreSQL).

---

## 🚀 Como Rodar o Projeto

Para testar o aplicativo completo na sua máquina, siga os passos abaixo:

### 1. Subir o Banco de Dados e Servidor (Backend)
O nosso backend utiliza o Docker para rodar de forma isolada, garantindo que funcione igual em qualquer computador.

Abra um terminal, entre na pasta do backend e rode:
```bash
cd backend
docker compose up -d --build
```
> O comando acima vai subir o banco de dados PostgreSQL e a API em Flask.

### 2. Rodar o Aplicativo (Frontend)
O aplicativo Flutter agora suporta rodar tanto como um Aplicativo de Computador (Linux) quanto direto no Navegador (Web/Chrome). 

Abra **outro** terminal, na raiz do projeto (pasta `planeja_ai`) e escolha **UMA** das opções abaixo:

**Opção A: Rodar no Navegador (Google Chrome)**
Excelente para testar rapidamente a interface Web.
```bash
flutter run -d chrome
```

**Opção B: Rodar como Aplicativo Desktop (Linux Ubuntu)**
Para uma experiência de software nativo.
*(Aviso: É necessário ter o pacote `libsecret-1-dev` instalado no Ubuntu para o cofre de senhas funcionar).*
```bash
flutter run -d linux
```

---

## 🔒 Segurança (Padrões SonarQube)
Este projeto implementa as diretrizes do SonarQube:
- Senhas são criptografadas com `bcrypt` no PostgreSQL.
- O Frontend armazena Tokens localmente usando `flutter_secure_storage` (Keychain/Hardware crypto).
- Nenhuma URL ou Segredo está hardcoded no código (utilizamos o arquivo `.env` para as variáveis do ambiente).
- Tratamento de exceções não vaza stacktraces para a UI.
