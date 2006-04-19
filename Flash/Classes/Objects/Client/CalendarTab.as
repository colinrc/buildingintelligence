class Objects.Client.CalendarTab extends Objects.BaseElement {
	private var zones:Array;
	private var label:String;
	private var icon:String;
	private var view:String;
	private var macro:String;
	private var treeNode:XMLNode;
	public function deleteSelf(){
		treeNode.removeNode();
	}		
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		if (zones.length == 0) {
			flag = "empty";
			appendValidationMsg("No Zones are defined");
		}
		if (label == null || label == "") {
			flag = "warning";
			appendValidationMsg("Label is missing");
		}
		if (icon == null || icon == "") {
			flag = "warning";
			appendValidationMsg("Icon is missing");
		}
		if (view == null || view == "") {
			flag = "warning";
			appendValidationMsg("View is missing");
		}
		if (macro == null || macro == "") {
			flag = "warning";
			appendValidationMsg("Macro is missing");
		}
		for (var zone in zones) {
			if (zones[zone].attributes["label"] == null || zones[zone].attributes["label"] == "") {
				flag = "warning";
				appendValidationMsg("Zone Name is missing");
			}
			if (zones[zone].attributes["key"] == null || zones[zone].attributes["key"] == "") {
				flag = "error";
				appendValidationMsg("Zone Key is missing");
			}
			else {
				if (_global.isKeyValid(zones[zone].attributes["key"]) == false) {
					flag = "error";
					appendValidationMsg("Key has changed and is invalid");
				}
			}
		}
		
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.calendartab";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "tab");
		if(label != "") {
			newNode.attributes["label"] = label;
		}
		if(icon != "") {
			newNode.attributes["icon"] = icon;
		}
		if(view != "") {
			newNode.attributes["view"] = view;
		}
		if(macro !=""){
			newNode.attributes["macro"] = macro;
		}
		for (var zone in zones) {
			newNode.appendChild(zones[zone]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Calendar_Tab");
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String{
		return "Calendar_Tab";
	}
	public function getName():String {
		return label;
	}
	public function getData():Object {
		return {zones:zones, label:label, icon:icon, view:view, macro:macro, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		label = "";
		icon = "";
		view = "";
		macro = "";
		zones = new Array();		
		if(newData.nodeName == "tab"){
			if(newData.attributes["label"] != undefined) {
				label = newData.attributes["label"];
			}
			if(newData.attributes["icon"] != undefined) {
				icon = newData.attributes["icon"];
			}
			if(newData.attributes["view"] != undefined) {
				view = newData.attributes["view"];
			}			
			if(newData.attributes["macro"] != undefined) {
				macro = newData.attributes["macro"];
			}						
			for(var child in newData.childNodes){
				zones.push(newData.childNodes[child]);
			}
		}
		else{
			trace("Error, found "+newData.nodeName+", was expecting tab");
		}
	}
	public function setData(newData:Object):Void {
		zones = newData.zones;
		label = newData.label;
		icon = newData.icon;
		macro = newData.macro;
		view = newData.view;
	}
	public function getUsedKeys():Array{
		for (var zone in zones) {
			if ((zones[zone].attributes["keys"] != "") && (zones[zone].attributes["keys"] != undefined)) {
				addUsedKey(zones[zone].attributes["keys"]);
			}
		}
		return super.getUsedKeys();
	}
	public function getIcons():Array{
		for (var zone in zones) {
			if ((zones[zone].attributes["icon"] != "") && (zones[zone].attributes["icon"] != undefined)) {
				addIcon(zones[zone].attributes["icon"]);
			}
		}
		return super.getIcons();
	}
}
