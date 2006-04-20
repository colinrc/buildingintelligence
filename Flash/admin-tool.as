//Temp
//mdm.Dialogs.prompt();
import mx.managers.PopUpManager;
import mx.containers.Window;
import mx.utils.Delegate;
mdm.Exception.enableHandler();
mdm.Application.onMDMScriptException = function(myObject) {
	/* mdm.Dialogs.prompt("An error has occured on Frame " + myObject.frameNumber);
	   mdm.Dialogs.prompt("Command: " +myObject.command);
	   mdm.Dialogs.prompt("MSG: " +myObject.message);
	   mdm.Dialogs.prompt("Form Type: " +myObject.formType);
	   mdm.Dialogs.prompt("Parameter: " +myObject.parameter);
	   mdm.Dialogs.prompt("Value: " +myObject.value);*/
};
mdm.Application.title = "eLIFE Admin Tool";
mdm.Forms.MainForm.title = "eLIFE Admin Tool";
historyViewer_btn._visible = false;
/*************************************************************************/
//Global style
_global.style.setStyle("themeColor", "haloBlue");
/********************************************************/
// form holder placed in the correct spot
var blocker:MovieClip;
var libraryManager:MovieClip;
this.createEmptyMovieClip("formContent_mc", 0);
formContent_mc._x = 270;
formContent_mc._y = 114;
formContent_mc.tabChildren = true;
formContent_mc.tabEnabled = false;
var form_mc;
form_mc.tabChildren = true;
form_mc.tabEnabled = false;
//Global variables
_global.advanced = false;
_global.unSaved = false;
_global.formDepth = 0;
_global.projectFileName = "";
_global.serverDesign = new Objects.Server.Server();
_global.serverInstance = new Objects.Instances.ServerInstance();
_global.keys = _global.serverDesign.getKeys();
_global.usedKeys = _global.serverDesign.getClients[0].getUsedKeys;
//_global.history = new Objects.History();
/*Workflow tree variables and initialization*/
var right_tree = workFlow_split.setFirstContents("Tree", "right_tree", 0);
var output_panel = workFlow_split.setSecondContents("OutputPanel", "output_panel", 1);
_global.right_tree = right_tree;
_global.output_panel = output_panel;
//_global.output_panel.setDescription("BLAH BLAH BLAH");
//_global.output_panel.setError("YAK YAK YAK");
_global.workflow = new Objects.WorkFlow();
//Create global reference to project/design tree
var left_tree:mx.controls.Tree;
_global.left_tree = left_tree;
_global.left_tree.vScrollPolicy = right_tree.vScrollPolicy = "auto";
_global.left_tree.hScrollPolicy = "auto";
_global.left_tree.setStyle("openDuration", 50);
/*************************************************************************/
//link to required xml files
//Load list of overrides for client objects
_global.overrides_xml = new XML();
_global.overrides_xml.ignoreWhite = true;
_global.overrides_xml.onLoad = function(success) {
	if (!success) {
		mdm.Dialogs.prompt("Error, overrides.xml file not loaded!");
	}
};
_global.overrides_xml.load("overrides.xml");
//Load list of possible raw parameters
_global.parameters_xml = new XML();
_global.parameters_xml.ignoreWhite = true;
_global.parameters_xml.onLoad = function(success) {
	if (!success) {
		mdm.Dialogs.prompt("Error, parameters.xml file not loaded!");
	}
};
_global.parameters_xml.load("parameters.xml");
//Load default client configuration
_global.default_client_xml = new XML();
_global.default_client_xml.ignoreWhite = true;
_global.default_client_xml.onLoad = function(success) {
	if (!success) {
		mdm.Dialogs.prompt("Error, client.xml file not loaded!");
	}
};
_global.default_client_xml.load("default_client.xml");
//Load default client configuration
_global.default_server_xml = new XML();
_global.default_server_xml.ignoreWhite = true;
_global.default_server_xml.onLoad = function(success) {
	if (!success) {
		mdm.Dialogs.prompt("Error, server.xml file not loaded!");
	}
};
_global.default_server_xml.load("default_server.xml");
//Load list of possible control type attributes
_global.controlTypeAttributes_xml = new XML();
_global.controlTypeAttributes_xml.ignoreWhite = true;
_global.controlTypeAttributes_xml.onLoad = function(success) {
	if (!success) {
		mdm.Dialogs.prompt("Error, controlTypeAttributes.xml file not loaded!");
	}
};
_global.controlTypeAttributes_xml.load("controlTypeAttributes.xml");
/*************************************************************************/
// load project xml data
_global.project = new Object();
//Design tree dataprovider
_global.designTree_xml = new XML();
//Control Tree dataprovider
_global.controlTree_xml = new XML();
//Project xml loader
var project_xml = new XML();
project_xml.ignoreWhite = true;
project_xml.onLoad = function(success) {
	//Reset the Design
	_global.designTree_xml = new XML();
	//Reset the Control
	_global.controlTree_xml = new XML();
	//Reset the Project Details
	_global.project = new Object();
	//Build Project Details from project xml
	for (var attrib in project_xml.firstChild.attributes) {
		_global.project[attrib] = project_xml.firstChild.attributes[attrib];
	}
	//Append list of server designs and list of server implementations
	_global.serverDesign = new Objects.Server.Server();
	_global.serverInstance = new Objects.Instances.ServerInstance();
	_global.serverInstance.serverDesign = _global.serverDesign;
	//mdm.Dialogs.prompt(project_xml.toString());
	for (var child in project_xml.firstChild.childNodes) {
		switch (project_xml.firstChild.childNodes[child].nodeName) {
		case "CONFIG" :
			_global.serverDesign.setXML(project_xml.firstChild.childNodes[child]);
			_global.designTree_xml.appendChild(_global.serverDesign.toTree());
			var clients = _global.serverDesign.getClients();
			for (var client in clients) {
				_global.designTree_xml.appendChild(clients[client].toTree());
			}
			break;
		case "serverInstance" :
			_global.serverInstance.setXML(project_xml.firstChild.childNodes[child]);
			_global.controlTree_xml.appendChild(_global.serverInstance.toTree());
			break;
		}
	}
	_global.refreshTheTree();
};
/**************************************************************************************/
/*For importing client xml files*/
var client_xml = new XML();
client_xml.ignoreWhite = true;
client_xml.onLoad = function(success) {
	if (success) {
	} else {
		mdm.Dialogs.prompt("Error, client.xml file not loaded!");
	}
};
/**************************************************************************************/
/*For importing server xml files*/
var server_xml = new XML();
server_xml.ignoreWhite = true;
server_xml.onLoad = function(success) {
	if (success) {
	} else {
		mdm.Dialogs.prompt("Error, server.xml file not loaded!");
	}
};
/**************************************************************************************/
function openFile(openType:String):Void {
	mdm.Dialogs.BrowseFile.buttonText = "Open";
	mdm.Dialogs.BrowseFile.title = "Please select a " + openType + ".xml file to open";
	mdm.Dialogs.BrowseFile.dialogText = "Select a " + openType + ".xml to Use";
	mdm.Dialogs.BrowseFile.defaultExtension = "xml";
	mdm.Dialogs.BrowseFile.filterList = "XML Files|*.xml";
	mdm.Dialogs.BrowseFile.filterText = "XML Files|*.xml";
	var file = mdm.Dialogs.BrowseFile.show();
	if (file != "false") {
		switch (openType) {
		case "Project" :
			_global.projectFileName = file;
			mdm.Application.title = "eLIFE Admin Tool - [" + _global.projectFileName + "]";
			mdm.Forms.MainForm.title = "eLIFE Admin Tool - [" + _global.projectFileName + "]";
			project_xml.load(file);
			setButtons(true);
			setView("project");
			break;
			/*case "Server" :
			server_xml.load(file);
			break;
			case "Client" :
			client_xml.load(file);
			break;*/
		}
	}
}
/**************************************************************************************/
_global.saveFile = function(saveType:String):Void  {
	if (saveType == "Project") {
		if (_global.projectFileName.length) {
			var newProjectXML = new XMLNode(1, "project");
			for (var attrib in _global.project) {
				if (_global.project[attrib].length) {
					newProjectXML.attributes[attrib] = _global.project[attrib];
				}
			}
			/*Append project contents to project node*/
			newProjectXML.appendChild(_global.serverDesign.toProject());
			newProjectXML.appendChild(_global.serverInstance.toXML());
			mdm.FileSystem.saveFile(_global.projectFileName, _global.writeXMLFile(newProjectXML, 0));
			mdm.Application.title = "eLIFE Admin Tool - [" + _global.projectFileName + "]";
			mdm.Forms.MainForm.title = "eLIFE Admin Tool - [" + _global.projectFileName + "]";
			_global.unSaved = false;
		} else {
			mdm.Dialogs.BrowseFile.buttonText = "Save";
			mdm.Dialogs.BrowseFile.title = "Please select a location to save to";
			mdm.Dialogs.BrowseFile.dialogText = "Please select a location to save to";
			mdm.Dialogs.BrowseFile.defaultExtension = "xml";
			mdm.Dialogs.BrowseFile.filterList = "XML Files|*.xml";
			mdm.Dialogs.BrowseFile.filterText = "XML Files|*.xml";
			var tempString = mdm.Dialogs.BrowseFile.show();
			if (tempString != "false") {
				_global.projectFileName = tempString;
				var newProjectXML = new XMLNode(1, "project");
				for (var attrib in _global.project) {
					if (_global.project[attrib].length) {
						newProjectXML.attributes[attrib] = _global.project[attrib];
					}
				}
				/*Append project contents to project node*/
				newProjectXML.appendChild(_global.serverDesign.toProject());
				newProjectXML.appendChild(_global.serverInstance.toProject());
				mdm.FileSystem.saveFile(_global.projectFileName, _global.writeXMLFile(newProjectXML, 0));
				mdm.Application.title = "eLIFE Admin Tool - [" + _global.projectFileName + "]";
				mdm.Forms.MainForm.title = "eLIFE Admin Tool - [" + _global.projectFileName + "]";
				_global.unSaved = false;
			}
		}
	} else {
		mdm.Dialogs.BrowseFile.buttonText = "Save";
		mdm.Dialogs.BrowseFile.title = "Please select a " + saveType + ".xml file to save";
		mdm.Dialogs.BrowseFile.dialogText = "Select a " + saveType + ".xml to Save";
		mdm.Dialogs.BrowseFile.defaultExtension = "xml";
		mdm.Dialogs.BrowseFile.filterList = "XML Files|*.xml";
		mdm.Dialogs.BrowseFile.filterText = "XML Files|*.xml";
		var file = mdm.Dialogs.BrowseFile.show();
		if (file != undefined) {
			if (saveType == "Server") {
				//mdm.FileSystem.saveFile(file, _global.writeXMLFile(_global.serverDesign.toXML(), 0));
			} else {
				//mdm.FileSystem.saveFile(file, _global.writeXMLFile(_global.client_test.toXML(), 0));
			}
			mdm.Dialogs.prompt("File saved to: " + file);
		}
	}
};
/****************************************************************/
function searchProject(treeNode:Object, object:Object):Object {
	if (treeNode.object == object) {
		return treeNode;
	} else {
		for (var child in treeNode.childNodes) {
			var foundNode = searchProject(treeNode.childNodes[child], object);
			if (foundNode != undefined) {
				return foundNode;
			}
		}
		return undefined;
	}
}
/********************************************************/
_global.refreshTheTree = function() {
	if (workFlow_split.visible) {		
		_global.left_tree.dataProvider = null;
		// clear
		_global.left_tree.dataProvider = _global.designTree_xml;	
	} else{
		_global.left_tree.dataProvider = null;
		// clear
		_global.left_tree.dataProvider = _global.controlTree_xml;
	}
	_global.keys = _global.serverDesign.getKeys();
	var clientList:Array = _global.serverDesign.getClients();
	var temp:Array = null;
	for (var eachClient in clientList) {
		temp.concat(clientList[eachClient].getUsedKeys);
	}
	_global.usedKeys = temp;
	_global.workflow.buildWorkflowTree();
	createWorkflow(_global.designTree_xml);
	oBackupDP = _global.right_tree.dataProvider;
	_global.right_tree.dataProvider = null;
	_global.right_tree.dataProvider = oBackupDP;
	_global.output_panel.setDescription(_global.left_tree.selectedNode.description);
	_global.output_panel.setError(_global.left_tree.selectedNode.object.getValidationMsg());
	_global.output_panel.draw();
};
/********************************************************/
_global.isKeyValid = function(inKey:String):Boolean  {
	for (var key in _global.keys) {
		if (_global.keys[key] == inKey) {
			return true;
		}
	}
	return false;
};
/********************************************************/
_global.isKeyUsed = function(inKey:String):Boolean  {
	for (var key in _global.usedKeys) {
		if (_global.usedKeys[key] == inKey) {
			return true;
		}
	}
	return false;
};
/********************************************************/
function createWorkflow(inNode:Object) {
	_global.workflow.addNode(inNode.object.getKey(), inNode);
	for (var child in inNode.childNodes) {
		createWorkflow(inNode.childNodes[child]);
	}
}
/*************************************************************************
Build xml formatted string to be written to file. This contains all the tabs
and line feeds to ensure that the output file is human readable.
*************************************************************************/
_global.writeXMLFile = function(inNode:XMLNode, depth:Number):String  {
	var tempString = "";
	if (inNode.nodeType == 3) {
		tempString += inNode.toString();
		return tempString;
	}
	for (index = 0; index < depth; index++) {
		tempString += "\t";
	}
	tempString += "<";
	tempString += inNode.nodeName;
	for (attribute in inNode.attributes) {
		tempString += " " + attribute + '="' + inNode.attributes[attribute] + '"';
	}
	if (inNode.hasChildNodes()) {
		if (inNode.firstChild.nodeType == 3) {
			tempString += ">";
			tempString += _global.writeXMLFile(inNode.firstChild, 0);
			return tempString + "</" + inNode.nodeName + "> \n";
		} else {
			tempString += "> \n";
			for (var child = 0; child < inNode.childNodes.length; child++) {
				tempString += _global.writeXMLFile(inNode.childNodes[child], depth + 1);
			}
			for (index = 0; index < depth; index++) {
				tempString += "\t";
			}
			return tempString + "</" + inNode.nodeName + "> \n";
		}
	} else {
		return tempString + "/> \n";
	}
};
/****************************************************************************/
//Application exit handling
mdm.Application.enableExitHandler(appExit);
mdm.Application.onAppExit = function() {
	appExit();
};
function appExit():Void {
	if (_global.unSaved) {
		var Result = mdm.Dialogs.promptModal("Save before exiting?", "yesno", "alert");
		if (Result) {
			saveFile("Project");
		}
	}
	var Result = mdm.Dialogs.promptModal("Are you sure you want to Exit?", "yesno", "alert");
	if (Result) {
		_global.serverInstance.serverConnection.disconnect();
		mdm.Application.exit();
	}
}
/********************************************************/
_global.comboSetSelected = function(combo, val, field) {
	for (var i = 0; i < combo.length; i++) {
		if (field.length && combo.getItemAt(i)[field] == val) {
			combo.selectedIndex = i;
			break;
		} else if (combo.getItemAt(i) == val) {
			combo.selectedIndex = i;
			break;
		}
	}
};
/****************************************************************/
mdm.Menu.Main.menuType = "function";
mdm.Menu.Main.insertHeader("File");
mdm.Menu.Main.insertHeader("Help");
mdm.Menu.Main.insertItem("File", "New Project");
mdm.Menu.Main.insertItem("File", "Open Project");
//mdm.Menu.Main.insertDivider("File");
//mdm.Menu.Main.insertItem("File", "Import Server XML");
//mdm.Menu.Main.insertItem("File", "Import Client XML");
mdm.Menu.Main.insertDivider("File");
mdm.Menu.Main.insertItem("File", "Save Project");
mdm.Menu.Main.insertItem("File", "Save Project As..");
mdm.Menu.Main.insertDivider("File");
mdm.Menu.Main.insertItem("File", "Exit");
mdm.Menu.Main.insertItem("Help", "Help");
mdm.Menu.Main.onMenuClick_New_Project = function() {
	_global.projectFileName = "";
	_global.project = new Object();
	_global.serverDesign = new Objects.Server.Server();
	_global.serverInstance = new Objects.Instances.ServerInstance();
	_global.serverInstance.serverDesign = _global.serverDesign;
	_global.designTree_xml = new XML();
	_global.designTree_xml.appendChild(serverDesign.toTree());
	var clients = _global.serverDesign.getClients();
	for (var client in clients) {
		_global.designTree_xml.appendChild(clients[client].toTree());
	}
	_global.controlTree_xml.appendChild(_global.serverInstance.toTree());
	mdm.Application.title = "eLIFE Admin Tool - [unsaved]";
	mdm.Forms.MainForm.title = "eLIFE Admin Tool - [unsaved]";
	setView("home");
	_global.refreshTheTree();
	setButtons(true);
};
mdm.Menu.Main.onMenuClick_Open_Project = function() {
	openFile("Project");
};
/*
mdm.Menu.Main.onMenuClick_Import_Server_XML = function() {
openFile("Server");
};
mdm.Menu.Main.onMenuClick_Import_Client_XML = function() {
openFile("Client");
};
*/
mdm.Menu.Main.onMenuClick_Save_Project = function() {
	saveFile("Project");
};
mdm.Menu.Main.onMenuClick_Save_Project_As__ = function() {
	mdm.Dialogs.BrowseFile.buttonText = "Save Project";
	mdm.Dialogs.BrowseFile.title = "Please select a location to save to";
	mdm.Dialogs.BrowseFile.dialogText = "Please select a location to save to";
	mdm.Dialogs.BrowseFile.defaultExtension = "xml";
	mdm.Dialogs.BrowseFile.filterList = "XML Files|*.xml";
	mdm.Dialogs.BrowseFile.filterText = "XML Files|*.xml";
	var tempString = mdm.Dialogs.BrowseFile.show();
	if (tempString != "false") {
		_global.projectFileName = tempString;
		saveFile("Project");
	}
};
mdm.Menu.Main.onMenuClick_Help = function() {
	var windowList = mdm.System.getWindowList();
	var WID = "";
	for (var window in windowList) {
		if (windowList[window][0] == "eLIFE Admin Tool - Help") {
			WID = windowList[window][1];
			break;
		}
	}
	if (WID.length) {
		mdm.System.setWindowFocus(parseInt(WID));
	} else {
		var currentPath = mdm.FileSystem.getCurrentDir();
		mdm.Process.create("", 0, 0, 500, 600, "", "hh.exe " + currentPath + "eLIFEAdminTool.chm", currentPath, 3, 4);
	}
};
mdm.Menu.Main.onMenuClick_Exit = function() {
	appExit();
};
/****************************************************************/
// set view function to display correct form
setView = function (view, dataObj) {
	if (_global.unSaved) {
		var Result = mdm.Dialogs.promptModal("You are about to lose your changes, would you like to save?", "yesno", "alert");
		if (Result) {
			form_mc.save();
		} else {
			_global.unSaved = false;
		}
	}
	form_mc.removeMovieClip();
	// render the view
	switch (view) {
	case "home" :
		tabBody_mc._visible = true;
		tabs_tb._visible = true;
		tabs_tb._x = 5;
		tabBody_mc._x = 5;
		tabs_tb.setSize(1015, 25);
		tabBody_mc._width = 1015;
		left_tree._visible = false;
		workFlow_split._visible = false;
		form_mc = formContent_mc.attachMovie("forms.home", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth());
		tabs_tb.dataProvider = [{label:"Project Details"}];
		tabs_tb.selectedIndex = 0;
		break;
	case "project" :
		tabBody_mc._visible = true;
		tabs_tb._visible = true;
		tabs_tb._x = 254;
		tabBody_mc._x = 254;
		tabs_tb.setSize(560, 25);
		tabBody_mc._width = 560;
		left_tree._visible = true;
		workFlow_split._visible = true;
		tabBody_mc._visible = true;
		tabs_tb.dataProvider = [{label:"Project Design"}];
		tabs_tb.selectedIndex = 0;
		left_tree.dataProvider = _global.designTree_xml;
		left_tree.labelFunction = function(item_obj:Object):String  {
			return item_obj.object.getName();
		};
		break;
		/************************************************************************************/
	case "control" :
		/*
		Need to rebuild left tree with elife devices
		*/
		tabBody_mc._visible = true;
		tabs_tb._visible = true;
		tabs_tb._x = 254;
		tabBody_mc._x = 254;
		tabs_tb.setSize(766, 25);
		tabBody_mc._width = 766;
		workFlow_split._visible = false;
		left_tree._visible = true;
		left_tree.dataProvider = _global.controlTree_xml;
		left_tree.labelFunction = function(item_obj:Object):String  {
			return item_obj.object.getName();
		};
		tabs_tb.dataProvider = [{label:"Project Command and Control"}];
		tabs_tb.selectedIndex = 0;
		break;
		/***********************************************************************************/
	case "none" :
		left_tree._visible = false;
		workFlow_split._visible = false;
		tabs_tb._visible = false;
		tabBody_mc._visible = false;
		break;
		/*
		case "history" :
		left_tree._visible = false;
		workFlow_split._visible = false;
		tabs_tb.dataProvider = [{label:"History", view:"history"}];
		tabs_tb.selectedIndex = 0;
		form_mc = formContent_mc.attachMovie("forms.history", "form" + (_global.formDepth++) + "_history", formContent_mc.getNextHighestDepth());
		break;
		*/
	}
};
/****************************************************************/
tabs_tb.change = function(eventObj) {
	if (this.lastTab.view != eventObj.target.selectedItem.view && eventObj.target.selectedItem.view.length) {
		if (_global.unSaved) {
			var Result = mdm.Dialogs.promptModal("You are about to lose your changes, would you like to save?", "yesno", "alert");
			if (Result) {
				form_mc.save();
			} else {
				_global.unSaved = false;
			}
		}
		var tempObject = form_mc.dataObject;
		form_mc.removeMovieClip();
		switch (eventObj.target.selectedItem.label) {
		case "Client Designs" :
			form_mc = formContent_mc.attachMovie("forms.project.clientDesigns", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), {clients:tempObject.getClients(), dataObject:tempObject});
			break;
		case "XML" :
			form_mc = formContent_mc.attachMovie("forms.project.xml", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), {node:tempObject.toXML(), dataObject:tempObject});
			break;
		case "Preview" :
			form_mc = formContent_mc.attachMovie("forms.project.client.preview", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), {controls:_global.client_test.getControlTypes(), previewXML:tempObject.toXML(), dataObject:tempObject});
			break;
		case "Overrides" :
			form_mc = formContent_mc.attachMovie("forms.project.client.overrides", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), {attributes:tempObject.getAttributes(), attributeGroups:tempObject.attributeGroups, dataObject:tempObject});
			break;
		case "Control" :
			form_mc = formContent_mc.attachMovie("forms."+eventObj.target.selectedItem.view, "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), tempObject.getConnections());
			break;
		case "Clients" :
			form_mc = formContent_mc.attachMovie("forms.control.clients", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), tempObject.getClients());
			break;
		case "Log" :
			form_mc = formContent_mc.attachMovie("forms.control.serverLog", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), tempObject.getConnections());
			break;
		case "IR" :
			form_mc = formContent_mc.attachMovie("forms.control.ir", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), tempObject.getConnections());
			break;
		case "SFTP" :
			form_mc = formContent_mc.attachMovie("forms.control.sftp", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), tempObject.getConnections());
			break;
		case "Publish" :
			form_mc = formContent_mc.attachMovie("forms."+eventObj.target.selectedItem.view, "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), tempObject.getConnections());
			break;
		case "Panels" :
			form_mc = formContent_mc.attachMovie(eventObj.target.selectedItem.view, "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), {dataObject:tempObject, panels:tempObject.getPanels()});
			break;
		case "Rooms" :
			form_mc = formContent_mc.attachMovie(eventObj.target.selectedItem.view, "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), {dataObject:tempObject, rooms:tempObject.getRooms()});
			break;
		default :
			form_mc = formContent_mc.attachMovie(tempObject.getForm(), "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), tempObject.getData());
			break;
		}
	}
	this.lastTab = this.selectedItem;
};
tabs_tb.addEventListener("change", tabs_tb);
/****************************************************************/
leftTreeListener = new Object();
leftTreeListener.change = function(eventObj) {
	if (_global.unSaved) {
		var Result = mdm.Dialogs.promptModal("You are about to lose your changes, would you like to save?", "yesno", "alert");
		if (Result) {
			form_mc.save();
		} else {
			_global.unSaved = false;
		}
	}
	var node = eventObj.target.selectedNode;
	form_mc.removeMovieClip();
	right_tree.selectedNode = undefined;
	if (node.object == undefined) {
		_global.output_panel.setDescription("");
		_global.output_panel.setError("");
		_global.output_panel.draw();
	}
	if (node.object != undefined) {
		_global.output_panel.setDescription(node.description);
		_global.output_panel.setError(node.object.getValidationMsg());
		_global.output_panel.draw();
		switch (node.nodeName) {
		case "Client" :
		case "StatusBarGroup" :
		case "Logging" :
		case "ClientIcon" :
		case "Calendar" :
			form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), node.object.getData());
			tabs_tb.dataProvider = [{label:node.object.getName(), view:node.object.getForm()}, {label:"Overrides", view:"forms.project.client.overrides"}, {label:"XML", view:"forms.project.xml"}];
			tabs_tb.selectedIndex = 0;
			break;
		case "Window" :
			form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), node.object.getData());
			tabs_tb.dataProvider = [{label:node.object.getName(), view:node.object.getForm()}, {label:"Overrides", view:"forms.project.client.overrides"}, {label:"Preview", view:"forms.project.client.preview"}, {label:"XML", view:"forms.project.xml"}];
			tabs_tb.selectedIndex = 0;
			break;
		case "Panel" :
		case "Tab" :
		case "Control" :
			form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), node.object.getData());
			tabs_tb.dataProvider = [{label:node.object.getName(), view:node.object.getForm()}, {label:"XML", view:"forms.project.xml"}, {label:"Preview", view:"forms.project.client.preview"}];
			tabs_tb.selectedIndex = 0;
			break;
		case "Server_Design" :
			form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), node.object.getData());
			tabs_tb.dataProvider = [{label:node.object.getName(), view:node.object.getForm()}, {label:"Client Designs", view:"forms.project.clientDesigns"}, {label:"XML", view:"forms.project.xml"}];
			tabs_tb.selectedIndex = 0;
			break;
		case "Server" :
			form_mc = formContent_mc.attachMovie("forms.control.servercontrols", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), node.object.getConnections());
			tabs_tb.dataProvider = [{label:"Control", view:"control.servercontrols"}, {label:"Clients", view:"control.clients"}, {label:"Log", view:"control.serverLog"}, {label:"IR", view:"control.ir"}, {label:"Publish", view:"control.publishserver"}, {label:"SFTP", view:"control.sftp"}];
			tabs_tb.selectedIndex = 0;
			//Need to rewrite how a view is attached to a server object
			//_global.server.attachView(form_mc);			
			break;
		case "clientInstance":
			form_mc = formContent_mc.attachMovie("forms.control.clientcontrols", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), node.object.getConnections());
			tabs_tb.dataProvider = [{label:"Control", view:"control.clientcontrols"}, {label:"Publish", view:"control.publishclient"}, {label:"SFTP", view:"control.sftp"}];
			tabs_tb.selectedIndex = 0;		
			break;
		case "Zone" :
			form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), node.object.getData());
			tabs_tb.dataProvider = [{label:node.object.getName(), view:node.object.getForm()}, {label:"Rooms", view:"forms.project.client.rooms"}, {label:"Panels", view:"forms.project.client.panels"}, {label:"XML", view:"forms.project.xml"}];
			tabs_tb.selectedIndex = 0;
			break;
			//Need to rewrite how a view is attached to a server object
			//_global.server.attachView(form_mc);			
			break;
		default :
			form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), node.object.getData());
			tabs_tb.dataProvider = [{label:node.object.getName(), view:node.object.getForm()}, {label:"XML", view:"forms.project.xml"}];
			tabs_tb.selectedIndex = 0;
			break;
		}
	}
};
left_tree.addEventListener("change", leftTreeListener);
/****************************************************************/
buttonListener = new Object();
buttonListener.last_btn = null;
buttonListener.click = function(eventObj) {
	this.last_btn.selected = false;
	this.last_btn = eventObj.target;
	switch (eventObj.target) {
	case home_btn :
		eventObj.target.selected = true;
		setView("home");
		break;
	case project_btn :
		eventObj.target.selected = true;
		setView("project");
		break;
	case control_btn :
		eventObj.target.selected = true;
		setView("control");
		break;
	case preview_btn :
		if (workFlow_split.visible) {
			var temp_node = _global.left_tree.selectedNode;
			var found_node_id = null;
			while ((temp_node != null) && (found_node_id == null)) {
				if (temp_node.nodeName == "Client") {
					found_node_id = temp_node.object.id;
				} else {
					temp_node = temp_node.parentNode;
				}
			}
			if (found_node_id != null) {
				var clients = _global.serverDesign.getClients();
				for (var client in clients) {
					if (clients[client].id == found_node_id) {
						mdm.FileSystem.saveFile("client.xml", _global.writeXMLFile(clients[client].toXML(), 0));
						mdm.Forms.Preview.callFunction("parseClient", '<client><setting name="applicationXML" value="client.xml" /><setting name="libLocation" value="lib/" /><setting name="fullScreen" value="false" /><setting name="hideMouseCursor" value="false" /></client>', "|");
						mdm.Forms.Preview.showModal();
						break;
					}
				}
			}
		}
		break;
	case library_btn :
		if (workFlow_split.visible) {
			if (form_mc.dataObject != undefined) {
				switch (form_mc.dataObject.getKey()) {
				case "AlertGroups" :
				case "Calendar" :
				case "Calendar_Settings" :
				case "Calendar_Tab" :
				case "Client" :
				case "ClientAlerts" :
				case "ClientApps_Bar" :
				case "ClientAritrary" :
				case "ClientControl" :
				case "ClientControl_Panel_Apps" :
				case "ClientControl_Types" :
				case "ClientDoors" :
				case "ClientIcon" :
				case "ClientRoom" :
				case "ClientSounds" :
				case "ClientTab" :
				case "ClientWindow" :
				case "Comfort" :
				case "Dynalite" :
				case "GC100" :
				case "Hal" :
				case "IRLearner" :
				case "Kramer" :
				case "Logging" :
				case "LoggingGroup" :
				case "Oregon" :
				case "Panel" :
				case "Pelco" :
				case "Property" :
				case "Raw_Connection" :
				case "Server" :
				case "StatusBar" :
				case "StatusBarGroup" :
				case "Tutondo" :
				case "Variables" :
				case "Zone" :
					eventObj.target.selected = true;
					blocker = _root.createEmptyMovieClip("blo" + (_global.formDepth++) + "cker", 10000);
					blocker.beginFill(0x000000);
					blocker.moveTo(0, 0);
					blocker.lineTo(Stage.width, 0);
					blocker.lineTo(Stage.width, Stage.height);
					blocker.lineTo(0, Stage.height);
					blocker.lineTo(0, 0);
					blocker.endFill();
					blocker.onRelease = function() {
					};
					blocker._alpha = 20;
					blocker.useHandCursor = false;
					var tempObject = form_mc.dataObject;
					libraryManager = PopUpManager.createPopUp(_root, Window, true, {contentPath:"forms.librarymanager"});
					libraryManager._x = 300;
					libraryManager._y = 50;
					libraryManager.title = "Library";
					libraryManager.closeButton = true;
					var winListener:Object = new Object();
					winListener.click = function() {
						libraryManager.deletePopUp();
						blocker.unloadMovie();
						var foundNode = searchProject(_global.left_tree.dataProvider, tempObject);
						if (foundNode != undefined) {
							left_tree.setIsOpen(foundNode, true);
							var temp_node = foundNode.parentNode;
							while (temp_node != null) {
								left_tree.setIsOpen(temp_node, true);
								temp_node = temp_node.parentNode;
							}
							var parentNode = foundNode.parentNode;
							if(tempObject.getKey() == "Server"){
								for(var node in parentNode.childNodes){
									parentNode.childNodes[node].removeNode();
								}
							} else{
								foundNode.removeNode();
							}
							foundNode=tempObject.toTree();
							parentNode.appendChild(foundNode);
							left_tree.selectedNode = foundNode;															
							var selectNode = new Object();
							selectNode.target = _global.left_tree;
							selectNode.type = "change";
							left_tree.dispatchEvent(selectNode);
						}
						_global.refreshTheTree();
						_global.unSaved = true;
					};
					winListener.complete = function(evt_obj:Object) {
						libraryManager.setSize(libraryManager.content._width + 7, libraryManager.content._height + 35);
						libraryManager.content.doLoad(tempObject);
					};
					libraryManager.addEventListener("click", winListener);
					libraryManager.addEventListener("complete", Delegate.create(this, winListener.complete));
					break;
				default :
					break;
				}
			}
		}
		break;
		/*
		case historyViewer_btn :
		eventObj.target.selected = true;
		setView("history");
		break;
		*/
	}
};
home_btn.addEventListener("click", buttonListener);
project_btn.addEventListener("click", buttonListener);
control_btn.addEventListener("click", buttonListener);
preview_btn.addEventListener("click", buttonListener);
library_btn.addEventListener("click", Delegate.create(this, buttonListener.click));
//historyViewer_btn.addEventListener("click", buttonListener);
/****************************************************************/
buttonListener2 = new Object();
buttonListener2.click = function(eventObj) {
	advanced_btn.icon = "advanced" + (!_global.advanced);
	_global.advanced = (!_global.advanced);
	CloseTip();
	var tempObject = _global.left_tree.selectedNode.object;
	_global.designTree_xml = new XML();
	_global.designTree_xml.appendChild(serverDesign.toTree());
	var clients = _global.serverDesign.getClients();
	for (var client in clients) {
		_global.designTree_xml.appendChild(clients[client].toTree());
	}
	_global.refreshTheTree();
	if (_global.advanced) {
		DisplayTip("To Basic");
	} else {
		DisplayTip("To Advanced");
	}
	var foundNode = searchProject(_global.left_tree.dataProvider, tempObject);
	if (foundNode != undefined) {
		left_tree.setIsOpen(foundNode, true);
		var temp_node = foundNode.parentNode;
		while (temp_node != null) {
			left_tree.setIsOpen(temp_node, true);
			temp_node = temp_node.parentNode;
		}
		form_mc.setAdvanced();
	} else {
		//Reset project
		setView("project");
	}
	_global.refreshTheTree();
	left_tree.selectedNode = foundNode;
};
advanced_btn.addEventListener("click", buttonListener2);
/****************************************************************/
function setButtons(enabled:Boolean) {
	home_btn.enabled = enabled;
	project_btn.enabled = enabled;
	control_btn.enabled = enabled;
	preview_btn.enabled = enabled;
	library_btn.enabled = enabled;
	//historyViewer_btn.enabled = enabled;
	advanced_btn.enabled = enabled;
	//mdm.Menu.Main.itemVisible("File", "Import Server XML", enabled);
	//mdm.Menu.Main.itemVisible("File", "Import Client XML", enabled);
	mdm.Menu.Main.itemVisible("File", "Save Project", enabled);
	mdm.Menu.Main.itemVisible("File", "Save Project As..", enabled);
}
home_btn.onRollOver = function() {
	DisplayTip("Project Details");
	this.setState("highlighted");
};
project_btn.onRollOver = function() {
	DisplayTip("Project Design");
	this.setState("highlighted");
};
control_btn.onRollOver = function() {
	DisplayTip("Server Controls");
	this.setState("highlighted");
};
preview_btn.onRollOver = function() {
	DisplayTip("Client Preview");
	this.setState("highlighted");
};
library_btn.onRollOver = function() {
	DisplayTip("Library");
	this.setState("highlighted");
};
/*
historyViewer_btn.onRollOver = function() {
DisplayTip("Changelog");
this.setState("highlighted");
};*/
advanced_btn.onRollOver = function() {
	if (this.icon == "advancedfalse") {
		DisplayTip("To Advanced");
	} else {
		DisplayTip("To Basic");
	}
	this.setState("highlighted");
};
home_btn.onRollOut = function() {
	CloseTip();
	this.setState(false);
};
project_btn.onRollOut = function() {
	CloseTip();
	this.setState(false);
};
control_btn.onRollOut = function() {
	CloseTip();
	this.setState(false);
};
preview_btn.onRollOut = function() {
	CloseTip();
	this.setState(false);
};
library_btn.onRollOut = function() {
	CloseTip();
	this.setState(false);
};
/*historyViewer_btn.onRollOut = function() {
CloseTip();
this.setState(false);
};*/
advanced_btn.onRollOut = function() {
	CloseTip();
	this.setState(false);
};
setButtons(false);
/****************************************************************/
/*treeFilter_cb.change = function(eventObj) {
switch (eventObj.target.selectedItem.label) {
case "Project" :
left_tree.dataProvider = _global.designTree_xml;
left_tree.labelFunction = function(item_obj:Object):String  {
return item_obj.object.getName();
};
break;
case "Library" :
left_tree.dataProvider = new XML('<n label="Icons" /><n label="Sounds" /><n label="Windows" /><n label="Tabs" /><n label="Rooms" /><n label="Controls" />');
left_tree.labelFunction = null;
break;
}
};
treeFilter_cb.addEventListener("change", treeFilter_cb);*/
setView("none");
/****************************************************************/
_global.right_tree.setStyle("indentation", 10);
_global.right_tree.setStyle("defaultLeafIcon", "Icon:null");
_global.right_tree.setStyle("folderOpenIcon", "Icon:null");
_global.right_tree.setStyle("folderClosedIcon", "Icon:null");
_global.right_tree.setStyle("disclosureClosedIcon", "Icon:null");
_global.right_tree.setStyle("disclosureOpenIcon", "Icon:null");
_global.right_tree.setStyle("depthColors", [0xCCCCCC, 0xFFFFFF]);
_global.right_tree.setStyle("rollOverColor", 0xDDDDDD);
_global.right_tree.setStyle("selectionColor", 0xCFDFF0);
_global.right_tree.setStyle("selectionDuration", 0);
_global.right_tree.setStyle("textRollOverColor", 0x000000);
_global.right_tree.setStyle("textSelectedColor", 0x000000);
_global.right_tree.cellRenderer = "WorkFlowTreeCellRenderer";
_global.right_tree.setStyle("lineColor", 0x000000);
_global.right_tree.setStyle("lineAlpha", 20);
_global.right_tree.vScrollPolicy = "auto";
var treeListener:Object = new Object();
treeListener.target = right_tree;
treeListener.opened = undefined;
treeListener.open_next = undefined;
/* a node in the tree has been selected */
treeListener.change = function(evt:Object) {
	var node = evt.target.selectedNode;
	var is_open = evt.target.getIsOpen(node);
	var is_branch = evt.target.getIsBranch(node);
	var node_to_close = node.getSiblings(this.target);
	// close the opened node first
	if ((this.target.getIsOpen(node_to_close)) && (this.target.getIsBranch(node_to_close)) && (node_to_close != undefined)) {
		this.target.setIsOpen(node_to_close, false, true, true);
		this.open_next = node;
	} else {
		if (is_branch) {
			this.target.setIsOpen(node, true, true, true);
		} else {
			this.target.selectedNode = node;
			this.target.dispatchEvent({type:"click", target:evt.target});
			left_tree.setIsOpen(node.left_node, true);
			var temp_node = node.left_node.parentNode;
			while (temp_node != null) {
				left_tree.setIsOpen(temp_node, true);
				temp_node = temp_node.parentNode;
			}
			left_tree.selectedNode = node.left_node;
			selectNode = new Object();
			selectNode.target = _global.left_tree;
			selectNode.type = "change";
			left_tree.dispatchEvent(selectNode);
		}
		this.open_next = undefined;
	}
};
treeListener.closeNode = function(node:XMLNode) {
	for (var a in node.childNodes) {
		if (this.target.getIsOpen(node.childNodes[a])) {
			this.closeNode(node.childNodes[a]);
		}
	}
	this.target.setIsOpen(node, false, false);
};
treeListener.nodeClose = function(evt:Object) {
	this.closeNode(evt.node);
	if (this.open_next != undefined and evt.target.getIsBranch(this.open_next)) {
		evt.target.setIsOpen(this.open_next, true, true, true);
	} else {
		evt.target.selectedNode = this.open_next;
		this.target.dispatchEvent({type:"click", target:evt.target});
		this.open_next = undefined;
	}
};
treeListener.nodeOpen = function(evt:Object) {
	evt.target.selectedNode = evt.node;
};
XMLNode.prototype.getSiblings = function(cTree:mx.controls.Tree) {
	var parent = this.parentNode;
	for (var a = 0; a < parent.childNodes.length; a++) {
		if (parent.childNodes[a] != this && cTree.getIsOpen(parent.childNodes[a])) {
			return parent.childNodes[a];
		}
	}
	return undefined;
};
// set out listeners for the menu
_global.right_tree.addEventListener('change', treeListener);
_global.right_tree.addEventListener('nodeClose', treeListener);
_global.right_tree.addEventListener('nodeOpen', treeListener);
//_global.workflow.buildWorkflowTree();
/************************************************************************/
//create the tooltip clip 
_root.createEmptyMovieClip("ToolTip", 15999);
// add the tooltip background box 
_root.ToolTip.createEmptyMovieClip("TipBackground", 1);
with (_root.ToolTip.TipBackground) {
	beginFill(0xCCCCCC, 100);
	lineStyle(1, 0x666666, 100);
	moveTo(0, 0);
	lineTo(110, 0);
	lineTo(110, 20);
	lineTo(0, 20);
	lineTo(0, 0);
	endFill();
}
// add the tooltip textfield. you could easily apply a 
// textFormat to this to customise the text more.
_root.ToolTip.createTextField("TipText", 2, 2, 0, 100, 20);
_root.ToolTip.TipText.type = "dynamic";
// mouse listener for tooltips 
TipMover = new Object();
TipMover.onMouseMove = function() {
	ToolTip._x = _xmouse;
	ToolTip._y = _ymouse + 20;
};
// adds a text-description of the buttons function 
function DisplayTip(tip) {
	Mouse.addListener(TipMover);
	ToolTip._x = _xmouse;
	ToolTip._y = _ymouse + 20;
	ToolTip.swapDepths(15999);
	ToolTip._width = 100;
	ToolTip._height = 20;
	ToolTip._alpha = 100;
	ToolTip.TipText.text = tip;
	ToolTip.TipText.width = ToolTip.TipText.textWidth;
	ToolTip.TipBackground._width = ToolTip.TipText.textWidth + 8;
}
// hide tip 
function CloseTip() {
	Mouse.removeListener(TipMover);
	ToolTip._alpha = 100;
	ToolTip._x = 0;
	ToolTip._y = 0;
	ToolTip._width = 1;
	ToolTip._height = 1;
}
// hide the tip initially 
CloseTip();
/*************************************************************************/
stop();
