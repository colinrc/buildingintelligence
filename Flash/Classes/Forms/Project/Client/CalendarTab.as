import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.CalendarTab extends Forms.BaseForm {
	private var zones:Array;
	private var zone_dg:DataGrid;
	private var zones_lb:Label;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;
	private var label_ti:TextInput;
	private var label:String;
	private var view_cmb:ComboBox;
	private var view:String;
	private var macro:String;
	private var macro_lb:Label;
	private var macro_cmb:ComboBox;
	private var icon_cmb:ComboBox;
	private var icon_ldr:Loader;
	private var icon:String;
	public function onLoad() {
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
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		label_ti.addEventListener("change", changeListener);
		var tempKeys = _global.serverDesign.getKeys();
		var DPKey = new Array();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			DPKey.push(tempObject);
		}
		label_ti.text = label;
		view_cmb.text = view;
		macro_cmb.text = macro;
		if (view_cmb.text == "today") {
			macro_cmb._visible = false;
			new_btn._visible = false;
			delete_btn._visible = false;
			zone_dg._visible = false;
			zones_lb._visible = false;
			macro_lb._visible = false;
		}
		if (icon.length) {
			icon_cmb.text = icon;
			icon_ldr.load(mdm.Application.path + "lib\\icons\\" + icon + ".png");
		}
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(zone_dg);
		dataGridHandler.addTextInputColumn("label", "Name", restrictions, false, 150);
		dataGridHandler.addComboBoxColumn("key", "Key", DPKey, false, 100);
		var DP = new Array();
		for (var zone in zones) {
			var newZone = new Object();
			newZone.label = "";
			newZone.key = "";
			if (zones[zone].attributes["label"] != undefined) {
				newZone.label = zones[zone].attributes["label"];
			}
			if (zones[zone].attributes["key"] != undefined) {
				newZone.key = zones[zone].attributes["key"];
			}
			DP.push(newZone);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
		icon_cmb.addEventListener("change", Delegate.create(this, loadIcon));
		view_cmb.addEventListener("change", Delegate.create(this, hideMacros));		
	}
	public function loadIcon(eventObject) {
		_global.unSaved = true;
		icon_ldr.load(icon_cmb.selectedItem.icon);
	}
	public function hideMacros(eventObject:Object) {
		_global.unSaved = true;		
		if (view_cmb.text == "today") {
			macro_cmb._visible = false;
			new_btn._visible = false;
			delete_btn._visible = false;
			zone_dg._visible = false;
			zones_lb._visible = false;
			macro_lb._visible = false;
		}
		else{
			macro_cmb._visible = true;
			new_btn._visible = true;
			delete_btn._visible = true;
			zone_dg._visible = true;
			zones_lb._visible = true;
			macro_lb._visible = true;
			
		}
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	private function save():Void {
		var newZones = new Array();
		var newMacro = "";
		if (view_cmb.text != "today") {
			newMacro = macro_cmb.text;
			var DP = dataGridHandler.getDataGridDataProvider();
			for (var index = 0; index < DP.length; index++) {
				var zone = new XMLNode(1, "zone");
				if (DP[index].label != undefined) {
					zone.attributes["label"] = DP[index].label;
				}
				if (DP[index].key != undefined) {
					zone.attributes["key"] = DP[index].key;
				}
				newZones.push(zone);
			}
		}
		dataObject.setData({zones:newZones, label:label_ti.text, view:view_cmb.text, icon:icon_cmb.text, macro:newMacro});
		_global.refreshTheTree();
		_global.saveFile("Project");
	}
}
