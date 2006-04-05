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
			_global.right_tree.dataProvider = new XML();
			for (var child = 0; child < steps.length; child++) {
				var newNode = new XMLNode(1, "step");
				newNode.attributes.stepOrder = steps[child].attributes.stepOrder;
				newNode.attributes.label = steps[child].attributes.label;
				newNode.attributes.description = steps[child].attributes.description;
				_global.right_tree.dataProvider.appendChild(newNode);
			}
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
		//mdm.Dialogs.prompt("InAddnode:"+key);
		if (newNode.attributes.label.length) {
			newNode.left_node = inst;
			newNode.attributes.complete = inst.object.isValid();
			mdm.Dialogs.prompt("InAddnode:IsValidCall:"+newNode.attributes.complete+"  "+key);
			for (var child in _global.right_tree.dataProvider.childNodes) {
				if (newNode.attributes.stepOrder == _global.right_tree.dataProvider.childNodes[child].attributes.stepOrder) {
					var tempNode = _global.right_tree.dataProvider.childNodes[child];
					if (tempNode.hasChildNodes()) {
						for (var i = 0; i < tempNode.childNodes.length; i++) {
							if (parseInt(newNode.attributes.order) < parseInt(tempNode.childNodes[i].attributes.order)) {
								tempNode.insertBefore(newNode, tempNode.childNodes[i]);
								found = true;
								//mdm.Dialogs.prompt("InAddnode-found");
								break;
							}
						}
					}
					if (!found) {
						//mdm.Dialogs.prompt("InAddnode-notfound");
						tempNode.appendChild(newNode);
					}
					break;
				}
			}
		}
	}
	public function deleteNode(inst:Object) {
		for (var child in _global.right_tree.dataProvider.childNodes) {
			var tempNode = _global.right_tree.dataProvider.childNodes[child];
			if (inst == tempNode.left_node) {
				tempNode.removeNode();
				break;
			}
		}
	}
	public function setAttributes(key:String, newNode:XMLNode):Void {
		for (var i = 0; i < steps.length; i++) {
			for (var child in steps[i].childNodes) {
				if (key == steps[i].childNodes[child].attributes.key) {
					newNode.attributes.label = steps[i].childNodes[child].attributes.label;
					newNode.attributes.order = steps[i].childNodes[child].attributes.order;
					newNode.attributes.description = steps[i].childNodes[child].firstChild.toString();
					newNode.attributes.stepOrder = steps[i].attributes.stepOrder;
					break;
				}
			}
		}
	}
	public function buildWorkflowTree() {
		for (var child in _global.right_tree.dataProvider.childNodes) {
			for(var index in _global.right_tree.dataProvider.childNodes[child].childNodes){
				_global.right_tree.dataProvider.childNodes[child].childNodes[index].removeNode();
			}
		}
	}
}
