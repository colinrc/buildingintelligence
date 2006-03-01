import mx.core.UIComponent;
class Forms.DataGrid.MultiLineHeaderRenderer extends mx.core.UIComponent
{
   var multiLineLabel; //the label to be used for text
   var owner; // the row that contains this cell
   var listOwner; // the List/grid/tree that contains this cell

   // empty constructor
   function MultiLineCell()
   {
   }

// UIObject expects you to fill in createChildren by instantiating
// all the movie clip assets you might need upon initialization.
// Here, it's just a label.
   function createChildren():Void
   {
// createLabel is a useful method of UIObject--all components use this
      var c = multiLineLabel = createLabel("multiLineLabel", 10);
// links the style of the label to the
// style of the grid
      c.styleName = listOwner;
      c.selectable = false;
      c.tabEnabled = false;
      c.background = false;
      c.border = false;
      c.multiline = true;
      c.wordWrap = true;
   }

// By extending UIComponent, you get setSize for free;
// however, UIComponent expects you to implement size().
// Assume __width and __height are set for you now.
// You're going to expand the cell to fit the whole rowHeight.
   function size():Void
   {
// __width and __height are the underlying variables 
// of the getter/setters .width and .height
      var c = multiLineLabel;
      c._width = __width;
      c._height = __height;
   }

   function getPreferredHeight():Number
   {
   /* The cell is given a property, "owner",
   that references the row. It's always preferred
   that the cell take up most of the row's height.
   */
      return owner.__height-4;
   }

   function setValue(suggested:String, item:Object, selected:Boolean):Void
   {
   // Set the text property of the label
   // You could also set the text property to a variable.
      multiLineLabel.text = suggested;
	  //c.text = suggested;
   }
   // function getPreferredWidth :: only necessary for menu
   // function getCellIndex :: not used in this cell renderer
   // function getDataLabel :: not used in this cell renderer
}