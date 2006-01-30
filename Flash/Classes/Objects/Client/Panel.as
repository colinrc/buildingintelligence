class Objects.Client.Panel extends Objects.BaseElement {
	private var controls:Array;
	private var name:String;
	private var x_pos:String;
	private var y_pos:String;
	private var height:String;
	private var width:String;	
	public function isValid():Boolean {
		var flag = true;
		for (var control in controls) {
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.panel";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "panel");
		if(name != "") {
			newNode.attributes["name"] = name;
		}
		if(x_pos != "") {
			newNode.attributes["x_pos"] = x_pos;
		}
		if(y_pos != "") {
			newNode.attributes["y_pos"] = y_pos;
		}
		if(height != "") {
			newNode.attributes["height"] = height;
		}
		if(width != "") {
			newNode.attributes["width"] = width;
		}		
		for (var control in controls) {
			newNode.appendChild(controls[control]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "Panel : "+name;
	}
	public function getData():Object {
		return new Object({controls:controls,name:name,x_pos:x_pos,y_pos:y_pos,width:width,height:height});
	}
	public function setXML(newData:XMLNode):Void {
		name = "";
		x_pos = "";
		y_pos = "";
		width = "";
		height = "";
		if(newData.nodeName == "panel"){
			if(newData.attributes["name"] != undefined) {
				name = newData.attributes["name"];
			}
			if(newData.attributes["x_pos"] != undefined) {
				x_pos = newData.attributes["x_pos"];
			}
			if(newData.attributes["y_pos"] != undefined) {
				y_pos = newData.attributes["y_pos"];
			}
			if(newData.attributes["width"] != undefined) {
				width = newData.attributes["width"];
			}
			if(newData.attributes["height"] != undefined) {
				height = newData.attributes["height"];
			}			
			controls = new Array();
			for(var child in newData.childNodes){
				controls.push(newData.childNodes[child]);
			}
		}
		else{
			trace("Error, found "+newData.nodeName+", was expecting panel");
		}
	}
	public function setData(newData:Object):Void {
		controls = newData.controls;
		name = newData.name;
		x_pos = newData.x_pos;
		y_pos = newData.y_pos;
		width = newData.width;
		height = newData.height;		
	}
}
