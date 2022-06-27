clear;close all;
%Qui sopra, vengono inseriti i comandi per ripulire l'area di lavoro

%{
TRACCIA ESERCIZIO D (punto 3):

Picco di risonanza M_r,dB <= 3 dB, banda passante 2 <= w_BW <= 8 rad/sec.

%}

%{
Si vogliono modulare i parametri richiesti per avere una nuova funzione 
di anello in modo tale che essa abbia i valori desiderati. 
Si procedrà in una logia EX-ANTE per poi operare verifiche 
finali. 
Se dopo di ciò le richieste della traccia non sono state rispettate, 
si potranno operare delle modifiche ai valori scelti fino al 
raggiungimento del risultato.
%}

% Definisco la variabile che conterrà la funzione di trasferimento
s=zpk('s');
G=(9*(0.04*s+1)/(s^2+6*s+4));

%Precisione statica
C=4.6/s;


% Si genera la funzione di anello L(s):

L_iniziale=series(C,G);


%{
Si modella il sistema mediante una rete correttrice posta in
cascata alla funzione di anello in modo tale da ottenere un picco di
risonanza inferiore a 3 dB ed una pulsazione di banda passante
compresa fra 2 e 8 rad/sec.
Questo tipo di problema è legato alla precisione dinamica e, per
il momento, ragiono in una logica EX-ANTE, ovvero prima di chiudere
l'anello in retroazione.

Tramite il comando margin, verifico i valori di wc, 
ovvero la pulsazione di attraversamento e della fase che chiamo phi.
%}

figure(1);
margin(L_iniziale);
grid;
legend;


%{
Ottengo un wc = 2.61 rad/s e phi = -4.26° dunque la funzione d'anello 
non è BIBO stabile per il criterio di Bode, 
il quale asserisce che se una funzione di anello presenta guadagno 
statico positivo, diagramma dei moduli monotono decrescente, 
pulsazione di attraversamento unica e margine di fase positivo 
allora è stabile.
In questo caso viene a cadere l'ultima condizione.
Dunque l'algoritmo di controllo dovrà stabilizzare in retroazione 
il sistema oltre che rispettare le specifiche legate alla 
precisione dinamica.

Il picco di risonanza è definito come il massimo assoluto 
del diagramma dei moduli della risposta in frequenza e per essere
minore o uguale a 3 dB bisogna calcolare lo smorzamento critico ovvero 
quel valore che corrisponde proprio ad un picco di 3 dB. 
Lo calcolo grazie alla funzione smorz_Mr.
%}

delta_cr=smorz_Mr(3);

%{
Si ottiene che lo smorzamento critico è delta_cr = 0.3832. 
Se il picco di risonanza aumenta,lo smorzamento diminuisce, poiché 
inversamente proporzionali.


Di conseguenza, sapendo che il margine di fase è all’incirca 100 volte 
il valore dello smorzamento critico, esso sarà pari a circa a 39°.

La pulsazione di attraversamento è un minorante della pulsazione di
banda passante (w_bw > wc).




Si hanno, quindi, due specifiche di progetto da verificare 
successivamente:
1. phi_m >= 39°
2. 2 <= wc <= 8 rad/sec

Si ha un margine di fase di progetto pari a 39° e la pulsazione di
attraversamento di progetto:
%}

wc=2.1;


%{
Per banda passante si intende l'intervallo di pulsazioni in corrispondenza
del quale il modulo della risposta in frequenza è pressocché piatto e 
quindi la fase della risposta in frequenza è nulla.
Procedo ora a calcolare i valori della funzione di anello tenendo in 
considerazione la nuova pulsazione e ottengo così i valori di 
modulo e fase.
%}

[modulo,fase]=bode(L_iniziale,wc);
%modulo = 1.5693
%fase = -177.0622
margine_fase_iniziale=180-abs(fase);
%margine_fase_iniziale= 2.9378

%{
Si ottiene un valore del modulo maggiore di 1 e l'argomento negativo.

Inoltre, si ha che il margine di fase iniziale, pari a 180-abs(argomento), 
sarà 2.9378° ovvero minore del margine di fase richiesto che è 39°.
Poiché picco di risonanza e smorzamento sono inversamente proporzionali,
per mantenerlo al di sotto dei 3 dB allora il margine di fase deve essere 
al di sopra del valore critico e cioè maggiore di 39°. 

Si necessita, dunque, di due effetti combinati:
attenuazione per abbassare il guadagno e
anticipo sulla fase per recuperare i gradi necessari sul margine
di fase.
Il compensatore necessario è la "Rete a Sella".
%}

m=1/modulo;

theta=42-margine_fase_iniziale;

k=15;

% Calcolo alpha, T1 e T2
[alpha,T1,T2] = sella(wc,m,39,k);

% Espressione della rete correttrice a sella
C_lag_lead = ((1 + s*alpha*T1)/ (1*s*T1))* ((1*s*T2) /(1+s*alpha*T2));
L = series(C_lag_lead,L_iniziale);

% Si mostrano, ora, le differenze tra il grafo di partenza e quello
% con la rete correttrice in un grafico.

figure(2);
margin(L_iniziale);
hold on;
margin(L);
legend('L_iniziale','L');


%{
La pulsazione di banda passante è circa 5.19 rad/s, che soddisfa la
richiesta della traccia (tra 2 e 8 rad/s).
Qui di seguito, si verifica che il picco di risonanza sia minore di 3 dB.

Per ogni delta_cr > 0.3832 il picco di risonanza è minore dei 3 dB. 
In particolare in questo caso il delta vale 0.4960 (Pm/100), che è
maggiore del valore precedentemente citato. 

Si procede nel controllare il picco di risonanza con il grafico dei moduli
della retroazione algebrica e unitaria.

Inoltre, la rete a sella ha reso il sistema retroazionato BIBO stabile 
rendendo il margine di fase di L> 0; 
per il criterio di Bode dopo aver sistemato le specifiche 
statiche il sistema retroazionato non era BIBO stabile in quanto 
non soddisfava la condizione che vedeva il margine di fase > O. 
Adesso quella condizione è stata recuperata.

%}

figure(3);
T = feedback(L,1);
bodemag(T);

