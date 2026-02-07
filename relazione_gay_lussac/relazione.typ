// --- Impostazioni Documento ---
#set page(
  paper: "a4",
  margin: (x: 3cm, y: 3cm),
  numbering: "1",
)
#set text(
  font: "New Computer Modern",
  size: 11pt,
  lang: "it"
)
#set par(justify: true)

// --- Metadati ---
#let title = [Verifica Sperimentale della Legge di Gay-Lussac con sensore Arduino BME280]
#let author = "Bossi Riccardo \n matricola: 881923"

//LOGO BICOCCA
#let logo_path = "immagini/logo_unimib.jpg"
#let logo = image(logo_path, width: 4cm)
#align(center, logo)  

#let date = datetime.today().display("[day]/[month]/[year]")

// --- Intestazione ---
#align(center, text(17pt, weight: "bold", title))
#align(center, text(12pt, style: "italic", author))
#align(center, text(10pt, date))
#v(1em)
#line(length: 100%, stroke: 0.5pt + gray)
#v(1em)

// --- Abstract ---
#v(1em)
#align(center)[
  #heading(outlined: false, numbering: none)[Abstract]
]

#pad(x: 2em)[ // Rientro per evidenziare l'abstract
  Il presente elaborato si pone come obiettivo la verifica sperimentale della seconda legge di Gay-Lussac e la determinazione della costante universale dei gas ideali ($R$), valutandone la compatibilità con il valore nominale. 
  
  L'intero apparato sperimentale è stato realizzato mediante strumentazione low-cost, nello specifico, il sensore BME280 e il microcontrollore Arduino UNO. Il resto della strumentazione utilizzata è comunemente reperibile in ambiente domestico.
  
  L'esperienza analizza l'evoluzione isocora di una massa d'aria confinata ermeticamente, sottoposta a un ciclo termico quasi-statico nell'intervallo compreso tra -15 °C e 80 °C. I parametri di pressione, temperatura e umidità relativa sono stati acquisiti in tempo reale e successivamente elaborati in ambiente Python per l'estrapolazione delle costanti fisiche di interesse.
  
  In appendice al report, redatto con finalità didattiche per i docenti di scuola secondaria di secondo grado, è riportata una scheda di laboratorio dedicata, concepita per guidare gli studenti durante l'esecuzione dell'esperimento.
]

#v(2em)
#line(length: 100%, stroke: 0.5pt + gray)
#v(2em)

#pagebreak()

// --- Table of Contents ---
#show outline.entry.where(
  level: 1
): it => {
  v(12pt, weak: true)
  strong(it)
}

#outline(
  title: [Indice dei Contenuti],
  indent: auto,
)

#pagebreak()



= 1. Setup Sperimentale e Strumentazione
L'apparato sperimentale è stato progettato per isolare una massa d'aria costante e sottoporla a variazioni termiche controllate (in regime quasi-statico), monitorando in tempo reale le variabili di stato termodinamiche.

== 1.1 Strumentazione Elettronica
Il sistema di acquisizione dati è basato su un microcontrollore Arduino, che funge da interfaccia tra i trasduttori digitali e l'unità di elaborazione per il monitoraggio dei parametri fisici.

- *Sensore:* Modulo *BME280*. Si tratta di un sensore ambientale digitale integrato ad alta precisione, in grado di misurare simultaneamente Pressione, Temperatura e Umidità Relativa. Le specifiche tecniche relative alla sensibilità e ai range di esercizio, derivate dai datasheet del costruttore, sono riportate in @fig-sensibilita.

#let imm_path = "immagini/sensibilità.jpg"
#figure(
  image(imm_path, width: 8cm),
  caption: [Specifiche tecniche e sensibilità del sensore BME280.],
) <fig-sensibilita> 

- *Microcontrollore:* Scheda *Arduino UNO*, impiegata per l'interfacciamento con il sensore e la trasmissione dei dati via seriale verso il PC. Il campionamento è stato impostato a una frequenza di $1 "Hz"$ ($1 "campione/s"$), valore ottimale per seguire l'inerzia termica del sistema senza generare ridondanza informativa.

- La configurazione finale include inoltre la cablatura necessaria e l'uso di un computer per l'acquisizione e analisi dei dati.


== 1.2 Camera di Misura e Sigillatura
Come camera isocora è stato impiegato un contenitore in vetro borosilicato, dotato di un tappo metallico a vite per garantire la necessaria rigidità strutturale.

- *Posizionamento del Sensore:* Il tappo è stato forato in corrispondenza del centro geometrico per minimizzare l'influenza termica delle pareti del contenitore sul sensore. Attraverso tale foro sono stati fatti passare i conduttori di connessione.

