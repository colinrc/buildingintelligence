﻿class Objects.Server.ContactClosures extends Objects.BaseElement {
	private var container:String;
	private var contacts:Array;
	var treeNode:XMLNode;			
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var contact in contacts) {
			tempKeys.push(contacts[contact].display_name);
		}
		return tempKeys;
	}
	public function isValid():String {
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
					if (_global.isKeyUsed(contacts[contact].display_name) == false) {
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
	public function getForm():String {
		return "forms.project.device.contact";
	}
	public function toXML():XMLNode {
		var contactsNode = new XMLNode(1, container);
		for (var contact in contacts) {
			var newContact = new XMLNode(1, "CONTACT_CLOSURE");
			if (contacts[contact].name != "") {
				newContact.attributes["NAME"] = contacts[contact].name;
			}
			if (contacts[contact].display_name != "") {
				newContact.attributes["DISPLAY_NAME"] = contacts[contact].display_name;
			}
			if (contacts[contact].key != "") {
				newContact.attributes["KEY"] = contacts[contact].key;
			}
			if (contacts[contact].active != "") {
				newContact.attributes["ACTIVE"] = contacts[contact].active;
			}
			if (contacts[contact].box != "") {
				newContact.attributes["BOX"] = contacts[contact].box;
			}
			contactsNode.appendChild(newContact);
		}
		return contactsNode;
	}
	public function getName():String {
		return "Contact Closures";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "ContactClosures";
	}
	public function setData(newData:Object) {
		contacts = newData.contacts;
	}
	public function getData():Object {
		return {contacts:contacts, dataObject:this};
	}
	public function setXML(newData:XMLNode):Void {
		contacts = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newContact = new Object();
			newContact.name = "";
			newContact.display_name = "";
			newContact.key = "";
			newContact.active = "Y";
			newContact.box = "";
			if (newData.childNodes[child].attributes["NAME"] != undefined) {
				newContact.name = newData.childNodes[child].attributes["NAME"];
			}
			if (newData.childNodes[child].attributes["DISPLAY_NAME"] != undefined) {
				newContact.display_name = newData.childNodes[child].attributes["DISPLAY_NAME"];
			}
			if (newData.childNodes[child].attributes["KEY"] != undefined) {
				newContact.key = newData.childNodes[child].attributes["KEY"];
			}
			if (newData.childNodes[child].attributes["ACTIVE"] != undefined) {
				newContact.active = newData.childNodes[child].attributes["ACTIVE"];
			}
			if (newData.childNodes[child].attributes["BOX"] != undefined) {
				newContact.box = newData.childNodes[child].attributes["BOX"];
			}
			contacts.push(newContact);
		}
	}
}
