import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Controls {
	private var controls:XMLNode;
	private var variables:XMLNode;
	private var messages:XMLNode;
	private var variables_mc:MovieClip;
	private var messages_mc:MovieClip;
	private var save_btn:mx.controls.Button;
	public function init():Void {
		save_btn.addEventListener("click", Delegate.create(this, save));
		for (var child in controls.childNodes){
			if(controls.childNodes[child].nodeName == "VARIABLES"){
				variables = controls.childNodes[child];
			}
			else if(controls.childNodes[child].nodeName == "CALENDAR_MESSAGES"){
				messages = controls.childNodes[child];
			}
		}
		variables_mc.variables = variables;
		messages_mc.node = messages;
	}
	private function save():Void {
		_global.left_tree.selectedNode.object.variables = variables_mc.getData();
		_global.left_tree.selectedNode.object.messages = messages_mc.getData();
	}
}
