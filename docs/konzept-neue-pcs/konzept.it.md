---
title: "Concetto per il Miglioramento dell'Ambiente IT dell'IKSDP"
#author: Andreas Roth
date: "2024-08-28"
titlepage: true
fontsize: 11
---

\newpage

## Scopo del Documento

Questo documento ha lo scopo di servire come base per il gruppo di lavoro IKSDP per discutere potenziali miglioramenti delle attrezzature tecniche dell'IKSDP. Mira a fornire una guida riguardo alle opzioni e ai costi associati.

I PC nella sala computer dovrebbero essere sostituiti con dispositivi contemporanei per garantire un funzionamento sicuro per gli utenti. L'hardware PC da acquistare dovrebbe soddisfare i seguenti requisiti:

- Creazione di documenti Office
- Uso di Internet (browser)
- Comunicazione via email
- Riproduzione di video in Full-HD
- Telefonia e conferenze video tramite Zoom, Teams, Jitsi, ecc.

Si presuppone un'acquisizione completamente nuova dei dispositivi. Se ci sono opportunità di ricevere hardware come donazione, questa opzione dovrebbe essere valutata in termini di consumo energetico e prestazioni.

## Situazione Attuale

Durante la mia ultima visita nel 2016, l'IKSDP aveva una piccola sala computer con 6 PC risalenti al 2004 circa. Questi PC avevano Windows XP installato con alcune applicazioni Office. C'era anche un PC di lavoro nell'ufficio amministrativo. Tutti i PC erano connessi a Internet. Microsoft ha terminato il supporto per Windows XP l'8 aprile 2014. Da allora, non ci sono stati aggiornamenti di sicurezza o correzioni di bug. Non è chiaro se fossero installate applicazioni di sicurezza sui PC con Windows XP. Tuttavia, queste potrebbero non funzionare correttamente a causa della mancanza di supporto da parte di Microsoft. Secondo Andreas Siekmann, questa situazione non è cambiata ad oggi. Si sconsiglia vivamente di continuare a utilizzare questi PC in qualsiasi modo.

## Retrospettiva

Durante la nostra visita, diversi studenti e residenti ci hanno chiesto se potevamo procurare hardware per PC. Data la situazione del momento, abbiamo sviluppato l'idea di sostituire i PC obsoleti con Raspberry Pi (Raspi). Il Raspberry Pi è un computer a scheda singola ed è uno dei computer più venduti al mondo. È particolarmente popolare tra hobbisti, istituzioni educative e sviluppatori.

![img/raspi_v3.png](img/raspi_v3.png)

Il basso consumo energetico di soli 4 watt rende il dispositivo particolarmente versatile.

La nostra idea all'epoca era di mostrare agli studenti e agli aspiranti insegnanti come procurarsi hardware relativamente economico (circa 35 USD) per implementare progetti. I Raspberry Pi sono disponibili anche in Kenya. Il prerequisito era che il Raspberry Pi funzionasse con un sistema operativo Linux, poiché non c'era Windows per la piattaforma hardware ARM su cui si basa il Raspberry Pi.

Nei nostri test, abbiamo scoperto che l'utilizzo di una postazione di lavoro per ufficio su un Raspberry Pi 3 è fondamentalmente possibile, ma raggiunge rapidamente i suoi limiti a causa della bassa memoria (1 GB di RAM). Il computer diventava molto lento non appena un browser Internet veniva aperto in parallelo con un programma di posta elettronica o un'applicazione per ufficio.

Nel giugno 2019 è stato rilasciato il successore, il Raspberry Pi 4. Questa versione è disponibile con fino a 8 GB di RAM e una CPU significativamente più potente, anche se a un prezzo più alto (~100 USD). I nostri test nel 2020 hanno mostrato che una postazione di lavoro per ufficio può essere gestita bene con questo dispositivo sotto Linux. Tuttavia, le videochiamate tramite Zoom o Microsoft Teams con webcam non sono possibili in modo ottimale, poiché il software dei produttori non supportava l'accelerazione hardware video. Tuttavia, dalla pandemia di Corona, consideriamo la possibilità di telefonia video assolutamente necessaria.

