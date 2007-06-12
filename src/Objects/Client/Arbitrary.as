package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Arbitrary")]
	[RemoteClass(alias="elifeAdmin.objects.client.arbitrary")]
	public class Arbitrary extends BaseElement {
		private var items:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(items);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			items = input.readObject()as Array;
		}
		
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			for (var item in items){
				switch (items[item].attributes["type"]) {
					case "label" :
						if((items[item].attributes["label"] == "")||(items[item].attributes["label"] == undefined)){
							flag = "warning";
							appendValidationMsg("Label:Label is empty");
						}
						if((items[item].attributes["fontSize"] == "")||(items[item].attributes["fontSize"] == undefined)){
							flag = "warning";
							appendValidationMsg("Label:Font size is invalid");
						}
						if((items[item].attributes["fontColour"] == "")||(items[item].attributes["fontColour"] == undefined)){
							flag = "warning";
							appendValidationMsg("Label:Font colour is invalid");
						}				
						break;
					case "button" :
						if((items[item].attributes["bgColour"] == "")||(items[item].attributes["bgColour"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Backgroung Colour is invalid");
						}
						if((items[item].attributes["borderColour"] == "")||(items[item].attributes["borderColour"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Border colour is invalid");
						}
						if((items[item].attributes["fontColour"] == "")||(items[item].attributes["fontColour"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Font colour is invalid");
						}
						if((items[item].attributes["labels"] == "")||(items[item].attributes["labels"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Labels are invalid");
						}
						if((items[item].attributes["commands"] == "")||(items[item].attributes["commands"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Commands are invalid");
						}
						if((items[item].attributes["width"] == "")||(items[item].attributes["width"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Width is invalid");
						}
						if((items[item].attributes["fontSize"] == "")||(items[item].attributes["fontSize"] == undefined)){
							flag = "warning";
							appendValidationMsg("Button:Font size is invalid");
						}
						if((items[item].attributes["key"] == "")||(items[item].attributes["key"] == undefined)){
							flag = "error";
							appendValidationMsg("Button:Key is invalid");
						}
						else {
							if (Application.application.isKeyValid(items[item].attributes["key"]) == false) {
								flag = "error";
								appendValidationMsg("Key has changed and is invalid");
							}
						}
						
						break;
					case "icon" :
						if((items[item].attributes["icons"] == "")||(items[item].attributes["icons"] == undefined)){
							flag = "warning";
							appendValidationMsg("Icon:Icons are invalid");
						}
						if((items[item].attributes["commands"] == "")||(items[item].attributes["commands"] == undefined)){
							flag = "warning";
							appendValidationMsg("Icon:Commands are invalid");
						}
						if((items[item].attributes["key"] == "")||(items[item].attributes["key"] == undefined)){
							flag = "error";
							appendValidationMsg("Icon:Key is invalid");
						}
						else {
							if (Application.application.isKeyValid(items[item].attributes["key"]) == false) {
								flag = "error";
								appendValidationMsg("Icon:Key has changed and is invalid");
							}
						}
						break;
					case "object" :
						if((items[item].attributes["src"] == "")||(items[item].attributes["src"] == undefined)){
							flag = "warning";
							appendValidationMsg("Object:Source is invalid");
						}
						
						if((items[item].attributes["width"] == "")||(items[item].attributes["width"] == undefined)){
							flag = "warning";
							appendValidationMsg("Object:Width is invalid");
						}
						if((items[item].attributes["height"] == "")||(items[item].attributes["height"] == undefined)){
							flag = "warning";
							appendValidationMsg("Object:Height is invalid");
						}
						if((items[item].attributes["show"] == "")||(items[item].attributes["show"] == undefined)){
							flag = "warning";
							appendValidationMsg("Object:Show is invalid");
						}
						if((items[item].attributes["hide"] == "")||(items[item].attributes["hide"] == undefined)){
							flag = "warning";
							appendValidationMsg("Object:Hide is invalid");
						}
						if((items[item].attributes["key"] == "")||(items[item].attributes["key"] == undefined)){
							flag = "error";
							appendValidationMsg("Object:Key is invalid");
						}
						else {
							if (Application.application.isKeyValid(items[item].attributes["key"]) == false) {
								flag = "error";
								appendValidationMsg("Object:Key has changed and is invalid");
							}
						}
						break;
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.arbitrary";
		}
		public override function toXML():XML {
			var newNode = new XML("<arbitrary />");
			for(var item in items) {
				newNode.appendChild(items[item]);
			}
			return newNode;
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String{
			return "ClientArbitrary";
		}
		public override function getName():String{
			return "Arbitrary";
		}
		public  function get Data():ObjectProxy {
			return {items:items, dataObject:this};
		}
		public function getItems():Array{
			return items;
		}
		public override function setXML(newData:XML):void{
			items = new Array();
			if(newData.name() == "arbitrary"){
				for (var child:int=0; child< newData.children().length();child++) {
					items.push(newData.children()[child]);
				}
			}
			else{
				trace("Error, found "+ newData.nodeName +", was expecting arbitrary");
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void{
				items = newData.items;
		}
		public override function getUsedKeys():Array{
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
}