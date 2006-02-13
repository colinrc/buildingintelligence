import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Room extends Forms.BaseForm {
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
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function save():Void {
		_global.left_tree.selectedNode.object.setData({name:name_ti.text, poly:poly_ta.text, switchZone:switchZone_cmb.text});
	}
}
