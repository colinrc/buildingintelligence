 /**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Image
{
	/* events */
	/* constructor */
	/* methods */
	static function bmpToJpg (inputFilePath : String) : Void
	static function bmpToJpgAdv (inputFilePath : String, compressionQuality : Number) : Void
	static function bmpToPng  (inputBmpFilePath : String, outputPngFilePath : String, use256Color : Boolean, transparentColor : String) : Void
	static function getJpgSize (filePath : String) : Array
	static function getSwfHeader (filePath : String) : Array
	static function jpgToSwf (inputJpgFilePath : String) : Void
	static function jpgToSwfSlideShow (frameRate : Number, inputJpgFiles : String, frameGap : String, outputFilePath : String, width : Number, height : Number) : Void
	static function pngToSwf (inputPngFilePath : String) : Void
	static function pngToSwfTransparent (inputPngFilePath : String) : Void
	static function setJpgSize (inputFilePath : String, width : Number, height : Number, outputFilePath : String, antialiasingRation : Number) : Void
	/* properties */
}
