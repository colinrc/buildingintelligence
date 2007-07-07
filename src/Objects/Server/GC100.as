package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.core.Application;
	import Forms.Server.GC100_frm;
	import mx.utils.ObjectProxy;
	
	[Bindable("GC100")]
	[RemoteClass(alias="elifeAdmin.server.gc100")] 
	public class GC100 extends Device {
		private var modules:GC100Modules;
		private var irs:GC100IRs;
		private var toggle_inputs:GC100Toggles;
		private var toggle_outputs:GC100Toggles;	
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(modules);
			output.writeObject(irs);
			output.writeObject(toggle_inputs);
			output.writeObject(toggle_outputs);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			modules = input.readObject()as GC100Modules;
			irs = input.readObject()as GC100IRs;
			toggle_inputs = input.readObject()as GC100Toggles;
			toggle_outputs = input.readObject()as GC100Toggles;	
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(irs.getKeys());
			tempKeys = tempKeys.concat(toggle_inputs.getKeys());
			tempKeys = tempKeys.concat(toggle_outputs.getKeys());		
			return tempKeys;
		}
		
		public override function toXML():XML {
			var newDevice = new XML("<DEVICE />");
			if(device_type != ""){
				newDevice.@DEVICE_TYPE = device_type;
			}
			if(description != ""){
				newDevice.@DESCRIPTION = description;
			}
			if(active != "") {
				newDevice.@ACTIVE = active;
			}
			newDevice.appendChild(connection.toXML());
			//newDevice.appendChild(parameters);
			var tempModules =  modules.Data;
			var tempInputs = toggle_inputs.Data;
			var tempOutputs = toggle_outputs.Data;
			var tempIRs = irs.Data;
			for (var child in tempModules.modules) {
				if(tempModules.modules[child].type == "IR"){
					var newModule = new XML("<GC100_IR />");				
				} else{
					var newModule = new XML("<GC100_Relay />");				
				}
				newModule.@NAME = tempModules.modules[child].name;
				var newParameters = new XML("<PARAMETERS />");
				var newNode = new XML("<ITEM />");
				newNode.@NAME = "MODULE";
				newNode.@VALUE = tempModules.modules[child].number;
				newParameters.appendChild(newNode);
				newNode = new XML("<ITEM />");
				newNode.@NAME = "MODULE_TYPE";
				newNode.@VALUE = tempModules.modules[child].type;
				newParameters.appendChild(newNode);
				newModule.appendChild(newParameters);			
				if(tempModules.modules[child].type == "IR"){
					for(var toggle_in in tempInputs.toggles){
						if(tempInputs.toggles[toggle_in].module == tempModules.modules[child].number){
							var newInput:XML = new XML("<TOGGLE_INPUT />");
							newInput.@NAME = tempInputs.toggles[toggle_in].name;
							newInput.@DISPLAY_NAME = tempInputs.toggles[toggle_in].display_name;
							newInput.@ACTIVE = tempInputs.toggles[toggle_in].active;
							newInput.@KEY = tempInputs.toggles[toggle_in].key;
							newModule.appendChild(newInput);
						}
					}
					for(var ir in tempIRs.irs){
						if(tempIRs.irs[ir].module == tempModules.modules[child].number){
							var newIR = new XML("<IR />");
							newIR.@KEY = tempIRs.irs[ir].key;
							newIR.@NAME = tempIRs.irs[ir].name;
							newIR.@AV_NAME = tempIRs.irs[ir].avname;
							newModule.appendChild(newIR);
						}
					}
				}
				else{
					for(var toggle_out in tempOutputs.toggles){
						if(tempOutputs.toggles[toggle_out].module == tempModules.modules[child].number){
							var newOutput = new XML("<TOGGLE_OUTPUT />");
							newOutput.@NAME = tempOutputs.toggles[toggle_out].name;
							newOutput.@DISPLAY_NAME = tempOutputs.toggles[toggle_out].display_name;
							newOutput.@ACTIVE = tempOutputs.toggles[toggle_out].active;
							newOutput.@KEY = tempOutputs.toggles[toggle_out].key;
							newModule.appendChild(newOutput);
						}
					}
				}
				newDevice.appendChild(newModule);
			}
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(modules.toTree());
			newNode.appendChild(irs.toTree());
			newNode.appendChild(toggle_inputs.toTree());
			newNode.appendChild(toggle_outputs.toTree());		
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "GC100";
		}	
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.GC100_frm;
			return className;		
		}
		
		public override function newObject():void {
			super.newObject();
			device_type = "GC100";
			description ="";
			active = "Y";		
			
			modules = new Objects.Server.GC100Modules();
			irs = new Objects.Server.GC100IRs();
			toggle_inputs = new Objects.Server.GC100Toggles();
			toggle_inputs.setToggleType("TOGGLE_INPUT");
			toggle_outputs = new Objects.Server.GC100Toggles();
			toggle_inputs.setToggleType("TOGGLE_OUTPUT");
			var tempModules:Array = new Array();
			var tempIRs:Array = new Array();
			var tempToggle_Inputs:Array = new Array();
			var tempToggle_Outputs:Array = new Array();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "";
			description ="";
			active = "";		
			catalogues = new Objects.Server.Catalogues();
			modules = new Objects.Server.GC100Modules();
			irs = new Objects.Server.GC100IRs();
			toggle_inputs = new Objects.Server.GC100Toggles();
			toggle_inputs.setToggleType("TOGGLE_INPUT");
			toggle_outputs = new Objects.Server.GC100Toggles();
			toggle_inputs.setToggleType("TOGGLE_OUTPUT");
			var tempModules:Array = new Array();
			var tempIRs:Array = new Array();
			var tempToggle_Inputs:Array = new Array();
			var tempToggle_Outputs:Array = new Array();
			if (newData.name() == "DEVICE") {
				if(newData.@NAME!=undefined){
					device_type = newData.@NAME;
				}
				if(newData.@DEVICE_TYPE!=undefined){
					device_type = newData.@DEVICE_TYPE;
				}			
				if(newData.@DISPLAY_NAME!=undefined){			
					description = newData.@DISPLAY_NAME;
				}
				if(newData.@DESCRIPTION!=undefined){			
					description = newData.@DESCRIPTION;
				}			
				if(newData.@ACTIVE!=undefined){			
					active = newData.@ACTIVE;
				}
				for (var child:int=0 ; child < newData.children().length() ; child++) {
					var fieldName:String = newData.children()[child].name();
					switch (fieldName) {
					case "CONNECTION" :
						connection.setXML(newData.children()[child]);
						break;
					/*case "PARAMETERS" :
						parameters = newData.children()[child];
						break;*/
					case "GC100_IR":
					case "GC100_Relay":
						var tempNode = newData.children()[child];
						var newModule = new Object();
						newModule.name = tempNode.@NAME;
						for (var index:int=0 ; index < tempNode.children().length() ; index++) {
							if(tempNode.children()[index].name() == "PARAMETERS"){
								for (var index2:int=0 ; index2 < tempNode.children()[index].children().length() ; index2++) {
									if(tempNode.children()[index].children()[index2].@NAME =="MODULE"){
										newModule.number = tempNode.children()[index].children()[index2].@VALUE;									
									}
									if(tempNode.children()[index].children()[index2].@NAME =="MODULE_TYPE"){
										newModule.type = tempNode.children()[index].children()[index2].@VALUE;
									}
								}
							}
						}
						for (var index:int=0 ; index < tempNode.children().length() ; index++) {
							switch(tempNode.children()[index].name()){
								case "IR":
									var newIR = new Object();
									newIR.key = "";
									newIR.name = "";
									newIR.avname = "";
									newIR.module = newModule.number;
									if(tempNode.children()[index].@KEY != undefined){
										newIR.key = tempNode.children()[index].@KEY;
									}
									if(tempNode.children()[index].@NAME != undefined){
										newIR.name = tempNode.children()[index].@NAME;
									}
									if(tempNode.children()[index].@AV_NAME != undefined){
										newIR.avname = tempNode.children()[index].@AV_NAME;
									}
									tempIRs.push(newIR);
									break;		
								case "TOGGLE_OUTPUT":
									var newToggle = new Object();
									
									newToggle.name = "";
									newToggle.display_name = "";
									newToggle.key = "";
									newToggle.module = newModule.number;
									if(tempNode.children()[index].@ACTIVE != undefined){
										newToggle.active = tempNode.children()[index].@ACTIVE;
									}
									if(tempNode.children()[index].@NAME != undefined){
										newToggle.name = tempNode.children()[index].@NAME;
									}
									if(tempNode.children()[index].@DISPLAY_NAME != undefined){
										newToggle.display_name = tempNode.children()[index].@DISPLAY_NAME;
									}
									if(tempNode.children()[index].@KEY != undefined){
										newToggle.key = tempNode.children()[index].@KEY;
									}
									tempToggle_Outputs.push(newToggle);
									break;							
								case "TOGGLE_INPUT":
									var newToggle = new Object();
									
									newToggle.name = "";
									newToggle.display_name = "";
									newToggle.key = "";
									newToggle.module = newModule.number;
									if(tempNode.children()[index].@ACTIVE != undefined){
										newToggle.active = tempNode.children()[index].@ACTIVE;
									}
									if(tempNode.children()[index].@NAME != undefined){
										newToggle.name = tempNode.children()[index].@NAME;
									}
									if(tempNode.children()[index].@DISPLAY_NAME != undefined){
										newToggle.display_name = tempNode.children()[index].@DISPLAY_NAME;
									}
									if(tempNode.children()[index].@KEY != undefined){
										newToggle.key = tempNode.children()[index].@KEY;
									}
									tempToggle_Inputs.push(newToggle);
									break;
							}
						}
						tempModules.push(newModule);
						break;
					}
				}
				var ob:ObjectProxy = new ObjectProxy( {modules:tempModules});
				modules.Data = ob;
				var ob2:ObjectProxy = new ObjectProxy( {irs:tempIRs});
				irs.Data = ob2;
				irs.setModules(modules);
				var ob3:ObjectProxy = new ObjectProxy({toggles:tempToggle_Inputs});
				toggle_inputs.Data = ob3;
				toggle_inputs.setModules(modules);
				var ob4:ObjectProxy = new ObjectProxy({toggles:tempToggle_Outputs})
				toggle_outputs.Data = ob4;
				toggle_outputs.setModules(modules);			
			} else {
				trace("ERROR, found node "+newData.name()+", expecting DEVICE");
			}
		}
	}
}