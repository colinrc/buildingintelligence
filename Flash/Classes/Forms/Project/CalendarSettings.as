import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.CalendarSettings extends Forms.BaseForm {
	private var settings:XMLNode;
	private var save_btn:mx.controls.Button;
	private var hideclose_chk:mx.controls.CheckBox;
	private var icon_cmb:ComboBox;
	private var icon_ldr:Loader;
	private var autoclose_ti:mx.controls.TextInput;
	private var dataObject:Object;
	public function onLoad():Void {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		hideclose_chk.addEventListener("change", changeListener);
		icon_ldr.autoLoad = true;
		icon_ldr.scaleContent = true;
		icon_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		var myIcons = mdm.FileSystem.getFileList(mdm.Application.path + "lib\\icons", "*.png");
		for (var myIcon = 0; myIcon < myIcons.length; myIcon++) {
			var newIcon = new Object();
			newIcon.label = myIcons[myIcon].split(".")[0];
			newIcon.icon = mdm.Application.path + "lib\\icons\\" + myIcons[myIcon];
			icon_cmb.addItem(newIcon);
		}
		autoclose_ti.addEventListener("change", changeListener);
		autoclose_ti.restrict = "0-9";
		for (var child in settings.childNodes) {
			if (settings.childNodes[child].attributes["NAME"] == "AUTOCLOSE") {
				autoclose_ti.text = settings.childNodes[child].attributes["VALUE"];
			}
			if (settings.childNodes[child].attributes["NAME"] == "ICON") {
				var icon = settings.childNodes[child].attributes["VALUE"];
				for (var tempIcon = 0; tempIcon < icon_cmb.dataProvider.length; tempIcon++) {
					if (icon_cmb.dataProvider[tempIcon].label == icon) {
						icon_cmb.selectedIndex = tempIcon;
						icon_ldr.load(mdm.Application.path + "lib\\icons\\" + icon + ".png");
						break;
					}
				}
			}
			if (settings.childNodes[child].attributes["NAME"] == "AUTOCLOSE") {
				if ("TRUE" == settings.childNodes[child].attributes["VALUE"]) {
					hideclose_chk.selected = true;
				}
			}
		}
		save_btn.addEventListener("click", Delegate.create(this, save));
		icon_cmb.addEventListener("change", Delegate.create(this, loadIcon));
	}
	public function loadIcon(eventObject) {
		_global.unSaved = true;
		icon_ldr.load(icon_cmb.selectedItem.icon);
	}
	private function save():Void {
		var newSettings = new XMLNode(1, "CALENDAR_MESSAGES");
		var newItem = new XMLNode(1, "ITEM");
		newItem.attributes["NAME"] = "HIDECLOSE";
		if (hideclose_chk.selected) {
			newItem.attributes["VALUE"] = "TRUE";
		} else {
			newItem.attributes["VALUE"] = "FALSE";
		}
		newSettings.appendChild(newItem);
		if (autoclose_ti.text.length) {
			newItem = new XMLNode(1, "ITEM");
			newItem.attributes["NAME"] = "AUTOCLOSE";
			newItem.attributes["VALUE"] = autoclose_ti.text;
		}
		newSettings.appendChild(newItem);
		newItem = new XMLNode(1, "ITEM");
		newItem.attributes["NAME"] = "ICON";
		newItem.attributes["VALUE"] = icon_cmb.text;
		newSettings.appendChild(newItem);
		dataObject.setData({settings:newSettings});
		_global.refreshTheTree();
		_global.saveFile("Project");
	}
}
