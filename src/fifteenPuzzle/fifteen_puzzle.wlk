import wollok.game.*
import gameManager.*

// 15 PUZZLE //

// tablero
object board {
	// Piezas
	const property pieces = []
	// Dimensiones
	var x_tablero
	var y_tablero
	var piece_side
	// Límites
	var property uplimit
	var property downlimit
	var property rightlimit
	var property leftlimit
	var property origin
	// Movimientos hechos
	var property moves = 0
	
	// Se llama con cada movimiento exitoso
	method addMove() { moves += 1 }
	
	// Posiciona el tablero en el centro
	method center(x, y, p_side){
		piece_side = p_side
		x_tablero = (x/2).truncate(0) - piece_side*2
		y_tablero = (y/2).truncate(0) - piece_side*2 + 1
	}
	// Límites del tablero
	method limits(){
		uplimit = self.coord_to_pos([[0,3],[1,3],[2,3],[3,3]])
		downlimit = self.coord_to_pos([[0,0],[1,0],[2,0],[3,0]])
		rightlimit = self.coord_to_pos([[3,0],[3,1],[3,2],[3,3]])
		leftlimit = self.coord_to_pos([[0,0],[0,1],[0,2],[0,3]])
		origin = self.coord_to_pos_elem([0,0])
	}
	method coord_to_pos(lista){
		return lista.map({ elem => self.coord_to_pos_elem(elem) }) // warning rarísimo gracias wollok wtf
	}
	method coord_to_pos_elem(elem){
		const x = x_tablero + (elem.get(0))*(piece_side)
		const y = y_tablero + (elem.get(1))*(piece_side)
		return game.at(x,y)
	}
	
	method init(){		
		// Genera las piezas
		15.times({ i =>
			// Posiciones x,y para que se acomoden como 1 2 3 4 \n 5 6 7 8 etc
			// 0,0 es abajo a la izquierda, 4,4 es arriba a la derecha (wollok moment)
			const x = x_tablero + piece_side*((i-1)%4)
			const y = y_tablero + piece_side*(3-((i-1)/4).truncate(0))
			// Metelas en la collection d1 capo
			pieces.add(
				new Piece(
					imgpath = "img/"+i.toString()+".png",
					solvedPos = game.at(x,y),
					position = game.at(x,y)
				)
			)
		})
	}
	method render(){
		// Fondo tablero
		if(!game.hasVisual(fondo))
			game.addVisualIn(fondo, game.at(x_tablero-1, y_tablero-1))
		// Se dibujan las piezas
		pieces.forEach({
			piece => piece.render()
		})
	}
	method checkWin(){
		if(pieces.all({ piece => piece.solved() })){
			// Sonidito molesto
			const musica = game.sound("sounds/victoria.mp3")
			// No sé por qué lo ejecuta cien millones de veces si no está esto
			if(!musica.played())
				musica.play()
				
			game.clear() // Para que no puedan mover más las piezas, Wollok no me deja sacar un key event...
			self.render() // ah pero también me borra todas las visuales xd Gracias Wollok
				
			self.printScore(moves) // Muestra puntaje
			moves = 0 // Lo reinicia por si juegan de nuevo
			
			// Muestra titilando el "R para volver"
			game.onTick(500, "volver_15", {
				if (game.hasVisual(rParaVolver))
					game.removeVisual(rParaVolver)
				else
					game.addVisual(rParaVolver)
			})
			// Tocar R
			keyboard.r().onPressDo {
				// esto lo puse en un try/catch porque medio que hacía un bounce y lo intentaba sacar más de una vez
				try
					game.removeTickEvent("volver_15")
				then always
					fifteen_puzzle.close()
			}
		}
	}
	method scramble(){
		// Tienen que producirse una cantidad par de swaps para que se pueda resolver
		100.times({ i =>
			const p1 = pieces.anyOne()
			pieces.remove(p1) // para no tomar la misma de nuevo
			const p2 = pieces.anyOne()
			pieces.add(p1)
			if(p1!=p2){
				const temppos = p1.position()
				p1.position(p2.position())
				p2.position(temppos)
			}
		})
	}
	method printScore(score){
		// Límites del recuadro superior
		const izq = game.width()
		const top = game.height() - 2
		
		// Los dígitos (tomados así en vez de con .charAt() porque es de longitud variable! (120, 95, 1??) )
		const m_num = score.div(100).toString()
		const d_num = (score.div(10) % 10).toString()
		const u_num = (score % 10).toString()
		// objetos ScoreNumber
		const miles = new ScoreNumber(img="fifteen_scoreimgs/"+m_num+".png", position=game.at(izq-9,top))
		const decenas = new ScoreNumber(img="fifteen_scoreimgs/"+d_num+".png", position=game.at(izq-6,top))
		const unidades = new ScoreNumber(img="fifteen_scoreimgs/"+u_num+".png", position=game.at(izq-3,top))
		// Mostrándolos
		game.addVisual(miles)
		game.addVisual(decenas)
		game.addVisual(unidades)
		game.addVisual(movimientosText)
	}
}

