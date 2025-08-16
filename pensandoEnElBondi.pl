/*
¡Pensando en el Bondi!

En todo el mundo se dice que el perro es el mejor amigo del hombre. Sin embargo, para nosotros en Argentina,
en ciertas ocasiones, podríamos decir que el bondi es nuestro mejor amigo.

Por eso la empresa PdePasajeros, nos contrató para construir un modelo de sus flotas dentro del sistema Prolog

Cada línea de colectivo tiene su propio recorrido dentro del GBA (Gran Buenos Aires) o 
CABA (Ciudad Autónoma de Buenos Aires). El GBA se organiza en distintas zonas: sur, norte, oeste y este, 
donde cada línea se adapta a estas divisiones en su trayecto.

*/

/*
Base de conocimientos

Tenemos como punto de partida un predicado recorrido/3 que relaciona una línea con la información de su 
recorrido, especificando el área por la que pasa y la calle que atraviesa.

Ejemplo de la base de conocimiento:
*/

% Recorridos en GBA:
recorrido(17, gba(sur), mitre).
recorrido(24, gba(sur), belgrano).
recorrido(247, gba(sur), onsari).
recorrido(60, gba(norte), maipu).
recorrido(152, gba(norte), olivos).


% Recorridos en CABA:
recorrido(17, caba, santaFe).
recorrido(152, caba, santaFe).
recorrido(10, caba, santaFe).
recorrido(160, caba, medrano).
recorrido(24, caba, corrientes).


/*
1)
Saber si dos líneas pueden combinarse, que se cumple cuando su recorrido 
pasa por una misma calle dentro de la misma zona.
*/

puedenCombinarse(Linea,Linea2):-
    recorrido(Linea, Zona, Calle),
    recorrido(Linea2, Zona, Calle),
    Linea \= Linea2.

/*
2)
Conocer cuál es la jurisdicción de una línea, que puede ser o bien nacional, 
que se cumple cuando la misma cruza la General Paz,  o bien provincial, cuando no la cruza. 
Cuando la jurisdicción es provincial nos interesa conocer de qué provincia se trata, si es 
de buenosAires (cualquier parte de GBA se considera de esta provincia) o si es de caba.

Se considera que una línea cruza la General Paz cuando parte de su recorrido pasa por una calle 
de CABA y otra parte por una calle del Gran Buenos Aires (sin importar de qué zona se trate).
*/

linea(Linea):-
    distinct(Linea,recorrido(Linea,_,_)).

area(Area):-
    distinct(Area,recorrido(_,Area,_)).

jurisdiccion(Linea, nacional):-
    cruzaGralPaz(Linea).

jurisdiccion(Linea,provincial(Provincia)):-
    linea(Linea),
    not(cruzaGralPaz(Linea)),
    recorrido(Linea, Area,_),
    esProvincial(Area,Provincia).

esProvincial(caba, caba).
esProvincial(gba(_), buenosAires).

%V2
jurisdiccionProvincial(Linea, Provincia):-
    linea(Linea),
    area(Provincia),
    not(cruzaGralPaz(Linea)),
    findall(Area, recorrido(Linea,Area,_), Areas),
    member(Provincia, Areas).
    
jurisdiccionNacional(Linea):-
    cruzaGralPaz(Linea).

cruzaGralPaz(Linea):-
    recorrido(Linea,Zona,_),
    recorrido(Linea,Zona2,_),
    Zona \= Zona2.

/*
3)
Saber cuál es la calle más transitada de una zona, que es por la que pasen mayor cantidad de líneas.
*/

lineasPorCalle(Zona,Calle,Cantidad):-
    recorrido(_,Zona,Calle),
    findall(Linea, recorrido(Linea,Zona,Calle), Lineas),
    length(Lineas, Cantidad).    

masTransitada(Calle,Zona):-
    recorrido(_,Zona,Calle),
    forall(lineasPorCalle(Zona,Calle,Cantidad),(lineasPorCalle(Zona,OtraCalle,OtraCantidad),OtraCalle \= Calle,Cantidad>OtraCantidad)).

%V2
masTransitada2(Calle,Zona):-
    lineasPorCalle(Zona,Calle,Cantidad),
    forall((recorrido(_,Zona,OtraCalle), OtraCalle \= Calle),(lineasPorCalle(Zona,OtraCalle,OtraCantidad),Cantidad>OtraCantidad)).


/*
4)
Saber cuáles son las calles de transbordos en una zona, que son aquellas por las que pasan al 
menos 3 líneas de colectivos, y todas son de jurisdicción nacional.
*/

deTransbordo(Calles,Zona):-
    recorrido(_,Zona,Calle),
    soloNacionales(Calle,Zona),
    findall(Calle,(lineasPorCalle(Zona,Calle,Cantidad), Cantidad >=3), CallesConRepe),
    list_to_set(CallesConRepe, Calles).

soloNacionales(Calle,Zona):-
    forall(recorrido(Linea,Zona,Calle), jurisdiccion(Linea, nacional)).

%V2

deTransbordo2(Calle,Zona):-
    distinct(Calle,recorrido(_,Zona,Calle)),
    forall(recorrido(Linea,Zona,Calle), jurisdiccion(Linea, nacional)),
    lineasPorCalle(Calle,Zona,Cantidad), 
    Cantidad >=3.

