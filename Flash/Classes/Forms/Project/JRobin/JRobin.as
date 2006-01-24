import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.JRobin.JRobin extends Forms.BaseForm {
	private var active_lb:Label;
	private var active_cb:ComboBox;
	private var interval_lb:Label;
	private var interval_ti:TextInput;
	private var rrd_label:Label;
	private var rrd_ti:TextInput;
	private var active:String;
	private var interval:String;
	private var rrd:String;
	function JRobin() {
	}
	public function init():Void {
		active_lb.text = "Active:";
		if (active == "Y") {
			active_cb.selectedIndex = 1;
		} else {
			active_cb.selectedIndex = 0;
		}
		interval_ti.text = interval;
		rrd_ti.text = rrd;
		active_cb.addEventListener("change", Delegate.create(this, activeSelection));
	}
	private function activeSelection(eventObj):Void {
		active = active_cb.selectedItem.label;
	}
}
