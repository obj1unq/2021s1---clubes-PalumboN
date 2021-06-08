/** 
Hay clubes 
  -> Se practican distintas actividades
     -> Equipos que practican deportes
     -> Actividades sociales
  -> Perfil: tradicional, comunitario, o profesional.

Equipo
  -> Plantel y 1 capitán (un jugador)
    -> Jugador 
       -> Valor de pase
       -> Cant de partidos jugados

Actividad social
  -> Organizador y socios participantes
    -> Socio -> cuántos años lleva 
 
"todos los jugadores de un equipo son también socios del club"

"Un socio pertenece a un único club"

 */

class Club { 
	const actividades = []	// O tener equipos y actSociales por separado?
//	const equipos = []
//	const actSociales = []
//	const socios = []  		// Me los guardo o los calculo?
//	const perfil 			// Herencia vs composicion
	const gastoMensual

//	method actividades() { return equipos + actSociales }

	method socios() {
		return actividades
			.map({ actividad => actividad.participantes() }) // usar flatMap
			.flatten().asSet()
	}
	
	method socioMasViejo() {
		return self.socios()
			.max({ socio => socio.antiguedad() })
	}
	
	method sociosDestacados() {
//		return self.socios().filter({ socio => esLider?? })
		return actividades.map({ actividad => actividad.socioDestacado() })
	}
	
	method esDestacado(socio) {
		return self.sociosDestacados().contains(socio)
	}
	
	method sociosDescatadosYEstrellas() {
		return self.sociosDestacados().filter({ socio => socio.esEstrella() })
	}
	
	method sancionar() {
		self.validarSancion()
		actividades.forEach({ actividad => actividad.sancionar() })
	}
	
	method validarSancion() {
		if (self.cantidadDeSocios() < 500) {
			self.error("No se puede sancionar este club")
		} 
	}
	
	// Template method / método plantilla
	method evaluacion() {
		return self.evaluacionBruta() / self.cantidadDeSocios()
	}
	
	method esPrestigioso() {
		return actividades.any({ actividad => actividad.esPrestigiosa() })
	}

	
	method cantidadDeSocios() {
		return self.socios().size()
	}
	
	method tieneComoSocio(socio) {
		return self.socios().contains(socio)
	}
	
	method participaEnMuchasActividades(socio) {
		return actividades
		.filter({ actividad => actividad.esParticipante(socio) }) // usar count
		.size() >= 3
	}
	
	method removerSocio(socio) {
		actividades.forEach({ actividad => actividad.sacarParticipante(socio) })
	}
	
	method tieneActividad(unaActividad) {
		return actividades.contains(unaActividad)
	}
	

	
	method evaluacionTotalPorActividades() {
		return actividades.sum({ actividad => actividad.evaluacion() }) 
	}
	
	method tePareceEstrella(jugador)
	method evaluacionBruta()
}

class Profesional inherits Club { 
	override method tePareceEstrella(jugador) {
		return jugador.esCaro()
	}
	
	override method evaluacionBruta() {
		return 2 * self.evaluacionTotalPorActividades() - 5 * gastoMensual
	}
}
class Comunitario inherits Club { 
	override method tePareceEstrella(jugador) {
		return self.participaEnMuchasActividades(jugador)
	}
	
	override method evaluacionBruta() {
		return self.evaluacionTotalPorActividades()
	}
	
}
class Tradicional inherits Club { 
	override method tePareceEstrella(jugador) {
		return jugador.esCaro() or self.participaEnMuchasActividades(jugador)
	}
	
	override method evaluacionBruta() {
		return self.evaluacionTotalPorActividades() - gastoMensual
	}	
}

class Actividad {
	const property participantes = []
	
	method esParticipante(socio) {
		return participantes.contains(socio)
	}
	
	method cantEstrellas() {
		return participantes.count({ participante => participante.esEstrella() })
	}
	
	method sacarParticipante(participante) {
		participantes.remove(participante)
	}
	
