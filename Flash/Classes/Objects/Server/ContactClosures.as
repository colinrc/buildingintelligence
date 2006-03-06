class Objects.Server.ContactClosures extends Objects.BaseElement {
	private var container:String;
	private var contacts:Array;
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var contact in contacts) {
			tempKeys.push(contacts[contact].display_name);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var contact in contacts) {
			if ((contacts[contact].attributes["ACTIVE"] != "Y") && (contacts[contact].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((contacts[contact].attributes["KEY"] == undefined) || (contacts[contact].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((contacts[contact].attributes["BOX"] == undefined) || (contacts[contact].attributes["BOX"] == "")) {
				flag = false;
			}
			if ((contacts[contact].attributes["NAME"] == undefined) || (contacts[contact].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((contacts[contact].attributes["DISPLAY_NAME"] == undefined) || (contacts[contact].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
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