## Hardware PC

Nel settembre 2023 è stato rilasciato il Raspberry Pi 5, che ha una CPU circa quattro volte più veloce. Tuttavia, non è stato ancora verificato se questo hardware sia ora sufficiente per le videochiamate. Il consumo energetico è aumentato a poco meno di 10 watt. Il prezzo per la versione da 8 GB è attualmente di circa 100 USD, più i costi per scheda SD, custodia e alimentatore, portando il prezzo totale a circa 150 USD.

All'inizio del 2023, Intel ha portato sul mercato la piattaforma N100, sviluppata specificamente per applicazioni a basso consumo energetico come mini-PC e laptop a basso costo. A differenza del Raspberry Pi, questa piattaforma si basa sull'architettura X86 ed è quindi compatibile con i PC convenzionali. Ciò renderebbe possibile l'installazione di un sistema operativo Windows "normale", il che migliora significativamente la compatibilità.

### Intel N100 

Il consumo energetico della piattaforma Intel N100 è di circa 8 watt in idle (la maggior parte del tempo) e sale fino a 25 watt sotto pieno carico (raramente). Sebbene questo consumo sia superiore al Raspberry Pi, è comunque significativamente inferiore ai PC per ufficio convenzionali, che consumano circa 50 watt. La piattaforma N100 è circa il 40% più veloce di un Raspberry Pi 5 e dovrebbe essere in grado di soddisfare tutti i requisiti senza problemi. L'N100 ha 4 core CPU con una frequenza di clock fino a 3,4 GHz.

Vari produttori integrano questa piattaforma nei loro dispositivi. Ecco alcuni esempi:

**Aoostar T box n100**

Hardware: CPU: N100, RAM 8/16GB, 256GB SSD
CPUMark: 5500
Link: https://aoostar.com/products/aoostar-t-box-intel-n100-metal-case-mini-pc4c-4t-with-w11-home-8-16gb-ram-256-512gb-ssd

Prezzo: 137 EUR.

![Aoostar T box](img/aoostar-t-box1.png){ width=300px } 
`<img src="images/syslog-ng-mergerequest.png" alt="Test Pipeline" style="border: 2px solid black" align="left">`{=html}

**Bosgame mini pc**

Hardware: CPU: N100, RAM 16GB, 512GB SSD
CPUMark: 5500
Link: https://www.bosgamepc.com/products/bosgame-mini-pc-b100-intel-12th-gen-alder-lake--n100-16gb-ddr4-ram-512gb-ssd

Prezzo: 152 EUR

### AMD Lucienne

Il concorrente AMD offre le CPU Lucienne come prodotto rivale all'Intel N100. Questi processori sono dotati di 8 core e raggiungono velocità di clock fino a 4,3 GHz, rendendoli significativamente più potenti. Hanno anche un chip grafico integrato che fornisce prestazioni sufficienti per giochi semplici. Tuttavia, queste CPU sono anche più costose e hanno un consumo energetico leggermente superiore. Un esempio di prodotto con questa CPU è:

**Aoostar MN57**

Hardware: CPU: AMD Ryzen 7 5700U, RAM 16GB, 256 SSD
CPUMark: 15000
Link: https://www.bosgamepc.com/products/bosgame-mini-pc-b100-intel-12th-gen-alder-lake--n100-16gb-ddr4-ram-512gb-ssd

Prezzo: 279 EUR

Tutti i prodotti provengono da fornitori cinesi che spediscono direttamente dalla Cina. Aoostar offre la spedizione in Kenya senza costi aggiuntivi. Tuttavia, dovrebbe essere verificato quali dazi doganali potrebbero essere sostenuti in Kenya. Deve anche essere chiarito se una conferma d'ordine da un negozio online è sufficiente per lo sponsor del progetto.

