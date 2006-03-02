import mx.controls.*;
class Forms.Project.Device.ParametersHAL extends Forms.BaseForm {
	private var parameters:Array;
	private var device_type;
	private var poll_ti:TextInput;
	public function onLoad() {
		poll_ti.restrict = "0-9";
		for(var parameter in parameters){
			if(parameters[parameter].attributes["NAME"] == "POLL_INTERVAL"){
				poll_ti.text = parameters[parameter].attributes["VALUE"];
			}
		}		
	}
	public function getData():Object {
		var newParameters = new Array();
		var item = new XMLNode(1, "ITEM");
		item.attributes["NAME"] = "POLL_INTERVAL";
		item.attributes["VALUE"] = poll_ti.text;
		newParameters.push(item);
		return newParameters;
	}
}