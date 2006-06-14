class Objects.Client.Client extends Objects.BaseElement{
	private var description:String;
	private var attributes:Array;
	private var adminPin:String;
	private var applicationXML:String;
	private var integratorHtml:String;	
	private var sounds:Objects.Client.Sounds;
	private var status_bar:Objects.Client.Status_Bar;
	private var logging:Objects.Client.Logging;
	private var apps_bar:Objects.Client.Apps_Bar;
	private var control_panel_apps:Objects.Client.Control_Panel_Apps;
	private var Property:Objects.Client.Property;
	private var control_types:Objects.Client.Control_Types;
	private var calendar:Objects.Client.Calendar;
	private var attributeGroups = ["settings","window","button","tabs"];
	private var treeNode:XMLNode;	
	public function deleteSelf(){
		treeNode.removeNode();
	}		
	public function isValid():String {
		var flag = "ok";
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
	public function getForm():String {
		return "forms.project.client.settings";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"application");
		newNode.attributes.description = description;
		var newCommon = new XMLNode(1,"common");
		var newSettings = new XMLNode(1,"settings");
		var newSetting = new XMLNode(1,"setting");
		//newSetting.attributes.name = "serverAddress";
		//newSetting.attributes.value = _global.project.ipAddress;
		//newCommon.appendChild(newSetting);
		newSetting = new XMLNode(1,"setting");
		newSetting.attributes.name = "applicationXML";
		newSetting.attributes.value = applicationXML;
		newCommon.appendChild(newSetting);		
		newSetting = new XMLNode(1,"setting");
		newSetting.attributes.name = "adminPin";
		newSetting.attributes.value = adminPin;
		newCommon.appendChild(newSetting);		
		newSetting = new XMLNode(1,"setting");
		newSetting.attributes.name = "integratorHtml";
		newSetting.attributes.value = integratorHtml;
		newCommon.appendChild(newSetting);
		for(var attribute in attributes){
			newSetting = new XMLNode(1,"setting");
			newSetting.attributes.name = attributes[attribute].name;
			newSetting.attributes.value = attributes[attribute].value;
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
		newNode.appendChild(Property.toXML());
		newNode.appendChild(control_types.toXML());
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,"Client");
		newNode.appendChild(Property.toTree());
		if(_global.advanced){
			newNode.appendChild(control_types.toTree());
		}
		newNode.appendChild(status_bar.toTree());
		newNode.appendChild(logging.toTree());
		newNode.appendChild(calendar.toTree());		
		newNode.appendChild(sounds.toTree());
		newNode.appendChild(apps_bar.toTree());
		if(_global.advanced){
			newNode.appendChild(control_panel_apps.toTree());			
		}					
		newNode.object = this;
		treeNode = newNode;		
		return newNode;
	}
	public function getKey():String{
		return "Client";
	}
	public function getName():String{
		return description;
	}
	public function getData():Object{
		return {attributes:attributes, dataObject:this, adminPin:adminPin, applicationXML:applicationXML, integratorHtml:integratorHtml};
	}
	public function setData(newData:Object):Void{
		attributes = newData.attributes;
		adminPin = newData.adminPin;
		applicationXML = newData.applicationXML;
		integratorHtml = newData.integratorHtml;	
	}
	public function getAttributes():Array{
		return attributes;
	}
	public function setAttributes(newAttributes:Array){
		attributes = newAttributes;
	}
	public function getControlTypes():Object{
		return control_types.toXML();
	}
	public function setXML(newData:XMLNode):Void{
		attributes = new Array();
		adminPin = "4321";
		applicationXML = "client.xml";
		integratorHtml = "about:blank";
		sounds = new Objects.Client.Sounds();
		status_bar = new Objects.Client.Status_Bar();
		logging = new Objects.Client.Logging();
		apps_bar = new Objects.Client.Apps_Bar();
		control_panel_apps = new Objects.Client.Control_Panel_Apps();
		calendar = new Objects.Client.Calendar();
		Property = new Objects.Client.Property();
		control_types = new Objects.Client.Control_Types();
		if(newData.nodeName == "application") {
			if(newData.attributes.description != undefined){
				description = newData.attributes.description;
			}
			for(var child in newData.childNodes){
				switch(newData.childNodes[child].nodeName){
					case "settings":
					var common = newData.childNodes[child].firstChild;
					for(var setting in common.childNodes){
						switch(common.childNodes[setting].attributes["name"]){
						case ("adminPin"):
							adminPin = common.childNodes[setting].attributes["value"];
						break;
						case ("applicationXML"):
							applicationXML = common.childNodes[setting].attributes["value"];
						break;
						case("serverAddress"):
							//same as _global.project.ipAddress
						break;
						case("integratorHtml"):
							integratorHtml = common.childNodes[setting].attributes["value"];
						break;
						default:
							var newAttribute = new Object();
							newAttribute.name = common.childNodes[setting].attributes["name"];
							newAttribute.value = common.childNodes[setting].attributes["value"];
							attributes.push(newAttribute);
						break;
						}
					}
					break;
					case "sounds":
					sounds.setXML(newData.childNodes[child]);
					break;
					case "statusBar":
					status_bar.setXML(newData.childNodes[child]);
					break;
					case "logging":
					logging.setXML(newData.childNodes[child]);
					break;
					case "appsBar":
					apps_bar.setXML(newData.childNodes[child]);
					break;
					case "controlPanelApps":
					control_panel_apps.setXML(newData.childNodes[child]);
					break;
					case "property":
					Property.setXML(newData.childNodes[child]);
					break;
					case "controlTypes":
					control_types.setXML(newData.childNodes[child]);
					break;
					case "calendar":
					calendar.setXML(newData.childNodes[child]);
					break;
					default:
					mdm.Dialogs.prompt(newData.childNodes[child]);
					break;
				}
			}
		}
		else{
			//mdm.Dialogs.prompt("Found node "+newData.nodeName+", was expecting application");
		}
	}
	public function getUsedKeys():Array{
		usedKeys = new Array();
		usedKeys=usedKeys.concat(sounds.getUsedKeys());
		usedKeys=usedKeys.concat(status_bar.getUsedKeys());
		usedKeys=usedKeys.concat(logging.getUsedKeys());
		usedKeys=usedKeys.concat(apps_bar.getUsedKeys());
		usedKeys=usedKeys.concat(control_panel_apps.getUsedKeys());
		usedKeys=usedKeys.concat(Property.getUsedKeys());
		usedKeys=usedKeys.concat(control_types.getUsedKeys());
		usedKeys=usedKeys.concat(calendar.getUsedKeys());
		return usedKeys;
	}
	public function getIcons():Array{
		usedIcons = new Array();
		//usedIcons=usedIcons.concat(sounds.getIcons());
		usedIcons=usedIcons.concat(status_bar.getIcons());
		usedIcons=usedIcons.concat(logging.getIcons());
		usedIcons=usedIcons.concat(apps_bar.getIcons());
		//usedIcons=usedIcons.concat(control_panel_apps.getIcons());
		usedIcons=usedIcons.concat(Property.getIcons());
		usedIcons=usedIcons.concat(control_types.getIcons());
		usedIcons=usedIcons.concat(calendar.getIcons());
		return usedIcons;
	}
}
