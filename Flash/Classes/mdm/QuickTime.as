/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.QuickTime {
	/* events */
	/* constructor */
	function QuickTime();
	/* methods */
	function close():Void;
	function hide():Void;
	function hideControl():Void;
	function mute():Void;
	function play():Void;
	function show():Void;
	function showControl():Void;
	function stop():Void;
	/* properties */
	var duration:Number;
	var height:Number;
	var isInstalled:Boolean;
	var position:Number;
	var visible:Boolean;
	var width:Number;
	var x:Number;
	var y:Number;
}
