class Objects.Server.ContactClosures extends Objects.BaseElement {
	private var container:String;
	private var contacts:Array;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var contact in contacts){
			tempKeys.push(contacts[contact].attributes["DISPLAY_NAME"]);
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
			contactsNode.appendChild(contacts[contact]);
		}
		return contactsNode;
	}
	public function getName():String {
		return "Contact Closures";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		_global.workflow.addNode("ContactClosures",newNode);
		return newNode;
	}
	public function setData(newData:Object){
		contacts = newData.contacts;
	}
	public function getData():Object {
		return new Object({contacts:contacts});
	}
	public function setXML(newData:XMLNode):Void {
		contacts = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			contacts.push(newData.childNodes[child]);
		}
	}
}
