		import FileAccess.FileCreateDirPanel;
		import FileAccess.FileOpenPanel;
		import FileAccess.FileSavePanel;
		import FileAccess.XMLFile;
		
		import Forms.*;
		import Forms.Control.clientView;
		import Forms.Control.serverView;
		import Forms.Server.*;
		
		import Objects.*;
		import Objects.Client.*;
		import Objects.Instances.*;
		import Objects.Server.*;
		
		import XMLloaders.*;
		
		import flash.display.*;
		import flash.events.*;
		import flash.filesystem.*;
		import flash.net.*;
		import flash.utils.*;
		
		import mx.binding.utils.BindingUtils;
		import mx.collections.ArrayCollection;
		import mx.collections.XMLListCollection;
		import mx.controls.Alert;
		import mx.events.*;
		import mx.messaging.*;
		import mx.rpc.events.*;
		import mx.utils.ObjectProxy;


		/************************* Init system variable *********************************/	
		[Bindable]
		[Embed (source="../bin/icons/check.png")]
		public var ok:Class;
		
		[Bindable]
		[Embed (source="../bin/icons/warning.png")]
		public var warning:Class;
		
		[Bindable]
		[Embed (source="../bin/icons/stop.png")]
		public var err:Class;
		
		[Bindable]
		[Embed (source="../bin/icons/check-grey.png")]
		public var empty:Class;
		
		[Bindable]
		[Embed (source="../bin/icons/default.png")]
		public var def:Class;
		
		[Bindable]
		[Embed (source="../bin/icons/folder.gif")]
		public var folder:Class;
		
		[Bindable]
		[Embed (source="../bin/icons/server.gif")]
		public var server:Class;
		
		[Bindable]
		[Embed (source="../bin/icons/client.gif")]
		public var client:Class;
		
		[Bindable]
		public var currentObj:ObjectProxy;
		
		[Bindable]
		public var currentCTObj:ObjectProxy;
					
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
			
		static public var rawConfigNames:Array = [
			{label:"POLL_STRING2",data:"POLL_STRING2", value:"Second poll\n"},
			{label:"POLL_STRING1",data:"POLL_STRING1", value:"First poll\x20World\r\n"},
			{label:"POLL_VALUE2",data:"POLL_VALUE2", value:"270"},
			{label:"POLL_VALUE1",data:"POLL_VALUE1", value:"180"},
			{label:"STARTUP5",data:"STARTUP5", value:"Starup string 5\n"},
			{label:"STARTUP4",data:"STARTUP4", value:"Starup string 4\n"},
			{label:"STARTUP3",data:"STARTUP3", value:"Starup string 3\n"},
			{label:"STARTUP2",data:"STARTUP2", value:"Starup string 2\n"},
			{label:"STARTUP1",data:"STARTUP1", value:"Starup string 1\n"},
			{label:"ETX",data:"ETX", value:"\n"},
			{label:"STX",data:"STX", value:""}
		];
			
		
		public function get deviceTypes():Array {
			return devTypes;
		}
		public function get rawConnections():Array {
			return rawConfigNames;
		}
		[Bindable]
		public var catalogsMulti:Array;
		
		[Bindable]
		public var codesMulti:Array;
		
		[Bindable]
		public var moduleNumber:Array;
		
		public var projName:String;
		[Bindable]
		public var advancedOn:Boolean = false;
		[Bindable]
		public var unSaved:Boolean = false;
		
		private var projectFileName:File;
        private var projectFileStream:FileStream = new FileStream();
		
		public var formDepth:int = 0;
		public var keys:Array;
		public var usedKeys:Array;
		public var bodyInstance:Object;
		
		public var controlBodyInstance:Object;
		public var serverViewObj:serverView = new serverView();
		public var clientViewObj:clientView = new clientView();
		
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
		[Bindable]
		public var dt:XMLListCollection;
		public var dtTemp:XML;
		
		[Bindable]
		public var ct:XMLListCollection;
		public var ctTemp:XML;
		
		[Bindable]
		public var controlTree_xml:MyTreeNode; 
		
		private var current_tree_node:XML = null;
		private var current_tree_openItems:Array = null;
		
		public var client_xml:XML = new XML();
		public var server_xml:XML = new XML();
		
		public var comfort_xml:XML = new XML();
		
		public var serverDesign:Objects.Server.Server;
		public var serverInstance:ServerInstance;
		
		[Bindable]
		public var workFlow:WorkFlow = new WorkFlow();
		
		[Bindable]
		[Bindable(event="vdivBoxWidthEvent")]
		public var vDivBoxWidth:String = "280";
		[Bindable]
		[Bindable(event="hdivBoxHeightEvent")]
		public var hDivBoxHeight:String = "500";
		
		[Bindable]
		[Bindable(event="hdivBoxHeightEventS")]
		public var hDivBoxHeightS:String = "500";
		[Bindable]
		[Bindable(event="vdivBoxWidthEventS")]
		public var vDivBoxWidthS:String = "280";
		
		public var eLifeAdmin_xml:XML = new XML;
		
		public var uniqueID:int = 0;
		private var myOpenItems:Object;
		private var refreshData:Boolean = false;		
		/***********************************************************************************/
		
		public function vdivBoxWidthEvent(event:Event):void {
			var fileSaver:XMLFile = new XMLFile();
			
			fileSaver.saveXMLFile("data/elifeAdmin.xml", eLifeAdmin_xml.toString());
		}//same as comments
		
		public function advLabel():void {
			if (advancedOn == true) {
				advanced.label = "To Basic";
			}
			else {
				advanced.label = "To Advanced";
			}
		}
		
		public function fileSystemTreeCreated(obj:Object) {
			
			//f1:File = new File("c:/");
			//fileSystemTree.directory = f1;
		}
		
		
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
   		//	this.stage.window.addEventListener(flash.events.Event.CLOSING, closeMe );
			dockedMenuBar.addEventListener(MenuEvent.ITEM_CLICK, itemClickInfo);
			loadXMLfiles();
			
		}
		public function setProject(proj:Object):void {
			project = proj;
		}
		
		public function getKeys():ArrayCollection {
			var t1:ArrayCollection = new ArrayCollection();
			for (var i:int = 0;i<keys.length;i++) {
				t1.addItem({name:keys[i].toString()});
			}
			return t1;
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
           	 else if (item.@icon == "server") {
           	 	return server;
           	 }
           	 else if (item.@icon == "client") {
           	 	return client;
           	 }
           	 return null;
           }
		public function getProject():Object {
			return project;
		}
		/***************************** new project loaded reset everything ****************/
	
		public function setProjectXML(proj:XML):void {
			project_xml = proj;
			
			project = new Project(project_xml);
			
			//Append list of server designs and list of server implementations
			serverDesign = new Server();
			serverInstance = new ServerInstance(); 
			
			
			
		//	var childNodes:XMLList =project_xml.children();
			
			var xmlNodeDesign:XML = project_xml.elements("CONFIG")[0];
			var xmlNodeInstance:XML = project_xml.elements("serverInstance")[0];
			
			serverDesign.setXML(xmlNodeDesign);
			serverInstance.serverDesign = serverDesign;
			serverInstance.setXML(xmlNodeInstance);
						
			refreshTheTree();
			keys = serverDesign.getKeys();
			
						
		}
		
		public function renderCTTree():void {
			
		}
		public function renderTree():void {
			/* if(refreshData){
                    // Refresh all rows on next update.
                    projectTree.invalidateList();
                    refreshData = false;
                    projectTree.openItems = current_tree_openItems;
                    // Validate and update the properties and layout
                    // of this object and redraw it, if necessary.
                    projectTree.validateNow();
                }
*/

		}
		public function refreshTheTree():void {
			if (projectTree) { current_tree_openItems = projectTree.openItems};
			
			refreshData = true;
			
			controlTree_xml = null;
			controlTree_xml =new MyTreeNode();
			controlTree_xml.make(0,"server",serverInstance);
			controlTree_xml.appendChild(serverInstance.toTree());
			controlTree_xml.object = serverInstance;
			if (ctTree) {ctTree.expandChildrenOf(ct.elements("server")[0],true)};
			
			designTree_xml = null;
			designTree_xml =new MyTreeNode();
			designTree_xml.make(0,"design",this);
			designTree_xml.appendChild(serverDesign.toTree());
			designTree_xml.object = this;
			//trace("After Server:" + designTree_xml.getXML().toString());
			var clients:Array = serverDesign.getClients();
			
			for (var client:int = 0; client < clients.length; client++) {
				designTree_xml.appendChild(clients[client].toTree());
			}
			
			keys = serverDesign.getKeys();
			
			var clientList:Array = serverDesign.getClients();
			usedKeys = null;
			usedKeys = new Array();
			
			for (var client2:int=0 ; client2 < clientList.length ; client2++) {
			
				usedKeys = usedKeys.concat(clientList[client2].getUsedKeys());
			}
						
			workFlow.serverList.removeAll();
			workFlow.clientList.removeAll();
			workFlow.createWorkflow(designTree_xml);
			if (projectTree) {
				var cOpen:Array = projectTree.openItems;
				//projectTree.invalidateList();
				dtTemp = designTree_xml.getXML();
				var t1:XMLListCollection = new XMLListCollection(new XMLList(dtTemp));
				
				dt.removeAll();
				dt.refresh();
				for (var its in t1) {
					dt.addItem(t1[its]);
				}
				projectTree.dataProvider = dt;
				projectTree.validateNow();
				
				for (it in cOpen) {
					var n:XML = cOpen[it];
					var key:String = n.@key;
					var ob:Object = designTree_xml.fixOpenItems(projectTree, dt[0], key);
					projectTree.expandItem(ob,true);
				}
			}			
		}


				
		public function fixDTXML():void {
			//dt.removeAll();
			//for (var i:int=0;i<dtTemp.length;i++) {
		
			//designTree_xml.walkTree(projectTree,dtTemp,dt,true);
			value = "test";
			var icon:String = "error";
			key = "test";
			dt.setChildren(dtTemp);
			//dt.children()[0].node[0].appendChild(new XML("<node name=\"test\" icon = \"err\" key=\"test\" />"));  
				//dt.addItem(dtTemp[1]);
			//}
			
		}
		
		public function isValidIP(ip:String):Boolean  {
			var isValid:Boolean = true;
			var ip_arr:Array = ip.split(".");
			if (ip_arr.length != 4) {
				isValid = false;
			} else {
				for (var i:int = 0; i < 4; i++) {
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
			for (var key:int in usedKeys) {
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
		
		public function loadXMLfiles():void {
			
			var fileLoader:XMLFile = new XMLFile();
			overrides_xml = fileLoader.getXMLFile("data/overrides.xml");
			parameters_xml = fileLoader.getXMLFile("data/parameters.xml");	    
			default_client_xml = fileLoader.getXMLFile("defaults/default_client.xml");	    
		  	default_Server_xml = fileLoader.getXMLFile("defaults/default_server.xml");	    
		    controlTypeAttributes_xml = fileLoader.getXMLFile("data/controlTypeAttributes.xml");	    
			comfort_xml = fileLoader.getXMLFile("defaults/default_comfort.xml");	    
		    
			eLifeAdmin_xml = fileLoader.getXMLFile("data/elifeAdmin.xml");
			vDivBoxWidth = eLifeAdmin_xml.settings[0].@vDivBoxWidth;
			hDivBoxHeight = eLifeAdmin_xml.settings[1].@hDivBoxHeight;
			advancedOn = Boolean(eLifeAdmin_xml.settings[2].@advanced);
			trace("Completed xml loads");
		}
		
		public function dividerResize_event(event:DividerEvent):void {
			var fileSaver:XMLFile = new XMLFile();
			eLifeAdmin_xml.settings[0].@vDivBoxWidth = vDivBox.width.toString();
			eLifeAdmin_xml.settings[1].@hDivBoxHeight = can1.height.toString();
			eLifeAdmin_xml.settings[2].@advanced = advancedOn.toString();
			fileSaver.saveXMLFile("data/elifeAdmin.xml", eLifeAdmin_xml.toString());
		}
		
		public function dividerSave():void {
			try {
				var fileSaver:XMLFile = new XMLFile();
				eLifeAdmin_xml.settings[0].@vDivBoxWidth = vDivBox.width.toString();
				eLifeAdmin_xml.settings[1].@hDivBoxHeight = can1.height.toString();
				eLifeAdmin_xml.settings[2].@advanced = advancedOn.toString();
				fileSaver.saveXMLFile("data/elifeAdmin.xml", eLifeAdmin_xml.toString());
			}
			catch (error:TypeError) {
				
				//just exit
			}
		}
	
				
		public function openProject(project:String):void { 	
		 //= fileLoader.getXMLFile("projects/" + project + ".elp");	    
		   // loader.addEventListener("onInit", loadDefaultComfort);
		  //  loader.addEventListener("onInit", continueOpenProject); 
		}	
		public function continueOpenProject(event:Event):void {
			//setProjectXML(loader.data);
		    currentState = "projectOpen";
			buttonBar.selectedIndex = "1";
		}	
		public function setProjectWithXML(file:XML):void {
			setProjectXML(file);
		    currentState = "projectOpen";
			buttonBar.selectedIndex = "1";
        
            
          //  trace ("Designtree xml:"+ designTree_xml.getXML());
          	dtTemp = designTree_xml.getXML();
          	dt = new XMLListCollection(new XMLList(dtTemp));
			projectTree.dataProvider = dt;
			projectTree.validateNow();
		
			try {
				ctTemp = controlTree_xml.getXML();
				ct = new XMLListCollection(new XMLList(ctTemp));
				ctTree.dataProvider = ct;
				ctTree.validateNow();
				ctTree.expandItem(ct.elements("server")[0],true);
			} catch (ex:TypeError) {
				trace("ctTree not initialized yet");
			}
			
			
			
		}	
		/*************************************************************************************/
		//     COntrol Tree code
		
		public function changeCTTreeEvt(event:flash.events.MouseEvent):void {
			if (event.currentTarget.selectedItem != null) {  
				var nodes:XML =  new XML(event.currentTarget.selectedItem);
	            var key:String = event.currentTarget.selectedItem.@key;
	            currentCTObj = new ObjectProxy(serverInstance.treeNode.getObjectinTree(key));
	            handleCTNavigation(nodes);
	        }
           
        }
		private function handleCTNavigation(nodes:XML):void {
			controlBody.removeAllChildren();
			var firstNode:XML = nodes[0];
			var name:String = firstNode.@name;
			if (firstNode.@icon=="server") {
				
				controlBody.addChild(DisplayObject(serverViewObj));
			} else {
				controlBody.addChild(DisplayObject(clientViewObj));
			//	clientViewObj.clientControls.clientName = name;
			}
        	
        }
		
		
		
		/*********************************************************************************/
		//List and Tree events
		
		public function changeEvt(event:flash.events.Event):void {
                TextDescription.htmlText=event.currentTarget.selectedItem.description;
                currentObj = new ObjectProxy(workFlow.getObject(event.currentTarget.selectedItem.key));
                doErrorDesc(currentObj);
               	handleNavigation(currentObj);
        }

		public function changeTreeEvt(event:flash.events.MouseEvent):void {
			if (event.currentTarget.selectedItem != null) {   
	            var key:String = event.currentTarget.selectedItem.@key;
	            TextDescription.htmlText = workFlow.getDescription(key);
	            currentObj = new ObjectProxy(workFlow.getObject(key));
	            doErrorDesc(currentObj);
	            handleNavigation(currentObj);
	        }
           
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
        	trace("num child="+main.getChildren().length.toString());
        	for (var rdo:int=main.getChildren().length-1;rdo>0;rdo--) {
        		trace("child="+main.getChildAt(rdo).name);
        		var myDo:DisplayObject = main.getChildAt(rdo);
        		if (myDo.name == "body2")
        		{
        		 	main.removeChildAt(rdo);
        		}
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
        				//main body page
        				bodyInstance = new ac[0]();
        				bodyInstance.dataHolder = CurrentObject;
        				body.label = obj.getName();  
        				body.addChild(bodyInstance);
        				
        				//other tab pages, if they exist
        				var tabName:ArrayCollection = obj.getOtherNames();
        				for (var i:int=1;i<ac.length;i++) {
        					var tabn:tabPanel = new tabPanel();
		        			tabn.label = tabName[i];
		        			var tabnContent:Object = new ac[i]();
		        			tabnContent.dataHolder = obj;
		        			tabn.addChild(DisplayObject(tabnContent));
		        			main.addChildAt(DisplayObject(tabn), 1);
        				}
        			}
        			else {
						bodyInstance = new ac();
        				bodyInstance.dataHolder = CurrentObject;
        				body.label = obj.getName();  
        				body.addChild(bodyInstance);
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
			      trace("New project");
			      currentState = "projectDetails";
			      buttonBar.selectedIndex = "0";
			      //initiailize();
			      menuXML = menuXMLOpenProject;
			      selectPath_event(new Event("CLICK", false, false));
			      
			      break;
			    case "Open Project":
			      	trace("Open project");
			      	
			     // var pop1:IFlexDisplayObject = PopUpManager.createPopUp(this, ProjectDialog,true);
					//var file:LoadMyFile = new LoadMyFile()
					var fileOpenPanel:FileOpenPanel = new FileOpenPanel();
					
					if (projectFileName) 
					{
					    fileOpenPanel = FileOpenPanel.show(projectFileName.parent);
					}
					else
					{		
						var f3Str:String = File.applicationResourceDirectory.nativePath + File.separator+"projects";			
						var f3:File = File.applicationResourceDirectory.resolvePath(f3Str);
					    fileOpenPanel = FileOpenPanel.show(f3);
					}
					fileOpenPanel.addEventListener(Event.SELECT, fileOpenSelected);
			     	fileOpenPanel.addEventListener(Event.CANCEL, fileOpenSelectedCancelled);
			     	menuXML = menuXMLOpenProject;
			      break;
			    case "Save Project":
			      trace("Save pro");
			      if (projectFileName) 
					{
					    saveFile("Project");
					}
					else
					{		
						var f1Str:String = File.applicationResourceDirectory.nativePath + File.separator+"projects"+File.separator+project.name;			
						var f1:File = File.applicationResourceDirectory.resolvePath(f1Str);
					    fileSavePanel = FileSavePanel.show(f1, project.name+".elp");
					    fileSavePanel.addEventListener(FileEvent.SELECT, fileSaveSelected);
				     	fileSavePanel.addEventListener(Event.CANCEL, fileSaveSelectedCancelled);
				     	menuXML = menuXMLOpenProject;
					} 
					
			      break;
			    case "Save Project As..":
			      trace("save pro as");
			      if (projectFileName) 
					{
					    fileSavePanel = FileSavePanel.show(projectFileName.parent, projectFileName.name);
					}
					else
					{		
						var f2Str:String = File.applicationResourceDirectory.nativePath + File.separator+"projects"+File.separator+project.name;			
						var f2:File = File.applicationResourceDirectory.resolvePath(f2Str);
					    fileSavePanel = FileSavePanel.show(f2, project.name+".elp");
					}
					fileSavePanel.addEventListener(FileEvent.SELECT, fileSaveSelected);
			     	fileSavePanel.addEventListener(Event.CANCEL, fileSaveSelectedCancelled);
			     	menuXML = menuXMLOpenProject;
			      break;
			    case "Exit":
			      currentState = "";
			      this.close();
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
        
        private function closeMe( event:Event ):void
		{
			dividerSave();
		}

		private function selectPath_event(event:Event): void {
			var dir:File = new File();
			dir.nativePath = File.applicationResourceDirectory.nativePath + File.separator+"projects";
			var selectDir:FileCreateDirPanel = FileCreateDirPanel.show(dir, null);	
			
			selectDir.addEventListener(Event.SELECT, dirCreateSelected);
			selectDir.addEventListener(Event.CANCEL, dirCreateSelectedCancelled);
			     	
			
		}
		private function fileSaveSelected(event:Event):void 
        {
        	currentState = "projectOpen";
        	buttonBar.selectedIndex = "1";
            projectFileName = event.file;
            if (projectFileStream != null)	
			{
				projectFileStream.close();
			}
			projectFileStream = new FileStream();
            projectFileStream.open(projectFileName, FileMode.WRITE);
            var str:String = projectFileStream.writeUTFBytes(projectFileStream.bytesAvailable);
            //var lineEndPattern:RegExp = new RegExp(File.lineEnding, "g");
            //str = str.replace(lineEndPattern, "\n");
            setProjectXML(XML(str)); 
            projectFileStream.close();
            
        }
        
        private function fileSaveSelectedCancelled(event:Event):void 
        {
        	projectFileStream.close();
        }
        
        private function dirCreateSelected(event:Event):void 
        {
        	createNewProject(event.file.name, event.file.nativePath);
        }
        
        private function enableProjectFields(value:Boolean):void {
        	projectPath.editable = false;
        	projectName.editable = false;
        	selectPath.enabled = false;
        	jobNumber.editable=value;
			clientName.editable=value;
			propertyAddress.editable=value;
			integrator.editable=value;
			company.editable=value;
			address.editable=value;
			phone.editable=value;
			fax.editable=value;
			mobile.editable=value;
			email.editable = value;
			notes.editable = value;
        }
        
        private function dirCreateSelectedCancelled(event:Event):void 
        {
        	// do not enable
        	Alert.show("You must set the project folder to start a new project","Please set the folder");
        }

		private function fileOpenSelected(event:Event):void 
        {		
        	currentState = "projectDetails";
        	buttonBar.selectedIndex = "1";
            projectFileName = event.file;
            
            if (projectFileStream != null)	
			{
				projectFileStream.close();
			}
			projectFileStream = new FileStream();
            projectFileStream.open(projectFileName, FileMode.READ);
            var str:String = projectFileStream.readUTFBytes(projectFileStream.bytesAvailable);
            //var lineEndPattern:RegExp = new RegExp(File.lineEnding, "g");
            //str = str.replace(lineEndPattern, "\n");
            setProjectWithXML(XML(str)); 
            projectFileStream.close();
            enableProjectFields(true);
            currentState = "projectOpen";
            advLabel();
        }
        
        private function fileOpenSelectedCancelled(event:Event):void 
        {
        	projectFileStream.close();
        }
       
        /**
        * Handles I/O errors that may come about when opening the currentFile.
        */
        private function readIOErrorHandler(event:Event):void 
        {
            Alert.show("The specified currentFile cannot be opened.", "Error", Alert.OK, this);
        }
        
        private function fixProjectBindings():void {
        	 project.path = projectPath.text;
        	 project.job = jobNumber.text;
        	 project.client_name = clientName.text;
        	 project.client_address = propertyAddress.text;
        	 project.integrator = integrator.text;
        	 project.company = company.text;
        	 project.company_address = address.text;
        	 project.phone = phone.text;
        	 project.fax = fax.text;
        	 project.mobile = mobile.text;
        	 project.email = email.text;
        	 project.notes = notes.text;
        }
        
        private function createNewProject(name:String, dir:String):void {
        	var file:File = new File();
        	file.nativePath = File.applicationResourceDirectory.nativePath + File.separator+"defaults"+File.separator+"default_project.elp";	
        	
			var fileStream:FileStream = new FileStream();
            fileStream.open(file, FileMode.READ);
            fileStream.position = 0;
            var defProject:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
            fileStream.close();
            
            setProjectWithXML(XML(defProject)); 
                        
            project.path = dir.replace(name, ""); 
            projectPath.text = dir.replace(name, "");
            
            project.project = name.replace(projectPath.text, "");
            projectName.text = name.replace(projectPath.text, "");
            
            enableProjectFields(true);         
                    
            projectFileName = new File();
            projectFileName.nativePath = dir;
            
            setPath(projectFileName);
            
            var newProjectXML:XML = project.toXML();
			newProjectXML.appendChild(serverDesign.toProject());
			newProjectXML.appendChild(serverInstance.toXML());
		
			var fileSave:XMLFile = new XMLFile();
			fileSave.saveProjectFile(projectFileName, newProjectXML.toString());
			
			unSaved = false;
            
            currentState = "projectOpen";
        	buttonBar.selectedIndex = "1";
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
			      currentState = "server";
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
        
        public function setPath(dir:File):void  {
			var f3Str:String = dir.nativePath.replace(dir.name, ""); 
			var f3:File = new File();
			f3.nativePath = f3Str;
		
			f3.nativePath =f3Str + File.separator+"server";	
			if (!f3.exists) {
				f3.createDirectory();
				f3.nativePath =f3Str + File.separator+"server"+File.separator+"config";	
				f3.createDirectory();
				f3.nativePath =f3Str + File.separator+"server"+File.separator+"datafiles";	
				f3.createDirectory();
				f3.nativePath =f3Str + File.separator+"server"+File.separator+"script";	
				f3.createDirectory();
			}
					
			f3.nativePath =f3Str + File.separator+"client";	
			if (!f3.exists) {	
				f3.createDirectory();
				f3.nativePath =f3Str + File.separator+"client"+File.separator+"lib";	
				f3.createDirectory();
				f3.nativePath =f3Str + File.separator+"client"+File.separator+"lib"+File.separator+"icons";	
				f3.createDirectory();
				f3.nativePath =f3Str + File.separator+"client"+File.separator+"lib"+File.separator+"maps";	
				f3.createDirectory();
				f3.nativePath =f3Str + File.separator+"client"+File.separator+"lib"+File.separator+"backgrounds";	
				f3.createDirectory();
				f3.nativePath =f3Str + File.separator+"client"+File.separator+"lib"+File.separator+"sounds";	
				f3.createDirectory();
				f3.nativePath =f3Str + File.separator+"client"+File.separator+"lib"+File.separator+"objects";	
				f3.createDirectory();
			}
			unsaved = true;
		
		}
		
	    public function saveFile(saveType:String):void  {
		if (saveType == "createProject") {
			setPath();
			return;
		}
		
		if (projectFileName.exists) {
			var newProjectXML:XML = project.toXML();
			newProjectXML.appendChild(serverDesign.toProject());
			newProjectXML.appendChild(serverInstance.toXML());
		
			var fileSave:XMLFile = new XMLFile();
			fileSave.saveProjectFile(projectFileName, newProjectXML.toString());
			
			unSaved = false;
		} else {
			Alert.show("You must first enter the ProjectName on the details screen","Missing ProjectName");
		 
		}
	    }
		 public function writeXMLFile(inNode:XML, depth:Number):String  {
			var tempString:String = "";
			if (inNode.h.nodeType == 3) {
				tempString += inNode.toString();
				return tempString;
			}
			for (index = 0; index < depth; index++) {
				tempString += "\t";
			}
			tempString += "<";
			tempString += inNode.nodeName;
			for (attribute in inNode.attributes) {
				var tempAtt:String = inNode.attributes[attribute];
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
					for (var child:int = 0; child < inNode.childNodes.length; child++) {
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
        public function advancedClick(event:Event):void {
        	advancedOn = !advancedOn;
        	refreshTheTree();
        	try {
	        	if (advancedOn == true) {
	        		advanced.label = "To Basic   ";
	        		bodyInstance.advanced(true);
	        	}
	        	else {
	        		advanced.label = "To Advanced";
	        		bodyInstance.advanced(false);
	        	}
        	} catch (except:Error)
        	{
        		trace("Advanced bodyInstnace - Not yet implemented " + except.message);
        	}
        	
       	
        //	srv.url="http://localhost:8182/guard"
        //	srv.useProxy = true;
        //	srv.destination = "c:"+File.separator+"";
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

	