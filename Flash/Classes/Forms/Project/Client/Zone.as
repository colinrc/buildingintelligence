import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Zone extends Forms.BaseForm {
	private var name_ti:TextInput;
	private var name:String;
	private var map_cmb:ComboBox;
	private var map:String;
	private var map_ldr:Loader;
	private var background_cmb:ComboBox;
	private var bg_ldr:Loader;
	private var background:String;
	private var cycle_chk:CheckBox;
	private var cycle:String;
	private var alignment_cmb:ComboBox;
	private var alignment:String;
	private var hideFromList_chk:CheckBox;
	private var hideFromList:String;
	private var save_btn:Button;
	private var dataObject:Object;	
	public function onLoad() {
		map_ldr.autoLoad = true;
		map_ldr.scaleContent = true;
		map_ldr.opaqueBackground = 0x0099CC;
		bg_ldr.autoLoad = true;
		bg_ldr.scaleContent = true;
		bg_ldr.opaqueBackground = 0x0099CC;
		map_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		var myMaps = mdm.FileSystem.getFileList(mdm.Application.path+"lib\\maps", "*.png");
		myMaps = myMaps.concat(mdm.FileSystem.getFileList(mdm.Application.path+"lib\\maps", "*.swf"));
		myMaps.sort();
		map_cmb.addItem({label:"No Map",icon:""});
		for(var myMap =0; myMap <myMaps.length; myMap++){
			var newMap = new Object();
			newMap.label = myMaps[myMap];
			newMap.icon = mdm.Application.path+"lib\\maps\\"+myMaps[myMap];
			map_cmb.addItem(newMap);
		}
		background_cmb.dropdown.cellRenderer = "ImageCellRenderer";
		var myBGs = mdm.FileSystem.getFileList(mdm.Application.path+"lib\\backgrounds", "*.jpg");
		myBGs = myBGs.concat(mdm.FileSystem.getFileList(mdm.Application.path+"lib\\backgrounds", "*.png"));
		myBGs = myBGs.concat(mdm.FileSystem.getFileList(mdm.Application.path+"lib\\backgrounds", "*.swf"));		
		myBGs.sort();
		background_cmb.addItem({label:"No Background",icon:""});
		for(var myBG =0; myBG <myBGs.length; myBG++){
			var newBG = new Object();
			newBG.label = myBGs[myBG];
			newBG.icon = mdm.Application.path+"lib\\backgrounds\\"+myBGs[myBG];
			background_cmb.addItem(newBG);
		}		
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);	
		alignment_cmb.addEventListener("change", changeListener);			
		cycle_chk.addEventListener("change", changeListener);	
		hideFromList_chk.addEventListener("change", changeListener);			
		name_ti.text = name;
		if(map.length){
			map_cmb.text = map;
			map_ldr.load(mdm.Application.path+"lib\\maps\\"+map);
		} else{
			map_cmb.text = "No Map";
		}
		if(background.length){
			background_cmb.text = background;
			bg_ldr.load(mdm.Application.path+"lib\\backgrounds\\"+background);
		} else{
			background_cmb.text = "No Background";
		}
		/*********************************/
		if(alignment.length){
			alignment_cmb.text = alignment;
		}
		/*for (var align in alignment_cmb.dataProvider) {
			if (alignment_cmb.dataProvider[align].label == alignment) {
				alignment_cmb.selectedIndex = parseInt(align);
			}
		}*/
		/********************************/
		if (cycle == "true") {
			cycle_chk.selected = true;
		} else {
			cycle_chk.selected = false;
		}
		if (hideFromList == "true") {
			hideFromList_chk.selected = true;
		} else {
			hideFromList_chk.selected = false;
		}
		map_cmb.addEventListener("change", Delegate.create(this, loadMap));	
		background_cmb.addEventListener("change", Delegate.create(this, loadBG));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function loadMap(eventObject){
		_global.unSaved = true;
		map_ldr.load(map_cmb.selectedItem.icon);
	}
	public function loadBG(eventObject){
		_global.unSaved = true;
		bg_ldr.load(background_cmb.selectedItem.icon);		
	}	
	public function save():Void {
		if (cycle_chk.selected) {
			cycle = "true";
		} else {
			cycle = "false";
		}
		if (hideFromList_chk.selected) {
			hideFromList = "true";
		} else {
			hideFromList = "false";
		}
		if(map_cmb.text == "No Map"){
			var tempMap = "";
		} else{
			var tempMap = map_cmb.text;
		}
		if(background_cmb.text == "No Background"){
			var tempBG = "";
		} else{
			var tempBG = background_cmb.text;
		}
		if (alignment_cmb.text == "top left") {
			var align = "top left";
		} else {
			var align = "";
		}
		dataObject.setData({name:name_ti.text, map:tempMap, background:tempBG, cycle:cycle, alignment:align, hideFromList:hideFromList});
		_global.refreshTheTree();				
		_global.saveFile("Project");
	}
}
