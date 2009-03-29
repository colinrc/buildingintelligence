/*
*
* @author	MDM
* @version	1.0.0
*/
intrinsic class mdm.Database.MySQL {
	/* events */
	/* constructor */
	/* methods */
	static function close():Void;
	static function connect(host:String, port:String, compression:Boolean, userName:String, password:String, databaseName:String):Boolean;
	static function getData():Array;
	static function getField(rowIndex:Number, columnIndex:Number):String;
	static function getLastError():String;
	static function getLastInsertedId():Number;
	static function getRecordCount():Number;
	static function getStatus():String;
	static function isConnected():Boolean;
	static function runQuery(query:String):Boolean;
	/* properties */
}
