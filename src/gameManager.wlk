import wollok.game.*
import snakeGame.snakeManager.snakeManager
import fifteenPuzzle.fifteen_puzzle.*
import flappyGame.flappyManager.flappyGame
import pongGame.pongManager.*

 object gameManager {
 	const cellsize = 30 // pixeles
	const height = 25 // en celdas
	const width = 25 // en celdas
	
	const piecelen = 120 // pixeles de ancho de cada piecita (15puzzle)
 	
 	method inicializar() {
		game.cellSize(cellsize)
		game.height(height)
		game.width(width)
		game.boardGround("img/fondo.png")
		game.title("PIGames")
 		fifteen_puzzle.init(width, height, piecelen, cellsize)
 		//hace la mezcla acá, es mucho más rápido para iniciarlo
 	}
 	
 	method mostrarMenu() {
 		game.clear()
 		if (!game.hasVisual(home)) game.addVisual(home)
 		// Eventos para iniciar cada juego
 		keyboard.s().onPressDo {
 			snakeManager.iniciarJuego()
 		}
 		keyboard.p().onPressDo {
			fifteen_puzzle.start() 
		}
		keyboard.b().onPressDo { 
			flappyGame.showMenu()
		}
		keyboard.x().onPressDo {
			pong.play()
		}
 	}
 	
 	method ocultarMenu() {
 		if (game.hasVisual(home))
 			game.removeVisual(home)
 	}
 	
 }

 object tituloSnake {
	const property image = "img/snake.png"
	const property position = game.at(1,13)
}

object tituloPuzzle {
	const property image = "img/fifteen.png"
	const property position = game.at(12,13)
}

object tituloFlappy {
	const property image = "img/flappy.png"
	const property position = game.at(6.5, 2)
}

object home {
	const property image = "img/home.png"
	const property position = game.at(0, 0)
}
