package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import Objects.MyTreeNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("macros")]
	[RemoteClass(alias="elifeAdmin.objects.server.macros")]
	public class Macros extends BaseElement {
		private var macros:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(macros);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			macros = input.readObject()as Array;
		}
		
		public function Macros(){
			macros = new Array();
		}
		public override function getForm():String {
			return "forms.project.macros";
		}
		public override function toXML():XML {
			var tempNode = new XML("<MACROS />");
			for (var macro:int = 0; macro < macros.length; macro++) {
				tempNode.appendChild(macros[macro].toXML());
			}
			return tempNode;
		}
		public override function getName():String {
			return "Macros";
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			for(var macro:int = 0; macro < macros.length; macro++){
				newNode.appendChild(macros[macro].toTree());
			}
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "Macros";
		}
		public override function getData():ObjectProxy {
			return {macros:macros, dataObject:this};
		}
		public override function setData(newData:Object):void {
			//jk _global.left_tree.setIsOpen(treeNode, false);
			//Process macro changes....
			var newMacros = new Array();
			for (var index in newData.macros) {
				if (newData.macros[index].id == undefined) {
					newMacros.push({name:newData.macros[index].name});
				}
			}
			for (var macro in macros) {
				var found = false;
				for (var index in newData.macros) {
					if (macros[macro].id == newData.macros[index].id) {
						macros[macro].name = newData.macros[index].name;
						found = true;
					}
				}
				if (found == false) {
					macros[macro].deleteSelf();
					macros.splice(parseInt(macro), 1);
				}
			}
			for (var newMacro in newMacros) {
				var newNode:XML = new XML("<CONTROL />");
				newNode.@EXTRA = newMacros[newMacro].name;
				var newMacro = new Objects.Server.Macro();
				newMacro.setXML(newNode);
				newMacro.id = Application.application.formDepth++;			
				treeNode.appendChild(newMacro.toTree());	
				macros.push(newMacro);
			}
			//jk _global.left_tree.setIsOpen(treeNode, true);
		}
		public function getMacros():Array{
			return macros;
		}
		public override function setXML(newData:XML):void {
			macros = new Array();
			if (newData.name() == "MACROS") {
				for(var child:int = 0; child<newData.children().length;child++){
					var newMacro = new Objects.Server.Macro();
					newMacro.setXML(newData.children()[child]);
					newMacro.id = Application.application.formDepth++;
					macros.push(newMacro);
				}
			} else {
				trace("ERROR, found node "+newData.name()+", expecting MACROS");
			}
		}
	}
}