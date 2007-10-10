package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Client.Control_frm;
	
	[Bindable("Control")]
	[RemoteClass(alias="elifeAdmin.objects.client.control")]
	public class Control extends BaseElement {
		[Bindable]
		public var type:String="";
		[Bindable]
		public var rows:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(type);
			output.writeObject(rows);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			type = input.readUTF() as String;
			rows = input.readObject()as Array;
		}
		
		public function deleteSelf():void{
			treeNode.removeNode(); 
		}
		public override function isValid():String { 
			var flag:String = "ok";
			clearValidationMsg();
			for (var row in rows){
				for (var item in rows[row].children())
				{
					switch ( rows[row].children()[item].@type) {
						case "slider" :
							if((rows[row].children()[item].@width == "")||(rows[row].children()[item].@width == undefined)){
								flag = "warning";
								appendValidationMsg("Slider:Width is empty");
							}
							break;
						case "button" :
							if((rows[row].children()[item].@label == "")||(rows[row].children()[item].@label == undefined)){
								flag = "warning";
								appendValidationMsg("Button:Label is empty");
							}
							if((rows[row].children()[item].@icon == "")||(rows[row].children()[item].@icon == undefined)){
								flag = "warning";
								appendValidationMsg("Button:Icon is empty");
							}
							if((rows[row].children()[item].@extra == "")||(rows[row].children()[item].@extra == undefined)){
								flag = "warning";
								appendValidationMsg("Button:Extra is empty");
							}
							/*if((rows[row].children()[item].@extra2 == "")||(rows[row].children()[item].@extra2 == undefined)){
								flag = "warning";
								appendValidationMsg("Button:Extra2 is empty");
							}
							if((rows[row].children()[item].@extra3 == "")||(rows[row].children()[item].@extra3 == undefined)){
								flag = "warning";
								appendValidationMsg("Button:Extra3 is empty");
							}*/
							if((rows[row].children()[item].@width == "")||(rows[row].children()[item].@width == undefined)){
								flag = "warning";
								appendValidationMsg("Button:Width is empty");
							}
							if((rows[row].children()[item].@command == "")||(rows[row].children()[item].@command == undefined)){
								flag = "warning";
								appendValidationMsg("Button:Command is empty");
							}
							if((rows[row].children()[item].@repeatRate == "")||(rows[row].children()[item].@repeatRate == undefined)){
								flag = "warning";
								appendValidationMsg("Button:RepeatRate is empty");
							}
							if((rows[row].children()[item].@showOn == "")||(rows[row].children()[item].@showOn == undefined)){
								flag = "warning";
								appendValidationMsg("Button:ShowOn is empty");
							}
							break;
						case "icon" :
							if((rows[row].children()[item].@icon == "")||(rows[row].children()[item].@icon == undefined)){
								flag = "warning";
								appendValidationMsg("Icon is empty");
							}
							if((rows[row].children()[item].@commands == "")||(rows[row].children()[item].@commands == undefined)){
								flag = "warning";
								appendValidationMsg("Commands are empty");
							}
							if((rows[row].children()[item].@key == "")||(rows[row].children()[item].@key == undefined)){
								flag = "warning";
								appendValidationMsg("Key is empty");
							}
							break;
						case "object" :
							if((rows[row].children()[item].@src == "")||(rows[row].children()[item].@src == undefined)){
								flag = "warning";
								appendValidationMsg("Source is empty");
							}
							if((rows[row].children()[item].@key == "")||(rows[row].children()[item].@key == undefined)){
								flag = "warning";
								appendValidationMsg("Key is empty");
							}
							if((rows[row].children()[item].@width == "")||(rows[row].children()[item].@width == undefined)){
								flag = "warning";
								appendValidationMsg("Width is empty");
							}
							if((rows[row].children()[item].@height == "")||(rows[row].children()[item].@height == undefined)){
								flag = "warning";
								appendValidationMsg("Height is empty");
							}
							if((rows[row].children()[item].@show == "")||(rows[row].children()[item].@show == undefined)){
								flag = "warning";
								appendValidationMsg("Show is empty");
							}
							if((rows[row].children()[item].@hide == "")||(rows[row].children()[item].@hide == undefined)){
								flag = "warning";
								appendValidationMsg("Hide is empty");
							}
							break;
					}
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.control";
		}
		public function getClassForm():Class {
			var className:Class = Forms.Client.Control_frm;
			return className;		
		}
		public override function toXML():XML {
			var newNode = new XML("<control />");
			newNode.@type = type;
			for (var row in rows) {
				newNode.appendChild(rows[row]);
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "ClientControl";
		}
		public override function getName():String {
			return "Control : " + type;
		}
		public  function get Data():ObjectProxy {
			var newNode = new XMLNode(1, "control");
			newNode.@type = type;
			for (var row in rows) {
				newNode.appendChild(rows[row]);
			}
			return {controlTypeData:newNode, type:type, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			rows = new Array();
			
			if (newData.name() == "control") {
				type = newData.@type;
				for (var child:int=0; child < newData.children().length(); child++) {
					rows.push(newData.row[child]);
				}
			} else {
				trace("Error, found " + newData.name() + ", was expecting control");
			}
		}
		[Bindable]
		public function set Data(newData:ObjectProxy):void {
			newData.controlTypeData.attributes.type = newData.type;
			//rows = newData.rows;
			setXML(newData.controlTypeData);
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			for (var item in rows) {
				if ((rows[item].@key != "") && (rows[item].@key != undefined)) {
					addUsedKey(rows[item].@key);
				}
			}
			return usedKeys;
		}
		public function getIcons():Array{
			usedIcons = new Array();
			for (var row in rows) {
				//mdm.Dialogs.prompt(rows[row].toString());
				var tempArray = rows[row].children();
				for(var item in tempArray)
				{
					if ((tempArray[item].@icons != "") && (tempArray[item].@icons != undefined)) {
						var tempIcons = tempArray[item].@icons.split(",");
						for(var tempIcon in tempIcons){
							if(tempIcons[tempIcon].length){
								addIcon(tempIcons[tempIcon]);
							}
						}
					} else if ((tempArray[item].@icon != "") && (tempArray[item].@icon != undefined)) {
						addIcon(tempArray[item].@icon);
					}
				}
			}
			return usedIcons;
		}
	}
}