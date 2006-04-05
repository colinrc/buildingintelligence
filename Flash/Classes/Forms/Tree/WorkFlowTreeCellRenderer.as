class Forms.Tree.workFlowTreeCellRenderer extends mx.controls.treeclasses.TreeRow {
	var owner;
	var listOwner;
	var cell:Object;
	var icon:MovieClip;
	
	function workFlowTreeCellRenderer() {
	}
	
	function createChildren() {
		super.createChildren();
	}
	
	function setValue(node, state) {
		super.setValue(node, state);
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
				else {/*warning*/
					iconName = "warning";
				}
			}
			icon = attachMovie("Icon:" + iconName, "icon", 100, {_x:listOwner.width - indent + 5, _y:2});
		}
		else{
			icon.removeMovieClip();
		}
		size();
	}
	
	function disclosurePress() {
		super.disclosurePress();
	}
	
	function size() {
		super.size();
	}
	
	function setColor(color:Number):Void {
		cell.setColor(color);
	}
}
