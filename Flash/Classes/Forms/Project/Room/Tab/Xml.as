import mx.controls.*
import Utils.XMLHighlighter;

class Forms.Project.Room.Tab.Xml {

	private var xml_ta:TextArea;
	
	private var controls:XML;
	
	function Xml() {
	}
	
	public function init():Void {
		xml_ta.html = true;
		xml_ta.text = XMLHighlighter.highlight(controls);
	}
}