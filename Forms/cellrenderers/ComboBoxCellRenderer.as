import mx.core.UIComponent
import mx.controls.ComboBox;

/*
 * ComboBoxCellRenderer
 *
 * This class implements a cell renderer which is a combo box. CombBoxes have a dataProvider
 * which is used to display the contents in the drop list. This cell renderer is designed
 * to allow each row to have its own unique list. 
 *
 * The ComboBoxCellRenderer class expects to find a property in every row called "comboData"
 * which is an object with 2 properties: dp (the dataProvider), and selectedIndex.
 *
 * This renderer also shows how you can include data validation. The validation is done by
 * a sub-class; the framework in this renderer simply supports it.
 */

class ComboBoxCellRenderer extends UIComponent
{ 
	var combo : MovieClip; 
	var listOwner : MovieClip; // the reference we receive to the list 
	var getCellIndex : Function; // the function we receive from the list 
	var getDataLabel : Function; // the function we receive from the list 
	var isCellEditor : Boolean = true;

	function createChildren(Void) : Void 
	{
		trace('createChildren combobox in grid');
		createClassObject(ComboBox, "combo", 1, {styleName:this, owner:this, selectable:true}); 
		combo.addEventListener("change", this); 
		size(); 
	} 

	function size(Void) : Void 
	{ 
		combo.setSize(layoutWidth,layoutHeight);
	} 

	function validate(item):Void
	{
		// if the item fails validation, set combo.errorString = "your error message";
		// otherwise, be sure to set combo.errorString = "" so no error appears!
	}

	function setValue(str:String, item:Object, sel:Boolean) : Void 
	{ 
		combo.visible =(item!=undefined); 
		
		// set the combo box's dataProvider from the list within the item.comboData.
		// you must do this because you do not know if this item is the same as it was
		// before - the user may have sorted the data!
		combo.dataProvider = item.comboData.dp;
		// also update the combo box's selectedIndex from the row data - since the dataProvider
		// was changed, it will have reset selectedIndex and you need to match it to the
		// row data value.
		combo.selectedIndex = item.comboData.selectedIndex;
			
		if (item.comboData.selectedIndex!=undefined){ 
			validate(item);
		}
	
	} 
	
	function getValue() : Object
	{
		var rd = listOwner.getItemAt(getCellIndex().itemIndex);
		return rd.comboData;
	}

	function getPreferredHeight(Void) : Number 
	{ 
		return 21; 
	} 
	
	
	function getPreferredWidth(Void) : Number 
	{ 
		return 150;  // be more realistic
	}

	function handleEvent(evt:Object):Void
	{
		if (evt.type == "change")
		{ 
			// get the row data corresponding to the current itemIndex (row #)
			var rd = listOwner.getItemAt(getCellIndex().itemIndex);
			// update the row's comboData.selectedIndex with that of selectedIndex of
			// the combo box
			rd.comboData.selectedIndex = combo.selectedIndex;
			// update the dataProvider to reflect this. this will cause setValue() to
			// be triggered again, which then uses the comboData.selectedIndex to
			// set the comboBox properly.
			listOwner.editField(getCellIndex().itemIndex,"comboData",rd.comboData);
		} 
	}
	
}
// ActionScript Document