class Objects.Client.Control extends Objects.BaseElement {
	private var type:String;
	private var rows:Array;
	private var treeNode:XMLNode;
	public function deleteSelf(){
		treeNode.removeNode();
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var row in rows){
			for (var item in rows[row].childNodes)
			{
				switch ( rows[row].childNodes[item].attributes["type"]) {
					case "slider" :
						if((rows[row].childNodes[item].attributes["width"] == "")||(rows[row].childNodes[item].attributes["width"] == undefined)){
							flag = "warning";
							appendValidationMsg("Slider:Width is empty");
						}
						break;
					case "button" :
						if((rows[row].childNodes[item].attributes["label"] == "")||(rows[row].childNodes[item].attributes["label"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Label is empty");
						}
						if((rows[row].childNodes[item].attributes["icon"] == "")||(rows[row].childNodes[item].attributes["icon"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Icon is empty");
						}
						if((rows[row].childNodes[item].attributes["extra"] == "")||(rows[row].childNodes[item].attributes["extra"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Extra is empty");
						}
						/*if((rows[row].childNodes[item].attributes["extra2"] == "")||(rows[row].childNodes[item].attributes["extra2"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Extra2 is empty");
						}
						if((rows[row].childNodes[item].attributes["extra3"] == "")||(rows[row].childNodes[item].attributes["extra3"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Extra3 is empty");
						}*/
						if((rows[row].childNodes[item].attributes["width"] == "")||(rows[row].childNodes[item].attributes["width"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Width is empty");
						}
						if((rows[row].childNodes[item].attributes["command"] == "")||(rows[row].childNodes[item].attributes["command"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Command is empty");
						}
						if((rows[row].childNodes[item].attributes["repeatRate"] == "")||(rows[row].childNodes[item].attributes["repeatRate"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:RepeatRate is empty");
						}
						if((rows[row].childNodes[item].attributes["showOn"] == "")||(rows[row].childNodes[item].attributes["showOn"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:ShowOn is empty");
						}
						break;
					case "icon" :
						if((rows[row].childNodes[item].attributes["icon"] == "")||(rows[row].childNodes[item].attributes["icon"] == undefined)){
							flag = "warning";
							appendValidationMsg("Icon is empty");
						}
						if((rows[row].childNodes[item].attributes["commands"] == "")||(rows[row].childNodes[item].attributes["commands"] == undefined)){
							flag = "warning";
							appendValidationMsg("Commands are empty");
						}
						if((rows[row].childNodes[item].attributes["key"] == "")||(rows[row].childNodes[item].attributes["key"] == undefined)){
							flag = "warning";
							appendValidationMsg("Key is empty");
						}
						break;
					case "object" :
						if((rows[row].childNodes[item].attributes["src"] == "")||(rows[row].childNodes[item].attributes["src"] == undefined)){
							flag = "warning";
							appendValidationMsg("Source is empty");
						}
						if((rows[row].childNodes[item].attributes["key"] == "")||(rows[row].childNodes[item].attributes["key"] == undefined)){
							flag = "warning";
							appendValidationMsg("Key is empty");
						}
						if((rows[row].childNodes[item].attributes["width"] == "")||(rows[row].childNodes[item].attributes["width"] == undefined)){
							flag = "warning";
							appendValidationMsg("Width is empty");
						}
						if((rows[row].childNodes[item].attributes["height"] == "")||(rows[row].childNodes[item].attributes["height"] == undefined)){
							flag = "warning";
							appendValidationMsg("Height is empty");
						}
						if((rows[row].childNodes[item].attributes["show"] == "")||(rows[row].childNodes[item].attributes["show"] == undefined)){
							flag = "warning";
							appendValidationMsg("Show is empty");
						}
						if((rows[row].childNodes[item].attributes["hide"] == "")||(rows[row].childNodes[item].attributes["hide"] == undefined)){
							flag = "warning";
							appendValidationMsg("Hide is empty");
						}
						break;
				}
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.control";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1, "control");
		newNode.attributes["type"] = type;
		for (var row in rows) {
			newNode.appendChild(rows[row]);
		}
		return newNode;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Control");
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "ClientControl";
	}
	public function getName():String {
		return "Control : " + type;
	}
	public function getData():Object {
		var newNode = new XMLNode(1, "control");
		newNode.attributes["type"] = type;
		for (var row in rows) {
			newNode.appendChild(rows[row]);
		}
		return {controlTypeData:newNode, type:type, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		rows = new Array();
		if (newData.nodeName == "control") {
			type = newData.attributes["type"];
			for (var child in newData.childNodes) {
				rows.push(newData.childNodes[child]);
			}
		} else {
			mdm.Dialogs.prompt("Error, found " + newData.nodeName + ", was expecting control");
		}
	}
	public function setData(newData:Object):Void {
		newData.controlTypeData.attributes.type = newData.type;
		//rows = newData.rows;
		setXML(newData.controlTypeData);
	}
	public function getUsedKeys():Array{
		usedKeys = new Array();
		for (var item in rows) {
			if ((rows[item].attributes["key"] != "") && (rows[item].attributes["key"] != undefined)) {
				addUsedKey(rows[item].attributes["key"]);
			}
		}
		return usedKeys;
	}
	public function getIcons():Array{
		usedIcons = new Array();
		for (var row in rows) {
			//mdm.Dialogs.prompt(rows[row].toString());
			var tempArray = rows[row].childNodes;
			for(var item in tempArray)
			{
				if ((tempArray[item].attributes["icons"] != "") && (tempArray[item].attributes["icons"] != undefined)) {
					var tempIcons = tempArray[item].attributes["icons"].split(",");
					for(var tempIcon in tempIcons){
						if(tempIcons[tempIcon].length){
							addIcon(tempIcons[tempIcon]);
						}
					}
				} else if ((tempArray[item].attributes["icon"] != "") && (tempArray[item].attributes["icon"] != undefined)) {
					addIcon(tempArray[item].attributes["icon"]);
				}
			}
		}
		return usedIcons;
	}
}
