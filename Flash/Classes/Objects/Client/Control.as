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
		for (var item in rows){
			switch (type) {
				case "slider" :
					if((rows[item].attributes["label"] == "")||(rows[item].attributes["label"] == undefined)){
						flag = "warning";
						appendValidationMsg("Label is invalid");
					}
					if((rows[item].attributes["fontSize"] == "")||(rows[item].attributes["fontSize"] == undefined)){
						flag = "warning";
						appendValidationMsg("Font size is invalid");
					}
					if((rows[item].attributes["fontColour"] == "")||(rows[item].attributes["fontColour"] == undefined)){
						flag = "warning";
						appendValidationMsg("Font colour is invalid");
					}				
					break;
				case "button" :
					if((rows[item].attributes["bgColour"] == "")||(rows[item].attributes["bgColour"] == undefined)){
						flag = "warning";
						appendValidationMsg("Backgroung Colour is invalid");
					}
					if((rows[item].attributes["borderColour"] == "")||(rows[item].attributes["borderColour"] == undefined)){
						flag = "warning";
						appendValidationMsg("Border colour is invalid");
					}
					if((rows[item].attributes["fontColour"] == "")||(rows[item].attributes["fontColour"] == undefined)){
						flag = "warning";
						appendValidationMsg("Font colour is invalid");
					}
					if((rows[item].attributes["labels"] == "")||(rows[item].attributes["labels"] == undefined)){
						flag = "warning";
						appendValidationMsg("Labels are invalid");
					}
					if((rows[item].attributes["commands"] == "")||(rows[item].attributes["commands"] == undefined)){
						flag = "warning";
						appendValidationMsg("Commands are invalid");
					}
					if((rows[item].attributes["width"] == "")||(rows[item].attributes["width"] == undefined)){
						flag = "warning";
						appendValidationMsg("Width is invalid");
					}
					if((rows[item].attributes["key"] == "")||(rows[item].attributes["key"] == undefined)){
						flag = "warning";
						appendValidationMsg("Key is invalid");
					}
					if((rows[item].attributes["fontSize"] == "")||(rows[item].attributes["fontSize"] == undefined)){
						flag = "warning";
						appendValidationMsg("Font size is invalid");
					}
					break;
				case "icon" :
					if((rows[item].attributes["icons"] == "")||(rows[item].attributes["icons"] == undefined)){
						flag = "warning";
						appendValidationMsg("Icons are invalid");
					}
					if((rows[item].attributes["commands"] == "")||(rows[item].attributes["commands"] == undefined)){
						flag = "warning";
						appendValidationMsg("Commands are invalid");
					}
					if((rows[item].attributes["key"] == "")||(rows[item].attributes["key"] == undefined)){
						flag = "warning";
						appendValidationMsg("Key is invalid");
					}
					break;
				case "object" :
					if((rows[item].attributes["src"] == "")||(rows[item].attributes["src"] == undefined)){
						flag = "warning";
						appendValidationMsg("Source is invalid");
					}
					if((rows[item].attributes["key"] == "")||(rows[item].attributes["key"] == undefined)){
						flag = "warning";
						appendValidationMsg("Key is invalid");
					}
					if((rows[item].attributes["width"] == "")||(rows[item].attributes["width"] == undefined)){
						flag = "warning";
						appendValidationMsg("Width is invalid");
					}
					if((rows[item].attributes["height"] == "")||(rows[item].attributes["height"] == undefined)){
						flag = "warning";
						appendValidationMsg("Height is invalid");
					}
					if((rows[item].attributes["show"] == "")||(rows[item].attributes["show"] == undefined)){
						flag = "warning";
						appendValidationMsg("Show is invalid");
					}
					if((rows[item].attributes["hide"] == "")||(rows[item].attributes["hide"] == undefined)){
						flag = "warning";
						appendValidationMsg("Hide is invalid");
					}
					break;
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
		return {rows:rows, type:type, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		rows = new Array();
		if (newData.nodeName == "control") {
			type = newData.attributes["type"];
			for (var child in newData.childNodes) {
				rows.push(newData.childNodes[child]);
			}
		} else {
			trace("Error, found " + newData.nodeName + ", was expecting control");
		}
	}
	public function setData(newData:Object):Void {
		type = newData.type;
		rows = newData.rows;
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
