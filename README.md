# graphR_Var_Group
# GraphR-VG

Applicazione Shiny per la visualizzazione e l'analisi dei dati di GraphR, pacchettizzata in Docker per una distribuzione semplificata.

## 🚀 Panoramica
Questo progetto migra un'installazione locale di R/Shiny verso un'architettura a microservizi. L'immagine Docker contiene tutte le dipendenze necessarie (R 4.3.0, Shiny, pacchetti di analisi dati e visualizzazione) eliminando i conflitti di sistema.

## 🛠️ Stack Tecnologico
* **Linguaggio:** R (v4.3.0)
* **Framework:** Shiny & ShinyDashboard
* **Infrastruttura:** Docker


## 📦 Installazione Rapida con Docker

Per avviare l'applicazione senza dover configurare l'ambiente R locale:

```bash
docker run -d \
  --name graphr_app \
  -p 8080:3838 \
  --restart unless-stopped \
  abeggi/graphr-vg:latest
```

Oppure usare Docker Compose
'''services:
  graphr-app:
    image: abeggi/graphr-vg:latest
    container_name: graphr_app
    restart: unless-stopped
    ports:
      - "8080:3838"
    environment:
      - TZ=Europe/Rome
    # Se in futuro vorrai mappare i dati esternamente per non ricostruire l'immagine
    # ad ogni cambio di CSV o file Excel, decommenta le righe sotto:
    # volumes:
    #   - ./data:/srv/shiny-server/graphr/data
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

networks:
  default:
    name: graphr_network
'''

