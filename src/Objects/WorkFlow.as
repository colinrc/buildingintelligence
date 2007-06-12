package Objects {
	/**
	    Name: Workflow
	    Description: This class is used to build the workflow tree.
	    author: Jeff 
	    version: 0.1
	    modified: 20060207
	    copyright: Building Intelligence
	*/
	
	//import mx.utils.Delegate;
	import XMLloaders.XLoader;
	import flash.xml.*;
	import flash.events.Event;
	import mx.core.Application;
	import mx.collections.ArrayCollection;
	import utils.*;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import flash.utils.describeType;
	
	[Bindable("WorkFlow")]
	[RemoteClass(alias="elifeAdmin.objects.server.workFlow")]
	public class WorkFlow implements IExternalizable {
		private var workflow_xml:XML;
		//public var workFlow_tree:MyTreeNode;
		
		private var serverHash:HashMap;
		private	var clientHash:HashMap;
		
		public var serverObject:HashMap;
		public var clientObject:HashMap;
		public var loader:XLoader;
		[Bindable]
		public var serverList:ArrayCollection;
		[Bindable]
		public var clientList:ArrayCollection;
		
		public function writeExternal(output:IDataOutput):void {
			output.writeObject(workflow_xml);
			output.writeObject(serverHash);
			output.writeObject(clientHash);
			output.writeObject(serverObject);
			output.writeObject(clientObject);
			output.writeObject(serverList);
			output.writeObject(clientList);
		}
		
		public function readExternal(input:IDataInput):void {
			workflow_xml = input.readObject() as XML;
			serverHash = input.readObject() as HashMap;
			clientHash = input.readObject() as HashMap;
			serverObject = input.readObject() as HashMap;
			clientObject = input.readObject() as HashMap;
			serverList = input.readObject() as ArrayCollection;
			clientList = input.readObject() as ArrayCollection;
		}
		
		public function WorkFlow():void {
			serverList = new ArrayCollection();
			clientList = new ArrayCollection();
			
		    XLoader.URL = "data/workflow.xml";
		    loader = XLoader.getInstance();
		    loader.addEventListener("onInit", loadWorkflow);
		}
	/*	public function getWorkFlow():MyTreeNode {
			return workFlow_tree;
		}*/
		public function loadWorkflow(event:Event):void {
			workflow_xml = loader.data;
			//trace(workflow_xml.toXMLString());
			loader.removeEventListener("onInit", loadWorkflow);
			processWorkflow();
		}
		
		public function processWorkflow():void {
			var clientSteps:XML;
			var serverSteps:XML;
			serverSteps = workflow_xml.step[0];
			clientSteps = workflow_xml.step[1];
			serverHash = new HashMap();
			clientHash = new HashMap();
			serverObject = new HashMap();
			clientObject = new HashMap();
			
			for (var child:int = 0; child < serverSteps.item.length(); child++) {
				serverSteps.item[child].@description = serverSteps.item[child].description;
				serverHash.put(serverSteps.item[child].@key, serverSteps.item[child]);
			}
			for (var child2:int = 0; child2 < clientSteps.item.length(); child2++) {
				clientSteps.item[child2].@description = clientSteps.item[child2].description;
				clientHash.put(clientSteps.item[child2].@key, clientSteps.item[child2]);
			}
			
			
		}
		
		public function getDescription(key:String):String {
			var lKey:String = key.split("_*_")[0];
			if (serverHash.containsKey(lKey) == true) { 
				return serverHash.getValue(lKey);
			}
			else if (clientHash.containsKey(lKey) == true) { 
				return clientHash.getValue(lKey);
			}
			return null;
		}
		
		public function getObject(key:String):Object {
			if (serverObject.containsKey(key) == true) { 
				return serverObject.getValue(key).object;
			}
			else if (clientObject.containsKey(key) == true) { 
				return clientObject.getValue(key).object;
			}
			return null;
		}
		
		public function createWorkflow(inNode:MyTreeNode) {
			addNode(inNode.object.getKey()+"_*_"+inNode.object.getUniqueID(), inNode);
			//trace("createWorkflow:"+inNode.object.getKey()+ " " + inNode.childObject.length.toString());
			for (var child:int=0 ; child < inNode.myXML.children().length() ; child++) {
				
				createWorkflow( inNode.childObject[child] );
			}
		}
		/*
		Call addNode to add right tree node in the correct order
		key: is the string to search for in workflow
		inst: is the left tree instance you want openned when right tree pressed.
		<step label="Step1" key="Device" description="" order="1"/>
		*/
		public function addNode(key:String, inst:MyTreeNode):void {
			var index:int = 0;
			var order:int = 0;
			var found:Boolean = false;
			var valid:String = "";
			
			valid = inst.object.isValid();
			if (valid == "error") {
				valid = "err";
			}
			var lKey:String = key.split("_*_")[0];
			if (serverHash.containsKey(lKey) == true) {
				index = 0;
				order = 0;
				found = false;
				var tempXML:XML = serverHash.getValue(lKey);
				//var tempNode:MyListNode = new MyListNode(tempXML, inst);
				order = parseInt(tempXML..@order);
				
				if (serverList.length == 0) {  //tempXML.@key.toString()
					serverList.addItemAt( { label: tempXML.@label.toString(), key:key , description: tempXML.@description.toString(), icon: valid, order: parseInt(tempXML.@order.toString()), obj: inst.object },0 );  			
				}
				else {
					for (var i:int= 0 ; i < serverList.length ; i++) {
						index = serverList.getItemAt(i).order;
						if (index > order) {
							serverList.addItemAt({ label: tempXML.@label.toString(), key: key, description: tempXML.@description.toString(), icon: valid, order: parseInt(tempXML.@order.toString()), obj: inst.object },i);
							found = true;
							break;
						}
					}
					if (found == false) {
						serverList.addItemAt({ label: tempXML.@label.toString(), key: key, description: tempXML.@description.toString(), icon: valid, order: parseInt(tempXML.@order.toString()), obj: inst.object },serverList.length);
					}
				}
				//var newKey:String = key+inst.object.getUniqueID();
				serverObject.put(key, inst); 
			}
			else if (clientHash.containsKey(lKey) == true) {
				index = 0;
				order = 0;
				found = false;
				var tmpXML:XML = clientHash.getValue(lKey);
				var tmpNode:MyListNode = new MyListNode(tmpXML, inst);
				order = parseInt(tmpXML..@order);
				if (clientList.length == 0) {
					clientList.addItemAt({ label: tmpXML.@label.toString(), key: key, description: tmpXML.@description.toString(), icon: valid, order: parseInt(tmpXML.@order.toString()), obj: inst.object },0);
				}
				else {
					for (var j:int= 0 ; j < clientList.length ; j++) {
						index = clientList.getItemAt(j).order;
						if (index > order) {
							clientList.addItemAt({ label: tmpXML.@label.toString(), key: key, description: tmpXML.@description.toString(), icon: valid, order: parseInt(tmpXML.@order.toString()), obj: inst.object },j);
							found = true;
							break;
						}
					}
					if (found == false) {
						clientList.addItemAt({ label: tmpXML.@label.toString(), key: key, description: tmpXML.@description.toString(), icon: valid, order: parseInt(tmpXML.@order.toString()), obj: inst.object },clientList.length);
					}
				}
				
				clientObject.put(key, inst); 
			}
			
			//Now they are sorted
		
		}
		/*
		public function deleteNode(inst:Object):void{
			for (var child:int = 0 ; child < workFlow_tree.children().length() ; child++) {
				var tempNode = workFlow_tree.children()[child];
				if (inst == tempNode.left_node) {
					tempNode.removeNode();
					break;
				}
			}
		}*/
		
		/*
		public function setAttributes(key:String, newNode:MyTreeNode):void {
			var found:Boolean = false;
			for (var i:int = 0; i < steps.length(); i++) {
				for (var child:int = 0 ; child < steps[i].item.length() ; child++) {
					if (key == steps[i].item[child].@key) {
					//	trace("key:"+key+": and stepskey:"+ steps[i].item[child].@key+":end");
						newNode.myXML.@label = steps[i].item[child].@label;
						newNode.myXML.@order = steps[i].item[child].@order;
						newNode.myXML.@description = steps[i].item[child].description[0].toString();
						newNode.myXML.@stepOrder = steps[i].@stepOrder;
						found = true;
						break;
					}
				}
				if (found == true) {
					break;
				}
			}
		}  */
		/*public function buildWorkflowTree():void {

			var result:XMLDocument = new XMLDocument();
            result.ignoreWhite = true;
            result.parseXML(workFlow_tree.myXML.toXMLString());
           
			for (var child in result.childNodes) {
				for(var index in result.childNodes[child].childNodes){
					result.childNodes[child].childNodes[index].removeNode();
				}
			}
			if (result.hasChildNodes() == true) {
				trace("result string:" + result.toString() + ":End of Result string");
				workFlow_tree.myXML = XML(result.toString());
			}
			else {
				workFlow_tree = null;
			}
		}*/
	}
}