import mx.controls.*;
class Forms.Project.Device.IP extends Forms.BaseForm {
	private var node:XMLNode;
	private var address_ti:TextInput;
	private var port_ti:TextInput;
	public function IP() {
	}
	public function onLoad():Void {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		address_ti.addEventListener("change", changeListener);
		port_ti.addEventListener("change", changeListener);
		address_ti.restrict = "0-9.";
		address_ti.maxChars = 15;
		port_ti.restrict = "0-9";
		port_ti.maxChars = 5;
		address_ti.text = "";
		port_ti.text = "";
		if (node.attributes["IP_ADDRESS"] != undefined) {
			address_ti.text = node.attributes["IP_ADDRESS"];
		}
		if (node.attributes["PORT"] != undefined) {
			port_ti.text = node.attributes["PORT"];
		}
	}
	public function getData():Object {
		return {address:address_ti.text, port:port_ti.text};
	}
}
