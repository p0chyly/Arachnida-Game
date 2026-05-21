import wollok.game.*
import arania.*
import enemigos.*
import ui.*

// ---- NIVELES ---- //

const nivel1 = new Nivel(cantidadEnemigos = 8, dificultad = facil, tipoEnemigos = #{chico}, enemigos = [moscaHum1, moscaHum2, mariquita1, mariquita2]) 
const nivel2 = new Nivel(cantidadEnemigos = 16, dificultad = media, tipoEnemigos = #{chico, mediano}) 
const nivel3 = new Nivel(cantidadEnemigos = 30, dificultad = dificil, tipoEnemigos = #{chico, mediano, grande}) 

// ----------------- //

object escena {
    var escenaActual = pantallaInicio
    var juegoCompletado = false 
    
    method escenaActual() = escenaActual 
    method juegoCompletado() = juegoCompletado
    
    method ganarElJuego() {
        juegoCompletado = true
    }
    
    method cambiarEscena(nuevaEscena) {
        escenaActual = nuevaEscena
    }

    method pasarAlNivel(unNivel) {
        if(arachnida.enemigosEliminados() == escenaActual.cantidadEnemigos()){
            game.removeVisual(escenaActual.dificultad())
            escenaActual.eliminarTodosLosEnemigos()
            self.cambiarEscena(unNivel)
            game.addVisual(escenaActual.dificultad())
        }
    }

    method instanciarNuevosEnemigos() {
        if(escenaActual.dificultad() == facil and escenaActual.noSuperaElLimiteDeEnemigos()){
            escenaActual.generarEnemigo(new MoscaDeHumedad(vida = 0))
	        game.schedule(2000, {escenaActual.generarEnemigo(new Mariquita(vida = 25))})
        }
        else if(escenaActual.dificultad() == media and escenaActual.noSuperaElLimiteDeEnemigos()){
            game.schedule(5000, {escenaActual.generarEnemigo(new Mosca(vida = 50))})
            game.schedule(8000, {escenaActual.generarEnemigo(new Abeja(vida = 75))})
        }
        else if(escenaActual.dificultad() == dificil and escenaActual.noSuperaElLimiteDeEnemigos()){
            game.schedule(7000, {escenaActual.generarEnemigo(new Mosquito(vida = 100))})
            game.schedule(10000, {escenaActual.generarEnemigo(new Abejorro(vida = 125))})
        }
    }

    method chequearCambioDeNivel() {
        if(escenaActual.dificultad() == facil){
                self.pasarAlNivel(nivel2)
            }
        else if(escenaActual.dificultad() == media){
            self.pasarAlNivel(nivel3)
        }
    }

    method reiniciar() {
        if(pantallaInicio.juegoIniciado()){
            escenaActual.reiniciarNivel()
            self.cambiarEscena(pantallaInicio)
            game.addVisual(escenaActual)
        }
    }

    method generarPantallaVictoria() {
        if(escenaActual.dificultad() == dificil and arachnida.enemigosEliminados() == escenaActual.cantidadEnemigos()){
            self.ganarElJuego()
            self.cambiarEscena(win)
        }
    }
}

class Nivel {
    var cantidadEnemigos 
    var dificultad 
    const enemigosInvasores = []
    const tipoEnemigos = #{} 
    const posicionesEnUso = #{} 
    const enemigos = []
    
    // METODOS DE INDICACION //

    method cantidadEnemigos() = cantidadEnemigos
    method dificultad() = dificultad
    method posicionesEnUso() = posicionesEnUso 
    method esAptoParaElNivel(unEnemigo) = tipoEnemigos.contains(unEnemigo.tipoDeEnemigo()) and self.noSuperaElLimiteDeEnemigos()
    method noSuperaElLimiteDeEnemigos() = enemigos.size() < 5 
    method estaEnColisionConOtroEnemigo(unEnemigo) = enemigos.any({e => unEnemigo.position() == e.position()})
    method enemigosVisibles() = enemigos.all({e => e.esVisible()})
    method nivelCompletado() = cantidadEnemigos == arachnida.enemigosEliminados() 
    method condicionDerrota() = enemigosInvasores.size() >= 3 || arachnida.estaDerrotado() 
 
    // METODOS DE EFECTO //
    
    method unEnemigoAleatorio() {
        if (enemigos.isEmpty()) {
            return new MoscaDeHumedad(vida = 0)
        } 
        else {
            return enemigos.anyOne()
        }
    }

    method reiniciarNivel() {
        if(pantallaInicio.juegoIniciado()){
            game.removeVisual(gameOver)
            game.removeVisual(dificultad)
            game.removeVisual(interfazTelaranias)
            cantidadEnemigos = 8
            dificultad = facil
            tipoEnemigos.clear()
            tipoEnemigos.add(chico)
            enemigos.forEach({e => self.eliminarEnemigo(e)})
            enemigosInvasores.clear()
            arachnida.reiniciar()
            pantallaInicio.reiniciar()
        }
    }
    method moverEnemigos() {
        enemigos.forEach({e => e.moverEnemigo()})
    }
    
    method agregarEnemigo(unEnemigo){
        enemigos.add(unEnemigo)
    }

    method agregarTipoDeEnemigo(tipoEnemigo){
        tipoEnemigos.add(tipoEnemigo)
    }

    method instanciarUnEnemigo(unEnemigo){ 
        if(not self.estaEnColisionConOtroEnemigo(unEnemigo) and unEnemigo.estaVivo()){ 
            enemigos.add(unEnemigo)
            posicionesEnUso.add(unEnemigo.position())
        }
        else{
            self.instanciarEnOtraPosicionSiEstaVivo(unEnemigo)
        }
    }

    method generarEnemigo(unEnemigo) {
        if(self.esAptoParaElNivel(unEnemigo)){
            self.instanciarUnEnemigo(unEnemigo)
            game.addVisual(unEnemigo)
            unEnemigo.hacerVisible()
            unEnemigo.moverEnemigo()
        }
        else{
            self.error("Enemigo no disponible")
        }
    }  

    method generarEnemigoConJuegoEnCurso() {
        game.schedule(5000, {self.generarEnemigo(self.unEnemigoAleatorio())})
    }

    method instanciarEnOtraPosicionSiEstaVivo(unEnemigo) {
        if(unEnemigo.estaVivo()){
            unEnemigo.elegirOtraPosicionDelNivel(self)
        }
        else{
            self.eliminarEnemigo(unEnemigo)
        }
    }

    method eliminarEnemigo(unEnemigo) {
        posicionesEnUso.remove(unEnemigo.posicionInicial())
        enemigos.remove(unEnemigo)
        unEnemigo.ocultar()
        game.removeVisual(unEnemigo)
    }

    method eliminarTodosLosEnemigos() {
        enemigos.forEach({e => self.eliminarEnemigo(e)})
        enemigosInvasores.clear()
    }
    
    method agregarEnemigoInvasor(unEnemigo){
        if(unEnemigo.position().y() <= 0 and unEnemigo.esVisible()){
            enemigosInvasores.add(unEnemigo)
            unEnemigo.ocultar()
            enemigos.remove(unEnemigo)
            game.removeVisual(unEnemigo)
        }
    } 

    // CONDICIONES DE VICTORIA Y DERROTA //

    method perdisteElJuego() {
        if(self.condicionDerrota() and not escena.juegoCompletado()){
            game.addVisual(gameOver)
            self.eliminarTodosLosEnemigos()
            game.schedule(10000, {game.removeVisual(gameOver)})
        }
    }

    method generarPantallaDeVictoria() {
        game.clear()
        self.eliminarTodosLosEnemigos()
        game.addVisual(win)
    }
}