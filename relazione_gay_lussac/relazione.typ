// --- Impostazioni Documento ---
#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2cm),
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
  Il presente elaborato si pone come obiettivo la verifica sperimentale della seconda legge di Gay-Lussac e la verifica della compatibilità della costante dei gas perfettti R estratta dai dati con il suo valor vero. L'intero elaborato è stato realizzato utilizzando strumentazione _low-cost_ (come il sensore BME280 e il microcontrollore Arduino UNO) e prestando la maggior attenzione possibile alla riduzione degli errori sistematici e casuali.
   
   L'esperimento cerca di osservare l'evoluzione isocora di una massa d'aria confinata ermeticamente e sottoposta a un ciclo termico quasi-statico nel range range $-15 degree "C" < T < 80 degree "C"$. I dati di Pressione, Temperatura e Umidità Relativa sono stati acquisiti in tempo reale tramite Arduino e successivamente analizzati con Python per estrapolare i parametri di interesse.

   Sul fondo di questo report, pensato per l'uso di un professore liceale, è riportata anche una scheda dedicata da poter fornire agli studenti durante lo svolgimento dell'esperimento in laboratorio.
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
L'apparato sperimentale è stato progettato per isolare una massa d'aria fissa e sottoporla a variazioni di temperatura controllate (quasi-statiche), monitorando in tempo reale le variabili di stato.

== 1.1 Strumentazione Elettronica
Il cuore del sistema di acquisizione è basato su piattaforma Arduino.
- *Sensore:* Modulo *BME280* . Si tratta di un sensore ambientale digitale integrato che misura Pressione, Temperatura e Umidità Relativa. Dai dati di fabbrica e dalla letteratura tecnica si riportano le specifiche in @fig-sensibilita.

#let imm_path = "immagini/sensibilità.jpg"

#figure(
  image(imm_path, width: 8cm),
  caption: [Descrizione  della sensibilità del sensore.],
) <fig-sensibilita> 

- *Microcontrollore:* Scheda *Arduino UNO*, utilizzata per l'interfacciamento con il sensore e il logging dei dati via seriale verso PC.
- *Frequenza di Campionamento:* I dati sono stati acquisiti a una frequenza di $1 "Hz"$ ($1 "sample/s"$), sufficiente per seguire l'evoluzione termica lenta del sistema.


== 1.2 Codice di Acquisizione

Il software di acquisizione è stato sviluppato in ambiente Arduino IDE, utilizzando librerie specifiche per la gestione del BME280 e per la comunicazione seriale. E' quindi ncessario l'uso di un computer con porta seriale USB per il salvataggio dei dati in formato CSV per l'analisi successiva.
Di seguito lascio il codice utilizzato per il corretto funzionamento del sensore.

#let imm_path = "immagini/arduino code.png"
#figure(
  image(imm_path, width: 15cm),
  caption: [Codice arduino per il corretto funzionamento del sensore.],
) <fig-code> 

== 1.3 Camera di Misura e Sigillatura
Come camera isocora è stato utilizzato un contenitore in vetro rigido dotato di tappo metallico a vite.
- *Posizionamento Sensore:* Il tappo è stato forato nel centro geometrico, questo per assicurare che il sensore interagisse meno con le pareti del contenitore. Nel foro sono stati passati i cavi di connessione tra sensore e arduino.
- *Isolamento foro:* Il passaggio dei cavi attraverso il tappo è stato sigillato ermeticamente utilizzando colla a caldo, applicata sia internamente che esternamente per cercare di garantire la tenuta in pressione e prevenire perdite di massa.

#let imm_path = "immagini/tappo.jpeg"
#figure(
  image(imm_path, width: 8cm),
  caption: [Dettaglio del tappo del contenitore isocoro.],
) <fig-tappo> 

- *Isolamento tappo a vite*: Un'altro possibile punto di fuga da trattare è il filetto del tappo a vite. Per minimizzare questo effetto, è stato applicato del nastro teflonico sul filetto prima della chiusura, in modo da migliorare la tenuta. In esterno è stato poi applicato del nastro isolante per ulteriore sicurezza.

