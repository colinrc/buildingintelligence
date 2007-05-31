import au.com.BI.Script.*
import au.com.BI.Command.*

public class dlt_zeljko4 extends BIScript  {

   /*
      The following behaviour occurs
     
             DLT1        long press    on / off                    short press   cycle input
             DLT2        long press    channel down         short press   channel up
             DLT3        long press    mute off                   short press   volume up
             DLT4        long press    mute on                   short press   volume down
      
      
       All DLTs used by this script must be configured as follows
           Short release -> recall 1
           Long press - > recall 2

           recall level 1 -> set to 100%
           recall level 2 -> set to 0%
           
           
           Ensure the DLTs are configured with RELAY="Y" in the server configuration file.
  */  
  
	// true if the script can be run multiple times in parallel
	boolean ableToRunMultiple = false

	// String DLT1 = "AUDIO_1"
	// String DLT2 = "AUDIO_2"
	// String DLT3 = "AUDIO_3"
	// String DLT4 = "AUDIO_4"
	
    String DLT1 = "DLT5"
	String DLT2 = "DLT6"
	String DLT3 = "DLT7"
	String DLT4 = "DLT8"
	
	// Set this to the name of the audio zone that the script is controlling.
	// String AUDIO_NAME = "SHOWROOM_AUDIO''
	String AUDIO_NAME = "KITCHEN_AV"

	// Volume level 1 is set when the third dlt is pressed for a long time. Volume 2 is set when the fourth DLT is held for a long press
	String VolumeLevel1 = "40"
	String VolumeLevel2 = "50"
	
	/*
	 Ensure the labels.xml file contains the following entries.
             <LABEL KEY="ON" VALUE="on"/>
             <LABEL KEY="OFF" VALUE="off"/>
        
            <LABEL KEY="BLANK" VALUE=" "/>
     
			<LABEL KEY="PLAY/STOP" VALUE="Play/Stop"/>  
		    <LABEL KEY="NEXT/PREV" VALUE="Next/Prev"/>
		    <LABEL KEY="UP/DOWN" VALUE="Up/Down"/>
		    
		    <LABEL KEY="VOLUP" VALUE="Vol up"/>  
		    <LABEL KEY="VOLDN" VALUE="Vol down"/>  
	*/
	
	// List the variables that will cause the script to run when they change
	String[]  fireOnChange =   [AUDIO_NAME,DLT1, DLT2,DLT3,DLT4,"SCENE_1"]

	// If the script is able to be stopped before completion, generally no
	boolean  stoppable = false;
	
	// If hidden is set to true then the script will not be visible to the client
	boolean hidden = true


	
	// Set the names of the four DLT buttons being used here
	
	def registerScript () {
		// this method is called when the script is first launched
	}
	
	def setLabelDVD () {
		elife.sendCommand(DLT1,"label","AUDIODVD")
		elife.sendCommand(DLT2,"label","PLAY/STOP")
	}

	def setLabelRADIO () {
		elife.sendCommand(DLT1,"label","AUDIORADIO")
		elife.sendCommand(DLT2,"label","NEXT/PREV")
	}

	def setLabelKISS () {
		elife.sendCommand(DLT1,"label","AUDIOKISS")
		elife.sendCommand(DLT2,"label","NEXT/PREV")
	}

	def setLabelTV () {
		elife.sendCommand(DLT1,"label","AUDIOTV")
		elife.sendCommand(DLT2,"label","UP/DOWN")
	}
	
	def setLabelOff() {
		elife.sendCommand(DLT1,"label","ON")
		elife.sendCommand(DLT2,"label","BLANK")
		elife.sendCommand(DLT3,"label","BLANK")
		elife.sendCommand(DLT4,"label","BLANK")
	}
	
	def setLabelOn() {
		switch (elife.getSource (AUDIO_NAME)){
			case "radio":
				setLabelRADIO()
			break
	
			case "kiss":
				setLabelKISS()
			break
	
			case "tv":
				setLabelTV()
			break
	
			case "dvd":
				setLabelDVD()
			break

			case "unknown":
				setLabelDVD()
			break
		}
		elife.sendCommand(DLT3,"label","VOLUP")
		elife.sendCommand(DLT4,"label","VOLDN")
	}
	
