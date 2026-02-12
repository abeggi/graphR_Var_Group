# both applications
readData_old <- function (file=choose.files()){
  data <- read.xlsx(file, sheetIndex=1, startRow=1, as.data.frame=TRUE, header=TRUE, keepFormulas=FALSE)
  return(data)
}

readData <- function (file=choose.files()){
  data <- data.frame(read_excel(file, sheet=1, col_names=TRUE))
  return(data)
}

designPlot <- function(plotVar){
  plotVar <- plotVar + theme(title = element_text(face="bold", size=24),
                               axis.title.x = element_text(face="bold", size=22, margin=margin(20,0,0,0)),
                               axis.text.x  = element_text(vjust=0.5, size=18),
                               axis.title.y = element_text(face="bold", size=22, margin=margin(20,15,0,0)),
                               axis.text.y  = element_text(vjust=0.5, size=18))
  return(plotVar)
}

get_rep_name <- function(dir) {
  report_name <- paste("report", ceiling(as.numeric(Sys.time())), floor(runif(1, min = 1000, max = 9999)), sep = "_")
  report_name <- paste0(report_name, ".pdf")
  file_path <- file.path(dir, report_name)
  return(c(report_name, file_path))
}

# Funzione Prevendita con nuove etichette colonne
get_stats_prevendita <- function(raw_df){
  t_prev <- raw_df %>%
    mutate(Stato = ifelse(Powerstate == "poweredOn", "Accese", "Spente")) %>%
    group_by(Stato) %>%
    summarise(
      `Q.tà` = n(),
      CPU = sum(CPU, na.rm = TRUE),
      `RAM [GB]` = round(sum(Memory, na.rm = TRUE) / 1024, 0),
      `Storage in use [GB]` = round(sum(In_Use_MiB, na.rm = TRUE) / 1024, 0),
      `Storage provisioned [GB]` = round(sum(Provisioned_MiB, na.rm = TRUE) / 1024, 0)
    )
  
  t_totale <- t_prev %>%
    summarise(
      Stato = "Totale", 
      `Q.tà` = sum(`Q.tà`), 
      CPU = sum(CPU), 
      `RAM [GB]` = sum(`RAM [GB]`), 
      `Storage in use [GB]` = sum(`Storage in use [GB]`),
      `Storage provisioned [GB]` = sum(`Storage provisioned [GB]`)
    )
  
  final_tab <- rbind(t_prev, t_totale)
  colnames(final_tab)[1] <- "VM"
  return(as.data.frame(final_tab))
}

get_stats <- function(df){
  profile <- df %>%
    mutate(Description = ifelse(CPU >= 6, "Large",
                                ifelse(CPU < 6 & CPU > 2, "Medium", 
                                       ifelse(CPU <= 2, "Small", NA)))) %>%
    mutate(VM_on = ifelse(Powerstate =="poweredOn", 1, 0)) %>%
    group_by(Description) %>%
    summarise(VM_Count = n(), n_VMs_on = sum(VM_on), n_VMs_off = n()-sum(VM_on), Concurrent_Ratio = round(n_VMs_on*100/(VM_Count), 1),
               CPU_Count = sum(CPU), Memory_Count = round(sum(Memory)/1024, 1), Storage_Occupied = round(sum(In_Use_MiB)/1024, 1),
               Storage_Provisioned = round(sum(Provisioned_MiB)/1024, 1), free_space = round(100-Storage_Occupied/Storage_Provisioned*100 ,1),
               CPU_Count_per_VM = round(CPU_Count/VM_Count, 1), Memory_Count_per_VM = round(Memory_Count/VM_Count, 1),
               Storage_Occupied_per_VM = round(Storage_Occupied/VM_Count, 1), Storage_Provisioned_per_VM = round(Storage_Provisioned/VM_Count, 1))
  
  total <- profile %>%
    mutate(Description = "Total") %>%
    group_by(Description) %>%
    summarise(VM_Count = sum(VM_Count), n_VMs_on = sum(n_VMs_on), n_VMs_off = sum(n_VMs_off), Concurrent_Ratio = round(n_VMs_on*100/VM_Count, 1),
               CPU_Count = sum(CPU_Count), Memory_Count = round(sum(Memory_Count), 1), Storage_Occupied = round(sum(Storage_Occupied), 1),
               Storage_Provisioned = round(sum(Storage_Provisioned), 1), free_space = round(100-Storage_Occupied/Storage_Provisioned*100 ,1),
               CPU_Count_per_VM = round(sum(CPU_Count)/VM_Count, 1), Memory_Count_per_VM = round(Memory_Count/VM_Count, 1),
               Storage_Occupied_per_VM = round(Storage_Occupied/VM_Count, 1), Storage_Provisioned_per_VM = round(Storage_Provisioned/VM_Count, 1))
  
  total <- rbind(profile, total)
  return(total)
}

get_stats_overview <- function(df){
  overview <- df %>%
    group_by(Datacenter) %>%
    summarise(Host_Count = n_distinct(Host), VM_Count = n(), CPU_Count = sum(CPU), Memory_Count = round(sum(Memory)/1024, 1), Storage_Occupied = round(sum(In_Use_MiB)/1024, 1),
               Storage_Provisioned = round(sum(Provisioned_MiB)/1024, 1), free_space = round(100-Storage_Occupied/Storage_Provisioned*100 ,1)) %>%
    arrange(desc(CPU_Count))
  return(overview)
}

get_top_VM <- function(df){
  top_VM <- df %>%
    arrange(desc(CPU), desc(Memory)) %>%
    slice(1:5) %>%
    mutate(Memory = round(Memory / 1024, 1), In_Use_MiB = round(In_Use_MiB/1024, 1), Provisioned_MiB = round(Provisioned_MiB/1024, 1))
  return(top_VM)
}

