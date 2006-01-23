﻿class Objects.Server.Oregon extends Objects.BaseElement {
	private var type:String = "OREGON";
	private var display_name:String;
	private var name:String;
	private var active:String;
	private var sensors:Objects.Server.CBusSensors;
	private var catalogues:Objects.Server.Catalogues;
	private var connection:XMLNode;
	private var parameters:XMLNode;
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(sensors.getKeys());
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		if((name == undefined)||(name=="")){
			flag = false;
		}
		if((active!="Y")&&(active!="N")){
			flag = false;
		}
		if(!sensors.isValid()){
			flag = false;
		}
		if (!catalogues.isValid()) {
			flag = false;
		}
		//need to isValid connection and parameters
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.head";
	}
	public function toXML():XMLNode {
		var newDevice = new XMLNode(1,"DEVICE");
		newDevice.attributes["NAME"] = name;
		newDevice.attributes["DISPLAY_NAME"] = display_name;
		newDevice.attributes["ACTIVE"] = active;
		newDevice.appendChild(connection);
		newDevice.appendChild(parameters);
		var tempCatalogues = catalogues.toXML();
		for(var child in tempCatalogues.childNodes){
			newDevice.appendChild(tempCatalogues.childNodes[child]);
		}
		var newOregon = new XMLNode(1,type);
		var tempSensors = sensors.toXML();
		for(var child in tempSensors.childNodes){
		newOregon.appendChild(tempSensors.childNodes[child]);
		}
		newDevice.appendChild(newOregon);
		return newDevice;
	}
	public function getName():String{
		return type+" : "+display_name;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(catalogues.toTree());
		newNode.appendChild(sensors.toTree());
		newNode.object = this;
		return newNode;
	}
	public function getData():Object {
		return new Object({name:name, display_name:display_name, active:active, connection:connection, parameters:parameters});
	}
	public function setData(newData:Object) {
		name = newData.name;
		display_name = newData.display_name;
		active = newData.active;
		connection = newData.connection;
		parameters = newData.parameters;
	}
	public function setXML(newData:XMLNode):Void{
		catalogues = new Objects.Server.Catalogues();
		var tempCatalogues = new XMLNode(1,"Catalogues");
		sensors = new Objects.Server.CBusSensors();
		if(newData.nodeName == "DEVICE"){
			name = newData.attributes["NAME"];
			display_name = newData.attributes["DISPLAY_NAME"];
			active = newData.attributes["ACTIVE"];
			for(var child in newData.childNodes){
				switch(newData.childNodes[child].nodeName){
					case "OREGON":
					sensors.setXML(newData.childNodes[child]);
					break;
					case "CONNECTION":
					connection = newData.childNodes[child];
					break;
					case "PARAMETERS":
					parameters = newData.childNodes[child];
					break;
					case "CATALOGUE":
					tempCatalogues.appendChild(newData.childNodes[child]);
					break;
				}
			}
			catalogues.setXML(tempCatalogues);
		}
		else{
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}