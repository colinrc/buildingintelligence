import au.com.BI.Script.*
import au.com.BI.Command.*

public class dlt_zeljko4 extends BIScript  {

	// true if the script can be run multiple times in parallel
	boolean ableToRunMultiple = false

	// List the variables that will cause the script to run when they change
	String[]  fireOnChange =   ["SHOWROOM_AUDIO","AUDIO_1", "AUDIO_2","AUDIO_3","AUDIO_4","SCENE_1"]

	// If the script is able to be stopped before completion, generally no
	boolean  stoppable = false;
	
	// If hidden is set to true then the script will not be visible to the client
	boolean hidden = true

	def registerScript () {
		// this method is called when the script is first launched
		
		patterns.addOnOffVolume ("MASTER_BED_LIGHT", "KITCHEN_AV", false)		
			// Item to listen for events from
			// item to send the changed level to
			// run the pattern if the trigger came from a script event Y/N ?

	}
	
	def setLabelDVD () {
		elife.sendCommand("AUDIO_2","label","AUDIODVD")
		elife.sendCommand("AUDIO_3","label","DVDPLAY")
		elife.sendCommand("AUDIO_4","label","DVDSTOP")
	}

	def setLabelRADIO () {
		elife.sendCommand("AUDIO_2","label","AUDIORADIO")
		elife.sendCommand("AUDIO_3","label","RADIONEXT")
		elife.sendCommand("AUDIO_4","label","RADIOPREV")
	}

	def setLabelKISS () {
		elife.sendCommand("AUDIO_2","label","AUDIOKISS")
		elife.sendCommand("AUDIO_3","label","KISSNEXT")
		elife.sendCommand("AUDIO_4","label","KISSPREV")
	}

	def setLabelTV () {
		elife.sendCommand("AUDIO_2","label","AUDIOTV")
		elife.sendCommand("AUDIO_3","label","TVUP")
		elife.sendCommand("AUDIO_4","label","TVDN")
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
			
			case "AUDIO_1": 
			switch (triggerCommand) {
				case "on":
				elife.sendCommand ("SHOWROOM_AUDIO","on")
				elife.sendCommand ("SHOWROOM_AUDIO","volume",triggerExtra)
				break

				case "off":
				elife.sendCommand ("SHOWROOM_AUDIO","off")
				break
			}

			break

			case "AUDIO_2":
			if (triggerCommand == "off") {
				return
			}
			switch (currentLabel){
				case "": 
				// The currently displayed text on the DLT is not known to eLife, so set it to something we can handle
				setLabelDVD()
				break

				case "AUDIODVD":
				elife.sendCommand( "SHOWROOM_AUDIO","src","radio")
				setLabelRADIO()
				break

				case "AUDIORADIO":
				elife.sendCommand("SHOWROOM_AUDIO","src","kiss")
				setLabelKISS()
				break

				case "AUDIOKISS":
				elife.sendCommand( "SHOWROOM_AUDIO","src","tv")
				setLabelTV()
				break

				case "AUDIOTV":
				elife.sendCommand( "SHOWROOM_AUDIO","src","dvd")
				setLabelDVD()
				break

			}
			break

			case "AUDIO_3" :
			// third button sends commands depending on source
			switch (currentLabel){
				case "": 
				// The currently displayed text on the DLT is not known to eLife, so set it to something we can handle
				elife.sendCommand("AUDIO_3","label","UNKNOWN")
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
			break

			case "AUDIO_4" :
			// forth button sends commands depending on source
			switch (currentLabel){
				case "": 
				// The currently displayed text on the DLT is not known to eLife, so set it to something we can handle
				elife.sendCommand("AUDIO_3","label","UNKNOWN")
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
			break

			case "SHOWROOM_AUDIO":

			switch (triggerCommand){
				case "on":
				elife.sendCommand("AUDIO_1","on",triggerExtra)
				break

				case "off":
				elife.sendCommand("AUDIO_1","off")
				break

				case "src":
				switch (triggerExtra){

					case "dvd":
					setLabelDVD()
					break
					case "radio":
					setLabelRADIO()
					break
					case "kiss":
					setLabelKISS()
					break
					case "tv":
					setLabelTV()
					break
				}

				// End of case src
				break
			}
			// end of case SHOWROOM_AUDIO
			break

		}
	}
}
