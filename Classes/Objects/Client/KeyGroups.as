class Objects.Client.KeyGroups extends Objects.BaseElement {
	private var keygroups:Array=new Array();
	private var treeNode:XMLNode;
	public function isValid():String {
		var flag = "ok";
		/*		clearValidationMsg();
		for(var child in apps.childNodes){
		if((apps.childNodes[child].attributes["name"] == undefined)||(apps.childNodes[child].attributes["name"] == "")){
		flag = "warning";
		appendValidationMsg("Label is empty");
		}
		if((apps.childNodes[child].attributes["program"] ==undefined)||(apps.childNodes[child].attributes["program"] =="")){
		flag = "warning";
		appendValidationMsg("Program is empty");
		}
		}*/
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.keygroups";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "keygroups");
		for (var keygroup in keygroups) {
			newNode.appendChild(keygroups[keygroup].toXML());
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		treeNode = newNode;
		newNode.object = this;
		for (var keygroup in keygroups) {
			newNode.appendChild(keygroups[keygroup].toTree());
		}
		return newNode;
	}
	public function getKey():String {
		return "KeyGroups";
	}
	public function getName():String {
		return "Key Groups";
	}
	public function getData():Object {
		var tempKeygroups = new Array();
		for(var index = 0; index < keygroups.length;index++){
			tempKeygroups.push({name:keygroups[index].name,id:keygroups[index].id});
		}
		return {keygroups:tempKeygroups, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		keygroups = new Array();
		if (newData.nodeName == "keygroups") {
			for (var keygroup in newData.childNodes) {
				var KeyGroup = new Objects.Client.KeyGroup();
				KeyGroup.setXML(newData.childNodes[keygroup]);
				KeyGroup.id = _global.formDepth++;
				keygroups.push(KeyGroup);
			}
		} else {
			trace("Error, received " + newData.nodeName + ", was expecting keygroups");
		}
	}
	public function setData(newData:Object):Void {
		//keygroups = newData.keygroups;
		_global.left_tree.setIsOpen(treeNode, false);
		//process new keygroups
		var newKeyGroups = new Array();
		for (var index in newData.keygroups) {
			if (newData.keygroups[index].id == undefined) {
				newData.keygroups[index].id = _global.formDepth++;
				newKeyGroups.push({name:newData.keygroups[index].name, id:newData.keygroups[index].id});
			}
		}
		for (var keygroup in keygroups) {
			var found = false;
			for (var index in newData.keygroups) {
				if (keygroups[keygroup].id == newData.keygroups[index].id) {
					keygroups[keygroup].name = newData.keygroups[index].name;
					found = true;
					break;
				}
			}
			if (found == false) {
				keygroups[keygroup].deleteSelf();
				keygroups.splice(parseInt(keygroup), 1);
			}
		}
		for (var newKeyGroup in newKeyGroups) {
			var newNode = new XMLNode(1, "keygroup");
			newNode.attributes["name"] = newKeyGroups[newKeyGroup].name;
			var KeyGroup = new Objects.Client.KeyGroup();
			KeyGroup.setXML(newNode);
			KeyGroup.id = newKeyGroups[newKeyGroup].id;
			keygroups.push(KeyGroup);
		}
		var treeLength = treeNode.childNodes.length;
		for (var child = treeLength - 1; child > -1; child--) {
			treeNode.childNodes[child].removeNode();
		}
		for (var keygroup = 0; keygroup < keygroups.length; keygroup++) {
			treeNode.appendChild(keygroups[keygroup].toTree());
		}
		_global.left_tree.setIsOpen(treeNode, true);
	}
}
