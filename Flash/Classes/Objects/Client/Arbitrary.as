class Objects.Client.Arbitrary extends Objects.BaseElement {
	private var items:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var item in items){
			if((items[item].attributes["type"] == "")||(items[item].attributes["type"] == undefined)){
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.arbitrary";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"arbitrary");
		for(var item in items) {
			newNode.appendChild(items[item]);
		}
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		_global.workflow.addNode("ClientArbitrary",newNode);
		return newNode;
	}
	public function getName():String{
		return "Arbitrary";
	}
	public function getData():Object{
		return new Object({items:items});
	}
	public function setXML(newData:XMLNode):Void{
		items = new Array();
		if(newData.nodeName == "arbitrary"){
			for(var child in newData.childNodes){
				items.push(newData.childNodes[child]);
			}
		}
		else{
			trace("Error, found "+ newData.nodeName +", was expecting arbitrary");
		}
	}
	public function setData(newData:Object):Void{
			items = newData.items;
	}
}
