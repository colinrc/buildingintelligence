import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ControlTypeToggle extends Forms.BaseForm {
	private var object:XMLNode;
	private var icon1_cmb:ComboBox;
	private var icon2_cmb:ComboBox;
	private var extras_ti:TextInput;
	private var width_ti:TextInput;
	private var command_ti:TextInput;
	private var sounds_ti:TextInput;
	private var delete_btn:Button;
	private var update_btn:Button;
	public function onLoad() {
		icon1_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		icon2_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		var myIcons = mdm.FileSystem.getFileList(mdm.Application.path+"lib\\icons", "*.png");
		var IconDP = new Array();
		IconDP.push({label:"No Icon",icon:""});
		for(var myIcon =0; myIcon <myIcons.length; myIcon++){
			var newIcon = new Object();
			newIcon.label = myIcons[myIcon].split(".")[0];
			newIcon.icon = mdm.Application.path+"lib\\icons\\"+myIcons[myIcon];
			IconDP.push(newIcon);
		}
		icon1_cmb.dataProvider = IconDP;
		icon2_cmb.dataProvider = IconDP;
		icon1_cmb.addEventListener("change", Delegate.create(this, changeListener));
		icon2_cmb.addEventListener("change", Delegate.create(this, changeListener));
		extras_ti.addEventListener("change", Delegate.create(this, changeListener));
		width_ti.addEventListener("change", Delegate.create(this, changeListener));
		command_ti.addEventListener("change", Delegate.create(this, changeListener));
		sounds_ti.addEventListener("change", Delegate.create(this, changeListener));
		if (object.attributes["icons"] != undefined) {
			var newIcons = object.attributes["icons"].split(",");
			if (newIcons[0].length) {
				icon1_cmb.text = newIcons[0];
			}
			if (newIcons[1].length) {
				icon2_cmb.text = newIcons[1];
			}
		}
		if (object.attributes["extras"] != undefined) {
			extras_ti.text = object.attributes["extras"];
		} else {
			extras_ti.text = "";
		}
		if (object.attributes["width"] != undefined) {
			width_ti.text = object.attributes["width"];
		} else {
			width_ti.text = "";
		}
		if (object.attributes["command"] != undefined) {
			command_ti.text = object.attributes["command"];
		} else {
			command_ti.text = "";
		}
		if (object.attributes["sounds"] != undefined) {
			sounds_ti.text = object.attributes["sounds"];
		} else {
			sounds_ti.text = "";
		}
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
	}
	public function deleteItem() {
	}
	public function changeListener(eventObject:Object) {
		_global.unSaved = true;
		if (icon1_cmb.text != "No Icon") {
			if (icon2_cmb.text != "No Icon") {
				var newIcons = new Array();
				newIcons.push(icon1_cmb.text);
				newIcons.push(icon2_cmb.text);
				object.attributes["icons"] = newIcons.join(",");
			} else {
				object.attributes["icons"] = icon1_cmb.text;
			}
		} else {
			if (icon2_cmb.text != "No Icon") {
				object.attributes["icons"] = icon2_cmb.text;
			}
		}
		object.attributes["extras"] = extras_ti.text;
		object.attributes["width"] = width_ti.text;
		object.attributes["command"] = command_ti.text;
		object.attributes["sounds"] = sounds_ti.text;
	}
}
