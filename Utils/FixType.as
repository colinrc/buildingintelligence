package Utils
{
	import Objects.Server.Pelco;
	import Objects.Server.Oregon;
	import Objects.Server.IR_Learner;
	import Objects.Server.Tutondo;
	import Objects.Server.Kramer;
	import Objects.Server.Hal;
	import Objects.Server.CBus;
	import Objects.Server.Nuvo;
	import Objects.Server.SignVideo;
	import Objects.Server.Dynalite;
	import Objects.Server.DMX;
	import Objects.Server.GC100;
	import Objects.Server.Raw_Connection;
	import Objects.Server.M1;
	import Objects.Server.Comfort;
	import Objects.Server.CustomConnect;
	import Objects.Server.Jandy;
	import Objects.MyTreeNode;
	
	dynamic public class FixType
	{
		static public function fix(oldDevices:Object):Array {
			var devices:Array = new Array();
			
			for (var device in oldDevices) {
				
				switch (oldDevices[device].device_type) {
				case "PELCO" :
					var newPelco:Pelco = new Pelco();
					newPelco = Pelco(oldDevices[device]);
					devices.push(newPelco);
					break;
				case "OREGON" :
					var newOregon:Oregon = new Oregon();
					newOregon = Oregon(oldDevices[device]);
					devices.push(newOregon);
					break;
				case "IR_LEARNER" :
					var newIR:IR_Learner = IR_Learner(oldDevices[device]);
					devices.push(newIR);
					break;
				case "TUTONDO" :
					var newTutondo:Tutondo = Tutondo(oldDevices[device]);				
					devices.push(newTutondo);
					break;
				case "KRAMER" :
					var newKramer:Kramer = Kramer(oldDevices[device]);		
					devices.push(newKramer);
					break;
				case "HAL" :
					var newHal:Hal =  Hal(oldDevices[device]);		
					devices.push(newHal);
					break;
				case "CBUS" :
					var newCBus:CBus = new CBus();
					newCBus.active = oldDevices[device].active;
					newCBus.catalogues = oldDevices[device].catalogues;
					newCBus.description = oldDevices[device].description;
					newCBus.device_type = oldDevices[device].device_type;
					newCBus.id = oldDevices[device].id;
					newCBus.parameters = oldDevices[device].parameters;
					var tTree:MyTreeNode = new MyTreeNode(1,null,null);
					tTree.childObject = oldDevices[device].treeNode.childObject as Array;
					tTree.myXML = oldDevices[device].treeNode.myXML as XML;
					tTree.object = oldDevices[device].treeNode.object as Object;
					newCBus.treeNode = tTree;
					newCBus.usedIcons = oldDevices[device].usedIcons; 
					//var newCBus = oldDevices[device] as CBus;
					devices.push(newCBus);
					break;
				case "NUVO" :
					var newNuvo:Nuvo =  Nuvo(oldDevices[device]);	
					devices.push(newNuvo);
					break;
				case "SIGN_VIDEO" :
					var newSignVideo:SignVideo = SignVideo(oldDevices[device]);
					devices.push(newSignVideo);
					break;
				case "DYNALITE" :
					var newDynalite:Dynalite = Dynalite(oldDevices[device]);
					devices.push(newDynalite);
					break;
				case "DMX" :
					var newDMX:DMX = DMX(oldDevices[device]);
					devices.push(newDMX);
					break;
				case "GC100" :
					var newGC100:GC100 = GC100(oldDevices[device]);
					devices.push(newGC100);
					break;
				case "RAW_CONNECTION" :
					var newRaw:Raw_Connection = Raw_Connection(oldDevices[device]);
					devices.push(newRaw);
					break;
				case "M1" :
					var newM1:M1 = M1(oldDevices[device]);
					devices.push(newM1);
					break;
				case "COMFORT" :
					var newComfort:Comfort = Comfort(oldDevices[device]);
					devices.push(newComfort);
					break;
				case "CUSTOM_CONNECT":
					var newCustomConnect:CustomConnect = CustomConnect(oldDevices[device]);
					devices.push(newCustomConnect);
					break;
				case "JANDI":
					var newJandy:Jandy = Jandy(oldDevices[device]);
					devices.push(newJandy);
					break;
				}
			}
			return devices;
		}
	}
}