import au.com.BI.Script.*
import au.com.BI.Command.*

//public class dlt_zeljko extends BIScript  {
 public class dlt_zeljko implements BIScript  {

   // true if the script can be run multiple times in parallel
    boolean ableToRunMultiple = false
    
    // List the variables that will cause the script to run when they change
    String[]  fireOnChange =   ["SHOWROOM_AUDIO","AUDIO_1", "AUDIO_2","AUDIO_3","AUDIO_4"]
    
    // If the script is able to be stopped before completion, generally no
    boolean  stoppable = false;
 
    // Include these lines as they are in every script
	def elife  = "${elife}"
	def   triggeringEvent = "${triggeringEvent}"
	def  cache = "${cache}"
	def labelMgr = "{labelMgr}"
	
	
    def setLabelDVD () {
		elife.sendCommand("AUDIO_2","label","AUDIORADIO")
		elife.sendCommand("AUDIO_3","label","DVDPLAY")
		elife.sendCommand("AUDIO_4","label","DVDSTOP")
    }
    
    def setLabelRADIO () {
		elife.sendCommand("AUDIO_2","label","AUDIOKISS")
		elife.sendcommand("AUDIO_3","label","RADIONEXT")
		elife.sendcommand("AUDIO_4","label","RADIOPREV")
    }
    
    def setLabelKISS () {
		elife.sendCommand("AUDIO_2","label","AUDIOTV")
		elife.sendcommand("AUDIO_3","label","KISSNEXT")
		elife.sendcommand("AUDIO_4","label","KISSPREV")
    }
    
    def setLabelTV () {
		elife.sendCommand("AUDIO_2","label","AUDIODVD")
		elife.sendcommand("AUDIO_3","label","TVUP")
		elife.sendcommand("AUDIO_4","label","TVDN")
    }
    
   def main (String[] argv){
	// def run () {
	//	super.run()
	// The action contents of the script go here
	
		if (triggeringEvent  == null || triggeringEvent.getExtra5Info() == "SCRIPT" || triggeringEvent.getCommandCode() == "label" ) {
			return
			// Just in case the script was run from the Flash control plan, rather than picking up a message change.
		}
		
		// to read something from the label manager in groovy
		def currentLabel = labelMgr.getLabelState (triggeringEvent.getDisplayName ())
		
		switch (triggeringEvent.getDisplayName ()) {
		case "AUDIO_1": 
			switch (triggeringEvent.getCommandCode()) {
			case "on":
				elife.sendCommand ("SHOWROOM_AUDIO","on","","","","","SCRIPT")
				elife.sendCommand("SHOWROOM_AUDIO","volume",triggeringEvent.getExtraInfo(),"","","","SCRIPT")
				elife.log( "EXTRA is " + triggeringEvent.getExtraInfo())
			break
			
			case "off":
				elife.sendCommand ("SHOWROOM_AUDIO","off","","","","","SCRIPT")
			break
			}
				
		break
				
		case "AUDIO_2":
			elife.log( "Got to AUDIO_2 before off check")
			if (triggeringEvent.getCommandCode() == "off") {
				return
			}
			elife.log( "Got to AUDIO_2 after off check")
			switch (currentLabel){
			case "": 
				// The currently displayed text on the DLT is not known to eLife, so set it to something we can handle
				elife.sendCommand("AUDIO_2","label","AUDIODVD")
				break
				
			case "AUDIODVD":
				elife.sendCommand( "SHOWROOM_AUDIO","src","dvd","","","","SCRIPT")
				elife.log( "Got to DVD Send Command")
				setLabelDVD()
				break
				
			case "AUDIORADIO":
				elife.sendCommand("SHOWROOM_AUDIO","src","radio","","",""."SCRIPT")
				setLabelRADIO()
				break
				
			case "AUDIOKISS":
				elife.sendCommand( "SHOWROOM_AUDIO","src","kiss","","","","SCRIPT")
				setLabelKISS()
				break

			case "AUDIOTV":
				elife.sendCommand( "SHOWROOM_AUDIO","src","tv","","",""."SCRIPT")
				setLabelTV()
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
			
			switch (triggeringEvent.getCommandCode()){
			case "on":
				elife.sendCommand("AUDIO_1","on",triggeringEvent.getExtraInfo())
				break
				
			case "off":
				elife.sendCommand("AUDIO_1","off")
				break
				
			case "src":
				switch (triggeringEvent.getExtraInfo()){
		
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
}
