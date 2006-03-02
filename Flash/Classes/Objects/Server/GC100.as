class Objects.Server.GC100 extends Objects.Server.Device {
	private var modules:Objects.Server.GC100Modules;
	private var irs:Objects.Server.GC100IRs;
	private var toggle_inputs:Objects.Server.GC100Toggles;
	private var toggle_outputs:Objects.Server.GC100Toggles;	
	public function getKeys():Array{
		var tempKeys = new Array();
		tempKeys = tempKeys.concat(irs.getKeys());
		tempKeys = tempKeys.concat(toggle_inputs.getKeys());
		tempKeys = tempKeys.concat(toggle_outputs.getKeys());		
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		if ((device_type == undefined) || (device_type == "")) {
			flag = false;
		}
		if ((active != "Y") && (active != "N")) {
			flag = false;
		}
		//need to isValid connection and parameters 
		return flag;
	}
	public function toXML():XMLNode {
		var newDevice = new XMLNode(1, "DEVICE");
		if(device_type != ""){
			newDevice.attributes["DEVICE_TYPE"] = device_type;
		}
		if(description != ""){
			newDevice.attributes["DESCRIPTION"] = description;
		}
		if(active != "") {
			newDevice.attributes["ACTIVE"] = active;
		}
		newDevice.appendChild(connection);
		//newDevice.appendChild(parameters);
		var tempModules =  modules.getData();
		var tempInputs = toggle_inputs.getData();
		var tempOutputs = toggle_outputs.getData();
		var tempIRs = irs.getData();
		for (var child in tempModules.modules) {
			if(tempModules.modules[child].type == "IR"){
				var newModule = new XMLNode(1,"GC100_IR");				
			} else{
				var newModule = new XMLNode(1,"GC100_Relay");				
			}
			var newParameters = new XMLNode(1,"PARAMETERS");
			var newNode = new XMLNode(1,"ITEM");
			newNode.attributes["NAME"] = "MODULE";
			newNode.attributes["VALUE"] = tempModules.modules[child].number;
			newParameters.appendChild(newNode);
			newNode = new XMLNode(1,"ITEM");
			newNode.attributes["NAME"] = "MODULE_TYPE";
			newNode.attributes["VALUE"] = tempModules.modules[child].type;
			newParameters.appendChild(newNode);
			newModule.appendChild(newParameters);			
			if(tempModules.modules[child].type == "IR"){
				for(var toggle_in in tempInputs.toggles){
					if(tempInputs.toggles[toggle_in].module == tempModules.modules[child].number){
						var newInput = new XMLNode(1,"TOGGLE_INPUT");
						newInput.attributes["NAME"] = tempInputs.toggles[toggle_in].name;
						newInput.attributes["DISPLAY_NAME"] = tempInputs.toggles[toggle_in].display_name;
						newInput.attributes["ACTIVE"] = tempInputs.toggles[toggle_in].active;
						newInput.attributes["KEY"] = tempInputs.toggles[toggle_in].key;
						newModule.appendChild(newInput);
					}
				}
				for(var ir in tempIRs.irs){
					if(tempIRs.irs[ir].module == tempModules.modules[child].number){
						var newIR = new XMLNode(1,"IR");
						newIR.attributes["KEY"] = tempIRs.irs[ir].key;
						newIR.attributes["NAME"] = tempIRs.irs[ir].name;
						newIR.attributes["AV_NAME"] = tempIRs.irs[ir].avname;
						newModule.appendChild(newIR);
					}
				}
			}
			else{
				for(var toggle_out in tempOutputs.toggles){
					if(tempOutputs.toggles[toggle_out].module == tempModules.modules[child].number){
						var newOutput = new XMLNode(1,"TOGGLE_OUTPUT");
						newOutput.attributes["NAME"] = tempOutputs.toggles[toggle_out].name;
						newOutput.attributes["DISPLAY_NAME"] = tempOutputs.toggles[toggle_out].display_name;
						newOutput.attributes["ACTIVE"] = tempOutputs.toggles[toggle_out].active;
						newOutput.attributes["KEY"] = tempOutputs.toggles[toggle_out].key;
						newModule.appendChild(newOutput);
					}
				}
			}
			newDevice.appendChild(newModule);
		}
		return newDevice;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1, this.getName());
		newNode.appendChild(modules.toTree());
		newNode.appendChild(irs.toTree());
		newNode.appendChild(toggle_inputs.toTree());
		newNode.appendChild(toggle_outputs.toTree());		
		newNode.object = this;
		_global.workflow.addNode("GC100",newNode);
		return newNode;
	}
	public function setXML(newData:XMLNode):Void {
		device_type = "";
		description ="";
		active = "Y";		
		catalogues = new Objects.Server.Catalogues();
		modules = new Objects.Server.GC100Modules();
		irs = new Objects.Server.GC100IRs();
		toggle_inputs = new Objects.Server.GC100Toggles("TOGGLE_INPUT");
		toggle_outputs = new Objects.Server.GC100Toggles("TOGGLE_OUTPUT");
		var tempModules = new Array();
		var tempIRs = new Array();
		var tempToggle_Inputs = new Array();
		var tempToggle_Outputs = new Array();
		if (newData.nodeName == "DEVICE") {
			if(newData.attributes["NAME"]!=undefined){
				device_type = newData.attributes["NAME"];
			}
			if(newData.attributes["DEVICE_TYPE"]!=undefined){
				device_type = newData.attributes["DEVICE_TYPE"];
			}			
			if(newData.attributes["DISPLAY_NAME"]!=undefined){			
				description = newData.attributes["DISPLAY_NAME"];
			}
			if(newData.attributes["DESCRIPTION"]!=undefined){			
				description = newData.attributes["DESCRIPTION"];
			}			
			if(newData.attributes["ACTIVE"]!=undefined){			
				active = newData.attributes["ACTIVE"];
			}
			for (var child in newData.childNodes) {
				switch (newData.childNodes[child].nodeName) {
				case "CONNECTION" :
					connection = newData.childNodes[child];
					break;
				/*case "PARAMETERS" :
					parameters = newData.childNodes[child];
					break;*/
				case "GC100_IR":
				case "GC100_Relay":
					var tempNode = newData.childNodes[child];
					var newModule = new Object();
					newModule.name = tempNode.attributes["NAME"];
					for(var index in tempNode.childNodes){
						if(tempNode.childNodes[index].nodeName == "PARAMETERS"){
							for(var index2 in tempNode.childNodes[index].childNodes){
								if(tempNode.childNodes[index].childNodes[index2].attributes["NAME"] =="MODULE"){
									newModule.number = tempNode.childNodes[index].childNodes[index2].attributes["VALUE"];									
								}
								if(tempNode.childNodes[index].childNodes[index2].attributes["NAME"] =="MODULE_TYPE"){
									newModule.type = tempNode.childNodes[index].childNodes[index2].attributes["VALUE"];
								}
							}
						}
					}
					for(var index in tempNode.childNodes){
						switch(tempNode.childNodes[index].nodeName){
							case "IR":
								var newIR = new Object();
								newIR.key = "";
								newIR.name = "";
								newIR.avname = "";
								newIR.module = newModule.number;
								if(tempNode.childNodes[index].attributes["KEY"] != undefined){
									newIR.key = tempNode.childNodes[index].attributes["KEY"];
								}
								if(tempNode.childNodes[index].attributes["NAME"] != undefined){
									newIR.name = tempNode.childNodes[index].attributes["NAME"];
								}
								if(tempNode.childNodes[index].attributes["AV_NAME"] != undefined){
									newIR.avname = tempNode.childNodes[index].attributes["AV_NAME"];
								}
								tempIRs.push(newIR);
								break;		
							case "TOGGLE_OUTPUT":
								var newToggle = new Object();
								newToggle.active = "Y";
								newToggle.name = "";
								newToggle.display_name = "";
								newToggle.key = "";
								newToggle.module = newModule.number;
								if(tempNode.childNodes[index].attributes["ACTIVE"] != undefined){
									newToggle.active = tempNode.childNodes[index].attributes["ACTIVE"];
								}
								if(tempNode.childNodes[index].attributes["NAME"] != undefined){
									newToggle.name = tempNode.childNodes[index].attributes["NAME"];
								}
								if(tempNode.childNodes[index].attributes["DISPLAY_NAME"] != undefined){
									newToggle.display_name = tempNode.childNodes[index].attributes["DISPLAY_NAME"];
								}
								if(tempNode.childNodes[index].attributes["KEY"] != undefined){
									newToggle.key = tempNode.childNodes[index].attributes["KEY"];
								}
								tempToggle_Outputs.push(newToggle);
								break;							
							case "TOGGLE_INPUT":
								var newToggle = new Object();
								newToggle.active = "Y";
								newToggle.name = "";
								newToggle.display_name = "";
								newToggle.key = "";
								newToggle.module = newModule.number;
								if(tempNode.childNodes[index].attributes["ACTIVE"] != undefined){
									newToggle.active = tempNode.childNodes[index].attributes["ACTIVE"];
								}
								if(tempNode.childNodes[index].attributes["NAME"] != undefined){
									newToggle.name = tempNode.childNodes[index].attributes["NAME"];
								}
								if(tempNode.childNodes[index].attributes["DISPLAY_NAME"] != undefined){
									newToggle.display_name = tempNode.childNodes[index].attributes["DISPLAY_NAME"];
								}
								if(tempNode.childNodes[index].attributes["KEY"] != undefined){
									newToggle.key = tempNode.childNodes[index].attributes["KEY"];
								}
								tempToggle_Inputs.push(newToggle);
								break;
						}
					}
					tempModules.push(newModule);
					break;
				}
			}
			modules.setData({modules:tempModules});
			irs.setData({irs:tempIRs});
			irs.setModules(modules);
			toggle_inputs.setData({toggles:tempToggle_Inputs});
			toggle_inputs.setModules(modules);
			toggle_outputs.setData({toggles:tempToggle_Outputs});
			toggle_outputs.setModules(modules);			
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting DEVICE");
		}
	}
}
