package Objects.Client {
	import Objects.*;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	
	[Bindable("Window")]
	[RemoteClass(alias="elifeAdmin.objects.client.window")]
	public class Window extends BaseElement {
		[Bindable]
		public var tabs:ArrayCollection;
		[Bindable]
		public var attributes:ArrayCollection;
		[Bindable]
		public var attributeGroups:ArrayCollection = new ArrayCollection();
		
		public function Window() {
			attributeGroups.addItem("window");
			attributeGroups.addItem("tabs");
		}
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(tabs);
			output.writeObject(attributes);
			output.writeObject(attributeGroups);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			tabs = input.readObject()as ArrayCollection;
			attributes = input.readObject()as ArrayCollection;
			attributeGroups = input.readObject()as ArrayCollection;
		}
		
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			if (tabs.length == 0) {
				flag = "empty";
				appendValidationMsg("No Tabs are defined");
			}
			/*for (var tab in tabs) {
				if (tabs[tab].isValid()!="ok") {
					flag = "warning";
					appendValidationMsg(tabs[tab].attributes["name"] + " is invalid");
				}
			}*/
			return flag;
		}
		public function deleteSelf():void{
			treeNode.removeNode();
		}
		public override function getForm():String {
			return "forms.project.client.window";
		}
		public override function toXML():XML {
			var newNode:XML = new XML("<window />");
			for (var attribute in attributes) {
				newNode.@[attributes[attribute].name] = attributes[attribute].value;
			}
			for (var tab:int = 0; tab < tabs.length; tab++) {			
				newNode.appendChild(tabs[tab].toXML());
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			for (var tab = 0; tab < tabs.length; tab++) {			
				newNode.appendChild(tabs[tab].toTree());
			}
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "ClientWindow";
		}
		public override function getName():String {
			return "Room Control Panel";
		}
		public  function get Data():ObjectProxy {
			return {tabs:tabs, dataObject:this};
		}
		public function getAttributes():ArrayCollection {
			return attributes;
		}
		public function setAttributes(newAttributes:ArrayCollection) {
			attributes = newAttributes;
		}
		public override function setXML(newData:XML):void {
			attributes = new ArrayCollection();
			if (newData.name() == "window") {
				for (var child:int = 0; child < newData.attributes().length(); child++) {
					attributes.addItem({name:newData.attributes()[child].name(), value:newData.attributes()[chlid]});
				}
				tabs = new ArrayCollection();
				for (var child:int =0; child< newData.children().length(); child++) {		
					var newTab:Tab = new Tab();
					newTab.setXML(newData.children()[child]);
					newTab.id = Application.application.formDepth++;
					tabs.addItem(newTab);
				}
			} else {
				trace("Error, found " + newData.name() + ", was expecting window");
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			//_global.left_tree.setIsOpen(treeNode, false);
			//process new tabs
			var newTabs:ArrayCollection = new ArrayCollection();
			for (var index in newData.tabs) {
				if (newData.tabs[index].id == undefined) {
					newData.tabs[index].id = Application.application.formDepth++;
					newTabs.addItem({name:newData.tabs[index].name, id:newData.tabs[index].id});
				}
			}
			for (var tab in tabs) {
				var found = false;
				for (var index in newData.tabs) {
					if (tabs[tab].id == newData.tabs[index].id) {
						tabs[tab].name = newData.tabs[index].name;
						found = true;
						break;
					}
				}
				if (found == false) {
					tabs.removeItemAt(tab);
				}
			}
			for (var newTab in newTabs) {
				var newNode:XML = new XML("<tab/>");
				newNode.@name = newTabs[newTab].name;
				var tab:Tab = new Objects.Client.Tab();
				tab.setXML(newNode);
				tab.id = newTabs[newTab].id;
				tabs.addItem(tab);
			}
			//sort according to desired order
			newTabs = new ArrayCollection();
			for (var newTab = 0; newTab < newData.tabs.length; newTab++) {			
				for (var tab = 0; tab < tabs.length; tab++) {			
					if (newData.tabs[newTab].id == tabs[tab].id) {
						newTabs.addItem(tabs[tab]);
						break;
					}
				}
			}
			tabs = newTabs;
			var treeLength:int = treeNode.childObject.length;
			for(var child = treeLength-1; child > -1;child--){
				treeNode.childObject[child].removeNode();
			}
			for(var tab = 0; tab<tabs.length;tab++){
				treeNode.appendChild(tabs[tab].toTree());
			}		
			
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			for (var tab in tabs) {
				usedKeys=usedKeys.concat(tabs[tab].getUsedKeys());
			}
			return usedKeys;
		}
		public function getIcons():Array{
			usedIcons = new Array();
			for (var tab in tabs) {
				usedIcons = usedIcons.concat(tabs[tab].getIcons());
			}
			return usedIcons;
		}
	}
}