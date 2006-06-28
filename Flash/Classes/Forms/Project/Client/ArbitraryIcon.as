import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ArbitraryIcon extends Forms.BaseForm {
	private var icon1_cmb:ComboBox;
	private var icon1_ldr:Loader;
	private var icon2_cmb:ComboBox;
	private var icon2_ldr:Loader;
	private var command_cmb:ComboBox;
	private var command2_cmb:ComboBox;
	private var key_cmb:ComboBox;
	private var currentAlert:Object;
	public function onLoad():Void {
		var DPControl = new Array();
		DPControl.push({label:"channel"});
		DPControl.push({label:"down"});
		DPControl.push({label:"goto"});
		DPControl.push({label:"keyPress"})
		DPControl.push({label:"on"});
		DPControl.push({label:"off"});
		DPControl.push({label:"pan"});
		DPControl.push({label:"pause"});
		DPControl.push({label:"tilt"});
		DPControl.push({label:"volume"});
		DPControl.push({label:"send_audio_command"});
		DPControl.push({label:"src"});
//		DPControl.push({label:"state"});
		DPControl.push({label:"up"});
		command_cmb.dataProvider = DPControl;
		command2_cmb.dataProvider = DPControl;
		command_cmb.text = currentAlert.command;
		command2_cmb.text = currentAlert.command2;
		icon1_ldr.autoLoad = true;
		icon1_ldr.scaleContent = true;
		icon1_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		icon2_ldr.autoLoad = true;
		icon2_ldr.scaleContent = true;
		icon2_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		var myIcons = mdm.FileSystem.getFileList(mdm.Application.path + "lib\\icons", "*.png");
		icon1_cmb.addItem({label:"No Icon",icon:""});
		icon2_cmb.addItem({label:"No Icon",icon:""});
		for (var myIcon = 0; myIcon < myIcons.length; myIcon++) {
			var newIcon = new Object();
			newIcon.label = myIcons[myIcon].split(".")[0];
			newIcon.icon = mdm.Application.path + "lib\\icons\\" + myIcons[myIcon];
			icon1_cmb.addItem(newIcon);
			icon2_cmb.addItem(newIcon);
		}
		if (currentAlert.icon1.length) {
			icon1_cmb.text = currentAlert.icon1;
			icon1_ldr.load(mdm.Application.path + "lib\\icons\\" + currentAlert.icon1 + ".png");
		}
		if (currentAlert.icon2.length) {
			icon2_cmb.text = currentAlert.icon2;
			icon2_ldr.load(mdm.Application.path + "lib\\icons\\" + currentAlert.icon2 + ".png");
		}
		var tempKeys = _global.serverDesign.getKeys();
		var DPKey = new Array();
		DPKey.push({label:""});
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			DPKey.push(tempObject);
		}
		key_cmb.dataProvider = DPKey;
		key_cmb.text = currentAlert.key;
		icon1_cmb.addEventListener("change", Delegate.create(this, loadIcon1));
		icon2_cmb.addEventListener("change", Delegate.create(this, loadIcon2));
		command_cmb.addEventListener("change", Delegate.create(this,changeListener));
		command2_cmb.addEventListener("change", Delegate.create(this,changeListener));
		key_cmb.addEventListener("change",Delegate.create(this, changeListener));
	}
	function changeListener() {
		_global.unSaved = true;
		currentAlert.command = command_cmb.text;
		currentAlert.command2 = command2_cmb.text;
		currentAlert.key = key_cmb.text;
	}
	public function loadIcon1(eventObject) {
		_global.unSaved = true;
		icon1_ldr.load(icon1_cmb.selectedItem.icon);
		currentAlert.icon1 = icon1_cmb.selectedItem.label;
	}
	public function loadIcon2(eventObject) {
		_global.unSaved = true;
		icon2_ldr.load(icon2_cmb.selectedItem.icon);
		currentAlert.icon2 = icon2_cmb.selectedItem.label;
	}
}
