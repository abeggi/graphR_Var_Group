options(shiny.maxRequestSize=50*1024^2) 

server_rv <- function(input, output) {
  
  temp_dir <- file.path("www", "tmp")
  if (!dir.exists(temp_dir)) {
    dir.create(temp_dir, recursive = TRUE)
  }

  observe({
    shinyjs::disable(id = "Generate_rv")
    shinyjs::toggleState(id = "Generate_rv", condition = !is.null(input$file_rv))
  })
  
  observeEvent(input$Generate_rv, {
    shinyjs::hide("pdfview_rv")
    shinyjs::show("progress_bar_rv")
    
    output$progress_bar_rv <- renderPlot({
      withProgress(message = 'Generating Report', value = 0, {
        
        setProgress(0.1, message = "Importing Data")
        
        file1 <- input$file_rv
        ext <- tools::file_ext(file1$name)
        new_path <- paste(file1$datapath, ext, sep = ".")
        file.rename(file1$datapath, new_path)
        
        if(ext == "csv"){
          data <- read.csv(new_path, header = TRUE, sep = ",", dec = ".", fill = FALSE, comment.char = "")
          if("OS.according.to.the.configuration.file" %in% colnames(data)){
            required_columns <- c("VM", "Powerstate", "CPUs", "Memory", "Provisioned.MiB", "In.Use.MiB", "Datacenter", "OS.according.to.the.configuration.file", "Host", "Network..1")
          } else{
            required_columns <- c("VM", "Powerstate", "CPUs", "Memory", "Provisioned.MiB", "In.Use.MiB", "Datacenter", "OS", "Host", "Network..1")
          }
          data_sub <- data[, required_columns]
          colnames(data_sub) <- c("VM", "Powerstate", "CPU", "Memory", "Provisioned_MiB", "In_Use_MiB", "Datacenter", "OS", "Host", "Network_1")
          data_sub <- na.omit(data_sub)
          overview_host <- NULL
        } else {
          data <- data.frame(read_excel(new_path, sheet=1, col_names=TRUE))
          if("OS.according.to.the.configuration.file" %in% colnames(data)){
            required_columns <- c("VM", "Powerstate", "CPUs", "Memory", "Provisioned.MiB", "In.Use.MiB", "Datacenter", "OS.according.to.the.configuration.file", "Host", "Network..1")
          } else{
            required_columns <- c("VM", "Powerstate", "CPUs", "Memory", "Provisioned.MiB", "In.Use.MiB", "Datacenter", "OS", "Host", "Network..1")
          }
          data_sub <- data[, required_columns]
          colnames(data_sub) <- c("VM", "Powerstate", "CPU", "Memory", "Provisioned_MiB", "In_Use_MiB", "Datacenter", "OS", "Host", "Network_1")
          data_sub <- na.omit(data_sub)
          
          overview_host <- tryCatch({
            data.frame(read_excel(new_path, sheet="vHost", col_names=TRUE))
          }, error = function(err) { NULL })  
        }
        
        setProgress(0.3, message = "Performing Calculations")    
        
        data_comp <- get_stats(data_sub)
        top_VM_comp <- get_top_VM(data_sub)
        dc_list <- unique(data_sub$Datacenter)
        
        if(length(dc_list) > 1){
          data_overview <- get_stats_overview(data_sub)
          data_list <- list()
          top_VM_list <- list()
          for(i in 1:length(dc_list)){
            df_dc <- data_sub[data_sub$Datacenter == dc_list[i], ]
            data_list[[i]] <- get_stats(df_dc)
            top_VM_list[[i]] <- get_top_VM(df_dc)
          }
        }
        
        setProgress(0.6, message = "Generating Diagrams")
        
        plot_comp <- generate_plots(data_comp, data_sub)
        if(length(dc_list) > 1){
          plot_dc <- list()
          for(i in 1:length(dc_list)){
            plot_dc[[i]] <- generate_plots(data_list[[i]], data_sub, dc_list[i])
          }
        }
        
        if(!is.null(overview_host)){
          host_sub <- overview_host[, c("Host", "Datacenter", "CPU.Model", "X..VMs", "X..CPU", "Cores.per.CPU", "X..Cores", "X..Memory", "X..vCPUs", "ESX.Version")]
          colnames(host_sub) <- c("Host", "Datacenter", "CPU_Model", "n_VMs", "n_CPU", "Cores_per_CPU", "n_Cores", "Memory", "n_vCPU", "ESX_Version")
          host_sub <- na.omit(host_sub) %>% mutate(Memory = round(Memory / 1024, 1)) %>% arrange(Datacenter)
          host_summary <- host_sub %>% summarise(Host_count = n_distinct(Host), Memory_count = sum(Memory), CPU_count = sum(n_CPU), Core_count = sum(n_Cores), vCPU_count = sum(n_vCPU), vCPU_to_Core = round(vCPU_count/Core_count, 1))  
          host_summary <- as.data.frame(t(host_summary)) %>% rownames_to_column()
          colnames(host_summary) <- c("Description", "Value")
          host_sub <- host_sub[, c("Host", "Datacenter", "CPU_Model", "Memory", "n_CPU", "n_vCPU")]
        }
        
        setProgress(0.8, message = "Generating Slides")
        
        file_name <- get_rep_name(temp_dir)
        pdf(file = file_name[2], width = 16, height = 9)
        
        slideFirst(titleName = ifelse(input$title_rv =="Report Title","RV_Tools Summary",as.character(input$title_rv)),
                   authorName = ifelse(input$author_rv =="Author of the Report","Name",as.character(input$author_rv)),
                   #documDate = Sys.Date())
                   documDate = format(Sys.Date(), "%d/%m/%Y"))
        
        if(length(dc_list) > 1){
          generate_overview_slide(data_overview)
        }
        
        generate_slides(data_comp, plot_comp, top_VM_comp, data_sub)
        
        if(length(dc_list) > 1){
          for(i in 1:length(dc_list)){
            generate_slides(data_list[[i]], plot_dc[[i]], top_VM_list[[i]], data_sub[data_sub$Datacenter == dc_list[i], ], dc_list[i])
          }
        }
        
        if(!is.null(overview_host)){
          j <- ceiling(nrow(host_sub)/6)
          for(i in 1:j){
            a <- (i-1)*6+1
            b <- min(i*6, nrow(host_sub))
            slideTable(host_sub[a:b,], "Host overview")
          }
          slideTable(host_summary, "Details")
        }
        
        slideLast()
        dev.off()

        old_files <- list.files(temp_dir, full.names = TRUE)
        unlink(old_files[file.info(old_files)$mtime < (Sys.time() - 3600)])
        system(paste("chmod 644", shQuote(file_name[2])))

      }) #withProgress
      
      output$pdfview_rv <- renderUI({
        tags$iframe(style = "height:610px; width:100%; scrolling=yes",
                    src = paste0("tmp/", file_name[1]))
      })
      shinyjs::hide("progress_bar_rv")
      shinyjs::show("pdfview_rv")
    }) 
  })
}
