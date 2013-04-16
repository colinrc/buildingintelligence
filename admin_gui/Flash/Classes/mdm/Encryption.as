/**
* @author	MDM
* @version	1.0.0
*/
intrinsic class mdm.Encryption {
	/* events */
	/* constructor */
	/* methods */
	static function decryptFile(key:String, inputFile:String, outputFile:String):Void;
	static function decryptString(key:String, dataToDecrypt:String):String;
	static function encryptFile(key:String, inputFile:String, outputFile:String):Void;
	static function encryptString(key:String, dataToEncrypt:String):String;
	/* properties */
}