- *Sigillatura del foro:* Il punto di passaggio dei cavi è stato sigillato ermeticamente mediante l'applicazione di colla a caldo su entrambi i lati del tappo, con l'obiettivo di garantire la tenuta pneumatica e prevenire variazioni della massa d'aria (perdite di carico).

#let imm_path = "immagini/tappo.jpeg"
#figure(
  image(imm_path, width: 5cm),
  caption: [Dettaglio della sigillatura del tappo della camera isocora.],
) <fig-tappo> 

- *Tenuta del filetto:* Per scongiurare fughe di gas attraverso la filettatura del tappo, è stato applicato del nastro in PTFE (Teflon) prima della chiusura definitiva. Esternamente, il giunto è stato ulteriormente messo in sicurezza con nastro isolante ad alta tenuta.

== 1.3 Bagni Termici
Per indurre le variazioni di temperatura necessarie alla verifica delle leggi dei gas, sono stati predisposti due bagni termici:

1. *Bagno Freddo:* Una miscela eutettica di ghiaccio tritato e cloruro di sodio (NaCl), sfruttata per raggiungere una temperatura minima di circa $-15 "°C"$ grazie all'abbassamento crioscopico. #footnote[Sebbene esistano sali in grado di raggiungere temperature inferiori (come $C a C l_2$ o $M g C l_2$), si è optato per il comune sale da cucina per ragioni di sicurezza operativa e facile reperibilità didattica.]

2. *Bagno Caldo:* Un bagno d'acqua riscaldato progressivamente, atto a portare il sistema in modo graduale verso la temperatura massima di esercizio dei componenti elettronici ($approx 80 "°C"$).

Il contenitore è stato immerso nei bagni garantendo un efficiente scambio termico attraverso le pareti in vetro. La raccolta dati è proseguita fino al raggiungimento dell'equilibrio termico ambientale, documentando sia la fase di riscaldamento che quella di raffreddamento.

= 2. Cenni Teorici e Modello Fisico

== 2.1 L'Aria come Gas Ideale
L'equazione di stato dei gas ideali rappresenta il modello teorico fondamentale per descrivere il comportamento termodinamico di un gas in condizioni di bassa densità e alta temperatura (rispetto al punto critico). Essa correla le variabili di stato pressione ($P$), volume ($V$) e temperatura assoluta ($T$) mediante la relazione:

$ P V = n R T $

Dove:
- $n$ indica la quantità di sostanza (numero di moli);
- $R$ rappresenta la costante universale dei gas ($approx 8.314 "J" / ("mol" K)$).

