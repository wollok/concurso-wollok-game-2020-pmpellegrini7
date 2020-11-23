import wollok.game.*
import food.foodDot
import wollok.lib.*
import snakeManager.snakeManager

class SnakeDot {
	var property x
	var property y
	const property image = "img/white_dot.png"
	
	method position() = game.at(x, y)
	
	method changePos(newx, newy) {
		x = newx
		y = newy
	}
}

class SnakeSegment {
	var property length = 1
	var property pos_movement // true movimiento es derecha/arriba
	var property x_movement // true se mueve en eje x, false en eje y
	var property dots = []
	
	// Solo para la serpiente de inicio del juego
	method initialSnake() {
		length = 2
		2.times({ i => 
			const newDot = new SnakeDot(x = 10, y = 10 + i)
			dots.add(newDot)
			game.addVisual(newDot)
		})	
	} 
	
	method getSpeed() {
		if(pos_movement)
			return 1
		else
			return -1
	}
	
	// Agregar un punto en frente de la cabeza
	method addMoveDot(newDot) {
		length += 1

		const speed = self.getSpeed()
			
		const tailPos = dots.last().position()
		
		if(x_movement)
			newDot.changePos(tailPos.x() + speed, tailPos.y())
		else
			newDot.changePos(tailPos.x(), tailPos.y() + speed)
		
		dots.add(newDot)
	}
	
	// Agregar primer punto al segmento
	method initialDot(x_coord, y_coord, snakeDot) {
		const speed = self.getSpeed()
		
		if(x_movement)
			snakeDot.changePos(x_coord + speed, y_coord)
		else
			snakeDot.changePos(x_coord, y_coord + speed)
	
		dots.add(snakeDot)		
	}

	method eat() {
		const speed = self.getSpeed()
		const lastPos = dots.head().position()
		const newDot = []
		
		if(x_movement)
			newDot.add(new SnakeDot(x = lastPos.x() - speed, y = lastPos.y()))
		else
			newDot.add(new SnakeDot(x = lastPos.x(), y = lastPos.y() - speed))
			
		length += 1
		game.addVisual(newDot.head())
			
		dots = newDot + dots
	}

	method removeLastDot() {
		const snakeDot = dots.head()
		length -= 1
		dots.remove(snakeDot)
		return snakeDot
	}
	
	method addDot(dot) {
		dots.add(dot)
	}
}

object snake {
	const property parts = []
	var cambiando = false
	
	method getLastDot() {
		var lastSegment = parts.head()
		
		if(lastSegment.length() == 0) {
			parts.remove(lastSegment)
			lastSegment = parts.head()
		}
			
		return lastSegment.removeLastDot()
	}
	
	method limpiarSerpiente() {
		parts.clear()
	}
	
	method stopTick() = game.removeTickEvent("gameClock")
	method resetTick() = game.onTick(100 + foodDot.delay() - 65 * (self.getTotalLength().min(25) / 25), "gameClock", { self.moveSnake() })
	
	method changeMovement(newX, newPos) {
		if(newX != parts.last().x_movement() && !cambiando) {
			cambiando = true
			self.stopTick()
			const lastDot = self.getLastDot()
			
			if(!self.seguirDelOtroLado(lastDot, newX, newPos)) {
			
				const newSegment = new SnakeSegment(pos_movement = newPos, x_movement = newX)
				const prevDot = self.posicionHead()
			
				newSegment.initialDot(prevDot.x(), prevDot.y(), lastDot)
			
				if(newSegment.dots().head().position() == foodDot.position()) {
					foodDot.effect()
				}
			
				parts.add(newSegment)
			}
			self.resetTick()
			cambiando = false
			self.verSiPerdio()
		}
	}
	
	// Antes de usar el metodo es recomentado parar el tick del reloj
	method eat() {
		var last = parts.head()
		
		if(last.length() == 0) {
			parts.remove(last)
			last = parts.head()
		}
		
		last.eat()
	}
	
	method getTotalLength() {
		var length = 0
		
		parts.forEach({ part => 
			length += part.length()
		})
		
		return length
	}
	
	method obtenerHead() = parts.last().dots().last()
	
	method posicionHead() = self.obtenerHead().position()
	
	method seguirDelOtroLado(dot, x_mov, pos_mov) {
		cambiando = true
		// Posiciones de la cabeza
		const x = self.posicionHead().x()
		const y = self.posicionHead().y()
		
		// Se podria simplificar con if anidados pero queda un choclo horrible
		// Capaz no es lo mejor pero es mas legible
		const cond1 = x <= 0 && !pos_mov && x_mov
		const cond2 = x >= game.height() - 1 && pos_mov && x_mov
		const cond3 = y <= 0 && !pos_mov && !x_mov
		const cond4 = y >= game.height() - 1 && pos_mov && !x_mov
				
		if(cond1 || cond2 || cond3 || cond4) {
			const newSegment = new SnakeSegment(x_movement = x_mov, pos_movement = pos_mov)
			
			if(cond1)
				dot.changePos(game.height() - 1, y)
			else if(cond2)
				dot.changePos(0, y)
			else if(cond3)
				dot.changePos(x, game.height() - 1)
			else if(cond4)
				dot.changePos(x, 0)
			
			newSegment.addDot(dot)
			parts.add(newSegment)
			
			cambiando = false
			return true	
		} else {
			cambiando = false
			return false
		}
	}
	
	method moveSnake() {
		const lastDot = self.getLastDot()
		const lastSegment = parts.last()
		
		if(!self.seguirDelOtroLado(lastDot, lastSegment.x_movement(), lastSegment.pos_movement()))
			parts.last().addMoveDot(lastDot)
		
		const pos = self.posicionHead()
		
		if(pos == foodDot.position()) {
			self.stopTick()
			foodDot.effect()
			self.resetTick()
		}
		
		console.println(pos)
		
		self.verSiPerdio()
	}
	
	method verSiPerdio() {
		const dot = self.obtenerHead()
		
		if(game.hasVisual(dot)) {
			const colliders = game.colliders(dot)
			if(colliders.size() > 1 || (colliders.size() == 1 && !colliders.contains(foodDot))) {
				snakeManager.perdio()
				parts.clear()
			}
		}
		
	}
	
	// Para iniciar el juego
	method snakeInit() {
		const newSegment = new SnakeSegment(pos_movement = true, x_movement = false)
		
		newSegment.initialSnake()
		parts.add(newSegment)
	}
}