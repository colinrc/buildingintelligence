class Objects.Client.Calendar extends Objects.BaseElement {
	private var attributes:Array;
	private var treeNode:XMLNode;
	private var tabs:Array;
	private var attributeGroups = ["tabs"];
	public function deleteSelf() {
		treeNode.removeNode();
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (tabs.length == 0) {
			flag = "empty";
			appendValidationMsg("No Calendar Tabs are defined");
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.calendar";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "calendar");
		for (var attribute in attributes) {
			newNode.attributes[attributes[attribute].name] = attributes[attribute].value;
		}
		/*Categories are hard coded for time being*/
		var newCategories = new XMLNode(1,"categories");
		var newCategory = new XMLNode(1,"category");
		newCategory.attributes.name = "Birthday";
		newCategory.attributes.icon = "light-bulb";
		newCategories.appendChild(newCategory);
		newCategory = new XMLNode(1,"category");
		newCategory.attributes.name = "Appointment";
		newCategory.attributes.icon = "videocamera";
		newCategories.appendChild(newCategory);
		newCategory = new XMLNode(1,"category");
		newCategory.attributes.name = "Reminder";
		newCategory.attributes.icon = "fireplace";
		newCategories.appendChild(newCategory);
		newNode.appendChild(newCategories);
		var newWindowNode = new XMLNode(1,"window");
		for (var tab = 0; tab < tabs.length; tab++) {
			newWindowNode.appendChild(tabs[tab].toXML());
		}
		newNode.appendChild(newWindowNode);
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getKey());
		newNode.object = this;
		for (var tab = 0; tab < tabs.length; tab++) {
			newNode.appendChild(tabs[tab].toTree());
		}
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "Calendar";
	}
	public function getName():String {
		return "Calendar";
	}
	public function getData():Object {
		return {tabs:tabs, dataObject:this};
	}
	public function setData(newData:Object):Void {
		_global.left_tree.setIsOpen(treeNode, false);
		//process new tabs
		var newTabs = new Array();
		for (var index in newData.tabs) {
			if (newData.tabs[index].id == undefined) {
				newData.tabs[index].id = _global.formDepth++;
				newTabs.push({label:newData.tabs[index].label, id:newData.tabs[index].id});
			}
		}
		for (var tab in tabs) {
			var found = false;
			for (var index in newData.tabs) {
				if (tabs[tab].id == newData.tabs[index].id) {
					tabs[tab].label = newData.tabs[index].label;
					found = true;
					break;
				}
			}
			if (found == false) {
				tabs[tab].deleteSelf();
				tabs.splice(parseInt(tab), 1);
			}
		}
		for (var newTab in newTabs) {
			var newNode = new XMLNode(1, "tab");
			newNode.attributes["label"] = newTabs[newTab].label;
			var Tab = new Objects.Client.CalendarTab();
			Tab.setXML(newNode);
			Tab.id = newTabs[newTab].id;
			tabs.push(Tab);
		}
		//sort according to desired order
		newTabs = new Array();
		for (var newTab = 0; newTab < newData.tabs.length; newTab++) {
			for (var tab = 0; tab < tabs.length; tab++) {
				if (newData.tabs[newTab].id == tabs[tab].id) {
					newTabs.push(tabs[tab]);
					break;
				}
			}
		}
		tabs = newTabs;
		var treeLength = treeNode.childNodes.length;
		for(var child = treeLength-1; child > -1;child--){
			treeNode.childNodes[child].removeNode();
		}
		for(var tab = 0; tab<tabs.length;tab++){
			treeNode.appendChild(tabs[tab].toTree());
		}
		_global.left_tree.setIsOpen(treeNode, true);
	}
	public function getAttributes():Array {
		return attributes;
	}
	public function setAttributes(newAttributes:Array) {
		attributes = newAttributes;
	}
	public function setXML(newData:XMLNode):Void {
		tabs = new Array();
		attributes = new Array();
		if (newData.nodeName = "calendar") {
			for (var attribute in newData.attributes) {
				attributes.push({name:attribute, value:newData.attributes[attribute]});
			}
			for (var child = 0; child < newData.childNodes.length; child++) {
				var newTab = new Objects.Client.CalendarTab();
				newTab.setXML(newData.childNodes[child]);
				newTab.id = _global.formDepth++;
				tabs.push(newTab);
			}
		} else {
			trace("Error, received " + newData.nodeName + ", was expecting calendar");
		}
	}
	public function getUsedKeys():Array{
		for (var tab in tabs) {
			usedKeys.concat(tabs[tab].getUsedKeys());
		}
		return super.getUsedKeys();
	}
	public function getIcons():Array{
		for (var tab in tabs) {
			icons.concat(tabs[tab].getIcons());
		}
		return super.getIcons();
	}
}
