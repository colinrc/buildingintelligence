import mx.controls.Label;

class Forms.Tree.LeftTreeCellRenderer extends mx.core.UIComponent {
	var __label:Label;
	var owner;
	var listOwner;
	var cell:Object;
	var icon:MovieClip;
	
	public function LeftTreeCellRenderer() {
	}
	
	public function createChildren():Void {
		super.createChildren();
		createClassObject(Label, "__label", this.getNextHighestDepth(), {visible:false});
	}
	
	public function setValue(label:String, node:Object):Void {
		clear();
		if (node != undefined) {
			var iconName="";
			var valid = node.object.isValid()
			if (valid == "error") {
				iconName = "stop";
			} 
			else {
				iconName = null;
			}
			icon = attachMovie("Icon:" + iconName, "icon", 100, {_x:__width - 18, _y:2});
		}
		else{
			icon.removeMovieClip();
		}
		__label.visible = (label != " ");
		__label.text = label;
	}
	
	public function size():Void {
		super.size();
		__label.setSize(__width, __height);
	}
}
