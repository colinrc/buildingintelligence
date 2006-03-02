import mx.controls.*;
class Forms.Project.Device.ParametersOregon extends Forms.BaseForm {
	private var parameters:Array;
	private var device_type;
	private var model_cmb:ComboBox;	
	public function onLoad() {
		for(var parameter in parameters){
			if(parameters[parameter].attributes["NAME"] == "MODEL"){
				for(var model in model_cmb.dataProvider){
					if(parameters[parameter].attributes["VALUE"] == model_cmb.dataProvider[model].label){
						model_cmb.selectedIndex = parseInt(model);
					}
				}
			}
		}		
	}
	public function getData():Object {
		var newParameters = new Array();
		var item = new XMLNode(1, "ITEM");
		item.attributes["NAME"] = "MODEL";
		item.attributes["VALUE"] = model_cmb.selectedItem.label;
		newParameters.push(item);		
		return newParameters;
	}
}