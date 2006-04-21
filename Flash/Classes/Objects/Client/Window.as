class Objects.Client.Window extends Objects.BaseElement {
	private var tabs:Array;
	private var treeNode:XMLNode;
	private var attributes:Array;
	private var attributeGroups = ["window", "tabs"];
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (tabs.length == 0) {
			flag = "empty";
			appendValidationMsg("No Tabs are defined");
		}
		/*for (var tab in tabs) {
			if (tabs[tab].isValid()!="ok") {
				flag = "warning";
				appendValidationMsg(tabs[tab].attributes["name"] + " is invalid");
			}
		}*/
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.window";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "window");
		for (var attribute in attributes) {
			newNode.attributes[attributes[attribute].name] = attributes[attribute].value;
		}
		for (var tab = 0; tab < tabs.length; tab++) {			
			newNode.appendChild(tabs[tab].toXML());
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		for (var tab = 0; tab < tabs.length; tab++) {			
			newNode.appendChild(tabs[tab].toTree());
		}
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "ClientWindow";
	}
	public function getName():String {
		return "Room Control Panel";
	}
	public function getData():Object {
		return {tabs:tabs, dataObject:this};
	}
	public function getAttributes():Array {
		return attributes;
	}
	public function setAttributes(newAttributes:Array) {
		attributes = newAttributes;
	}
	public function setXML(newData:XMLNode):Void {
		attributes = new Array();
		if (newData.nodeName == "window") {
			for (var attribute in newData.attributes) {
				attributes.push({name:attribute, value:newData.attributes[attribute]});
			}
			tabs = new Array();
			for (var child = 0; child < newData.childNodes.length; child++) {			
				var newTab = new Objects.Client.Tab();
				newTab.setXML(newData.childNodes[child]);
				newTab.id = _global.formDepth++;
				tabs.push(newTab);
			}
		} else {
			trace("Error, found " + newData.nodeName + ", was expecting window");
		}
	}
	public function setData(newData:Object):Void {
		_global.left_tree.setIsOpen(treeNode, false);
		//process new tabs
		var newTabs = new Array();
		for (var index in newData.tabs) {
			if (newData.tabs[index].id == undefined) {
				newData.tabs[index].id = _global.formDepth++;
				newTabs.push({name:newData.tabs[index].name, id:newData.tabs[index].id});
			}
		}
		for (var tab in tabs) {
			var found = false;
			for (var index in newData.tabs) {
				if (tabs[tab].id == newData.tabs[index].id) {
					tabs[tab].name = newData.tabs[index].name;
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
			newNode.attributes["name"] = newTabs[newTab].name;
			var Tab = new Objects.Client.Tab();
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
	public function getUsedKeys():Array{
		usedKeys = new Array();
		for (var tab in tabs) {
			usedKeys=usedKeys.concat(tabs[tab].getUsedKeys());
		}
		return usedKeys;
	}
	public function getIcons():Array{
		usedIcons = new Array();
		for (var tab in tabs) {
			usedIcons = usedIcons.concat(tabs[tab].getIcons());
		}
		return usedIcons;
	}
}
