import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ArbitraryLabel{
	private var fontColour_mc:MovieClip;
	private var label_ti:TextInput;
	private var fontSize_ti:TextInput;
	private var dataObj:Object;
	
	public function init():Void{
		fontColour_mc.setColour(dataObj.fontColour);
		label_ti.text = dataObj.label;
		fontSize_ti.text = dataObj.fontSize;
	}
	private function getData():Object{
		var newObj = new Object();
		newObj.fontColour="0x"+fontColour_mc.getColour().toString(16);
		newObj.label = label_ti.text;
		newObj.fontSize = fontSize_ti.text;
		return newObj;
	}
}
