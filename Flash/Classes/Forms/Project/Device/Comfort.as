import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Device.Comfort extends Forms.BaseForm {
	private var device:Object;
	private var scrollBar:mx.containers.ScrollPane;
	private var save_btn:mx.controls.Button;
	public function init():Void {
		save_btn.addEventListener("click", Delegate.create(this, save));
		scrollBar.content.x10_mc.lights = device.x10;
		scrollBar.content.cbus_mc.lights = device.cbus;
		scrollBar.content.alarm_mc.alarms = device.alarms;
		scrollBar.content.pulse_mc.toggles = device.pulses;
		scrollBar.content.pulse_mc.title_lb.text = "PULSE_OUTPUT";
		scrollBar.content.alerts_mc.alerts = device.alerts;
		scrollBar.content.customs_mc.customs = device.customs;
		scrollBar.content.counter_mc.counters = device.counters;
		scrollBar.content.monitors_mc.monitors = device.monitors;
		scrollBar.content.analogue_mc.analogues = device.analogues;
		scrollBar.content.toggle_inputs_mc.toggles = device.toggle_inputs;
		scrollBar.content.toggle_inputs_mc.title_lb.text = "TOGGLE_INPUT";
		scrollBar.content.interfaces_mc.interfaces = device.raw_interfaces;
		scrollBar.content.toggle_outputs_mc.toggles = device.toggle_outputs;
		scrollBar.content.toggle_outputs_mc.title_lb.text = "TOGGLE_OUTPUT";
	}
	private function save():Void {
		device.x10 = scrollBar.content.x10_mc.getData();
		device.cbus = scrollBar.content.cbus_mc.getData();
		device.alarms = scrollBar.content.alarm_mc.getData();
		device.pulses = scrollBar.content.pulse_mc.getData();
		device.alerts = scrollBar.content.alerts_mc.getData();
		device.customs = scrollBar.content.customs_mc.getData();
		device.counters = scrollBar.content.counter_mc.getData();
		device.monitors = scrollBar.content.monitors_mc.getData();
		device.analogues = scrollBar.content.analogue_mc.getData();
		device.toggle_inputs = scrollBar.content.toggle_inputs_mc.getData();
		device.raw_interfaces = scrollBar.content.intefaces_mc.getData();
		device.toggle_outputs = scrollBar.content.toggle_outputs_mc.getData();
		_global.left_tree.selectedNode.device = device;
	}
}