### Monitor

La nostra ricerca su Internet ha mostrato che i monitor TFT tendono ad essere più costosi e meno disponibili in Kenya.

Ecco alcuni esempi:

https://www.mombasacomputers.com/product/dell-p2018h-20-led-backlit-lcd-1600x900-hd-monitor/
Prezzo: 18000KES - 126 EUR + IVA

https://devicestech.co.ke/product/22inch-edge-to-edge-monitorex-uk/
Prezzo: 14500KES - 100 EUR + IVA

Forse un contatto a Nairobi potrebbe verificare i prezzi dei monitor in un centro commerciale sul posto, poiché questi dispositivi probabilmente sono meglio acquistati direttamente sul posto. Potrebbe anche avere senso acquistare i dispositivi online e conservarli presso una persona di fiducia a Nairobi.

### Valutazione e Costi

Attualmente consigliamo un mini-PC basato sull'Intel N100. Questo offre prestazioni sufficienti per soddisfare i requisiti dell'IKSDP e rappresenta un buon compromesso tra costo e prestazioni.

Per l'hardware di una postazione di lavoro PC, si dovrebbe prevedere circa 250-300 USD. Oltre al PC, dovrebbero essere acquistate semplici cuffie USB per poter riprodurre e registrare l'audio. Devono essere acquistati anche nuovi tastiere e mouse con connessione USB. Dovrebbero essere pianificate anche webcam (circa 50 USD) per alcuni dei PC.

| **Componente** |  **Prezzo**   |
|------------|----------|
| PC N100    |  170 EUR |
| TFT        |  120 EUR |
| Accessori  |  30  EUR |
|------------|----------|
| Totale     |  320 EUR |

## Internet

Non siamo stati in grado di determinare se ci sono fornitori di Internet che possono fornire Internet tramite cavo telefonico o dati in questa località.

Pertanto, ci siamo concentrati su soluzioni mobili.

### Starlink

Starlink è un servizio Internet satellitare di SpaceX che fornisce connettività Internet globale, in particolare per aree remote o poco servite. Utilizzando una rete di migliaia di satelliti in orbita terrestre bassa, Starlink consente una connessione Internet veloce e affidabile con bassa latenza. Il prodotto è rivolto sia a individui che a imprese ed è particolarmente utile in regioni dove le infrastrutture Internet convenzionali sono difficili da accedere.

In Germania, Starlink offre prestazioni paragonabili a connessioni VDSL di 200 Mbps. Attualmente non abbiamo rapporti di esperienza dal Kenya.

Secondo il sito web, l'accesso a Internet tramite Starlink è disponibile a Nyandiwa dall'inizio del 2024.

![Starlink](img/starlink_bestellen.png)

L'hardware richiesto può essere acquistato o noleggiato. Il noleggio mensile è di 1950 KES (14 EUR), e la tassa di attivazione una tantum è di 2700 KES (18 EUR).

Se si sceglie di acquistare invece di noleggiare, si pagheranno 45.500 KES (322 EUR) per l'antenna satellitare, 5700 KES per l'adattatore Ethernet e 13.300 KES per un supporto.

Per la tariffa Internet, si può scegliere tra una tariffa basata sul volume (50 GB per 1300 KES/9 EUR) e una tariffa flat per 6500 KES (46 EUR). Se si supera il volume di dati di 50 GB sulla tariffa basata sul volume, verranno addebitati 20 KES per GB aggiuntivo. Da un consumo mensile di dati di 250 GB, la tariffa flat sarebbe quindi conveniente.

### Internet Mobile

È stato molto difficile ottenere dati di copertura validi per la località di Nyandiwa. Secondo https://nperf.com, l'Internet mobile è disponibile solo attraverso il fornitore Airtel Mobile. Tuttavia, la cella termina direttamente a Nyandiwa. È discutibile se l'IKSDP abbia effettivamente ricezione.