generate_plots <- function(df, raw_df, praefix = "comp"){
  plot_list <- list()
  plot_list[[length(plot_list)+1]] <- designPlot(ggplot(df, aes(x=Description, y=VM_Count))  + geom_bar(stat="identity", width=.7, fill="steelblue") + xlab("VM Profile") + ylab("Number of VM's") + geom_text(aes(label=VM_Count), vjust=1.6, color="white", size=5.5, fontface="bold") + guides(fill="none"))
  
  tmp <- df[, c("Description", "VM_Count", "n_VMs_on", "n_VMs_off")]
  tmp <- melt(tmp ,  id='Description', value.name='Count', variable.name = 'Type')
  plot_list[[length(plot_list)+1]] <- designPlot(ggplot(tmp, aes(x=Description, y=Count, fill=factor(Type, levels = c("n_VMs_off", "n_VMs_on", "VM_Count")))) + geom_bar(stat="identity", width=.7, position = "dodge") + xlab("VM Profile") + ylab("Number of VM's") + scale_fill_manual(values=c("#fc8d62", "#66c2a5", "#377eb8"), name ="", labels=c("VM's powered off", "VM's powered on", "Total Number of VM's")))
  
  if(praefix != "comp"){
    df_plot <- raw_df[raw_df$Datacenter == praefix, ]
  }else{
    df_plot <- raw_df
  }
  plot_list[[length(plot_list)+1]] <- designPlot(ggplot(df_plot, aes(x=CPU)) + geom_density(alpha =.5, fill="steelblue", aes(y= after_stat(scaled))) + xlab("vCPU Count") + ylab("Density [ - ]") + xlim(c(-0.5,20)))
  plot_list[[length(plot_list)+1]] <- designPlot(ggplot(df_plot, aes(x=Memory/1024)) + geom_density(alpha =.5, fill="steelblue", aes(y= after_stat(scaled))) + xlab("Memory [GB]") + ylab("Density [ - ]") + xlim(c(-0.5,60)))
  
  tmp_storage <- df_plot[,c("Provisioned_MiB", "In_Use_MiB")]
  tmp_storage <- melt(tmp_storage, measure.vars = c('Provisioned_MiB', 'In_Use_MiB'), variable.name = 'Type', value.name = 'Count')
  plot_list[[length(plot_list)+1]] <- designPlot(ggplot(tmp_storage, aes(x=Count/1024, fill=Type)) + geom_density(alpha =.5, aes(y= after_stat(scaled))) + xlab("Storage [GiB]") + ylab("Density [ - ]") + xlim(c(-0.5,2000))  + scale_fill_discrete(name ="", labels=c("Provisioned Storage [GiB]", "Occupied Storage [GiB]")))
  
  return(plot_list)
}

generate_slides <- function(df, plot_list, top_VM, raw_df = NULL, praefix = "comp"){
  
  if(!is.null(raw_df)){
    data_prev <- get_stats_prevendita(raw_df)
    slideTable(data_prev, "Riepilogo Risorse")
  }

  if(praefix == "comp"){
    slidePlot(plot_list[[3]], "Distribution of vCPU for all VM's")
    slidePlot(plot_list[[4]], "Distribution of Memory for all VM's")
    slidePlot(plot_list[[5]], "Distribution of occup. and provis. storage for all VM's")
    
    tmp_top <- as.data.frame(top_VM[, c("VM", "CPU", "Memory", "In_Use_MiB", "Provisioned_MiB", "Datacenter", "Host")])
    colnames(tmp_top) <- c("VM Name", "# vCPU", "Memory [GB]", "Occupied Storage [GiB]", "Provisioned Storage [GiB]", "Datacenter", "Host")
    slideTable(tmp_top, "Top 5 VM's")
    
  }else{
    slideChapter(paste("Summary for Datacenter: ", praefix, ""))
    
    slidePlot(plot_list[[3]], paste("Distribution of vCPU for all VM's - ", praefix, ""))
    slidePlot(plot_list[[4]], paste("Distribution of Memory for all VM's - ", praefix, ""))
    slidePlot(plot_list[[5]], paste("Distribution of occup. and provis. storage for all VM's - ", praefix, ""))
    
    tmp_top <- as.data.frame(top_VM[, c("VM", "CPU", "Memory", "In_Use_MiB", "Provisioned_MiB", "Datacenter", "Host")])
    colnames(tmp_top) <- c("VM Name", "# vCPU", "Memory [GB]", "Occupied Storage [GiB]", "Provisioned Storage [GiB]", "Datacenter", "Host")
    slideTable(tmp_top, paste("Top 5 VM's for: ", praefix, ""))
  }  
}

generate_overview_slide <- function(df){
  tmp <- as.data.frame(df[, c("Datacenter", "Host_Count","VM_Count", "CPU_Count", "Memory_Count", "Storage_Occupied", "Storage_Provisioned", "free_space")])
  colnames(tmp) <- c("Datacenter", "# Hosts", "# VM's", "# vCPU's", "Memory [GB]", "Occupied Storage [GiB]", "Provisioned Storage [GiB]", "Free Space [%]")
  slideTable(tmp, paste("Overview for ", nrow(df), " Datacenter", sep=""))
}

get_vertices <- function(var_list){
  tmp_list <- list()
  for(i in 1:length(var_list)){
    tmp_list[[length(tmp_list)+1]] <- paste(var_list[i], "--", var_list[i], sep="")
    names(tmp_list)[i] <- as.character(i)
  }
  return(tmp_list)
}