	method sancionar()
	method evaluacion()
	method esPrestigiosa()
}

class Equipo inherits Actividad {
	const property capitan // Es uno de los participantes
	var property cantSanciones = 0
	var cantCampeonatos
	
	override method sancionar() {
		cantSanciones += 1
	}
	
	override method evaluacion() {
		return self.aporteDeCampeonatos() 
		+ self.aporteDeMiembros()
		+ self.aporteDelCapitan()
		- self.aportePorSanciones()
	}
	
	method aporteDeCampeonatos() {
		return 5 * cantCampeonatos
	}
	method aporteDeMiembros() {
		return 2 * self.cantMiembros() 
	}
	method aporteDelCapitan() {
		return if (capitan.esEstrella()) 5 else 0 
	}
	method aportePorSanciones() {
		return self.valorPorSancion() * cantSanciones 
	}
	
	method esExperimentado() {
		return participantes.all({ jugador => jugador.esExperimentado() })
	}
	
	override method esPrestigiosa() {
		return self.esExperimentado()
	}
	
	method agregarJugador(jugador) {
		participantes.add(jugador)
	}
	
	method valorPorSancion() { return 20 }
	method jugadores() { return participantes }
	method socioDestacado() { return capitan }
	method cantMiembros() { return participantes.size()	}
}

class EquipoDeFutbol inherits Equipo {
	override method evaluacion() {
		return super() + self.aportePorEstrellasEnPlantel()
	}
	
	method aportePorEstrellasEnPlantel() {
		return 5 * self.cantEstrellas() 
	}
	
	override method valorPorSancion() { return 30 }
	
}

class ActividadSocial inherits Actividad {
	const property organizador // Es uno de los participantes
	var property suspendida = false
	const valorDeEvaluacion
	
	override method sancionar() {
		suspendida = true
	}
	
	method reanudar() {
		suspendida = false
	}
	
	override method evaluacion() {
		return if (suspendida) 0 else valorDeEvaluacion
	}
	
	override method esPrestigiosa() {
		return self.cantEstrellas() >= 5
	}
	


	method socios() { return participantes }
	method socioDestacado() { return organizador }
}

class Socio {
	const property antiguedad
	
	method esEstrella() {
		return antiguedad > 20
	}
}

class Jugador inherits Socio {
	const valorDePase
	var cantPartidosJugados
//	const club 		// Esto crea una referencia ciclica con el club y las actividades.
	
	override method esEstrella() {
		return 	cantPartidosJugados >= 50
		or 		self.club().tePareceEstrella(self)
	}
	
	method esCaro() {
		return valorDePase > municipio.paseEstrella()
	}
	
	method esExperimentado() {
		return cantPartidosJugados >= 10
	}
	
	method transferir(nuevoEquipo) {
		self.validarTransferenciaHacia(nuevoEquipo)
		self.transferirHacia(nuevoEquipo)
	}
	
	method validarTransferenciaHacia(nuevoEquipo) {
		if (self.club().esDestacado(self)) {
			self.error("Jugador destacado no se puede transferir")
		}
		if (self.club().tieneActividad(nuevoEquipo)) {
			self.error("No se puede transferir jugadores del mismo club")
		}
	}
	
	method transferirHacia(nuevoEquipo) {
		self.club().removerSocio(self)
		nuevoEquipo.agregarJugador(self)
		cantPartidosJugados = 0
	}
	
	method club() {
		return municipio.clubAlQuePertenece(self)
	}
}

object municipio {
	const clubes = []
	var property paseEstrella = 100
	
	method nuevoClub(club) {
		clubes.add(club)
	}
	
	method clubAlQuePertenece(socio) {
		return clubes.find({ club => club.tieneComoSocio(socio) })
	}
}

// jugador.transferir(nuevoEquipo)
// club.transferir(jugador, nuevoEquipo)
// municipio.transferir(jugador, nuevoEquipo)
