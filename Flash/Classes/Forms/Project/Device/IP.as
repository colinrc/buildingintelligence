import mx.controls.*;
class Forms.Project.Device.IP {
	private var node:XMLNode;
	private var address_ti:TextInput;
	private var port_ti:TextInput;
	public function IP(){
	}
	public function init():Void{
		address_ti.restrict = "0-9.";
		address_ti.maxChars = 15;
		port_ti.restrict = "0-9";
		port_ti.maxChars = 5;
		address_ti.text = node.attributes["IP_ADDRESS"];
		port_ti.text = node.attributes["PORT"];
	}
	public function getData():Object{
		return {address:address_ti.text, port:port_ti.text};
	}
}