#!/bin/bash

# Entra nella cartella del progetto
cd /opt/graphr

# Aggiunge tutte le modifiche (rispettando il .gitignore)
git add .

# Crea il messaggio con data e ora attuale
TIMESTAMP=$(date +"%d/%m/%Y %H:%M:%S")
COMMIT_MSG="Backup automatico del $TIMESTAMP"

# Esegue il commit
git commit -m "$COMMIT_MSG"

# Pusha sul repository remoto
git push origin main

echo "---------------------------------------"
echo "Sincronizzazione completata: $COMMIT_MSG"
echo "---------------------------------------"
