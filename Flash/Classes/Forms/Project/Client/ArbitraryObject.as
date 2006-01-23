import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ArbitraryObject{
	private var src_ti:TextInput;
	private var key_ti:TextInput;
	private var width_ti:TextInput;
	private var height_ti:TextInput;
	private var show_ti:TextInput;
	private var hide_ti:TextInput;
	private var dataObj:Object;
	
	public function init():Void{
		src_ti.text = dataObj.src;
		key_ti.text = dataObj.key;
		width_ti.text = dataObj.width;
		height_ti.text = dataObj.height;
		show_ti.text = dataObj.show;
		hide_ti.text = dataObj.hide;
	}
	private function getData():Object{
		var newObj = new Object();
		newObj.src = src_ti.text;
		newObj.key = key_ti.text;
		newObj.width = width_ti.text;
		newObj.height = height_ti.text;
		newObj.show = show_ti.text;
		newObj.hide = hide_ti.text;
		return newObj;
	}
}
