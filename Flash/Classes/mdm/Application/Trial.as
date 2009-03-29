/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Application.Trial {
	/* events */
	/* constructor */
	/* methods */
	static function activate(serial:String):Boolean;
	static function evaluate(serial:String):Boolean;
	static function resetTimer():Void;
	/* properties */
	static var daysLeft:Number;
	static var expired:Boolean;
	static var tampered:Boolean;
	static var usesLeft:Number;
}
