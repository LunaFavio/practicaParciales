/*
“La siguiente obra del presente recital ilustra un periodo poco conocido de la juventud 
de Johann Sebastian Mastroprolog. Todo empezó cuando un conocido crítico se resfrió...”

Nos acercamos a los últimos shows de Los Honguitos... ya no pueden estar todos los integrantes 
por diferentes razones. Aún así, queremos armar propuestas entretenidas entre los conocidos 
sketches que se hicieron durante sus largos años de trayectoria. Para realizar cada sketch se 
requieren distintos roles, ya sean musicales o teatrales. Y, para ello, tenemos estos datos en 
nuestra base de conocimiento y precisamos generar ciertas relaciones que nos permitan presentar 
shows completos.

puedeCumplir(Persona, Rol): relaciona una persona con un rol que puede cumplir
*/

puedeCumplir(jorge, instrumentista(guitarra)).
puedeCumplir(jorge, actor(canto)).
puedeCumplir(jorge, instrumentista(bolarmonio)).

puedeCumplir(daniel, instrumentista(guitarra)).
puedeCumplir(daniel, actor(narrador)).
puedeCumplir(daniel, instrumentista(tuba)).
puedeCumplir(daniel, actor(paciente)).
puedeCumplir(daniel, instrumentista(percusion)).
puedeCumplir(daniel, actor(canto)).

puedeCumplir(marcos, actor(narrador)).
puedeCumplir(marcos, actor(psicologo)).
puedeCumplir(marcos, instrumentista(percusion)).
puedeCumplir(marcos, actor(canto)).

puedeCumplir(carlos, instrumentista(violin)).
puedeCumplir(carlos, actor(canto)).

puedeCumplir(carlitos, instrumentista(piano)).
puedeCumplir(carlitos, actor(canto)).



%necesita(Sketch, Rol): relaciona un sketch con un rol necesario para interpretarlo.

necesita(payadaDeLaVaca, instrumentista(guitarra)).
necesita(malPuntuado, actor(narrador)).
necesita(laBellaYGraciosaMozaMarchoseALavarLaRopa, actor(canto)).
necesita(laBellaYGraciosaMozaMarchoseALavarLaRopa, instrumentista(violin)).
necesita(laBellaYGraciosaMozaMarchoseALavarLaRopa, instrumentista(tuba)).
necesita(lutherapia, actor(paciente)).
necesita(lutherapia, actor(psicologo)).
necesita(cantataDelAdelantadoDonRodrigoDiazDeCarreras, actor(narrador)).
necesita(cantataDelAdelantadoDonRodrigoDiazDeCarreras, instrumentista(percusion)).
necesita(cantataDelAdelantadoDonRodrigoDiazDeCarreras, actor(canto)).
necesita(rhapsodyInBalls, instrumentista(bolarmonio)).
necesita(rhapsodyInBalls, instrumentista(piano)).

%duracion(Sketch, Duracion):. relaciona un sketch con la duración 
%(aproximada, pero la vamos a tomar como fija) que se necesita para interpretarlo.

duracion(payadaDeLaVaca, 9).
duracion(malPuntuado, 6).
duracion(laBellaYGraciosaMozaMarchoseALavarLaRopa, 8).
duracion(lutherapia, 15).
duracion(cantataDelAdelantadoDonRodrigoDiazDeCarreras, 17).
duracion(rhapsodyInBalls, 7).

/*1)
Necesitamos programar interprete/2, que relacione a una persona con un sketch en el que puede participar. 
Inversible.
*/

interprete(Persona,Sketch):-
    puedeCumplir(Persona, Rol),
    necesita(Sketch, Rol).

/*2)
Se precisa la relación duracionTotal/2, que relacione una lista de sketches 
con la duración total que tomaría realizarlos a todos. 
Inversible para la duración.
*/

duracionTotal(Lista,Duracion):-
    maplist(duracion,Lista,ListaDuraciones),
    sum_list(ListaDuraciones, Duracion).

