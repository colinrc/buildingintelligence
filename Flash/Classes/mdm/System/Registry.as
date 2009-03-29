/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.System.Registry {
	/* events */
	/* constructor */
	/* methods */
	static function createKey(keyBranchID:Number, keyName:String, keyDefaultValue:String):Void;
	static function deleteKey(keyBranchID:Number, keyName:String):Void;
	static function deleteTree(keyBranchID:Number):Void;
	static function getKeyNames(keyBranchID:Number, keyName:String):Array;
	static function getValueNames(keyBranchID:Number, keyName:String):Array;
	static function hasSubKeys(keyBranchID:Number, keyName:String):Boolean;
	static function keyExists(keyBranchID:Number, keyName:String):Boolean;
	static function load(keyBranchID:Number, keyName:String):String;
	static function loadBoolean(keyBranchID:Number, keyName:String, keyNameValue:String):String;
	static function loadInteger(keyBranchID:Number, keyName:String, keyNameValue:String):Number;
	static function loadString(keyBranchID:Number, keyName:String, keyNameValue:String):String;
	static function loadMultiSz(keyBranchID:Number, keyName:String, keyNameValue:String):String;
	static function save(keyName:String, keyValue:String):Void;
	static function saveInteger(keyBranchID:Number, keyName:String, keyNameValue:String, keyNameData:Number):Void;
	static function saveString(keyBranchID:Number, keyName:String, keyNameValue:String, keyNameData:String):Void;
	static function saveMultiSz(keyBranchID:Number, keyName:String, keyNameValue:String, keyNameData:String):Void;
	/* properties */
}
