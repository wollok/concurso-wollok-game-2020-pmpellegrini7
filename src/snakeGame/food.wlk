import wollok.game.*
import wollok.lib.*
import snake.snake
import snakeManager.snakeManager

/*
 * Las comidas son polimorficas
*/

object apple {
	const property image = "img/apple.png"
	
	method effect() {
		snake.eat()
	}
}

object manzanaDorada {
	const property image = "img/golden_apple.png"
	
	method effect() {
		5.times({ i => snake.eat() })
	}
}

object rayo {
	const property image = "img/rayopng.png"
	var enEfecto = false
	
	method effect() {
		foodDot.cambiarDelay(-25)
		
		if(enEfecto)
			game.removeTickEvent("efectoRayo")
		
		game.onTick(3000, "efectoRayo", {
			foodDot.cambiarDelay(25)
			enEfecto = false
			game.removeTickEvent("efectoRayo")
		})
	}
}

object foodDot {
	var property selected = apple
	var property position = game.at(5, 5)
	var property delay = 0
	const posibles = [manzanaDorada, apple, rayo]
	method image() = selected.image()
	
	method cambiarDelay(nuevo) {
		delay += nuevo
	}
	
	method effect() {
		selected.effect()
		self.moveDot()
	}
	
	method moveDot() {
		selected = posibles.anyOne()
		const x = 0.randomUpTo(game.width()).truncate(0)
		const y = 0.randomUpTo(game.height()).truncate(0)
		
		position = game.at(x, y)		
				
		if(game.getObjectsIn(self.position()).size() > 1) {
			self.moveDot()
		}
	}
}