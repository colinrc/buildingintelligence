import mx.controls.*;

class Forms.Project.Device.Serial extends Forms.BaseForm {
	private var node:XMLNode;
	private var port_ti:TextInput;
	private var baud_ti:TextInput;
	private var parity_ti:TextInput;
	private var supportsCd_ti:TextInput;
	private var stopBits_cb:ComboBox;
	private var dataBits_cb:ComboBox;
	private var flow_cb:ComboBox;
	public function init():Void{
		if(node.attributes["PORT"] != undefined) {
			port_ti.text = node.attributes["PORT"];
		}
		if(node.attributes["BAUD"] != undefined) {
			baud_ti.text = node.attributes["BAUD"];
		}
		if(node.attributes["PARITY"] != undefined) {
			parity_ti.text = node.attributes["PARITY"];
		}
		if(node.attributes["SUPPORTS_CD"] != undefined) {
			supportsCd_ti.text = node.attributes["SUPPORTS_CD"];
		}
		if(node.attributes["STOP_BITS"] != undefined) {
			if(node.attributes["STOP_BITS"] == "0") {
				stopBits_cb.selectedIndex = 0;
			}
			else if (node.attributes["STOP_BITS"] == "1") {
				stopBits_cb.selectedIndex = 1;
			}
			else if (node.attributes["STOP_BITS"] == "2") {
				stopBits_cb.selectedIndex = 2;
			}
		}
		if(node.attributes["DATA_BITS"] != undefined) {
			if(node.attributes["DATA_BITS"] == "8") {
				dataBits_cb.selectedIndex = 0;
			}
			else {
				dataBits_cb.selectedIndex = 1;
			}
		}
		if(node.attributes["FLOW"] != undefined) {
			if(node.attributes["FLOW"] == "NONE") {
				flow_cb.selectedIndex = 0;
			}
			else if(node.attributes["FLOW"] == "RTSCTS") {
				flow_cb.selectedIndex = 1;
			}
		}
	}
	public function getData():Object{
		var dataObj = {port:port_ti.text, baud:baud_ti.text, parity:parity_ti.text, supportsCd:supportsCd_ti.text};
		dataObj.stopBits = stopBits_cb.selectedItem.label;
		dataObj.dataBits = dataBits_cb.selectedItem.label;
		dataObj.flow = flow_cb.selectedItem.label;
		return dataObj;
	}
}