/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.RealMedia {
	/* events */
	/* constructor */
	function RealMedia();
	/* methods */
	function close():Void;
	function hide():Void;
	function fullScreen():Void;
	function mute():Void;
	function play():Void;
	function pause():Void;
	function show():Void;
	function stop():Void;
	/* properties */
	var duration:Number;
	var height:Number;
	var id:Number;
	var isInstalled:Boolean;
	var position:Number;
	var visible:Boolean;
	var width:Number;
	var x:Number;
	var y:Number;
}
