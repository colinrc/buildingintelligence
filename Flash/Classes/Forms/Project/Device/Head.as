import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Head {
	private var node:XMLNode;
	private var connections:XMLNode;
	private var parameters:XMLNode;
	private var connection_mc:MovieClip;
	private var parameters_mc:MovieClip;
	private var form1_mc:mx.controls.Loader;
	private var form2_mc:mx.controls.Loader;
	private var form3_mc:mx.controls.Loader;
	private var form4_mc:mx.controls.Loader;
	private var name_ti:mx.controls.TextInput;
	private var dName_ti:mx.controls.TextInput;
	private var save_btn:mx.controls.Button;
	private var active_chk:mx.controls.CheckBox;
	public function Head() {
	}
	public function init():Void {
		name_ti.text= node.attributes["NAME"];
		dName_ti.text = node.attributes["DISPLAY_NAME"];
		var dataObj = {node:connections};
		connection_mc = form1_mc.attachMovie("forms.project.device.connection", "connection_mc", 0, dataObj);
		connection_mc.dataObj = dataObj;
		var dataObj = {node:parameters};
		parameters_mc = form2_mc.attachMovie("forms.project.device.parameters", "parameters_mc", 0, dataObj);
		parameters_mc.dataObj = dataObj;
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function save():Void{
		//var dataObj = connection_mc.getData()
		//trace(connection_mc.getData());
		//trace(parameters_mc.getData());
		_global.left_tree.selectedNode.connections =connection_mc.getData();
		_global.left_tree.selectedNode.parameters =parameters_mc.getData();
		trace(_global.left_tree.selectedNode);
	}
}
