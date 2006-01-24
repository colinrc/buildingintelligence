import mx.controls.*

class Forms.Project.KeySelector extends Forms.BaseForm {

	private var left_li:List;
	private var right_li:List;
	private var name_ti:TextInput;
	private var icon_ti:TextInput;
	
	private var name:String;
	private var icon:String;
	private var controls:XML;
	
	function KeySelector() {
	}
	
	public function init():Void {
		left_li.vScrollPolicy = right_li.vScrollPolicy = "auto";
		
		name_ti.text = name;
		icon_ti.text = icon;
		
		left_li.dataProvider = _global.keysArray;
		
		for (var i=0; i<controls.childNodes.length; i++) {
			right_li.addItem({label:controls.childNodes[i].attributes.key, data:controls.childNodes[i].attributes.key});
		}
	}
}