Nell'intervallo termico esplorato in questa esperienza e a pressioni prossime a quella atmosferica, le interazioni intermolecolari dell'aria risultano trascurabili e il volume proprio delle molecole è infinitesimo rispetto al volume del contenitore. Pertanto, le deviazioni dal comportamento ideale (descritte da modelli più complessi come l'equazione di Van der Waals) sono minime, permettendo di trattare l'aria come un gas perfetto con un'eccellente approssimazione.

== 2.2 Trasformazione Isocora (Legge di Gay-Lussac)
Mantenendo costanti il volume del sistema ($V = "cost"$) e la quantità di sostanza ($n = "cost"$), l'equazione di stato si riduce alla relazione di proporzionalità lineare nota come *Seconda Legge di Gay-Lussac*:

$ P = (n R / V) dot T $

Tale legge implica una dipendenza lineare diretta tra la pressione e la temperatura assoluta.

=== Procedura di Analisi Dati
Per verificare sperimentalmente la validità del modello e ricavare le costanti fisiche, si è proceduto secondo il seguente protocollo:

1. *Normalizzazione dimensionale:* Le temperature misurate in gradi Celsius ($t_C$) dal sensore BME280, vengono convertite in Kelvin ($T_K$) dal firmware di acquisizione:
   $ T_K = t_C + 273.15 $
   Simultaneamente, la pressione acquisita in kPa viene convertita in unità SI (Pa) mediante un fattore di scala $10^3$.

2. *Regressione Lineare:* Si esegue un fit lineare sui dati sperimentali nel piano $P (P a)$ vs $T_K (K)$. Il modello teorico prevede la relazione:
   $ P = m dot T_K + q $
   Per un gas ideale, l'ordinata all'origine $q$ deve risultare nulla (o compatibile con lo zero) entro le incertezze sperimentali.

3. *Determinazione della Costante $R$:* Nota la quantità di sostanza $n$ (vedi capitolo 2.4), il valore sperimentale della costante dei gas ideali si ottiene manipolando l'equazione di stato: $ R = (P V) / (n T) $.
  Tutte le grandezze risultano note, ed è quindi possibile calcolarla puntualmente.

4. *Estrapolazione dello Zero Assoluto ($T_0$):*
   Per determinare lo zero assoluto, si esegue una regressione lineare utilizzando la temperatura in gradi Celsius ($t_C$) in confronto con la pressione in Pascal. L'equazione della retta assume la forma:
   $ P = a dot t_C + b $
   Imponendo la condizione di pressione nulla ($P=0$), si estrapola la temperatura di zero assoluto $T_0$:
   $ T_0 = - b / a $
   Fisicamente, questo valore rappresenta la temperatura alla quale l'energia cinetica molecolare sarebbe nulla secondo il modello classico. Il valore ottenuto viene confrontato con il riferimento standard di $-273.15 "°C"$.

== 2.3 Composizione Chimica e Massa Molare
Sebbene l'aria sia una miscela gassosa, in regime di gas ideale essa è approssimabile a un gas singolo avente una *massa molare apparente* ($MM_"mix"$), calcolata come media pesata delle masse molari dei suoi costituenti in base alle rispettive frazioni molari ($chi_i$).

Considerando la composizione standard dell'aria secca a livello del mare, i principali costituenti sono:
- *Azoto ($N_2$):* $chi approx 78.08\%$, $MM approx 28.01 "g/mol"$
- *Ossigeno ($O_2$):* $chi approx 20.95\%$, $MM approx 32.00 "g/mol"$
- *Argon ($A r$):* $chi approx 0.93\%$, $MM approx 39.95 "g/mol"$
- *Anidride Carbonica ($C O_2$):* $chi approx 0.04\%$, $MM approx 44.01 "g/mol"$

La massa molare risultante dell'aria secca è:
$ MM_"aria" = sum (chi_i dot MM_i) approx 28.96 "g/mol" $

Tale parametro è essenziale per convertire la massa d'aria confinata nella quantità di sostanza $n$.

== 2.4 Correzioni per l'Umidità Atmosferica
Data la presenza intrinseca di vapore acqueo nell'aria ambientale, è stata implementata una correzione basata sui dati di umidità relativa forniti dal sensore.

La procedura di correzione segue un approccio semi-empirico:

1. *Pressione di Saturazione ($P_"sat"$):* Determinata mediante la relazione di *Magnus-Tetens*: Questa relazione empirica descrive molto bene il comportamenteo della pressione di saturazione nell'intervallo studiato.   $ P_"sat" = 611.2 dot exp((17.67 dot t_C) / (t_C + 243.5)) space [P a] $

2. *Pressione Parziale del Vapore ($P_v$):* Ricavata dall'Umidità Relativa ($U R$):
   $ P_v = (U R) / 100 dot P_"sat" $

3. *Frazione Molare del Vapore ($x_v$):*
   $ x_v = P_v / P_"tot" $

4. *Aggiornamento della Massa Molare:*
   La massa molare della miscela viene ricalcolata includendo il contributo del vapore acqueo:
   $ MM_"mix" = (1 - x_v) MM_"aria" + x_v MM_"vapore" $
   Dove $MM_"vapore" = 18.02 "g/mol"$. La quantità di sostanza $n$ è quindi determinata come:
   $ n = (rho V) / MM_"mix" $
   Il calcolo della densità ($rho$) è stato gestito mediante tabelle standard NIST per l'aria umida, applicando un algoritmo di interpolazione bilineare per evitare dipendenze ricorsive tra le variabili.

5. *Sistemi di Essiccazione:* Per minimizzare l'incertezza legata all'umidità, si è proceduto all'essiccazione dell'aria mediante *silica gel*, riducendo l'UR a valori prossimi al $10-15\%$. In configurazioni avanzate, il contenitore è stato trattato in forno ventilato a $120 "°C"$ per indurre l'evaporazione totale del vapore acqueo residuo; la successiva sigillatura a caldo (unita alla presenza della silica) ha permesso di ottenere un'umidità relativa prossima allo $0\%$ entro i limiti di sensibilità strumentale.
   
   La silica gel utilizzata include un *indicatore cromotropico* (viraggio dal rosa al verde in caso di saturazione), permettendo il monitoraggio visivo dell'efficacia del disidratante, rigenerabile tramite trattamento termico.
= 3. Metodologia
In questa sezione viene descritto il protocollo sperimentale adottato per la caratterizzazione volumetrica del sistema e la successiva acquisizione dei dati termodinamici.

== 3.1 Determinazione del Volume della Camera
Per la misura del volume interno della camera isocora è stata impiegata una procedura gravimetrica mediante una bilancia digitale con risoluzione al grammo. 

Il contenitore, preventivamente deterso e asciugato, è stato posto sulla bilancia per la taratura del peso a vuoto. Successivamente, la camera è stata riempita d'acqua fino al piano di chiusura. Durante l'operazione è stata prestata particolare attenzione per minimizzare l'errore di parallasse e l'effetto della tensione superficiale (menisco) sul bordo superiore. Al fine di evitare pregiudizi sistematici nella lettura, si raccomanda di occultare il display della bilancia fino al completamento del riempimento.

#let path1 = "immagini/barattolo_vuoto.png"
#let path2 = "immagini/barattolo_pieno.png"

#figure(
  grid(
    columns: (1fr, 1fr), 
    gutter: 10pt,        
    image(path1, width: 70%),
    image(path2, width: 70%),
  ),
  caption: [Procedura di calcolo volumetrico per via gravimetrica.],
) <fig-barattolo>

