class Objects.Server.Catalogues extends Objects.BaseElement {
	var catalogues:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var catalogue in catalogues) {
			if (!catalogues[catalogue].isValid()) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.catalogues";
	}
	public function toXML():XMLNode {
		var newCatalogues = new XMLNode(1, "Catalogues");
		for (var catalogue in catalogues) {
			newCatalogues.appendChild(catalogues[catalogue].toXML());
		}
		return newCatalogues;
	}
	public function toTree():XMLNode{
		var newNode= new XMLNode(1, "Catalogues");
		for (var catalogue in catalogues) {
			newNode.appendChild(catalogues[catalogue].toTree());
		}
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "Catalogues";
	}
	public function getData():Object {
		return new Object({catalogues:catalogues});
	}
	public function setData(newData:Object) {
		//process new catalogues
	}
	public function setXML(newData:XMLNode):Void {
		catalogues = new Array();
		for (var child in newData.childNodes) {
			var newCatalogue = new Objects.Server.Catalogue();
			newCatalogue.setXML(newData.childNodes[child]);
			catalogues.push(newCatalogue);
		}
	}
}
