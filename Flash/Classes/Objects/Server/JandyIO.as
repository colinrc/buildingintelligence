class Objects.Server.JandyIO extends Objects.BaseElement {
	private var container:String;
	private var auxiliary:Array;
	private var treeNode:XMLNode;	

	public function getKeys():Array{
		var tempKeys = new Array();
		for(var aux in auxiliary){
			tempKeys.push(auxiliary[aux].display_name);
		}
		return tempKeys;
	}

	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var aux in auxiliary)
		{
			if ((auxiliary[aux].active != "Y") && (auxiliary[aux].active != "N")) {
				flag = "error";
				appendValidationMsg("Active flag is invalid");
			}
			if (auxiliary[aux].active =="Y")
			{
				if ((auxiliary[aux].name == undefined) || (auxiliary[aux].name == ""))
				{
					flag = "empty";
					appendValidationMsg("Description is empty");
				}
				if ((auxiliary[aux].display_name == undefined) || (auxiliary[aux].display_name == ""))
				{
					flag = "error";
					appendValidationMsg("Key is invalid");
				}
				else
				{
					if (_global.isKeyUsed(auxiliary[aux].display_name) == false) {
						flag = "error";
						appendValidationMsg(auxiliary[aux].display_name+" key is not being used");
					}
				}
				if ((auxiliary[aux].key == undefined) || (auxiliary[aux].key == "")) {
					flag = "error";
					appendValidationMsg("Input/Output No. is empty");
				}
			}
			else{
				flag = "empty";
				appendValidationMsg("Auxiliary is not Active");
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.jandyio";
	}

	public function toXML():XMLNode {
		var JandyNode = new XMLNode(1, container);
		for (var aux in auxiliary)
		{
			var auxNode = new XMLNode(1, auxiliary[aux].node);
			if (auxiliary[aux].name != "")
			{
				auxNode.attributes["NAME"] = auxiliary[aux].name;
			}
			if (auxiliary[aux].key != "")
			{
				auxNode.attributes["KEY"] =  auxiliary[aux].key;
			}
			if (auxiliary[aux].display_name != "")
			{
				auxNode.attributes["DISPLAY_NAME"] = auxiliary[aux].display_name;
			}
			if (auxiliary[aux].active != "")
			{
				auxNode.attributes["ACTIVE"] = auxiliary[aux].active;
			}

			JandyNode.appendChild(auxNode);
		}
		return JandyNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "JandyIO";
	}	
	public function getName():String {
		return "JandyIO";
	}
	public function getData():Object {
		return {auxiliary:auxiliary, dataObject:this};
	}
	public function setData(newData:Object):Void{
		auxiliary = newData.auxiliary;
	}
	
	public function setXML(newData:XMLNode):Void {
		auxiliary = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) 
		{
			var newAuxiliary = new Object();
			newAuxiliary.name = "";
			newAuxiliary.key = "";
			newAuxiliary.display_name = "";
			newAuxiliary.active = "Y";
			newAuxiliary.node = newData.childNodes[child].nodeName;
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newAuxiliary.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined)
			{
				newAuxiliary.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) 
			{
				newAuxiliary.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined)
			{
				newAuxiliary.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			auxiliary.push(newAuxiliary);
		}
	}
}
