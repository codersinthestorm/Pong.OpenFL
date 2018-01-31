/**
 * ...
 * @author Shivank
 */

package;	

import flash.events.KeyboardEvent;
import flash.geom.Point;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.events.Event;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;


enum GameState {
	Paused;
	Playing;
}

enum Player {
	Human;
	AI;	
}

class Main extends Sprite 
{
	private var currentGameState:GameState;
	private var scoreAI:Int;
	private var scorePlayer:Int;
	
	private var scoreField:TextField;       // display dynamic score.
	private var messageField:TextField;		// display game state: paused/ live.
	
	private var platform1:Platform;
	private var platform2:Platform;
	private var ball:Ball;
	
	private var platformSpeed:Int;
	private var arrowKeyUp:Bool;
	private var arrowKeyDown:Bool;
	
	private var inited: Bool;
	
	private var ballMovement:Point;
	private var ballSpeed:Int;
	
	function resize(e)
	{
		if (!inited)
			init();
	}
	
	private function updateScore():Void
	{
		scoreField.text = scorePlayer + ":" + scoreAI;
	}
	
	private function setGameState(state:GameState):Void
	{
		currentGameState = state;
		updateScore();
		
		if (state == Paused) 			// show message
			messageField.alpha = 1;
		else{
			messageField.alpha = 0;		// hide message
			
			// reset platform location
			platform1.y = 200;
			platform2.y = 200;
			// reset ball location
			ball.x = 250;
			ball.y = 250;
			
			var direction:Int = (Math.random() > 0.5) ? (1) : (-1);
			var randomAngle:Float = (Math.random() * Math.PI / 2) - 45;
			ballMovement.x = direction * Math.cos(randomAngle) * ballSpeed;
			ballMovement.y = Math.sin(randomAngle) * ballSpeed;
		}
	}	
	
	private function bounceBall():Void{
		var direction:Int = (ballMovement.x > 0) ? (-1) : (1);
		var randomAngle:Float = (Math.random() * Math.PI / 2) - 45;
		ballMovement.x = direction * Math.cos(randomAngle) * ballSpeed;
		ballMovement.y = Math.sin(randomAngle) * ballSpeed;
	}
	
	function init()
	{
		if (inited)	
			return;
		inited = true;					
		
		var scoreFormat:TextFormat = createTextFormat("Verdana", 24, 0xbbbbbb, true, TextFormatAlign.CENTER);		
		
		scoreField = createTextField(500, 30, scoreFormat, false);
		addChild(scoreField);		
		
		var messageFormat:TextFormat = createTextFormat("Verdana", 18, 0xbbbbbb, true, TextFormatAlign.CENTER);

		messageField = createTextField(500, 450, messageFormat, false);
		messageField.text = "Press SPACE to start\nUse ARROW KEYS to move your platform";
		addChild(messageField);				
		
		platform1 = new Platform(5, 200);		
		this.addChild(platform1);
		
		platform2 = new Platform(480, 200);
		this.addChild(platform2);
		
		ball = new Ball(250, 250);					
		this.addChild(ball);
		
		scoreAI = 0;
		scorePlayer = 0;		
		arrowKeyDown = arrowKeyUp = false;
		platformSpeed = 7;
		ballSpeed = 7;
		ballMovement = new Point(0, 0);
		setGameState(Paused); 		// initial state = PAUSED
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		this.addEventListener(Event.ENTER_FRAME, everyFrame);
	}
	
	private function everyFrame(event:Event):Void{	
		if (currentGameState == Playing)
		{
			if (arrowKeyUp)
				platform1.y -= platformSpeed;							
			if (arrowKeyDown)
				platform1.y += platformSpeed;

			if (platform1.y < 5)
				platform1.y = 5;
			if (platform1.y > 395)
				platform1.y = 395;
				
			ball.x += ballMovement.x;
			ball.y += ballMovement.y;
			
			if (ball.y < 5 || ball.y > 495)
				ballMovement.y *= -1;
			if (ball.x < 5)
				winGame(AI);
			if (ball.x > 495)
				winGame(Human);
				
			if (ballMovement.x < 0 && ball.x < 30 && ball.y >= platform1.y &&ball.y <= platform1.y + 100) {
				bounceBall();
				ball.x = 30;
			}
			if (ballMovement.x > 0 && ball.x > 470 && ball.y >= platform2.y && ball.y <= platform2.y + 100) {
				bounceBall();
				ball.x = 470;
			}
			
			// AI platform movement
			if (ball.x > 300 && ball.y > platform2.y + 70) {
				platform2.y += platformSpeed;
			}
			if (ball.x > 300 && ball.y < platform2.y + 30) {
				platform2.y -= platformSpeed;
			}
		}
	}
	
	private function winGame(player:Player):Void
	{
		if (player == Human)
			scorePlayer++;
		else	
			scoreAI++;
		setGameState(Paused);
	}
	
	private function keyDown(event:KeyboardEvent):Void
	{
		// if spacebar is pressed, play game.
		if(currentGameState == Paused && event.keyCode == 32) {
			setGameState(Playing);
		}else if (event.keyCode == 38){
			arrowKeyUp = true;			
		}else if(event.keyCode == 40){
			arrowKeyDown = true;
		}
	}
	
	private function keyUp(event:KeyboardEvent):Void {
		if (event.keyCode == 38) { 		// Up
			arrowKeyUp = false;
		}
		else if (event.keyCode == 40) { // Down
			arrowKeyDown = false;
	}
}
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, added);
	}
	
	function added(e)
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		
		#if ios
		haxe.Timer.delay(init, 100);  // iOS 6
		#else
		init();
		#end
	}
	
	public static function main()
	{			
		Lib.current.stage.align = openfl.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = openfl.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
	
	private function createTextFormat(font:String, size:Int, color:Int , bold:Bool, alignment:TextFormatAlign):TextFormat
	{
		var temp:TextFormat = new TextFormat(font, size, color, bold);
		temp.align = alignment;
		return temp;
	}
	
	private function createTextField(width:Int, y:Int, defaultTextFormat:TextFormat, selectable:Bool):TextField
	{
		var temp:TextField = new TextField();
		temp.width = width;
		temp.y = y;
		temp.defaultTextFormat = defaultTextFormat;
		temp.selectable = selectable;
		return temp;
	}
}
