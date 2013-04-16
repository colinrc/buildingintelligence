package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.Hal_frm;
	
	[Bindable("Hal")]
	[RemoteClass(alias="elifeAdmin.server.hal")] 
	public class Hal extends Device {
		private var audiovideos:AudioVideos;
		private var inputs:Catalogue;
		private var functions:Catalogue;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(audiovideos);
			output.writeObject(inputs);
			output.writeObject(functions);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			audiovideos = input.readObject()as AudioVideos;
			inputs = input.readObject()as Catalogue;
			functions = input.readObject()as Catalogue;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			tempKeys = tempKeys.concat(audiovideos.getKeys());
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
						
			var newParameters = new XML("<PARAMETERS />");
			for(var parameter in parameters){
				var x1:XML = new XML("<ITEM />");
				x1.@NAME = parameter;
				x1.@VALUE = parameters[parameter];
				newParameters.appendChild(x1);
			}
			var newParameter = new XML("<ITEM />");
			newParameter.@NAME = "INPUTS";
			newParameter.@VALUE = "HAL Inputs";
			newParameters.appendChild(newParameter);
			newParameter = new XML("<ITEM />");
			newParameter.@NAME = "FUNCTIONS";
			newParameter.@VALUE = "HAL Functions";
			newParameters.appendChild(newParameter);		
			
			newDevice.appendChild(newParameters);
						
			newDevice.appendChild(inputs.toXML());
			newDevice.appendChild(functions.toXML());		
			var tempCatalogues:XML = catalogues.toXML();
			for (var child:int=0 ; child < tempCatalogues.children().length() ; child++) {
				newDevice.appendChild(tempCatalogues.children()[child]);
			}
			var newHal:XML = new XML("<"+device_type+ " />");
			var tempAudioVideos:XML = audiovideos.toXML();
			for (var child:int=0 ; child < tempAudioVideos.children().length() ; child++) {
				newHal.appendChild(tempAudioVideos.children()[child]);
			}
			newDevice.appendChild(newHal);
			return newDevice;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(inputs.toTree());
			newNode.appendChild(functions.toTree());			
			newNode.appendChild(audiovideos.toTree());
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "Hal";
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.Hal_frm;
			return className;		
		}
		
		public override function newObject():void {
			super.newObject();
			device_type = "HAL";
			description ="";
			active = "Y";
				
			inputs = new Objects.Server.Catalogue();
			
			var newInputs:XML = new XML("<CATALOGUE />");
			newInputs.@NAME = "HAL Inputs";
			inputs.setXML(newInputs);
			functions = new Objects.Server.Catalogue();		
			var newFunctions:XML = new XML("<CATALOGUE />");
			newFunctions.@NAME = "HAL Functions";
			functions.setXML(newFunctions);				
			audiovideos = new Objects.Server.AudioVideos();
		}
		
		public override function setXML(newData:XML):void {
			device_type = "";
			description ="";
			active = "Y";
			parameters = new HashMap();		
			inputs = new Objects.Server.Catalogue();
			var newInputs:XML = new XML("<CATALOGUE />");
			newInputs.@NAME = "HAL Inputs";
			inputs.setXML(newInputs);
			functions = new Objects.Server.Catalogue();		
			var newFunctions:XML = new XML("<CATALOGUE />");
			newFunctions.@NAME = "HAL Functions";
			functions.setXML(newFunctions);				
			audiovideos = new Objects.Server.AudioVideos();
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
					var myType:String = newData.children()[child].name();
					switch (myType) {
					case "CONNECTION" :
						connection.setXML(newData.children()[child]);
						break;
					case "PARAMETERS" :
					for (var parameter:int=0 ; parameter < newData.children()[child].children().length() ; parameter++) {
						if((newData.children()[child].children()[parameter].@NAME != "INPUTS")&&(newData.children()[child].children()[parameter].@NAME != "FUNCTIONS")){						
								parameters.put(newData.children()[child].children()[parameter].@NAME.toString(), newData.children()[child].children()[parameter].@VALUE.toString());
						  	}
						}
						break;
					case "CATALOGUE" :
						if(newData.children()[child].@NAME == "HAL Inputs"){
							inputs.setXML(newData.children()[child]);
						} else if(newData.children()[child].@NAME == "HAL Functions"){
							functions.setXML(newData.children()[child]);						
						}
						break;
					case "HAL":
						audiovideos.setXML(newData.children()[child]);
						break;
					}
				}
			} else {
				trace("ERROR, found node "+newData.name()+", expecting DEVICE");
			}
		}
	}
}