== 1.4 Bagni Termici
Per variare la temperatura del sistema sono stati utilizzati due bagni termici esterni:
1.  *Bagno Freddo:* Miscela eutettica di ghiaccio tritato e sale (NaCl), utilizzata per raggiungere la temperatura minima di circa $-15 degree "C"$ per abbassamento crioscopico. #footnote[E' importante notare che in commercio sono disponibili altri tipi di sale che a contatto con il ghiaccio tritato possono raggiungere temperature ben più basse (ad esempio CaCl2 o MgCl2, comunemente usati come additivi in inverno per lo spargimento del sale sulle strade), ma per motivi di sicurezza e reperibilità si è scelto di utilizzare il comune sale da cucina.]

2. *Bagno Caldo:* Bagno d'acqua riscaldato su piastra/fiamma, per portare il sistema dolcemente verso la temperatura massima di esercizio dell'elettronica ($approx 80 degree "C"$).

Il barattolo è stato immerso nei bagni termici in modo da garantire un buon scambio termico, mantenendo il sensore all'interno della camera di misura. Sono stati poi raccolti i dati fino al raggiungimento dell'equilibrio termico con l'ambiente in entrambe le fasi di riscaldamento e raffreddamento.


= 2. Cenni Teorici e Modello Fisico

== 2.1 L'Aria come Gas Ideale
L'equazione di stato dei gas ideali rappresenta il modello fondamentale per descrivere il comportamento termodinamico di un gas in condizioni di bassa densità e alta temperatura (rispetto al punto critico). Essa lega le variabili di stato pressione ($P$), volume ($V$) e temperatura assoluta ($T$) tramite la relazione:

$ P V = n R T $

Dove:
- $n$ è il numero di moli di gas;
- $R$ è la costante universale dei gas ($approx 8.314  "J" / ("mol" K)$).

Nel range di temperature esplorato in questo esperimento e a pressione circa atmosferica, le interazioni intermolecolari dell'aria sono estremamente deboli e il volume proprio delle molecole è trascurabile rispetto al volume del contenitore. Di conseguenza, le deviazioni dal comportamento ideale (descritte ad esempio dall'equazione di Van der Waals) sono minime e l'aria può essere trattata con eccellente approssimazione come un gas perfetto.

== 2.2 Trasformazione Isocora (Legge di Gay-Lussac)
Mantenendo costante il volume del sistema ($V = "cost"$) e la quantità di sostanza ($n = "cost"$), l'equazione di stato si riduce alla relazione lineare nota come *Seconda Legge di Gay-Lussac*:

$ P = (n R / V) dot T $

Questa relazione implica una dipendenza diretta tra pressione e temperatura assoluta.

=== Protocollo di Analisi Dati
Per verificare sperimentalmente la legge e ricavare le costanti fisiche, si procede come segue:

1. *Controllo dimensionale:* Tutte le temperature misurate sono in gradi Celsius ($t$) ma vengono convertite in Kelvin ($T_K$) dallo script arduino di presa dati:
   $ T_K = t + 273.15 $
Allo stesso modo anche la pressione restituita dallo script in kPa, viene convertita in Pa moltiplicando per 1000.

2. *Regressione Lineare:* Si esegue poi un fit lineare sui dati sperimentali riportati nel piano $P$ (Pa) vs $T_K$ (K). Il modello teorico prevede:
   $ P = m dot T_K + q $
   Dove idealmente, per un gas perfetto, l'intercetta $q$ dovrebbe essere nulla ($q=0$) entro l'errore sperimentale.

3. *Calcolo della Costante $R$:* Dai dati è possibile estrarre anche il valore della costante dei gas ideali R, questa si ottiene semplicemente invertendo la relazione dei gas perfetti $ R = (P V) / (n T) $

4. *Stima dello Zero Assoluto ($T_0$):*
   Per visualizzare fisicamente lo zero assoluto, si può eseguire un fit alternativo utilizzando la temperatura in Celsius ($t$). L'equazione della retta diventa:
   $ P = a dot t + b $
   Imponendo la condizione di pressione nulla ($P=0$), si ottiene la temperatura di estrapolazione $T_0$:
   $ T_0 = - b / a $
   Questo valore rappresenta la temperatura alla quale l'agitazione termica molecolare cesserebbe completamente secondo il modello classico. Il risultato sperimentale andrà confrontato con il valore teorico atteso di $-273.15 degree "C"$.

== 2.3 Composizione Chimica e Massa Molare
Sebbene l'aria sia una miscela, in regime di gas ideale si comporta come un unico gas avente una *massa molare apparente* ($MM_"mix"$) calcolata come media ponderata delle masse molari dei suoi costituenti rispetto alle loro frazioni molari ($chi_i$).

