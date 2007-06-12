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
		icon.removeMovieClip();
		if (node != undefined) {
			var iconName="";
			var valid = node.object.isValid()
			if (valid == "error") {
				iconName = "stop";
				icon = attachMovie("Icon:" + iconName, "icon", 100, {_x:0, _y:2});
			} 
			else {
				iconName = undefined;
			}
		}
		if(iconName!= undefined){
			__label.visible = (label != " ");
			__label.text = label;
			__label._x = 16;
		} else{
			__label.visible = (label != " ");
			__label.text = label;
			__label._x = 0;
		}
	}
	
	public function size():Void {
		super.size();
		__label.setSize(__width, __height);
	}
}
