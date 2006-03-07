class Objects.Client.Property extends Objects.BaseElement{
	private var zones:Array;
	private var treeNode:XMLNode;		
	public function isValid():Boolean {
		return true;
	}
	public function getForm():String {
		return "forms.project.client.property";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"property");
		for(var zone in zones){
			newNode.appendChild(zones[zone].toXML());
		}
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,"Property");
		newNode.object = this;
		for(var zone in zones){
			newNode.appendChild(zones[zone].toTree());
		}
		treeNode = newNode;			
		return newNode;
	}
	public function getKey():String{
		return "Property";
	}
	public function getName():String{
		return "Property";
	}
	public function getData():Object{
		return {zones:zones, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void{
		zones = new Array();
		if(newData.nodeName == "property"){
			for(var child in newData.childNodes){
				var newZone = new Objects.Client.Zone();
				newZone.setXML(newData.childNodes[child]);
				newZone.id = _global.formDepth++;				
				zones.push(newZone);
			}
		}
		else{
			trace("Error, found "+ newData.nodeName +", was expecting property");
		}
	}
	public function setData(newData:Object):Void{
		_global.left_tree.setIsOpen(treeNode, false);		
		//Process new zones
		var newZones = new Array();
		for (var index in newData.zones) {
			trace(newData.zones[index].id);
			if (newData.zones[index].id == undefined) {
				newZones.push({name:newData.zones[index].name});
			}
		}
		for (var zone in zones) {
			var found = false;
			for (var index in newData.zones) {
				if (zones[zone].id == newData.zones[index].id) {
					found = true;
				}
			}
			if (found == false) {
				zones[zone].deleteSelf();
				zones.splice(parseInt(zone), 1);
			}
		}
		for (var newZone in newZones) {
			var newNode = new XMLNode(1, "zone");
			newNode.attributes["name"] = newZones[newZone].name;
			var newZone = new Objects.Client.Zone();
			newZone.id = _global.formDepth++;
			newZone.setXML(newNode);
			treeNode.appendChild(newZone.toTree());			
			zones.push(newZone);
		}
		_global.left_tree.setIsOpen(treeNode, true);		
	}
}
