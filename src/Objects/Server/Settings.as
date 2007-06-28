package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import Objects.MyTreeNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import Forms.Server.CalendarSettings_frm;
	
	[Bindable("Settings")]
	[RemoteClass(alias="elifeAdmin.objects.server.settings")]
	public class Settings extends BaseElement {
		[Bindable]
		public var hideClose:String="";
		[Bindable]
		public var icon:String="";
		[Bindable]
		public var autoClose:String="";
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(hideClose);
			output.writeUTF(icon);
			output.writeUTF(autoClose);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			hideClose = input.readUTF() as String;
			icon = input.readUTF() as String;
			autoClose = input.readUTF() as String;
		}
		
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			
			if (autoClose == null || autoClose.length == 0) {
				flag = "error";
				appendValidationMsg("Autoclose is empty");
			}
			if (icon == null || icon.length == 0) {
				flag = "error";
				appendValidationMsg("Icon is empty");
			}
			if (hideClose == null || hideClose.length == 0) {
				flag = "error";
				appendValidationMsg("Hide Close check is empty");
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.calendarsettings";
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.CalendarSettings_frm;
			return className;		
		}
		
		public override function toXML():XML {
			
			if (icon == "" && autoClose == "" && hideClose == "") {
				return XML();
			}
			var settingsNode:XML = new XML("<CALENDAR_MESSAGES />");
			var itemNode:XML = new XML("<ITEM />");
			itemNode.@VALUE = hideClose;
			itemNode.@NAME = "HIDECLOSE";
			settingsNode.appendChild(itemNode);
			
			itemNode = new XML("<ITEM />");
			itemNode.@VALUE = autoClose;
			itemNode.@NAME = "AUTOCLOSE";
			settingsNode.appendChild(itemNode);
			
			itemNode = new XML("<ITEM />");
			itemNode.@VALUE = icon;
			itemNode.@NAME = "ICON";
			settingsNode.appendChild(itemNode);
			
			return settingsNode;
		}
		public override function getName():String {
			return "Calendar Settings";
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "Calendar_Settings";
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy({hideClose:hideClose, autoClose:autoClose, icon:icon, dataObject:this});
			return ob;
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			hideClose = newData.hideClose;
			autoClose = newData.autoClose;
			icon = newData.icon;
		}
		public override function setXML(newData:XML):void {
			hideClose = "";
			autoClose = "";
			icon = "";
			if (newData.name() == "CALENDAR_MESSAGES") {
				for (var child:int=0 ; child < newData.children().length() ; child++) {
					if (newData.children()[child].@NAME == "HIDECLOSE") {
						hideClose = newData.children()[child].@VALUE.toString();
					}
					if (newData.children()[child].@NAME == "AUTOCLOSE") {
						autoClose = newData.children()[child].@VALUE.toString();
					}
					if (newData.children()[child].@NAME == "ICON") {
						icon = newData.children()[child].@VALUE.toString();
					}
				}
			}
			else {
				trace("ERROR, found node "+newData.name()+", expecting CALENDAR_MESSAGES");
			}
			
		}
	}
}