package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.core.Application;
	import mx.collections.ArrayCollection;
	import Forms.Server.ContactClosures_frm;
	[Bindable("ContactClosures")]
	[RemoteClass(alias="elifeAdmin.server.contactClosures")] 
	public class ContactClosures extends BaseElement {
		private var container:String="";
		[Bindable]
		public var contacts:ArrayCollection;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(container);
			output.writeObject(contacts);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			container = input.readUTF()as String;
			contacts = input.readObject()as ArrayCollection;
		}
		
		public function getKeys():Array {
			var tempKeys = new Array();
			for (var contact in contacts) {
				tempKeys.push(contacts[contact].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var contact in contacts) {
				if ((contacts[contact].active != "Y") && (contacts[contact].active != "N")) {
					flag = "error";
					appendValidationMsg("Active flag is invalid");
				}
				
				if (contacts[contact].active =="Y"){
					if ((contacts[contact].name == undefined) || (contacts[contact].name == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((contacts[contact].display_name == undefined) || (contacts[contact].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					} else {
						if (Application.application.isKeyUsed(contacts[contact].display_name) == false) {
							flag = "error";
							appendValidationMsg(contacts[contact].display_name +" Key is not used");
						}
					}
					if ((contacts[contact].box == undefined) || (contacts[contact].box == "")) {
						flag = "error";
						appendValidationMsg("Box is empty");
					}
					if ((contacts[contact].key == undefined) || (contacts[contact].key == "")) {
						flag = "error";
						appendValidationMsg("Input key is empty");
					}
				}
				else {
					flag = "empty";
					appendValidationMsg("Contact Closures is not Active");
				}
			}
			return flag;
			
		}
		public override function getForm():String {
			return "forms.project.device.contact";
		}
		public override function toXML():XML {
			if (container.length == 0) {
				return XML();
			}
			
			var contactsNode = new XML("<"+container+" />");
			for (var contact in contacts) {
				var newContact = new XML("<CONTACT_CLOSURE />");
				if (contacts[contact].name != "") {
					newContact.@NAME = contacts[contact].name;
				}
				if (contacts[contact].display_name != "") {
					newContact.@DISPLAY_NAME = contacts[contact].display_name;
				}
				if (contacts[contact].key != "") {
					newContact.@KEY = contacts[contact].key;
				}
				if (contacts[contact].active != "") {
					newContact.@ACTIVE = contacts[contact].active;
				}
				if (contacts[contact].box != "") {
					newContact.@BOX = contacts[contact].box;
				}
				contactsNode.appendChild(newContact);
			}
			return contactsNode;
		}
		public override function getName():String {
			return "Contact Closures";
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "ContactClosures";
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.ContactClosures_frm;
			return className;		
		}
		
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			contacts = newData.contacts;
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy({contacts:contacts, dataObject:this});
			return ob;
		}
		
		public override function setXML(newData:XML):void {
			contacts = new ArrayCollection();
			container = newData.name();
			for (var child:int=0 ; child < newData.children().length() ; child++) {
			
				var newContact = new Object();
				newContact.name = "";
				newContact.display_name = "";
				newContact.key = "";
				newContact.active = "Y";
				newContact.box = "";
				if (newData.children()[child].@NAME != undefined) {
					newContact.name = newData.children()[child].@NAME;
				}
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newContact.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@KEY != undefined) {
					newContact.key = newData.children()[child].@KEY;
				}
				if (newData.children()[child].@ACTIVE != undefined) {
					newContact.active = newData.children()[child].@ACTIVE;
				}
				if (newData.children()[child].@BOX != undefined) {
					newContact.box = newData.children()[child].@BOX;
				}
				contacts.addItem(newContact);
			}
		}
	}
}