/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Dialogs {
	/* events */
	/* constructor */
	/* methods */
	static function inputBox(inputTitle:String, defaultText:String):String;
	static function prompt(message:String):Void;
	static function promptUnicode(message:String):Void;
	static function promptAdv(message:String, promptStyle:String):Boolean;
	static function promptAdvUnicode(message:String, promptStyle:String):Boolean;
	static function promptModal(message:String, promptType:String, promptStyle:String):Boolean;
	static function promptModalUnicode(message:String, promptType:String, promptStyle:String):Boolean;
	/* properties */
}
