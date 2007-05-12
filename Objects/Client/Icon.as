package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Icon")]
	[RemoteClass(alias="elifeAdmin.objects.client.icon")]
	public class Icon extends BaseElement {
		private var name:String;
		private var icon:String;
		private var func:String;
		private var canOpen:String;
		private var param:String;
		private var attributes:Array;
		private var attributeGroups:Array = ["button"];	
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(name);
			output.writeUTF(icon);
			output.writeUTF(func);
			output.writeUTF(canOpen);
			output.writeUTF(param);
			output.writeObject(attributes);
			output.writeObject(attributeGroups);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			name = input.readUTF() as String;
			icon = input.readUTF() as String;
			func = input.readUTF() as String;
			canOpen = input.readUTF() as String;
			param = input.readUTF() as String;
			attributes = input.readObject()as Array;
			attributeGroups = input.readObject()as Array;
		}
		
		public function deleteSelf():void{
			treeNode.removeNode();
		}			
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			if (name == null || name == "") {
					flag = "error";
					appendValidationMsg("Name is empty");
			}
			if (icon == undefined || icon == "") {
					flag = "error";
					appendValidationMsg("Icon is invalid");
			}
			if (func == undefined || func == "") {
					flag = "error";
					appendValidationMsg("Function is invalid");
			}
			if ((func == "runexe") && (param == undefined || param == "")) {
					flag = "error";
					appendValidationMsg("Parameter is invalid");
			}
			
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.icon";
		}
		public override function toXML():XML {
			var newNode = new XML("<icon />");
			if ((name != undefined) && (name != "")) {
				newNode.@name = name;
			}
			if ((icon != undefined) && (icon != "")) {
				newNode.@icon = icon;
			}
			if ((func != undefined) && (func != "")) {
				newNode.@func = func;
			}
			if ((param != undefined) && (param != "")) {
				newNode.@program = param;
			}		
			newNode.@canOpen = canOpen;
			for (var attribute in attributes) {
				newNode.@attributes[attribute].name = attributes[attribute].value;
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String{
			return "ClientIcon";
		}	
		public override function getName():String {
			return "Icon:"+name;
		}
		public override function getData():ObjectProxy {
			return {name:name, icon:icon, func:func, canOpen:canOpen, param:param, dataObject:this};
		}
		public override function setData(newData:Object):void {
			name = newData.name;
			icon = newData.icon;
			func = newData.func;
			canOpen = newData.canOpen;
			param = newData.param;
		}
		public function getAttributes():Array{
			return attributes;
		}
		public function setAttributes(newAttributes:Array){
			attributes = newAttributes;
		}	
		public override function setXML(newData:XML):void {
			attributes = new Array();
			name = "";
			icon = "";
			func = "";
			canOpen = "";
			param = "";
			if (newData.name() == "icon") {
				name = newData.attribute("name").toString();
				icon = newData.attribute("icon").toString();
				func = newData.attribute("func").toString();
				canOpen = newData.attribute("canOpen").toString();
				param = newData.attribute("program").toString();
				
				//fix up attributes that arnt listed jk
				//attributes.push({name:attribute, value:newData.attributes[attribute]});
			}
			else {
				trace("Error, received "+newData.nodeName+", was expecting icon");
			}
		}
	
		public function getIcons():Array{
			usedIcons = new Array();
			if (icon != "" && icon != undefined){
				addIcon(icon);
			}
			return usedIcons;
		}
	}
}