/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Input.Mouse {
	/* events */
	/* constructor */
	/* methods */
	static function getPosition():Array;
	static function generateEvent(event:String, x:Number, y:Number, restorePosition:Boolean):Void;
	static function setCursor(cursorType:String):Void;
	static function setPosition(x:Number, y:Number):Void;
	static function show():Void;
	static function hide():Void;
	/* properties */
}
