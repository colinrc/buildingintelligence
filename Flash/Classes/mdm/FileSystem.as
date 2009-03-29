/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.FileSystem {
	/* events */
	/* constructor */
	/* methods */
	static function appendFile(filePath:String, dataToAdd:String):Void;
	static function appendFileUnicode(filePath:String, dataToAdd:String):Void;
	static function changeDir(newPath:String):Void;
	static function copyFile(copyFrom:String, copyTo:String):Void;
	static function copyFileUnicode(copyFrom:String, copyTo:String):Void;
	static function copyFolder(copyFrom:String, copyTo:String):Void;
	static function createShortcut(targetPath:String, startInFolder:String, description:String, iconFilePath:String, iconID:Number, shorcutLinkPath:String):Void;
	static function deleteFile(pathToFile:String):Void;
	static function deleteFileUnicode(pathToFile:String):Void;
	static function deleteFolder(folderPath:String, prompt:String):Void;
	static function fileExists(filePath:String):Boolean;
	static function fileExistsUnicode(filePath:String):Boolean;
	static function findFile(searchCriteria:String):String;
	static function folderExists(folder:String):Boolean;
	static function folderExistsUnicode(folder:String):Boolean;
	static function getAssociation(extension:String):String;
	static function getFileAttribs(filePath:String):Array;
	static function getCurrentDir():String;
	static function getCurrentDirUnicode():String;
	static function getFileDate(pathToFile:String):String;
	static function getFileSize(pathToFile:String):Number;
	static function getFileTime(pathToFile:String):String;
	static function getFileList(folderPath:String, searchMask:String):Array;
	static function getFolderList(folderPath:String):Array;
	static function getFolderSize(folderPath:String):Number;
	static function getLongPathName(path:String):String;
	static function getShortPathName(path:String):String;
	static function loadFile(filePath:String):String;
	static function loadFileUnicode(filePath:String):String;
	static function makeFolder(folderPath:String):Void;
	static function makeFolderUnicode(folderPath:String):Void;
	static function saveFile(filePath:String, dataToSave:String):Void;
	static function saveFileUnicode(filePath:String, dataToSave:String):Void;
	static function saveFileAttributes(filePath:String, attribute:String):Void;
	/* properties */
}
