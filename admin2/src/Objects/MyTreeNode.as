package Objects
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	import mx.collections.*;
	import mx.controls.Tree;
	import mx.controls.treeClasses.*;
	
	[Bindable("myTreeNode")]
	[RemoteClass(alias="elifeAdmin.objects.server.myTreeNode")]
	dynamic public class MyTreeNode implements IExternalizable {
		public var childObject:Array;
		public var object:Object;
		public var myXML:XML;
		
		public var openNodes:Object = new Object();
		
		public function writeExternal(output:IDataOutput):void {
			output.writeObject(childObject);
			output.writeObject(object);	
			output.writeObject(myXML);
		}
		
		public function readExternal(input:IDataInput):void {
			childObject = input.readObject() as Array;
			object = input.readObject() as Object;
			myXML = input.readObject() as XML;		
		}
		
		public function MyTreeNode():void{
			
		}
		public function make(type:uint, value:String, ob:Object):void
		{
			var icon:String = "def";
			var key:String = "";
			object = ob;
			childObject = new Array();
			if (type == 0) { //top level
				myXML = new XML("<"+value+" />");
				//trace(myXML.toXMLString());
			}
			else {
				if (object == null) {
					icon = "def";
					key = "";
					
				} else
				{
					key = object.getKey()+"_*_"+object.getUniqueID();
					icon = object.isValid();
					if (icon=="error") {icon = "err";}
				}
				myXML = new XML("<node name=\""+value+ "\" icon = \""+icon+"\" key=\""+key+"\" />");
				//trace(myXML.toXMLString());
			}
		}
		public function getObject():Object {
			return object;
		}
		public function getObjectinTree(key:String):Object {
			if (myXML..@key == key) { return object; }
			for (var i:int=0;i<childObject.length;i++) {
				if (childObject[i].myXML..@key == key) { return childObject[i].object; }
			}
			return null;
		}
		public function setObject(obj:Object):void {
			object= obj;
		}	
		public function appendChildObject(obj:Object):void {
			childObject.push(obj);
		}
		public function getChildObject():Array {
			return childObject;
		}
		public function setChildObject(obj:Array):void {
			childObject = obj;
		}	
		public function getXML():XML {
			return myXML;
		}
		public function getXMLOnly():XML {
			return myXML;
		}	
		public function setXML(obj:XML):void {
			myXML = obj;
		}
		public function appendChild(obj:MyTreeNode):MyTreeNode {
			childObject.push(obj);
			var objXML:XML = obj.getXMLOnly();
			myXML.appendChild(objXML);
			
			
			//trace ("myXML:"+myXML.toXMLString());
			return this;
			
		}
		
		public function fixOpenItems(tree:Tree, items:Object, key:String):XML {
			
			var ret:XML = walkTree(tree, items, key);
			
			return openNodes;
		}
		
		/**
		 * This method will traverse a Tree's model independent of it's
		 * type.
		 * 
		 * <p>Remember, I had coupled the model to this method by tracing
		 * @label, obviously you do not need to do this. The intention of
		 * this example is to show you that the dataDescriptor seperates
		 * the models type and is awesome. It enables you to create a tight 
		 * method like this without type checks on the model.</p>
		 *
		 * @param tree The Tree instance that will be examined by the method.
		 * @param item An item found in the dataProvider of the Tree passed in.
		 * @param startAtParent A boolean that determines if the method upon
		 * initialization will back up one level to the item passed in and
		 * start it's recursion at the item's parent node. 
		 */
		public function walkTree(tree:Tree, item:Object, key:String, startAtParent:Boolean = false):Object {
		    // get the Tree's data descriptor
		    var descriptor:ITreeDataDescriptor = tree.dataDescriptor;
		    var cursor:IViewCursor;
		    
		    var parentItem:Object;
		    var childItem:Object;
		    var childItems:Object;
		    
		    // if the item is null, stop
		    if (item == null)
		        return;
		        
		    // do we back up one level to the item's parent
		    if (startAtParent)
		    {
		        // get the parent
		        
		        parentItem = tree.getParentItem(item);
		     	//parentItem = item;
		        // is the parent real
		        if (parentItem == null) { 
		        	parentItem = item;
		        }
		        if (parentItem)
		        {
		            trace("|-- Parent Node ", parentItem[tree.labelField]);
		            // if the parent is a branch
		            if (descriptor.isBranch(parentItem))
		            {
		                // if the branch has children to run through
		                if (descriptor.hasChildren(parentItem)) 
		                {
		                    // get the children of the branch
		                    // this part of the algorithm contains the item
		                    // passed
		                    childItems = descriptor.getChildren(parentItem);
		                }
		            }
		            // if the branch has valid child items
		            if (childItems)
		            {
		                // create our back step cursor
		                cursor = childItems.createCursor();
		                // loop through the items parent's children (item)
		                while (!cursor.afterLast)
		                {
		                    // get the current child item
		                    childItem = cursor.current;
		
		                    var label:String = childItem[tree.labelField];
		                    var branch:Boolean = descriptor.isBranch(childItem);
		                    
		                    // good place for a custom method()
		                    trace("Sibling Nodes :: ", label, "Is Branch :: ", branch); 
		                    
		                    // if the child item is a branch
		                    if (descriptor.isBranch(childItem)) {
		                        // traverse the childs branch all the way down 
		                        // before returning
		                        walkTree(tree, childItem, key);
		                    }
		                    trace ("look here----------------------------------");
		                    if (childItem.@key == key) {
		                    	trace ("Found Key----------------------------------"+key);
		                    	openNodes = childItem;
		                    	return childItem;
		                    }
		                    // do it again!
		                    cursor.moveNext();
		                }
		            }
		        }
		    }
		    else // we don't want the parent OR this is the second iteration
		    {
		        // if we are a branch
		        if (descriptor.isBranch(item))
		        {
		            // if the branch has children to run through
		            if (descriptor.hasChildren(item)) 
		            {
		                // get the children of the branch
		                childItems = descriptor.getChildren(item);
		            }
		            
		            // if the child items exist
		            if (childItems)
		            {
		                // create our cursor pointer
		                cursor = childItems.createCursor();
		                // loop through all of the children
		                // if one of these children are a branch we will recurse
		                while (!cursor.afterLast)
		                {
		                    // get the current child item
		                    childItem = cursor.current;
		
		                    var label:String =  childItem[tree.labelField];
		                    var branch:Boolean = descriptor.isBranch(childItem);
		                    
		                    // good place for a custom method()
		                    trace("-- Sub Node :: ", label, "Is Branch :: ", branch); 
		
		                    // if the child item is a branch
		                    if (descriptor.isBranch(childItem)) {
		                        // traverse the childs branch all the way down 
		                        // before returning
		                        walkTree(tree, childItem, key);
		                    }
		                    //code goes here
		                    trace ("look here2-----------------------"+ label);
		                    if (childItem.@key==key) {
		                    	openNodes = childItem;
		                    	trace ("Found Key----------------------------------"+key);
		                    	return childItem;
		                    }
		                    
		                    // check the next child
		                    cursor.moveNext();
		                }
		            }
		        }
		    }
		}
	}
}