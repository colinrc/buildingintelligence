import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.CalendarSettings extends Forms.BaseForm {
	private var settings:XMLNode;
	private var save_btn:mx.controls.Button;
	private var hideclose_chk:mx.controls.CheckBox;
	private var icon_ti:mx.controls.TextInput;
	private var autoclose_ti:mx.controls.TextInput;
	private var dataObject:Object;
	public function onLoad():Void {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		hideclose_chk.addEventListener("change", changeListener);
		icon_ti.addEventListener("change", changeListener);
		autoclose_ti.addEventListener("change", changeListener);
		autoclose_ti.restrict = "0-9";
		for (var child in settings.childNodes) {
			if (settings.childNodes[child].attributes["NAME"] == "AUTOCLOSE") {
				autoclose_ti.text = settings.childNodes[child].attributes["VALUE"];
			}
			if (settings.childNodes[child].attributes["NAME"] == "ICON") {
				icon_ti.text = settings.childNodes[child].attributes["VALUE"];
			}
			if (settings.childNodes[child].attributes["NAME"] == "AUTOCLOSE") {
				if ("TRUE" == settings.childNodes[child].attributes["VALUE"]) {
					hideclose_chk.selected = true;
				}
			}
		}
		save_btn.addEventListener("click", Delegate.create(this, save));
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
		if (icon_ti.text.length) {
			newItem = new XMLNode(1, "ITEM");
			newItem.attributes["NAME"] = "ICON";
			newItem.attributes["VALUE"] = icon_ti.text;
		}
		newSettings.appendChild(newItem);
		dataObject.setData({settings:newSettings});
		_global.saveFile("Project");
	}
}