Considerando la composizione standard dell'aria secca a livello del mare, si riportano i principali componenti con le loro frazioni molari e masse molari:
- *Azoto ($N_2$):* $chi approx 78.08\%$, $MM approx 28.01 "g/mol"$
- *Ossigeno ($O_2$):* $chi approx 20.95\%$, $MM approx 32.00 "g/mol"$
- *Argon ($A r$):* $chi approx 0.93\%$, $MM approx 39.95 "g/mol"$
- *Anidride Carbonica ($C O_2$):* $chi approx 0.04\%$, $MM approx 44.01 "g/mol"$

La massa molare dell'aria risulta:
$ MM_"aria" = sum (chi_i dot MM_i) approx 28.96 "g/mol" $

Questo valore è fondamentale per convertire la massa d'aria intrappolata nel numero di moli $n$.

== 2.4 Correzioni per l'Umidità

L'aria atmosferica non è mai perfettamente secca. La presenza di vapore acqueo è stata considerata come una possibile correzione da tenere sotto controllo grazie al fatto che il sensore restituisce il valor dell'umidità relativa dell'aria.

Per farlo si è seguita una procedura semiempirica:

1. *Pressione di Saturazione ($P_"sat"$):* Calcolata tramite la formula empirica di *Magnus-Tetens*, che fornisce un'ottima approssimazione nel range di interesse:
   $ P_"sat"(t) = 611.2 dot exp((17.67 dot t) / (t + 243.5)) space ["Pa"] $

2. *Pressione Parziale del Vapore ($P_v$):* Derivata dall'Umidità Relativa ($U R(%)$) misurata dal sensore:
   $ P_v = (U R) / 100 dot P_"sat" $

3. *Frazione Molare del Vapore ($x_v$):*
   $ x_v = P_v / P_"tot" $

4. *Correzioni:*
   La frazione molare del valore acqueo è stata usata nel calcolo della massa molare apparente della miscela, aggiornando la formula come segue:
   $ MM_"mix" = (1 - x_v) MM_"aria" + x_v MM_"vapore" $
   Dove $MM_"vapore" = 18.02 "g/mol"$.
   Con questa procedura è stato possibile calcolare il numero di moli nel barattolo usando la relazione:
   $ n = m / MM_"mix" = (rho V) / MM_"mix" $

   Il parametro di densità ($rho$) è fortemente dipendente da umidità, temperatura e pressione, rischiando di cadere in una definizione circolare, per questo motivo si sono usate delle tabelle standard per l'aria secca a temperatura e pressione variabili e corrette per l'umidità relativa.

5. *Prevenzione:* Per minimizzare l'impatto di queste correzioni, si è cercato di mantenere l'umidità relativa all'interno del barattolo il più bassa possibile durante l'esperimento.
   Nei primi tentativi sperimentali, l'uso di aria ambientale ha portato a valori di umidità relativa alti ($approx 40-60\%$), era quindi necessario deumidificare l'aria all'interno del barattolo. L'inserimento di silica gel ha permesso di ridurre l'umidità relativa a valori medi di circa $10-15\%$, con un conseguente miglioramento della ripetibilità delle misure e della coerenza dei risultati  anche nel caso in cui si ignorino i fenomeni di non idealità e di presenza di vapore acqueo.

   Si è anche esplorato un metodo per portare attorno a 0% l'UR, è quello di mettere il barattolo in forno ventilato a una temperatura di circa 120° per un'ora, in modo da far evaporare tutta l'umidità presente. Tappando il contenitore ancora caldo si ottiene un setup a pressione minore della atmosferica e con umidità estremamente bassa.

   Per un corretto uso della silica , è importante sottolineare che nelle bustine in commercio è presente anche un'indicatore di funzioanamento della silica, con lo scopo di segnalarci se questa non sia più attiva contro l'umidità. Nel mio particolare caso delle palline virano dal rosa al verde quando sono sature di umidità assorbita. E' comunque sempre possibile rigenerarla con un trattamento molto semplice ad alte temperature in forno.


= 4. Metodologia
In questa sezione cerchiamo di presentare come è stata effettuata la procedura sperimentale.

== 4.1 Calcolo dei volumi
Per il calcolo del volume dei diversi contenitori in esame si è seguita una semplice procedura sperimentale con 3 misurazioni tramite una bilancia da cucina. 
Impostando la bilancia su “acqua” ho appoggiato il barattolo vuoto e asciutto, ho poi tarato la bilancia. In seguito ho riempito il contenitore fino all’orlo con acqua. Per evitare di essere prevenuto sul valore ho coperto il risultato della bilancia in modo tale da non leggerlo. Ho anche cercato anche di diminuire la parallasse stando il più possibile allineato al barattolo. 

