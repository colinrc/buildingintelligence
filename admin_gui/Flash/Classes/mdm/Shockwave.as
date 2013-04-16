/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Shockwave {
	/* events */
	/* constructor */
	function Shockwave();
	/* methods */
	function close():Void;
	function evaluateScript(scriptString:String):Void;
	function gotoFrame(frame:Number):Void;
	function gotoMovie(filePath:String):Void;
	function play():Void;
	function rewind():Void;
	function swBackColor(backgroundColor:Number):Void;
	function swBanner(bannerText:String):Void;
	function swColor(instanceColor:Number):Void;
	function swForeColor(foregroundColor:Number):Void;
	function swFrame(frame:Number):Void;
	function swAudio(filePath:String):Void;
	function swList(delimitedKeys:String):Void;
	function swName(nameValue:String):Void;
	function swPassword(passwordValue:String):Void;
	function swPreLoadTime(preloadTime:Number):Void;
	function swSound(filePath:String):Void;
	function swText(nameValue:String):Void;
	function swVolume(soundLevel:Number):Void;
	/* properties */
	var bgcolor:Number;
	var currentFrame:Number;
	var height:Number;
	var visible:Boolean;
	var width:Number;
	var x:Number;
	var y:Number;
}
