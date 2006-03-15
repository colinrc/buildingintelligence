historyViewer_btn._visible = false;
mdm.Application.enableExitHandler(appExit);
_global.advanced = false;
_global.unSaved = false;
var form_mc;
_global.formDepth = 0;
var keyListener:Object = new Object();
keyListener.onKeyDown = function() {
	if (Key.isDown(Key.ESCAPE)) {
		appExit();
	}
};
Key.addListener(keyListener);
//advanced_btn._visible = false;
//var debugger:mx.controls.TextArea;
//_root.debugger = debugger;
//_root.debugger.text +="blsh \n";
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
/********************************************************/
var menu_mb:mx.controls.MenuBar;
_global.history = new Objects.History();
var right_tree = workFlow_split.setFirstContents("Tree", "right_tree", 0);
var infoflow_ta = workFlow_split.setSecondContents("TextArea", "infoflow_ta", 1);
_global.right_tree = right_tree;
_global.infoflow_ta = infoflow_ta;
_global.infoflow_ta.editable = false;
_global.infoflow_ta.wordWrap = true;
_global.workflow = new Objects.WorkFlow();
var left_tree:mx.controls.Tree;
_global.left_tree = left_tree;
_global.overrides_xml = new XML();
_global.overrides_xml.ignoreWhite = true;
_global.overrides_xml.onLoad = function(success) {
};
_global.overrides_xml.load("overrides.xml");
_global.parameters_xml = new XML();
_global.parameters_xml.ignoreWhite = true;
_global.parameters_xml.onLoad = function(success) {
};
_global.parameters_xml.load("parameters.xml");
_global.controlTypeAttributes_xml = new XML();
_global.controlTypeAttributes_xml.ignoreWhite = true;
_global.controlTypeAttributes_xml.onLoad = function(success) {
};
_global.controlTypeAttributes_xml.load("controlTypeAttributes.xml");
_global.server = new Objects.ServerConnection();
_global.style.setStyle("themeColor", "haloBlue");
_global.left_tree.vScrollPolicy = right_tree.vScrollPolicy = "auto";
_global.left_tree.hScrollPolicy = "auto";
_global.left_tree.setStyle("openDuration", 50);
// form holder placed in the correct spot
this.createEmptyMovieClip("formContent_mc", 0);
formContent_mc._x = 270;
formContent_mc._y = 114;
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
_global.refreshTheTree = function() {
	var oBackupDP = _global.left_tree.dataProvider;
	_global.left_tree.dataProvider = null;
	// clear
	_global.left_tree.dataProvider = oBackupDP;
	_global.workflow.buildWorkflowTree();
	createWorkflow(projectTree_xml);
	oBackupDP = _global.right_tree.dataProvider;
	_global.right_tree.dataProvider = null;
	_global.right_tree.dataProvider = oBackupDP;
	/*for(var child in _global.right_tree.dataProvider.childNodes){
	_global.right_tree.setIsOpen(_global.right_tree.dataProvider.childNodes[child],false);
	}*/
};
function createWorkflow(inNode:Object) {
	_global.workflow.addNode(inNode.object.getKey(), inNode);
	for (var child in inNode.childNodes) {
		createWorkflow(inNode.childNodes[child]);
	}
}
// load project xml data
var project_xml = new XML();
_global.project = new Object();
var projectTree_xml = new XML();
project_xml.ignoreWhite = true;
project_xml.onLoad = function(success) {
	//projectTree_xml = new XML();
	for (var child in projectTree_xml.childNodes) {
		if (projectTree_xml.childNodes[child].nodeName == "Client") {
			projectTree_xml.childNodes[child].removeNode();
		}
	}
	for (var child in projectTree_xml.childNodes) {
		if (projectTree_xml.childNodes[child].nodeName == "Server") {
			projectTree_xml.childNodes[child].removeNode();
		}
	}
	for (var child in project_xml.firstChild.childNodes) {
		switch (project_xml.firstChild.childNodes[child].nodeName) {
		case "CONFIG" :
			_global.server_test = new Objects.Server.Server();
			_global.server_test.setXML(project_xml.firstChild.childNodes[child]);
			break;
		case "application" :
			_global.client_test = new Objects.Client.Client();
			_global.client_test.setXML(project_xml.firstChild.childNodes[child]);
			break;
		case "projectSettings" :
			_global.project = new Object();
			for (var attrib in project_xml.firstChild.childNodes[child].attributes) {
				_global.project[attrib] = project_xml.firstChild.childNodes[child].attributes[attrib];
			}
			_global.history = null;
			_global.history = new Objects.History();
			_global.history.setProject(_global.project.project);
			break;
		}
	}
	//_global.right_tree.dataProvider.removeAll();
	projectTree_xml.appendChild(_global.client_test.toTree());
	projectTree_xml.appendChild(_global.server_test.toTree());
	refreshTheTree();
};
var client_xml = new XML();
client_xml.ignoreWhite = true;
client_xml.onLoad = function(success) {
	_global.client_test = new Objects.Client.Client();
	_global.client_test.setXML(client_xml.firstChild);
	for (var child in projectTree_xml.childNodes) {
		if (projectTree_xml.childNodes[child].nodeName == "Client") {
			projectTree_xml.childNodes[child].removeNode();
		}
	}
	projectTree_xml.appendChild(_global.client_test.toTree());
	refreshTheTree();
};
var server_xml = new XML();
server_xml.ignoreWhite = true;
server_xml.onLoad = function(success) {
	_global.server_test = new Objects.Server.Server();
	_global.server_test.setXML(this.firstChild);
	for (var child in projectTree_xml.childNodes) {
		if (projectTree_xml.childNodes[child].nodeName == "Server") {
			projectTree_xml.childNodes[child].removeNode();
		}
	}
	projectTree_xml.appendChild(_global.server_test.toTree());
	refreshTheTree();
};
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
	mdm.Application.exit("ask", "Are you sure you want to Exit?");
}
function openFile(openType:String):Void {
	mdm.Dialogs.BrowseFile.buttonText = "Open file";
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
			project_xml.load(file);
			setButtons(true);
			setView("project");
			break;
		case "Server" :
			server_xml.load(file);
			break;
		case "Client" :
			client_xml.load(file);
			break;
		}
	}
}
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
		tempString += " " + attribute + '= "' + inNode.attributes[attribute] + '"';
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
function saveFile(saveType:String):Void {
	if (saveType == "Project") {
		if (_global.projectFileName.length) {
			var newProjectXML = new XMLNode(1, "project");
			var myXML = new XMLNode(1, 'projectSettings');
			for (var attrib in _global.project) {
				if (_global.project[attrib].length) {
					myXML.attributes[attrib] = _global.project[attrib];
				}
			}
			newProjectXML.appendChild(myXML);
			newProjectXML.appendChild(_global.server_test.toXML());
			newProjectXML.appendChild(_global.client_test.toXML());
			mdm.FileSystem.saveFile(_global.projectFileName, _global.writeXMLFile(newProjectXML, 0));
			//mdm.Dialogs.prompt("File saved to: " + _global.projectFileName);
			_global.unSaved = false;
		} else {
			mdm.Dialogs.BrowseFile.buttonText = "Save Project";
			mdm.Dialogs.BrowseFile.title = "Please select a location to save to";
			mdm.Dialogs.BrowseFile.dialogText = "Please select a location to save to";
			mdm.Dialogs.BrowseFile.defaultExtension = "xml";
			mdm.Dialogs.BrowseFile.filterList = "XML Files|*.xml";
			mdm.Dialogs.BrowseFile.filterText = "XML Files|*.xml";
			var tempString = mdm.Dialogs.BrowseFile.show();
			if (tempString != "false") {
				_global.projectFileName = tempString;
				var newProjectXML = new XMLNode(1, "project");
				var myXML = new XMLNode(1, 'projectSettings');
				for (var attrib in _global.project) {
					if (_global.project[attrib].length) {
						myXML.attributes[attrib] = _global.project[attrib];
					}
				}
				newProjectXML.appendChild(myXML);
				newProjectXML.appendChild(_global.server_test.toXML());
				newProjectXML.appendChild(_global.client_test.toXML());
				mdm.FileSystem.saveFile(_global.projectFileName, _global.writeXMLFile(newProjectXML, 0));
				//mdm.Dialogs.prompt("File saved to: " + _global.projectFileName);
				_global.unSaved = false;
			}
		}
	} else {
		mdm.Dialogs.BrowseFile.buttonText = "Save file";
		mdm.Dialogs.BrowseFile.title = "Please select a " + saveType + ".xml file to save";
		mdm.Dialogs.BrowseFile.dialogText = "Select a " + saveType + ".xml to Save";
		mdm.Dialogs.BrowseFile.defaultExtension = "xml";
		mdm.Dialogs.BrowseFile.filterList = "XML Files|*.xml";
		mdm.Dialogs.BrowseFile.filterText = "XML Files|*.xml";
		var file = mdm.Dialogs.BrowseFile.show();
		if (file != undefined) {
			if (saveType == "Server") {
				mdm.FileSystem.saveFile(file, _global.writeXMLFile(_global.server_test.toXML(), 0));
			} else {
				mdm.FileSystem.saveFile(file, _global.writeXMLFile(_global.client_test.toXML(), 0));
			}
			mdm.Dialogs.prompt("File saved to: " + file);
		}
	}
}
_global.saveFile = saveFile;
_global.projectFileName = "";
// setup the drop down menus at the top
/****************************************************************/
mdm.Menu.Main.menuType = "function";
mdm.Menu.Main.insertHeader("File");
mdm.Menu.Main.insertHeader("Help");
mdm.Menu.Main.insertItem("File", "New Project");
mdm.Menu.Main.insertItem("File", "Open Project");
mdm.Menu.Main.insertDivider("File");
mdm.Menu.Main.insertItem("File", "Import Server XML");
mdm.Menu.Main.insertItem("File", "Import Client XML");
mdm.Menu.Main.insertDivider("File");
mdm.Menu.Main.insertItem("File", "Save Project");
mdm.Menu.Main.insertItem("File", "Save Project As..");
mdm.Menu.Main.insertDivider("File");
mdm.Menu.Main.insertItem("File", "Exit");
mdm.Menu.Main.onMenuClick_New_Project = function() {
	_global.projectFileName = "";
	_global.project = new Object();
	setView("home");
	/** Load templates*/
	/*_global.right_tree.dataProvider.removeAll();
	_global.workflow.buildWorkflowTree();*/
	client_xml.load("default_client.xml");
	server_xml.load("default_server.xml");
	_global.refreshTheTree();
	setButtons(true);
};
mdm.Menu.Main.onMenuClick_Open_Project = function() {
	openFile("Project");
};
mdm.Menu.Main.onMenuClick_Import_Server_XML = function() {
	openFile("Server");	
};
mdm.Menu.Main.onMenuClick_Import_Client_XML = function() {
	openFile("Client");
};
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
	// reset all the components on stage to their "original" size, positions and make them visible     
	left_tree._visible = true;
	/*left_tree._y = 93;
	left_tree.setSize(244, 670);*/
	workFlow_split._visible = true;
	tabs_tb._visible = true;
	tabBody_mc._visible = true;
	form_mc.removeMovieClip();
	//form_mc = formContent_mc.createEmptyMovieClip("form_"+ formContent_mc.getNextHighestDepth()+"_mc", formContent_mc.getNextHighestDepth());
	// render the view
	switch (view) {
	case "home" :
		left_tree._visible = false;
		workFlow_split._visible = false;
		form_mc = formContent_mc.attachMovie("forms.home", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth());
		tabs_tb.dataProvider = [{label:"Project Details"}];
		tabs_tb.selectedIndex = 0;
		tabs_tb._visible = true;
		break;
	case "project" :
		var currentTab = 0;
		var label = "Project";
		if (tabs == undefined) {
			tabs = [{label:"Project"}];
		}
		tabs_tb.dataProvider = tabs;
		tabs_tb.selectedIndex = currentTab;
		left_tree.dataProvider = projectTree_xml;
		left_tree.labelFunction = function(item_obj:Object):String  {
			return item_obj.object.getName();
		};
		break;
	case "control" :
	case "control.controls" :
	case "control.files" :
	case "control.logLevels" :
	case "control.serverLog" :
	case "control.ir" :
		//_global.infoflow_ta._visible = false;
		workFlow_split._visible = false;
		left_tree._visible = false;
		/*left_tree._y = 68;
		left_tree.setSize(244, 695);
		left_tree.dataProvider = null;
		left_tree.dataProvider = new XML('<n label="Servers"><n label="Coming Soon!" /></n><n label="Clients"><n label="Coming Soon!" /></n>');
		left_tree.labelFunction = null;*/
		tabs_tb.dataProvider = [{label:"Control", view:"control.controls"}, {label:"Files", view:"control.files"}, {label:"Log Levels", view:"control.logLevels"}, {label:"Log", view:"control.serverLog"}, {label:"IR", view:"control.ir"}];
		if (view == "control.controls") {
			tabs_tb.selectedIndex = 0;
		} else if (view == "control.files") {
			tabs_tb.selectedIndex = 1;
		} else if (view == "control.logLevels") {
			tabs_tb.selectedIndex = 2;
		} else if (view == "control.serverLog") {
			tabs_tb.selectedIndex = 3;
		} else if (view == "control.ir") {
			tabs_tb.selectedIndex = 4;
		} else {
			tabs_tb.selectedIndex = 0;
			view = "control.controls";
		}
		form_mc = formContent_mc.attachMovie("forms." + view, "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth());
		//_root.debugger.text += "setting view "+view+"\n";
		_global.server.attachView(form_mc);
		break;
	case "none" :
		left_tree._visible = false;
		workFlow_split._visible = false;
		tabs_tb._visible = false;
		tabBody_mc._visible = false;
		break;
	case "publish" :
		left_tree._visible = false;
		workFlow_split._visible = false;
		form_mc = formContent_mc.attachMovie("forms.publish", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth());
		tabs_tb.dataProvider = [{label:"Publish", view:"publish"}];
		tabs_tb.selectedIndex = 0;
		break;
	case "history" :
		left_tree._visible = false;
		workFlow_split._visible = false;
		tabs_tb.dataProvider = [{label:"History", view:"history"}];
		tabs_tb.selectedIndex = 0;
		form_mc = formContent_mc.attachMovie("forms.history", "form" + (_global.formDepth++) + "_history", formContent_mc.getNextHighestDepth());
		break;
	}
};
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
		if (form_mc.dataObject != undefined) {
			var tempObject = form_mc.dataObject;
			form_mc.removeMovieClip();
			//form_mc = formContent_mc.createEmptyMovieClip("form_"+ formContent_mc.getNextHighestDepth()+"mc",  formContent_mc.getNextHighestDepth());
			switch (eventObj.target.selectedItem.label) {
			case "XML" :
				form_mc = formContent_mc.attachMovie("forms.project.xml", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), {node:tempObject.toXML(), dataObject:tempObject});
				break;
			case "Preview" :
				form_mc = formContent_mc.attachMovie("forms.project.client.preview", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), {controls:_global.client_test.getControlTypes(), previewXML:tempObject.toXML(), dataObject:tempObject});
				break;
			case "Overrides":
				form_mc = formContent_mc.attachMovie("forms.project.client.overrides", "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), {attributes:tempObject.getAttributes(), attributeGroups:tempObject.attributeGroups,dataObject:tempObject});
				break;			
			default :
				form_mc = formContent_mc.attachMovie(tempObject.getForm(), "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), tempObject.getData());
				break;
			}
		} else {
			setView(eventObj.target.selectedItem.view, form_mc.dataObj);
		}
	}
	this.lastTab = this.selectedItem;
};
tabs_tb.addEventListener("change", tabs_tb);
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
	if (node.object != undefined) {
		switch (node.nodeName) {
		case "Client":
		case "StatusBarGroup":
		case "Logging":
		case "ClientIcon":
			form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), node.object.getData());
			tabs_tb.dataProvider = [{label:node.object.getName(), view:node.object.getForm()},{label:"Overrides", view:"forms.project.client.overrides"}, {label:"XML", view:"forms.project.xml"}];
			tabs_tb.selectedIndex = 0;		
			break;
		case "Window" :
			form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), node.object.getData());
			tabs_tb.dataProvider = [{label:node.object.getName(), view:node.object.getForm()}, {label:"Overrides", view:"forms.project.client.overrides"},{label:"Preview", view:"forms.project.client.preview"},{label:"XML", view:"forms.project.xml"}];
			tabs_tb.selectedIndex = 0;
			break;
		case "Panel" :
		case "Tab" :
		case "Control" :
			form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_" + (_global.formDepth++) + "_mc", formContent_mc.getNextHighestDepth(), node.object.getData());
			tabs_tb.dataProvider = [{label:node.object.getName(), view:node.object.getForm()}, {label:"XML", view:"forms.project.xml"}, {label:"Preview", view:"forms.project.client.preview"}];
			tabs_tb.selectedIndex = 0;
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
		mdm.FileSystem.saveFile("client.xml", _global.writeXMLFile(_global.client_test.toXML(), 0));
		mdm.Forms.Preview.callFunction("parseClient", '<client><setting name="applicationXML" value="client.xml" /><setting name="libLocation" value="lib/" /><setting name="fullScreen" value="false" /><setting name="hideMouseCursor" value="false" /></client>', "|");
		mdm.Forms.Preview.showModal();
		break;
	case publish_btn :
		eventObj.target.selected = true;
		setView("publish");
		break;
	case historyViewer_btn :
		eventObj.target.selected = true;
		setView("history");
		break;
	}
};
home_btn.addEventListener("click", buttonListener);
project_btn.addEventListener("click", buttonListener);
control_btn.addEventListener("click", buttonListener);
preview_btn.addEventListener("click", buttonListener);
publish_btn.addEventListener("click", buttonListener);
historyViewer_btn.addEventListener("click", buttonListener);
buttonListener2 = new Object();
buttonListener2.click = function(eventObj) {
	switch (eventObj.target) {
	case advanced_btn :
		advanced_btn.icon = "advanced" + (!_global.advanced);
		_global.advanced = (!_global.advanced);
		CloseTip();
		var tempObject = _global.left_tree.selectedNode.object;
		for (var child in projectTree_xml.childNodes) {
			if ((projectTree_xml.childNodes[child].nodeName == "Server") || (projectTree_xml.childNodes[child].nodeName == "Client")) {
				projectTree_xml.childNodes[child].removeNode();
			}
		}
		/*_global.right_tree.dataProvider.removeAll();
		_global.workflow.buildWorkflowTree();*/
		projectTree_xml.appendChild(_global.client_test.toTree());
		projectTree_xml.appendChild(_global.server_test.toTree());
		_global.refreshTheTree();
		if (_global.advanced) {
			DisplayTip("Advanced View");
		} else {
			DisplayTip("Basic View");
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
		refreshTheTree();
		left_tree.selectedNode = foundNode;
		break;
	}
};
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
advanced_btn.addEventListener("click", buttonListener2);
function setButtons(enabled:Boolean) {
	home_btn.enabled = enabled;
	project_btn.enabled = enabled;
	control_btn.enabled = enabled;
	preview_btn.enabled = enabled;
	publish_btn.enabled = enabled;
	historyViewer_btn.enabled = enabled;
	advanced_btn.enabled = enabled;
mdm.Menu.Main.itemVisible("File", "Import Server XML",enabled);
mdm.Menu.Main.itemVisible("File", "Import Client XML",enabled);
mdm.Menu.Main.itemVisible("File", "Save Project",enabled);
mdm.Menu.Main.itemVisible("File", "Save Project As..",enabled);
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
publish_btn.onRollOver = function() {
	DisplayTip("Project Publish");
	this.setState("highlighted");
};
historyViewer_btn.onRollOver = function() {
	DisplayTip("Changelog");
	this.setState("highlighted");
};
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
publish_btn.onRollOut = function() {
	CloseTip();
	this.setState(false);
};
historyViewer_btn.onRollOut = function() {
	CloseTip();
	this.setState(false);
};
advanced_btn.onRollOut = function() {
	CloseTip();
	this.setState(false);
};
setButtons(false);
/*treeFilter_cb.change = function(eventObj) {
switch (eventObj.target.selectedItem.label) {
case "Project" :
left_tree.dataProvider = projectTree_xml;
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
_global.right_tree.cellRenderer = "workFlowTreeCellRenderer";
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
			infoflow_ta.text = node.attributes.description;
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
stop();
