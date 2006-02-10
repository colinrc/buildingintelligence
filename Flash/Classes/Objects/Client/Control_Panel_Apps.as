class Objects.Client.Control_Panel_Apps extends Objects.BaseElement{
	private var apps:Array;
	public function isValid():Boolean {
		var flag = true;
		/*for(var child in apps.childNodes){
			if(apps.childNodes[child].attributes["label"] == undefined){
				flag = false;
			}
			if(apps.childNodes[child].attributes["program"] ==undefined){
				flag = false;
			}
		}*/
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.controlpanelapps";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"controlPanelApps");
		for(var app in apps) {
			newNode.appendChild(apps[app]);
		}
		return newNode;		
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getName():String{
		return "Control Panel Apps";
	}
	public function getData():Object{
		return {apps:apps};
	}
	public function setXML(newData:XMLNode):Void{
		apps = new Array();
		if(newData.nodeName == "controlPanelApps"){
			for(var app in newData.childNodes){
				apps.push(newData.childNodes[app]);
			}
		}
		else{
			trace("Error, received "+newData.nodeName+", was expecting controlPanelApps");			
		}
	}
	public function setData(newData:Object):Void{
		apps = newData.apps;
	}
}
