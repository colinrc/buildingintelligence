/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Input.Joystick {
	/* events */
	static var onJoystick1ButtonDown:Function;
	static var onJoystick1Move:Function;
	static var onJoystick2ButtonDown:Function;
	static var onJoystick2Move:Function;
	/* constructor */
	/* methods */
	static function enable(joystickID:Number, joystickEmulationType:String):Void;
	static function disable():Void;
	static function setKey(joystickButtonID:Number, keyboardKeyCode:String):Void;
	/* properties */
}