=== 3.1.1 Valutazione dei Volumi Parassiti (Elettronica e Disidratante)
Al volume totale del contenitore è necessario sottrarre il volume occupato dalla componentistica interna (volumi parassiti), costituita dal cablaggio, dal sensore BME280 e dai relativi supporti. 

Sulla base delle specifiche dimensionali del costruttore e delle sezioni dei conduttori, il volume dell'elettronica è stato stimato in circa $383 "mm"^3$, valore trascurabile rispetto alla capacità complessiva della camera.

#let imm_path = "immagini/dimensioni.jpg"
#figure(
  image(imm_path, width: 5cm),
  caption: [Specifiche dimensionali del sensore BME280.],
) <fig-sensore-dim> 

Al contrario, l'inserimento del disidratante (silica gel) rappresenta un contributo volumetrico non trascurabile. Considerando una densità tabulata di $0.7 "g/ml"$ e una massa di $10 "g"$ per unità, la riduzione del volume utile è di circa $14 "ml"$, valore tenuto in considerazione nella considerazione del volume.

== 3.2 Protocollo di Acquisizione
La procedura sperimentale prevede l'immersione della camera in una vasca termostatica. Inizialmente, il sistema viene raffreddato criogenicamente mediante una miscela eutettica di ghiaccio tritato e cloruro di sodio. Per contrastare la spinta idrostatica (di Archimede) risultante dalla fusione della miscela, è necessario applicare un sovraccarico sulla sommità del contenitore per garantirne la stabilità meccanica e l'immersione costante.

#let imm_path = "immagini/ghiaccio.jpeg"
#figure( 
  image(imm_path, width: 7cm), 
  caption: [Configurazione sperimentale in fase di raffreddamento criogenico.], 
) <fig-ghiaccio>

L'acquisizione dei dati può avvenire secondo due modalità operative:

- *Evoluzione spontanea:* il sistema raggiunge l'equilibrio termico con l'ambiente esterno mediante convezione naturale.
- *Riscaldamento forzato:* l'utilizzo di una sorgente termica esterna accelera la transizione termica, permettendo di esplorare intervalli di temperatura superiori in tempi ridotti.

Entrambi i protocolli hanno mostrato risultati consistenti. Ai fini dell'ottimizzazione dei tempi, la modalità forzata risulta preferibile, purché si eviti il contatto termico diretto tra la sorgente (fiamma) e il vetro. Ciò è fondamentale per prevenire stress meccanici e l'insorgenza di gradienti termici localizzati che invaliderebbero l'ipotesi di omogeneità del gas. Si consiglia un posizionamento asimmetrico della sorgente o l'interposizione di uno strato isolante per garantire una trasmissione del calore uniforme e quasi-statica.

= 4. Analisi dei Dati
In questa sezione viene fornita una panoramica delle metodologie computazionali adottate per l'elaborazione dei dati sperimentali.

Tutti gli algoritmi sviluppati, unitamente ai dataset raccolti, sono stati sistematizzati e resi disponibili in un repository GitHub dedicato, al fine di garantire la riproducibilità dell'esperienza: #link("https://github.com/oblivion0218/BME280").

== 4.1 Gestione dei Dati Iniziali
Il firmware per l'acquisizione dei dati (disponibile in GitHub come: `Arduino_code.txt`) viene caricato sul microcontrollore Arduino UNO e ha lo scopo di trasmettere i segnali digitali dei sensori all'unità di calcolo tramite interfaccia seriale. Per l'archiviazione di tali flussi è stato implementato uno script Python, `bme280_logger.py`, che formatta i dati in ingresso e li salva in file in formato `.csv`.

#let imm_path = "immagini/Andamento.png"
#figure(
  image(imm_path, width: 15cm),
  caption: [Esempio di serie temporale completa relativa a un ciclo di acquisizione.],
) <fig-andamento> 

