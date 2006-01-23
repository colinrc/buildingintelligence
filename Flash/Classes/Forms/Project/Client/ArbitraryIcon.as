import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ArbitraryIcon{
	private var icons_ti:TextInput;
	private var commands_ti:TextInput;
	private var key_ti:TextInput;
	private var dataObj:Object;
	
	public function init():Void{
		icons_ti.text = dataObj.icons;
		commands_ti.text = dataObj.commands;
		key_ti.text = dataObj.key;
	}
	private function getData():Object{
		var newObj = new Object();
		newObj.icons = icons_ti.text;
		newObj.commands = commands_ti.text;
		newObj.key = key_ti.text;
		return newObj;
	}
}
