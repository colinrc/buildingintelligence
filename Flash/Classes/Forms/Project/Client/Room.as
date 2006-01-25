import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Room extends Forms.BaseForm {
	private var alertGroups:Array;
	private var alertGroups_li:List;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var name:String;
	private var name_ti:TextInput;
	private var poly:String;
	private var poly_ta:TextArea;
	private var x_pos_ti:TextInput;
	private var y_pos_ti:TextInput;
	private var switchZone:String;
	private var switchZone_cmb:ComboBox;
	private var save_btn:Button;
	public function init() {
		name_ti.text = name;
		poly_ta.text = poly;
		switchZone_cmb.text = switchZone;
		for (var alertGroup in alertGroups) {
			alertGroups_li.addItem({x_pos:alertGroups[alertGroup].x_pos, y_pos:alertGroups[alertGroup].y_pos});
		}
		alertGroups_li.labelFunction = function(item_obj:Object):String  {
			var label_str:String = "Alerts";
			if ((item_obj.x_pos != undefined)&&(item_obj.x_pos != "")) {
				label_str += " X:"+item_obj.x_pos;
			}
			if ((item_obj.y_pos != undefined)&&(item_obj.y_pos != "")) {
				label_str += " Y:"+item_obj.y_pos;
			}
			return label_str;
		};
		delete_btn.enabled = false;
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		alertGroups_li.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function deleteItem() {
		alertGroups_li.removeItemAt(alertGroups_li.selectedIndex);
		alertGroups_li.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function addItem() {
		alertGroups_li.addItem({x_pos:x_pos_ti.text,y_pos:y_pos_ti.text});
		alertGroups_li.selectedIndex = undefined;
		x_pos_ti.text = "";
		y_pos_ti.text = "";
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		x_pos_ti.text = alertGroups_li.selectedItem.x_pos;
		y_pos_ti.text = alertGroups_li.selectedItem.y_pos;
		delete_btn.enabled = true;
	}
	public function save():Void {
		var newAlertGroups = new Array();
		for (var index = 0; index<alertGroups_li.length; index++) {
			var AlertGroup = new Object();
			AlertGroup.x_pos = alertGroups_li.getItemAt(index).x_pos;
			AlertGroup.y_pos = alertGroups_li.getItemAt(index).y_pos;
			newAlertGroups.push(AlertGroup);
		}
		_global.left_tree.selectedNode.object.setData(new Object({alertGroups:newAlertGroups, name:name_ti.text, poly:poly_ta.text, switchZone:switchZone_cmb.text}));
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, false);
		var newNode:XMLNode = _global.left_tree.selectedNode.object.toTree();
		for (var child in _global.left_tree.selectedNode.childNodes) {
			_global.left_tree.selectedNode.childNodes[child].removeNode();
		}
		// Nodes are added in reverse order to maintain consistancy
		_global.left_tree.selectedNode.appendChild(new XMLNode(1, "Placeholder"));
		for (var child in newNode.childNodes) {
			_global.left_tree.selectedNode.insertBefore(newNode.childNodes[child], _global.left_tree.selectedNode.firstChild);
		}
		_global.left_tree.selectedNode.lastChild.removeNode();
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, true);
	}
}
