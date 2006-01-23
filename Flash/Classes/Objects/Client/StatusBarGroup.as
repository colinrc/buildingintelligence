 class Objects.Client.StatusBarGroup extends Objects.BaseElement{
	private var name:String;
	private var icon:String;
	private var show:String;
	private var hide:String;
	private var controls:Array;
	private var attributes:Array;
	public function isValid():Boolean {
		var flag = true;
		for(var control in controls){
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.statusbargroup";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"group");
		newNode.attributes["name"] = name;
		newNode.attributes["icon"] = icon;
		newNode.attributes["show"] = show;
		newNode.attributes["hide"] = hide;
		for(var attribute in attributes){
			newNode.attributes[attributes[attribute].name] = attributes[attribute].value;
		}
		for(var control in controls){
			newNode.appendChild(controls[control]);
		}
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getName():String{
		return "Group: "+name;
	}
	public function getData():Object{
		return new Object({controls:controls, icon:icon,name:name,show:show,hide:hide});
	}
	public function setXML(newData:XMLNode):Void{
		controls = new Array();
		attributes = new Array();
		if(newData.nodeName = "group"){
			for(var attribute in newData.attributes){
				switch(attribute){
					case "name":
					name = newData.attributes[attribute];
					break;
					case "icon":
					icon = newData.attributes[attribute];
					break;
					case "show":
					show = newData.attributes[attribute];
					break;
					case "hide":
					hide = newData.attributes[attribute];
					break;
					default:
					attributes.push({name:attribute, value:newData.attributes[attribute]});
					break;
				}
			}
			for(var child in newData.childNodes){
				controls.push(newData.childNodes[child]);
			}
		}
		else{
			trace("Error, received "+newData.nodeName+", was expecting group");
		}
	}
	public function setData(newData:Object):Void{
		controls = newData.controls;
		name = newData.name;
		icon = newData.icon;
		show = newData.show;
		hide = newData.hide;
	}
}
