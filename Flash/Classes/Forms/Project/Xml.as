import mx.controls.*
//import Utils.XMLHighlighter;
import mx.utils.Delegate;

class Forms.Project.Xml extends Forms.BaseForm {

	private var xml_ta:TextArea;
	private var node:XMLNode;
	//private var controls:XML;
	private var save_btn:Button;
	
	function Xml() {
	}
	
	public function init():Void {
		//xml_ta.html = true;
		xml_ta.html = false;
		//controls = new XML();
		//controls.appendChild(node);
		//xml_ta.text = XMLHighlighter.highlight(controls);
		xml_ta.text = node.toString();
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function save():Void {
		var newXML = new XML();
		newXML.ignoreWhite = true;
		newXML.parseXML(xml_ta.text);
		_global.left_tree.selectedNode.object.setXML(newXML.firstChild);
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode,false);
		var newNode:XMLNode = _global.left_tree.selectedNode.object.toTree();
		for(var child in _global.left_tree.selectedNode.childNodes){
			_global.left_tree.selectedNode.childNodes[child].removeNode();
		}
		// Nodes are added in reverse order to maintain consistancy
		_global.left_tree.selectedNode.appendChild(new XMLNode(1,"Placeholder"));
		for(var child in newNode.childNodes){
			_global.left_tree.selectedNode.insertBefore(newNode.childNodes[child], _global.left_tree.selectedNode.firstChild);
		}
		_global.left_tree.selectedNode.lastChild.removeNode();
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode,true);
	}
}