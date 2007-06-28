package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Control_Panel_Apps")]
	[RemoteClass(alias="elifeAdmin.objects.client.control_Panel_Apps")]
	public class Control_Panel_Apps extends BaseElement{
		private var apps:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(apps);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			apps = input.readObject()as Array;
		}
		
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for(var child in apps.childNodes){
				if((apps.childNodes[child].attributes["label"] == undefined)||(apps.childNodes[child].attributes["label"] == "")){
					flag = "warning";
					appendValidationMsg("Label is empty");
				}
				if((apps.childNodes[child].attributes["program"] ==undefined)||(apps.childNodes[child].attributes["program"] =="")){
					flag = "warning";
					appendValidationMsg("Program is empty");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.controlpanelapps";
		}
		public override function toXML():XML {
			var newNode = new XML("<controlPanelApps />");
			for(var app in apps) {
				newNode.appendChild(apps[app]);
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
			return "ClientControl_Panel_Apps";
		}	
		public override function getName():String{
			return "Control Panel Apps";
		}
		public  function get Data():ObjectProxy {
			return {apps:apps, dataObject:this};
		}
		public override function setXML(newData:XML):void{
			apps = new Array();
			if(newData.name() == "controlPanelApps"){
				for (var app:int =0; app< newData.children().length();app++){
					apps.push(newData.control[app]);
				}
			}
			else{
				trace("Error, received "+newData.nodeName+", was expecting controlPanelApps");			
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void{
			apps = newData.apps;
		}
	}
}