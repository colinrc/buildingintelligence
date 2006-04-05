﻿class Objects.Server.Alarms extends Objects.BaseElement {
	private var container:String;
	private var alarms:Array;
	var treeNode:XMLNode;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var alarm in alarms){
			tempKeys.push(alarms[alarm].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		for (var alarm in alarms) {
			if ((alarms[alarm].attributes["KEY"] == undefined) || (alarms[alarm].attributes["KEY"] == "")) {
				flag = "error";
			}
			if ((alarms[alarm].attributes["DISPLAY_NAME"] == undefined) || (alarms[alarm].attributes["DISPLAY_NAME"] == "")) {
				flag = "error";
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.alarm";
	}
	public function toXML():XMLNode {
		var alarmsNode = new XMLNode(1, container);		
		for (var alarm in alarms) {
			var newAlarm = new XMLNode(1, "ALARM");
			if(alarms[alarm].key != ""){
				newAlarm.attributes["KEY"] = alarms[alarm].key;
			}
			if(alarms[alarm].display_name != ""){
				newAlarm.attributes["DISPLAY_NAME"] = alarms[alarm].display_name;
 		    }
			if(alarms[alarm].name != ""){
				newAlarm.attributes["NAME"] = alarms[alarm].name;
 		    }			
			alarmsNode.appendChild(newAlarm);
		}
		return alarmsNode;
	}
	public function getName():String {
		return "Alarms";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		treeNode = newNode;	
		return newNode;
	}
	public function getKey():String{
		return "Alarms";
	}
	public function getData():Object {
		return {alarms:alarms, dataObject:this};
	}
	public function setData(newData:Object):Void{
		alarms = newData.alarms;
	}
	public function setXML(newData:XMLNode):Void {
		alarms = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newAlarm = new Object();
			newAlarm.key = "";
			newAlarm.display_name = "";
			newAlarm.name = "";
			if(newData.childNodes[child].attributes["KEY"]!=undefined){
				newAlarm.key = newData.childNodes[child].attributes["KEY"];
			}
			if(newData.childNodes[child].attributes["DISPLAY_NAME"]!=undefined){
				newAlarm.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if(newData.childNodes[child].attributes["NAME"]!=undefined){
				newAlarm.name = newData.childNodes[child].attributes["NAME"];
			}			
			alarms.push(newAlarm);
		}
	}
}
