import wollok.game.*
import arania.*
import niveles.*
import ui.*

const moscaHum1  = new MoscaDeHumedad(vida = 0)  
const moscaHum2  = new MoscaDeHumedad(vida = 0) 
const mariquita1 = new Mariquita(vida = 25) 
const mariquita2 = new Mariquita(vida = 25)         
const mosca1     = new Mosca(vida = 50)    
const mosca2     = new Mosca(vida = 50)        
const abeja1     = new Abeja(vida = 75)
const abeja2    = new Abeja(vida = 75)           
const mosquito  = new Mosquito(vida = 100)        
const abejorro  = new Abejorro(vida = 125)        

const bordes = [
    game.at(0,6),
    game.at(3,6),
    game.at(6,6),
    game.at(9,6),
    game.at(12,6),
    game.at(14,6)]

class Enemigos { 
    var vida
    var position = posicionInicial
    var posicionInicial = bordes.anyOne() 
    var esVisible = false 
    const movimiento = game.tick(2500, {self.moverse()}, false) 

    method tipoDeEnemigo()
    method image()
    method esVisible() = esVisible
    method posicionInicial() = posicionInicial
    method position() = position
    method nivelActual() = escena
    method vida() = vida
    method estaVivo() = self.vida() != 0 
    
    method sufrirDanio() {
        vida = 0.max(vida - 25)
    }
    method hacerVisible() {
        esVisible = true
    }
    method ocultar() {
        esVisible = false
    }
    method elegirOtraPosicionDelNivel(unNivel) {
        posicionInicial = bordes.find({p => not unNivel.posicionesEnUso().contains(p)})
    }
    method moverse() {
        position = position.down(1)
        escena.escenaActual().agregarEnemigoInvasor(self)
        
    }
    method moverEnemigo() {
        movimiento.start()
    }   

    method sufrirDanioOMorirSiColisiona(){
        if(self.estaVivo()){
            self.sufrirDanio()
        }
        else if (not self.estaVivo()){
            self.morir()
            escena.escenaActual().eliminarEnemigo(self)
            escena.instanciarNuevosEnemigos()
            escena.chequearCambioDeNivel()
        }
    }
    method cantidadRecargaSegunTipo() {
        return self.tipoDeEnemigo().cantidadRecarga()
    }
    method morir(){
        self.generarHuevoTelarania(new HuevoTelarania(), self.position(), self.cantidadRecargaSegunTipo())
        self.ocultar()
        game.removeVisual(self)
        arachnida.eliminarUnEnemigo()
    }
    method generarHuevoTelarania(unHuevo, unaPosicion, cantidad) {
        unHuevo.inicializar(unaPosicion, cantidad)
        game.addVisual(unHuevo)
    }
}

class Abeja inherits Enemigos{
    override method image() = "Abeja.png" 
    override method tipoDeEnemigo() = mediano 
}

class Abejorro inherits Abeja{
    override method image() = "Abejorro.png"
    override method tipoDeEnemigo() = grande
}

class Mosca inherits Enemigos{
    override method image() = "Mosca.png"
    override method tipoDeEnemigo() = mediano 
}

class MoscaDeHumedad inherits Enemigos{ 
    override method image() = "MoscaDeHumedad.png"
    override method tipoDeEnemigo() = chico
}

class Mariquita inherits Enemigos{ 
    override method image() = "Mariquita.png"
    override method tipoDeEnemigo() = chico
}

class Mosquito inherits Enemigos{  
    override method image() = "Mosquito.png"
    override method tipoDeEnemigo() = grande
}

object mediano {
    method cantidadRecarga() = 6
}
object grande {
    method cantidadRecarga() = 9
}
object chico {
    method cantidadRecarga() = 3
}