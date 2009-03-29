/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Network.HTTPD {
	/* events */
	static var onRequest:Function;
	/* constructor */
	/* methods */
	static function resume():Void;
	static function setResponse(responseString:String):Void;
	static function startServer(serverPort:Number):Void;
	static function stopServer():Void;
	/* properties */
}