duracionTotal2(Lista,Duracion):-
    findall(Tiempo, (member(Sketch, Lista), duracion(Sketch, Tiempo)), Duraciones),
    sum_list(Duraciones, Duracion).

/*3)
Saber si un sketch puede ser interpretado por un conjunto de intérpretes. 
Esto sucede cuando en ese conjunto disponemos de intérpretes que cubren todos 
los roles necesarios para el mencionado sketch.
Inversible para el sketch.
*/

puedeSerInterpretadoPor(Sketch, Interpretes):-
    duracion(Sketch,_),
    forall(necesita(Sketch,Rol),(member(Persona, Interpretes),puedeCumplir(Persona,Rol))).

/*4)
Hacer generarShow/3 que relacione: 
a)Un conjunto de posibles intérpretes.
b)Una duración máxima del show.
c)Una lista de sketches no vacía (un show), que deben poder ser interpretados 
por los intérpretes y durar menos que la duración máxima.

Inversible para el show.
*/

generarShow(Interpretes,DuracionMax,Show):-
    sketchsPosibles(Interpretes, Sketchs),
    subconjunto(Sketchs, Show),
    Show \= [],
    duracionTotal(Show,Duracion),
    Duracion < DuracionMax.

sketchsPosibles(Interpretes,Sketchs):-
    findall(Sketch,puedeSerInterpretadoPor(Sketch, Interpretes), Sketchs).

subconjunto(_, []).
subconjunto(Conjunto, [Elemento | Subconjunto]):-
    select(Elemento, Conjunto, Resto),
    subconjunto(Resto, Subconjunto).

/*5)
Los shows, muchas veces tienen algún participante estrella; que es aquel que puede 
participar en todos los sketchs que componen dicho show. Implementar un predicado 
que relacione a un show con un participante estrella.

Inversible para la estrella
*/

estrella(Show,Estrella):-
    persona(Estrella),
    forall(member(Sketch,Show), interprete(Estrella,Sketch)).

persona(Persona):-
    distinct(Persona,puedeCumplir(Persona,_)).

/*6)
Para hacer mejor el marketing, queremos saber si un show:
a) Es puramenteMusical/1. Esto sucede cuando en todos los sketches, 
sólo se precisan roles de instrumentista.

b) Tiene todosCortitos/1. Esto sucede cuando todos los sketches del 
show duran menos de 10 minutos.

c) Los juntaATodos/1. Este evento especial solo pasa si la única manera de 
que el show suceda es que tengan que participar todos los intérpretes que conocemos.

No necesitan ser inversibles
*/

% a
puramenteMusical(Show):-
    forall(member(Sketch,Show),esMusical(Sketch)).

esMusical(Sketch):-
    forall(necesita(Sketch, Rol), Rol = instrumentista(_)).

% b
todosCortitos(Show):-
    forall(member(Sketch,Show),esCorto(Sketch)).

esCorto(Sketch):-
    duracion(Sketch,Tiempo), 
    Tiempo < 10.

% c
juntaATodos(Show):-
    forall(persona(Interprete),participaEnShow(Interprete,Show)).

participaEnShow(Interprete, Show):-
    member(Sketch, Show),
    interprete(Interprete,Sketch).

juntoATodos2(Show):-
    findall(Interprete, persona(Interprete), InterpretesConocidos),
    length(InterpretesConocidos, Cantidad),
    findall(InterpreteNecesario, (member(Sketch,Show), interprete(InterpreteNecesario,Sketch)), InterpretesNecesarios),
    list_to_set(InterpretesNecesarios, InterpretesNecSinRepe),
    length(InterpretesNecSinRepe, Necesarios),
    Necesarios = Cantidad.

esNecesario(Interprete, Show):-
    member(Sketch, Show),
    necesita(Sketch, Rol),
    puedeCumplir(Interprete, Rol),
    not((puedeCumplir(OtroInterprete, Rol), Interprete \= OtroInterprete)).