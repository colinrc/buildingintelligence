class Objects.Client.Client extends Objects.BaseElement{
	private var settings:XMLNode;
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
		for(var setting in settings.childNodes){
			newSettings.appendChild(settings.childNodes[setting].cloneNode(false));
		}
		newNode.appendChild(newSettings);
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
		newNode.appendChild(sounds.toTree());
		newNode.appendChild(status_bar.toTree());
		newNode.appendChild(logging.toTree());
		newNode.appendChild(apps_bar.toTree());
		newNode.appendChild(Property.toTree());
		newNode.appendChild(control_types.toTree());
		newNode.object = this;
		return newNode;
	}
	public function getKey():String{
		return "Client";
	}
	public function getName():String{
		return "Client";
	}
	public function getData():Object{
		return {settings:settings, dataObject:this, adminPin:adminPin, applicationXML:applicationXML, integratorHtml:integratorHtml};
	}
	public function setData(newData:Object):Void{
		settings = newData.settings;
		adminPin = newData.adminPin;
		applicationXML = newData.applicationXML;
		integratorHtml = newData.integratorHtml;	
	}	
	public function getControlTypes():Object{
		return control_types.toXML();
	}
	public function setXML(newData:XMLNode):Void{
		//settings = new Objects.Client.Settings();
		adminPin = "4321";
		applicationXML = "client.xml";
		integratorHtml = "about:blank";
		sounds = new Objects.Client.Sounds();
		status_bar = new Objects.Client.Status_Bar();
		logging = new Objects.Client.Logging();
		apps_bar = new Objects.Client.Apps_Bar();
		control_panel_apps = new Objects.Client.Control_Panel_Apps();
		Property = new Objects.Client.Property();
		control_types = new Objects.Client.Control_Types();
		if(newData.nodeName == "application") {
			for(var child in newData.childNodes){
				switch(newData.childNodes[child].nodeName){
					case "settings":
					settings = newData.childNodes[child];
					for(var setting in settings.childNodes){
						if(settings.childNodes[setting].attributes["name"] == "adminPin"){
							adminPin = settings.childNodes[setting].attributes["value"];
							settings.childNodes[setting].removeNode();
						}
						if(settings.childNodes[setting].attributes["name"] == "applicationXML"){
							applicationXML = settings.childNodes[setting].attributes["value"];
							settings.childNodes[setting].removeNode();							
						}
						if(settings.childNodes[setting].attributes["name"] == "serverAddress"){
							//same as _global.project.ipAddress
							settings.childNodes[setting].removeNode();							
						}
						if(settings.childNodes[setting].attributes["name"] == "integratorHtml"){
							integratorHtml = settings.childNodes[setting].attributes["value"];
							settings.childNodes[setting].removeNode();							
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
