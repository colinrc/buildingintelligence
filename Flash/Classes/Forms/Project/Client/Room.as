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
	private var dataObject:Object;	
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);		
		name_ti.text = name;
		if(map == undefined){
			map = "";
		}
		roomEditor.map = "lib/maps/"+map;
		if(poly == undefined){
			poly = "";
		}
		roomEditor.poly = poly;
		switchZone_cmb.addItem({label:"None"});
		var foundNode = _global.searchProject(_global.left_tree.dataProvider, dataObject);
		var tempNode = foundNode.parentNode;
		while(tempNode.nodeName != "Client"){
			tempNode = tempNode.parentNode;
		}
		var tempZones = tempNode.object.Property.zones;
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
		dataObject.setData({name:name_ti.text, poly:roomEditor.poly, switchZone:switchZone_cmb.text});
		_global.refreshTheTree();				
		_global.saveFile("Project");
	}
}
