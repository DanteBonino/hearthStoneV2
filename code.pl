%Base de conocimiento
nombre(jugador(Nombre,_,_,_,_,_), Nombre).
nombre(criatura(Nombre,_,_,_), Nombre).
nombre(hechizo(Nombre,_,_), Nombre).

vida(jugador(_,Vida,_,_,_,_), Vida).
vida(criatura(_,_,Vida,_), Vida).
vida(hechizo(_,curar(Vida),_), Vida).

dano(criatura(_,Dano,_,_), Dano).
dano(hechizo(_,dano(Dano),_), Dano).

mana(jugador(_,_,Mana,_,_,_), Mana).
mana(criatura(_,_,_,Mana), Mana).
mana(hechizo(_,_,Mana), Mana).

cartasMazo(jugador(_,_,_,Cartas,_,_), Cartas).
cartasMano(jugador(_,_,_,_,Cartas,_), Cartas).
cartasCampo(jugador(_,_,_,_,_,Cartas), Cartas).

/*
Functores:
----------

% jugadores
jugador(Nombre, PuntosVida, PuntosMana,CartasMazo, CartasMano, CartasCampo)

% cartas
criatura(Nombre, PuntosDaño, PuntosVida, CostoMana)
hechizo(Nombre, FunctorEfecto, CostoMana)

% efectos
daño(CantidadDaño)
cura(CantidadCura)
*/
jugador(jugador(dante,8000,8000,[criatura(blueEyesWhiteDrago,3000, 3500, 1500), hechizo(darkhole,dano(500),250)],[],[])).

%Punto 1:
tiene(Jugador, Carta):-
    jugador(Jugador),
    algunConjuntoDeCartas(Jugador, Cartas),
    member(Carta, Cartas).
    

algunConjuntoDeCartas(Jugador, Cartas):-
    cartasCampo(Jugador, Cartas).
algunConjuntoDeCartas(Jugador, Cartas):-
    cartasMazo(Jugador, Cartas).
algunConjuntoDeCartas(Jugador, Cartas):-
    cartasMano(Jugador, Cartas).

%Punto 2:
esUnGuerrero(Jugador):-
    jugador(Jugador),
    forall(tiene(Jugador, Carta), esDeTipo(Carta,criatura)).

esDeTipo(criatura(_,_,_,_), criatura).
esDeTipo(hechizo(_,_,_), hechizo).

%Punto 3:
jugadorPostEmpezarTurno(Jugador, jugador(Nombre, Vida, NuevoMana, NuevasCartasMazo, NuevasCartasMano, CartasCampo)):-
    jugador(Jugador),
    atributosJugador(Jugador, Nombre, Vida, Mana, CartasMazo, CartasMano, CartasCampo),
    NuevoMana is Mana + 1,
    primeraCartaDe(CartasMazo, PrimeraCarta),
    agregarCartaAlFinal(CartasMano, PrimeraCarta, NuevasCartasMano),
    cartasSinPrimera(CartasMazo, PrimeraCarta,NuevasCartasMazo).

atributosJugador(Jugador, Nombre, Vida, Mana, CartasMazo, CartasMano, CartasCampo):-
    vida(Jugador,Vida),
    atributosBasico(Jugador, Nombre, Mana),
    cartasMazo(Jugador, CartasMazo),
    cartasMano(Jugador, CartasMano),
    cartasCampo(Jugador, CartasCampo).

primeraCartaDe(Cartas, Carta):-
    nth0(0, Cartas, Carta).

agregarCartaAlFinal(Cartas, Carta, NuevasCartas):-
    append(Cartas, [Carta], NuevasCartas).

cartasSinPrimera(Cartas, PrimeraCarta, NuevasCartas):-
    append([PrimeraCarta], NuevasCartas, Cartas).
    
%Punto 4:
%a)
puedeJugar(Jugador, Carta):-
    mana(Carta, Mana),
    mana(Jugador, ManaJugador),
    ManaJugador >= Mana.

%b)
vaAPoderJugar(Jugador, Carta):-
    jugadorPostEmpezarTurno(Jugador, JugadorPostEmpezarTurno),
    estaEnLaMano(JugadorPostEmpezarTurno, Carta),
    puedeJugar(JugadorPostEmpezarTurno, Carta).

estaEnLaMano(Jugador, Carta):-
    cartasMano(Jugador, Cartas),
    member(Carta, Cartas).

%Punto 6:
cartaMasDanina(Jugador, NombreCarta):-
    atributosCartaDe(Jugador, _, NombreCarta,_, Dano,_),
    forall(atributosCartaDe(Jugador,_,_,_,OtroDano,_), Dano >= OtroDano).

atributosCartaDe(Jugador, Carta, Nombre, Mana, Dano, Tipo):-
    tiene(Jugador, Carta),
    atributosBasico(Carta, Nombre, Mana),
    dano(Carta,Dano),
    esDeTipo(Carta, Tipo).

atributosBasico(CartaOPersona, Nombre, Mana):-
    nombre(CartaOPersona, Nombre),
    mana(CartaOPersona, Mana).

%Punto 7:
%a)
jugarContra(Carta, Jugador, jugador(Nombre, NuevaVida, Mana, CartasMazo, CartasMano, CartasCampo)):-
    atributosCartaDe(_,Carta,_,_,Dano,hechizo),
    atributosJugador(Jugador, Nombre, Vida, Mana,  CartasMazo, CartasMano, CartasCampo),
    NuevaVida is Vida - Dano.

%b)
jugar(Carta, Jugador, JugadorPostJugarla):-
    vaAPoderJugar(Jugador, Carta),
    accionesBasicas(Jugador, Carta, JugadorIntermedio),
    accionSegunTipo(JugadorIntermedio, carta(Carta, Tipo), JugadorPostJugarla).

accionSegunTipo(Jugador, carta(Carta,criatura), )

accionesBasicas(Jugador, Carta, jugador(Nombre,Vida,NuevoMana, Mazo, NuevaMano, CartasCampo)):-
    mana(Carta, ManaCarta),
    atributosJugador(Jugador, Nombre, Vida, Mana, CartasMazo, CartasMano, CartasCampo),
    agregarMana(Mana, -ManaCarta, NuevoMana),
    quitarCartaDe(CartasMano, PrimeraCarta, NuevasCartasMano).

agregarMana(Mana, Cantidad, NuevoMana):-
    NuevoMana is Mana + Cantidad.

quitarCartaDe(Cartas, Carta, NuevasCartas):-
    