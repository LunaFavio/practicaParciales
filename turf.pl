/*
Turf!
Nos encargaron el diseño de una aplicación para modelar carreras de caballo en hipódromos (todo totalmente legal). 
A continuación dejamos los primeros requerimientos, sabiendo que nuestra intención es aplicar los conocimientos 
del paradigma lógico.

Punto 1: Pasos al costado (2 puntos)
Les jockeys son personas que montan el caballo en la carrera: 
tenemos a Valdivieso, que mide 155 cms y pesa 52 kilos,
Leguisamo, que mide 161 cms y pesa 49 kilos, 
Lezcano, que mide 149 cms y pesa 50 kilos, 
Baratucci, que mide 153 cms y pesa 55 kilos, 
Falero, que mide 157 cms y pesa 52 kilos.

También tenemos a los caballos: Botafogo, Old Man, Enérgica, Mat Boy y Yatasto, entre otros. 
Cada caballo tiene sus preferencias:
a Botafogo le gusta que le jockey pese menos de 52 kilos o que sea Baratucci
a Old Man le gusta que le jockey sea alguna persona de muchas letras (más de 7), existe el predicado atom_length/2
a Enérgica le gustan todes les jockeys que no le gusten a Botafogo
a Mat Boy le gusta les jockeys que midan mas de 170 cms
a Yatasto no le gusta ningún jockey

También sabemos el Stud o la caballeriza al que representa cada jockey
Valdivieso y Falero son del stud El Tute
Lezcano representa a Las Hormigas
Y Baratucci y Leguisamo a El Charabón

Por otra parte, sabemos que Botafogo ganó el Gran Premio Nacional y el Gran Premio República, 
Old Man ganó el Gran Premio República y el Campeonato Palermo de Oro y Enérgica y Yatasto no ganaron ningún campeonato. 
Mat Boy ganó el Gran Premio Criadores.

Modelar estos hechos en la base de conocimientos e indicar en caso de ser necesario si algún 
concepto interviene a la hora de hacer dicho diseño justificando su decisión.

*/

jockey(valdivieso,155,52).
jockey(leguisamo,161,49).
jockey(lezcano,149,50).
jockey(baratucci,153,55).
jockey(falero,157,52).

caballo(botafogo).
caballo(oldMan).
caballo(energica).
caballo(matBoy).
caballo(yatasto).

prefiere(botafogo,Jockey):-
    jockey(Jockey, _, Peso),
    Peso < 52.

prefiere(botafogo,baratucci).

prefiere(oldMan,Jockey):-
    jockey(Jockey,_,_),
    atom_length(Jockey, Cantidad),
    Cantidad > 7.

prefiere(energica,Jockey):-
    jockey(Jockey,_,_),
    not(prefiere(botafogo,Jockey)).

prefiere(matBoy,Jockey):-
    jockey(Jockey,Altura,_),
    Altura > 170.

stud(elTute).
stud(lasHormigas).
stud(elCharabon).

representa(valdivieso,elTute).
representa(falero,elTute).
representa(lezcano,lasHormigas).
representa(baratucci,elCharabon).
representa(leguisamo,elCharabon).

gano(botafogo,granPremioNacional).
gano(botafogo,granPremioRepublica).
gano(oldMan,granPremioRepublica).
gano(oldMan,campeonatoPalermoDeOro).
gano(matBoy,granPremioCriadores).

/*
Punto 2: Para mí, para vos (2 puntos)
Queremos saber quiénes son los caballos que prefieren a más de un jockey. 
Ej: Botafogo, Old Man y Enérgica son caballos que cumplen esta condición según la base de conocimiento planteada. 
El predicado debe ser inversible.
*/

prefiereMasDeUnJockey(Caballo):-
    distinct(Caballo,(
        prefiere(Caballo,Jockey),
        prefiere(Caballo,Jockey2),
        Jockey \= Jockey2)).


prefiereMasDeUnJockey2(Caballo):-
    caballo(Caballo),
    findall(Jockey,prefiere(Caballo,Jockey), Jockeys),
    length(Jockeys, Cantidad),
    Cantidad > 1.

/*
Punto 3: No se llama Amor (2 puntos)
Queremos saber quiénes son los caballos que no prefieren a ningún jockey de una caballeriza. 
El predicado debe ser inversible. 
Ej: 
Botafogo aborrece a El Tute (porque no prefiere a Valdivieso ni a Falero), 
Old Man aborrece a Las Hormigas y Mat Boy aborrece a todos los studs, entre otros ejemplos.
*/

