% publicacion(Fecha, Post).
publicacion(fecha(25, 01, 2013), tuid(coirotomas, ["es", "mi", "cumple", "arrodíllense"])).
publicacion(fecha(26, 01, 2014), tuid(fanDeTusk, ["paga", "Tuiderr", "en", "vez", "de", "quejarte", "queridito"])).
publicacion(fecha(06, 07, 2014), tuid(matifreyre, ["que", "bueno", "Les", "Luthiers"])).
publicacion(fecha(25, 12, 2014), tuid(melonTusk, ["ser", "millonario", "es", "más", "difícil", "que", "ser", "pobre"])).
publicacion(fecha(23, 07, 2023), tuid(melonTusk, ["ahora", "se", "llama", "Z"])).
publicacion(fecha(18, 05, 2024), tuid(alumnoFrustrado, ["pdep", "hace", "los", "peores", "parciales"])).
publicacion(fecha(05, 06, 2024), retuid(fanDeTusk, tuid(melonTusk, ["ser", "millonario", "es", "más", "difícil", "que", "ser", "pobre"]))).
publicacion(fecha(18, 05, 2024), retuid(alumno2, tuid(alumnoFrustrado, ["pdep", "hace", "los", "peores", "parciales"]))).
publicacion(fecha(23, 06, 2024), tuid(bornoPot, ["para", "mas", "contenido", "gatito", "enBio"])).
publicacion(fecha(23, 06, 2024), tuid(bornoPot, ["para", "menos", "contenido", "gatito", "enBio"])).
publicacion(fecha(23, 06, 2024), tuid(bornoPot, ["para", "otro", "contenido", "gatito", "enBio"])).
publicacion(fecha(23, 06, 2024), tuid(bornoPot, ["para", "diferente", "contenido", "gatito", "enBio"])).
publicacion(fecha(23, 06, 2024), tuid(bornoPot, ["para", "parecido", "contenido", "gatito", "enBio"])).
publicacion(fecha(23, 06, 2024), tuid(bornoPot, ["para", "distinto", "contenido", "gatito", "enBio"])).
publicacion(fecha(23, 06, 2024), tuid(coirotomas, ["compren", "bitcoin", "es", "el", "futuro"])).
publicacion(fecha(27, 06, 2024), tuid(estafador238, ["cryptos", "gratis", "en", "link", "pongan", "datos"])).
publicacion(fecha(06, 07, 2024), retuid(matifreyre, tuid(matifreyre, ["que", "bueno", "Les", "Luthiers"]))).
publicacion(fecha(06, 08, 2024), retuid(matifreyre, retuid(matifreyre, tuid(matifreyre, ["que", "bueno", "Les", "Luthiers"])))).

% paraAprobar(Fecha, Post).
paraAprobar(fecha(20, 03, 2023), tuid(leocesario, ["miren", "este", "lechoncito"])).
paraAprobar(fecha(25, 01, 2024), tuid(coirotomas, ["cumplí", "30", "me", "duele", "la", "espalda"])).
paraAprobar(fecha(17, 11, 2024), retuid(leocesario,  tuid(coirotomas, ["es", "mi", "cumple", "arrodíllense"]))).
paraAprobar(fecha(23, 06, 2024), tuid(bornoPot, ["gatito", "enBio", "clickea", "el", "link"])).

% 1 
% Hacer publicacionDe/2, que relacione a un usuario con el contenido de una de sus publicaciones.
publicacionDe(Usuario, Contenido):-
  publicacion(_, Post),
  postDe(Usuario, Contenido, Post).

postDe(Usuario, Contenido, tuid(Usuario, Contenido)).
postDe(Usuario, Contenido, retuid(Usuario, Post)):-
  postDe(_, Contenido, Post).
% 2.a
% Implementar diferentes predicados de revisión de contenido: contieneFrase/3 que relaciona dos palabras con un Post si las dos palabras están escritas en forma consecutiva en el contenido de ese Post. No necesita ser inversible para las dos palabras.
contieneFrase(Palabra1, Palabra2, Post):-
  contenido(Contenido, Post),
  sonConsecutivas(Palabra1, Palabra2, Contenido).

sonConsecutivas(Palabra1, Palabra2, Contenido):-
  nth1(Indice, Contenido, Palabra1),
  nth0(Indice, Contenido, Palabra2).

sonConsecutivas2(Palabra1, Palabra2, Contenido):-
  append(_, [Palabra1,Palabra2|_], Contenido).

contenido(Contenido, Post):-
  post(Post),
  postDe(_, Contenido, Post).

