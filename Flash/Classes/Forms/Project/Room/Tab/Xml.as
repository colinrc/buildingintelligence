import mx.controls.*

class Forms.Project.Room.Tab.Xml {

	private var xml_ta:TextArea;
	
	private var controls:XML;
	
	function Xml() {
	}
	
	public function init():Void {
		xml_ta.text = controls.toString();
	}
}