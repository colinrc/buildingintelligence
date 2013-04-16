/**
* @author 	MDM
* @version 	1.0.0
* @version 	1.0.1 getHDSerial method added
*/
intrinsic class mdm.System {
	/* events */
	/* constructor */
	/* methods */
	static function closeCDTray(driveLetter:String):Void;
	static function exec(exePath:String):Void;
	static function execStdOut(exePath:String):Void;
	static function execUnicode(exePath:String):Void;
	static function getDisplayModes():String;
	static function getFreeSpace(driveLetter:String):Number;
	static function getHDSerial(driveLetter:String):String;
	static function getMasterVolume():Number;
	static function getWindowFocus():String;
	static function getWindowList():Array;
	static function getResolution():String;
	static function hibernate(promptOption:String, messageText:String):Void;
	static function hideTaskBar():Void;
	static function logOff(promptOption:String, messageText:String):Void;
	static function openCDTray(driveLetter:String):Void;
	static function powerOff(promptOption:String, messageText:String):Void;
	static function restart(promptOption:String, messageText:String):Void;
	static function sendMessage(windowID:Number, messageNo:Number, wParam:Number, lParam:Number):Void;
	static function setMasterVolume(volumeLevel:Number):Void;
	static function setResolution(resolutionX:Number, resolutionY:Number):Void;
	static function setWindowFocus(windowID:Number):Void;
	static function setWaveVolume(volumeLevel:Number):Void;
	static function setWaveVolumeAdv(leftVolumeLevel:Number, rightVolumeLevel:Number):Void;
	static function setWaveBalance(volumeBalance:Number):Void;
	static function setWallpaper(filePath:String):Void;
	static function setWallpaperAlt(filePath:String):Void;
	static function showTaskBar():Void;
	static function suspend(promptOption:String, messageText:String):Void;
	static function taskBarBlink():Void;
	/* properties */
	static var computerCompany:String;
	static var computerName:String;
	static var computerOwner:String;
	static var CPUSpeed:Number;
	static var CDDrive:String;
	static var hdSerial:String;
	static var isAdmin:Boolean;
	static var IPAddress:String;
	static var localTime:Date;
	static var language:String;
	static var macVerString:String;
	static var networkIsPresent:Boolean;
	static var osVersion:String;
	static var RAMSize:Number;
	static var screenHeight:Number;
	static var screenWidth:Number;
	static var servicePack:String;
	static var winVerString:String;
	static var winVerStringDetail:String;
}
