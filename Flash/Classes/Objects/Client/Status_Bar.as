class Objects.Client.Status_Bar extends Objects.BaseElement{
	private var groups:Array;
	private var treeNode:XMLNode;		
	public function isValid():Boolean {
		var flag = true;
		for(var group in groups){
			if(!groups[group].isValid()){
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.statusbar";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"statusBar")
		for(var group in groups){
			newNode.appendChild(groups[group].toXML());
		}
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		for(var group in groups){
			newNode.appendChild(groups[group].toTree());
		}
		newNode.object = this;
		treeNode = newNode;			
		return newNode;
	}
	public function getKey():String{
		return "StatusBar";
	}	
	public function getName():String{
		return "Status Bar";
	}
	public function getData():Object{
		return {groups:groups, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void{
		groups = new Array();
		if(newData.nodeName = "statusBar"){
			for(var child in newData.childNodes){
				var newGroup = new Objects.Client.StatusBarGroup();
				newGroup.setXML(newData.childNodes[child]);
				newGroup.id = _global.formDepth++;
				groups.push(newGroup);
			}
		}
		else{
			trace("Error, received "+newData.nodeName+", was expecting statusBar");
		}
	}
	public function setData(newData:Object):Void{
		_global.left_tree.setIsOpen(treeNode, false);
		/*Find new groups*/
		var newGroups = new Array();
		for (var index in newData.groups) {
			if (newData.groups[index].id == undefined) {
				newGroups.push({name:newData.groups[index].name});
			}
		}
		/*Delete missing groups*/
		for (var group in groups) {
			var found = false;
			for (var index in newData.groups) {
				if (groups[group].id == newData.groups[index].id) {
					found = true;
				}
			}
			if (found == false) {
				groups[group].deleteSelf();
				groups.splice(parseInt(group), 1);
			}
		}
		/*Create new Group objects*/
		for (var newGroup in newGroups) {
			var newNode = new XMLNode(1, "group");
			newNode.attributes["name"] = newGroups[newGroup].name;
			var newGroup = new Objects.Client.StatusBarGroup();
			newGroup.setXML(newNode);
			newGroup.id = _global.formDepth++;
			treeNode.appendChild(newGroup.toTree());			
			groups.push(newGroup);
		}
		_global.left_tree.setIsOpen(treeNode, true);		
	}
}
