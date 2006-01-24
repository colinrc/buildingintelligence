import mx.controls.*;
import mx.utils.Delegate;

class Forms.Project.Client.ControlPanelApps extends Forms.BaseForm {
	private var save_btn:Button;
	private var add_btn:Button;
	private var del_btn:Button;
	private var apps_li:List;
	private var prog_cmb:ComboBox;
	private var label_ti:TextInput;
	private var apps:XMLNode;
	public function init():Void{
		for(var child in apps.childNodes){
			var newObj = new Object();
			newObj.label = apps.childNodes[child].attributes["label"];
			newObj.program = apps.childNodes[child].attributes["program"];
			apps_li.addItem(newObj);
		}
		save_btn.addEventListener("click", Delegate.create(this, save));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		del_btn.addEventListener("click", Delegate.create(this, delItem));
		apps_li.labelFunction = function(item_obj:Object):String {
			var label_str:String = item_obj.label + " - Program: " + item_obj.program;
			return label_str;
		}
	}
	private function addItem(){
		apps_li.addItem({label:label_ti.text, program:prog_cmb.text});
	}
	private function delItem(){
		if(apps_li.selectedIndex != undefined){
			apps_li.removeItemAt(apps_li.selectedIndex);
		}
	}
	private function save(){
		var newApps = new XMLNode(1,"controlPanelApps");
		for (var index = 0; index<apps_li.length; index++) {
			var newOverride = new XMLNode(1,"app");
			newOverride.attributes["label"] = apps_li.getItemAt(index).label;
			newOverride.attributes["program"] = apps_li.getItemAt(index).program;
			newApps.appendChild(newOverride);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		_global.left_tree.selectedNode.object.setData(new Object({apps:newApps}));
		_global.left_tree.selectedNode = _global.left_tree.selectedNode.object.toTree();
		_global.left_tree.selectedIndex = tempIndex;
	}
}
