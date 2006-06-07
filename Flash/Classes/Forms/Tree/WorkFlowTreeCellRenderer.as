import mx.controls.Label;

class Forms.Tree.WorkFlowTreeCellRenderer extends mx.core.UIComponent {
	var owner;
	var listOwner;
	var cell:Object;
	var icon:MovieClip;
	var __label:Label;
	
	function WorkFlowTreeCellRenderer() {
	}
	
	function createChildren() {
		super.createChildren();
		createClassObject(Label, "__label", this.getNextHighestDepth(), {visible:false});
	}
	
	function setValue(label:String, node:XMLNode) {
		var lineColor:Number = listOwner.getStyle('lineColor');
		var indent = ((listOwner.getNodeDepth(owner.node)) + 3) * getStyle("indentation");
		clear();
		if (owner.node != undefined) {
			beginFill(lineColor, listOwner.getStyle('lineAlpha') || 100);
			drawRect(-indent, Math.ceil(owner.height) - .25, listOwner.width, Math.ceil(owner.height) + .25);
			endFill();
			var iconName="";
			if (owner.node.attributes.complete == "error") {
				iconName = "stop";
			} 
			else {
				if (owner.node.attributes.complete == "ok") {
					iconName = "tick";
				} 
				else {
					if (owner.node.attributes.complete == "empty") {
						iconName = "incomplete";
					}
					else {
						if (owner.node.attributes.complete == "warning") {
							iconName = "warning";
						}
						else {
							iconName = null;
						}
					}
				}
			}
			icon = attachMovie("Icon:" + iconName, "icon", 100, {_x:__width - 18, _y:2});
		}
		else{
			icon.removeMovieClip();
		}
		__label.visible = (label != " ");
		__label.text = label;
		if (listOwner.getNodeDepth(owner.node) == 1) __label.setStyle("fontWeight", "bold");
	}
	
	function size() {
		super.size();
		__label.setSize(__width, __height);
	}
}
