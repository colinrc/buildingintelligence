import au.com.BI.Script.*
import au.com.BI.Command.*

 public class DoorStrikeNew  implements BIScript  {
 
   // true if the script can be run multiple times in parallel
    boolean ableToRunMultiple = false
    
    // List the variables that will cause the script to run when they change
    String[]  fireOnChange =   ["DLT_1", "DLT_2","DLT_3","DLT_4"]
    
    // If the script is able to be stopped before completion, generally no
    boolean  stoppable = false;
 
    
   // Include these lines as they are in every script
	def elife  = "${elife}"
	def   triggeringEvent = "${triggeringEvent}"
	def  cache = "${cache}"
	def labelMgr = "{labelMgr}"
	
	def main (String[] argv) {
	// The action contents of the script go here
	
		if (triggeringEvent  == null) {
			return
			// Just in case the script was run from the Flash control plan, rather than picking up a message change.
		}
		
		currentLabel = labelMgr.getLabelState (triggeringEvent.getDisplayName ())
		elife.log ("Label " + currentLabel)
		
		switch (triggeringEvent.getDisplayName()) {
			case None:
				

				   // to read something from the label manager in groovy
				   currentLabel = labelMgr.getLabelState (triggeringEvent.getDisplayName ())
				   
				   if (currentLabel == "ON""){
							 // do something
							 elife.sendCommand(""DLT_1","label","OFF")
				   } 
				   
				
				   
// original jython code

if triggeringEvent != None:
	currentLabel = labelMgr.getLabelState (triggeringEvent.getDisplayName ())
	elife.log ("Label " + currentLabel)

	#First button
	
	if triggeringEvent.getDisplayName () == "DLT_1":
		if currentLabel == "ON":
			elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","on","")
			elife.sendCommand("DLT_1","DLT_1","label","OFF")
	
		elif currentLabel == "OFF":
			elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","off","")
			elife.sendCommand("DLT_1","DLT_1","label","ON")
	
  
    # Second button, select source
    
	if triggeringEvent.getDisplayName () == "DLT_2":
		if currentLabel == None:
			# Unknown label
			elife.sendCommand("DLT_2","DLT_2","label","CD1")
			
			
		elif currentLabel == "CD1":
			elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","src","cd1")
			elife.sendCommand("DLT_2","DLT_2","label","CD2")

		elif currentLabel == "CD2":
			elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","src","cd2")
			elife.sendCommand("DLT_2","DLT_2","label","DVD")
			
		elif currentLabel == "DVD":
			elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","src","dvd")
			elife.sendCommand("DLT_2","DLT_2","label","TV")
			
		elif currentLabel == "TV":
			elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","src","tv")
			elife.sendCommand("DLT_2","DLT_2","label","CD1")


    # Third button, volume
    
	if triggeringEvent.getDisplayName () == "DLT_3":
		elife.sendCommand( "KITCHEN_AV","KITCHEN_AV","volume",triggerEvent.getExtraInfo())

