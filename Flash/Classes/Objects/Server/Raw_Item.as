class Objects.Server.Raw_Item extends Objects.BaseElement {
	var raws:Array;
	var catalogue:String;
	var prefix:String;
	public function isValid():Boolean {
		var flag = true;
		if ((catalogue == undefined) || (catalogue == "")) {
			flag = false;
		}
		for (var raw in raws) {
			if (!raws[raw].isValid()) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.raw_item";
	}
	public function toXML():XMLNode {
		var newRaw_Item = new XMLNode(1, "RAW_ITEMS");
		if (catalogue != "") {
			newRaw_Item.attributes["CATALOGUE"] = catalogue;
		}
		if (prefix != "") {
			newRaw_Item.attributes["PREFIX"] = prefix;
		}
		for (var raw in raws) {
			newRaw_Item.appendChild(raws[raw].toXML());
		}
		return newRaw_Item;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		for (var raw in raws) {
			newNode.appendChild(raws[raw].toTree());
		}
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return catalogue;
	}
	public function getData():Object {
		return new Object({raws:raws, catalogue:catalogue, prefix:prefix});
	}
	public function setData(newData:Object) {
		catalogue = newData.catalogue;
		prefix = newData.prefix;
		//process raw changes
		var newRaws = new Array();
		for (var index in newData.raws) {
			var found = false;
			for (var raw_item in raws) {
				if (raws[raw_item].command == newData.raws[index].command) {
					found = true;
				}
			}
			if (found == false) {
				newRaws.push({command:newData.raws[index].command});
			}
		}
		var deletedRaws = new Array();
		for (var raw_item in raws) {
			var found = false;
			for (var index in newData.raws) {
				if (raws[raw_item].command == newData.raws[index].command) {
					found = true;
				}
			}
			if (found == false) {
				raws.splice(parseInt(raw_item), 1);
			}
		}
		for (var newRaw in newRaws) {
			var newNode = new XMLNode(1, "RAW");
			newNode.attributes["COMMAND"] = newRaws[newRaw].command;
			var newRaw = new Objects.Server.Raw();
			newRaw.setXML(newNode);
			raws.push(newRaw);
		}
	}
	public function setXML(newData:XMLNode):Void {
		catalogue = "";
		prefix = "";
		if (newData.attributes["CATALOGUE"] != undefined) {
			catalogue = newData.attributes["CATALOGUE"];
		}
		if (newData.attributes["PREFIX"] != undefined) {
			prefix = newData.attributes["PREFIX"];
		}
		raws = new Array();
		for (var child in newData.childNodes) {
			var tempRaw = new Objects.Server.Raw();
			tempRaw.setXML(newData.childNodes[child]);
			raws.push(tempRaw);
		}
	}
}