![Copertura di Rete](img/network_coverage_nyandiwa.png)

| **Pacchetto** | **Prezzo (KES)**	 |
| -------|---------------|
| Piano 5G Illimitato 10Mbps |	3500KES/25 EUR |
| Piano 5G Illimitato 20Mbps |	5000KES/36 EUR |
| Piano 5G Illimitato 30Mbps |	6500KES/35 EUR |

Inoltre, si incorre in costi per un modem 5G/4G. Un modem 4G con portata migliorata specialmente, come il Mikrotik LHG LTE18 Kit (vedi https://mikrotik.com/product/lhg_lte18), è disponibile per circa 250 EUR. L'hardware 5G, che potrebbe non essere completamente utilizzato nel prossimo futuro, costa circa 550 EUR.

### Valutazione e Costi

Attualmente consigliamo l'accesso a Internet tramite Starlink, poiché la qualità dell'Internet mobile è difficile da prevedere. Suggeriremmo la variante più piccola con hardware noleggiato e una tariffa da 50 GB. Se risulta che sono necessari più dati, dovrebbe essere passato alla tariffa flat.

Costi mensili (noleggio):

| **Componente**                     | **Prezzo**             |
| ------------------------------| ------------------|
| Hardware Starlink             | 1950 KES (14 EUR) |
| Tariffa Internet Starlink (50GB) | 1300 KES (9 EUR)  |
| opzionale 50GB*                | 1000 KES (7 EUR)  |
| ------------------------------| ------------------|
| Totale                         | 4250 KES (30 EUR) |

+ tassa di attivazione una tantum 2700 KES

## Rete (WLAN)

Raccomandiamo l'hardware del produttore europeo di attrezzature di rete Mikrotik, con sede a Riga, Lettonia. Sebbene Mikrotik sia relativamente sconosciuto in Europa, l'azienda è molto popolare in Sud America, Europa dell'Est, Asia e Africa. Mikrotik si distingue per la sua gamma estremamente completa di funzioni in hardware e software, che spesso si trova solo in soluzioni aziendali di produttori come Cisco. Allo stesso tempo, i costi dell'hardware sono molto bassi in confronto. Un altro vantaggio: Mikrotik non ha ancora tolto alcun dispositivo dalla manutenzione. Anche i dispositivi prodotti nel 1997 ricevono ancora un sistema operativo router aggiornato.

L'hardware può essere acquistato in Kenya, e ci sono sia partner che consulenti sul posto che possono fornire supporto se necessario.

![Partner Mikrotik](img/mikrotik-distributors.png)
![Consulenti Mikrotik](img/mikrotik-consultants.png)

Per la connessione in rete dei computer, potremmo utilizzare i seguenti prodotti:

https://mikrotik.com/product/hex_s 80EUR
https://mikrotik.com/product/l009uigs_2haxd_in 	120EUR

Questi dispositivi sono anche adatti per configurare l'accesso remoto per il supporto.

Per fornire copertura WLAN ai locali, sarebbero adatti punti di accesso esterni come il Mikrotik mANTBox ax 15s https://mikrotik.com/product/mantbox_ax_15s (circa 180 EUR). Il dispositivo copre un angolo di circa 180 gradi. A seconda del posizionamento, potrebbero essere necessari due dispositivi per garantire una copertura completa.

| **Componente**                     | **Prezzo**             |
| ------------------------------| ------------------|
| Mikrotik HexS                 | 80 EUR            |
| L009UiGS-2HaxD-IN             | 120 EUR           |
| Punto di Accesso mANTBox ax 15s | 180 EUR (circa 2) |
| Accessori (cavi, alimentatore)| 50 EUR            |
| ------------------------------| ------------------|
| Totale                        | 430 EUR / 610 EUR |