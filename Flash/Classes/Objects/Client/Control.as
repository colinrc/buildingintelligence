class Objects.Client.Control extends Objects.BaseElement{
	private var type:String;
	private var rows:Array;
	public function isValid():Boolean {
		return true;
	}
	public function getForm():String {
		return "forms.project.client.control";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"control");
		newNode.attributes["type"] = type;
		for(var row in rows){
			newNode.appendChild(rows[row].toXML());
		}
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		for(var row in rows){
			newNode.appendChild(rows[row].toTree());
		}
		return newNode;
	}
	public function getName():String{
		return "Control : "+type;
	}
	public function getData():Object{
		return new Object({rows:rows,type:type});
	}
	public function setXML(newData:XMLNode):Void{
		rows = new Array();
		if(newData.nodeName == "control"){
			type = newData.attributes["type"];
			for(var child in newData.childNodes){
				var newRow = new Objects.Client.Row();
				newRow.setXML(newData.childNodes[child]);
				rows.push(newRow);
			}
		}
		else{
			trace("Error, found "+newData.nodeName+", was expecting control");
		}
	}
	public function setData(newData:Object):Void{
		type = newData.type;
		rows = newData.rows;
	}
}
