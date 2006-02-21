//import mx.styles.CSSStyleDeclaration;
/*
_global.style.setStyle("fontSize", "11");
_global.style.setStyle("color", 0x000000);
_global.style.setStyle("embedFonts", true);
_global.style.setStyle("fontFamily", "_defaultFont");
*/
//var debugger:mx.controls.TextArea;
//_root.debugger = debugger;
//_root.debugger.text +="blsh \n";
/****************************************************************/
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
	/*ToolTip.TipText._width = 0;
	ToolTip.TipBackground._width = 0;	
	ToolTip.TipText.text = "";*/
}
// hide the tip initially 
CloseTip();
/********************************************************/
var menu_mb:mx.controls.MenuBar;
_global.history = new Objects.History();
var right_tree:mx.controls.Tree;
_global.right_tree = right_tree;
var infoflow_ta:mx.controls.TextArea;
_global.infoflow_ta = infoflow_ta;
_global.workflow_xml = new XML();
_global.workflow_xml.ignoreWhite = true;
//_global.workflow_xml.onLoad = function(success) {
//if (success) {
//.childNodes
//} else {
// something didn't load..
//}
//};
_global.workflow_xml.load("workflow.xml");
_global.right_tree_xml = new XML();
//values set in workflow object
_global.right_tree_xml.ignoreWhite = true;
_global.right_tree.dataProvider = _global.right_tree_xml;
_global.right_tree.setStyle("depthColors",[ 0x00ff00, 0xff0000, 0x0000ff ]);
//_global.right_tree.setStyle("borderStyle","alert");
_global.workflow = new Objects.WorkFlow();
var left_tree:mx.controls.Tree;
_global.left_tree = left_tree;
_global.overrides_xml = new XML();
_global.overrides_xml.ignoreWhite = true;
_global.overrides_xml.onLoad = function(success) {
};
_global.overrides_xml.load("overrides.xml");
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
function refreshTheTree() {
	//_global.left_tree.refresh(); // this is USELESS
	var oBackupDP = _global.left_tree.dataProvider;
	_global.left_tree.dataProvider = null;
	// clear
	_global.left_tree.dataProvider = oBackupDP;
	oBackupDP = _global.right_tree.dataProvider;
	_global.right_tree.dataProvider = null;
	_global.right_tree.dataProvider = oBackupDP;
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
	_global.right_tree.dataProvider.removeAll();
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
		}
	}
}
_global.projectFileName = "";
// setup the drop down menus at the top
var file_xml = new XML('<mi label="New Project" instanceName="new" /><mi label="Open Project" instanceName="open" /><mi type="separator" /><mi label="Import Client.xml" instanceName="importClient" /><mi label="Import Server.xml" instanceName="importServer" /><mi type="separator" /><mi label="Save Project" instanceName="save" /><mi label="Save Project As..." instanceName="saveAs" /><mi type="separator" /><mi label="Exit" instanceName="exit" />');
menu_mb.addMenu("File", file_xml);
var coming_soon_xml = new XML('<n label="Coming Soon!"/>');
var coming_soon_xml2 = new XML('<n label="Coming Soon!"/>');
menu_mb.addMenu("Edit", coming_soon_xml);
menu_mb.addMenu("Help", coming_soon_xml2);
mdm.Application.enableExitHandler(appExit);
var menuListener:Object = new Object();
menuListener.change = function(evt:Object) {
	var menu = evt.menu;
	var item = evt.menuItem;
	switch (item.attributes["instanceName"]) {
	case "open" :
		openFile("Project");
		break;
	case "new" :
		_global.projectFileName = "";
		_global.project = new Object();
		setView("home");
		/** Load templates*/
		client_xml.load("default_client.xml");
		server_xml.load("default_server.xml");
		setButtons(true);
		break;
	case "importClient" :
		openFile("Client");
		break;
	case "importServer" :
		openFile("Server");
		break;
	case "exit" :
		appExit();
		break;
	case "saveAs" :
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
		break;
	case "save" :
		saveFile("Project");
		break;
	}
};
//saveFile("Client");
menu_mb.addEventListener("change", menuListener);
// set view function to display correct form
setView = function (view, dataObj) {
	// reset all the components on stage to their "original" size, positions and make them visible
	treeFilter_cb._visible = true;
	left_tree._visible = true;
	left_tree._y = 93;
	left_tree.setSize(244, 670);
	right_tree._visible = true;
	_global.infoflow_ta._visible = true;
	tabs_tb._visible = true;
	//tabs_tb.enabled = false;
	tabBody_mc._visible = true;
	formContent_mc.form_mc.removeMovieClip();
	formContent_mc.createEmptyMovieClip("form_mc", 0);
	// render the view
	switch (view) {
	case "home" :
		treeFilter_cb._visible = false;
		left_tree._visible = false;
		right_tree._visible = false;
		_global.infoflow_ta._visible = false;
		formContent_mc.attachMovie("forms.home", "form_mc", 0);
		tabs_tb.dataProvider = [{label:"Project Details"}];
		tabs_tb.selectedIndex = 0;
		tabs_tb._visible = true;
		break;
	case "project" :
		var currentTab = 0;
		treeFilter_cb.change({target:treeFilter_cb});
		var label = "Project";
		if (tabs == undefined) {
			tabs = [{label:"Project"}];
		}
		tabs_tb.dataProvider = tabs;
		tabs_tb.selectedIndex = currentTab;
		//tabs_tb.enabled = true;
		//formContent_mc.attachMovie("forms."+view, "form_mc", 0, dataObj);
		break;
	case "control" :
	case "control.controls" :
	case "control.files" :
	case "control.logLevels" :
	case "control.serverLog" :
	case "control.ir" :
		_global.infoflow_ta._visible = false;
		right_tree._visible = false;
		treeFilter_cb._visible = false;
		left_tree._y = 68;
		left_tree.setSize(244, 695);
		left_tree.dataProvider = null;
		left_tree.dataProvider = new XML('<n label="Servers"><n label="Coming Soon!" /></n><n label="Clients"><n label="Coming Soon!" /></n>');
		left_tree.labelFunction = null;
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
		var form_mc = formContent_mc.attachMovie("forms." + view, "form_" + random(999) + "_mc", 0);
		//_root.debugger.text += "setting view "+view+"\n";
		_global.server.attachView(form_mc);
		//tabs_tb.enabled = true;
		break;
	case "none" :
		treeFilter_cb._visible = false;
		left_tree._visible = false;
		right_tree._visible = false;
		_global.infoflow_ta._visible = false;
		tabs_tb._visible = false;
		tabBody_mc._visible = false;
		break;
	case "preview" :
		treeFilter_cb._visible = false;
		left_tree._visible = false;
		right_tree._visible = false;
		_global.infoflow_ta._visible = false;
		formContent_mc.attachMovie("forms.preview", "form_mc", 0);
		tabs_tb.dataProvider = [{label:"Client Preview"}];
		tabs_tb.selectedIndex = 0;
		tabs_tb._visible = true;
		break;
	case "publish" :
		treeFilter_cb._visible = false;
		left_tree._visible = false;
		right_tree._visible = false;
		_global.infoflow_ta._visible = false;
		formContent_mc.attachMovie("forms.publish", "form_mc", 0);
		tabs_tb.dataProvider = [{label:"Publish", view:"publish"}];
		tabs_tb.selectedIndex = 0;
		break;
	case "history" :
		treeFilter_cb._visible = false;
		left_tree._visible = false;
		right_tree._visible = false;
		_global.infoflow_ta._visible = false;
		tabs_tb.dataProvider = [{label:"History", view:"history"}];
		tabs_tb.selectedIndex = 0;
		formContent_mc.attachMovie("forms.history", "form" + random(999) + "_history", 0);
		break;
	}
};
tabs_tb.change = function(eventObj) {
	if (this.lastTab.view != eventObj.target.selectedItem.view && eventObj.target.selectedItem.view.length) {
		if (left_tree.selectedNode.object != undefined) {
			formContent_mc.form_mc.unloadMovie();
			formContent_mc.createEmptyMovieClip("form_mc", 0);
			switch (eventObj.target.selectedItem.label) {
			case "XML" :
				var form_mc = formContent_mc.attachMovie(eventObj.target.selectedItem.view, "form_" + random(999) + "_mc", 0, {node:left_tree.selectedNode.object.toXML()});
				break;
			case "Preview" :
				var form_mc = formContent_mc.attachMovie(eventObj.target.selectedItem.view, "form_" + random(999) + "_mc", 0, {controls:_global.client_test.getControlTypes(), previewXML:left_tree.selectedNode.object.toXML()});
				break;
			default :
				var form_mc = formContent_mc.attachMovie(eventObj.target.selectedItem.view, "form_" + random(999) + "_mc", 0, left_tree.selectedNode.object.getData());
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
	var node = eventObj.target.selectedNode;
	formContent_mc.form_mc.removeMovieClip();
	formContent_mc.createEmptyMovieClip("form_mc", 0);
	right_tree.selectedNode = undefined;
	if (node.object != undefined) {
		/*if (node.description.length) {
		infoflow_ta.text = node.description;
		} else {
		infoflow_ta.text = "";
		}*/
		switch (node.nodeName) {
		case "Panel" :
		case "Tab" :
		case "Control" :
		case "Window" :
			var form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_" + random(999) + "_mc", 0, node.object.getData());
			tabs_tb.dataProvider = [{label:node.object.getName(), view:node.object.getForm()}, {label:"XML", view:"forms.project.xml"}, {label:"Preview", view:"forms.project.client.preview"}];
			tabs_tb.selectedIndex = 0;
			break;
		default :
			var form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_" + random(999) + "_mc", 0, node.object.getData());
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
		eventObj.target.selected = true;
		setView("preview");
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
function setButtons(enabled:Boolean) {
	home_btn.enabled = enabled;
	project_btn.enabled = enabled;
	control_btn.enabled = enabled;
	preview_btn.enabled = enabled;
	publish_btn.enabled = enabled;
	historyViewer_btn.enabled = enabled;
	//save_btn.enabled = enabled;
	for (var child in menu_mb.dataProvider.firstChild.childNodes) {
		if (menu_mb.dataProvider.firstChild.childNodes[child].attributes["instanceName"] == "importClient") {
			menu_mb.dataProvider.firstChild.childNodes[child].attributes.enabled = enabled;
		}
		if (menu_mb.dataProvider.firstChild.childNodes[child].attributes["instanceName"] == "importServer") {
			menu_mb.dataProvider.firstChild.childNodes[child].attributes.enabled = enabled;
		}
		if (menu_mb.dataProvider.firstChild.childNodes[child].attributes["instanceName"] == "saveAs") {
			menu_mb.dataProvider.firstChild.childNodes[child].attributes.enabled = enabled;
		}
		if (menu_mb.dataProvider.firstChild.childNodes[child].attributes["instanceName"] == "save") {
			menu_mb.dataProvider.firstChild.childNodes[child].attributes.enabled = enabled;
		}
	}
	var oBackupDP = menu_mb.dataProvider;
	menu_mb.dataProvider = null;
	menu_mb.dataProvider = oBackupDP;
}
home_btn.addEventListener("click", buttonListener);
project_btn.addEventListener("click", buttonListener);
control_btn.addEventListener("click", buttonListener);
preview_btn.addEventListener("click", buttonListener);
publish_btn.addEventListener("click", buttonListener);
historyViewer_btn.addEventListener("click", buttonListener);
save_btn.addEventListener("click", buttonListener);
save_btn.enabled = true;
save_btn.icon = "floppytrue";
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
save_btn.onRollOver = function() {
	DisplayTip("Save");
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
save_btn.onRollOut = function() {
	CloseTip();
	this.setState(false);
	//this.highlight = false;
};
save_btn.click = function(){
		//DO SAVE
		this.icon = "floppyfalse";
		//eventObj.target.selected =false;
		//eventObj.target.enabled = false;
		break;
}
setButtons(false);
treeFilter_cb.change = function(eventObj) {
	switch (eventObj.target.selectedItem.label) {
	case "Project" :
		left_tree.dataProvider = projectTree_xml;
		left_tree.labelFunction = function(item_obj:Object):String  {
			//if (item_obj.object.isValid()) {
				return item_obj.object.getName();
			/*} else {
				return "*" + item_obj.object.getName();
			}*/
		};
		break;
	case "Library" :
		left_tree.dataProvider = new XML('<n label="Icons" /><n label="Sounds" /><n label="Windows" /><n label="Tabs" /><n label="Rooms" /><n label="Controls" />');
		left_tree.labelFunction = null;
		break;
	}
};
treeFilter_cb.addEventListener("change", treeFilter_cb);
rightTreeListener = new Object();
rightTreeListener.change = function(eventObj) {
	var node = eventObj.target.selectedNode;
	left_tree.setIsOpen(node.left_node, true);
	var temp_node = node.left_node.parentNode;
	while (temp_node != null) {
		left_tree.setIsOpen(temp_node, true);
		temp_node = temp_node.parentNode;
	}
	left_tree.selectedNode = node.left_node;
	infoflow_ta.text = node.attributes.description;
	left_tree.setFocus();
	left_tree.dataProvider.updateViews("change");
	selectNode = new Object();
	selectNode.target = _global.left_tree;
	selectNode.type = "change";
	left_tree.dispatchEvent(selectNode);
};
right_tree.addEventListener("change", rightTreeListener);
setView("none");
stop();
