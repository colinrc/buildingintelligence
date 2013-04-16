/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Network.UDP.TFTP {
	/* events */
	/* constructor */
	function TFTP();
	/* methods */
	function abort():Void;
	function getFile(remoteIPAddress:String, remotePortNumber:Number, localFilePath:String, remoteFilePath:String):Void;
	function getProgressCurrent():Number;
	function getProgressMax():Number;
	function sendFile(remoteIPAddress:String, remotePortNumber:Number, localFilePath:String, remoteFilePath:String):Void;
	function setBuffer():Void;
	function setBlockSize(blockSize:Number):Void;
	function startServer(localPortNumber:Number):Void;
	function setTimeout(timeout:Number):Void;
	function setTransferMode(transferMode:String):Void;
	function stopServer():Void;
	/* properties */
}
