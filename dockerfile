# 1. Base ufficiale R-Shiny su Debian Bookworm
FROM rocker/shiny:4.3.0

# 2. Installazione dipendenze di sistema per pacchetti R (curl, ssl, xml2)
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. Installazione pacchetti R necessari
# Nota: usiamo un repository specifico per garantire la stabilità
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'shinyjs', 'dplyr', 'ggplot2', 'openxlsx', 'readxl', 'reshape2', 'tibble', 'forcats'), repos='https://cran.rstudio.com/')"

RUN R -e "install.packages(c('GGally', 'grid', 'igraph', 'markdown', 'png', 'readxl', 'shinyjs', 'tools'), repos='https://cran.rstudio.com/')"
# 4. Impostazione della cartella di lavoro nel container
WORKDIR /srv/shiny-server/graphr

# 5. Copia di tutto il contenuto di /opt/graphr nel container
# Docker copierà app.R, instruction.MD e le cartelle backgrounds e www
COPY . .

# 6. Creazione cartella temporanea per i report e gestione permessi
# Shiny gira con l'utente 'shiny', quindi deve possedere i file per scriverci
RUN mkdir -p www/tmp && \
    chown -R shiny:shiny /srv/shiny-server/graphr && \
    chmod -R 755 /srv/shiny-server/graphr

# 7. Esposizione della porta 3838 (standard di Shiny Server)
EXPOSE 3838

# 8. Esecuzione: facciamo girare l'app direttamente senza passare per shiny-server.conf
# Questo rende i log più facili da leggere nel terminale Docker
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/graphr', host = '0.0.0.0', port = 3838)"]
