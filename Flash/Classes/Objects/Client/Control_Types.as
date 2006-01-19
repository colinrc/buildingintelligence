class Objects.Client.Control_Types extends Objects.BaseElement{
	public function isValid():Boolean {
		return true;
	}
	public function getForm():String {
		return "base.form";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"controlTypes")
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getName():String{
		return "Control Types";
	}
	public function getData():Object{
		return new Object({object:""});
	}
	public function setXML(newData:XMLNode):Void{
	}
	public function setData(newData:Object):Void{
	}
}
