# graphR-VG: analizzatore RVTools VMware
(basato su: https://github.com/smichard/graphR)

Applicazione Shiny per la visualizzazione e l'analisi dei dati di GraphR.

## 🛠️ Stack Tecnologico
* **Linguaggio:** R (v4.3.0)
* **Framework:** Shiny & ShinyDashboard
* **Infrastruttura:** Docker


## 📦 Installazione con docker

Il container non ha volumi o bind persistenti perché non c'è nulla da salvare o configurazioni da modificare: il report può essere scaricato dopo la creazione.

Per avviare l'applicazione senza dover configurare l'ambiente R locale:

```bash
docker run -d \
  --name graphr_app \
  -p 8080:3838 \
  --restart unless-stopped \
  abeggi/graphr-vg:latest
```
e lanciare con http://localhost:8080 oppure http://ip-del-server:8080


Oppure usare Docker Compose

```bash
services:
  graphr-app:
    image: abeggi/graphr-vg:latest
    container_name: graphr_app
    restart: unless-stopped
    ports:
      - "8080:3838"
    environment:
      - TZ=Europe/Rome
    # Opzionale: mappare i dati esternamente
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
```
e lanciare con http://localhost:8080 oppure http://ip-del-server:808

## Autore
Andrea Beggi - Var Group  
andrea.beggi@vargroup.com