noSeLlamaAmor(Caballo,Stud):-
    caballo(Caballo),
    stud(Stud), 
    forall(representa(Jockey,Stud),not(prefiere(Caballo,Jockey))).


/*
Punto 4: Piolines (2 puntos)
Queremos saber quiénes son les jockeys "piolines", que son las personas preferidas por todos los caballos
que ganaron un premio importante. El Gran Premio Nacional y el Gran Premio República son premios importantes.

Por ejemplo, Leguisamo y Baratucci son piolines, no así Lezcano que es preferida 
por Botafogo pero no por Old Man. El predicado debe ser inversible.
*/

importante(granPremioNacional).
importante(granPremioRepublica).

piolines(Jockey):-
    jockey(Jockey,_,_),
    forall(ganoImportante(Caballo),prefiere(Caballo,Jockey)).

ganoImportante(Caballo):-
    distinct(Caballo,(
        gano(Caballo,Premio),
        importante(Premio))).

/*
Punto 5: El jugador (2 puntos)
Existen apuestas
a ganador por un caballo => gana si el caballo resulta ganador
a segundo por un caballo => gana si el caballo sale primero o segundo
exacta => apuesta por dos caballos, y gana si el primer caballo sale primero y el segundo caballo sale segundo
imperfecta => apuesta por dos caballos y gana si los caballos terminan primero y segundo sin importar el orden

Queremos saber, dada una apuesta y el resultado de una carrera de caballos si la apuesta resultó ganadora. 
No es necesario que el predicado sea inversible.

*/

apuesta(ganador,Caballos).
apuesta(segundo,Caballos).
apuesta(exacta,Caballos).
apuesta(imperfecta,Caballos).

ganoLaApuesta(Apuesta,Resultado):-
    resultado(Apuesta,Resultado).

resultado(apuesta(ganador,[Caballo]),Resultado):-
    nth1(1,Resultado,Caballo).

resultado(apuesta(segundo,[Caballo]),Resultado):-
    nth1(1,Resultado,Caballo).

resultado(apuesta(segundo,[Caballo]),Resultado):-
    nth1(2,Resultado,Caballo).

resultado(apuesta(exacta,[Caballo,Caballo2]),Resultado):-
    nth1(1,Resultado,Caballo),
    nth1(2,Resultado,Caballo2).
/*
resultado(apuesta(imperfecta,[Caballo,Caballo2]),Resultado):-
    nth1(1,Resultado,Caballo),
    nth1(2,Resultado,Caballo2).

resultado(apuesta(imperfecta,[Caballo,Caballo2]),Resultado):-
    nth1(2,Resultado,Caballo),
    nth1(1,Resultado,Caballo2).
*/
resultado(apuesta(imperfecta,[Caballo,Caballo2]),[Primer,Segundo|_]):-
    permutation([Caballo,Caballo2], [Primer,Segundo]).


/*
Sabiendo que cada caballo tiene un color de crin:
Botafogo es tordo (negro)
Old Man es alazán (marrón)
Enérgica es ratonero (gris y negro)
Mat Boy es palomino (marrón y blanco)
Yatasto es pinto (blanco y marrón)
Queremos saber qué caballos podría comprar una persona que tiene preferencia por caballos de un color específico. 
Tiene que poder comprar por lo menos un caballo para que la solución sea válida. 
Ojo: no perder información que se da en el enunciado.

Por ejemplo: 
una persona que quiere comprar caballos marrones podría comprar a Old Man, Mat Boy y Yatasto. 
O a Old Man y Mat Boy. O a Old Man y Yatasto. O a Old Man. O a Mat Boy y Yatasto. O a Mat Boy. O a Yatasto.
NOTA
12 = 10 | 11 a 10 = 9 | 9 = 8 | 8 = 7 | 7 = 6 | 6 a 7 = Revisión | menos de 5 = desaprobado
*/

crin(botafogo,tordo).
crin(oldMan,alazan).
crin(energica,ratonero).
crin(matBoy,palomino).
crin(yatasto,pinto).

color(tordo,negro).
color(alazan,marron).
color(ratonero,gris).
color(ratonero,negro).
color(palomino,marron).
color(palomino,blanco).
color(pinto,blanco).
color(pinto,marron).
 
puedeComprar(Color,CaballosPosibles):-
    caballo(Caballo),
    findall(Caballo,(crin(Caballo,Crin), color(Crin,Color)), CaballosDisponibles),
    subconjunto(CaballosDisponibles,CaballosPosibles),
    CaballosPosibles \= [].

subconjunto(_, []).
subconjunto([H|T], [H|Resto]):-
  subconjunto(T, Resto).
subconjunto([H|T], Resto):-
  subconjunto(T, Resto).