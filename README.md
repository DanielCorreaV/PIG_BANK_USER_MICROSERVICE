
---

# PIG BANK USER MICROSERVICE

Este repositorio contiene el microservicio de gestión de usuarios, diseñado bajo principios de **Clean Architecture** y desplegado en **AWS** utilizando un enfoque Serverless. Permite el registro, autenticación, gestión de perfiles y carga de avatares.

## 🏗️ Arquitectura del Proyecto

El proyecto sigue una estructura de capas para asegurar la escalabilidad y el desacoplamiento:

* **Application:** Contiene los casos de uso (`useCases`) como `register-user`, `login`, etc.
* **Domain:** Define las entidades de negocio y las interfaces (puertos) para los repositorios.
* **Infrastructure:** Implementaciones técnicas (Database con DynamoDB, Handlers para Lambda, Middleware y Esquemas).
* **Terraform:** Infraestructura como código (IaC) para automatizar el despliegue en AWS.

---

## 🛠️ Stack Tecnológico

* **Lenguaje:** TypeScript
* **Runtime:** AWS Lambda (Node.js)
* **Infraestructura:** Terraform
* **Base de Datos:** Amazon DynamoDB
* **Almacenamiento:** Amazon S3 (para imágenes de perfil)
* **Seguridad:** AWS Secrets Manager (Gestión de secretos) y JWT (Autenticación)
* **API Gateway:** Punto de entrada REST

---

## 📑 Endpoints y Contratos

### 1. Registro de Usuario

**POST** `/register`

Crea un nuevo usuario con contraseña cifrada.

```json
{
  "name": "Jane",
  "lastName": "Doe",
  "email": "jane@doe.com",
  "password": "1234567890",
  "document": "1234567890"
}

```

### 2. Login

**POST** `/login`

Autentica al usuario y devuelve un token JWT.

```json
{
  "email": "jane@doe.com",
  "password": "1234567890"
}

```

### 3. Actualizar Perfil

**PUT** `/profile/{user_id}`

Permite actualizar dirección y teléfono.

```json
{
  "address": "Cll 55B",
  "phone": "0987654321"
}

```

### 4. Cargar Avatar

**POST** `/profile/{user_id}/avatar`

Recibe un string en `base64`. La Lambda procesa la imagen, genera un nombre único y la almacena en **S3**, actualizando la URL en **DynamoDB**.

```json
{
  "image": "base64_string_here",
  "fileType": "image/jpeg"
}

```

### 5. Obtener Perfil

**GET** `/profile/{user_id}`

Retorna la información completa del usuario, incluyendo la URL de la imagen de perfil.

---

## 🗄️ Modelo de Datos (DynamoDB)

La tabla `user-table` utiliza la siguiente estructura:

* **Partition Key:** `uuid`
* **Sort Key:** `document`

**Esquema del Item:**

```json
{
  "uuid": "uuid-v4",
  "name": "Jane",
  "lastName": "Doe",
  "email": "jane@doe.com",
  "password": "hashed_password",
  "document": "1234567890",
  "address": "Cll 55B",
  "phone": "0987654321",
  "image": "https://s3.amazonaws.com/bucket-name/path/filename.jpg"
}

```

---

## 🚀 Despliegue con Terraform

Para desplegar la infraestructura, navega a la carpeta `terraform/` y ejecuta:

1. `terraform init`
2. `terraform plan`
3. `terraform apply`

Asegúrate de tener configuradas tus credenciales de AWS y las variables necesarias en `variable.tf`.

---¿
