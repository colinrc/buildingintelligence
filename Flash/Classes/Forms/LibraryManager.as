import mx.controls.*;
import mx.utils.Delegate;
class Forms.LibraryManager extends Forms.BaseForm{
	private var type_ti:TextInput;
	private var name_ti:TextInput;
	private var keys_chk:CheckBox;
	private var add_btn:Button;
	private var restore_btn:Button;
	private var delete_btn:Button;
	private var library_ls:List;
	private var dataObject:Object;
	public function LibraryManager(){
	}
	public function onLoad(){
		keys_chk.enabled = false;
		type_ti.text = dataObject.getKey();
		type_ti.editable = false;
		name_ti.text = "";
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		restore_btn.addEventListener("click", Delegate.create(this, restoreItem));
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		refreshLibrary();				
	}
	public function doLoad(inDataObject){
		dataObject = inDataObject;
	}
	public function refreshLibrary(){
		library_ls.removeAll();
		var library = mdm.FileSystem.getFileList(mdm.Application.path+"library\\"+dataObject.getKey(), "*.xml");
		for(var index = 0;index<library.length;index++){
			var item = new Object();
			item.data = library[index];
			item.label = library[index].substring(0,library[index].length-4);
			library_ls.addItem(item);
		}
		library_ls.dataProvider.sortOn("label","ASC");
	}	
	private function restoreItem(){
		if(library_ls.selectedItem != undefined){
			var tempXML = new XML();
			var url = "";
			url = mdm.Application.path+"library\\"+dataObject.getKey()+"\\"+library_ls.selectedItem.data;
			tempXML.onLoad = function(success:Boolean){
				if(success){
					dataObject.setXML(this.firstChild);
				} else{
					mdm.Dialogs.prompt("Error Loading: "+url);
				}
			}
			tempXML.load(url);
			_global.unSaved = true;
		}
	}
	private function deleteItem(){
		if(library_ls.selectedItem != undefined){
			mdm.FileSystem.deleteFile(mdm.Application.path+"library\\"+dataObject.getKey()+"\\"+library_ls.selectedItem.data);
			refreshLibrary();
		}
	}
	private function addItem(){
		if(name_ti.text != ""){
			mdm.FileSystem.saveFile(mdm.Application.path+"library\\"+dataObject.getKey()+"\\"+name_ti.text+".xml", _global.writeXMLFile(dataObject.toXML(), 0));
			name_ti.text = "";
			refreshLibrary();
		}
	}
}