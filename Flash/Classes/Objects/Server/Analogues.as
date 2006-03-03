﻿class Objects.Server.Analogues extends Objects.BaseElement {
	private var container:String;
	private var analogues:Array;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var analogue in analogues){
			tempKeys.push(analogues[analogue].display_name);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var analogue in analogues) {
			if ((analogues[analogue].attributes["ACTIVE"] != "Y") && (analogues[analogue].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((analogues[analogue].attributes["KEY"] == undefined) || (analogues[analogue].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((analogues[analogue].attributes["NAME"] == undefined) || (analogues[analogue].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((analogues[analogue].attributes["DISPLAY_NAME"] == undefined) || (analogues[analogue].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.analogue";
	}
	public function toXML():XMLNode {
		var analoguesNode = new XMLNode(1, container);
		for (var analogue in analogues) {
			var newAnalogue = new XMLNode(1, "ANALOG");
			if (analogues[analogue].key != "") {
				newAnalogue.attributes["KEY"] = analogues[analogue].key;
			}
			if (analogues[analogue].name != "") {
				newAnalogue.attributes["NAME"] = analogues[analogue].name;
			}
			if (analogues[analogue].active != "") {
				newAnalogue.attributes["ACTIVE"] = analogues[analogue].active;
			}
			if (analogues[analogue].display_name != "") {
				newAnalogue.attributes["DISPLAY_NAME"] = analogues[analogue].display_name;
			}
			analoguesNode.appendChild(newAnalogue);
		}
		return analoguesNode;
	}
	public function getName():String {
		return "Analog Inputs";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		_global.workflow.addNode("Analogues",newNode);
		return newNode;
	}
	public function getData():Object {
		return new Object({analogues:analogues});
	}
	public function setData(newData:Object){
		analogues = newData.analogues;
	}
	public function setXML(newData:XMLNode):Void {
		analogues = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newAnalogue = new Object();
			newAnalogue.key = "";
			newAnalogue.name = "";
			newAnalogue.display_name = "";
			newAnalogue.active = "Y";			
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newAnalogue.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newAnalogue.name = newData.childNodes[child].attributes["NAME"];
			}	
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newAnalogue.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newAnalogue.active = newData.childNodes[child].attributes["ACTIVE"];
			}			
			analogues.push(newAnalogue);
		}
	}
}
