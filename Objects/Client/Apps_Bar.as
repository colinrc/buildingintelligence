package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Apps_Bar")]
	[RemoteClass(alias="elifeAdmin.objects.client.apps_Bar")]
	public class Apps_Bar extends BaseElement {
		private var icons:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(icons);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			icons = input.readObject()as Array;
		}
		
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var icon in icons) {
				if (icons[icon].isValid() != "ok" ){
					flag = "error";
					appendValidationMsg("Icon " + icons[icon].name + " is invalid");
				}
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.appsbar";
		}
		public override function toXML():XML {
			var newNode = new XML("<appsBar />");
			for (var icon = 0; icon < icons.length; icon++) {
				newNode.appendChild(icons[icon].toXML());
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			for (var icon:int = 0; icon < icons.length; icon++) {
				newNode.appendChild(icons[icon].toTree());
			}
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "ClientApps_Bar";
		}
		public override function getName():String {
			return "Apps Bar";
		}
		public override function getData():ObjectProxy {
			return {icons:icons, dataObject:this};
		}
		public override function setXML(newData:XML):void {
			icons = new Array();
			if (newData.name() == "appsBar") {
				for (var child:int =0; child< newData.children().length(); child++) {
					var newIcon = new Icon();
					newIcon.setXML(newData.icon[child]);
					newIcon.id = mx.core.Application.application.formDepth++;
					icons.push(newIcon);
					
				}
			} else {
				trace("Error, received " + newData.nodeName + ", was expecting appsBar");
			}
		}
		public override function setData(newData:Object):void {
			_global.left_tree.setIsOpen(treeNode, false);
			//process new icons
			var newIcons = new Array();
			for (var index in newData.icons) {
				if (newData.icons[index].id == undefined) {
					newIcons.push({name:newData.icons[index].name});
				}
			}
			for (var icon in icons) {
				var found = false;
				for (var index in newData.icons) {
					if (icons[icon].id == newData.icons[index].id) {
						icons[icon].name = newData.icons[index].name;
						found = true;
					}
				}
				if (found == false) {
					icons[icon].deleteSelf();
					icons.splice(parseInt(icon), 1);
				}
			}
			for (var newIcon in newIcons) {
				var newNode = new XMLNode(1, "icon");
				newNode.attributes["name"] = newIcons[newIcon].name;
				var newIcon = new Objects.Client.Icon();
				newIcon.setXML(newNode);
				newIcon.id = _global.formDepth++;
				icons.push(newIcon);
			}
			//sort according to desired order
			newIcons = new Array();
			for (var newIcon = 0; newIcon < newData.icons.length; newIcon++) {			
				for (var icon = 0; icon < icons.length; icon++) {
					if (newData.icons[newIcon].name == icons[icon].name) {
						newIcons.push(icons[icon]);
					}
				}
			}
			icons = newIcons;
			var treeLength = treeNode.childNodes.length;
			for(var child = treeLength-1; child > -1;child--){
				treeNode.childNodes[child].removeNode();
			}
			for(var icon = 0; icon<icons.length;icon++){
				treeNode.appendChild(icons[icon].toTree());
			}
			_global.left_tree.setIsOpen(treeNode, true);
		}
		public function getIcons():Array{
			usedIcons = new Array();
			for (var icon in icons) {
				if ((icons[icon].icon != "") && (icons[icon].icon != undefined)) {
					addIcon(icons[icon].icon);
				}
			}
			return usedIcons;
		}
	}
}