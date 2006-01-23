class Objects.Client.Item extends Objects.BaseElement{
	private var type:String;
	private var attributes:Array;
	public function isValid():Boolean {
		return true;
	}
	public function getForm():String {
		return "forms.project.client.item";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"item");
		newNode.attributes["type"] = type;
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
		return "Item : "+type;
	}
	public function getData():Object{
		return new Object({type:type,attributes:attributes});
	}
	public function setXML(newData:XMLNode):Void{
		attributes = new Array();
		if(newData.nodeName == "item"){
			for(var attribute in newData.attributes){
				switch(attribute){
					case "type":
						type = newData.attributes[attribute];
						break;
					default:
						var newAttribute = new Object();
						newAttribute.name = attribute;
						newAttribute.value = newData.attributes[attribute];
						attributes.push(newAttribute);
						break;
				}
			}
		}
		else{
			trace("Error, found "+newData.nodeName+", was expecting item");
		}
	}
	public function setData(newData:Object):Void{
		type = newData.type;
		attributes = newData.attributes;
		//process items changes
	}
}
