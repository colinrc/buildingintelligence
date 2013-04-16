/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Network.Mail {
	/* events */
	/* constructor */
	/* methods */
	static function send(serverName:String, username:String, password:String, from:String, to:String, bcc:String, subject:String, body:String, attachementsPath:String):Void;
	static function sendNoAuth(serverName:String, username:String, password:String, from:String, to:String, bcc:String, subject:String, body:String, attachementsPath:String):Void;
	static function sendClientSide(to:String, subject:String, body:String, attachementsPath:String):Void;
	/* properties */
}
