class Objects.Client.Window extends Objects.BaseElement {
	private var tabs:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var tab in tabs) {
			if (!tabs[tab].isValid()) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.window";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "window");
		for (var tab in tabs) {
			newNode.appendChild(tabs[tab].toXML());
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		for (var tab in tabs) {
			newNode.appendChild(tabs[tab].toTree());
		}
		newNode.object = this;
		_global.workflow.addNode("ClientWindow",newNode);
		return newNode;
	}
	public function getName():String {
		return "Window";
	}
	public function getData():Object {
		return new Object({tabs:tabs});
	}
	public function setXML(newData:XMLNode):Void {
		if(newData.nodeName == "window"){
			tabs = new Array();
			for(var child in newData.childNodes){
				var newTab = new Objects.Client.Tab();
				newTab.setXML(newData.childNodes[child]);
				tabs.push(newTab);
			}
		} else{
			trace("Error, found "+ newData.nodeName+", was expecting window");
		}
	}
	public function setData(newData:Object):Void {
		//process new tabs
		var newTabs = new Array();
		for (var index in newData.tabs) {
			var found = false;
			for (var tab in tabs) {
				if (tabs[tab].name == newData.tabs[index].name) {
					found = true;
				}
			}
			if (found == false) {
				newTabs.push({name:newData.tabs[index].name});
			}
		}
		var deletedTabs = new Array();
		for (var tab in tabs) {
			var found = false;
			for (var index in newData.tabs) {
				if (tabs[tab].name == newData.tabs[index].name) {
					found = true;
				}
			}
			if (found == false) {
				tabs.splice(parseInt(tab), 1);
			}
		}
		for (var newTab in newTabs) {
			var newNode = new XMLNode(1, "tab");
			newNode.attributes["name"] = newTabs[newTab].name;
			var newTab = new Objects.Client.Tab();
			newTab.setXML(newNode);
			tabs.push(newTab);
		}
		//sort according to desired order
		newTabs = new Array();
		for(var newTab in newData.tabs){
			for(var tab in tabs){
				if(newData.tabs[newTab].name == tabs[tab].name){
					newTabs.push(tabs[tab]);
				}
			}
		}
		tabs = newTabs;
	}
}
