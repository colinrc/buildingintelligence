/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Network.UDP.Socket {
	/* events */
	static var onData:Function;
	/* constructor */
	/* methods */
	static function broadcast(remotePortNumber:Number, messageText:String):Void;
	static function send(remoteIPAddress:String, remotePortNumber:Number, messageText:String):Void;
	static function startServer(localPortNumber:Number):Void;
	static function stopServer():Void;
	/* properties */
}
