import mx.core.View;
import mx.controls.Loader;
import mx.controls.Label;
class Forms.DataGrid.ImageCellRenderer extends View {
	//static public var symbolName:String = "ImageCellRenderer";
	//static public var symbolOwner:Object = ImageCellRenderer;
	//public var className:String = "ImageCellRenderer";
	private var multiLineLabel;
	// The label to be used for text.
	private var owner;
	// The row that contains this cell.
	private var listOwner;
	// The List, data grid or tree containing this cell.
	// Cell height offset from the row height total and preferred cell width.
	private static var PREFERRED_HEIGHT_OFFSET = 0;
	private static var PREFERRED_WIDTH = 100;
	private var image_ldr:MovieClip;
	private var label_lbl:MovieClip;
	private var lastIcon:String;
	public var getDataLabel:Function;
	public function ImageCellRenderer() {
	}
	public function createChildren():Void {
		//image_ldr = createObject("Loader", "image_ldr", 1, {styleName:this, owner:this});
		createChild(Loader, "image_ldr");
		image_ldr.setSize(22, 22);
		image_ldr.autoLoad = true;
		image_ldr.scaleContent = true;
		image_ldr.opaqueBackground = 0x0099CC;
		//label_lbl = createObject("Label", "label_lbl", 1, {styleName:this, owner:this});
		createChild(Label, "label_lbl");
	}
	public function doLayout():Void {
		label_lbl.move(image_ldr.x + image_ldr.width, 0);
		var w:Number = width - label_lbl.x;
		label_lbl.setSize(w, 22);
	}
	public function getPreferredHeight():Number {
		return owner.__height - PREFERRED_HEIGHT_OFFSET;
	}
	public function setValue(suggestedValue:String, item:Object, selected:Boolean):Void {
		if (item == undefined) {
			visible = false;
			return;
		}
		visible = true;
		if (lastIcon != item.icon) {
			lastIcon = item.icon;
			image_ldr.load(item.icon);
		}
		var label:String = getDataLabel();
		//trace("lbl: " + lbl);
		//trace(item[lbl]);
		label_lbl.text = item[label];
	}
	// function getPreferredWidth :: only for menus and DataGrid headers
	// function getCellIndex :: not used in this cell renderer
}
