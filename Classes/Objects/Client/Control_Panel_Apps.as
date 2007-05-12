﻿class Objects.Client.Control_Panel_Apps extends Objects.BaseElement{
	private var apps:Array;
	private var treeNode:XMLNode;
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for(var child in apps.childNodes){
			if((apps.childNodes[child].attributes["label"] == undefined)||(apps.childNodes[child].attributes["label"] == "")){
				flag = "warning";
				appendValidationMsg("Label is empty");
			}
			if((apps.childNodes[child].attributes["program"] ==undefined)||(apps.childNodes[child].attributes["program"] =="")){
				flag = "warning";
				appendValidationMsg("Program is empty");
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.controlpanelapps";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"controlPanelApps");
		for(var app in apps) {
			newNode.appendChild(apps[app]);
		}
		return newNode;		
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		treeNode = newNode;
		newNode.object = this;
		return newNode;
	}
	public function getKey():String{
		return "ClientControl_Panel_Apps";
	}	
	public function getName():String{
		return "Control Panel Apps";
	}
	public function getData():Object{
		return {apps:apps, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void{
		apps = new Array();
		if(newData.nodeName == "controlPanelApps"){
			for(var app in newData.childNodes){
				apps.push(newData.childNodes[app]);
			}
		}
		else{
			trace("Error, received "+newData.nodeName+", was expecting controlPanelApps");			
		}
	}
	public function setData(newData:Object):Void{
		apps = newData.apps;
	}
}
