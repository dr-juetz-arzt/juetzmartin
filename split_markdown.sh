#!/bin/bash

# Voraussetzung: GNU coreutils via Homebrew → gcsplit
# Eingabedatei: dissertation.md
# Zielordner: ./kapitel/
# Aufteilung nach "# Kapitel ..." (oder vergleichbarem Muster)
# Umbenennung anhand der ersten Überschrift in der jeweiligen Datei

INPUT_FILE="dissertation.md"
OUTPUT_DIR="./kapitel"

# Prüfen, ob Eingabedatei existiert
if [ ! -f "$INPUT_FILE" ]; then
  echo "Fehler: Datei $INPUT_FILE nicht gefunden."
  exit 1
fi

# Erstelle Zielverzeichnis
mkdir -p "$OUTPUT_DIR"

# Temporärverzeichnis für Zwischendateien
TMP_DIR=$(mktemp -d)

# Schritt 1: Aufteilen mit gcsplit (GNU!)
gcsplit -s -f "$TMP_DIR/kapitel" -b "%02d.md" "$INPUT_FILE" '/^# Kapitel/' '{*}'

# Schritt 2: Umbenennen und verschieben
counter=0
for file in "$TMP_DIR"/kapitel*.md; do
  title=$(head -n 1 "$file" | sed 's/^# *//' | tr '[:space:]' '_' | tr -cd '[:alnum:]_-')
  title=${title:-Kapitel_$counter}
  dest="$OUTPUT_DIR/${counter}_${title}.md"
  iconv -f UTF-8 -t UTF-8 "$file" -o "$dest"
  echo "Gespeichert: $dest"
  ((counter++))
done

# Aufräumen
rm -r "$TMP_DIR"

echo "✅ Aufteilung abgeschlossen: $counter Dateien gespeichert in $OUTPUT_DIR"
