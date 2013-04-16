 /**
* @author 	MDM
* @version 	1.0.0
* @version 	1.0.1 added: IPAddress property, isPresent property
*/
intrinsic class mdm.Network
{
	/* events */
	/* constructor */
	/* methods */
	static function checkConnection () : Boolean
	static function checkConnectionAdv () : String
	static function checkConnectionPing (remoteAddress : String, timeout : Number) : Boolean
	static function getIPByHost (hostName : String) : String
	static function getMacAddress (adapterID : Number) : String
	static function getURL (url : String) : Void
	/* properties */
	static var IPAddress:String;
	static var isPresent:Boolean;
}
