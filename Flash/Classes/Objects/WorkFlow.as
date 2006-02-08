/**
    Name: History
Description: This class is used to build the workflow tree.
    author: Jeff 
    version: 0.1
    modified: 20060207
    copyright: Building Intelligence
*/
import mdm.FileSystem.*;
class Objects.WorkFlow {
	private var workflow_xml:XML;
	private var steps:Array;
	public function WorkFlow() {
		workflow_xml = new XML();
		workflow_xml.ignoreWhite = true;
		workflow_xml.onLoad = function(success) {
			if (success) {
				steps = workflow_xml.firstChild.childNodes;
			} else {
				// something didn't load..
			}
		};
		workflow_xml.load("workflow.xml");
	}
	/*
	Call addNode to add right tree node in the correct order
	key: is the string to search for in workflow
	inst: is the left tree instance you want openned when right tree pressed.
	<step label="Step1" key="Device" description="" order="1"/>
	*/
	public function addNode(key:String, inst:Object) {
		var order = getOrder(key);
		var found:Boolean = false;
		var newNode = new XMLNode(1, "step ");
		newNode.attributes.label = getLabel(key);
		newNode.left_node = inst;
		if (_global.right_tree_xml.hasChildNodes()) {
			for (var i = 0; i<_global.right_tree_xml.firstChild.childNodes.length; i++) {
				if (order<_global.right_tree_xml.firstChild.childNodes[i].attributes.order) {
					//add to tree_xml at correct location, add inst for uri lookup
					_global.right_tree_xml.insertBefore(newNode, _global.right_tree_xml.firstChild.childNodes[i]);
					found = true;
					break;
				}
			}
		}
		if (found == false) {
			_global.right_tree_xml.appendChild(newNode);
		}
	}
	public function getOrder(key:String):Number {
		for (var i = 0; i<steps.length; i++) {
			if (key == steps[i].attributes.key) {
				return parseInt(steps[i].attributes.order);
			}
		}
		return 0;
	}
	public function getLabel(key:String):String {
		for (var i = 0; i<steps.length; i++) {
			if (key == steps[i].attribute.key) {
				return steps[i].attributes.label;
			}
		}
		return "";
	}
	public function getTreeXML():XML {
		return workflow_xml;
	}
	public function buildWorkflowTree() {
		_global.right_tree.dataProvider = _global.workflow;
	}
}
