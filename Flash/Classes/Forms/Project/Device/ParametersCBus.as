import mx.controls.*;
class Forms.Project.Device.ParametersCBus extends Forms.BaseForm {
	private var parameters:Array;
	private var device_type;
	private var poll_temp_interval_ti:TextInput;
	public function onLoad() {
		for(var parameter in parameters){
			poll_temp_interval_ti.restrict = "0-9";
			if(parameters[parameter].attributes["NAME"] == "POLL_TEMP_INTERVAL"){
				poll_temp_interval_ti.text = parameters[parameter].attributes["VALUE"];
			}
		}
	}
	public function getData():Object {
		var newParameters = new Array();
		var item = new XMLNode(1, "ITEM");
		item.attributes["NAME"] = "POLL_TEMP_INTERVAL";
		item.attributes["VALUE"] = poll_temp_interval_ti.text;
		newParameters.push(item);
		return newParameters;
	}
}