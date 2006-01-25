class Objects.Client.Client extends Objects.BaseElement{
	private var settings:Objects.Client.Settings;
	private var sounds:Objects.Client.Sounds;
	private var status_bar:Objects.Client.Status_Bar;
	private var logging:Objects.Client.Logging;
	private var apps_bar:Objects.Client.Apps_Bar;
	private var control_panel_apps:Objects.Client.Control_Panel_Apps;
	private var Property:Objects.Client.Property;
	private var control_types:Objects.Client.Control_Types;
	public function isValid():Boolean {
		var flag = true
		if(!settings.isValid()){
			flag = false;
		}
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
		return "NONE";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"application");
		newNode.appendChild(settings.toXML());
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
		newNode.appendChild(settings.toTree());
		newNode.appendChild(sounds.toTree());
		newNode.appendChild(status_bar.toTree());
		newNode.appendChild(logging.toTree());
		newNode.appendChild(apps_bar.toTree());
		newNode.appendChild(control_panel_apps.toTree());
		newNode.appendChild(Property.toTree());
		newNode.appendChild(control_types.toTree());
		newNode.object = this;
		return newNode;
	}
	public function getName():String{
		return "Client";
	}
	public function getData():Object{
		return new Object();
	}
	public function getControlTypes():Object{
		return control_types.toXML();
	}
	public function setXML(newData:XMLNode):Void{
		settings = new Objects.Client.Settings();
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
					settings.setXML(newData.childNodes[child]);
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
	public function setData(newData:Object):Void{
	}
}
