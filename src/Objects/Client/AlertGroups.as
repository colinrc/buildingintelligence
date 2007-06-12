package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import Objects.MyTreeNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("AlertGroups")]
	[RemoteClass(alias="elifeAdmin.objects.server.alertGroups")]
	public class AlertGroups extends BaseElement {
		var alertgroups:Array;
		var room:Object;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(alertgroups);
			output.writeObject(room);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			alertgroups = input.readObject() as Array;
			room = input.readObject() as Object;
		}
		
		public function AlertGroups() {
			alertgroups = new Array();				
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			if (alertgroups.length == 0) {
				flag = "empty";
				appendValidationMsg("No AlertGroups are defined");
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.alertgroups";
		}
		public function setRoom(inRoom:Object) {
			room = inRoom;
		}
		public override function toXML():XML {
			var newNode = new XML("<AlertGroups />");
			for (var alertgroup in alertgroups) {
				newNode.appendChild(alertgroups[alertgroup].toXML());
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			for (var alertgroup in alertgroups) {
				newNode.appendChild(alertgroups[alertgroup].toTree());
			}
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "AlertGroups";
		}
		public override function getName():String {
			return "Alert Groups";
		}
		public  function get Data():ObjectProxy {
			return {alertgroups:alertgroups, dataObject:this, map:room.zone.map, background:room.zone.background, poly:room.poly};
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			//_global.left_tree.setIsOpen(treeNode, false);
			//process alertGroup changes
			var newAlertGroups = new Array();
			for (var index in newData.alertgroups) {
				if (newData.alertgroups[index].id == undefined) {
					newAlertGroups.push({name:newData.alertgroups[index].name, x_pos:newData.alertgroups[index].x_pos, y_pos:newData.alertgroups[index].y_pos});
				}
			}
			for (var alertGroup in alertgroups) {
				var found = false;
				for (var index in newData.alertgroups) {
					if (alertgroups[alertGroup].id == newData.alertgroups[index].id) {
						alertgroups[alertGroup].name = newData.alertgroups[index].name;
						alertgroups[alertGroup].x_pos = newData.alertgroups[index].x_pos;
						alertgroups[alertGroup].y_pos = newData.alertgroups[index].y_pos;
						found = true;
					}
				}
				if (found == false) {
					alertgroups[alertGroup].deleteSelf();
					alertgroups.splice(parseInt(alertGroup), 1);
				}
			}
			for (var AlertGroup in newAlertGroups) {
				var newNode = new XMLNode(1, "alerts");
				newNode.attributes["name"] = newAlertGroups[AlertGroup].name;
				newNode.attributes["x"] = newAlertGroups[AlertGroup].x_pos;
				newNode.attributes["y"] = newAlertGroups[AlertGroup].y_pos;
				var newAlertGroup = new Objects.Client.Alerts();
				newAlertGroup.setXML(newNode);
				newAlertGroup.id = _global.formDepth++;
				treeNode.appendChild(newAlertGroup.toTree());
				alertgroups.push(newAlertGroup);
			}
			//_global.left_tree.setIsOpen(treeNode, true);
		}
		public override function setXML(newData:XML):void {
			for (var child:int=0; child< newData.children().length();child++) {
				var newAlertGroup:Alerts = new Alerts();
				newAlertGroup.setXML(newData.children()[child]);
				newAlertGroup.id = Application.application.formDepth++;
				alertgroups.push(newAlertGroup);
			}
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			for (var alerts in alertgroups) {
				usedKeys=usedKeys.concat(alertgroups[alerts].getUsedKeys());
			}
			return usedKeys;
		}
		public function getIcons():Array{
			usedIcons = new Array();
			for (var alerts in alertgroups) {
				//var newAlerts = new Objects.Client.Alerts();
				usedIcons=usedIcons.concat(alertgroups[alerts].getIcons());
			}
			return usedIcons;
		}
	}
}