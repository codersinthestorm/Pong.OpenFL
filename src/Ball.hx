package;
import openfl.display.Sprite;

/**
 * ...
 * @author Shivank
 */

class Ball extends Sprite
{
	public function new(x:Int, y:Int) 
	{
		super();
		this.x = x;
		this.y = y;		
		this.graphics.beginFill(0xFFFFFF);
		this.graphics.drawCircle(0, 0, 10);
		this.graphics.endFill();
	}	
}