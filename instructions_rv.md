<br>  
 
*V. beta 0.5*

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


Il resto deve essere inalterato (no righe aggiuntiva, no totali, eccetera).

#### __Credit__
Il codice originale e' di Stephan Michard, i sorgenti si trovano su [Github](https://github.com/smichard/graphR), le [modifiche](https://github.com/abeggi/graphR_Var_Group) sono di Andrea Beggi <andrea.beggi@vargroup.com>.  

#### __Note__
[RVTools](http://www.robware.net/rvtools/) è un'utility VMware che si collega a un vCenter e raccoglie informazioni con un livello di dettaglio molto elevato sull’ambiente VMware, ad esempio su macchine virtuali, host ESX e configurazione di rete. Il risultato finale può essere salvato in un file Microsoft Excel. Le esportazioni di RVTools rappresentano un ottimo modo per raccogliere dati sugli ambienti VMware. Tuttavia, l’analisi delle esportazioni RVTools, soprattutto in ambienti complessi, può richiedere molto tempo ed essere soggetta a errori e difficoltà operative.  

Lo scopo di **graphR** è automatizzare e semplificare l'analisi delle esportazioni RVTools e fornire una rappresentazione visiva delle informazioni contenute in un file Excel o in un file CSV.

