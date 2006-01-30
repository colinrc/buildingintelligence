﻿//import mx.styles.CSSStyleDeclaration;
/*
_global.style.setStyle("fontSize", "11");
_global.style.setStyle("color", 0x000000);
_global.style.setStyle("embedFonts", true);
_global.style.setStyle("fontFamily", "_defaultFont");
*/

var menu_mb:mx.controls.MenuBar;
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
//XML.prototype.ignoreWhite = true;
//test serverconnection
//var server:Objects.ServerConnection;
var server = new Objects.ServerConnection("Server1", "127.0.0.1", 10002, 10001);
server.makeConnections();
//_global.style.setStyle("themeColor", "haloOrange");
_global.left_tree.vScrollPolicy = right_tree.vScrollPolicy="auto";
_global.left_tree.hScrollPolicy = "auto";
_global.left_tree.setStyle("openDuration", 50);
// form holder placed in the correct spot
this.createEmptyMovieClip("formContent_mc", 0);
formContent_mc._x = 270;
formContent_mc._y = 114;
_global.comboSetSelected = function(combo, val, field) {
	for (var i = 0; i<combo.length; i++) {
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
}
// load project xml data
var project_xml = new XML();
var client_xml = new XML();
client_xml.ignoreWhite = true;
client_xml.onLoad = function(success) {
	_global.client_test = new Objects.Client.Client();
	_global.client_test.setXML(client_xml.firstChild);
	for (var child in project_xml.childNodes) {
		if (project_xml.childNodes[child].nodeName == "Client") {
			project_xml.childNodes[child].removeNode();
		}
	}
	project_xml.appendChild(_global.client_test.toTree());
	refreshTheTree();
};
var server_xml = new XML();
server_xml.ignoreWhite = true;
server_xml.onLoad = function(success) {
	_global.server_test = new Objects.Server.Server();
	_global.server_test.setXML(this.firstChild);
	for (var child in project_xml.childNodes) {
		if (project_xml.childNodes[child].nodeName == "Server") {
			project_xml.childNodes[child].removeNode();
		}
	}
	project_xml.appendChild(_global.server_test.toTree());
	refreshTheTree();
};
// setup the drop down menus at the top
var file_xml = new XML('<mi label="New Client.xml" instanceName="newClient" /><mi label ="New Server.xml" instanceName="newServer"/><mi label="Open Client.xml" instanceName="openClient" /><mi label="Open Server.xml" instanceName="openServer" /><mi label="Close Client.xml" instanceName="closeClient" /><mi label="Close Server.xml" instanceName="closeServer" /><mi type="separator" /><mi label="Save Project" instanceName="save" /><mi label="Client.xml Save As..." instanceName="saveAsClient" /><mi label="Server.xml Save As..." instanceName="saveAsServer" /><mi type="separator" /><mi label="Exit" instanceName="exit" />');
menu_mb.addMenu("File", file_xml);
menu_mb.addMenu("Edit", null);
menu_mb.addMenu("Help", null);
mdm.Application.onAppExit = function() {
	appExit();
};
function appExit():Void {
	mdm.Application.exit("ask", "Are you sure you want to Exit?");
}
function openFile(openType:String):Void {
	mdm.Dialogs.BrowseFile.buttonText = "Open file";
	mdm.Dialogs.BrowseFile.title = "Please select a "+openType+".xml file to open";
	mdm.Dialogs.BrowseFile.dialogText = "Select a "+openType+".xml to Use";
	mdm.Dialogs.BrowseFile.defaultExtension = "xml";
	mdm.Dialogs.BrowseFile.filterList = "XML Files|*.xml";
	mdm.Dialogs.BrowseFile.filterText = "XML Files|*.xml";
	var file = mdm.Dialogs.BrowseFile.show();
	if (openType == "Server") {
		server_xml.load(file);
	} else {
		client_xml.load(file);
	}
}
function writeXMLFile(inNode:XMLNode, depth:Number):String {
	var tempString = "";
	for (index=0; index<depth; index++) {
		tempString += "\t";
	}
	if (inNode.nodeType == 3) {
		tempString += inNode.toString()+"\n";
		return tempString;
	}
	tempString += "<";
	tempString += inNode.nodeName+" ";
	for (attribute in inNode.attributes) {
		tempString += attribute+'= "'+inNode.attributes[attribute]+'" ';
	}
	if (inNode.hasChildNodes()) {
		tempString += "> \n";
		for (var child = 0; child<inNode.childNodes.length; child++) {
			tempString += writeXMLFile(inNode.childNodes[child], depth+1);
		}
		for (index=0; index<depth; index++) {
			tempString += "\t";
		}
		return tempString+"</"+inNode.nodeName+"> \n";
	} else {
		return tempString+"/> \n";
	}
}
function saveFile(saveType:String):Void {
	mdm.Dialogs.BrowseFile.buttonText = "Save file";
	mdm.Dialogs.BrowseFile.title = "Please select a "+saveType+".xml file to save";
	mdm.Dialogs.BrowseFile.dialogText = "Select a "+saveType+".xml to Save";
	mdm.Dialogs.BrowseFile.defaultExtension = "xml";
	mdm.Dialogs.BrowseFile.filterList = "XML Files|*.xml";
	mdm.Dialogs.BrowseFile.filterText = "XML Files|*.xml";
	var file = mdm.Dialogs.BrowseFile.show();
	if (saveType == "Server") {
		mdm.FileSystem.saveFile(file, writeXMLFile(_global.server_test.toXML(), 0));
	} else {
		mdm.FileSystem.saveFile(file, writeXMLFile(_global.client_test.toXML(), 0));
	}
}
mdm.Application.enableExitHandler(appExit);
var menuListener:Object = new Object();
menuListener.change = function(evt:Object) {
	var menu = evt.menu;
	var item = evt.menuItem;
	switch (item.attributes["instanceName"]) {
	case "newClient" :
		trace(item.attributes["instanceName"]+" 1");
		break;
	case "newServer" :
		trace(item.attributes["instanceName"]+" 1");
		break;
	case "openClient" :
		openFile("Client");
		break;
	case "openServer" :
		openFile("Server");
		break;
	case "closeClient" :
		trace(item.attributes["instanceName"]+" 3");
		break;
	case "closeServer" :
		trace(item.attributes["instanceName"]+" 3");
		break;
	case "exit" :
		appExit();
		break;
	case "saveAsClient" :
		saveFile("Client");
		break;
	case "saveAsServer" :
		saveFile("Server");
		break;
	case "save" :
		trace(item.attributes["instanceName"]+" 6");
		break;
	}
};
menu_mb.addEventListener("change", menuListener);
// set view function to display correct form
setView = function (view, dataObj) {
	// reset all the components on stage to their "original" size, positions and make them visible
	treeFilter_cb._visible = true;
	left_tree._visible = true;
	left_tree._y = 93;
	left_tree._height = 670;
	right_tree._visible = true;
	tabs_tb._visible = true;
	tabBody_mc._visible = true;
	formContent_mc.form_mc.removeMovieClip();
	formContent_mc.createEmptyMovieClip("form_mc", 0);
	// render the view
	switch (view) {
	case "home" :
		treeFilter_cb._visible = false;
		left_tree._visible = false;
		right_tree._visible = false;
		formContent_mc.attachMovie("forms.home", "form_mc", 0);
		tabs_tb.dataProvider = [{label:"Sample House"}];
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
		//formContent_mc.attachMovie("forms."+view, "form_mc", 0, dataObj);
		break;
	case "control" :
	case "control.controls" :
	case "control.files" :
	case "control.logLevels" :
	case "control.serverLog" :
	case "control.ir" :
		treeFilter_cb._visible = false;
		left_tree._y = 68;
		left_tree._height = 695;
		left_tree.dataProvider = null;
		//left_tree.dataProvider = new XML('<n label="Servers"><n label="Server 1" /><n label="Server 2" /></n><n label="Clients"><n label="Client 1" /><n label="Client 2" /><n label="Client 3" /></n>');
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
		var form_mc = formContent_mc.attachMovie("forms."+view, "form"+random(999)+"_mc", 0);
		server.attachView(form_mc);
		break;
	case "preview" :
		treeFilter_cb._visible = false;
		left_tree._visible = false;
		right_tree._visible = false;
		tabs_tb._visible = false;
		tabBody_mc._visible = false;
		break;
	case "publish" :
		treeFilter_cb._visible = false;
		left_tree._visible = false;
		right_tree._visible = false;
		tabs_tb.dataProvider = [{label:"Publish", view:"publish"}];
		tabs_tb.selectedIndex = 0;
		break;
	}
};
setView("home");
tabs_tb.change = function(eventObj) {
	if (this.lastTab.view != eventObj.target.selectedItem.view && eventObj.target.selectedItem.view.length) {
		if (left_tree.selectedNode.object != undefined) {
			formContent_mc.form_mc.unloadMovie();
			formContent_mc.createEmptyMovieClip("form_mc", 0);
			if (eventObj.target.selectedItem.label == "XML") {
				var form_mc = formContent_mc.attachMovie(eventObj.target.selectedItem.view, "form_"+random(999)+"_mc", 0, {node:left_tree.selectedNode.object.toXML()});
			} else if (eventObj.target.selectedItem.label == "Preview") {
				var form_mc = formContent_mc.attachMovie(eventObj.target.selectedItem.view, "form_"+random(999)+"_mc", 0, {controls:_global.client_test.getControlTypes(), windowXML:left_tree.selectedNode.object.toXML()});
			} else {
				var form_mc = formContent_mc.attachMovie(eventObj.target.selectedItem.view, "form_"+random(999)+"_mc", 0, left_tree.selectedNode.object.getData());
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
	if (node.object != undefined) {
		if (node.nodeName != "Window") {
			var form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_"+random(999)+"_mc", 0, node.object.getData());
			tabs_tb.dataProvider = [{label:node.object.getName(), view:node.object.getForm()}, {label:"XML", view:"forms.project.xml"}];
			tabs_tb.selectedIndex = 0;
		} else {
			var form_mc = formContent_mc.attachMovie(node.object.getForm(), "form_"+random(999)+"_mc", 0, node.object.getData());
			tabs_tb.dataProvider = [{label:node.object.getName(), view:node.object.getForm()}, {label:"XML", view:"forms.project.xml"}, {label:"Preview", view:"forms.project.client.preview"}];
			tabs_tb.selectedIndex = 0;
		}
	}
};
left_tree.addEventListener("change", leftTreeListener);
buttonListener = new Object();
buttonListener.last_btn = null;
buttonListener.click = function(eventObj) {
	this.last_btn.selected = false;
	eventObj.target.selected = true;
	this.last_btn = eventObj.target;
	switch (eventObj.target) {
	case home_btn :
		setView("home");
		break;
	case project_btn :
		setView("project");
		break;
	case control_btn :
		setView("control");
		break;
	case preview_btn :
		setView("preview");
		break;
	case publish_btn :
		setView("publish");
		break;
	}
};
home_btn.addEventListener("click", buttonListener);
project_btn.addEventListener("click", buttonListener);
control_btn.addEventListener("click", buttonListener);
preview_btn.addEventListener("click", buttonListener);
publish_btn.addEventListener("click", buttonListener);
treeFilter_cb.change = function(eventObj) {
	switch (eventObj.target.selectedItem.label) {
	case "Project" :
		left_tree.dataProvider = project_xml;
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
treeFilter_cb.addEventListener("change", treeFilter_cb);

stop();
