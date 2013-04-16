/*
*
* @author	MDM
* @version	1.0.0
*/
intrinsic class mdm.Database.ADO {
	/* events */
	/* constructor */
	/* methods */
	static function close():Void;
	static function connect(adoString:String):Void;
	static function error():Boolean;
	static function errorDetails():String;
	static function getBlob(fieldName:String, fieldRow:Number, fileName:String):Void;
	static function getData():Array;
	static function getField(fieldName:String, fieldRow:Number):String;
	static function getHTML():String;
	static function getRecordCount():Number;
	static function getXML():String;
	static function runQuery(query:String):Void;
	static function select(query:String):Void;
	static function success():Boolean;
	/* properties */
}
