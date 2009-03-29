/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.ActiveX {
	/* events */
	/* constructor */
	function ActiveX();
	/* methods */
	function addMethodParam(paramID:Number, paramType:String, paramValue):Void;
	function close():Void;
	function doVerbCustom(verbID:Number):Void;
	function doVerbDiscardUndoState():Void;
	function doVerbHide():Void;
	function doVerbInPlaceActivate():Void;
	function doVerbPrimary():Void;
	function doVerbOpen():Void;
	function doVerbShow():Void;
	function doVerbUIActivate():Void;
	function getProperty(propertyName:String):String;
	function hide():Void;
	function loadObject(fileName:String):Void;
	function runMethod(methodName:String, numArguments:String):Void;
	function runMethodRet(methodName:String, numArguments:Number):Void;
	function saveDoc(fileName:String):Void;
	function saveObject(fileName:String):Void;
	function setProperty(propertyName:String, propertyType:String, newValue:String):Void;
	function show():Void;
	/* properties */
	var height:Number;
	var visible:Boolean;
	var width:Number;
	var x:Number;
	var y:Number;
}
