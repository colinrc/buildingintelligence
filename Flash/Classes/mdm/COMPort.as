/**
* @author	MDM
* @version	1.0.0
* @version 	1.0.1	sendHEXData method added
*/
intrinsic class mdm.COMPort {
	/* events */
	static var onCOMPortCTSChanged:Function;
	static var onCOMPortDSRChanged:Function;
	static var onCOMPortData:Function;
	static var onCOMPortDataSent:Function;
	static var onCOMPortError:Function;
	static var onCOMPortHEXData:Function;
	static var onCOMPortSendProgress:Function;
	/* constructor */
	/* methods */
	static function close():Void;
	static function open(port:Number, baudRate:Number, byteSize:Number, parity:String, dataBits:Number, flowControl:String):Void;
	static function send(value:String):Void;
	static function sendFileContents(fileName:String):Void;
	static function sendHEXData(hexData:String):Void;
	static function setBreak():Void;
	static function setDTR():Void;
	static function setEcho(enable:Boolean):Void;
	static function setRTS():Void;
	static function setXON():Void;
	static function setXOFF():Void;
	static function unsetBreak():Void;
	static function unsetDTR():Void;
	static function unsetRTS():Void;
	static function useLineMode(enable:Boolean, lineStr:String):Void;
	static function useThreshold(enable:Boolean, threshold:Number):Void;
	/* properties */
	static var initialDTR:String;
	static var initialRTS:String;
	static var ports:String;
}
