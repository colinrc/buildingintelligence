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
		if(name != ""){
			newNode.attributes["name"] = name;
		}
		if(icon != "") {
			newNode.attributes["icon"] = icon;
		}
		if(show != "") {
			newNode.attributes["show"] = show;
		}
		if(hide != "") {
			newNode.attributes["hide"] = hide;
		}
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
		_global.workflow.addNode("ClientStatusBarGroup",newNode);
		return newNode;
	}
	public function getName():String{
		return "Group: "+name;
	}
	public function getData():Object{
		return new Object({controls:controls,attributes:attributes, icon:icon,name:name,show:show,hide:hide});
	}
	public function setXML(newData:XMLNode):Void{
		name = "";
		icon = "";
		show = "";
		hide = "";
		controls = new Array();
		attributes = new Array();
		if(newData.nodeName = "group"){
			for(var attribute in newData.attributes){
				switch(attribute){
					case "name":
					if(newData.attributes[attribute] != undefined){
						name = newData.attributes[attribute];
					}
					break;
					case "icon":
					if(newData.attributes[attribute] != undefined){				
						icon = newData.attributes[attribute];
					}
					break;
					case "show":
					if(newData.attributes[attribute] != undefined) {					
						show = newData.attributes[attribute];
					}
					break;
					case "hide":
					if(newData.attributes[attribute] != undefined) {
						hide = newData.attributes[attribute];
					}
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
		attributes = newData.attributes;
		name = newData.name;
		icon = newData.icon;
		show = newData.show;
		hide = newData.hide;
	}
}
