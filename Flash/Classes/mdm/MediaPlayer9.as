 /**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.MediaPlayer9
{
	/* events */
	var onWMP9Buffering : Function
	var onWMP9ChangeState : Function
	var onWMP9Error : Function
	var onWMP9PositionChanged : Function
	/* constructor */
	function MediaPlayer9 ()
	/* methods */
	function close () : Void
	function fastForward () : Void
	function fastReverse () : Void
	function hide () : Void
	function isAvailable () : Boolean
	function mute () : Void
	function noMenu () : Void
	function pause () : Void
	function play () : Void
	function show () : Void
	function stop () : Void
	function unMute () : Void
	/* properties */
	var balance : Number
	var currentMarker : Number
	var duration : Number
	var height : Number
	var isInstalled : Boolean
	var markerCount : Number
	var mediaName : String
	var mediaHeight : Number
	var mediaWidth : Number
	var position : Number
	var volume : Number
	var visible : Boolean
	var width : Number
	var x : Number
	var y : Number
}
