import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.JRobin.Data {
	private var display_name:String;
	private var variable:String;
	private var source:String;
	private var search_value:String;
	private var dataSource:String;
	private var func:String;
	private var display_name_lb:Label;
	private var display_name_ti:TextInput;
	private var variable_lb:Label;
	private var variable_ti:TextInput;
	private var source_lb:Label;
	private var source_cb:ComboBox;
	private var search_value_lb:Label;
	private var search_value_ti:TextInput;
	private var dataSource_lb:Label;
	private var dataSource_ti:TextInput;
	private var func_lb:Label;
	private var func_cb:ComboBox;
	function Data() {
	}
	public function init():Void {
		display_name_ti.text = display_name;
		variable_ti.text = variable;
		search_value_ti.text = search_value;
		dataSource_ti.text = dataSource;
		switch (source) {
		case "USAGE" :
			source_cb.selectedIndex = 0;
			break;
		case "EXTRA_VALUE1" :
			source_cb.selectedIndex = 1;
			break;
		case "EXTRA_VALUE2" :
			source_cb.selectedIndex = 2;
			break;
		case "EXTRA_VALUE3" :
			source_cb.selectedIndex = 3;
			break;
		case "EXTRA_VALUE4" :
			source_cb.selectedIndex = 4;
			break;
		case "EXTRA_VALUE5" :
			source_cb.selectedIndex = 5;
			break;
		default :
			break;
		}
		switch (func) {
		case "TOTAL" :
			func_cb.selectedIndex = 0;
			break;
		case "AVG" :
			func_cb.selectedIndex = 1;
			break;
		case "MIN" :
			func_cb.selectedIndex = 2;
			break;
		case "MAX" :
			func_cb.selectedIndex = 3;
			break;
		default :
			break;
		}
		source_cb.addEventListener("change", Delegate.create(this, sourceSelection));
		func_cb.addEventListener("change", Delegate.create(this, funcSelection));
	}
	private function sourceSelection(eventObj):Void {
		source = source_cb.selectedItem.label;
	}
	private function funcSelection(eventObj):Void {
		func = func_cb.selectedItem.label;
	}
}