#let path1 = "immagini/barattolo_vuoto.png"
#let path2 = "immagini/barattolo_pieno.png"

#figure(
  grid(
    columns: (1fr, 1fr), // Due colonne di uguale larghezza
    gutter: 10pt,        // Spazio tra le immagini
    image(path1, width: 100%),
    image(path2, width: 100%),
  ),
  caption: [Valutazione del volume di un barattolo con l'uso dell'acqua.],
) <fig-barattolo>


=== 4.1.1 Correzione per elettronica e silice

Al volume del contenitore è necessario sottrarre il volume dell'elettronica inserita costituita dai 4 cavi, dal sensore BME280 e dal ponte di collegamento. 
Utilizzando le dimensioni fornite dal costruttore e la sezione dei cavi tabulata online, stimo un volume di $383 m m^ 3$, completamente trascurabile rispetto al volume del contenitore.

#let imm_path = "immagini/dimensioni.jpg"
#figure(
  image(imm_path, width: 5cm),
  caption: [Dettaglio delle dimensioni del sensore],
) <fig-tappo> 

Una realtà più impattante invece è quella della silica gel, che avendo una densità di $0.7 g/(m l)$ e una massa di 10g per bustina, comporta una diminuzione del volume di circa 14 ml.

== 4.2 Presa dati
La procedura sedguita per la presa dati è molto semplice, ponendo il barattolo nella pentola, lo si circonda di ghiaccio tritato e sale fino, sopra il barattolo è bene posizioanr eun peso perchè una volta che il ghiaccio sarà sciolto combatterà il fenomeno del galleggiamento.

#let imm_path = "immagini/ghiaccio.jpeg"
#figure(
  image(imm_path, width: 7cm),
  caption: [Presa dati con ghiaccio e sale da cucina],
) <fig-tappo> 

La presa dati può avvenire molto lentamente fino all'equilibrio termico oppure, in un contesto più scolastico sarebbe utile l'uso di una piccola fiamma che possa favorire lo scioglimento e poi portare l'acqua a temperature più alte; entrambe le strade sono state provate con risultati molto simili. La scelta della fiamma sembra quindi la più intelligente a patto però che non sia a contatto diretto con il vetro per non falsare i risultati, è necessario che sia spostata geometricamente o separata da uno strato di isolnante tipo sughero.

= 5. Analisi Dati
Nelle precedenti sezioni è stato analizzato un caso volutamente generico in modo da poter fornire una visione di come replicare l'esperienza al meglio.
In questa parte però scendiamo ad analizzare una singola presa dati con i rispettivi risultati in modo da affrontare l'analisi.

== 5.1 Dati iniziali
Il codice fornito ( nella sezione 1.2) e caricato sull'arduino, consente di mandare dal sensore al computer una serie di numeri che vanno ora letti e salvati, per falo ho utilizzato un codice da me scritto, chiamato 'bme280_logger.py' che salva i dati in ingresso in un file '.csv'. Contemporanemente ho sviluppato un codice che in tempo reale fornisse l'andamento temporale delle tre grandezze analizzate denominato 'grafico_dinamico.py'; così facendo è stato possibile visualizzare l'andamento ed accorgesi immediatamente di eventuali errori dell'apparato.

#let imm_path = "immagini/Andamento.png"
#figure(
  image(imm_path, width: 17cm),
  caption: [Ciclo completo di raccolta dati],
) <fig-andamento> 

Tutti i codici utilizzati nell'analisi e i dati raccolti sono stati sistemati e organizzati dentro una cartella GitHub condivisa, chiunque tentasse di replicare l'esperieza può utilizzarli liberamente e li trova al seguente link: https://github.com/oblivion0218/BME280 .

