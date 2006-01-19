class Objects.Client.Settings extends Objects.BaseElement{
	private var settings:XMLNode;
	public function isValid():Boolean {
		var flag = true;
		for(var child in settings.childNodes){
			if((settings.childNodes[child].attributes["name"] == "")||(settings.childNodes[child].attributes["name"] == undefined)){
				flag = false;
			}
			if((settings.childNodes[child].attributes["value"] == "")||(settings.childNodes[child].attributes["value"] == undefined)){
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.settings";
	}
	public function toXML():XMLNode {
		return settings;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getName():String{
		return "Settings";
	}
	public function getData():Object{
		return new Object({settings:settings});
	}
	public function setXML(newData:XMLNode):Void{
		if(newData.nodeName == "settings"){
			settings = newData;
		}
		else{
			trace("Found node "+newData.nodeName+", was expecting settings");
		}
	}
	public function setData(newData:Object):Void{
		settings = newData.settings;
	}
}