// pieza
class Piece {
	const imgpath = null
	const solvedPos = game.origin()
	var property position = game.origin()
	
	// Dibujando el tablero
	method render(){
		if(game.hasVisual(self))
			game.removeVisual(self)
		game.addVisualIn(self, position)
	}
	
	// Moviendo piezas
	method up(piece_side) {
		self.trymove(board.uplimit(), position.up(piece_side))
	}
	method down(piece_side) {
		self.trymove(board.downlimit(), position.down(piece_side))
	}
	method left(piece_side) {
		self.trymove(board.leftlimit(), position.left(piece_side))
	}
	method right(piece_side) {
		self.trymove(board.rightlimit(), position.right(piece_side))
	}
	
	// Se mueve si no se sale del tablero y si no hay otra pieza en el lugar
	method trymove(bads, destino){
		const ocupado = (game.getObjectsIn(destino).size() != 0)
		if(!ocupado && bads.all({dest => dest!=position})){ //warning extraño
			position = destino
			board.addMove()
		}
	}
	
	// Cosas de Wollok Game
	method image() = imgpath
	method solved() { return position == solvedPos }
}

// Textos en pantalla (fondo, volver, puntaje final)

object fondo {
	const img = "img/background.png"
	method image() = img
}
object rParaVolver {
	const position = game.origin()
	const img = "img/r_para_volver_15.png"
	method image() = img
	method position() = position
}
class ScoreNumber {
	const img
	const position
	method image() = img
	method position() = position
}
object movimientosText {
	const img = "fifteen_scoreimgs/movimientos.png"
	const position = game.at(1, game.height()-2)
	method image() = img
	method position() = position
}

////////////////////////////////
///////// OBJETO JUEGO /////////
////////////////////////////////

object fifteen_puzzle{	
	var piece_side //en celdas
	
	// Fija variables, crea piezas y tablero, centra el tablero, mezcla el puzzle
	method init(x, y, piecelen, cellsize){

		piece_side = (piecelen/cellsize).truncate(0) //pixel a celdas
		
		board.center(x, y, piece_side) //centrar tablero
		board.limits() //hallar límites del tablero
		
		board.init()
		board.scramble()
	}
	
	// Eventos de teclado
	method init_keyboard_events() {
		keyboard.r().onPressDo{
			self.close()
		}
		// Se ve un poco repetido el código acá, pero no se
		// me ocurrió cómo hacerlo mejor
		keyboard.up().onPressDo{
			board.pieces().forEach({
				piece => piece.up(piece_side)
			})
			board.render()
			board.checkWin()
		}
		keyboard.down().onPressDo{
			board.pieces().forEach({
				piece => piece.down(piece_side)
			})
			board.render()
			board.checkWin()
		}
		keyboard.left().onPressDo{
			board.pieces().forEach({
				piece => piece.left(piece_side)
			})
			board.render()
			board.checkWin()
		}
		keyboard.right().onPressDo{
			board.pieces().forEach({
				piece => piece.right(piece_side)
			})
			board.render()
			board.checkWin()
		}
	}
	
	// Dibuja el tablero y comienza el juego
	method start(){
		game.clear()
		self.init_keyboard_events()
		
		board.render()
		game.addVisual(rParaVolver)
	}
	
	method close(){
		// Para asegurarse de que no siga
		if (game.hasVisual(rParaVolver))
			game.removeVisual(rParaVolver)
		gameManager.mostrarMenu()
		board.scramble()
	}
}