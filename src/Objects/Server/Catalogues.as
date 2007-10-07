package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.collections.ArrayCollection;
	import Forms.Server.Catalogues_frm;
	
	[Bindable("catalogues")]
	[RemoteClass(alias="elifeAdmin.objects.server.catalogues")]
	public class Catalogues extends BaseElement{
		[Bindable]
		public var catalogues:ArrayCollection;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(catalogues);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			catalogues = input.readObject()as ArrayCollection;
		}
		
		public function getVariablesArray(cat:String, code:String):Array {
			var splitString:String = getOutputString(cat, code);
			var chunks:Array = splitString.split("%");
			var newArray:Array = new Array();
			if (isVariablesWellFormed(cat, code)==true) {
				var size:int = chunks.length
				for (var i:int = 1 ; i < size; i=i + 2) {
					newArray.push({"NAME":chunks[i], "VALUE":""});
				}
			}
			return newArray;
		}
		public function isVariablesWellFormed(cat:String, code:String):Boolean {
			var splitString:String = getOutputString(cat, code);
			var chunks:Array = splitString.split("%");
			var size:int = chunks.length/2;
			
			if (chunks.length ==1 || chunks.length == Math.round(size)*2) {
				//even
				return false;
			}
			return true;
		}
		/*public function doesCodeContainVariables(cat:String, code:String):Boolean {
			for (var catalogue in catalogues) {
				if (catalogues[catalogue].name == cat) {
					var items:ArrayCollection = catalogues[catalogue].items;
					for (var item in items) {
						if (items[item].code == code) {
							var theItem:String = items[item].value;
							var splitString:Array =  theItem.split("%");
							if (splitString.length > 4) {
								return true;
							}
							return false;
						}
					}
				}
			}
		}  */
		
		public function getOutputString(cat:String, code:String):String {
			for (var catalogue in catalogues) {
				if (catalogues[catalogue].name == cat) {
					var items:ArrayCollection = catalogues[catalogue].items;
					for (var item in items) {
						if (items[item].code == code) {
							return items[item].value;
						}
					}
				}
			}
			return "";
		}
		
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var catalogue in catalogues) {
				if (catalogues[catalogue].isValid()!="ok") {
					flag = "error";
					appendValidationMsg("Catalogue's are in error");
				}
			}
			return flag;
		}
		
	/*	public function clone():Object {
			var newCat:Catalogues = new Catalogues();
			for each (var val:Catalogue in catalogues) {
				newCat.catalogues.push(val);
			}
			newCat.id = catalogues.id;
			newCat.treeNode = catalogues.id;
			newCat.usedIcons = catalogues.usedIcons;
		}
		*/
		
		public override function getForm():String {
			return "forms.project.device.catalogues";
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Server.Catalogues_frm;
			return className;		
		}
		
		public override function toXML():XML {
			var newCatalogues = new XML("<Catalogues />");
			for (var catalogue in catalogues) {
				newCatalogues.appendChild(catalogues[catalogue].toXML());
			}
			return newCatalogues;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			for (var catalogue in catalogues) {
				newNode.appendChild(catalogues[catalogue].toTree());
			}
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "Catalogues";
		}
		public override function getName():String {
			return "Catalogs";
		}
		
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy( {catalogues:catalogues, dataObject:this})
			return ob;
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			//_global.left_tree.setIsOpen(treeNode, false);		
			//Process catalogue changes....
			var newCatalogues = new Array();
			for (var index in newData.catalogues) {
				if (newData.catalogues[index].id == undefined) {
					newCatalogues.push({name:newData.catalogues[index].name});
				}
			}
			for (var catalogue in catalogues) {
				var found = false;
				for (var index in newData.catalogues) {
					if (catalogues[catalogue].id == newData.catalogues[index].id) {
						catalogues[catalogue].name = newData.catalogues[index].name;
						found = true;
					}
				}
				if (found == false) {
					catalogues[catalogue].deleteSelf();
					catalogues.removeItemAt(catalogue);
				}
			}
			for (var newCatalogue in newCatalogues) {
				var newNode = new XML("<CATALOGUE />");
				newNode.@NAME = newCatalogues[newCatalogue].name;
				var newCatalogue = new Objects.Server.Catalogue();
				newCatalogue.setXML(newNode);
				newCatalogue.id = Application.application.formDepth++;
				treeNode.appendChild(newCatalogue.toTree());			
				catalogues.addItem(newCatalogue);
			}
			//_global.left_tree.setIsOpen(treeNode, true);		
		}
		public override function setXML(newData:XML):void {
			catalogues = new ArrayCollection();
			for (var child in newData.children()) {
				var newCatalogue:Catalogue = new Objects.Server.Catalogue();
				newCatalogue.setXML(newData.children()[child]);
				newCatalogue.id = Application.application.formDepth++;		
				newCatalogue.name = newData.children()[child].@NAME;	
				catalogues.addItem(newCatalogue);
				
			}
		}
	}
}