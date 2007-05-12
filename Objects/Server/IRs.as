package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("irs")]
	[RemoteClass(alias="elifeAdmin.objects.server.irs")]
	public class IRs extends BaseElement {
		private var container:String;
		private var irs:Array;
		private var treeNode:XMLNode;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(irs);
			output.writeObject(treeNode);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			irs = input.readObject()as Array;
			treeNode = input.readObject()as XMLNode;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			for(var ir in irs){
				tempKeys.push(irs[ir].avname);
			}
			return tempKeys;
		}
		public function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var ir in irs) {
				if ((irs[ir].name == undefined) || (irs[ir].name == "")) {
					flag = "empty";
					appendValidationMsg("Description is empty");
				}
				if ((irs[ir].key == undefined) || (irs[ir].key == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				}
				if ((irs[ir].avname == undefined) || (irs[ir].avname == "")) {
					flag = "error";
					appendValidationMsg("AV Name is empty");
				}
			}
			return flag;
		}
		public function getForm():String {
			return "forms.project.device.ir";
		}
		public function toXML():XML {
			var irsNode:XML = new XML(container);
			for (var ir in irs) {
				irsNode.appendChild(irs[ir]);
			}
			return irsNode;
		}
		public function getName():String {
			return "IR Inputs";
		}
		public function toTree():XMLNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "IRs";
		}
		public function setData(newData:Object){
			irs = newData.irs;
		}
		public function getData():Object {
			return {irs:irs, dataObject:this};
		}
		public function setXML(newData:XML):Void {
			irs = new Array();
			container = newData.name();
			for (var child:int=0 ; child < newData.children().length() ; child++) {
				irs.push(newData.children()[child]);
			}
		}
	}
}