	def main (String[] argv){

		// The action contents of the script go here

		if (triggeringEvent  == null || triggerWasScript ) {
			return
			// Just in case the script was run from the Flash control plan, rather than picking up a message change.
		}

		// to read something from the label manager in groovy
		def currentLabel = labelMgr.getLabelState (triggerDisplayName)

		switch (triggerDisplayName) {

			case "SCENE_1": 
			switch (triggerCommand) {
				case "on":
					elife.sendCommand ("MACRO","abort","SHOWROOM SCENE OFF")
					elife.sendCommand ("MACRO","run","SHOWROOM SCENE ON")
				break

				case "off":
					elife.sendCommand ("MACRO","abort","SHOWROOM SCENE ON")
					elife.sendCommand ("MACRO","run","SHOWROOM SCENE OFF")
				break
				

			}

			break
			
			case AUDIO_NAME: 
				// The user changed the audio on the device
				
				switch (triggerCommand) {
					case "on":
						setLabelOn();
					break

					case "off":
						setLabelOff();
					break
					
					case "src":
						
						switch (triggerExtra) {
								case "radio":
									setLabelRADIO()
								break
					
								case "kiss":
									setLabelKISS()
								break
					
								case "tv":
									setLabelTV()
								break
					
								case "dvd":
									setLabelDVD()
								break
						}
						break
				}

				break

			case DLT1:
			if (triggerCommand == "off") {
				elife.sendCommand (AUDIO_NAME,"off")
				setLabelOff()
				return
			}
			if (triggerCommand == "on") {

				if (elife.isOff(AUDIO_NAME)){
					elife.sendCommand (AUDIO_NAME,"on")
					// it was previously off, so switch the audio on, and label the DLT with the first label of the sequence.
					setLabelOn()
					
				} else {
					
					switch (currentLabel){
					   // case will always be switched by the previous entry in the cycle
					   
						case "": 
							// The currently displayed text on the DLT is not known to eLife, so set it to something we can handle
						setLabelDVD()
						break
		
						case "AUDIODVD":
						elife.sendCommand( AUDIO_NAME,"src","radio")
						setLabelRADIO()
						break
		
						case "AUDIORADIO":
						elife.sendCommand(AUDIO_NAME,"src","kiss")
						setLabelKISS()
						break
		
						case "AUDIOKISS":
						elife.sendCommand( AUDIO_NAME,"src","tv")
						setLabelTV()
						break
		
						case "AUDIOTV":
						elife.sendCommand( AUDIO_NAME,"src","dvd")
						setLabelDVD()
						break
		
					}
				}
			}
			break // DLT1

			case DLT2 :
				switch (triggerCommand) {
				case "on": 
					
					// second button sends commands depending on source
					// The button should be configured to send an ON for a short press and an OFF for a long press
					switch (currentLabel){
						case "": 
						// The currently displayed text on the DLT is not known to eLife, so set it to something we can handle
						elife.sendCommand(DLT3,"label","UNKNOWN")
						break
		
						case "DVDPLAY":
						elife.sendCommand( "AV.DVDPlayer","DVD.play")
						break
		
						case "TVUP":
						elife.sendCommand( "AV.TV","TV.chanup")
						break
		
						case "RADIONEXT":
						elife.sendCommand( "AV.RADIO","RADIO.next")
						break
		
						case "KISSNEXT":
						elife.sendCommand( "AV.KISS","KISS.next")
						break
					}
				break // on
				
				case "off": 
					switch (currentLabel){
					case "": 
						// The currently displayed text on the DLT is not known to eLife, so set it to something we can handle
						elife.sendCommand(DLT3,"label","UNKNOWN")
						break
	
						case "DVDSTOP":
						elife.sendCommand("AV.DVDPlayer","DVD.stop")
						break
	
						case "TVDN":
						elife.sendCommand( "AV.TV","TV.chandn")
						break
	
						case "RADIOPREV":
						elife.sendCommand( "AV.RADIO","RADIO.prev")
						break
	
						case "KISSPREV":
						elife.sendCommand( "AV.KISS","KISS.prev")
						break
					}
				break // off
				}
				
			break // DLT2
				

			case DLT3 :
			// third button is volume up or mute off
				if (triggerCommand == "on"){
					elife.sendCommand(AUDIO_NAME,"volume","up")
				}
				if (triggerCommand == "off"){
					elife.sendCommand(AUDIO_NAME,"volume",VolumeLevel1)
				}

			break // DLT3
			
			case DLT4:
				// fourth button is volume down or mute on
				if (triggerCommand == "on"){
					elife.sendCommand(AUDIO_NAME,"volume","down")
				}
				if (triggerCommand == "off"){
					elife.sendCommand(AUDIO_NAME,"volume",VolumeLevel2)
				}

			break // DLT4

				}
		}
}
