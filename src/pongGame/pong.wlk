import wollok.game.*
import pongManager.*
import gameManager.*

object pelota {

	//COLECCION PARA HACER EL MOVIMIENTO ALEATORIO EN EL INICIO
	const numeros = [1 , -1]
	
	//DIRECCION X , Y
	var direccionX = -1
	var direccionY = -1
	
	//VELOCIDAD PELOTA
	var property pelotaSpeed = 100
	const image = 'pongImages/pelota.png'
	var property position
	
	method numeros() = numeros
	method image() = image	
	method pelotaSpeed() = pelotaSpeed
	
	//MOVIMIENTO DE LA PELOTA AL INICIO
	method movimientoInicio(){
		position = game.at(10,12)
		direccionX = numeros.anyOne()
		direccionY = numeros.anyOne()
	}
	
	//MOVIMIENTO CONTINUO DE LA PELOTA
	method movement(){
		self.position( position.up(direccionY).right(direccionX) )
		self.movementY()
		self.movementX()
	}	
	
	//MOVIMIENTO EN Y
	method movementY(){
		if([0, 24].contains(position.y())) direccionY *= -1
	}
	
	//MOVIMIENTO EN X
	method movementX(){
		if((position.x() == 1) && usuario.areaColision().contains(position.y()))
			direccionX = 1
		if((position.x() == 23) && ia.areaColision().contains(position.y()))
			direccionX = -1
	}
	
	// Si se sale de los límites nos vamos
	method gameOver(){
		if ([-1, 25].contains(position.x())) gameManager.mostrarMenu()
  	}	
}

// Class Raqueta

class Raqueta {
	var areaColision
	var property image
	var property position

	// Movimiento vertical
	method movement(dir){
		// min = 0, max = 22
		if (! ((position.y()==0 && dir<0) || (position.y()==22 && dir>0)) )
			self.position(position.up( dir ))
	}
	
	method area() { areaColision = (position.y() - 1 .. position.y() + 4) }
	method areaColision() = areaColision
}

// Objetos raquetas y franja

object usuario inherits Raqueta(position = game.at(0, 14) , image = 'pongImages/raqueta.png') {}

object ia inherits Raqueta (position = game.at(24, 14) , image = 'pongImages/ia.png') { 
	//PELOTA
	var property iaSpeed = 450
	
	//MOVIMIENTO DE LA IA
	 override method movement(numero){
		self.position(game.at(position.x() , pelota.position().y()))
	}
}

object franja {
	const position = game.at(25.div(2), 0)
	const image = 'pongImages/franja.png'
	method image() = image
	method position() = position	
}
