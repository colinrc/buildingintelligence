import mx.controls.*
import mx.utils.Delegate;

class Forms.Project.Room.Tab.Config extends Forms.BaseForm {

	private var left_li:List;
	private var right_li:List;
	private var tabName_ti:TextInput;
	private var icon_ti:TextInput;
	private var name_ti:TextInput;
	private var canOpen_ti:TextInput;
	private var icons_ti:TextInput;
	private var keys_cb:ComboBox;
	
	private var name:String;
	private var icon:String;
	private var canOpen:String;
	private var controls:XML;
	
	function Config() {
	}
	
	public function init():Void {
		left_li.vScrollPolicy = right_li.vScrollPolicy = "auto";
		
		tabName_ti.text = name;
		icon_ti.text = icon;
		if (canOpen.length) canOpen_ti.text = canOpen;
		
		for (var i=0; i<controls.childNodes.length; i++) {
			right_li.addItem({label:controls.childNodes[i].attributes.type + " (" + controls.childNodes[i].attributes.name + ")", id:i});
		}
		
		function onListChange(eventObj:Object):Void {
			var id = eventObj.target.selectedItem.id;
			name_ti.text = controls.childNodes[id].attributes.name;
			icons_ti.text = controls.childNodes[id].attributes.icons;
			_global.comboSetSelected(keys_cb, controls.childNodes[id].attributes.key);
		}
		right_li.addEventListener("change", Delegate.create(this, onListChange));
		
		keys_cb.dataProvider = _global.keysArray;
	}
}