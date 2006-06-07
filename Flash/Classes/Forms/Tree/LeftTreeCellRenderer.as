import mx.controls.Label;

class Forms.Tree.LeftTreeCellRenderer extends mx.core.UIComponent {
	var __label:Label;
	var owner;
	var listOwner;

	public function LeftTreeCellRenderer() {
	}
	
	public function createChildren():Void {
		createClassObject(Label, "__label", this.getNextHighestDepth(), {visible:false});
	}
	
	public function size():Void {
		__label.setSize(__width, __height);
	}
	
	public function getPreferredHeight():Number {
		return owner.__height;
	}
	
	public function setValue(label:String, node:XMLNode):Void {
		__label.visible = (label != " ");
		__label.text = label;
		if (listOwner.getNodeDepth(owner.node) == 1) __label.setStyle("fontWeight", "bold");		
	}
}
