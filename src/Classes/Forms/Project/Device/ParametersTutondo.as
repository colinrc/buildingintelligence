import mx.controls.*;
class Forms.Project.Device.ParametersTutondo extends Forms.BaseForm {
	private var parameters:Array;
	private var device_type;
	private var poll_ti:TextInput;
	private var protocol_cmb:ComboBox;	
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		poll_ti.addEventListener("change", changeListener);
		protocol_cmb.addEventListener("change", changeListener);		
		poll_ti.restrict = "0-9";
		for (var parameter in parameters) {
			if (parameters[parameter].attributes["NAME"] == "POLL_INTERVAL") {
				poll_ti.text = parameters[parameter].attributes["VALUE"];
			} else if (parameters[parameter].attributes["NAME"] == "PROTOCOL") {
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
		var item = new XMLNode(1, "ITEM");
		item.attributes["NAME"] = "POLL_INTERVAL";
		item.attributes["VALUE"] = poll_ti.text;
		newParameters.push(item);
		return newParameters;
	}
}
