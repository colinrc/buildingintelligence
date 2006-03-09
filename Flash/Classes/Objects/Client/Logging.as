class Objects.Client.Logging extends Objects.BaseElement{
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
		return "forms.project.client.logging";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"logging")
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
		return "Logging";
	}
	public function getName():String{
		return "Logging";
	}
	public function getData():Object{
		return {groups:groups, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void{
		groups = new Array();
		if(newData.nodeName = "logging"){
			for(var child in newData.childNodes){
				var newGroup = new Objects.Client.LoggingGroup();
				newGroup.setXML(newData.childNodes[child]);
				newGroup.id = _global.formDepth++;
				groups.push(newGroup);
			}
		}
		else{
			trace("Error, received "+newData.nodeName+", was expecting logging");
		}
	}
	public function setData(newData:Object):Void{
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
			treeNode.appendChild(newGroup.toTree());				
			groups.push(newGroup);
		}
		_global.left_tree.setIsOpen(treeNode, true);		
	}
}