Contemporaneamente, è stato sviluppato lo script `grafico_dinamico.py` per la visualizzazione in tempo reale dell'andamento temporale delle tre grandezze fisiche monitorate. Questo strumento si è rivelato fondamentale per l'identificazione immediata di eventuali anomalie strutturali dell'apparato o derive termiche indesiderate. Tale applicazione riveste inoltre una significativa valenza didattica, permettendo agli studenti di osservare fenomenologicamente l'evoluzione del sistema durante il setup.



== 4.2 Determinazione della Costante Universale $R$
L'elaborazione successiva è affidata a un Jupyter Notebook (`Analisi.ipynb`), deputato al calcolo della quantità di sostanza e dei parametri termodinamici derivati.

Il software integra i dati sperimentali con le tabelle NIST relative alla densità dell'aria umida. Mediante un algoritmo di interpolazione bilineare, il codice determina il valore di densità ottimale in funzione della temperatura e dell'umidità misurate, scalandolo successivamente in base alla pressione istantanea osservata.

Determinata  quindi la quantità di sostanza $n$ facendo uso delle precedenti relazioni. Il valore della costante $R$ viene calcolato puntualmente invertendo l'equazione di stato dei gas ideali. L'analisi prosegue con la generazione di un istogramma della distribuzione di frequenza e di un plot dell'andamento temporale di $R$. Infine, viene eseguito un test di compatibilità tra il valore medio pesato ottenuto e il valore nominale CODATA, esprimendo la divergenza in termini di deviazioni standard ($sigma$).

#let imm_path = "immagini/R.png"
#figure(
  image(imm_path, width: 15cm),
  caption: [Distribuzione statistica dei valori sperimentali della costante R.],
) <fig-R-dist> 

== 4.3 Verifica della Legge di Gay-Lussac e Stima di $T_0$
Il core dell'analisi riguarda la correlazione tra pressione e temperatura per la verifica della seconda legge di Gay-Lussac.

Dalla regressione lineare dei dati di pressione e temperatura (in °C), viene effettuato un confronto tra il valore teorico dello zero termico ($-273.15 "°C"$) e il valore ottenuto dall'estrapolazione a pressione nulla ($P = 0 "Pa"$), valutandone la consistenza statistica.

È stato inoltre eseguito un fit lineare nel piano $P-T_K$ per quantificare lo scostamento dall'idealità del gas, espresso dal parametro di intercetta $q != 0$.

Contrariamente alla determinazione di $R$, questa fase dell'esperienza ha evidenziato una discrepanza sistematica tra i risultati sperimentali e le previsioni del modello. Come visibile in @fig-PT, i dati mostrano una marcata non sovrapponibilità tra le fasi di riscaldamento e raffreddamento, fenomeno riconducibile a un'isteresi del sistema.

#let imm_path = "immagini/P-T.png"
#figure(
  image(imm_path, width: 14cm),
  caption: [Diagramma P-T con regressione lineare forzata sui dati sperimentali.],
) <fig-PT> 


A seguito di un'analisi approfondita, tale comportamento è stato attribuito a fenomeni di "respirazione" del contenitore, ovvero a una perdita di ermeticità della camera isocora. Nonostante le contromisure adottate (applicazione di PTFE, isolamento delle connessioni e ottimizzazione del gradiente termico), la criticità principale permane nella sigillatura del tappo mediante colla a caldo. Quest'ultima, raggiungendo temperature prossime al punto di rammollimento, subisce deformazioni plastiche che permettono lo sfiato del gas, creando canali di fuga che persistono anche durante la fase di raffreddamento, alterando irreversibilmente la massa d'aria confinata.

= 5. Discussione finale e Analisi degli Errori

L'analisi quantitativa dei dati raccolti richiede una rigorosa gestione delle incertezze per poter trarre conclusioni fisicamente valide. 

In questo esperimento, le sorgenti di errore sono state classificate in due categorie principali: strumentali e di metodo.

Per le grandezze dirette quali Pressione ($P$), Temperatura ($T$) e Umidità Relativa ($U R$), si è adottata le tolleranze fornite dal datasheet del sensore BME280 (come riportato in @fig-sensibilita). Il volume del gas, invece, è affetto da un errore statistico legato alla misurazione della capacità del contenitore, mentre il volume sottratto dai componenti interni è stato trattato come esatto in quanto geometricamente determinato.

