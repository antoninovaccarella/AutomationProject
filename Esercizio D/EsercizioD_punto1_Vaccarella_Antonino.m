clear;close all;
%Qui sopra, vengono inseriti i comandi per ripulire l'area di lavoro

% Definisco la variabile che conterrà la funzione di trasferimento
s=zpk('s');
G=(9*(0.04*s+1)/(s^2+6*s+4));

%Precisione statica
C=4.6/s;

% Si genera la funzione di anello L(s):

L_iniziale=series(C,G);

%Diagramma di Bode della funzione di anello

figure(1);
margin(L_iniziale);
grid;
legend;