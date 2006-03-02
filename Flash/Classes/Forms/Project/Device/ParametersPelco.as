import mx.controls.*;
class Forms.Project.Device.ParametersPelco extends Forms.BaseForm {
	private var parameters:Array;
	private var device_type;
	private var protocol_cmb:ComboBox;
	public function onLoad() {
		for (var parameter in parameters) {
			if (parameters[parameter].attributes["NAME"] == "PROTOCOL") {
				for (var protocol in protocol_cmb.dataProvider) {
					if (parameters[parameter].attributes["VALUE"] == protocol_cmb.dataProvider[protocol].label) {
						protocol_cmb.selectedIndex = parseInt(protocol);
					}
				}
			}
		}
	}
	public function getData():Object {
		var newParameters = new Array();
		var item = new XMLNode(1, "ITEM");
		item.attributes["NAME"] = "PROTOCOL";
		item.attributes["VALUE"] = protocol_cmb.selectedItem.label;
		newParameters.push(item);
		return newParameters;
	}
}
