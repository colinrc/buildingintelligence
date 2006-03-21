 class Objects.Client.Calendar extends Objects.BaseElement{
	private var attributes:Array;
	private var treeNode:XMLNode;
	private var tabs:Array;
	private var attributeGroups = ["tabs"];	
	public function deleteSelf(){
		treeNode.removeNode();
	}			
	public function isValid():Boolean {
		var flag = true;
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.calendar";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"calendar");
		for(var attribute in attributes){
			newNode.attributes[attributes[attribute].name] = attributes[attribute].value;
		}
		for(var tab in tabs){
			newNode.appendChild(tabs[tab]);
		}
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getKey());
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String{
		return "Calendar";
	}	
	public function getName():String{
		return "Calendar";
	}
	public function getData():Object{
		return {tabs:tabs, dataObject:this};
	}
	public function setData(newData:Object):Void{
		tabs = newData.tabs;
	}
	public function getAttributes():Array{
		return attributes;
	}
	public function setAttributes(newAttributes:Array){
		attributes = newAttributes;
	}		
	public function setXML(newData:XMLNode):Void{
		tabs = new Array();
		attributes = new Array();
		if(newData.nodeName = "calendar"){
			for(var attribute in newData.attributes){
				attributes.push({name:attribute, value:newData.attributes[attribute]});
			}
			for(var child in newData.childNodes){
				tabs.push(newData.childNodes[child]);
			}
		}
		else{
			trace("Error, received "+newData.nodeName+", was expecting calendar");
		}
	}
}
