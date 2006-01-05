import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Head {
	private var node:XMLNode;
	private var connections:XMLNode;
	private var parameters:XMLNode;
	private var catalogues:Array;
	private var device:Object;
	private var connection_mc:MovieClip;
	private var device1_mc:MovieClip;
	private var device2_mc:MovieClip;
	private var device3_mc:MovieClip;
	private var form1:mx.controls.Loader;
	private var form2:mx.controls.Loader;
	private var form3:mx.controls.Loader;
	private var form4:mx.controls.Loader;
	private var name_ti:mx.controls.TextInput;
	private var dName_ti:mx.controls.TextInput;
	private var save_btn:mx.controls.Button;
	private var active_chk:mx.controls.CheckBox;
	public function Head() {
	}
	public function init():Void {
		if (node.attributes["ACTIVE"] == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		name_ti.text = node.attributes["NAME"];
		dName_ti.text = node.attributes["DISPLAY_NAME"];
		save_btn.addEventListener("click", Delegate.create(this, save));
		processDevice();
	}
	private function processDevice():Void {
		var dataObj = {node:connections};
		connection_mc = form1.attachMovie("forms.project.device.connection", "connection_mc", 0, dataObj);
		connection_mc.dataObj = dataObj;
		switch (device.type) {
		case "IR_LEARNER" :
			//What needs to be done with ir_learner?
			var dataObj = {node:parameters};
			device1_mc = form2.attachMovie("forms.project.device.parameters", "device1_mc", 0, dataObj);
			device1_mc.dataObj = dataObj;
			break;
		case "HAL" :
		case "TUTONDO" :
		case "KRAMER" :
			var dataObj = {node:parameters};
			device1_mc = form2.attachMovie("forms.project.device.parameters", "device1_mc", 0, dataObj);
			device1_mc.dataObj = dataObj;
			var dataObj = {catalogues:catalogues};
			device2_mc = form3.attachMovie("forms.project.device.catalogues", "device2_mc", 0, dataObj);
			device2_mc.dataObj = dataObj;
			var dataObj = {node:device.audio};
			device3_mc = form4.attachMovie("forms.project.device.audiovideo", "device3_mc", 0, dataObj);
			device3_mc.dataObj = dataObj;
			break;
		case "PELCO" :
			var dataObj = {node:parameters};
			device1_mc = form2.attachMovie("forms.project.device.parameters", "device1_mc", 0, dataObj);
			device1_mc.dataObj = dataObj;
			var dataObj = {node:device.cameras};
			device2_mc = form3.attachMovie("forms.project.device.camera", "device2_mc", 0, dataObj);
			device2_mc.dataObj = dataObj;
			break;
		case "OREGON" :
			var dataObj = {node:parameters};
			device1_mc = form2.attachMovie("forms.project.device.parameters", "device1_mc", 0, dataObj);
			device1_mc.dataObj = dataObj;
			var dataObj = {sensors:device.sensors};
			device2_mc = form3.attachMovie("forms.project.device.cbussensors", "device2_mc", 0, dataObj);
			device2_mc.dataObj = dataObj;
			break;
		case "CBUS" :
			var dataObj = {lights:device.lights};
			device1_mc = form2.attachMovie("forms.project.device.cbuslights", "device1_mc", 0, dataObj);
			device1_mc.dataObj = dataObj;
			var dataObj = {sensors:device.sensors};
			device2_mc = form3.attachMovie("forms.project.device.cbussensors", "device2_mc", 0, dataObj);
			device2_mc.dataObj = dataObj;
			break;
		case "DYNALITE" :
			var dataObj = {irs:device.irs};
			device1_mc = form2.attachMovie("forms.project.device.ir", "device1_mc", 0, dataObj);
			device1_mc.dataObj = dataObj;
			var dataObj = {closures:device.closures};
			device2_mc = form3.attachMovie("forms.project.device.contact", "device2_mc", 0, dataObj);
			device2_mc.dataObj = dataObj;
			var dataObj = {lights:device.lights};
			device3_mc = form4.attachMovie("forms.project.device.dynalitelights", "device3_mc", 0, dataObj);
			device3_mc.dataObj = dataObj;
			break;
		case "GC100":
			var dataObj = {modules:device.modules};
			device1_mc = form2.attachMovie("forms.project.device.gc100_modules","device1_mc",0,dataObj);
			break;

		default :
			var dataObj = {node:parameters};
			device1_mc = form2.attachMovie("forms.project.device.parameters", "device1_mc", 0, dataObj);
			device1_mc.dataObj = dataObj;
			var dataObj = {catalogues:catalogues};
			device2_mc = form3.attachMovie("forms.project.device.catalogues", "device2_mc", 0, dataObj);
			device2_mc.dataObj = dataObj;
			break;
		}
	}
	private function save():Void {
		if (active_chk.selected) {
			_global.left_tree.selectedNode.attributes["ACTIVE"] = "Y";
		} else {
			_global.left_tree.selectedNode.attributes["ACTIVE"] = "N";
		}
		switch (device.type) {
		case "TUTONDO" :
		case "HAL" :
		case "KRAMER" :
			_global.left_tree.selectedNode.parameters = device1_mc.getData();
			device.audio = device3_mc.getData();
			ProcessCatalogs();
			break;
		case "PELCO" :
			_global.left_tree.selectedNode.parameters = device1_mc.getData();
			device.cameras = device2_mc.getData();
			break;
		case "CBUS" :
			device.lights = device1_mc.getData();
			device.sensors = device2_mc.getData();
			break;
		case "DYNALITE" :
			device.irs = device1_mc.getData();
			device.closures = device2_mc.getData();
			device.lights = device3_mc.getData();
			break;
		case "OREGON" :
			device.sensors = device2_mc.getData();
			_global.left_tree.selectedNode.parameters = device1_mc.getData();
			break;
		case "GC100":
			ProcessModules();
			break;
		}
		_global.left_tree.selectedNode.connections = connection_mc.getData();
		_global.left_tree.selectedNode.device = device;
	}
	private function ProcessModules():Void{
		var tempModules = device2_mc.getData();
		//process modules changes
		//for(var module in tempModules){
		//}
	}
	private function ProcessCatalogs():Void {
		var tempCatalogues = device2_mc.getData();
		//process catalogue changes
		for (var catalogue in tempCatalogues) {
			//if a catalogue has been added
			if (tempCatalogues[catalogue].oldName == undefined) {
				var newNode = new XMLNode(1, "CATALOGUE");
				newNode.attributes["NAME"] = tempCatalogues[catalogue].name;
				_global.left_tree.selectedNode.appendChild(newNode);
				//if a catalogue has been renamed
			} else if ((tempCatalogues[catalogue].name != "DELETED") && (tempCatalogues[catalogue].oldName != tempCatalogues[catalogue].name)) {
				for (var child in _global.left_tree.selectedNode.childNodes) {
					if ((_global.left_tree.selectedNode.childNodes[child].nodeName == "CATALOGUE") && (_global.left_tree.selectedNode.childNodes[child].attributes["NAME"] == tempCatalogues[catalogue].oldName)) {
						_global.left_tree.selectedNode.childNodes[child].attributes["NAME"] = tempCatalogues[catalogue].name;
						break;
					}
				}
				//if a catalogue has been deleted  				
			} else if ((tempCatalogues[catalogue].name == "DELETED") && (tempCatalogues[catalogue].oldName != undefined)) {
				for (var child in _global.left_tree.selectedNode.childNodes) {
					if ((_global.left_tree.selectedNode.childNodes[child].nodeName == "CATALOGUE") && (_global.left_tree.selectedNode.childNodes[child].attributes["NAME"] == tempCatalogues[catalogue].oldName)) {
						_global.left_tree.selectedNode.childNodes[child].removeNode();
						break;
					}
				}
			}
		}
		catalogues = new Array();
		for (var catalogue in tempCatalogues) {
			if (tempCatalogues[catalogue].name != "DELETED") {
				catalogues.push(tempCatalogues[catalogue].name);
			}
		}
		_global.left_tree.selectedNode.catalogues = catalogues;
	}
}