post(Post):-post(_, Post). % Porque Messi-rve
post(Fecha, Post):-publicacion(Fecha, Post).
post(Fecha, Post):-paraAprobar(Fecha, Post).
% post(Post):-rechazado(_, Post).

% 2.b
% esDeBot/1, que se verifica para cualquier Post que cumpla al menos una de las siguientes condiciones:
% Contiene "gatito enBio" en cualquier lugar del contenido.
% No es de este año.
% Es un ReTuid de un Post anterior a 2015.
anioActual(2024).

esDeBot(Post):-
  contieneFrase("gatito", "enBio", Post).

esDeBot(Post):-
  anioActual(AnioActual),
  post(fecha(_,_,Anio), Post),
  Anio \= AnioActual.

esDeBot(retuid(Usuario, Post)):-
  post(retuid(Usuario, Post)),
  post(fecha(_,_,Anio), Post),
  Anio < 2015.

% 3
% Hacer verdaderoAutor/2, que relaciona un Post con su autor verdadero, siendo que, en los casos de los ReTuids, el verdadero autor es el que publicó el Tuid original.
verdaderoAutor(tuid(Autor,Contenido), Autor):-
  post(tuid(Autor,Contenido)).
  
verdaderoAutor(retuid(Usuario, Post), Autor):-
  post(retuid(Usuario, Post)),
  verdaderoAutor(Post, Autor).

% 4 
% Implementar postsParaPublicar/2, que relaciona un usuario y sus Posts en proceso de aprobación que no son de bot.

postsParaPublicar(Usuario, Posts):-
  usuario(Usuario),
  findall(Post,
    (paraAprobar(_, Post),
    postDe(Usuario, Post),
    not(esDeBot(Post))), 
    Posts).

usuario(Usuario):-
  distinct(Usuario, postDe(Usuario,_)).

% 5
% Necesitamos saber si un usuario debe ser favorecido/1 por el algoritmo. Esto sucede sólo cuando, en sus Posts, no tiene ReTuids (él/ella no retuidea, es “100% ORISHINAL”), y además nunca incluyó la frase "cryptos gratis".
postDe(Usuario,Post):-
  post(Post), postDe(Usuario,_,Post).

favorecido(Usuario):-
  usuario(Usuario),
  not(postDe(Usuario, retuid(_, _))),
  not( 
    (postDe(Usuario, Post),
    contieneFrase("cryptos", "gratis", Post))
  ).

% 6
% esteEsWallE/1, que se cumple para un usuario que tiene altas chances de ser un bot. Estos son los usuarios para los que todos sus Posts son de bot, o si existe un día en el que hizo más de 5 Posts.

esteEsWallE(UsuarioBot):-
  usuario(UsuarioBot), 
  forall(postDe(UsuarioBot, Post), esDeBot(Post)).

esteEsWallE(UsuarioBot):-
  post(Fecha, UsuarioBot, _),
  findall(Post, post(Fecha, UsuarioBot, Post), Posts),
  length(Posts, Cantidad),
  Cantidad > 5.
  
post(Fecha, Usuario, Post):-
  post(Fecha, Post),
  postDe(Usuario, Post).


% 7
% Implementar elMejorTimeline/2, que relaciona un número de publicaciones pedidas, y una lista con esa cantidad de posts (sin repetir),
% Posts de usuarios favorecidos.
% Posts donde el verdadero autor sea "melonTusk".
% Posts que contengan la frase "paga Tuiderr".

elMejorTimeline(Cantidad, Publicaciones):-
  length(Publicaciones, Cantidad),
  findall(Post, mejorPost(Post), MejoresPosts),
  list_to_set(MejoresPosts, MejoresPostsSet),
  subConjunto(MejoresPostsSet, Publicaciones).

subConjunto(_, []).
subConjunto(Original, [H|Resto]):-  
  select(H, Original, RestoOriginal),
  subConjunto(RestoOriginal, Resto).
  
% subConjunto(_, []).
% subConjunto([H|T], [H|Resto]):-
%   subConjunto(T, Resto).
% subConjunto([H|T], Resto):-
%   subConjunto(T, Resto).

mejorPost(Post):-
   publicacion(_, Post),
   condicionMejorPost(Post).

condicionMejorPost(Post):-
  postDe(Usuario, Post),
  favorecido(Usuario).

condicionMejorPost(Post):-
  verdaderoAutor(Post, melonTusk).

condicionMejorPost(Post):-
  contieneFrase("paga", "Tuiderr", Post).
  