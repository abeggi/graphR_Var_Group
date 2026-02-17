# graphR_Var_Group
# GraphR-VG

Applicazione Shiny per la visualizzazione e l'analisi dei dati di GraphR, pacchettizzata in Docker per una distribuzione semplificata.

## 🚀 Panoramica
Questo progetto migra un'installazione locale di R/Shiny verso un'architettura a microservizi. L'immagine Docker contiene tutte le dipendenze necessarie (R 4.3.0, Shiny, pacchetti di analisi dati e visualizzazione) eliminando i conflitti di sistema.

## 🛠️ Stack Tecnologico
* **Linguaggio:** R (v4.3.0)
* **Framework:** Shiny & ShinyDashboard
* **Infrastruttura:** Docker / Proxmox LXC
* **Networking:** Tailscale + Nginx Proxy Manager (NPM)

## 📦 Installazione Rapida

Per avviare l'applicazione senza dover configurare l'ambiente R locale:

```bash
docker run -d \
  --name graphr_app \
  -p 8080:3838 \
  --restart unless-stopped \
  abeggi/graphr-vg:latest
