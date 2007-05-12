/
historyViewer_btn._visible = false;
/*************************************************************************/
//Global style
_global.style.setStyle("themeColor", "haloBlue");
/********************************************************/

_focusrect = false;

// form holder placed in the correct spot
var blocker:MovieClip;
var libraryManager:MovieClip;
//this.createEmptyMovieClip("formContent_mc", 0);
formContent_mc._x = 270;
formContent_mc._y = 90;
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
_global.keys = _global.serverDesign.getKeys();
/*Workflow tree variables and initialization*/
var treeSwitcher = workFlow_split.setFirstContents("TreeSwitcher","treeSwitcher", 0);
var output_panel = workFlow_split.setSecondContents("OutputPanel", "output_panel", 1);
_global.right_tree = treeSwitcher.getClip2();
_global.output_panel = output_panel;
_global.workflow = new Objects.WorkFlow();
//Create global reference to project/design tree
_global.left_tree = treeSwitcher.getClip1();
_global.left_tree.vScrollPolicy = _global.right_tree.vScrollPolicy = "auto";
_global.right_tree.hScrollPolicy = "off";
_global.left_tree.hScrollPolicy = "on";
_global.left_tree.maxHPosition = 150;
_global.output_panel.hScrollPolicy = "auto";
_global.left_tree.setStyle("openDuration", 50);
_global.left_tree.cellRenderer = "LeftTreeCellRenderer";
/*************************************************************************/
//link to required xml files
//Load list of overrides for client objects
_global.overrides_xml = new XML();
_global.overrides_xml.ignoreWhite = true;
/********************************************************************************/
*	_global.overrides_xml.onLoad 
_global.overrides_xml.load("data/overrides.xml");

//Load list of possible raw parameters
_global.parameters_xml = new XML();
_global.parameters_xml.ignoreWhite = true;

*   _global.parameters_xml.onLoad 
_global.parameters_xml.load("data/parameters.xml");
//Load default client configuration
_global.default_client_xml = new XML();
_global.default_client_xml.ignoreWhite = true;
*	_global.default_client_xml.onLoad

_global.default_client_xml.load("defaults/default_client.xml");
//Load default client configuration
_global.default_server_xml = new XML();
_global.default_server_xml.ignoreWhite = true;
*	_global.default_server_xml.onLoad

_global.default_server_xml.load("defaults/default_server.xml");
//Load list of possible control type attributes
_global.controlTypeAttributes_xml = new XML();
_global.controlTypeAttributes_xml.ignoreWhite = true;
*	_global.controlTypeAttributes_xml.onLoad

_global.controlTypeAttributes_xml.load("data/controlTypeAttributes.xml");
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
*	project_xml.onLoad
/**************************************************************************************/
/*For importing client xml files*/
var client_xml = new XML();
client_xml.ignoreWhite = true;
*	client_xml.onLoad
/**************************************************************************************/
/*For importing server xml files*/
var server_xml = new XML();
server_xml.ignoreWhite = true;
*	server_xml.onLoad

var comfort_XML = new XML();
comfort_XML.ignoreWhite = true;
*	comfort_XML.onLoad

_global.comfort_XML = comfort_XML;
_global.comfort_XML.load("defaults/default_comfort.xml");
/**************************************************************************************/

function openFile(openType:String):Void 
_global.setPath = function():Void  
/**************************************************************************************/
_global.saveFile = function(saveType:String):Void  
_global.searchProject = function(treeNode:Object, object:Object):Object  
_global.refreshTheTree = function() 
_global.isKeyValid = function(inKey:String):Boolean  
_global.isKeyUsed = function(inKey:String):Boolean 
_global.makeArray = function(inString:String):Array  
_global.isValidIP = function(ip:String):Boolean  
function createWorkflow(inNode:Object) 

