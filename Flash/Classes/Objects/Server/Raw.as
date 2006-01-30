﻿class Objects.Server.Raw extends Objects.BaseElement {
	private var container:String;
	private var command:String;
	private var extra:String;
	private var code:String;
	private var variables:Array;
	public function isValid():Boolean {
		var flag = true;
		if ((command == undefined) || (command == "")) {
			flag = false;
		}
		if ((code == undefined) || (code == "")) {
			flag = false;
		}
		if ((extra == undefined) || (extra == "")) {
			flag = false;
		}
		for (var variable in variables) {
			if ((variables[variable].attributes["VALUE"] == undefined) || (variables[variable].attributes["VALUE"] == "")) {
				flag = false;
			}
			if ((variables[variable].attributes["NAME"] == undefined) || (variables[variable].attributes["NAME"] == "")) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.raw";
	}
	public function toXML():XMLNode {
		var variablesNode = new XMLNode(1, container);
		if (command != "") {
			variablesNode.attributes["COMMAND"] = command;
		}
		if (extra != "") {
			variablesNode.attributes["EXTRA"] = extra;
		}
		if (code != "") {
			variablesNode.attributes["CODE"] = code;
		}
		for (var variable in variables) {
			variablesNode.appendChild(variables[variable]);
		}
		return variablesNode;
	}
	public function getName():String {
		return command;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		return newNode;
	}
	public function setData(newData:Object) {
		variables = newData.variables;
		command = newData.command;
		code = newData.code;
		extra = newData.extra;
	}
	public function getData():Object {
		return new Object({variables:variables, command:command, code:code, extra:extra});
	}
	public function setXML(newData:XMLNode):Void {
		command = "";
		code = "";
		extra = "";
		variables = new Array();
		container = newData.nodeName;
		if (newData.attributes["COMMAND"] != undefined) {
			command = newData.attributes["COMMAND"];
		}
		if (newData.attributes["CODE"] != undefined) {
			code = newData.attributes["CODE"];
		}
		if (newData.attributes["EXTRA"] != undefined) {
			extra = newData.attributes["EXTRA"];
		}
		for (var child in newData.childNodes) {
			variables.push(newData.childNodes[child]);
		}
	}
}
