import wollok.game.*
import niveles.*
import enemigos.*
import ui.*

object arachnida {
    var telaranias = 15
    var position = game.at(7, 0)
    var enemigosEliminados = 0
    var estadoDerrota = false
    const telaraniasDisparadas = []
    
    method estaDerrotado() = estadoDerrota
    method enemigosEliminados() = enemigosEliminados 
    method disparadas() = telaraniasDisparadas
    method primerTelarania() = telaraniasDisparadas.first() 
    method telaranias() = telaranias
    method image() = "ArachnidaV2.png" 
    method position() = position 
    
    method setDerrota(valor) {
        estadoDerrota = valor
    }

    method atacarSiElJuegoInicio(unaTelarania){
        if(pantallaInicio.juegoIniciado()){
            self.atacar(unaTelarania)
        }
    }

    method atacar(unaTelarania) {
        if(telaranias > 0){
            telaranias -= 1
            telaraniasDisparadas.add(unaTelarania)
            game.addVisual(unaTelarania)
            unaTelarania.prepararTelarania()
            unaTelarania.dispararTelarania()
            unaTelarania.eliminarSiNoColisiono()
            }
        else{
            self.setDerrota(true)
            escena.escenaActual().perdisteElJuego()
        }    
    }
    method recargarTelarania(cantidadRecarga) {
        telaranias = 20.min(telaranias + cantidadRecarga)
    }
    method eliminarUnEnemigo() {
        if(enemigosEliminados > 16){
            game.addVisual(win)
            keyboard.space().onPressDo({self.recargarTelarania(15)})
        }
        else{
            enemigosEliminados  += 1
        }
    }
    method reiniciar() {
        telaranias = 15
        position = game.at(7, 0)
        enemigosEliminados = 0
        telaraniasDisparadas.clear()
        estadoDerrota = false
    }
    method moverDerecha() {
       if (pantallaInicio.juegoIniciado() && position.x() < game.width() - 1) 
            position = position.right(1)
            escena.escenaActual().perdisteElJuego()
    }
    method moverIzquierda() {
        if (pantallaInicio.juegoIniciado() && position.x() > 0)
            position = position.left(1)
            escena.escenaActual().perdisteElJuego()
    }
}

class Telarania {
    var position = game.origin()  
    var estaPreparada = false
    
    method position() = position 
    method image() = "telarania.png"

    method moverTelarania() {
        position = position.up(1)
    } 
    method prepararTelarania() {
        estaPreparada = true
        position = arachnida.position()
    }
    method dispararTelarania() {
        if(estaPreparada){
            game.onTick(100, "disparar", { => self.moverTelarania()})
            self.colisionoConEnemigo()
            estaPreparada = false
        }
        else{
            estaPreparada = false
        }
    }
    method eliminarSiNoColisiono() {
        game.schedule(3000, {game.removeVisual(self)})
    }
    method colisionoConEnemigo() {
        game.onCollideDo(self, {e =>
            e.sufrirDanioOMorirSiColisiona()
            game.removeVisual(self)
            arachnida.disparadas().remove(self)
        })
    }
}

class HuevoTelarania {
    var position = game.origin()
    var cantidadRecarga = 0
    
    method position() = position
    method image() = "ContenedorTelarania.png"
    
    method inicializar(posicionEnemigo, cantidad){
        position = posicionEnemigo
        cantidadRecarga = cantidad
        self.caerYRecargar()
    }

    method moverHuevo() {
        if(position.y() >= 0)
            position = position.down(1)
        else{
            position = game.at(position.x(), 0)
            game.removeTickEvent("caer")
        }
    }
    method caerYRecargar() {
        if(position.y() >= 1){
            game.onTick(100, "caer", { => self.moverHuevo()})
            self.recargarArachnidaSiColisiona()
            game.schedule(5000, {game.removeVisual(self)})
        }
        else{
            game.removeVisual(self)
        }
    }

     method recargarArachnidaSiColisiona() {
        game.onCollideDo(self, {a =>
            a.recargarTelarania(cantidadRecarga)
            game.removeVisual(self) 
        })
    }

}