package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Logging")]
	[RemoteClass(alias="elifeAdmin.objects.client.logging")]
	public class Logging extends BaseElement {
		private var groups:Array;
		private var attributes:Array;
		private var attributeGroups:Array = ["window", "tabs"];
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(groups);
			output.writeObject(attributes);
			output.writeObject(attributeGroups);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			groups = input.readObject()as Array;
			attributes = input.readObject()as Array;
			attributeGroups = input.readObject()as Array;
		}
		
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			if (groups.length == 0) {
				flag = "empty";
				appendValidationMsg("No Logging Groups are defined");
			}
			for (var group in groups) {
				if (groups[group].isValid()!="ok") {
					flag = "warning";
					appendValidationMsg("Group:" + groups[group].name + " is in error");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.logging";
		}
		public override function toXML():XML {
			var newNode:XML = new XML("<logging />");
			for (var attribute in attributes) {
				newNode.@[attributes[attribute].name] = attributes[attribute].value;
			}
			for (var group = 0; group < groups.length; group++) {
				newNode.appendChild(groups[group].toXML());
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			for (var group = 0; group < groups.length; group++) {
				newNode.appendChild(groups[group].toTree());
			}
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "Logging";
		}
		public override function getName():String {
			return "Logging";
		}
		public  function get Data():ObjectProxy {
			return {groups:groups, dataObject:this};
		}
		public function getAttributes():Array {
			return attributes;
		}
		public function setAttributes(newAttributes:Array) {
			attributes = newAttributes;
		}
		public override function setXML(newData:XML):void {
			groups = new Array();
			attributes = new Array();
			if (newData.name() == "logging") {
				
				for (var child:int = 0; child < newData.attributes().length(); child++) {
					attributes.push({name:newData.attributes()[child].name(), value:newData.attributes()[child]});
				}
				for (var child:int = 0; child < newData.children().length(); child++) {
					var newGroup:LoggingGroup = new LoggingGroup();
					newGroup.setXML(newData.children()[child]);
					newGroup.id = Application.application.formDepth++;
					groups.push(newGroup);
				}
			} else {
				trace("Error, received " + newData.name() + ", was expecting logging");
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			//_global.left_tree.setIsOpen(treeNode, false);
			//process new groups
			var newGroups = new Array();
			for (var index in newData.groups) {
				if (newData.groups[index].id == undefined) {
					newGroups.push({name:newData.groups[index].name});
				}
			}
			for (var group in groups) {
				var found = false;
				for (var index in newData.groups) {
					if (groups[group].id == newData.groups[index].id) {
						groups[group].name = newData.groups[index].name;
						found = true;
					}
				}
				if (found == false) {
					groups[group].deleteSelf();
					groups.splice(parseInt(group), 1);
				}
			}
			for (var newGroup in newGroups) {
				var newNode = new XMLNode(1, "group");
				newNode.attributes["name"] = newGroups[newGroup].name;
				var newGroup = new Objects.Client.LoggingGroup();
				newGroup.id = Application.application.formDepth++;
				newGroup.setXML(newNode);
				groups.push(newGroup);
			}
			//sort according to desired order
			newGroups = new Array();
			for (var newGroup = 0; newGroup < newData.groups.length; newGroup++) {
				for (var group = 0; group < groups.length; group++) {
					if (newData.groups[newGroup].name == groups[group].name) {
						newGroups.push(groups[group]);
					}
				}
			}
			groups = newGroups;
			var treeLength = treeNode.childNodes.length;
			for(var child = treeLength-1; child > -1;child--){
				treeNode.childNodes[child].removeNode();
			}
			for(var group = 0; group<groups.length;group++){
				treeNode.appendChild(groups[group].toTree());
			}
			//_global.left_tree.setIsOpen(treeNode, true);
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			for (var group in groups) {
				usedKeys=usedKeys.concat(groups[group].getUsedKeys());
			}
			return usedKeys;
		}
		public function getIcons():Array{
			usedIcons = new Array();
			for (var group in groups) {
				usedIcons=usedIcons.concat(groups[group].getIcons());
			}
			return usedIcons;
		}
	}
}