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
	public function isValid():Boolean {
		var flag = true
		if(!sounds.isValid()){
			flag = false;
		}
		if(!status_bar.isValid()){
			flag = false;
		}
		if(!logging.isValid()){
			flag = false;
		}
		if(!apps_bar.isValid()){
			flag = false;
		}
		if(!control_panel_apps.isValid()){
			flag = false;
		}
		if(!Property.isValid()){
			flag = false;
		}
		if(!control_types.isValid()){
			flag = false;
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.settings";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"application");
		newNode.attributes.description = description;
		var newSettings = new XMLNode(1,"settings");
		var newSetting = new XMLNode(1,"setting");
		newSetting.attributes.name = "serverAddress";
		newSetting.attributes.value = _global.project.ipAddress;
		newSettings.appendChild(newSetting);
		newSetting = new XMLNode(1,"setting");
		newSetting.attributes.name = "applicationXML";
		newSetting.attributes.value = applicationXML;
		newSettings.appendChild(newSetting);		
		newSetting = new XMLNode(1,"setting");
		newSetting.attributes.name = "adminPin";
		newSetting.attributes.value = adminPin;
		newSettings.appendChild(newSetting);		
		newSetting = new XMLNode(1,"setting");
		newSetting.attributes.name = "integratorHtml";
		newSetting.attributes.value = integratorHtml;
		newSettings.appendChild(newSetting);
		for(var attribute in attributes){
			newSetting = new XMLNode(1,"setting");
			newSetting.attributes.name = attributes[attribute].name;
			newSetting.attributes.value = attributes[attribute].value;
			newSettings.appendChild(newSetting);
		}
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
		if(_global.advanced){
			newNode.appendChild(control_panel_apps.toTree());			
		}					
		newNode.appendChild(calendar.toTree());		
		newNode.appendChild(sounds.toTree());
		newNode.appendChild(status_bar.toTree());
		newNode.appendChild(logging.toTree());
		newNode.appendChild(apps_bar.toTree());
		newNode.appendChild(Property.toTree());
		newNode.appendChild(control_types.toTree());
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
			description = newData.attributes.description;
			for(var child in newData.childNodes){
				switch(newData.childNodes[child].nodeName){
					case "settings":
					for(var setting in newData.childNodes[child].childNodes){
						switch(newData.childNodes[child].childNodes[setting].attributes["name"]){
						case ("adminPin"):
							adminPin = newData.childNodes[child].childNodes[setting].attributes["value"];
						break;
						case ("applicationXML"):
							applicationXML = newData.childNodes[child].childNodes[setting].attributes["value"];
						break;
						case("serverAddress"):
							//same as _global.project.ipAddress
						break;
						case("integratorHtml"):
							integratorHtml = newData.childNodes[child].childNodes[setting].attributes["value"];
						break;
						default:
							var newAttribute = new Object();
							newAttribute.name = newData.childNodes[child].childNodes[setting].attributes["name"];
							newAttribute.value = newData.childNodes[child].childNodes[setting].attributes["value"];
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
					trace(newData.childNodes[child]);
					break;
				}
			}
		}
		else{
			trace("Found node "+newData.nodeName+", was expecting application");
		}
	}
}
