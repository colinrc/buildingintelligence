package Objects {
	import flash.xml.XMLNode;
	import Objects.MyTreeNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.core.Application;
	[Bindable("base")]
	[RemoteClass(alias="elifeAdmin.base")]
	public class BaseElement implements IExternalizable {
		private var validationMsg:String ="";
		public var usedIcons:Array = new Array();
		private var usedKeys:Array;
		private var errorText:String ="";
		public var id:int;
		public var uniqueID:int;
		public var treeNode:MyTreeNode;
		
		public function BaseElement():void{
			Application.application.uniqueID = Application.application.uniqueID + 1;
			uniqueID = Application.application.uniqueID;
		}
		public function getUniqueID():String {
			return String(uniqueID);
		}
		public function writeExternal(output:IDataOutput):void {
			output.writeUTF(validationMsg);
			output.writeObject(usedIcons);
			output.writeObject(usedKeys);
			output.writeUTF(errorText);
			output.writeInt(id);	
			output.writeObject(treeNode);
		}
		
		public function readExternal(input:IDataInput):void {
			validationMsg = input.readUTF()as String;
			usedIcons = input.readObject()as Array;
			usedKeys = input.readObject()as Array;		
			errorText = input.readUTF()as String;
			id = input.readInt()as int;
			treeNode = input.readObject() as MyTreeNode;
		}
		
		//public function getIcons():Array{
		//	return usedIcons;
		//}
		private function addIcon(icon:String):void {
			usedIcons.push(icon);
		}
		public function getUsedKeys():Array{
			return usedKeys;
		}
		private function addUsedKey(key:String):void { 
			usedKeys.push(key);
		}
		public function isValid():String {
			return "ok";
		}
		public function getHighestFlagValue(oldFlag:String, isValidFlag:String):String{
			if (oldFlag == "ok"){
				return isValidFlag;
			}
			if (oldFlag == "empty") {
				if (isValidFlag == "warning" || isValidFlag == "error") {
					return isValidFlag;
				}
				else {
					return "empty";
				}
			}
			if (oldFlag == "warning") {
				if (isValidFlag == "warning" || isValidFlag == "error") {
					return isValidFlag;
				}
				else {
					return "warning";
				}
			}
			return "error";
		}
				
		public function getValidationMsg():String{
			return validationMsg;
		}
		public function setValidationMsg(msg:String):void{
			validationMsg = msg+"\n";
		}
		public function clearValidationMsg():void{
			validationMsg = "";
		}
		public function appendValidationMsg(msg:String):void{
			validationMsg += msg+"\n";
		}
		public function getForm():String {
			return "base.form";
		}
		public function toXML():XML {
			return new XML("XML_UNAVAILABLE");
		}
		public function toTree():MyTreeNode{
			return new MyTreeNode(1,"XML_UNAVAILABLE",this);
		}
		public function getName():String{
			return "BASE FORM";
		}
		public function getData():ObjectProxy{
			return null;
		}
		
		public function setXML(newData:XML):void{
		}
		public function setData(newData:Object):void{
		}
		
	}
}
