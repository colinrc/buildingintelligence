import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Device.Alert {
	private var alerts:Array;
	private var alerts_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var key_ti:TextInput;
	private var dname_ti:TextInput;	
	private var cat_ti:TextInput;
	private var message_ti:TextInput;
	private var active_chk:CheckBox;
	private var type_cb:ComboBox;
	public function init() {
		for (var alert in alerts) {
			alerts_dg.addItem({key:alerts[alert].attributes["KEY"], display_name:alerts[alert].attributes["DISPLAY_NAME"],cat:alerts[alert].attributes["CLIENT_CAT"], active:alerts[alert].attributes["ACTIVE"], message:alerts[alert].attributes["MESSAGE"],type:alerts[alert].attributes["ALERT_TYPE"]});
		}
		delete_btn.enabled = false;
		update_btn.enabled = true;
		active_chk.selected = false;
		type_cb.selectedIndex = 0;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		alerts_dg.addEventListener("change", Delegate.create(this, itemChange));
	}
	private function deleteItem() {
		alerts_dg.removeItemAt(alerts_dg.selectedIndex);
		alerts_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
		active_chk.selected = false;
		dname_ti.text = "";
		key_ti.text ="";
		cat_ti.text = "";
		message_ti.text = "";
		type_cb.selectedIndex = 0;
	}
	private function updateItem() {
		if(active_chk.selected){
			var active = "Y";
		}
		else{
			var active = "N";
		}
		if (alerts_dg.selectedIndex != undefined) {
			alerts_dg.getItemAt(alerts_dg.selectedIndex).key = key_ti.text;
			alerts_dg.getItemAt(alerts_dg.selectedIndex).display_name = dname_ti.text;
			alerts_dg.getItemAt(alerts_dg.selectedIndex).cat = cat_ti.text;
			alerts_dg.getItemAt(alerts_dg.selectedIndex).active = active;
			alerts_dg.getItemAt(alerts_dg.selectedIndex).message = message_ti.text;
			alerts_dg.getItemAt(alerts_dg.selectedIndex).type = type_cb.selectedItem.label;
		} else {
			alerts_dg.addItem({type:type_cb.selectedItem.label, key:key_ti.text, display_name:dname_ti.text, cat:cat_ti.text, active:active, message:message_ti.text});
		}
		alerts_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		alerts_dg.selectedIndex = undefined;
		active_chk.selected = false;
		dname_ti.text = "";
		key_ti.text ="";
		cat_ti.text = "";
		message_ti.text ="";
		type_cb.selectedIndex = 0;
		delete_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function itemChange(evtObj) {
		key_ti.text = alerts_dg.selectedItem.key;
		dname_ti.text = alerts_dg.selectedItem.display_name;
		cat_ti.text = alerts_dg.selectedItem.cat;
		message_ti.text = alerts_dg.selectedItem.message;
		if(alerts_dg.selectedItem.active == "N"){
			active_chk.selected = false;
		}
		else{
			active_chk.selected = true;
		}
		var tempType = alerts_dg.selectedItem.type;
		for(var index in type_cb.dataProvider){
			if(tempType == type_cb.dataProvider[index].label){
				type_cb.selectedIndex = index;
			}
		}
		update_btn.enabled = true;
		delete_btn.enabled = true;
	}
	public function getData():Array {
		var newAlerts = new Array();
		for(var index = 0; index < alerts_dg.length; index++){
			var alertNode = new XMLNode(1, "ALERT");
			alertNode.attributes["KEY"] = alerts_dg.getItemAt(index).key;
			alertNode.attributes["DISPLAY_NAME"] = alerts_dg.getItemAt(index).display_name;
			alertNode.attributes["ACTIVE"] = alerts_dg.getItemAt(index).active;
			alertNode.attributes["CLIENT_CAT"] = alerts_dg.getItemAt(index).cat;
			alertNode.attributes["MESSAGE"] = alerts_dg.getItemAt(index).message;
			alertNode.attributes["ALERT_TYPE"] = alerts_dg.getItemAt(index).type;
			newAlerts.push(alertNode);
		}
		return newAlerts;
	}
}
