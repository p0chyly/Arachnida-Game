import wollok.game.*
import arania.*
import niveles.*

object pantallaInicio{
	var position = game.origin()
	var juegoIniciado = false 

    method juegoIniciado() = juegoIniciado 
    method image() = "Inicio1.png"
    method position() = position
    
    method comenzarElJuego() {
		juegoIniciado = true
		game.removeVisual(self)
        escena.cambiarEscena(nivel1)
	}
    
    method detenerJuego() {
        juegoIniciado = false
    }

    method reiniciar(){
        juegoIniciado = false
        position = game.origin()
    }
}

object interfazTelaranias{
	const position = game.at(0,5.5)
    method position() = position
    const interfaces = ["T0.png", "T1.png", "T2.png", "T3.png", "T4.png", "T5.png", "T6.png", "T7.png", "T8.png", "T9.png", "T10.png", "T11.png", "T12.png", "T13.png", "T14.png", "T15.png", "T16.png", "T17.png", "T18.png", "T19.png", "T20.png"]
    method image() = self.interfaz(arachnida.telaranias())
	method interfaz(numero){
    	return interfaces.get(20.min(numero))
    }
}

object sinTelaranias{
    const position = game.origin()
    method position() = position
    method image() = "sinTelaranias.png"
}

object gameOver{
    const position = game.origin()
    method position() = position
    method image() = "gameOverMensaje.png"
    method ganasteElJuego() = true 
}

object win{
    const position = game.origin()
    method position() = position
    method image() = "ganasteVisual.png"
}

object controles{
    const position = game.at(5,3)
    method position() = position
    method image() = "controles.png"
}

object bestiario{
    var visibilidad = false
    const position = game.origin()
    method position() = position
    method image() = "Bestiario1.png"

    method cambiarVisibilidad(){
        visibilidad = not visibilidad
    }

    method alternarVisibilidadEnPantalla() {
        if(visibilidad){
		    game.addVisual(self)
        }
        else if(not visibilidad){
            game.removeVisual(self)
        }
    }
    
    method mostrarBestiario() {
		if(not pantallaInicio.juegoIniciado()){
            self.cambiarVisibilidad()
            self.alternarVisibilidadEnPantalla()
        }
	}
}

object facil{
    var position = game.at(11.5, 6)
    method position() = position
    method image() = "Nivel1Visual.png"
}

object media{
    var position = game.at(11.5, 6)
    method position() = position
    method image() = "Nivel2Visual.png"
    }

object dificil{
    var position = game.at(11.5, 6)
    method position() = position
    method image() = "Nivel3Visual.png"
    }