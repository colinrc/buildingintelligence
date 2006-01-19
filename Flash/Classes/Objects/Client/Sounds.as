class Objects.Client.Sounds extends Objects.BaseElement{
	public function isValid():Boolean {
		return true;
	}
	public function getForm():String {
		return "base.form";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"sounds")
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getName():String{
		return "Sounds";
	}
	public function getData():Object{
		return new Object({object:""});
	}
	public function setXML(newData:XMLNode):Void{
	}
	public function setData(newData:Object):Void{
	}
}
