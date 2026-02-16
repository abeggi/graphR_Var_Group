#### __Istruzioni__
Il file Excel RVTools:
Il tab "vInfo" deve avere le colonne interessate **esattamente** con queste etichette:

- VM  
- Powerstate  
- CPUs  
- Memory  
- Network..1  
- Provisioned.MiB  
- In.Use.MiB  
- Datacenter  
- Host  
- OS.according.to.the.configuration.file  

E' **essenziale** che il tab abbia almeno queste colonne con questi nomi.

#### __Attenzione__
Il resto deve essere inalterato (no righe aggiuntiva, no totali, eccetera).

#### __Credit__
Il codice originale e' di Stephan Michard, i sorgenti si trovano su [Github](https://github.com/smichard/graphR), le modifiche sono di Andrea Beggi <andrea.beggi@vargroup.com> 

#### __Note__
[RVTools](http://www.robware.net/rvtools/) is a VMware utility that connects to a vCenter and gathers information with an impressive level of detail on the VMware environment (e. g. on virtual machines, on ESX hosts, on the network configuration). The data collection is fast and easy. The end result can be stored in a Microsoft Excel file. RVTools exports are a great way to collect data on VMware environments. However, analyzing RVTool exports especially of complex environments can be time-consuming, error-prone and cumbersome.  
The purpose of **graphR** is to automatize and simplify the analysis of RVTools exports and to give a visual presentation of the information contained within an Excel file or a comma seperated file.

