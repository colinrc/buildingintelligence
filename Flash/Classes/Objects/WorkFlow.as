/**
    Name: Workflow
Description: This class is used to build the workflow tree.
    author: Jeff 
    version: 0.1
    modified: 20060207
    copyright: Building Intelligence
*/
import mdm.FileSystem.*;
import mx.utils.Delegate;
class Objects.WorkFlow {
	private var workflow_xml:XML;
	private var steps:Array;
	public function WorkFlow() {
		workflow_xml = new XML();
		workflow_xml.ignoreWhite = true;
		workflow_xml.onLoad = Delegate.create(this, loadWorkflow);
		workflow_xml.load("workflow.xml");
	}
	public function loadWorkflow(success:Boolean) {
		if (success) {
			steps = workflow_xml.firstChild.childNodes;
		}
	}
	/*
	Call addNode to add right tree node in the correct order
	key: is the string to search for in workflow
	inst: is the left tree instance you want openned when right tree pressed.
	<step label="Step1" key="Device" description="" order="1"/>
	*/
	public function addNode(key:String, inst:Object) {
		var found:Boolean = false;
		var newNode = new XMLNode(1, "step");
		setAttributes(key, newNode);
		newNode.left_node.description = newNode.attributes.description;
		if (newNode.attributes.label.length > 0) {
			newNode.left_node = inst;
			newNode.attributes.label = newNode.left_node.object.getName();
			newNode.attributes.complete = inst.object.isValid();
			for (var child in _global.right_tree_xml.childNodes) {
				if (newNode.attributes.stepOrder == _global.right_tree_xml.childNodes[child].stepOrder) {
					var tempNode = _global.right_tree_xml.childNodes[child];
					if (tempNode.hasChildNodes()) {
						for (var i = 0; i < tempNode.childNodes.length; i++) {
							if (newNode.attributes.order < parseInt(tempNode.childNodes[i].attributes.order)) {
								tempNode.insertBefore(newNode, tempNode.childNodes[i]);
								trace("hello");
								found = true;
								break;
							}
						}
					}
					if (found == false) {
						tempNode.appendChild(newNode);
						trace("hello2");						
					}
				}
			}
		}
	}
	public function setAttributes(key:String, newNode:XMLNode):Void {
		for (var i = 0; i < steps.length; i++) {
			for (var child in steps[i].childNodes) {
				if (key == steps[i].attributes.key) {
					newNode.attributes.label = steps[i].childNodes[child].attributes.label;
					newNode.attributes.order = steps[i].childNodes[child].attributes.order;
					newNode.attributes.description = steps[i].childNodes[child].attributes.description.split("\\n").join("\n");
					newNode.attributes.stepOrder = steps[i].attributes.stepOrder;
					break;
				}
			}
		}
	}
	/*public function getTreeXML():XML {
	return workflow_xml;
	}*/
	public function buildWorkflowTree() {
		//_global.right_tree.dataProvider = _global.workflow;
		_global.right_tree.dataProvider = new XML();
		for(var child in steps){
			var newNode = new XMLNode(1,"step");
			newNode.attributes.stepOrder = steps[child].attributes.stepOrder;
			newNode.attributes.label = steps[child].attributes.label;
			newNode.attributes.description = steps[child].attributes.description.split("\\n").join("\n");
			_global.right_tree.dataProvider.appendChild();
		}
	}
}
