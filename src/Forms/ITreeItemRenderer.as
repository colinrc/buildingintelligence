package Forms {
	import mx.controls.treeClasses.*;
    import mx.collections.*;
	import mx.utils.ObjectUtil;
	import mx.controls.Image;
	import mx.core.*;
    public class ITreeItemRenderer extends TreeItemRenderer {
		
		protected var leafIcon:Image;
		
		private var defaultLeafImage:String     = "icons/defaultLeafIcon.png";
		private var inActiveLeafImage:String    = "icons/inActive.png";
		private var noMapPosImage:String    	= "icons/noMapPos.png";
		
		[Bindable]
		public var leafNodeImage:String = inActiveLeafImage;
		
        // Define the constructor.
        public function ITreeItemRenderer() {
        	
            super();
        }
       
        
        
        // Override the set method for the data property
        // to set the font color and style of each node.
        override public function set data(value:Object):void {
            super.data = value;
            if(TreeListData(super.listData).hasChildren) {
                setStyle("color", 0xff0000);
                setStyle("fontWeight", 'bold');
            }
            else {
                setStyle("color", 0x000000);
                setStyle("fontWeight", 'normal');
                //setStyle("defaultLeafIcon","{leafNodeImage}");	
            }  
        }
     
        // Override the updateDisplayList() method 
        // to set the text for each tree node.        
       override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            if(super.data) {
                if(TreeListData(super.listData).hasChildren) {
                    var tmp:XMLList = 
                        new XMLList(TreeListData(super.listData).item);
                    var myStr:int = tmp[0].children().length();
                    super.label.text =  TreeListData(super.listData).label + "(" + myStr + ")";
                }
            }
        }
    }
}