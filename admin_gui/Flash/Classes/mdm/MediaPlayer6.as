 /**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.MediaPlayer6
{
	/* events */
	var onMPChangeState : Function
	/* constructor */
	function MediaPlayer6 ()
	/* methods */
	function close () : Void
	function fastForward () : Void
	function fastRewind () : Void
	function hide () : Void
	function mute (muteFlag : Boolean) : Void
	function noMenu () : Void
	function pause () : Void
	function play () : Void
	function show () : Void
	function stop () : Void
	/* properties */
	var balance : Number
	var duration : Number
	var height : Number
	var isInstalled : Boolean
	var position : Number
	var volume : Number
	var visible : Boolean
	var width : Number
	var x : Number
	var y : Number
}
