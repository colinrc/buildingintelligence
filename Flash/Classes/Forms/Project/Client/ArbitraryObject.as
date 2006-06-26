import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ArbitraryObject extends Forms.BaseForm {
	private var src_ti:TextInput;
	private var key_ti:TextInput;
	private var width_ti:TextInput;
	private var height_ti:TextInput;
	private var show_ti:TextInput;
	private var hide_ti:TextInput;
	private var dataObj:Object;
	public function onLoad():Void {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
			dataObj.src = src_ti.text;
			dataObj.key = key_ti.text;
			dataObj.width = width_ti.text;
			dataObj.height = height_ti.text;
			dataObj.show = show_ti.text;
			dataObj.hide = hide_ti.text;
		};
		src_ti.text = dataObj.src;
		key_ti.text = dataObj.key;
		width_ti.text = dataObj.width;
		height_ti.text = dataObj.height;
		show_ti.text = dataObj.show;
		hide_ti.text = dataObj.hide;
		src_ti.addEventListener("change", changeListener);	
		key_ti.addEventListener("change", changeListener);		
		width_ti.addEventListener("change", changeListener);
		height_ti.addEventListener("change", changeListener);		
		show_ti.addEventListener("change", changeListener);		
		hide_ti.addEventListener("change", changeListener);
	}
}
