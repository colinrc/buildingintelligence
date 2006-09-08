import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Head extends Forms.BaseForm {
	private var device_type:String;
	private var description:String;
	private var active:String;
	private var connection:XMLNode;
	private var parameters:Array;
	private var connection_mc:MovieClip;
	private var parameters_mc:MovieClip;
	private var device_type_lb:mx.controls.Label;
	private var description_ti:mx.controls.TextInput;
	private var save_btn:mx.controls.Button;
	private var active_chk:mx.controls.CheckBox;
	private var dataObject:Object;		
	public function Head() {
	}
	public function onLoad():Void {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
		    _global.unSaved = true;
		};
		description_ti.addEventListener("change", changeListener);
		
		var checkBoxListener:Object = new Object();
	
		checkBoxListener.change = function(eventObject) {
		    _global.unSaved = true;
			if (active_chk.selected == false){
				active = "N";
			}else {
				active = "Y";
			}
		};
		active_chk.addEventListener("click", checkBoxListener);
		
		if (active == "N") {
			active_chk.selected = false;
		} else {
			active_chk.selected = true;
		}
		device_type_lb.text = device_type;
		description_ti.text = description;
		connection_mc.node = connection;
		save_btn.addEventListener("click", Delegate.create(this, save));	
		if(device_type.toLowerCase()!="custom_connection"){
			parameters_mc = this.attachMovie("forms.project.device.parameters"+device_type.toLowerCase(),"parameters_"+getNextHighestDepth()+"_mc",0,{parameters:parameters,device_type:device_type});
		} else{		
			parameters_mc = this.attachMovie("forms.project.device.parametersraw_connection","parameters_"+getNextHighestDepth()+"_mc",0,{parameters:parameters,device_type:device_type});
		}
		parameters_mc._x = 0;
		parameters_mc._y = 170;		
		setAdvanced();
	}
	public function setAdvanced(){
		if((device_type.toLowerCase()!= "raw_connection")||(device_type.toLowerCase()!= "custom_connection")){
			parameters_mc._visible = _global.advanced;
		}
	}			
	private function save():Void {
		var newData = new Object();
		newData.device_type = device_type_lb.text;
		newData.description = description_ti.text;
		if (active_chk.selected) {
			newData.active = "Y";
		} else {
			newData.active = "N";
		}
		newData.parameters = parameters_mc.getData();
		newData.connection = connection_mc.getData();
		dataObject.setData(newData);
		_global.refreshTheTree();		
		_global.saveFile("Project");				
	}
}
