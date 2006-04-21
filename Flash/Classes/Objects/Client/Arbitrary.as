class Objects.Client.Arbitrary extends Objects.BaseElement {
	private var items:Array;
	private var treeNode:XMLNode;	
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var item in items){
			switch (items[item].attributes["type"]) {
				case "label" :
					if((items[item].attributes["label"] == "")||(items[item].attributes["label"] == undefined)){
						flag = "warning";
						appendValidationMsg("Label is invalid");
					}
					if((items[item].attributes["fontSize"] == "")||(items[item].attributes["fontSize"] == undefined)){
						flag = "warning";
						appendValidationMsg("Font size is invalid");
					}
					if((items[item].attributes["fontColour"] == "")||(items[item].attributes["fontColour"] == undefined)){
						flag = "warning";
						appendValidationMsg("Font colour is invalid");
					}				
					break;
				case "button" :
					if((items[item].attributes["bgColour"] == "")||(items[item].attributes["bgColour"] == undefined)){
						flag = "warning";
						appendValidationMsg("Backgroung Colour is invalid");
					}
					if((items[item].attributes["borderColour"] == "")||(items[item].attributes["borderColour"] == undefined)){
						flag = "warning";
						appendValidationMsg("Border colour is invalid");
					}
					if((items[item].attributes["fontColour"] == "")||(items[item].attributes["fontColour"] == undefined)){
						flag = "warning";
						appendValidationMsg("Font colour is invalid");
					}
					if((items[item].attributes["labels"] == "")||(items[item].attributes["labels"] == undefined)){
						flag = "warning";
						appendValidationMsg("Labels are invalid");
					}
					if((items[item].attributes["commands"] == "")||(items[item].attributes["commands"] == undefined)){
						flag = "warning";
						appendValidationMsg("Commands are invalid");
					}
					if((items[item].attributes["width"] == "")||(items[item].attributes["width"] == undefined)){
						flag = "warning";
						appendValidationMsg("Width is invalid");
					}
					if((items[item].attributes["fontSize"] == "")||(items[item].attributes["fontSize"] == undefined)){
						flag = "warning";
						appendValidationMsg("Font size is invalid");
					}
					if((items[item].attributes["key"] == "")||(items[item].attributes["key"] == undefined)){
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					else {
						if (_global.isKeyValid(items[item].attributes["key"]) == false) {
							flag = "error";
							appendValidationMsg("Key has changed and is invalid");
						}
					}
					
					break;
				case "icon" :
					if((items[item].attributes["icons"] == "")||(items[item].attributes["icons"] == undefined)){
						flag = "warning";
						appendValidationMsg("Icons are invalid");
					}
					if((items[item].attributes["commands"] == "")||(items[item].attributes["commands"] == undefined)){
						flag = "warning";
						appendValidationMsg("Commands are invalid");
					}
					if((items[item].attributes["key"] == "")||(items[item].attributes["key"] == undefined)){
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					else {
						if (_global.isKeyValid(items[item].attributes["key"]) == false) {
							flag = "error";
							appendValidationMsg("Key has changed and is invalid");
						}
					}
					break;
				case "object" :
					if((items[item].attributes["src"] == "")||(items[item].attributes["src"] == undefined)){
						flag = "warning";
						appendValidationMsg("Source is invalid");
					}
					
					if((items[item].attributes["width"] == "")||(items[item].attributes["width"] == undefined)){
						flag = "warning";
						appendValidationMsg("Width is invalid");
					}
					if((items[item].attributes["height"] == "")||(items[item].attributes["height"] == undefined)){
						flag = "warning";
						appendValidationMsg("Height is invalid");
					}
					if((items[item].attributes["show"] == "")||(items[item].attributes["show"] == undefined)){
						flag = "warning";
						appendValidationMsg("Show is invalid");
					}
					if((items[item].attributes["hide"] == "")||(items[item].attributes["hide"] == undefined)){
						flag = "warning";
						appendValidationMsg("Hide is invalid");
					}
					if((items[item].attributes["key"] == "")||(items[item].attributes["key"] == undefined)){
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					else {
						if (_global.isKeyValid(items[item].attributes["key"]) == false) {
							flag = "error";
							appendValidationMsg("Key has changed and is invalid");
						}
					}
					break;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.client.arbitrary";
	}
	public function toXML():XMLNode {
		var newNode = new XMLNode(1,"arbitrary");
		for(var item in items) {
			newNode.appendChild(items[item]);
		}
		return newNode;
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String{
		return "ClientArbitrary";
	}
	public function getName():String{
		return "Arbitrary";
	}
	public function getData():Object{
		return {items:items, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void{
		items = new Array();
		if(newData.nodeName == "arbitrary"){
			for(var child in newData.childNodes){
				items.push(newData.childNodes[child]);
			}
		}
		else{
			trace("Error, found "+ newData.nodeName +", was expecting arbitrary");
		}
	}
	public function setData(newData:Object):Void{
			items = newData.items;
	}
	public function getUsedKeys():Array{
		usedKeys = new Array();
		for (var item in items) {
			if ((items[item].attributes["keys"] != "") && (items[item].attributes["keys"] != undefined)) {
				addUsedKey(items[item].attributes["keys"]);
			}
		}
		return usedKeys;
	}
	public function getIcons():Array{
		usedIcons = new Array();
		for (var item in items) {
			if ((items[item].attributes["icon"] != "") && (items[item].attributes["icon"] != undefined)) {
				addIcon(items[item].attributes["icon"]);
			}
		}
		return usedIcons;
	}
}
