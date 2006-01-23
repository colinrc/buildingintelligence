class Objects.Client.Control_Panel_Apps extends Objects.BaseElement{
	private var apps:XMLNode;
	public function isValid():Boolean {
		return true;
	}
	public function getForm():String {
		return "forms.project.client.controlpanelapps";
	}
	public function toXML():XMLNode {
		return apps;
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
		return new Object({apps:apps});
	}
	public function setXML(newData:XMLNode):Void{
		if(newData.nodeName == "controlPanelApps"){
			apps = newData;
		}
		else{
			trace("Error, received "+newData.nodeName+", was expecting controlPanelApps");			
		}
	}
	public function setData(newData:Object):Void{
		apps = newData.apps;
	}
}