Un aspetto cruciale di questa analisi è stato il metodo di propagazione degli errori per la costante $R$ e per le moli $n$. A causa della complessità delle formule e della correlazione tra le variabili (ad esempio, la densità dell'aria dipende sia da $P$ che da $T$), non è stato utilizzato il classico metodo differenziale analitico. Si è optato invece per un approccio computazionale di perturbazione numerica: l'algoritmo calcola come varia il risultato finale "perturbando" ogni variabile di ingresso del suo valore di incertezza. Le variazioni risultanti sono state poi sommate in quadratura. Questo approccio ha permesso di ottenere una stima dell'incertezza molto più robusta e aderente alla realtà fisica del sistema, evitando sovrastime o sottostime tipiche delle semplificazioni algebriche.

Tuttavia, l'errore dominante nell'esperimento non è di natura statistica, ma sistematica. Come evidenziato dai grafici $P-T$, l'apparato soffre di un fenomeno di isteresi: le curve di riscaldamento e raffreddamento non si sovrappongono perfettamente. Questo indica che la trasformazione non è perfettamente isocora (a volume costante). La causa è stata individuata nella "respirazione" del contenitore: le sigillature, sottoposte a stress termico, tendono a perdere ermeticità ad alte temperature, alterando la massa di gas all'interno del vaso e compromettendo parzialmente la verifica della legge di Gay-Lussac.

== 5.1 Sviluppi Futuri e Migliorie

=== Possibili migliorie dell'esperienza

L'esperienza, pur fornendo risultati qualitativamente coerenti con la teoria, presenta margini di miglioramento sia dal punto di vista tecnico che didattico.

Dal punto di vista tecnico, la priorità assoluta è garantire l'ermeticità del sistema. L'uso della colla a caldo si è rivelato inefficace per cicli termici estesi, in quanto il materiale tende ad ammorbidirsi col calore. Per iterazioni future, si suggerisce l'uso di:
- Sigillanti siliconici per alte temperature o mastici epossidici. 
- Un sistema di chiusura meccanica con guarnizioni in gomma (o-ring) e grasso da vuoto, che garantiscono la tenuta permettendo al contempo una facile apertura.

Risolvendo il problema della tenuta, l'ellisse di isteresi collasserebbe sulla retta teorica, permettendo una stima dello zero assoluto molto più precisa.

=== Commento didattico

Dal punto di vista didattico, una criticità emersa è la durata dell'esperimento. Una raccolta dati accurata richiede variazioni di temperatura lente ("quasi-statiche"), il che può tradursi in tempi morti in cui l'attenzione degli studenti rischia di calare. Per mitigare questo rischio, si propongono due strategie:

- Visualizzazione in tempo reale con l'uso del software 'grafico_dinamico.py' . Vedere il grafico costruirsi "live" trasforma l'attesa in osservazione attiva.
- Integrazione teorica: Il docente può sfruttare il tempo di riscaldamento/raffreddamento per spiegare le leggi dei gas o discutere la natura microscopica della pressione, trasformando l'attesa in un momento di lezione frontale applicata.

=== Estensione alla legge di Boyle

Una volta che l’apparato sperimentale è stato stabilizzato, l’esperienza può essere facilmente estesa utilizzando barattoli di volume diverso per gruppi differenti di studenti. In questo modo ogni gruppo può svolgere l’esperimento in modo autonomo.

I risultati ottenuti possono poi essere confrontati e unificati per verificare sperimentalmente la legge di Boyle. A temperatura costante, dall’interpolazione dei dati emergono valori di pressione diversi al variare del volume. Rappresentando tali risultati nel piano pressione–volume (P-V), si osserva la relazione di proporzionalità inversa $P prop 1/V$.

L’esperienza fornisce così agli studenti una conferma sperimentale completa dell’equazione di stato dei gas ideali.

#let imm_path = "immagini/generico.png"
#let imm_path2 = "immagini/boyle.jpg"

#figure(
  grid(
    columns: (1fr, 1fr), 
    gutter: 10pt,        
    image(imm_path, width: 90%),
    image(imm_path2, width: 105%),
  ),
  caption: [Possibile estensione dell'esperienza per verificare la legge di Boyle],
) <fig-barattolo>

== 5.2 Conclusioni
 
 In conclusione, l'attività proposta si dimostra uno strumento didattico potente e versatile, perfettamente adattabile al curriculum di un liceo scientifico.
 
 Al di là della semplice verifica della legge dei gas ideali, il vero valore aggiunto di questo setup risiede nell'approccio moderno alla fisica sperimentale: gli studenti non si limitano a leggere un termometro analogico, ma si interfacciano con sensori digitali, microcontrollori e analisi dati al computer. Questo permette di introdurre concetti trasversali come l'acquisizione dati, la calibrazione e l'analisi statistica degli errori in modo naturale e intuitivo.
 
 Nonostante le difficoltà tecniche legate all'isolamento termico e pneumatico, facilmente risolvibili con materiali più idonei, l'esperienza riesce a rendere tangibili concetti astratti come lo zero assoluto e la costante universale dei gas. Con le dovute accortezze sulla gestione dell'umidità e della tenuta stagna, questo laboratorio rappresenta un eccellente ponte tra la fisica classica e le moderne tecniche di indagine scientifica.

#pagebreak()

// Titolo
#align(center)[
  #text(17pt, weight: "bold")[A caccia del Gas Perfetto]\
  #text(14pt, style: "italic")[Analisi di una trasformazione Isocora con sensore BME280]
  #v(1em)
]

