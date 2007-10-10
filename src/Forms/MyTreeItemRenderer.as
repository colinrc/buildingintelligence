package Forms {

	import mx.controls.treeClasses.*;
    import mx.collections.*;
	import mx.utils.ObjectUtil;
	import mx.controls.Image;
    public class MyTreeItemRenderer extends TreeItemRenderer {
		
		protected var leafIcon:Image;
		
		private var defaultLeafImage:String     = "../icons/defaultLeafIcon.png";
		private var inActiveLeafImage:String    = "../icons/inActive.png";
		private var noMapPosImage:String    	= "../icons/noMapPos.png";
		
		[Bindable]
		public var leafNodeImage:String = inActiveLeafImage;
		
        // Define the constructor.
        public function MyTreeItemRenderer() {
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
     

         public function makeLastChildArr(node:Object, requestedLevel:Number, startLevel:Number):Boolean {

                 var isLastFlag:Boolean = false;
                 var parentNode:XML = node.parent();
                 var grandParNode:XML = parentNode.parent();

                 if (grandParNode){
                     var children:XMLList = grandParNode.children();
                     var noOfChildren:Number = children.length();

                     if ( parentNode == children[noOfChildren -1]){
                         isLastFlag = true;
                     }

                     lineArr.push(isLastFlag);

                     if (requestedLevel !=  startLevel){
                         makeLastChildArr(node.parent(), requestedLevel, startLevel - 1);
                     }
                 }

                 return isLastFlag;
         }

         public function drawParentLines(i:Number):void {
             graphics.lineStyle(.7, 0x999999,.3,false,"NONE");
             var offset:Number = i*17 - 11;
             if (i == 2){offset = 23};
             graphics.moveTo(offset,-8);
             graphics.lineTo(offset,14);
         }

         public function drawChildLeafLines(indent:Number):void {
             graphics.lineStyle(.7, 0x999999,.3,false,"NONE");
             var offset:Number = indent + 6.5;
             graphics.moveTo(offset,-8);
             graphics.lineTo(offset,10);
             graphics.moveTo(offset,10);
             graphics.lineTo(offset + 10,10);
         }

         public function drawChildFolderLines(indent:Number):void {
             graphics.lineStyle(.7, 0x999999,.3,false,"NONE");
             var offset:Number = indent + 6.5;
             graphics.moveTo(offset,-8);
             graphics.lineTo(offset,2);
         }

         // Override the updateDisplayList() method
         // to set the text for each tree node.
        override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void {
             super.updateDisplayList(unscaledWidth, unscaledHeight);
             if(super.data) {
                 if (TreeListData(super.listData)){
                 graphics.clear();
                  var node:Object = TreeListData(super.listData).item;

                 var depth:Number = TreeListData(super.listData).depth;
                 var indent:Number = TreeListData(super.listData).indent ;

                  lineArr = new Array();

                 if(TreeListData(super.listData).hasChildren) {
                     var tmp:XMLList = new XMLList(TreeListData(super.listData).item);
                     var myStr:int = tmp[0].children().length();
                     super.label.text = " " + TreeListData(super.listData).label + " (" + myStr + ")";
                     graphics.lineStyle(.7, 0x999999,.3,false,"NONE");

                     //trace("icon = " + TreeListData(super.listData).icon );

                     // makeLastChildArr calls grandparentnode in order to determinewhether the parent&apos;s
                     // node is the last child.
                     // if no grandparent node exist, then it will give an error.
                     if ( depth > 2){
                         makeLastChildArr(node,depth,depth);
                         if (depth >3){
                             makeLastChildArr(node,3,depth);
                         }

                         lineArr = lineArr.reverse();

                         for(var i:Number=1;i<=depth;i++){

                             var parentDropLine:Boolean = false;

                             TreeListData(super.listData);

                             if(i == depth ){
                                 drawChildFolderLines(indent);
                             }
                             else { // Preceding lines
                                 if (i != 1 ){ // don&apos;t draw first line
                                 // pull out from correct index of lineArray
                                     isLast = lineArr[i-2];
                                     // draw line if corresponding parent is not lastchild
                                     if (!isLast){
                                         drawParentLines(i);
                                     }//if
                                 }//if
                             }//else
                         }//for
                     }// > 2

                     else if ( depth == 2){
                         var offset:Number = 23;
                         graphics.moveTo(offset,-8);
                         graphics.lineTo(offset,2);

                     }
                 }
                 else{

                     makeLastChildArr(node,3,depth);
                     lineArr = lineArr.reverse();

                     for(var i:Number=1;i<=depth;i++){

                         var parentDropLine:Boolean = false;

                         if(i == depth ){
                             drawChildLeafLines(indent);
                         }
                         else { // Preceding lines
                             if (i != 1 ){ // don&apos;t draw first line
                             // pull out from correct index of lineArray
                                 isLast = lineArr[i-2];
                                  // draw line if corresponding parent is not lastchild
                                 if (!isLast){
                                     drawParentLines(i);
                                 }//if
                             }//if
                         }//else
                     }//for
                 }

                 }//treee

             }// super data

         }
    }
}