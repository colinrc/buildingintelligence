class Objects.Client.Property extends Objects.BaseElement{
	private var zones:Array;
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
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		for(var zone in zones){
			newNode.appendChild(zones[zone].toTree());
		}
		return newNode;
	}
	public function getName():String{
		return "Property";
	}
	public function getData():Object{
		return new Object({zones:zones});
	}
	public function setXML(newData:XMLNode):Void{
		zones = new Array();
		if(newData.nodeName == "property"){
			for(var child in newData.childNodes){
				var newZone = new Objects.Client.Zone();
				newZone.setXML(newData.childNodes[child]);
				zones.push(newZone);
			}
		}
		else{
			trace("Error, found "+ newData.nodeName +", was expecting property");
		}
	}
	public function setData(newData:Object):Void{
		//Process new zones
		var newZones = new Array();
		for (var index in newData.zones) {
			var found = false;
			for (var zone in zones) {
				if (zones[zone].name == newData.zones[index].name) {
					found = true;
				}
			}
			if (found == false) {
				newZones.push({name:newData.zones[index].name});
			}
		}
		var deletedZones = new Array();
		for (var zone in zones) {
			var found = false;
			for (var index in newData.zones) {
				if (zones[zone].name == newData.zones[index].name) {
					found = true;
				}
			}
			if (found == false) {
				zones.splice(parseInt(zone), 1);
			}
		}
		for (var newZone in newZones) {
			var newNode = new XMLNode(1, "zone");
			newNode.attributes["name"] = newZones[newZone].name;
			var newZone = new Objects.Client.Zone();
			newZone.setXML(newNode);
			zones.push(newZone);
		}
	}
}
