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
	public function History() {
	}
	/*
	Call setProject when opening a project or creating a new one
	*/
	public function setProject(project:String, overideDefaultDirectory:String) {
		/*if (overideDefaultDirectory.length>0) {
		defaultDirectory = overideDefaultDirectory;
		}
		projectName = project;
		var ret:String = chr(13);
		fileName = defaultDirectory+projectName+".log";
		var date_str:String = getDateTime();
		if (mdm.FileSystem.fileExists(fileName)) {
		mdm.FileSystem.appendFile(fileName, "Modified: "+date_str+ret);
		mdm.FileSystem.appendFile(fileName, "--------------------------------------------------------------------------------------------------------------------------"+ret);
		} else {
		if (mdm.FileSystem.folderExists(defaultDirectory)) {
		mdm.FileSystem.saveFile(fileName, "Project: "+projectName+ret);
		mdm.FileSystem.appendFile(fileName, "Created: "+date_str+ret);
		mdm.FileSystem.appendFile(fileName, "--------------------------------------------------------------------------------------------------------------------------"+ret);
		} else {
		mdm.FileSystem.makeFolder(defaultDirectory);
		mdm.FileSystem.saveFile(fileName, "Project: "+projectName+ret);
		mdm.FileSystem.appendFile(fileName, "Created: "+date_str+ret);
		mdm.FileSystem.appendFile(fileName, "--------------------------------------------------------------------------------------------------------------------------"+ret);
		}
		}*/
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
	public function changed(category:String, type:String, description:String, oldValues:Object, newValues:Object):Void {
		//	mdm.FileSystem.appendFile(fileName, "CHANGED:"+getDateTime()+" CAT:"+category+" Type:"+type+" DESC:"+description+" OLDVALUE:"+oldValues.toString()+" NEWVALUE:"+newValues.toString()+"\n");
	}
	// Function created used when a new value is used without an existing one.
	public function created(category:String, type:String, description:String, newValues:Object) {
		//	mdm.FileSystem.appendFile(fileName, "CREATED:"+getDateTime()+" CAT:"+category+" Type:"+type+" DESC:"+description+" NEWVALUE:"+newValues.toString()+"\n");
	}
	// Function deleted is used when an existing value is removed.
	public function deleted(category:String, type:String, description:String, oldValues:Object) {
		//	mdm.FileSystem.appendFile(fileName, "DELETED:"+getDateTime()+" CAT:"+category+" Type:"+type+" DESC:"+description+" OLDVALUE:"+oldValues.toString()+"\n");
	}
	//Returns the current dateTime
	private function getDateTime():String {
		var today_date:Date = new Date();
		var time_str:String = today_date.getHours().toString()+":"+today_date.getMinutes().toString()+":"+today_date.getSeconds().toString();
		var date_str:String = today_date.getDate().toString()+" "+getMonthAsString(today_date.getMonth())+" "+today_date.getFullYear().toString()+" "+time_str;
		return date_str;
	}
	private function getMonthAsString(month:Number):String {
		var monthNames_array:Array = new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
		return monthNames_array[month];
	}
	/* Used by the History UI screen to display history information*/
	public function viewHistory():String {
		if (mdm.FileSystem.fileExists(fileName)) {
			var mySavedData = mdm.FileSystem.loadFile(fileName);
		} else {
			mySavedData = "";
		}
		return mySavedData;
	}
}
