class Objects.Client.Logging extends Objects.BaseElement {
	private var groups:Array;
	private var treeNode:XMLNode;
	private var attributes:Array;
	private var attributeGroups = ["window", "tabs"];
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (groups.length == 0) {
			flag = "empty";
			appendValidationMsg("No Logging Groups are defined");
		}
		for (var group in groups) {
			if (groups[group].isValid()!="ok") {
				flag = "warning";
				appendValidationMsg("Group:" + groups[group].attributes["name"] + " is in error");
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.logging";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "logging");
		for (var attribute in attributes) {
			newNode.attributes[attributes[attribute].name] = attributes[attribute].value;
		}
		for (var group = 0; group < groups.length; group++) {
			newNode.appendChild(groups[group].toXML());
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		for (var group = 0; group < groups.length; group++) {
			newNode.appendChild(groups[group].toTree());
		}
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "Logging";
	}
	public function getName():String {
		return "Logging";
	}
	public function getData():Object {
		return {groups:groups, dataObject:this};
	}
	public function getAttributes():Array {
		return attributes;
	}
	public function setAttributes(newAttributes:Array) {
		attributes = newAttributes;
	}
	public function setXML(newData:XMLNode):Void {
		groups = new Array();
		attributes = new Array();
		if (newData.nodeName = "logging") {
			for (var attribute in newData.attributes) {
				attributes.push({name:attribute, value:newData.attributes[attribute]});
			}
			for (var child = 0; child < newData.childNodes.length; child++) {
				var newGroup = new Objects.Client.LoggingGroup();
				newGroup.setXML(newData.childNodes[child]);
				newGroup.id = _global.formDepth++;
				groups.push(newGroup);
			}
		} else {
			trace("Error, received " + newData.nodeName + ", was expecting logging");
		}
	}
	public function setData(newData:Object):Void {
		_global.left_tree.setIsOpen(treeNode, false);
		//process new groups
		var newGroups = new Array();
		for (var index in newData.groups) {
			if (newData.groups[index].id == undefined) {
				newGroups.push({name:newData.groups[index].name});
			}
		}
		for (var group in groups) {
			var found = false;
			for (var index in newData.groups) {
				if (groups[group].id == newData.groups[index].id) {
					groups[group].name = newData.groups[index].name;
					found = true;
				}
			}
			if (found == false) {
				groups[group].deleteSelf();
				groups.splice(parseInt(group), 1);
			}
		}
		for (var newGroup in newGroups) {
			var newNode = new XMLNode(1, "group");
			newNode.attributes["name"] = newGroups[newGroup].name;
			var newGroup = new Objects.Client.LoggingGroup();
			newGroup.id = _global.formDepth++;
			newGroup.setXML(newNode);
			groups.push(newGroup);
		}
		//sort according to desired order
		newGroups = new Array();
		for (var newGroup = 0; newGroup < newData.groups.length; newGroup++) {
			for (var group = 0; group < groups.length; group++) {
				if (newData.groups[newGroup].name == groups[group].name) {
					newGroups.push(groups[group]);
				}
			}
		}
		groups = newGroups;
		var treeLength = treeNode.childNodes.length;
		for(var child = treeLength-1; child > -1;child--){
			treeNode.childNodes[child].removeNode();
		}
		for(var group = 0; group<groups.length;group++){
			treeNode.appendChild(groups[group].toTree());
		}
		_global.left_tree.setIsOpen(treeNode, true);
	}
	public function getUsedKeys():Array{
		for (var group in groups) {
			usedKeys.concat(groups[group].getUsedKeys());
		}
		return super.getUsedKeys();
	}
	public function getIcons():Array{
		for (var group in groups) {
			icons.concat(groups[group].getIcons());
		}
		return super.getIcons();
	}
}
