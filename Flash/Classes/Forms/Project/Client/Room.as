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
	public function onLoad() {
		name_ti.text = name;
		roomEditor.map = map.split('\\').join('/');
		roomEditor.poly = poly;
		switchZone_cmb.addItem({label:"None"});
		var tempZones = _global.client_test.Property.zones;
		for(var zone in tempZones){
			switchZone_cmb.addItem({label:tempZones[zone].name});
		}
		for(var zone in switchZone_cmb.dataProvider){
			if(switchZone_cmb.dataProvider[zone].label == switchZone){
				switchZone_cmb.selectedIndex = parseInt(zone);
			}
		}
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function save():Void {
		_global.left_tree.selectedNode.object.setData({name:name_ti.text, poly:roomEditor.poly, switchZone:switchZone_cmb.text});
		_global.needSave();						
		_global.refreshTheTree();		
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, true);		
	}
}
