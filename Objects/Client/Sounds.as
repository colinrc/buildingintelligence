package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Sounds")]
	[RemoteClass(alias="elifeAdmin.objects.client.sounds")]
	public class Sounds extends BaseElement {
		private var sounds:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(sounds);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			sounds = input.readObject()as Array;
		}
		
		public function deleteSelf():void {
			treeNode.removeNode();
		}
		public override function isValid():String {
			//mdm.Dialogs.prompt("InSound");
			var flag:String = "ok";
			clearValidationMsg();
			if (sounds.length == 0) {
				flag = "empty";
				appendValidationMsg("No Sounds are defined");
			}
			for (var sound in sounds) {
				if ((sounds[sound].attributes["name"] == undefined) || (sounds[sound].attributes["name"] == "")) {
					flag = "empty";
					appendValidationMsg("Name is empty");
				}
				if ((sounds[sound].attributes["file"] == undefined) || (sounds[sound].attributes["file"] == "")) {
					flag = "warning";
					appendValidationMsg("File is empty");
				}
				if ((sounds[sound].attributes["volume"] == undefined) || (sounds[sound].attributes["volume"] == "")) {
					flag = "warning";
					appendValidationMsg("Volume is empty");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.sounds";
		}
		public override function toXML():XML {
			var newNode:XML = new XML("<sounds />");
			for(var sound:int=0 ; sound < sounds.length ; sound++){
				newNode.appendChild(sounds[sound]);
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
			return "ClientSounds";
		}
		public override function getName():String {
			return "Sounds";
		}
		public override function getData():ObjectProxy {
			return {sounds:sounds, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			sounds = new Array();
			if(newData.name() == "sounds"){
				for (var child:int =0; child< newData.children().length(); child++) {
					sounds.push(newData.children()[child]);
				}
			}
			else{
				trace("Error, found "+newData.nodeName+", was expecting sounds");
			}
		}
		public override function setData(newData:Object):void {
			sounds = newData.sounds;
		}
	}
}