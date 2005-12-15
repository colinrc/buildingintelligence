import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.LogLevels {
	private var server_socket:XMLSocket;
	private var monitor_socket:XMLSocket;
	private var admin_cb:mx.controls.ComboBox;
	private var admin_lb:mx.controls.Label;
	private var bi_cb:mx.controls.ComboBox;
	private var bi_lb:mx.controls.Label;
	private var cbus_cb:mx.controls.ComboBox;
	private var cbus_lb:mx.controls.Label;
	private var client_cb:mx.controls.ComboBox;
	private var client_lb:mx.controls.Label;
	private var comfort_cb:mx.controls.ComboBox;
	private var comfort_lb:mx.controls.Label;
	private var comms_cb:mx.controls.ComboBox;
	private var comms_lb:mx.controls.Label;
	private var config_cb:mx.controls.ComboBox;
	private var config_lb:mx.controls.Label;
	private var dynalite_cb:mx.controls.ComboBox;
	private var dynalite_lb:mx.controls.Label;
	private var gc100_cb:mx.controls.ComboBox;
	private var gc100_lb:mx.controls.Label;
	private var global_cb:mx.controls.ComboBox;
	private var global_lb:mx.controls.Label;
	private var hal_cb:mx.controls.ComboBox;
	private var hal_lb:mx.controls.Label;
	private var ir_learner_cb:mx.controls.ComboBox;
	private var ir_learner_lb:mx.controls.Label;
	private var jrobin_cb:mx.controls.ComboBox;
	private var jrobin_lb:mx.controls.Label;
	private var kramer_cb:mx.controls.ComboBox;
	private var kramer_lb:mx.controls.Label;
	private var macro_cb:mx.controls.ComboBox;
	private var macro_lb:mx.controls.Label;
	private var oregon_cb:mx.controls.ComboBox;
	private var oregon_lb:mx.controls.Label;
	private var pelco_cb:mx.controls.ComboBox;
	private var pelco_lb:mx.controls.Label;
	private var raw_cb:mx.controls.ComboBox;
	private var raw_lb:mx.controls.Label;
	private var script_cb:mx.controls.ComboBox;
	private var script_lb:mx.controls.Label;
	private var tutondo_cb:mx.controls.ComboBox;
	private var tutondo_lb:mx.controls.Label;
	function LogLevels() {
	}
	public function setSockets(inMonitor_socket:XMLSocket, inServer_socket:XMLSocket) {
		server_socket = inServer_socket;
		monitor_socket = inMonitor_socket;
	}
	public function init():Void {
		admin_cb.addEventListener("change", Delegate.create(this, comboSelection));
		bi_cb.addEventListener("change", Delegate.create(this, comboSelection));
		cbus_cb.addEventListener("change", Delegate.create(this, comboSelection));
		client_cb.addEventListener("change", Delegate.create(this, comboSelection));
		comfort_cb.addEventListener("change", Delegate.create(this, comboSelection));
		comms_cb.addEventListener("change", Delegate.create(this, comboSelection));
		config_cb.addEventListener("change", Delegate.create(this, comboSelection));
		dynalite_cb.addEventListener("change", Delegate.create(this, comboSelection));
		gc100_cb.addEventListener("change", Delegate.create(this, comboSelection));
		global_cb.addEventListener("change", Delegate.create(this, comboSelection));
		hal_cb.addEventListener("change", Delegate.create(this, comboSelection));
		ir_learner_cb.addEventListener("change", Delegate.create(this, comboSelection));
		jrobin_cb.addEventListener("change", Delegate.create(this, comboSelection));
		kramer_cb.addEventListener("change", Delegate.create(this, comboSelection));
		macro_cb.addEventListener("change", Delegate.create(this, comboSelection));
		oregon_cb.addEventListener("change", Delegate.create(this, comboSelection));
		pelco_cb.addEventListener("change", Delegate.create(this, comboSelection));
		raw_cb.addEventListener("change", Delegate.create(this, comboSelection));
		script_cb.addEventListener("change", Delegate.create(this, comboSelection));
		tutondo_cb.addEventListener("change", Delegate.create(this, comboSelection));
	}
	public function comboSelection(eventObj) {
		switch (eventObj.target) {
		case admin_cb :
			changeDebugLevels(admin_cb.selectedItem.data, "au.com.BI.Admin");
			break;
		case bi_cb :
			changeDebugLevels(bi_cb.selectedItem.data, "au.com.BI");
			break;
		case cbus_cb :
			changeDebugLevels(cbus_cb.selectedItem.data, "au.com.BI.CBUS");
			break;
		case client_cb :
			changeDebugLevels(client_cb.selectedItem.data, "au.com.BI.Flash");
			break;
		case comfort_cb :
			changeDebugLevels(comfort_cb.selectedItem.data, "au.com.BI.Comfort");
			break;
		case comms_cb :
			changeDebugLevels(comms_cb.selectedItem.data, "au.com.BI.Comms");
			break;
		case config_cb :
			changeDebugLevels(config_cb.selectedItem.data, "au.com.BI.Config");
			break;
		case dynalite_cb :
			changeDebugLevels(dynalite_cb.selectedItem.data, "au.com.BI.Dynalite");
			break;
		case gc100_cb :
			changeDebugLevels(gc100_cb.selectedItem.data, "au.com.BI.GC100");
			break;
		case global_cb :
			changeDebugLevels(global_cb.selectedItem.data, "au.com");
			break;
		case hal_cb :
			changeDebugLevels(hal_cb.selectedItem.data, "au.com.BI.HAL");
			break;
		case ir_learner_cb :
			changeDebugLevels(ir_learner_cb.selectedItem.data, "au.com.BI.IR");
			break;
		case jrobin_cb :
			changeDebugLevels(jrobin_cb.selectedItem.data, "au.com.BI.JRobin");
			break;
		case kramer_cb :
			changeDebugLevels(kramer_cb.selectedItem.data, "au.com.BI.Kramer");
			break;
		case macro_cb :
			changeDebugLevels(macro_cb.selectedItem.data, "au.com.BI.Macro");
			break;
		case oregon_cb :
			changeDebugLevels(oregon_cb.selectedItem.data, "au.com.BI.OregonScientific");
			break;
		case pelco_cb :
			changeDebugLevels(pelco_cb.selectedItem.data, "au.com.BI.Pelco");
			break;
		case raw_cb :
			changeDebugLevels(raw_cb.selectedItem.data, "au.com.BI.Raw");
			break;
		case script_cb :
			changeDebugLevels(script_cb.selectedItem.data, "au.com.BI.Script");
			break;
		case tutondo_cb :
			changeDebugLevels(tutondo_cb.selectedItem.data, "au.com.BI.Tutondo");
			break;
		}
	}
	public function setVisible(showing:Boolean):Void {
		if (showing == true) {
			getDebugLevels();
		}
		admin_cb._visible = showing;
		admin_lb._visible = showing;
		bi_cb._visible = showing;
		bi_lb._visible = showing;
		cbus_cb._visible = showing;
		cbus_lb._visible = showing;
		client_cb._visible = showing;
		client_lb._visible = showing;
		comfort_cb._visible = showing;
		comfort_lb._visible = showing;
		comms_cb._visible = showing;
		comms_lb._visible = showing;
		config_cb._visible = showing;
		config_lb._visible = showing;
		dynalite_cb._visible = showing;
		dynalite_lb._visible = showing;
		gc100_cb._visible = showing;
		gc100_lb._visible = showing;
		global_cb._visible = showing;
		global_lb._visible = showing;
		hal_cb._visible = showing;
		hal_lb._visible = showing;
		ir_learner_cb._visible = showing;
		ir_learner_lb._visible = showing;
		jrobin_cb._visible = showing;
		jrobin_lb._visible = showing;
		kramer_cb._visible = showing;
		kramer_lb._visible = showing;
		macro_cb._visible = showing;
		macro_lb._visible = showing;
		oregon_cb._visible = showing;
		oregon_lb._visible = showing;
		pelco_cb._visible = showing;
		pelco_lb._visible = showing;
		raw_cb._visible = showing;
		raw_lb._visible = showing;
		script_cb._visible = showing;
		script_lb._visible = showing;
		tutondo_cb._visible = showing;
		tutondo_lb._visible = showing;
	}
	function generateDebugLevels(inLevels:XMLNode) {
		var inNode:XMLNode = inLevels.firstChild;
		while (inNode != null) {
			//Script, comms and config all behave strangely, changing BI sets all 3 values
			switch (inNode.attributes["SHORTNAME"]) {
			case "Global" :
				setDebugMenuLevel(global_cb, inNode.attributes["LEVEL"]);
				break;
			case "Config" :
				setDebugMenuLevel(config_cb, inNode.attributes["LEVEL"]);
				break;
			case "Comms" :
				setDebugMenuLevel(comms_cb, inNode.attributes["LEVEL"]);
				break;
			case "Script" :
				setDebugMenuLevel(config_cb, inNode.attributes["LEVEL"]);
				break;
			case "COMFORT" :
				setDebugMenuLevel(comfort_cb, inNode.attributes["LEVEL"]);
				break;
			case "OREGON" :
				setDebugMenuLevel(oregon_cb, inNode.attributes["LEVEL"]);
				break;
			case "KRAMER" :
				setDebugMenuLevel(kramer_cb, inNode.attributes["LEVEL"]);
				break;
			case "RAW_CONNECTION" :
				setDebugMenuLevel(raw_cb, inNode.attributes["LEVEL"]);
				break;
			case "FLASH_CLIENT" :
				setDebugMenuLevel(client_cb, inNode.attributes["LEVEL"]);
				break;
			case "PELCO" :
				setDebugMenuLevel(pelco_cb, inNode.attributes["LEVEL"]);
				break;
			case "SCRIPT" :
				setDebugMenuLevel(script_cb, inNode.attributes["LEVEL"]);
				break;
			case "HAL" :
				setDebugMenuLevel(hal_cb, inNode.attributes["LEVEL"]);
				break;
			case "CBUS" :
				setDebugMenuLevel(cbus_cb, inNode.attributes["LEVEL"]);
				break;
			case "ADMIN" :
				setDebugMenuLevel(admin_cb, inNode.attributes["LEVEL"]);
				break;
			case "MACRO" :
				setDebugMenuLevel(macro_cb, inNode.attributes["LEVEL"]);
				break;
			case "DYNALITE" :
				setDebugMenuLevel(dynalite_cb, inNode.attributes["LEVEL"]);
				break;
			case "IR_LEARNER" :
				setDebugMenuLevel(ir_learner_cb, inNode.attributes["LEVEL"]);
				break;
			case "TUTONDO" :
				setDebugMenuLevel(tutondo_cb, inNode.attributes["LEVEL"]);
				break;
			case "GC100" :
				setDebugMenuLevel(gc100_cb, inNode.attributes["LEVEL"]);
				break;
			}
			inNode = inNode.nextSibling;
		}
	}
	function setDebugMenuLevel(menu, level) {
		switch (level) {
		case "WARNING" :
			menu.selectedIndex = 0;
			break;
		case "INFO" :
			menu.selectedIndex = 1;
			break;
		case "FINE" :
			menu.selectedIndex = 2;
			break;
		case "FINER" :
			menu.selectedIndex = 3;
			break;
		case "FINEST" :
			menu.selectedIndex = 4;
			break;
		}
	}
	function changeDebugLevels(level:String, package:String) {
		var xmlMsg = new XML('<DEBUG PACKAGE="'+package+'" LEVEL="'+level+'" />\n');
		server_socket.send(xmlMsg);
		getDebugLevels();
	}
	function getDebugLevels() {
		var xmlMsg = new XML('<DEBUG_PACKAGES />\n');
		server_socket.send(xmlMsg);
	}
}
