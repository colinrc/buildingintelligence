class Objects.Client.Window extends Objects.BaseElement {
	private var tabs:Array;
	private var treeNode:XMLNode;		
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
		treeNode = newNode;			
		return newNode;
	}
	public function getKey():String{
		return "ClientWindow";
	}	
	public function getName():String {
		return "Window";
	}
	public function getData():Object {
		return {tabs:tabs,dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		if(newData.nodeName == "window"){
			tabs = new Array();
			for(var child in newData.childNodes){
				var newTab = new Objects.Client.Tab();
				newTab.setXML(newData.childNodes[child]);
				newTab.id = _global.formDepth++;
				tabs.push(newTab);
			}
		} else{
			trace("Error, found "+ newData.nodeName+", was expecting window");
		}
	}
	public function setData(newData:Object):Void {
		_global.left_tree.setIsOpen(treeNode, false);		
		//process new tabs
		var newTabs = new Array();
		for (var index in newData.tabs) {
			if (newData.tabs[index].id == undefined) {
				newTabs.push({name:newData.tabs[index].name});
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
			Tab.id = _global.formDepth++;			
			treeNode.appendChild(Tab.toTree());			
			tabs.push(Tab);
		}
		//sort according to desired order
		/*newTabs = new Array();
		for(var newTab in newData.tabs){
			for(var tab in tabs){
				if(newData.tabs[newTab].id == tabs[tab].id){
					newTabs.push(tabs[tab]);
					break;
				}
			}
		}
		tabs = newTabs;*/
		_global.left_tree.setIsOpen(treeNode, true);		
	}
}
