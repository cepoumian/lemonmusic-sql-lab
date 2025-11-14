#!/usr/bin/env bash
set -euo pipefail

# =========================
# c
# =========================
DB="${DB:-lemonmusic}"
PGUSER="${PGUSER:-lemon}"
PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
CONTAINER="${CONTAINER:-lemonmusic-db}"

OBL_FILE="${OBL_FILE:-01-obligatorio/consultas.script.sql}"
EXT_FILE="${EXT_FILE:-02-extra/consultas-extra.script.sql}"

RESULTS_DIR="${RESULTS_DIR:-results}"
OBL_OUT="$RESULTS_DIR/01-obligatorio.txt"
EXT_OUT="$RESULTS_DIR/02-extra.txt"

# =========================
# Ayuda
# =========================
usage() {
  cat <<EOF
Uso: $(basename "$0") [obligatorio|extra|ambos] [--local]

- obligatorio  Ejecuta solo 01-obligatorio/consultas.script.sql
- extra        Ejecuta solo 02-extra/consultas-extra.script.sql
- ambos        (por defecto) ejecuta ambos bloques
--local        Fuerza uso de psql local (ignora Docker)

Variables (opcionales):
  DB, PGUSER, PGHOST, PGPORT, CONTAINER, OBL_FILE, EXT_FILE, RESULTS_DIR
EOF
}

# =========================
# Parseo simple de args
# =========================
TARGET="ambos"
FORCE_LOCAL="no"

for arg in "${@:-}"; do
  case "$arg" in
    obligatorio|extra|ambos) TARGET="$arg" ;;
    --local) FORCE_LOCAL="yes" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Argumento desconocido: $arg"; usage; exit 1 ;;
  esac
done

# =========================
# Modo de ejecución (docker vs local)
# =========================
MODE="local"
if [[ "$FORCE_LOCAL" != "yes" ]]; then
  if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    MODE="docker"
  fi
fi

echo "==> Modo: $MODE"
mkdir -p "$RESULTS_DIR"

run_file() {
  local infile="$1"
  local outfile="$2"

  [[ -f "$infile" ]] || { echo "No existe el archivo: $infile"; exit 1; }

  echo "==> Ejecutando: $infile"
  if [[ "$MODE" == "docker" ]]; then
    # Nota: el contenedor no monta el repo, por eso usamos pipe:
    cat "$infile" \
      | docker exec -i "$CONTAINER" psql \
          -U "$PGUSER" -d "$DB" -v ON_ERROR_STOP=1 -X \
      > "$outfile"
  else
    psql -U "$PGUSER" -d "$DB" -h "$PGHOST" -p "$PGPORT" \
         -v ON_ERROR_STOP=1 -X \
         < "$infile" \
      > "$outfile"
  fi
  echo "   -> OK: $outfile"
}

# =========================
# Selección de bloques
# =========================
case "$TARGET" in
  obligatorio)
    run_file "$OBL_FILE" "$OBL_OUT"
    ;;
  extra)
    run_file "$EXT_FILE" "$EXT_OUT"
    ;;
  ambos)
    [[ -f "$OBL_FILE" ]] && run_file "$OBL_FILE" "$OBL_OUT" || echo "Aviso: no existe $OBL_FILE"
    [[ -f "$EXT_FILE" ]] && run_file "$EXT_FILE" "$EXT_OUT" || echo "Aviso: no existe $EXT_FILE"
    ;;
esac

echo "==> Listo. Revisa la carpeta $RESULTS_DIR/"
