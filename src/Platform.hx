package;
import openfl.display.Sprite;

/**
 * ...
 * @author Shivank
 */
class Platform  extends Sprite
{
	public function new(x:Int, y:Int) 
	{
		super();
		this.x = x;
		this.y = y;
		this.graphics.beginFill(0xFFFFFF);
		this.graphics.drawRect(0, 0, 15, 100);
		this.graphics.endFill();
	}
	
}