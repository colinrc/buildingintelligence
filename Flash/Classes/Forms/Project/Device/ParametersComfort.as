import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.ParametersComfort extends Forms.BaseForm {
	private var parameters:Array;
	private var device_type;
	private var poll_ti:TextInput;
	private var analog_poll_ti:TextInput;
	private var keypad_ti:TextInput;
	private var cbus_chk:CheckBox;
	private var cbus_app_ti:TextInput;
	private var cbus_ucm_ti:TextInput;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		poll_ti.addEventListener("change", changeListener);		
		analog_poll_ti.addEventListener("change", changeListener);		
		keypad_ti.addEventListener("change", changeListener);		
		cbus_chk.addEventListener("change", changeListener);		
		cbus_app_ti.addEventListener("change", changeListener);
		cbus_ucm_ti.addEventListener("change", changeListener);				
		poll_ti.restrict = "0-9";
		analog_poll_ti.restrict = "0-9";
		cbus_app_ti.restrict = "0-9";
		cbus_ucm_ti.restrict = "0-9";
		cbus_chk.selected = false;
		setOn();
		for (var parameter in parameters) {
			switch (parameters[parameters].attributes["NAME"]) {
			case "POLL_INTERVAL" :
				poll_ti.text = parameters[parameters].attributes["VALUE"];
				break;
			case "ANALOGUE_POLL_INTERVAL" :
				analog_poll_ti.text = parameters[parameters].attributes["VALUE"];
				break;
			case "SHOW_KEYPAD_MODES" :
				keypad_ti.text = parameters[parameters].attributes["VALUE"];
				break;
			case "CBUS_APPLICATION" :
				cbus_app_ti.text = parameters[parameters].attributes["VALUE"];
				cbus_chk.selected = true;
				setOn();
				break;
			case "CBUS_UCM" :
				cbus_ucm_ti.text = parameters[parameters].attributes["VALUE"];
				cbus_chk.selected = true;
				setOn();
				break;
			}
		}
		cbus_chk.addEventListener("click", Delegate.create(this, setOn));
	}
	public function setOn() {
		cbus_app_ti.enabled = cbus_chk.selected;
		cbus_ucm_ti.enabled = cbus_chk.selected;
	}
	public function getData():Object {
		var newParameters = new Array();
		var item = new XMLNode(1, "ITEM");
		item.attributes["NAME"] = "POLL_INTERVAL";
		item.attributes["VALUE"] = poll_ti.text;
		newParameters.push(item);
		item = new XMLNode(1, "ITEM");
		item.attributes["NAME"] = "ANALOGUE_POLL_INTERVAL";
		item.attributes["VALUE"] = analog_poll_ti.text;
		newParameters.push(item);
		item = new XMLNode(1, "ITEM");
		item.attributes["NAME"] = "SHOW_KEYPAD_MODES";
		item.attributes["VALUE"] = keypad_ti.text;
		newParameters.push(item);
		if (cbus_chk.selected) {
			item = new XMLNode(1, "ITEM");
			item.attributes["NAME"] = "CBUS_APPLICATION";
			item.attributes["VALUE"] = cbus_app_ti.text;
			newParameters.push(item);
			item = new XMLNode(1, "ITEM");
			item.attributes["NAME"] = "CBUS_UCM";
			item.attributes["VALUE"] = cbus_ucm_ti.text;
			newParameters.push(item);
		}
		return newParameters;
	}
}
