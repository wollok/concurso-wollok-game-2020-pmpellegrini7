import wollok.game.*
import flappy.*
import flappyManager.*

class Obstacle {

	// image(100, 300)

	var property p // Posicion
	var property cA // Area de colision 
	const image = 'flappyImages/obstacle.png'
	
	method image() = image
	method position() = p
	method position(newPosition) { p = newPosition }
	method cA() = cA
	
}

object obstacles {
	
	const initialCollection = [[]]
	var collection = initialCollection
	
	// Con esto indico la posicion de la parte de arriba y la parte de abajo de un obstaculo
	// dejando un hueco para que el pajaro pueda pasar.
	const obstaclesPositions = [ 
	//  TOP  BOTTOM en el eje Y 
		[16,  -25],
		[8,    84],
		[84,  -15],
		[13,  -28],
		[18,  -23]
	]
	
	method getCollection() = collection
	method resetCollection() = { collection = initialCollection }
		
	method render() {
		const posY = obstaclesPositions.anyOne()
		const topPiece = posY.first()
		const bottomPiece = posY.last()
		
		const newObstacle = [
			// Parte de arriba
			new Obstacle( p = game.at(25, topPiece), cA = (topPiece..30) ),
			
			// Parte de abajo
			new Obstacle( p = game.at(25, bottomPiece), cA = (bottomPiece..bottomPiece+33) )
		]
		
		collection.add(newObstacle)
		newObstacle.forEach({ piece => game.addVisual(piece) })
	}
	
	method behaviour(piece) {
		const posX = piece.position().x()
		const posY = piece.position().y()
		
		// Realiza el movimiento del obstaculo
		piece.position(game.at(posX - 1, posY))
		
		// Cuando el obstaculo desaparece de la pantalla se lo destruye
		if(posX == -3) {
			game.removeVisual(piece)
		}
		
		// Cuando se detecta la colision del pajaro en una de las partes del obstaculo 
		// o el pajaro sale de la pantalla, se termina el juego
		if(flappy.position().x() == posX && piece.cA().contains(flappy.position().y()) 
			|| (-1 == flappy.position().y()) || (flappy.position().y() > 25)) {
				game.clear()
				flappyGame.showMenu()
		}	
	}
	
	method restart() {
		initialCollection.clear()
		initialCollection.add(
			[
				new Obstacle(p = game.at(25, 16), cA = (16..25)), 
				new Obstacle(p = game.at(25, -25), cA = (-25..8))
			]
		)
	}
	
}