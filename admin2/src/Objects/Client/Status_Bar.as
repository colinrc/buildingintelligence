package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Status_Bar")]
	[RemoteClass(alias="elifeAdmin.objects.client.status_Bar")]
	public class Status_Bar extends BaseElement {
		private var groups:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(groups);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			groups = input.readObject()as Array;
		}
		
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			if (groups.length == 0) {
				flag = "empty";
				appendValidationMsg("No Groups are defined");
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.statusbar";
		}
		public override function toXML():XML {
			var newNode:XML = new XML("<statusBar />");
			for (var group:int = 0; group < groups.length; group++) {
				newNode.appendChild(groups[group].toXML());
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			for (var group:int = 0; group < groups.length; group++) {
				newNode.appendChild(groups[group].toTree());
			}
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "StatusBar";
		}
		public override function getName():String {
			return "Status Bar";
		}
		public  function get Data():ObjectProxy {
			return {groups:groups, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			groups = new Array();
			if (newData.name() == "statusBar") {
				for (var child:int = 0; child < newData.children().length; child++) {
					var newGroup:StatusBarGroup = new StatusBarGroup();
					newGroup.setXML(newData.children()[child]);
					newGroup.id = Application.application.formDepth++;
					groups.push(newGroup);
				}
			} else {
				trace("Error, received " + newData.nodeName + ", was expecting statusBar");
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			//_global.left_tree.setIsOpen(treeNode, false);
			/*Find new groups*/
			var newGroups:Array = new Array();
			for (var index in newData.groups) {
				if (newData.groups[index].id == undefined) {
					newGroups.push({name:newData.groups[index].name});
				}
			}
			/*Delete missing groups*/
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
			/*Create new Group objects*/
			for (var newGroup in newGroups) {
				var newNode = new XMLNode(1, "group");
				newNode.attributes["name"] = newGroups[newGroup].name;
				var newGroup = new Objects.Client.StatusBarGroup();
				newGroup.setXML(newNode);
				newGroup.id = Application.application.formDepth++;
				treeNode.appendChild(newGroup.toTree());
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