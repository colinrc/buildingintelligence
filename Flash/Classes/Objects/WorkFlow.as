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
	private var tree_xml = new XML();
	public function WorkFlow() {
		tree_xml.ignoreWhite = true;
	}
		
	/*
	Call addNode to add tree node in the correct order
	*/
	public function addNode(key:String, Object inst) {
		//loop through _global.workflow and find key
		for (var child in _global.workflow_xml.firstChild.childNodes) {
			if (key == _global.workflow_xml.firstChild.childNodes[child].nodeName) {
				//add to tree_xml at correct location, add inst for uri lookup
			}
			
		}
	}
	public function getTreeXML():XML {
		return tree_xml;
	}
	
	public function buildWorkflowTree() {
		_global.right_tree.dataProvider = _global.workflow;
	}
	
}