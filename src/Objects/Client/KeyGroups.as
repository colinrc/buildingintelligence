package Objects.Client {
	import Objects.*;
	import Objects.Client.KeyGroup;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("KeyGroups")]
	[RemoteClass(alias="elifeAdmin.objects.client.keyGroups")]
	public class KeyGroups extends BaseElement {
		private var keygroups:Array=new Array();
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(keygroups);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			keygroups = input.readObject()as Array;
		}
		
		public override function isValid():String {
			var flag:String = "ok";
			/*		clearValidationMsg();
			for(var child in apps.childNodes){
			if((apps.childNodes[child].attributes["name"] == undefined)||(apps.childNodes[child].attributes["name"] == "")){
			flag = "warning";
			appendValidationMsg("Label is empty");
			}
			if((apps.childNodes[child].attributes["program"] ==undefined)||(apps.childNodes[child].attributes["program"] =="")){
			flag = "warning";
			appendValidationMsg("Program is empty");
			}
			}*/
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.keygroups";
		}
		public override function toXML():XML {
			var newNode:XML = new XML("<keygroups />");
			for (var keygroup in keygroups) {
				newNode.appendChild(keygroups[keygroup].toXML());
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
		
			
			for (var keygroup in keygroups) {
				newNode.appendChild(keygroups[keygroup].toTree());
			}
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "KeyGroups";
		}
		public override function getName():String {
			return "Key Groups";
		}
		public  function get Data():ObjectProxy {
			var tempKeygroups:Array = new Array();
			for(var index:int = 0; index < keygroups.length;index++){
				tempKeygroups.push({name:keygroups[index].name,id:keygroups[index].id});
			}
			return {keygroups:tempKeygroups, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			keygroups = new Array();
			if (newData.name() == "keygroups") {
				for (var child:int=0; child< newData.children().length();child++) {
					var keyGroup:KeyGroup = new KeyGroup();
					keyGroup.setXML(newData.children()[child]);
					keyGroup.id = Application.application.formDepth++;
					keygroups.push(keyGroup);
				}
			} else {
				trace("Error, received " + newData.name() + ", was expecting keygroups");
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			//keygroups = newData.keygroups;
			//_global.left_tree.setIsOpen(treeNode, false);
			//process new keygroups
			var newKeyGroups:Array = new Array();
			for (var index in newData.keygroups) {
				if (newData.keygroups[index].id == undefined) {
					newData.keygroups[index].id = _global.formDepth++;
					newKeyGroups.push({name:newData.keygroups[index].name, id:newData.keygroups[index].id});
				}
			}
			for (var keygroup in keygroups) {
				var found:Boolean = false;
				for (var index in newData.keygroups) {
					if (keygroups[keygroup].id == newData.keygroups[index].id) {
						keygroups[keygroup].name = newData.keygroups[index].name;
						found = true;
						break;
					}
				}
				if (found == false) {
					keygroups[keygroup].deleteSelf();
					keygroups.splice(parseInt(keygroup), 1);
				}
			}
			for (var newKeyGroup in newKeyGroups) {
				var newNode:XMLNode = new XMLNode(1, "keygroup");
				newNode.attributes["name"] = newKeyGroups[newKeyGroup].name;
				var keyGroup:KeyGroup = new KeyGroup();
				keyGroup.setXML(newNode);
				keyGroup.id = newKeyGroups[newKeyGroup].id;
				keygroups.push(keyGroup);
			}
			var treeLength:int = treeNode.childNodes.length;
			for (var child:int = treeLength - 1; child > -1; child--) {
				treeNode.childNodes[child].removeNode();
			}
			for (var keygroup:int = 0; keygroup < keygroups.length; keygroup++) {
				treeNode.appendChild(keygroups[keygroup].toTree());
			}
			//_global.left_tree.setIsOpen(treeNode, true);
		}
	}
}