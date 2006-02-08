class Objects.Client.Status_Bar extends Objects.BaseElement{
	private var groups:Array;
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
		return newNode;
	}
	public function getName():String{
		return "Status Bar";
	}
	public function getData():Object{
		return new Object({groups:groups});
	}
	public function setXML(newData:XMLNode):Void{
		groups = new Array();
		if(newData.nodeName = "statusBar"){
			for(var child in newData.childNodes){
				var newGroup = new Objects.Client.StatusBarGroup();
				newGroup.setXML(newData.childNodes[child]);
				groups.push(newGroup);
			}
		}
		else{
			trace("Error, received "+newData.nodeName+", was expecting statusBar");
		}
	}
	public function setData(newData:Object):Void{
		//process new groups
		var newGroups = new Array();
		for (var index in newData.groups) {
			var found = false;
			for (var group in groups) {
				if (groups[group].name == newData.groups[index].name) {
					found = true;
				}
			}
			if (found == false) {
				newGroups.push({name:newData.groups[index].name});
			}
		}
		var deletedGroups = new Array();
		for (var group in groups) {
			var found = false;
			for (var index in newData.groups) {
				if (groups[group].name == newData.groups[index].name) {
					found = true;
				}
			}
			if (found == false) {
				groups.splice(parseInt(group), 1);
			}
		}
		for (var newGroup in newGroups) {
			var newNode = new XMLNode(1, "group");
			newNode.attributes["name"] = newGroups[newGroup].name;
			var newGroup = new Objects.Client.StatusBarGroup();
			newGroup.setXML(newNode);
			groups.push(newGroup);
		}
	}
}
