﻿class Objects.Server.Controls extends Objects.BaseElement {
	private var variables:XMLNode;
	var treeNode:XMLNode;			
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var variable in variables.childNodes){
			tempKeys.push(variables.childNodes[variable].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var child in variables.childNodes) {
			if ((variables.childNodes[child].attributes["ACTIVE"] != "Y") && (variables.childNodes[child].attributes["ACTIVE"] != "N")) {
				flag = "error";
				appendValidationMsg("Active flag is invalid");
			}
			if (variables.childNodes[child].attributes["ACTIVE"] =="Y"){
				if ((variables.childNodes[child].attributes["NAME"] == undefined) || (variables.childNodes[child].attributes["NAME"] == "")) {
					flag = "empty";
					appendValidationMsg("Description is empty");
				}
				if ((variables.childNodes[child].attributes["DISPLAY_NAME"] == undefined) || (variables.childNodes[child].attributes["DISPLAY_NAME"] == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				}
				if ((variables.childNodes[child].attributes["INIT_EXTRA"] == undefined) || (variables.childNodes[child].attributes["INIT_EXTRA"] == "")) {
					flag = "error";
					appendValidationMsg("Init Extra is empty");
				}
				if ((variables.childNodes[child].attributes["INIT_COMMAND"] == undefined) || (variables.childNodes[child].attributes["INIT_COMMAND"] == "")) {
					flag = "error";
					appendValidationMsg("Init Command is empty");
				}
			}
			else{
				flag = "empty";
				appendValidationMsg("Variable " + variables.childNodes[child].attributes["DISPLAY_NAME"] + " is not Active");
			}
			
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.variables";
	}
	public function toXML():XMLNode {
		return variables;
	}
	public function getName():String {
		return "Variables";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Controls");
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "Controls";
	}
	public function getData():Object {
		return {variables:variables, dataObject:this};
	}
	public function setData(newData:Object):Void {
		variables = newData.variables;
	}
	public function setXML(newData:XMLNode):Void {
		variables = new XMLNode();
		if (newData.nodeName == "VARIABLES") {
			variables = newData;
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting VARIABLES");
		}
	}
}
