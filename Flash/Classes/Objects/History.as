/**
    Name: History
	Description: This class is used to record changes that occur in a project.
    author: Jeff 
    version: 0.1
    modified: 20060116
    copyright: Building Intelligence
*/
import mdm.FileSystem.*;
class Objects.History {
	//The history stored as xml
	private var history:XML;
	private static var instance:Objects.History = null;
	private var projectName:String;
	private var fileName:String;
	private var defaultDirectory:String = "C:\\eLifeAdmin\\";
	
	public function History(overideDefaultDirectory:String) {
		if (overideDefaultDirectory.length > 0) {
			defaultDirectory = overideDefaultDirectory;
		}
	}
	
	/*
	Call getInstance to create an instance of this class.
	This code implements the Singleton class.
	*/
	public static function getInstance():Objects.History {
		if (Objects.History.instance == null) {
			Objects.History.instance = new Objects.History();
		}
		return Objects.History.instance;
	}
	/*
	Call setProject straight after you call getInstance.
	*/
	public function setProject(project:String) {
		projectName = project;
		fileName = defaultDirectory + projectName;
		var date_str:String = getDateTime();
		if (mdm.FileSystem.fileExists(fileName) ) {
			
			mdm.FileSystem.appendFile(fileName, "Modified: " + date_str);
			mdm.FileSystem.appendFile(fileName,"-----------------------------------------------------------------");
		} 
		else
		{
			trace("Savefile " + fileName);
			mdm.FileSystem.saveFile(fileName, "Project: " + projectName);
			mdm.FileSystem.appendFile(fileName, "Created: " + date_str);
			mdm.FileSystem.appendFile(fileName,"-----------------------------------------------------------------");
		}									  
	}
	
	/*	
		Attributes that may be passed into the following 3 methods
		category is the high level grouping
		type is a more specific detail.
		description is free text for any additional information
		oldValues contains what is to be changed or deleted.
		newValues contains what is to be changed or created.
	*/
	// Function changed used when a value already exists
	public function changed(category:String, type:String, description:String, oldValues:Object, newValues:Object):Void{
		mdm.FileSystem.appendFile(fileName,"CHANGED:" + getDateTime() + " CAT:"+category+ " Type:"+type+ " DESC:"+description + "OLDVALUE:"+oldValues.toString() + "NEWVALUE:" + newValues.toString());
	}
	
	// Function created used when a new value is used without an existing one.
	public function created(category:String, type:String, description:String, newValues:Object){
		mdm.FileSystem.appendFile(fileName,"CREATED:" + getDateTime() + " CAT:"+category+ " Type:"+type+ " DESC:"+description + "NEWVALUE:" + newValues.toString());
	}
	
	// Function deleted is used when an existing value is removed.
	public function deleted(category:String, type:String, description:String, oldValues:Object){
		mdm.FileSystem.appendFile(fileName,"DELETED:" + getDateTime() + " CAT:"+category+ " Type:"+type+ " DESC:"+description + "OLDVALUE:"+oldValues.toString());
	}
	
	// Returns the current dateTime
	private function getDateTime():String {
		var today_date:Date = new Date();
		var date_str:String = today_date.getFullYear()+(today_date.getMonth()+1)+today_date.getDate() + today_date.getHours+":"+today_date.getMinutes+":"+today_date.getSeconds;
		return date_str;
	}
	
	/* Used by the History UI screen to display history information*/
	public function viewHistory():String{
		var mySavedData = mdm.FileSystem.loadFile(fileName);

		return mySavedData;
	}
}