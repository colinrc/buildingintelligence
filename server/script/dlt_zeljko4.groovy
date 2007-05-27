import au.com.BI.Script.*
import au.com.BI.Command.*

public class dlt_zeljko4 extends BIScript  {

   // All DLT's should be configured to produce an "on" message when pressed normally, and an "off" mesage when held for a long time.
    
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
	
	// String AUDIO_NAME = "SHOWROOM_AUDIO''
	String AUDIO_NAME = "KITCHEN_AV"

	
	// List the variables that will cause the script to run when they change
	String[]  fireOnChange =   [AUDIO_NAME,DLT1, DLT2,DLT3,DLT4,"SCENE_1"]

	// If the script is able to be stopped before completion, generally no
	boolean  stoppable = false;
	
	// If hidden is set to true then the script will not be visible to the client
	boolean hidden = true


	
	// Set the names of the four DLT buttons being used here
	
	def registerScript () {
		// this method is called when the script is first launched
		
		// patterns.addOnOffVolume ("MASTER_BED_LIGHT", "KITCHEN_AV", false)		
			// Item to listen for events from
			// item to send the changed level to
			// run the pattern if the trigger came from a script event Y/N ?

	}
	
	def setLabelDVD () {
		elife.sendCommand(DLT1,"label","AUDIODVD")
		elife.sendCommand(DLT3,"label","DVDPLAY")
		elife.sendCommand(DLT4,"label","DVDSTOP")
	}

	def setLabelRADIO () {
		elife.sendCommand(DLT1,"label","AUDIORADIO")
		elife.sendCommand(DLT3,"label","RADIONEXT")
		elife.sendCommand(DLT4,"label","RADIOPREV")
	}

	def setLabelKISS () {
		elife.sendCommand(DLT1,"label","AUDIOKISS")
		elife.sendCommand(DLT3,"label","KISSNEXT")
		elife.sendCommand(DLT4,"label","KISSPREV")
	}

	def setLabelTV () {
		elife.sendCommand(DLT1,"label","AUDIOTV")
		elife.sendCommand(DLT3,"label","TVUP")
		elife.sendCommand(DLT4,"label","TVDN")
	}
	
	def setLabelOn() {
		elife.sendCommand(DLT1,"label","ON")
		elife.sendCommand(DLT3,"label","BLANK")
		elife.sendCommand(DLT4,"label","BLANK")
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
			


			case DLT1:
			if (triggerCommand == "off") {
				elife.sendCommand (AUDIO_NAME,"off")
				setLabelOn()
				return
			}
			if (triggerCommand == "on") {

				if (elife.isOff(AUDIO_NAME)){
					elife.sendCommand (AUDIO_NAME,"on")
					// it was previously off, so switch the audio on, and label the DLT with the first label of the sequence.
						setLabelDVD()
					
				} else {
					switch (currentLabel){
					
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
					elife.sendCommand(AUDIO_NAME,"mute","off")
				}

			break // DLT3
			
			case DLT4:
				// fourth button is volume down or mute on
				if (triggerCommand == "on"){
					elife.sendCommand(AUDIO_NAME,"volume","down")
				}
				if (triggerCommand == "off"){
					elife.sendCommand(AUDIO_NAME,"mute","on")
				}

			break // DLT4

				}
		}
}
