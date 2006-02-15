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
	private var alt;
	public function WorkFlow() {
		////_root.debugger.text += "   in workflow constructor"+"\r";
		workflow_xml = new XML();
		workflow_xml.ignoreWhite = true;
		workflow_xml.onLoad = Delegate.create(this, loadWorkflow);
		workflow_xml.load("workflow.xml");
	}
	public function loadWorkflow(success:Boolean) {
		//workflow_xml.onLoad = function(success) {
		if (success) {
			////_root.debugger.text += "Nodename="+workflow_xml.toString()+"\r";
			//newData = this.firstChild;
			steps = workflow_xml.firstChild.childNodes;
			////_root.debugger.text += "steps=" + steps.toString()+"\r";
		} else {
			////_root.debugger.text += "WORKFLOW NOT LOADED.....\r";
			// something didn't load..
		}
		//};
		////_root.debugger.text += "   fin loadWorkflow"+"\r";
	}
	/*
	Call addNode to add right tree node in the correct order
	key: is the string to search for in workflow
	inst: is the left tree instance you want openned when right tree pressed.
	<step label="Step1" key="Device" description="" order="1"/>
	*/
	public function addNode(key:String, inst:Object) {
		//_root.debugger.text += "    in addNode"+key+"\r";
		var order = getOrder(key);
		var found:Boolean = false;
		var newNode = new XMLNode(1, "step ");
		newNode.attributes.label = getLabel(key);
		newNode.attributes.order = order;
		newNode.attributes.description = getDescription(key);
		newNode.left_node.description = newNode.attributes.description;
		if (newNode.attributes.label.length>0) {
			newNode.left_node = inst;
			newNode.attributes.label = newNode.left_node.object.getName();
			if (_global.right_tree_xml.hasChildNodes()) {
				_root.debugger.text += "Child Nodes existant \n";
				for (var i = 0; i<_global.right_tree_xml.childNodes.length; i++) {
					_root.debugger.text += _global.right_tree_xml.childNodes[i].attributes.order+" \n";
					if (order<parseInt(_global.right_tree_xml.childNodes[i].attributes.order)) {
						//add to tree_xml at correct location, add inst for uri lookup
						_root.debugger.text += order+" found\n";
						_global.right_tree_xml.insertBefore(newNode, _global.right_tree_xml.childNodes[i]);
						found = true;
						break;
					}
				}
			}
			//_root.debugger.text += "   found="+found.toString()+"\r";   
			if (found == false) {
				_root.debugger.text += order+" didnt find\n";
				_global.right_tree_xml.appendChild(newNode);
			}
		}
	}
	public function getOrder(key:String):Number {
		for (var i = 0; i<steps.length; i++) {
			if (key == steps[i].attributes.key) {
				////_root.debugger.text += "   in getOrder, found="+steps[i].attributes.order+"\r";
				return parseInt(steps[i].attributes.order);
			}
		}
		////_root.debugger.text += "   in getOrder, NOT FOUND";
		return 0;
	}
	public function getLabel(key:String):String {
		for (var i = 0; i<steps.length; i++) {
			if (key == steps[i].attributes.key) {
				////_root.debugger.text += "   in getLabel, found="+steps[i].attributes.label+"\r";
				return steps[i].attributes.label;
			}
		}
		////_root.debugger.text += "   in getLabel, NOT FOUND";
		return "";
	}
	public function getDescription(key:String):String {
		for (var i = 0; i<steps.length; i++) {
			if (key == steps[i].attributes.key) {
				////_root.debugger.text += "   in getLabel, found="+steps[i].attributes.label+"\r";
				return steps[i].attributes.description;
			}
		}
		////_root.debugger.text += "   in getLabel, NOT FOUND";
		return "";
	}	
	public function getTreeXML():XML {
		return workflow_xml;
	}
	public function buildWorkflowTree() {
		_global.right_tree.dataProvider = _global.workflow;
	}
}
