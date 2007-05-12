
		import mx.controls.Alert;
        import mx.messaging.Consumer;
    	import mx.logging.Log;
        import mx.controls.Menu;
        import mx.events.MenuEvent;
        import mx.containers.TabNavigator;
        import mx.events.ItemClickEvent;
        //import flash.events.MouseEvent;
		import flash.net.*;
		import flash.display.Sprite;
	    import flash.events.*;
	    import flash.net.FileFilter;
	    import flash.net.FileReference;
	    import flash.net.URLRequest;
 		import flash.external.ExternalInterface;
 		import flash.system.Security;
 		import mx.rpc.http.HTTPService;
 		import mx.utils.ObjectProxy;
 		import mx.messaging.*; 
 		import mx.messaging.messages.SOAPMessage;
 		import mx.rpc.AsyncToken;
 		import mx.rpc.events.*;
 		import flash.xml.XMLDocument;
 		import mx.rpc.xml.XMLEncoder;
 		import mx.collections.ArrayCollection;
		import flash.net.sendToURL
		import mx.core.Application;
		import mx.core.ClassFactory;
		import mx.containers.Form
		import mx.managers.PopUpManager;
		import flash.display.MovieClip;
		import XMLloaders.*;
	
		import Objects.*;
		import Objects.Server.*;
		import Objects.Instances.*;
		import Objects.Client.*;
		import mx.messaging.config.ServerConfig;
		import flash.xml.XMLNode;
		import flash.xml.XMLNodeType;
		import mx.controls.Tree;
		import Forms.ITreeItemRenderer;
		import Forms.MyTreeItemRenderer;
		import mx.collections.ArrayCollection;
		import mdm.*;
		import flash.display.*;
		import Forms.*;
		import Forms.Server.*;
		import flash.utils.*;
		import mx.utils.ObjectProxy;
		import Utils.Cellrenderers.MultilineComboBox;
		import mx.binding.utils.BindingUtils;
		
		/************************* Init system variable *********************************/	
		[Bindable]
		[Embed (source="C:/Documents and Settings/Jeff Kitchener/My Documents/Flex Builder 2/eLifeAdmin/bin/icons/check.png")]
		public var ok:Class;
		
		[Bindable]
		[Embed (source="C:/Documents and Settings/Jeff Kitchener/My Documents/Flex Builder 2/eLifeAdmin/bin/icons/warning.png")]
		public var warning:Class;
		
		[Bindable]
		[Embed (source="C:/Documents and Settings/Jeff Kitchener/My Documents/Flex Builder 2/eLifeAdmin/bin/icons/stop.png")]
		public var err:Class;
		
		[Bindable]
		[Embed (source="C:/Documents and Settings/Jeff Kitchener/My Documents/Flex Builder 2/eLifeAdmin/bin/icons/check-grey.png")]
		public var empty:Class;
		
		[Bindable]
		[Embed (source="C:/Documents and Settings/Jeff Kitchener/My Documents/Flex Builder 2/eLifeAdmin/bin/icons/default.png")]
		public var def:Class;
		
		[Bindable]
		public var currentObj:ObjectProxy
			
		static public var devTypes:Array = [
			{label:"CBUS",data:Objects.Server.CBus},
			{label:"COMFORT",data:Objects.Server.Comfort},
			{label:"CUSTOM_CONNECT",data:Objects.Server.CustomConnect},
			{label:"DMX",data:Objects.Server.DMX},
			{label:"DYNALITE",data:Objects.Server.Dynalite},
			{label:"GC100",data:Objects.Server.GC100},
			{label:"HAL",data:Objects.Server.Hal},
			{label:"IR_LEARNER",data:Objects.Server.IR_Learner},
			{label:"JANDI",data:Objects.Server.Jandy},
			{label:"KRAMER",data:Objects.Server.Kramer},
			{label:"M1",data:Objects.Server.M1},
			{label:"NUVO",data:Objects.Server.Nuvo},
			{label:"OREGON",data:Objects.Server.Oregon},
			{label:"PELCO",data:Objects.Server.Pelco},
			{label:"RAW_CONNECTION",data:Objects.Server.Raw_Connection},
			{label:"SIGN_VIDEO",data:Objects.Server.SignVideo},
			{label:"TUTONDO",data:Objects.Server.Tutondo}
		];
			
		
		public function get deviceTypes():Array {
				return devTypes;
			}
		
		public var projName:String;
		public var advancedOn:Boolean = false;
		public var unSaved:Boolean = false;
		public var projectFileName:String = "";
		public var formDepth:int = 0;
		public var keys:Array;
		public var usedKeys:Array;
		public var bodyInstance:Object;
		
		public var objClass:Class;
	    public var obj2Class:Class;
		
		[Bindable]
		public var project:Objects.Project;
		public var project_xml:XML = new XML();
		public var overrides_xml:XML;
		public var parameters_xml:XML = new XML();
		public var default_client_xml:XML = new XML();
		public var default_server_xml:XML = new XML();
		public var controlTypeAttributes_xml:XML = new XML();
		
		[Bindable]
		public var designTree_xml:MyTreeNode;
		public var controlTree_xml:XML = new XML();
		
		public var client_xml:XML = new XML();
		public var server_xml:XML = new XML();
		
		public var comfort_xml:XML = new XML();
		
		public var serverDesign:Objects.Server.Server;
		public var serverInstance:ServerInstance;
		
		public var loader:XLoader;
		
		public var workFlow:WorkFlow = new WorkFlow();
		
		[Bindable]
		public var vDivBoxWidth:String = "280";
		public var eLifeAdmin_xml:XML = new XML;
		
		public var uniqueID = 0;
		
		/***********************************************************************************/
		
		public function incFormDepth():int {
			formDepth++;
			return formDepth;
		}
		public function getKey():String {
			return "design";
		}
		
		public function isValid():String {
			return "ok";
		}
		public function setProjectName(project:String):void {
			projName = project;
		}
		public function getProjectName():String {
			return projName;
		}
		
   		public function init():void {
			dockedMenuBar.addEventListener(MenuEvent.ITEM_CLICK, itemClickInfo);
			firstOne();
			
		}
		public function setProject(proj:Object):void {
			project = proj;
		}
		
		 public function getIcon(item:Object):Class {
           	
           	 //trace (item.@icon.toString());
           	 if (item.@icon == "ok") {
           	 	return ok;
           	 }
           	 else if (item.@icon == "empty") {
           	 	return empty;
           	 }
           	 else if (item.@icon == "err") {
           	 	return err;
           	 }
           	 else if (item.@icon == "warning") {
           	 	return warning;
           	 }
           	 else if (item.@icon == "def") {
           	 	return def;
           	 }
           	 return null;
           }
		public function getProject():Object {
			return project;
		}
		/***************************** new project loaded reset everything ****************/
	
		public function setProjectXML(proj:XML):void {
			project_xml = proj;
					
			controlTree_xml:XML;
			controlTree_xml = new XML();
			project = new Project(project_xml);
			
			//var r1:XMLList = project_xml.attributes();
			//var i:int = r1.length();
			
			//for each (attrib in r1) {
			//	project[attrib] = project_xml.attributes[attrib];
			//}
			//for (var attrib:XMLList in project_xml.firstChild.attributes) {
				//project[attrib] = project_xml.firstChild.attributes[attrib];
			//}
			
			//Append list of server designs and list of server implementations
			serverDesign = new Server();
			serverInstance = new ServerInstance(); 
			
			
			
		//	var childNodes:XMLList =project_xml.children();
			
			var xmlNodeDesign:XML = project_xml.elements("CONFIG")[0];
			var xmlNodeInstance:XML = project_xml.elements("serverInstance")[0];
			
			serverDesign.setXML(xmlNodeDesign);
			serverInstance.setXML(xmlNodeInstance);
			
			//moved from before for each
			serverInstance.serverDesign = serverDesign;
			
			designTree_xml =new MyTreeNode();
			designTree_xml.make(0,"design",this);
			designTree_xml.appendChild(serverDesign.toTree());
			designTree_xml.object = this;
			//trace("After Server:" + designTree_xml.getXML().toString());
			var clients:Array = serverDesign.getClients();
			
			for (var client:int = 0; client < clients.length; client++) {
				designTree_xml.appendChild(clients[client].toTree());
			}
			//trace("After clients:" + designTree_xml.getXML().toString());
			controlTree_xml.appendChild(serverInstance.toTree());
			//trace(designTree_xml.toString());
			
			//
			
			refreshTheTree();
			keys = serverDesign.getKeys();
			
						
		}
		
		public function refreshTheTree():void {
			
			keys = serverDesign.getKeys();
			
			var clientList:Array = serverDesign.getClients();
			usedKeys = null;
			usedKeys = new Array();
			
			for (var client:int=0 ; client < clientList.length ; client++) {
			
				usedKeys = usedKeys.concat(clientList[client].getUsedKeys());
			}
	
			workFlow.createWorkflow(designTree_xml);
			//remove and add in listner
			//TextDescription.text = srvList.selectedItem.description;
			//errorDescription.text = srvList.selectedItem.object.getValidationMsg();
			
		//	output_panel.setDescription(projectTree.selectedNode.description);
		//	output_panel.setError(projectTree.selectedNode.object.getValidationMsg());
		//	output_panel.draw();
			
		}
		
		public function isValidIP(ip:String):Boolean  {
			var isValid:Boolean = true;
			var ip_arr:Array = ip.split(".");
			if (ip_arr.length != 4) {
				isValid = false;
			} else {
				for (var i = 0; i < 4; i++) {
					if (ip_arr[i] != Number(ip_arr[i])) {
						isValid = false;
						break;
					}
				}
			}
			return isValid;
		}
		public function getValidationMsg():String {
			return "";
		}
		
		public function getUniqueID():String {
			return "0";
		}
		
		public function isKeyUsed(inKey:String):Boolean  {
			for (var key in usedKeys) {
				if (usedKeys[key] == inKey) {
					return true;
				}
			}
			return false;
		}
		
		/***********************************************************************************/
		public function getProjectXML():XML {
			return projectXML;
		}
		
		public function firstOne():void {
				  	
		    XLoader.URL = "data/overrides.xml";
		    loader = XLoader.getInstance();
		    loader.addEventListener("onInit", loadOverides);
		 
		}
		public function loadOverides(event:Event):void {
			overrides_xml = loader.data;
			//trace(overrides_xml.toXMLString());
			
			loader.removeEventListener("onInit", loadOverides);
			loader.setURLandLoad("data/parameters.xml");	    
		    loader.addEventListener("onInit", loadParameters);
		    
		}
		public function loadParameters(event:Event):void {
			parameters_xml = loader.data;
			//trace(parameters_xml.toXMLString());
			
			loader.removeEventListener("onInit", loadParameters);
			loader.setURLandLoad("defaults/default_client.xml");	    
		    loader.addEventListener("onInit", loadDefaultClient);
		}
		public function loadDefaultClient(event:Event):void {
			default_client_xml = loader.data;
			//trace(default_client_xml.toXMLString());
			
			loader.removeEventListener("onInit", loadDefaultClient);
			loader.setURLandLoad("defaults/default_server.xml");	    
		    loader.addEventListener("onInit", loadDefaultServer);
		}
		public function loadDefaultServer(event:Event):void {
			default_Server_xml = loader.data;
			//trace(default_Server_xml.toXMLString());
			
			loader.removeEventListener("onInit", loadDefaultServer);
			loader.setURLandLoad("data/controlTypeAttributes.xml");	    
		    loader.addEventListener("onInit", loadControlTypes);
		}
		public function loadControlTypes(event:Event):void {
			controlTypeAttributes_xml = loader.data;
			//trace(controlTypeAttributes_xml.toXMLString());
			
			loader.removeEventListener("onInit", loadControlTypes);
			loader.setURLandLoad("defaults/default_comfort.xml");	    
		    loader.addEventListener("onInit", loadDefaultComfort);
		}
		public function loadDefaultComfort(event:Event):void {
			comfort_xml = loader.data;
			//trace(comfort_xml.toXMLString());
			
			loader.removeEventListener("onInit", loadDefaultComfort);
			systemSettings();
			trace("Completed xml loads");
		}
								
		
		public function loaderOnComplete(event:Event):void {
			var loader:URLLoader = new URLLoader(event.target);
		 var overrides_xml:XML;
			overrides_xml = new XML(loader.data);
			//trace(overrides_xml.toXMLString());
			
		}
			
		public function openProject(project:String):void { 	
			loader.setURLandLoad("projects/" + project + ".elp");	    
		   // loader.addEventListener("onInit", loadDefaultComfort);
		    loader.addEventListener("onInit", continueOpenProject); 
		}	
		public function continueOpenProject(event:Event):void {
			setProjectXML(loader.data);
		    currentState = "projectOpen";
			buttonBar.selectedIndex = "1";
		}	
		public function setProjectWithXML(file:XML):void {
			setProjectXML(file);
		    currentState = "projectOpen";
			buttonBar.selectedIndex = "1";
			
			
			//projectTree.itemRenderer=new ClassFactory(Forms.MyTreeItemRenderer);

          
            
           /* <mx:itemRenderer>
        		<mx:Component>
        			<mx:VBox>
        				<mx:Text id="treeLabel" width="100%" text="default" />
        				<mx:Image id="iconImage" height="45" />
        			</mx:VBox>
        		</mx:Component>
        	</mx:itemRenderer> 
		/*	<mx:itemRenderer>
											
											<mx:Component>
												<mx:VBox>
												 
												<mx:Text id="block" text="{data.text}" color="{data.color}"/>
												<mx:Image source="icons/{data.image}" visible="{data.image_visible}"/>
												</mx:VBox>
											</mx:Component>
											
											</mx:itemRenderer>
            */
            
            
          //  trace ("Designtree xml:"+ designTree_xml.getXML());
			projectTree.dataProvider = designTree_xml.getXML();
		}	
		/*********************************************************************************/
		//List and Tree events
		
		public function changeEvt(event:flash.events.Event):void {
                TextDescription.htmlText=event.currentTarget.selectedItem.description;
                currentObj = new ObjectProxy(workFlow.getObject(event.currentTarget.selectedItem.key));
                doErrorDesc(currentObj);
               	handleNavigation(currentObj);
        }

		public function changeTreeEvt(event:flash.events.Event):void {
           
            var key:String = event.currentTarget.selectedItem.@key;
            TextDescription.htmlText = workFlow.getDescription(key);
            currentObj = new ObjectProxy(workFlow.getObject(key));
            doErrorDesc(currentObj);
            handleNavigation(currentObj);
        }
        
        public function set CurrentObject(obj:ObjectProxy):void {
        	currentObj = obj;
        }
        public function get CurrentObject():ObjectProxy{
        	return currentObj;
        }
        
        public function resetFormBindings(source:Object):void{
        	BindingUtils.bindProperty(source,"device",currentObj.getData(),"device");
        }
        
        private function handleNavigation(obj:ObjectProxy):void {
        	body.label = "Not yet Implemented";
        	var myDo:DisplayObject = main.getChildByName("body2");
        	if (myDo != null) {
        		main.removeChild(myDo);
        	}
        	
        	//main.childDescriptors[1].visible = false;
        	if (obj != null) {
        		//var o1:Object = ObjectProxy(dataHolder).object_proxy::object;
        		var myXML:XML = obj.toXML();
        		bodyXML.setXML(myXML);
	        	try {
        			if (bodyInstance != null) {
        				body.removeChild(bodyInstance);
        				bodyInstance = null;
        			}
	        	}
    			catch (err:Error) {
    				trace("Could not remove body instance: "+bodyInstance.toString() + " Error was "+err.message);
    			}
        		try {
        			
        			var ac:Object = obj.getClassForm();
        			var descType:XML = describeType(ac);
        			if (descType.@name == "Array") {
        			
	        			objClass = ac[0];
	        			obj2Class = ac[1];
        			}
        			else {
        				objClass = ac;
        				obj2Class = null;
        			}
        			
        			bodyInstance = new objClass();
        			
        			//var dataObj:ObjectProxy = new ObjectProxy(obj.getData());
        			
        			bodyInstance.dataHolder = obj.getData();
        			body.label = obj.getName();  
        			body.addChild(bodyInstance);
        			
        			if (obj2Class != null) {
        				var tab2:tabPanel = new tabPanel();
	        			tab2.label = obj.get2Name();
	        			var tab2Content:Object = new obj2Class();
	        			tab2Content.dataHolder = obj.getData();
	        			tab2.addChild(DisplayObject(tab2Content));
	        			main.addChildAt(DisplayObject(tab2), 1);
	        			
        			}        			
        		}
        		catch (err:Error) {
        			trace("Could not create body instance:  Error was "+err.message);
        		}
	        }
        }
        
        private function doErrorDesc(obj:ObjectProxy):void {
        	try {
	        	var tempMsg:String =obj.getValidationMsg();
	            
	            if (tempMsg == null || tempMsg == "") {
	            	tempMsg = "";
	            	//move to help
	            	output_panel.selectedIndex = 0;
	            }
	            else {
	            	//move to error
	            	output_panel.selectedIndex = 1
	            }
	            errorDescription.text = tempMsg;
	        } 
            catch (err:Error) {
            	errorDescription.text ="";
                trace("ERROR:"+err.message.toString());
                output_panel.selectedIndex = 0;
            }  
        }
            
		public function dataTip(item:Object):String {
			return item.description;
		}
		
		
		
		
		
		
        // The event listener for the itemClick event.
        public function itemClickInfo(event:MenuEvent):void {
           
  //          ta1.text+="\ntarget menuBarIndex: " + event.currentTarget.label;
     //       ta1.text+="\ntarget label: " + event.target.dataProvider.@label;
    //        ta1.text+="\ntarget data: " + event.target.dataProvider.@data;
        
			switch(event.label) {
			    case "New Project":
			      trace("Sunday");
			      currentState = "projectDetails";
			      buttonBar.selectedIndex = "0";
			      //initiailize();
			      
			      break;
			    case "Open Project":
			      trace("Open project");
			     // var pop1:IFlexDisplayObject = PopUpManager.createPopUp(this, ProjectDialog,true);
			      var file:LoadMyFile = new LoadMyFile();
			      
			     
			      
				//  var file:FileReference = new FileReference();
			//	  var projectTypes:FileFilter = new FileFilter("eLife Admin Project Files (*.elp)", "*.elp");
			//	  var elifeTypes:Array = new Array(projectTypes);
				// Array rest = new Array;
				 // ExternalInterface.call("get",rest);
				  
		       //   configureListeners(file);
				//  file.browse(elifeTypes);
				 // file.upload(file);
				 // useWebService(1,"blah");
				  
				//  <mx:Model source="aaaaa.elp" id="project"/>

			      break;
			    case "Save Project":
			      trace("Save pro");
			      break;
			    case "Save Project As..":
			      trace("save pro as");
			      break;
			    case "Exit":
			      currentState = "";
			      var url:URLRequest = new URLRequest("javascript:window.close()");
				  navigateToURL(url,"_self"); 
			      return;
			      
			    case "Help":
			      trace("Wednesday");
			      break;
			    case "About":
			      trace("Thursday");
			      break;
			    default:
			      trace("Out of range");
        	}
        }

		private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.CANCEL, cancelHandler);
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(Event.SELECT, selectHandler);
        }
		private function getTypes():Array {
            var allTypes:Array = new Array(getImageTypeFilter(), getTextTypeFilter());
            return allTypes;
        }

        private function getImageTypeFilter():FileFilter {
            return new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png");
        }

        private function getTextTypeFilter():FileFilter {
            return new FileFilter("Text Files (*.txt, *.rtf)", "*.txt;*.rtf");
        }

        private function cancelHandler(event:Event):void {
            trace("cancelHandler: " + event);
        }

        private function completeHandler(event:Event):void {
            trace("completeHandler: " + event);
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
            trace("httpStatusHandler: " + event);
        }
        
        private function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event);
        }

        private function openHandler(event:Event):void {
            trace("openHandler: " + event);
        }

        private function progressHandler(event:ProgressEvent):void {
            var file:FileReference = FileReference(event.target);
            trace("progressHandler name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
        }

        private function selectHandler(event:Event):void {
            var file:FileReference = FileReference(event.target);
            trace("selectHandler: name=" + file.name + " URL=" + uploadURL.url);
            file.upload(uploadURL);
        }

        
        
        public function buttonClick(event:ItemClickEvent):void {
 			
 			switch(event.label) {
			    case "Project Details":
			      currentState = "projectDetails";
			      trace("Project Details");
			      break;
			    case "Design":
			      trace("Design");
			      currentState = "projectOpen";
			      break;
			    case "Server Controls":
			      trace("Server Controls");
			      break;
			    case "Library":
			      trace("Library");
			      break;
			    case "Preview":
			      trace("Preview");
			      break;	      
			    case "History":
			      //srv.loadProject("fred");
			      trace("History");
			      break;
			    default:
			      trace("Out of range");
        	}
        } 
        
        public function setPath():void  {
			mdm.Dialogs.BrowseFolder.title = "Please select a Folder";
			var tempString = mdm.Dialogs.BrowseFolder.show();
			if (tempString != "false") {
				project.path = tempString;

				//_global.history.setProject(_global.project.project, _global.project.path);
				mdm.FileSystem.makeFolder(project.path + "/server");
				mdm.FileSystem.makeFolder(project.path + "/server/config");
				mdm.FileSystem.makeFolder(project.path + "/server/datafiles");
				mdm.FileSystem.makeFolder(project.path + "/server/script");
				mdm.FileSystem.makeFolder(project.path + "/client");
				mdm.FileSystem.makeFolder(project.path + "/client/lib");
				mdm.FileSystem.makeFolder(project.path + "/client/lib/icons");
				mdm.FileSystem.makeFolder(project.path + "/client/lib/maps");
				mdm.FileSystem.makeFolder(project.path + "/client/lib/backgrounds");
				mdm.FileSystem.makeFolder(project.path + "/client/lib/sounds");
				mdm.FileSystem.makeFolder(project.path + "/client/lib/objects");
				unsaved = true;
			} else {
				mdm.Dialogs.prompt("Your project cannot be saved without selecting a project directory.");
			}
		}
		
	    public function saveFile(saveType:String):void  {
		if (saveType == "Project") {
			if (project.path.length) {
				setPath();
				if (project.path.length) {
					return;
				}
			}
			if (projectFileName.length) {
				var newProjectXML = new XMLNode(1, "project");
				for (var attrib in project_xml) {
					if (project_xml[attrib].length) {
						newProjectXML.attributes[attrib] = project[attrib];
					}
				}
				/*Append project contents to project node*/
				newProjectXML.appendChild(serverDesign.toProject());
				newProjectXML.appendChild(serverInstance.toXML());
				mdm.FileSystem.saveFile(projectFileName, writeXMLFile(newProjectXML, 0));
				//TODO change to flex way
				//mdm.Application.title = "eLIFE Admin Tool - [" + _global.projectFileName + "]";
				//mdm.Forms.MainForm.title = "eLIFE Admin Tool - [" + _global.projectFileName + "]";
				unSaved = false;
			} else {
				var tempString = mdm.Dialogs.inputBox("Enter project file name", "Enter project file name");
				if (tempString != "false") {
					projectFileName = project.path + tempString + ".elp";
					var newProjectXML = new XMLNode(1, "project");
					for (var attrib in project_xml) {
						if (project[attrib].length) {
							newProjectXML.attributes[attrib] = _global.project[attrib];
						}
					}
					/*Append project contents to project node*/
					newProjectXML.appendChild(serverDesign.toProject());
					newProjectXML.appendChild(serverInstance.toXML());
					mdm.FileSystem.saveFile(projectFileName, writeXMLFile(newProjectXML, 0));
				//	mdm.Application.title = "eLIFE Admin Tool - [" + _global.projectFileName + "]";
				//	mdm.Forms.MainForm.title = "eLIFE Admin Tool - [" + _global.projectFileName + "]";
					unSaved = false;
				}
			}
		} else {
			//replace with apollo code or correct file system access
			mdm.Dialogs.BrowseFile.buttonText = "Save";
			mdm.Dialogs.BrowseFile.title = "Please select a " + saveType + ".xml file to save";
			mdm.Dialogs.BrowseFile.dialogText = "Select a " + saveType + ".xml to Save";
			mdm.Dialogs.BrowseFile.defaultExtension = "xml";
			mdm.Dialogs.BrowseFile.filterList = "XML Files|*.xml";
			mdm.Dialogs.BrowseFile.filterText = "XML Files|*.xml";
			var file = mdm.Dialogs.BrowseFile.show();
			if (file != undefined) {
				if (saveType == "Server") {
					mdm.FileSystem.saveFile(file, writeXMLFile(serverDesign.toXML(), 0));
				} else {
					mdm.FileSystem.saveFile(file, writeXMLFile(client_test.toXML(), 0));
				}
				mdm.Dialogs.prompt("File saved to: " + file);
			}
		}
	}
        
		 public function writeXMLFile(inNode:XMLNode, depth:Number):String  {
			var tempString = "";
			if (inNode.nodeType == 3) {
				tempString += inNode.toString();
				return tempString;
			}
			for (index = 0; index < depth; index++) {
				tempString += "\t";
			}
			tempString += "<";
			tempString += inNode.nodeName;
			for (attribute in inNode.attributes) {
				var tempAtt = inNode.attributes[attribute];
				tempAtt=(tempAtt.split("&")).join("&amp;");
				tempAtt=(tempAtt.split("<")).join("&lt;");
				tempAtt=(tempAtt.split(">")).join("&gt;");
				tempAtt=(tempAtt.split("'")).join("&apos;");
				tempAtt=(tempAtt.split('"')).join("&quot;");
				tempString += " " + attribute + '="' + tempAtt + '"';
			}
			if (inNode.hasChildNodes()) {
				if (inNode.firstChild.nodeType == 3) {
					tempString += ">";
					tempString += writeXMLFile(inNode.firstChild, 0);
					tempString += "</" + inNode.nodeName + "> \n";
				} else {
					tempString += "> \n";
					for (var child = 0; child < inNode.childNodes.length; child++) {
						tempString += writeXMLFile(inNode.childNodes[child], depth + 1);
					}
					for (index = 0; index < depth; index++) {
						tempString += "\t";
					}
					tempString += "</" + inNode.nodeName + "> \n";
				}
			} else {
				tempString += "/> \n";
			}
			return tempString;
		}
        public function advancedClick(event:MouseEvent):void {
       	
        //	srv.url="http://localhost:8182/guard"
        //	srv.useProxy = true;
        //	srv.destination = "c:\\";
        ///	srv.setCredentials("jeff", "spec1");
        //	srv.resultFormat = "object";
        //srv.send();
       /// 	var st:ArrayCollection
        ///	st = new ArrayCollection(srv.lastResult);
        	
       // 	ta.text =st.toString();
        	
        	
        	//ta.text =  srv.lastResult.toString();
 
        }
        
         
         	
        
        //	var xml:XML;
        //	xml = new XML(srv.lastResult.toString());
        	        	
       // 	projectTree.dataProvider = xml;
        	//ta.text = srv.lastResult.toString();
       // 	trace("adv");
      //  }
        
    /*    import mx.rpc.soap.WebService;
   		mx.rpc.events.ResultEvent;
        mx.rpc.events.FaultEvent;

    public function useWebService(intArg:int, strArg:String):void {
        var ws:WebService = new mx.rpc.soap.WebService();
        ws.destination = "eLifeAdminWS";
        ws.echoArgs.addEventListener("result", echoResultHandler);
        ws.addEventListener("fault", faultHandler);
        ws.loadWSDL();
        ws.echoArgs(intArg, strArg);
    }  */

  //  public function echoResultHandler(event:ResultEvent):void {
    //    var retStr:String = event.result.echoStr;
      //  var retInt:int = event.result.echoInt;
     //Do something.
   // }

   // public function faultHandler(event:FaultEvent):void {
  //deal with event.faultstring, etc
   // }

	