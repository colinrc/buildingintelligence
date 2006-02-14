class Objects.Client.Apps_Bar extends Objects.BaseElement{
	private var icons:Array;
	public function isValid():Boolean {
		var flag = true;
		for(var icon in icons){
			if(!icons[icon].isValid()){
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.appsbar";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"appsBar")
		for(var icon in icons){
			newNode.appendChild(icons[icon].toXML());
		}		
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		for(var icon in icons){
			newNode.appendChild(icons[icon].toTree());
		}
		newNode.object = this;
		_global.workflow.addNode("ClientApps_Bar",newNode);
		return newNode;
	}
	public function getName():String{
		return "Apps Bar";
	}
	public function getData():Object{
		return new Object({icons:icons});
	}
	public function setXML(newData:XMLNode):Void{
		icons = new Array();
		if(newData.nodeName == "appsBar"){
			for(var child in newData.childNodes){
				var newIcon = new Objects.Client.Icon();
				newIcon.setXML(newData.childNodes[child]);
				icons.push(newIcon);
			}
		}
		else{
			trace("Error, received "+newData.nodeName+", was expecting appsBar");
		}
	}
	public function setData(newData:Object):Void{
		//process new icons
		var newIcons = new Array();
		for (var index in newData.icons) {
			var found = false;
			for (var icon in icons) {
				if (icons[icon].name == newData.icons[index].name) {
					found = true;
				}
			}
			if (found == false) {
				newIcons.push({name:newData.icons[index].name});
			}
		}
		var deletedIcons = new Array();
		for (var icon in icons) {
			var found = false;
			for (var index in newData.icons) {
				if (icons[icon].name == newData.icons[index].name) {
					found = true;
				}
			}
			if (found == false) {
				icons.splice(parseInt(icon), 1);
			}
		}
		for (var newIcon in newIcons) {
			var newNode = new XMLNode(1, "icon");
			newNode.attributes["name"] = newIcons[newIcon].name;
			var newIcon = new Objects.Client.Icon();
			newIcon.setXML(newNode);
			icons.push(newIcon);
		}
		//sort according to desired order
		newIcons = new Array();
		for(var newIcon in newData.icons){
			for(var icon in icons){
				if(newData.icons[newIcon].name == icons[icon].name){
					newIcons.push(icons[icon]);
				}
			}
		}
		icons = newIcons;
	}
}
