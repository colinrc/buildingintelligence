package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.collections.ArrayCollection;
	import Forms.Server.DynaliteIRs_frm;
	[Bindable("DynaliteIRs")]
	[RemoteClass(alias="elifeAdmin.server.dynaliteIRs")] 
	public class DynaliteIRs extends BaseElement {
		[Bindable]
		public var container:String="";
		[Bindable]
		public var irs:ArrayCollection;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(irs);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			irs = input.readObject()as ArrayCollection;
		}
		
		public function getKeys():Array{
			var tempKeys = new Array();
			for(var ir in irs){
				tempKeys.push(irs[ir].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var ir in irs) {
				if ((irs[ir].active != "Y") && (irs[ir].active != "N")) {
					flag = "error";
					appendValidationMsg("Active Flag is invalid");
				}
				else {
					if (irs[ir].active =="Y"){
						if ((irs[ir].name == undefined) || (irs[ir].name == "")) {
							flag = "empty";
							appendValidationMsg("Description is empty");
						}
						if ((irs[ir].key == undefined) || (irs[ir].key == "")) {
							flag = "error";
							appendValidationMsg("Dynalite Code is empty");
						}
						if ((irs[ir].box == undefined) || (irs[ir].box == "")) {
							flag = "error";
							appendValidationMsg("Box is empty");
						}			
						if ((irs[ir].display_name == undefined) || (irs[ir].display_name == "")) {
							flag = "error";
							appendValidationMsg("Key is invalid");
						}
						else {
							if (Application.application.isKeyUsed(irs[ir].display_name) == false) {
								flag = "error";
								appendValidationMsg(irs[ir].display_name+" key is not used");
							}
						}
					}
					else {
						if (irs[ir].active =="N"){
							flag = "empty";
							appendValidationMsg("Dynalite IRs is not active");
						}
					}
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.dynaliteirs";
		}
		public override function toXML():XML {
			if (container.length == 0) {
				return XML();
			}
			
			var irsNode = new XML("<"+container+" />");
			for (var ir in irs) {
				var newIR = new XML("<IR />");
				if (irs[ir].name != "") {
					newIR.@NAME = irs[ir].name;
				}
				if (irs[ir].display_name != "") {
					newIR.@DISPLAY_NAME = irs[ir].display_name;
				}
				if (irs[ir].key != "") {
					newIR.@KEY = irs[ir].key;
				}
				if (irs[ir].active != "") {
					newIR.@ACTIVE = irs[ir].active;
				}
				if (irs[ir].box != "") {
					newIR.@BOX = irs[ir].box;
				}
				irsNode.appendChild(newIR);
			}
			return irsNode;
		}
		public override function getName():String {
			return "IR Inputs";
		}
		public override function toTree():MyTreeNode{
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
		
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "DynaliteIRs";
		}	
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			irs = newData.irs;
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy( {irs:irs, dataObject:this})
			return ob;
		}
		public function getClassForm():Class {
			var className:Class = Forms.Server.DynaliteIRs_frm;
			return className;		
		}
		public override function setXML(newData:XML):void {
			irs = new ArrayCollection();
			container = newData.name();
			for (var child:int=0 ; child < newData.children().length() ; child++) {
				var newIR = new Object();
				newIR.name = "";
				newIR.display_name = "";
				newIR.key = "";
				newIR.active = "Y";
				newIR.box = "";
				if (newData.children()[child].@NAME != undefined) {
					newIR.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newIR.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newIR.key = newData.children()[child].@KEY;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newIR.active = newData.children()[child].@ACTIVE;
				}
				if (newData.children()[child].@BOX != undefined) {
					newIR.box = newData.children()[child].@BOX;
				}
				irs.addItem(newIR);
			}
		}
	}
}