= Quando un gas è "Perfetto"?
In fisica, un gas si definisce "perfetto" quando accettiamo quattro grandi compromessi (o approssimazioni) che ci semplificano la vita:

1.  Il volume delle singole molecole è zero, cioè le approssimiamo come puntiformi.
2.  **Nessuna attrazione:** Ignoriamo le forze intermolecolari (come quelle di Van der Waals).
3. Tutti gli urti (tra molecole o contro le pareti) sono perfettamente elastici. Niente energia viene persa.
4.  **Caos totale:** Il moto è puramente casuale (Moto Browniano).

Se accettiamo queste ipotesi, otteniamo le famose leggi di Boyle e Gay-Lussac che convergono nell'equazione di stato dei gas perfetti:

$ P V = n R T $

Dove $P$ è la pressione, $V$ il volume, $T$ la temperatura, $n$ le moli di gas e $R$ la costante universale dei gas perfetti.
Oggi metteremo alla prova queste leggi dell'800 con la tecnologia del 2026!

= Modello Cinetico: Cosa succede lì dentro?
Immagina le molecole d'aria come miliardi di palline chiuse nel nostro barattolo.
La **Temperatura** è una misura della loro energia cinetica media: più scaldi, più le palline vanno veloci.
La **Pressione** è il risultato dei continui urti che queste palline danno sulle pareti del barattolo.

*Domanda flash:* Se il volume è bloccato (il barattolo non si espande) e tu aumenti la temperatura (palline più veloci), cosa succederà alla violenza degli impatti sulle pareti? E quindi, cosa farà la pressione?

= Materiale e Setup
Ecco il nostro kit di esplorazione:
- Barattolo in vetro con tappo metallico forato
- Sensore ambientale BME280
- Scheda Arduino UNO + cavi
- Computer per l'analisi
- Silica gel (in bustine o sfusa)
- Nastro in teflon e Nastro isolante
- Silicone o colla a caldo
- Ghiaccio, sale fino, acqua e una fiamma

= Procedura Sperimentale

== 1. Quanto è grande il nostro barattolo?
Prima di tutto dobbiamo sapere esattamente qual è il volume $V$ del nostro barattolo.
Non usate il righello! C'è un metodo più preciso usando una **bilancia da cucina** e dell'**acqua**.
*Indizio:* La densità dell'acqua è $1 "g/cm"^3$... vi viene in mente come fare?

#quote(block: true)[
  _Consiglio:_ Fate più misurazioni e calcolate la media. Una sola misura è spesso preda dell'errore casuale!
]

== 2. Preparazione dell'apparato
Ora dobbiamo rendere il barattolo ermetico. Vogliamo una trasformazione **Isocora** ($V =$ costante), quindi (idealmente) non deve scappare nemmeno una molecola!

1.  **Silica Gel:** Pesate una quantità nota di silica gel e inseritela nel barattolo.
    #footnote[La silica serve ad assorbire l'umidità. Controllate il colore delle palline indicatrici per essere sicuri che sia attiva (secche)!] 
    La presenza della silica è importante perchè il vapore acqueo NON si comporta come un gas perfetto vicino alla saturazione, rimuoverlo è quindi un'ottimo modo per semplificare il problema.

2.  **Teflon:** Avvolgete il filetto del barattolo con nastro in teflon per sigillare la chiusura.
3.  **Cablaggio:** Collegate il sensore BME280 ad Arduino passando i cavi dal foro del tappo. Seguite lo schema qui sotto (@fig-collegamenti).

#let imm_path = "immagini/collegamenti.jpeg"
#figure(image(imm_path, width: 8cm),
caption: [Schema di collegamento del sensore BME280 ad Arduino],) <fig-collegamenti>

4.  **Test:** fate una prova rapida di lettura dati (vedi sez. successiva per il come). Il sensore è calibrato? risponde con dati sensati? Per rispondere a queste domande confrontati con gli altri gruppi, oppure puoi fare un confronto con le previsioni del meteo, queste forniscono pressione, umidità e temperatura dell'aria aperta nell'arco della giornata!

5.  **Sigillatura:** Se l'output del sensore vi convince, sigillate il foro dei cavi con silicone o colla a caldo (senza lasciare buchi!) chiudete poi il tappo con forza. Un giro di nastro isolante esterno renderà tutto più sicuro.