== 5.1 Determinazione della costante $R$
Il passo successivo è la stesura di un codice (che trovate come 'Analisi.py') in cui siano calcolate le moli prima e tutte le altre grandezze poi. Questo fa riferimento alla tabella del NIST per le densità dell'aria umida ad una determinata pressione, implementa un algoritmo di 'NearestNeighbour' per trovare il dato più vicino in tabella, per poi scalarlo linearmente con la pressione realmente osservata. 
Dal numero di moli ottenuto il codice prosegue con il calcolo della costante R invertendo la formula dei gas perfetti.
Il valore di R viene così calcolato punto per punto, ottenendo una distribuzione dei valori ottenuti, ciascuno con il relativo errore ottenuto tramite propagazione degli errori considerando quelli strumentali. 
Il passo successivo del codice è la stesura di un istogramma con la distribuzione e un plot con l'andamento temporale del valore di R calcoalto nel tempo.
infine , in questa prima parte di coice, viene fatto un confronto tra il valore vero e la media pesata ottenuta dai dati restituendo una distanza in sigma.ù

#let imm_path = "immagini/R.png"
#figure(
  image(imm_path, width: 10cm),
  caption: [Distribuzione statistica della costante R],
) <fig-andamento> 

Per esempio, usando un contenitore da (322 $+/-$ 3) ml, il codice stima (0.016 $+/-$ 0.002) moli di gas, e restituisce una costante R pari a (8.30 $+/-$ 4.2e-01) J/(mol·K)), assicurando una compatibilità elevata con il valor vero.

== 5.2 Verifica Legge di Gay-Lussac e Stima di $T_0$
Il codice prosegue poi analizzandoa dipendenza tra pressione e temperatura, cercando di verificare le seconda legge di Gay-Lussac.

#let imm_path = "immagini/P-T.png"
#figure(
  image(imm_path, width: 17cm),
  caption: [Plot P-T dei dati raccolti con fit forzato ai dati],
) <fig-PT> 

Come si può osservare dalla un'amdamento ciclico è stato sempre riscontrato, e molte delle tecniche sopra citate (introduzione della silica, uso del forno per diminuire la pressione e uso dei nastri isolanti) hanno proprio lo scopo di ridurre questo effetto. 
Il codice fa poi un confronto tra lo zero termico (posto a -273.15 °C) con il valore trovato dall'estrapolazione a 0 Pa della temperatura valutandone la compatibilità. Purtroppo in questa parte dell'esperienza non si riscontra un buon risultato in termini di compatibilità.

= 6. Discussione finale e Analisi degli Errori
Per quanto riguarda gli errori, nelle grandezze di Pressione, Temperatura e UR si è usato l'errore strumntale riportanto in @fig-sensibilita. Il volume da sottrarre è stato considerato senza errore in quanto derivante da parametri noti e/o tabulati.

l'errore sulle moli è stato ottenuto tramite perturbazione delle grandezze in gioco con un meccanismo puramente computazionale , mentre l'errore su R deriva direttamente dalla teoria degli errori.

Nel corso della prima esecuzione di questa esperienza molte possibili strade sono state perseguite e molte piccole accortezze portate per migliorare il risultato, non ha senso affrontarle qui una per una ma nel testo scritto fino ad ora sono riportate tutte.

L'unica nota degna di dettaglio in caso si tentasse di replicare questa esperienza, è il perchè della forma ovale visibile nel grafico P-T. Dopo numerosi tentativi e approfondimenti, sono ormai sicuro che il motivo è una fuga di gas dalla sigillatura in silicone del tappo. Quest'ultimo diventa più molle ad alte temperature invalidando l'ipotesi di isocoricità del sistema permettendo così all'interno di respirare.

== 6.1 Sviluppi Futuri
L'intera esperienza può evolversi ancora meglio se si riuscisse ad individuare un metodo più sicuro per isolare l'apparato , a quel punto sono sicuro che l'intera ellisse collasserebbe sulla linea osservata da Gay-Lussac, portando probabilmente ad una migliore compatibilità con lo zero termico.

una volta risolto il problema dell'isolamento, si potrebbe ripetere l'esperimento con volumi differenti dati da barattoli differenti per verificare sperimentalmete la legge di Boyle sulla dipendenza P-V ad una temperatura fissa.

#let imm_path = "immagini/generico.png"
#figure(
  image(imm_path, width: 10cm),
  caption: [Possibile evoluzione dell'esperienza],
) <fig-gen> 

== 6.2 conclusioni

In conclusione, questa esperienza ha tutte le caratteristiche per poter essere riproposta in un liceo scientifico, e potrebbe essere un ottimo complemento alla teoria sulla legge dei gas perfetti aiutando i ragazzi a comprendere in pieno i fenomeni studiati. Non vedo particolari difficoltà concettuali rispetto a tutto ciò che è contenuto lungamente in questa scheda, tranne forse la questione dell'umidità dell'aria che però può essere facilemnte prevenuta e sistemata.