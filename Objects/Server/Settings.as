package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import Objects.MyTreeNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Settings")]
	[RemoteClass(alias="elifeAdmin.objects.server.settings")]
	public class Settings extends BaseElement {
		private var settings:XML;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(settings);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			settings = input.readObject()as Array;
		}
		
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			
			var autoClose:Boolean = false;
			var iconSet:Boolean = false;
			for (var child:int = 0; child<settings.children().length;child++){	
				if (settings.children()[child].@NAME == "AUTOCLOSE") {
					autoClose = true;
				}
				if (settings.children()[child].@NAME == "ICON") {
					iconSet = true;
				}
			}
			if (autoClose == false) {
				flag = "error";
				appendValidationMsg("Autoclose is empty");
			}
			if (iconSet == false) {
				flag = "error";
				appendValidationMsg("Icon is empty");
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.calendarsettings";
		}
		public override function toXML():XML {
			if (settings == null) {
				return null
			}
			return settings;
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
		public override function getData():ObjectProxy {
			return {settings:settings, dataObject:this};
		}
		public override function setData(newData:Object):void {
			settings = newData.settings;
		}
		public override function setXML(newData:XML):void {
			settings = new XML();
			if (newData.name() == "CALENDAR_MESSAGES") {
					settings = newData;
			} else {
				trace("ERROR, found node "+newData.name()+", expecting CALENDAR_MESSAGES");
			}
		}
	}
}