== 3. Il Software
Assieme a questa scheda avete a disposizione 4 file: Non eseguiteli a caso!
1.  `Arduito_code.txt`: Questo è il codice da caricare sulla scheda Arduino per "parlare" col sensore.
2.  `bme280_logger.py`: Il suo ruolo è salvare i dati in arrivo dalla porta USB su un file '.csv'.
3.  `grafico_dinamico.py`:  Vi mostra i grafici in tempo reale per capire se sta succedendo qualcosa di strano.
4.  `Analisi.ipynb`:  Lo userete alla fine per fare i calcoli.

I codici sono commentati. Apriteli; riuscite a capire dove vengono salvati i dati e cosa sta succedendo? Chiedete pure a un'AI di spiegarvi i passaggi oscuri.

== 4. Esperimento: Dal gelo al caldo
Tutto pronto? Si parte!

1.  **Il Gelo (-15°C):** Preparate una miscela frigorifera (ghiaccio tritato + sale fino) in una bacinella. Grazie alla chimica, questa miscela scende ben sotto lo zero! Immergete il barattolo e aspettate che la temperatura letta dal sensore sia minima e stabile.

2.  **Il Fuoco (Quasi-statico):** Accendete una fiamma *bassa* sotto la bacinella in cui c'è il barattolo, portando il ghiaccio a scioglersi e poi scaldarsi.
    * *Attenzione:* Il processo deve essere **Quasi-statico**, cioè moooolto lento.*
    
    *Perché?* Dobbiamo dare tempo al gas interno di raggiungere la stessa temperatura delle pareti. Se scaldate troppo in fretta, il termometro segnerà una temperatura diversa da quella reale del gas!
3.  **Stop:** Raccogliete dati finché non arrivate a **massimo 70°C**. Oltre questa soglia il sensore potrebbe "cuocersi" e dare numeri a caso.
4.  Spegnete tutto e lasciate raffreddare.

= Analisi dei Dati
Avviate il notebook `Analisi.ipynb`. Il primo passo fondamentale è inserire correttamente i parametri del vostro sistema: il **volume netto** misurato con il suo errore.

Il software eseguirà un'analisi statistica e grafica divisa in due fasi:

1.  **Stima della Costante $R$:**
    Il codice inverte l'equazione di stato dei gas perfetti calcolando $R$ per ogni singolo istante di campionamento.
    -   **Istogramma:** Vi permetterà di vedere la distribuzione dei valori calcolati (come si distribuiscono? perchè?).
    -   **Drift temporale:** Il grafico $R$ vs $t$ è fondamentale per la diagnostica. Se $R$ non è costante ma sale o scende durante l'esperimento, significa che abbiamo una perdita di gas o che il sistema non era in equilibrio termico.

2.  **Regressione Lineare ($P$ vs $T$):**
    Verranno prodotti due grafici su cui sarà effettuato un fit lineare del tipo $y = m x + q$, la differenza tra i due sta nell'unità di misura di T:
    -   **Scala Kelvin:** Qui ci aspettiamo una relazione di proporzionalità diretta ($P prop T$). L'intercetta $q$ è compatibile con zero entro l'errore sperimentale?
    -   **Scala Celsius:** Qui la retta è traslata. L'estrapolazione della retta fino a $P=0$ vi fornirà la stima sperimentale dello **Zero Assoluto**. Confrontate il vostro risultato con il valore teorico ($-273.15$ °C) è compatibile?

= Spunti di Riflessione e Confronto
Rispondete a queste domande nella vostra relazione finale per dimostrare la comprensione del fenomeno:

1. Come potresti calcolare le moli "n" di aria intrappolata nel barattolo? Qual'è il ruolo del vapore acqueo all'interno? Come lo gestisce il codice?

2.  Confrontate il vostro grafico $P-T$ con quello di un gruppo che ha usato un barattolo di volume $V$ diverso.
    Dall'equazione $P = (n R / V) dot T$, notate che il coefficiente angolare (la pendenza della retta) è $m = (n R) / V$.
    -   Osservate come cambia la pendenza al variare del volume: chi ha il volume maggiore ha una retta più ripida o meno ripida?
    -   Guardate poi il valore della pressione tra gruppi con volumi viversi ma alla stessa temperatura, provate a costruire un grafico P-V tutti assieme. Riuscite a verificare la legge di Boyle?  .

3.  **Analisi degli Errori:**
    Quale variabile incide maggiormente sull'errore finale di $R$? È l'incertezza sulla misura del Volume o quella sulla temperatura del sensore? Giustificate la risposta.








