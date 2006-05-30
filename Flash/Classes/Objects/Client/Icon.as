class Objects.Client.Icon extends Objects.BaseElement {
	private var name:String;
	private var icon:String;
	private var func:String;
	private var canOpen:String;
	private var param:String;
	private var attributes:Array;
	private var treeNode:XMLNode;
	private var attributeGroups = ["button"];	
	public function deleteSelf(){
		treeNode.removeNode();
	}			
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (name == undefined || name == "") {
				flag = "error";
				appendValidationMsg("Name is invalid");
		}
		if (icon == undefined || icon == "") {
				flag = "error";
				appendValidationMsg("Icon is invalid");
		}
		if (func == undefined || func == "") {
				flag = "error";
				appendValidationMsg("Function is invalid");
		}
		//only for keyboards
		if ((func == "runexe") && (param == undefined || param == "")) {
				flag = "error";
				appendValidationMsg("Parameter is invalid");
		}
		
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.icon";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "icon");
		if ((name != undefined) && (name != "")) {
			newNode.attributes["name"] = name;
		}
		if ((icon != undefined) && (icon != "")) {
			newNode.attributes["icon"] = icon;
		}
		if ((func != undefined) && (func != "")) {
			newNode.attributes["func"] = func;
		}
		if ((param != undefined) && (param != "")) {
			newNode.attributes["program"] = param;
		}		
		newNode.attributes["canOpen"] = canOpen;
		for (var attribute in attributes) {
			newNode.attributes[attributes[attribute].name] = attributes[attribute].value;
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getKey());
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String{
		return "ClientIcon";
	}	
	public function getName():String {
		return "Icon:"+name;
	}
	public function getData():Object {
		return {name:name, icon:icon, func:func, canOpen:canOpen, param:param, dataObject:this};
	}
	public function setData(newData:Object):Void {
		name = newData.name;
		icon = newData.icon;
		func = newData.func;
		canOpen = newData.canOpen;
		param = newData.param;
	}
	public function getAttributes():Array{
		return attributes;
	}
	public function setAttributes(newAttributes:Array){
		attributes = newAttributes;
	}	
	public function setXML(newData:XMLNode):Void {
		attributes = new Array();
		name = "";
		icon = "";
		func = "";
		canOpen = "";
		param = "";
		if (newData.nodeName == "icon") {
			for (var attribute in newData.attributes) {
				switch (attribute) {
				case "name" :
					name = newData.attributes[attribute];
					break;
				case "icon" :
					icon = newData.attributes[attribute];
					break;
				case "func" :
					func = newData.attributes[attribute];
					break;
				case "canOpen" :
					canOpen = newData.attributes[attribute];
					break;
				case "program":
					param = newData.attributes[attribute];
					break;
				default :
					attributes.push({name:attribute, value:newData.attributes[attribute]});
					break;
				}
			}
		} else {
			mdm.Dialogs.prompt("Error, received "+newData.nodeName+", was expecting icon");
		}
	}

	public function getIcons():Array{
		usedIcons = new Array();
		if (icon != "" && icon != undefined){
			addIcon(icon);
		}
		return usedIcons;
	}
}
