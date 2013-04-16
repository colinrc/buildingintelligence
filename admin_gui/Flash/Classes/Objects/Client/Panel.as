﻿class Objects.Client.Panel extends Objects.BaseElement {
	private var controls:Array;
	private var name:String;
	private var x_pos:String;
	private var y_pos:String;
	private var height:String;
	private var width:String;
	private var treeNode:XMLNode;
	private var attributes:Array;
	private var attributeGroups = ["Window"];
	public function deleteSelf() {
		treeNode.removeNode();
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (controls.length == 0) {
			flag = "empty";
			appendValidationMsg("No Controls are defined");
		}
		if (name == undefined || name == "") {
			flag = "error";
			appendValidationMsg("Name is empty");
		}
		if (x_pos == undefined || x_pos == "") {
			flag = "error";
			appendValidationMsg("X pos is empty");
		}
		if (height == undefined || height == "") {
			flag = "error";
			appendValidationMsg("Heigth is empty");
		}
		if (width == undefined || width == "") {
			flag = "error";
			appendValidationMsg("Width is empty");
		}
		for (var control in controls) {
			if ((controls[control].attributes["name"] == "") || (controls[control].attributes["name"] == undefined)) {
				flag = "error";
				appendValidationMsg("Control Name is empty");
			}
			if ((controls[control].attributes["key"] == "") || (controls[control].attributes["key"] == undefined)) {
				flag = "error";
				appendValidationMsg("No Keys are used");
			} else {
				if (_global.isKeyValid(controls[control].attributes["key"]) == false) {
					flag = "error";
					appendValidationMsg("Key has changed and is invalid");
				}
			}
			if ((controls[control].attributes["type"] == "") || (controls[control].attributes["type"] == undefined)) {
				flag = "error";
				appendValidationMsg("Control Type is invalid");
			}
			if ((controls[control].attributes["icons"] == "") || (controls[control].attributes["icons"] == undefined)) {
				flag = "error";
				appendValidationMsg("Icons are invalid");
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.panel";
	}
	public function getAttributes():Array {
		return attributes;
	}
	public function setAttributes(newAttributes:Array) {
		attributes = newAttributes;
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "panel");
		for (var attribute in attributes) {
			newNode.attributes[attributes[attribute].name] = attributes[attribute].value;
		}
		if (y_pos != "") {
			newNode.attributes["y"] = y_pos;
		}
		if (x_pos != "") {
			newNode.attributes["x"] = x_pos;
		}
		if (name != "") {
			newNode.attributes["name"] = name;
		}
		if (width != "") {
			newNode.attributes["width"] = width;
		}
		if (height != "") {
			newNode.attributes["height"] = height;
		}
		for (var control in controls) {
			newNode.appendChild(controls[control]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Panel");
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "Panel";
	}
	public function getName():String {
		return "Panel : " + name;
	}
	public function getData():Object {
		return {controls:controls, name:name, x_pos:x_pos, y_pos:y_pos, width:width, height:height, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		attributes = new Array();
		name = "";
		x_pos = "";
		y_pos = "";
		width = "";
		height = "";
		if (newData.nodeName == "panel") {
			for (var attribute in newData.attributes) {
				switch (attribute) {
				case "name" :
					name = newData.attributes["name"];
					break;
				case "x" :
					x_pos = newData.attributes["x"];
					break;
				case "y" :
					y_pos = newData.attributes["y"];
					break;
				case "width" :
					width = newData.attributes["width"];
					break;
				case "height" :
					height = newData.attributes["height"];
					break;
				default :
					attributes.push({name:attribute, value:newData.attributes[attribute]});
					break;
				}
			}
			controls = new Array();
			for (var child in newData.childNodes) {
				controls.push(newData.childNodes[child]);
			}
		} else {
			trace("Error, found " + newData.nodeName + ", was expecting panel");
		}
	}
	public function setData(newData:Object):Void {
		controls = newData.controls;
		name = newData.name;
		x_pos = newData.x_pos;
		y_pos = newData.y_pos;
		width = newData.width;
		height = newData.height;
	}
	public function getUsedKeys():Array {
		usedKeys = new Array();
		for (var control in controls) {
			if ((controls[control].attributes["key"] != "") && (controls[control].attributes["key"] != undefined)) {
				addUsedKey(controls[control].attributes["key"]);
			}
		}
		return usedKeys;
	}
	public function getIcons():Array {
		usedIcons = new Array();
		for (var control in controls) {
			if ((controls[control].attributes["icons"] != "") && (controls[control].attributes["icons"] != undefined)) {
				addIcon(controls[control].attributes["icons"]);
			}
		}
		return usedIcons;
	}
}