/*************************************************************************
Build xml formatted string to be written to file. This contains all the tabs
and line feeds to ensure that the output file is human readable.
*************************************************************************/
_global.writeXMLFile = function(inNode:XMLNode, depth:Number):String  
//Application exit handling
mdm.Application.enableExitHandler(appExit);
mdm.Application.onAppExit = function() {
	appExit();
};
function appExit():Void 
_global.comboSetSelected = function(combo, val, field) 
/****************************************************************/
mdm.Menu.Main.menuType = "function";
mdm.Menu.Main.insertHeader("File");
mdm.Menu.Main.insertHeader("Help");
mdm.Menu.Main.insertItem("File", "New Project");
mdm.Menu.Main.insertItem("File", "Open Project");
//mdm.Menu.Main.insertDivider("File");
//mdm.Menu.Main.insertItem("File", "Import Server XML");
//mdm.Menu.Main.insertItem("File", "Python Editor");
mdm.Menu.Main.insertDivider("File");
mdm.Menu.Main.insertItem("File", "Save Project");
mdm.Menu.Main.insertItem("File", "Save Project As..");
mdm.Menu.Main.insertDivider("File");
mdm.Menu.Main.insertItem("File", "Exit");
mdm.Menu.Main.insertItem("Help", "Help");
mdm.Menu.Main.insertItem("Help", "About");

mdm.Menu.Main.onMenuClick_New_Project = function() 
mdm.Menu.Main.onMenuClick_Open_Project = function() 
_global.Python_Editor = function(filename:String)
mdm.Menu.Main.onMenuClick_Save_Project = function() {
	saveFile("Project");
};
mdm.Menu.Main.onMenuClick_Save_Project_As__ = function() 
mdm.Menu.Main.onMenuClick_Help = function() 
mdm.Menu.Main.onMenuClick_About = function() 
mdm.Menu.Main.onMenuClick_Exit = function() 
/****************************************************************/
// set view function to display correct form
setView = function (view, dataObj) 
/****************************************************************/
tabs_tb.change = function(eventObj) 
tabs_tb.addEventListener("change", tabs_tb);
/****************************************************************/
leftTreeListener = new Object();
leftTreeListener.change = function(eventObj) 
/****************************************************************/
buttonListener = new Object();
buttonListener.last_btn = null;
buttonListener.click = function(eventObj) 
_global.updateFromLibrary = function(tempObject) 

home_btn.addEventListener("click", buttonListener);
project_btn.addEventListener("click", buttonListener);
control_btn.addEventListener("click", buttonListener);
preview_btn.addEventListener("click", buttonListener);

/****************************************************************/
buttonListener2 = new Object();
buttonListener2.click = function(eventObj) 
advanced_btn.addEventListener("click", buttonListener2);
/****************************************************************/
function setButtons(enabled:Boolean) 
home_btn.onRollOver = function() 
project_btn.onRollOver = function() 
control_btn.onRollOver = function() 
preview_btn.onRollOver = function()
library_btn.onRollOver = function() 
advanced_btn.onRollOver = function() 
home_btn.onRollOut = function() 
project_btn.onRollOut = function() 
control_btn.onRollOut = function() 
preview_btn.onRollOut = function() 
library_btn.onRollOut = function() 
advanced_btn.onRollOut = function() 
setButtons(false);
/****************************************************************/
setView("none");
/****************************************************************/
_global.right_tree.setStyle("openDuration", 50);
_global.left_tree.setStyle("openDuration", 50);
_global.right_tree.setStyle("indentation", 10);
_global.right_tree.setStyle("defaultLeafIcon", "Icon:error");
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
treeListener.change = function(evt:Object) 
treeListener.closeNode = function(node:XMLNode) 
treeListener.nodeClose = function(evt:Object) 
treeListener.nodeOpen = function(evt:Object)
XMLNode.prototype.getSiblings = function(cTree:mx.controls.Tree) 
// set out listeners for the menu
_global.right_tree.addEventListener('change', treeListener);
_global.right_tree.addEventListener('nodeClose', treeListener);
_global.right_tree.addEventListener('nodeOpen', treeListener);
_global.left_tree.addEventListener('nodeOpen', treeListener);
//_global.workflow.buildWorkflowTree();
/************************************************************************/
//create the tooltip clip
_root.tooltip_mc.swapDepths(15998);
// adds a text-description of the buttons function 
function DisplayTip(tip) 
// hide tip 
function CloseTip() 
/*************************************************************************/
_global.left_tree.addEventListener("change", leftTreeListener);
left_tree.addEventListener("change", leftTreeListener);
mdm.Forms.Preview.show();
mdm.Forms.Preview.callFunction("parseClient", '<client><setting name="applicationXML" value="'+mdm.Application.path+'client.xml" /><setting name="libLocation" value="lib/" /><setting name="fullScreen" value="false" /><setting name="hideMouseCursor" value="false" /></client>', "|");
mdm.Forms.Preview.visible = false;