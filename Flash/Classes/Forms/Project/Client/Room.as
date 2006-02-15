import mx.controls.*;
import Controls.MapEditor;
import mx.utils.Delegate;
class Forms.Project.Client.Room extends Forms.BaseForm {
	private var name:String;
	private var name_ti:TextInput;
	private var switchZone:String;
	private var switchZone_cmb:ComboBox;
	private var poly:String;
	private var save_btn:Button;
	private var roomEditor:MapEditor;
	private var map:String;
	public function init() {
		name_ti.text = name;
		roomEditor.map = map.split('\\').join('/');
		roomEditor.poly = poly;		
		switchZone_cmb.text = switchZone;
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function save():Void {
		_global.left_tree.selectedNode.object.setData({name:name_ti.text, poly:roomEditor.poly, switchZone:switchZone_cmb.text});
	}
}
