# SnapSafe

SnapSafe is a secure file upload and storage API built with Phoenix (Elixir). It provides authenticated file management with user isolation, supporting multiple file types with size restrictions.

## Features

- **Secure Authentication**: JWT-based authentication with user registration and login
- **File Upload**: Support for JPG, PNG, GIF, SVG, TXT, MD, CSV files up to 2MB
- **User Isolation**: Users can only access their own files
- **RESTful API**: Clean endpoints for upload, list, and download operations

## API Endpoints

### Authentication
- `POST /api/register` - Register a new user
- `POST /api/login` - Login and receive JWT token

### File Management (Requires Authentication)
- `POST /api/upload` - Upload a file
- `GET /api/files` - List user's files
- `GET /api/files/:id` - Download a specific file

## Getting Started

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4001`](http://localhost:4001) from your browser.

## Usage Examples

### Register a User
```bash
curl -X POST http://localhost:4001/api/register \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "user@example.com", "password": "password123"}}'
```

### Login
```bash
curl -X POST http://localhost:4001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'
```

### Upload a File
```bash
curl -X POST http://localhost:4001/api/upload \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/path/to/your/file.jpg"
```

### List Files
```bash
curl -X GET http://localhost:4001/api/files \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Download a File
```bash
curl -X GET http://localhost:4001/api/files/FILE_ID \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -o downloaded_file.jpg
```

## Security Features

- Password hashing with bcrypt
- JWT token authentication
- File type validation
- File size limits (2MB max)
- User ownership enforcement
- Filename sanitization

## Supported File Types

- Images: JPG, PNG, GIF, SVG
- Text: TXT, MD, CSV

## Development Tools

This project includes several development tools to maintain code quality:

- **Credo**: Static code analysis for Elixir
  - Run `mix credo` for code analysis
  - Run `mix quality` for formatting and strict code analysis
  - Run `mix quality.fix` to auto-generate config for new issues

- **Dialyzer**: Static type analysis via Dialyxir
  - Run `mix dialyzer` for type checking
  - Run `mix dialyzer.build` to rebuild PLT files
  - First run takes longer to build PLT (Persistent Lookup Table)

Available Mix aliases:
- `mix setup` - Install dependencies and setup database
- `mix quality` - Run formatter and Credo with strict checks
- `mix quality.fix` - Run formatter and Credo with auto-config generation
- `mix quality.ci` - Full quality check (format check, Credo, Dialyzer)
- `mix dialyzer` - Run type analysis
- `mix dialyzer.build` - Build/rebuild Dialyzer PLT files
- `mix test` - Run tests with database setup

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
