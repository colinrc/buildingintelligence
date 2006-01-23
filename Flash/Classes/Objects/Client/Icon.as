class Objects.Client.Icon extends Objects.BaseElement{
	private var name:String;
	private var icon:String;
	private var func:String;
	private var canOpen:String;
	private var attributes:Array;
	public function isValid():Boolean {
		return true;
	}
	public function getForm():String {
		return "forms.project.client.Icon";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"icon");
		newNode.attributes["name"] = name;
		newNode.attributes["icon"] = icon;
		newNode.attributes["func"] = func;
		newNode.attributes["canOpen"] = canOpen;
		for(var attribute in attributes){
			newNode.attributes[attributes[attribute].name] = attributes[attribute].value;
		}
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getName():String{
		return "Icon:"+name;
	}
	public function getData():Object{
		return new Object({name:name,icon:icon,func:func,canOpen:canOpen,attributes:attributes});
	}
	public function setXML(newData:XMLNode):Void{
		attributes = new Array();
		if(newData.nodeName =="icon"){
			for(var attribute in newData.attributes){
				switch(attribute){
					case "name":
					name = newData.attributes[attribute];
					break;
					case "icon":
					icon = newData.attributes[attribute];
					break;
					case "func":
					func = newData.attributes[attribute];
					break;
					case "canOpen":
					canOpen = newData.attributes[attribute];
					break;
					default:
					attributes.push({name:attribute, value:newData.attributes[attribute]});
					break;
				}
			}
		}
		else{
			trace("Error, received "+newData.nodeName+", was expecting icon");			
		}
	}
	public function setData(newData:Object):Void{
		name = newData.name;
		icon = newData.icon;
		func = newData.func;
		canOpen = newData.canOpen;
		attributes = newData.attributes;
	}
}