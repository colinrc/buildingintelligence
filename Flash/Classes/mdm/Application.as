/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Application {
	/* events */
	static var onAppChangeFocus:Function;
	static var onAppExit:Function;
	static var onAppMinimize:Function;
	static var onAppRestore:Function;
	static var onArrowKeyPress:Function;
	static var onBottomHit:Function;
	static var onDragDrop:Function;
	static var onLeftHit:Function;
	static var onMDMScriptException:Function;
	static var onMDMScriptExceptionOSX:Function;
	static var onRightHit:Function;
	static var onSplashClosed:Function;
	static var onTopHit:Function;
	static var onFormChangeFocus:Function;
	static var onFormClose:Function;
	static var onFormMaximize:Function;
	static var onFormMinimize:Function;
	static var onFormReposition:Function;
	static var onFormResize:Function;
	static var onFormRestore:Function;
	/* constructor */
	/* methods */
	static function delay(delay:Number):Void;
	static function doEvents():Void;
	static function enableExitHandler():Void;
	static function exit():Void;
	static function exitWithCode(exitCode:Number):Void;
	static function exitWithModalResult(modalResult:String):Void;
	static function getCMDParams(cmdID:Number):String;
	static function getEnvar(varName:String):String;
	static function getSecureVar(varName:String):String;
	static function hideStatusBar():Void;
	static function maximize():Void;
	static function minimize():Void;
	static function minimizeToTray(enable:Boolean):Void;
	static function printVar(varToPrint:String, showPrintDialog:Boolean):Void;
	static function restore():Void;
	static function say(text2speech:String):Void;
	static function setEnvar(varName:String, varValue:String):Void;
	static function shake(shakeTime:Number):Void;
	static function showTips(tips:String, tip:String):Boolean;
	static function statusBar():Void;
	static function setStatusBarText(text:String):Void;
	static function textAreaEnhance(enhance:Boolean):Void;
	/* properties */
	static var filename:String;
	static var filenameUnicode:String;
	static var filenameUnix:String;
	static var isMinimized:Boolean;
	static var path:String;
	static var pathUnicode:String;
	static var pathUnix:String;
	static var title:String;
	static var windowTitle:String;
}
