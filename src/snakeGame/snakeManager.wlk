import wollok.game.*
import snake.snake
import food.foodDot
import gameManager.gameManager

object titulo1 {
	var property image = "img/texto1.png"
	method position() = game.at(5, 14)
}

object perdiste {
	var property image = "img/perdiste.png"
	method position() = game.at(6, 14)
}

object volverMenu {
	const property image = "img/return_menu.png"
	const property position = game.at(7.5, 6)
}

object titulo2 {
	var property image = "img/texto2.png"
	var property mostrando = false
	
	method mostrar() {
		if(self.mostrando())
			game.removeVisual(self)
		else
			game.addVisual(self)
			
		mostrando = !mostrando
	}
	
	method cambiarTexto() {
		if(image == "img/texto2.png")
			image = "img/reiniciar.png"
		else
			image = "img/texto2.png"
	}
	
	method position() = game.at(7.5, 11)
}

object snakeManager {
	method configurarTeclado() {
		keyboard.w().onPressDo { snake.changeMovement(false, true) }
		keyboard.s().onPressDo { snake.changeMovement(false, false) }
		keyboard.d().onPressDo { snake.changeMovement(true, true) }
		keyboard.a().onPressDo { snake.changeMovement(true, false) }
	}
	
	method printearTodo() {
		snake.parts().forEach({ part =>
			part.dots().forEach({ dot =>
				game.addVisual(dot)
			})
		})
		game.addVisual(foodDot)
	}
	
	method iniciarJuego() {
		game.clear()
		game.addVisual(titulo1)
		
		game.onTick(1200, "titulo", {
			titulo2.mostrar()
		})
		
		keyboard.w().onPressDo {
			game.removeTickEvent("titulo")
			game.clear()
			self.startGame()
		}
	}
	
	method cerrarJuego() {
		snake.limpiarSerpiente()
		game.clear()
	}
	
	method perdio() {
		game.clear()
		titulo2.cambiarTexto()
		game.addVisual(perdiste)
		game.addVisual(titulo2)
		game.addVisual(volverMenu)
		
		keyboard.w().onPressDo {
			game.clear()
			self.configurarTeclado()
			self.startGame()
		}
		
		keyboard.r().onPressDo {
			self.cerrarJuego()
			gameManager.mostrarMenu()
		}
	}
	
	method startGame() {
		snake.snakeInit()
		self.configurarTeclado()
		game.addVisual(foodDot)
		
		game.onTick(100, "gameClock", {
			snake.moveSnake()
		})
	}
}