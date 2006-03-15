import mx.controls.*;
import mx.utils.Delegate;
import mdm.Dialogs.BrowseFile;
class Forms.Project.Client.Icon extends Forms.BaseForm {
	private var save_btn:Button;
	private var name:String;
	private var name_ti:TextInput;
	private var icon:String;
	private var icon_ti:TextInput;
	private var func:String;
	private var func_cmb:ComboBox;
	private var canOpen:String;
	private var canOpen_chk:CheckBox;
	private var dataObject:Object;
	private var param:String;
	private var param_ti:TextInput;
	private var param_lb:Label;
	public function onLoad():Void {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
			if (func_cmb.text == "runexe") {
				param_ti.visible = true;
				param_lb.visible = true;
			} else {
				param_ti.visible = false;
				param_lb.visible = false;
				param_ti.text = "";
			}
		};
		if (func == "runexe") {
			param_ti.visible = true;
			param_lb.visible = true;
			param_ti.text = param;
		} else {
			param_ti.visible = false;
			param_lb.visible = false;
			param_ti.text = "";
		}
		name_ti.text = name;
		icon_ti.text = icon;
		func_cmb.text = func;
		if (canOpen == "superuser") {
			canOpen_chk.selected = true;
		} else {
			canOpen_chk.selected = false;
		}
		name_ti.addEventListener("change", Delegate.create(this,changeListener.change));
		icon_ti.addEventListener("change", Delegate.create(this,changeListener.change));
		func_cmb.addEventListener("change", Delegate.create(this,changeListener.change));
		canOpen_chk.addEventListener("change", Delegate.create(this,changeListener.change));
		param_ti.addEventListener("change", Delegate.create(this,changeListener.change));		
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function save() {
		if (canOpen_chk.selected) {
			var newCanOpen = "superuser";
		} else {
			var newCanOpen = "";
		}
		dataObject.setData({name:name_ti.text, icon:icon_ti.text, func:func_cmb.text, param:param_ti.text, canOpen:newCanOpen});
		_global.saveFile("Project");
	}
}