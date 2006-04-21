class Objects.Client.Apps_Bar extends Objects.BaseElement {
	private var icons:Array;
	private var treeNode:XMLNode;
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var icon in icons) {
			if (icons[icon].isValid() != "ok" ){
				flag = "error";
				appendValidationMsg("Icon " + icons[icon].name + " is invalid");
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.appsbar";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "appsBar");
		for (var icon = 0; icon < icons.length; icon++) {
			newNode.appendChild(icons[icon].toXML());
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		for (var icon = 0; icon < icons.length; icon++) {
			newNode.appendChild(icons[icon].toTree());
		}
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "ClientApps_Bar";
	}
	public function getName():String {
		return "Apps Bar";
	}
	public function getData():Object {
		return {icons:icons, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		icons = new Array();
		if (newData.nodeName == "appsBar") {
			for (var child =0; child< newData.childNodes.length; child++) {
				var newIcon = new Objects.Client.Icon();
				newIcon.setXML(newData.childNodes[child]);
				newIcon.id = _global.formDepth++;
				icons.push(newIcon);
			}
		} else {
			trace("Error, received " + newData.nodeName + ", was expecting appsBar");
		}
	}
	public function setData(newData:Object):Void {
		_global.left_tree.setIsOpen(treeNode, false);
		//process new icons
		var newIcons = new Array();
		for (var index in newData.icons) {
			if (newData.icons[index].id == undefined) {
				newIcons.push({name:newData.icons[index].name});
			}
		}
		for (var icon in icons) {
			var found = false;
			for (var index in newData.icons) {
				if (icons[icon].id == newData.icons[index].id) {
					icons[icon].name = newData.icons[index].name;
					found = true;
				}
			}
			if (found == false) {
				icons[icon].deleteSelf();
				icons.splice(parseInt(icon), 1);
			}
		}
		for (var newIcon in newIcons) {
			var newNode = new XMLNode(1, "icon");
			newNode.attributes["name"] = newIcons[newIcon].name;
			var newIcon = new Objects.Client.Icon();
			newIcon.setXML(newNode);
			newIcon.id = _global.formDepth++;
			icons.push(newIcon);
		}
		//sort according to desired order
		newIcons = new Array();
		for (var newIcon = 0; newIcon < newData.icons.length; newIcon++) {			
			for (var icon = 0; icon < icons.length; icon++) {
				if (newData.icons[newIcon].name == icons[icon].name) {
					newIcons.push(icons[icon]);
				}
			}
		}
		icons = newIcons;
		var treeLength = treeNode.childNodes.length;
		for(var child = treeLength-1; child > -1;child--){
			treeNode.childNodes[child].removeNode();
		}
		for(var icon = 0; icon<icons.length;icon++){
			treeNode.appendChild(icons[icon].toTree());
		}
		_global.left_tree.setIsOpen(treeNode, true);
	}
	public function getIcons():Array{
		usedIcons = new Array();
		for (var icon in icons) {
			if ((icons[icon].icon != "") && (icons[icon].icon != undefined)) {
				addIcon(icons[icon].icon);
			}
		}
		return usedIcons;
	}
}
