#!/usr/bin/env bash
set -euo pipefail

# =========================
# Config (con defaults)
# =========================
DB="${DB:-lemonmusic}"
PGUSER="${PGUSER:-lemon}"
PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
CONTAINER="${CONTAINER:-lemonmusic-db}"
SQL_FILE_DEFAULT="db/scripts/lemonmusic.sql"

# =========================
# Ayuda
# =========================
usage() {
  cat <<EOF
Uso: $(basename "$0") [ruta_sql] [--local]

Restaura una base de datos desde un script .sql
- Si no pasas ruta_sql, usa: $SQL_FILE_DEFAULT
- Detecta Docker automáticamente (contenedor: $CONTAINER) a menos que uses --local

Variables opcionales:
  DB, PGUSER, PGHOST, PGPORT, CONTAINER
EOF
}

# =========================
# Parseo de args
# =========================
SQL_FILE="${1:-$SQL_FILE_DEFAULT}"
FORCE_LOCAL="no"

if [[ "${2:-}" == "--local" ]]; then
  FORCE_LOCAL="yes"
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage; exit 0
fi

[[ -f "$SQL_FILE" ]] || { echo "No existe el archivo: $SQL_FILE"; exit 1; }

# =========================
# Detección Docker vs local
# =========================
MODE="local"
if [[ "$FORCE_LOCAL" != "yes" ]]; then
  if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    MODE="docker"
  fi
fi
echo "==> Modo: $MODE"

# =========================
# Crear DB si no existe
# =========================
create_db_if_missing_local() {
  if ! psql -U "$PGUSER" -h "$PGHOST" -p "$PGPORT" -lqt | cut -d \| -f 1 | grep -qw "$DB"; then
    echo "==> Creando DB '$DB' (local)"
    createdb -U "$PGUSER" -h "$PGHOST" -p "$PGPORT" "$DB"
  fi
}

create_db_if_missing_docker() {
  if ! docker exec -i "$CONTAINER" psql -U "$PGUSER" -tAc "SELECT 1 FROM pg_database WHERE datname='$DB'" | grep -q 1; then
    echo "==> Creando DB '$DB' (docker)"
    docker exec -i "$CONTAINER" createdb -U "$PGUSER" "$DB"
  fi
}

# =========================
# Restauración
# =========================
echo "==> Restaurando: $SQL_FILE -> DB: $DB"
if [[ "$MODE" == "docker" ]]; then
  create_db_if_missing_docker
  # Inyectamos el SQL por STDIN dentro del contenedor
  cat "$SQL_FILE" \
    | docker exec -i "$CONTAINER" psql -U "$PGUSER" -d "$DB" -v ON_ERROR_STOP=1 -X
else
  create_db_if_missing_local
  psql -U "$PGUSER" -h "$PGHOST" -p "$PGPORT" -d "$DB" -v ON_ERROR_STOP=1 -X \
    < "$SQL_FILE"
fi

echo "==> OK: restauración completada."
