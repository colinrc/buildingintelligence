package Objects.Client {
	import flash.xml.XMLNode;
	import Objects.*;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Client")]
	[RemoteClass(alias="elifeAdmin.objects.client.client")]
	public class Client extends BaseElement{
		public var description:String;
		public var attributes:Array;
		public var adminPin:String;
		public var applicationXML:String;
		public var integratorHtml:String;	
		public var sounds:Sounds;
		public var status_bar:Status_Bar;
		public var logging:Logging;
		public var apps_bar:Apps_Bar;
		public var control_panel_apps:Control_Panel_Apps;
		public var property:Property;
		public var control_types:Control_Types;
		public var calendar:Calendar;
		public var keygroups:KeyGroups;
		public var attributeGroups:Array = ["settings","window","button","tabs"];
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(description);
			output.writeObject(attributes);
			output.writeUTF(adminPin);
			output.writeUTF(applicationXML);
			output.writeUTF(integratorHtml);	
			output.writeObject(sounds);
			output.writeObject(status_bar);
			output.writeObject(logging);
			output.writeObject(apps_bar);
			output.writeObject(control_panel_apps);
			output.writeObject(property);
			output.writeObject(control_types);
			output.writeObject(calendar);
			output.writeObject(keygroups);
			output.writeObject(attributeGroups);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);	
			description = input.readUTF()as String;
			attributes = input.readObject() as Array;
			adminPin = input.readUTF()as String;
			applicationXML = input.readUTF()as String;
			integratorHtml = input.readUTF()as String;	
			sounds = input.readObject() as Sounds;
			status_bar = input.readObject() as Status_Bar;
			logging = input.readObject() as Logging;
			apps_bar = input.readObject() as Apps_Bar;
			control_panel_apps = input.readObject() as Control_Panel_Apps;
			property = input.readObject() as Property;
			control_types = input.readObject() as Control_Types;
			calendar = input.readObject() as Calendar;
			keygroups = input.readObject() as KeyGroups;
			attributeGroups = input.readObject() as Array
		}
		
		public function deleteSelf():void {
			treeNode.removeNode();
		}		
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			if (attributes.length == 0) {
				flag = "empty";
				appendValidationMsg("No OverRides are defined");
			}
			if (description == null || description == "") {
				flag = "empty";
				appendValidationMsg("Description is missing");
			}
			if (adminPin == null || adminPin == "") {
				flag = "error";
				appendValidationMsg("Admin Pin is missing");
			}
			if (applicationXML == null || applicationXML == "") {
				flag = "error";
				appendValidationMsg("Application XML filename is missing");
			}
			if (integratorHtml == null || integratorHtml == "") {
				flag = "empty";
				appendValidationMsg("Integrator HTML is missing");
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.settings";
		}
		public override function toXML():XML {
			var newNode:XML = new XML("<application />");
			newNode.@description = description;
			var newCommon:XML = new XML("<common />");
			var newSettings:XML = new XML("<settings />");
			var newSetting:XML = new XML("<setting />");
			newSetting = new XML("<setting />");
			newSetting.@name = "applicationXML";
			newSetting.@value = applicationXML;
			newCommon.appendChild(newSetting);		
			newSetting = new XML("<setting />");
			newSetting.@name = "adminPin";
			newSetting.@value = adminPin;
			newCommon.appendChild(newSetting);		
			newSetting = new XML("<setting />");
			newSetting.@name = "integratorHtml";
			newSetting.@value = integratorHtml;
			newCommon.appendChild(newSetting);
			for(var attribute in attributes){
				newSetting = new XML("<setting />");
				newSetting.@name = attributes[attribute].name;
				newSetting.@value = attributes[attribute].value;
				newCommon.appendChild(newSetting);
			}
			newSettings.appendChild(newCommon);
			newNode.appendChild(newSettings);
			newNode.appendChild(calendar.toXML());		
			newNode.appendChild(sounds.toXML());
			newNode.appendChild(status_bar.toXML());
			newNode.appendChild(logging.toXML());
			newNode.appendChild(apps_bar.toXML());
			newNode.appendChild(control_panel_apps.toXML());
			newNode.appendChild(property.toXML());
			newNode.appendChild(control_types.toXML());
			newNode.appendChild(keygroups.toXML());
			return newNode;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.appendChild(control_types.toTree());
			newNode.appendChild(keygroups.toTree());
			newNode.appendChild(property.toTree());
			newNode.appendChild(status_bar.toTree());
			newNode.appendChild(logging.toTree());
			newNode.appendChild(calendar.toTree());		
			newNode.appendChild(sounds.toTree());
			newNode.appendChild(apps_bar.toTree());
			if (Application.application.advancedOn == true){
				newNode.appendChild(control_panel_apps.toTree());			
			}					
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String{
			return "Client";
		}
		public override function getName():String{
			return description;
		}
		public override function getData():ObjectProxy{
			var ob:ObjectProxy = new ObjectProxy({attributes:attributes, dataObject:this, adminPin:adminPin, applicationXML:applicationXML, integratorHtml:integratorHtml});
			return ob;
		}
		public override function setData(newData:Object):void{
			attributes = newData.attributes;
			adminPin = newData.adminPin;
			applicationXML = newData.applicationXML;
			integratorHtml = newData.integratorHtml;	
		}
		public function getAttributes():Array{
			return attributes;
		}
		public function setAttributes(newAttributes:Array):void {
			attributes = newAttributes;
		}
		public function getKeyGroups():XMLNode{
			return keygroups.toXML();
		}
		public function getControlTypes():Object{
			return control_types.toXML();
		}
		public override function setXML(newData:XML):void{
			attributes = new Array();
			adminPin = "4321";
			applicationXML = "client.xml";
			integratorHtml = "about:blank";
			sounds = new Sounds();
			status_bar = new Status_Bar();
			logging = new Logging();
			apps_bar = new Apps_Bar();
			control_panel_apps = new Control_Panel_Apps();
			calendar = new Calendar();
			property = new Property();
			control_types = new Control_Types();
			keygroups = new KeyGroups();
			if(newData.name().toString() == "application") {
				if(newData.@description != undefined){
					description = newData.@description;
				}
				
				var sizeOfApp:int = newData.children().length();
				
				var i:int;
				for (var i:int = 0; i < sizeOfApp; i++) {
				
				
					var child:XML = newData.children()[i];
					var appName:String = child.name();
					switch(appName){
						case "settings":
						var common:XML = child.common[0];
						
						var sizeOfSetting:int = common.elements("setting").length();
				
						var j:int;
						for (j = 0; j < sizeOfSetting; j++) {
						
							var name:String = common.setting[j].attribute("name");
							var value:String = common.setting[j].attribute("value");
								switch(name){
									case ("adminPin"):
										adminPin =value;
									break;
									case ("applicationXML"):
										applicationXML = value;
									break;
									case("serverAddress"):
										//same as _global.project.ipAddress
									break;
									case("integratorHtml"):
										integratorHtml = value;
									break;
									default:
										var newAttribute:Object = new Object();
										newAttribute.name = name;
										newAttribute.value = value;
										attributes.push(newAttribute);
									break;
									}
						}
		
						break;
						case "sounds":
						sounds.setXML(child);
						break;
						case "statusBar":
						status_bar.setXML(child);
						break;
						case "logging":
						logging.setXML(child);
						break;
						case "appsBar":
						apps_bar.setXML(child);
						break;
						case "controlPanelApps":
						control_panel_apps.setXML(child);
						break;
						case "property":
						property.setXML(child);
						break;
						case "controlTypes":
						control_types.setXML(child);
						break;
						case "calendar":
						calendar.setXML(child);
						break;
						case "keygroups":
						keygroups.setXML(child);
						break;
						default:
						trace("error here:"+child.toString());
						break;
					}
				}
			}
			else{
				trace("Found node "+newData.name()+", was expecting application");
			}
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			usedKeys=usedKeys.concat(sounds.getUsedKeys());
			usedKeys=usedKeys.concat(status_bar.getUsedKeys());
			usedKeys=usedKeys.concat(logging.getUsedKeys());
			usedKeys=usedKeys.concat(apps_bar.getUsedKeys());
			usedKeys=usedKeys.concat(control_panel_apps.getUsedKeys());
			usedKeys=usedKeys.concat(property.getUsedKeys());
			usedKeys=usedKeys.concat(control_types.getUsedKeys());
			usedKeys=usedKeys.concat(calendar.getUsedKeys());
			return usedKeys;
		}
		public function getIcons():Array{
			usedIcons = new Array();
			usedIcons=usedIcons.concat(status_bar.getIcons());
			usedIcons=usedIcons.concat(logging.getIcons());
			usedIcons=usedIcons.concat(apps_bar.getIcons());
			usedIcons=usedIcons.concat(property.getIcons());
			usedIcons=usedIcons.concat(control_types.getIcons());
			usedIcons=usedIcons.concat(calendar.getIcons());
			return usedIcons;
		}
	}
}