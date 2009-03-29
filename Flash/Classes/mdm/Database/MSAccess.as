/*
*
* @author	MDM
* @version	1.0.0
*/
intrinsic class mdm.Database.MSAccess {
	/* events */
	/* constructor */
	/* methods */
	static function close():Void;
	static function compact(fileName:String, databaseVersion:String, databasePassword:String):Void;
	static function connect(filename:String, databasePassword:String):Void;
	static function connectAbs(filename:String, databasePassword:String):Void;
	static function connectReadOnly(filename:String, databasePassword:String):Void;
	static function connectReadOnlyAbs(filename:String, databasePassword:String):Void;
	static function error():Boolean;
	static function errorDetails():String;
	static function getBlob(fieldName:String, fieldRow:Number, fileName:String):Void;
	static function getData():Array;
	static function getField(rowIndex:Number, columnIndex:Number):String;
	static function getHTML():String;
	static function getRecordCount():Number;
	static function getXML():String;
	static function runQuery(query:String):Void;
	static function select(query:String):Void;
	static function success():Boolean;
	/* properties */
}
