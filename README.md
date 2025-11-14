# LemonMusic SQL Lab

Proyecto del módulo **PostgreSQL** del Bootcamp de Backend.  
El objetivo es practicar consultas SQL sobre la base de datos **LemonMusic**, una plataforma musical con información sobre canciones, playlists, artistas y clientes.

---

## Contenido

El laboratorio se divide en dos bloques:

| Bloque               | Descripción                     | Archivo                               |
| :------------------- | :------------------------------ | :------------------------------------ |
| **Obligatorio**      | Consultas básicas e intermedias | `01-obligatorio/consultas.script.sql` |
| **Extra (opcional)** | Consultas avanzadas             | `02-extra/consultas-extra.script.sql` |

Cada archivo contiene:

- El enunciado de la consulta como comentario (`-- ...`)
- La sentencia SQL correspondiente
- Separadores (`\echo`) para visualizar los resultados claramente al ejecutar el script en `psql`

---

## Estructura del proyecto

lemonmusic-sql-lab/
├─ README.md
├─ docker-compose.yml
├─ db/
│ ├─ scripts/lemonmusic.sql # Script SQL para restaurar la base
│ └─ backup/lemonmusic.tar # Backup alternativo (si se usa pg_restore)
├─ 01-obligatorio/
│ └─ consultas.script.sql
├─ 02-extra/
│ └─ consultas-extra.script.sql
└─ scripts/
├─ restore-from-sql.sh # Restaura la base desde un .sql
├─ run-consultas.sh # Ejecuta las consultas y guarda resultados
└─ (opcional) restore-from-backup.sh

---

## Configuración con Docker

El proyecto incluye un entorno con PostgreSQL y pgAdmin.

```yaml
services:
  db:
    image: postgres:16
    container_name: lemonmusic-db
    environment:
      POSTGRES_USER: ${PGUSER}
      POSTGRES_PASSWORD: ${PGPASSWORD}
      POSTGRES_DB: lemonmusic
    ports: ["5432:5432"]
    volumes:
      - ./pgdata:/var/lib/postgresql/data

  pgadmin:
    image: dpage/pgadmin4
    container_name: lemonmusic-pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD}
    ports: ["8080:80"]
```

Crea el archivo .env a partir de este ejemplo y ajusta los valores si lo deseas:

```bash
PGUSER=lemon
PGPASSWORD=lemon123
PGADMIN_EMAIL=admin@lemon.dev
PGADMIN_PASSWORD=admin123
```

Levanta los servicios:

```bash
docker compose up -d
```

pgAdmin estará disponible en http://localhost:8080

Restaurar la base de datos

El script scripts/restore-from-sql.sh
automatiza la restauración del archivo db/scripts/lemonmusic.sql.

### Ejemplo de uso:

#### Dar permisos de ejecución una sola vez

```bash
chmod +x scripts/restore-from-sql.sh
```

#### Restaurar usando el archivo por defecto

```bash
scripts/restore-from-sql.sh
```

#### Forzar ejecución local (sin Docker)

```bash
scripts/restore-from-sql.sh --local
```

### El script:

Detecta automáticamente si el contenedor lemonmusic-db está corriendo.

Crea la base de datos si no existe.

Inyecta el archivo .sql directamente al servidor Postgres.

Detiene la ejecución si ocurre un error (ON_ERROR_STOP=1).

Ejecutar las consultas

El script scripts/run-consultas.sh
ejecuta todas las consultas y guarda los resultados en ./results/.

```bash
chmod +x scripts/run-consultas.sh

# Ejecutar ambos bloques (por defecto)
scripts/run-consultas.sh

# Solo obligatorio
scripts/run-consultas.sh obligatorio

# Solo extra
scripts/run-consultas.sh extra

# Forzar ejecución local
scripts/run-consultas.sh --local

```

Los resultados se guardan en:

results/
├─ 01-obligatorio.txt
└─ 02-extra.txt

## Notas

Puedes ejecutar los .sql directamente desde pgAdmin o desde la terminal:

```bash
psql -U lemon -d lemonmusic -f 01-obligatorio/consultas.script.sql
```

Cada consulta está documentada con su enunciado original.

Los scripts son seguros: no modifican la base, solo ejecutan SELECT.

Puedes adaptar las rutas o credenciales modificando las variables de entorno.

## Autor

Cesar Poumian
LemonCode Bootcamp Backend – PostgreSQL Lab
https://github.com/cepoumian
