import wollok.game.*
import pong.*

object pong {
	method init(){
		pelota.movimientoInicio()
		
		// Eventos
		keyboard.k().onPressDo({
			usuario.movement(2)
			usuario.area()
		})
		keyboard.m().onPressDo({
			usuario.movement(-2)
			usuario.area()
		})
	}
	method play(){
		game.clear()
		self.init()
		
		game.addVisual(franja)
		game.addVisual(usuario)
		game.addVisual(ia)
		game.addVisual(pelota)
	
		// Ticks
		game.onTick(pelota.pelotaSpeed(), 'movimiento', {
			pelota.movement()
			pelota.gameOver()
		})
		
		game.onTick(ia.iaSpeed(), 'movimientoIa' , {
			ia.movement(0)  
			ia.area()
		})
	}

//	method mostrarMenu(){
//		gameManager.mostrarMenu()
//		
//		keyboard.c().onPressDo({
//			self.play()
//		})
//		keyboard.r().onPressDo({
//			game.stop()
//		})
//	}
}

object menu{
	method image() = 'pongImages/menu.png'
	method position() = game.at(1,2);
}