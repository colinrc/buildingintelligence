class Objects.Client.Alerts extends Objects.BaseElement {
	private var x_pos:String;
	private var y_pos:String;
	private var alerts:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var alert in alerts) {
			if (!alerts[alert]) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.alerts";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "alerts");
		newNode.attributes["x"] = x_pos;
		newNode.attributes["y"] = y_pos;
		for (var alert in alerts) {
			newNode.appendChild(alerts[alert]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		var newString = "Alerts";
		if((x_pos !=undefined)&&(x_pos !="")){
			newString+= " X:"+x_pos;
		}
		if((y_pos !=undefined)&&(y_pos !="")){
			newString+= " Y:"+y_pos;
		}
		return newString;
	}
	public function getData():Object {
		return new Object({x_pos:x_pos,y_pos:y_pos,alerts:alerts});
	}
	public function setXML(newData:XMLNode):Void {
		if(newData.nodeName == "alerts"){
			alerts = new Array();
			x_pos = newData.attributes["x"];
			y_pos = newData.attributes["y"];
			for(var child in newData.childNodes){
				alerts.push(newData.childNodes[child]);
			}
		} else{
			trace("Error, found "+newData.nodeName+", was expecting alerts");
		}
	}
	public function setData(newData:Object):Void {
		x_pos = newData.x_pos;
		y_pos = newData.y_pos;
		alerts = newData.alerts;
	}
}