/*
5)
Necesitamos incorporar a la base de conocimientos cuáles son los beneficios que las personas 
tienen asociadas a sus tarjetas registradas en el sistema SUBE. Dichos beneficios pueden ser 
cualquiera de los siguientes:

Estudiantil: el boleto tiene un costo fijo de $50.

Personal de casas particulares: nos interesará registrar para este beneficio cuál es la 
zona en la que se encuentra el domicilio laboral. Si la línea que se toma la persona con 
este beneficio pasa por dicha zona, se subsidia el valor total del boleto, por lo que no tiene costo.

Jubilado: el boleto cuesta la mitad de su valor.

	Sabemos que:
Pepito tiene el beneficio de personal de casas particulares dentro de la zona oeste del GBA.

Juanita tiene el beneficio del boleto estudiantil.

Tito no tiene ningún beneficio.

Marta tiene beneficio de jubilada y también de personal de casas particulares dentro de CABA y 
en zona sur del GBA.

beneficio(Tipo, Linea,Costo).
*/

%a
beneficio(estudiantil).
beneficio(personalCasaParticular(Zona)).
beneficio(jubilado).

beneficiario(pepito,personalCasaParticular(gba(oeste))).
beneficiario(juanita,estudiantil).
beneficiario(marta,jubilado).
beneficiario(marta,personalCasaParticular(gba(sur))).
beneficiario(marta,personalCasaParticular(caba)).

persona(pepito).
persona(juanita).
persona(tito).
persona(marta).

valorBoleto(Linea,500):-
    jurisdiccion(Linea, nacional).

valorBoleto(Linea,350):-
    jurisdiccion(Linea,provincial(caba)).

valorBoleto(Linea,Costo):-
    jurisdiccion(Linea,provincial(buenosAires)),
    precioPorCalles(Linea,Precio),
    plus(Linea,Plus),
    Costo is Plus + Precio.

precioPorCalles(Linea,Precio):-
    findall(Calle, recorrido(Linea,_,Calle), Calles),
    length(Calles, Cantidad),
    Precio is Cantidad * 25.

plus(Linea,50):-
    pasaPorDiferentesZonas(Linea).

plus(Linea,0):-
    not(pasaPorDiferentesZonas(Linea)).

pasaPorDiferentesZonas(Linea):-
    recorrido(Linea,Zona,_),
    recorrido(Linea,OtraZona,_),
    Zona \= OtraZona.


costoDelViaje(Persona,Linea,Costo):-
    persona(Persona),
    not(beneficiario(Persona,_)),
    recorrido(Linea,_,_),
    valorBoleto(Linea,Costo),
    costoDelViaje(Persona, Linea, Costo).

costoDelViaje(Persona,Linea,PrecioFinal):-
    beneficiario(Persona,_),
    recorrido(Linea,_,_),
    findall(Costo, (beneficiario(Persona,Beneficio), valorFinal(Beneficio,Linea,Costo)), Costos),
    min_member(PrecioFinal, Costos).
    
valorFinal(jubilado,Linea,Costo):-
    distinct(Precio,valorBoleto(Linea,Precio)),
    Costo is Precio / 2.

valorFinal(personalCasaParticular(Zona),Linea,0):-
    recorrido(Linea,Zona,_).

valorFinal(estudiantil,_,50).

/*
%% Punto 5

pasaPorDistintasZonas(Linea):-
    recorrido(Linea, gba(Zona), _),
    recorrido(Linea, gba(OtraZona), _),
    Zona \= OtraZona.

plus(Linea, 50):-
    pasaPorDistintasZonas(Linea).
plus(Linea, 0):-
    not(pasaPorDistintasZonas(Linea)).

valorNormal(Linea, 500):-
    jurisdiccion(Linea, nacional).
valorNormal(Linea, 350):-
    jurisdiccion(Linea, provincial(caba)).
valorNormal(Linea, Valor):-
    jurisdiccion(Linea, provincial(buenosAires)),
    findall(Calle, recorrido(Linea, Calle, _), Calles),
    length(Calles, CantidadCalles),
    plus(Linea, Plus),
    Valor is (25*CantidadCalles) + Plus.

beneficiario(pepito, personalCasaParticular(gba(oeste))).
beneficiario(juanita, estudiantil).
beneficiario(marta, jubilado).
beneficiario(marta, personalCasaParticular(caba)).
beneficiario(marta, personalCasaParticular(gba(sur))).

beneficio(estudiantil, _, 50).
beneficio(personalCasaParticular(Zona), Linea, 0):-
    recorrido(Linea, Zona, _).
beneficio(jubilado, Linea, ValorConBeneficio):-
    valorNormal(Linea, ValorNormal),
    ValorConBeneficio is ValorNormal // 2.

posiblesBeneficios(Persona, Linea, ValorConBeneficio):-
    beneficiario(Persona, Beneficio),
    beneficio(Beneficio, Linea, ValorConBeneficio).

costo(Persona, Linea, CostoFinal):-
    beneficiario(Persona, _),
    recorrido(Linea, _, _),
    posiblesBeneficios(Persona, Linea, CostoFinal),
    forall((posiblesBeneficios(Persona, Linea, OtroValorBeneficiado), OtroValorBeneficiado \= CostoFinal), CostoFinal < OtroValorBeneficiado).

costo(Persona, Linea, ValorNormal):-
   persona(Persona),
   valorNormal(Linea, ValorNormal),
   not(beneficiario(Persona, _)).
   
persona(pepito).
persona(juanita).
persona(tito).
persona(marta).

*/

