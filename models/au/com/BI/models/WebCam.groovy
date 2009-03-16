package au.com.BI.models;

import au.com.BI.Util.*
import au.com.BI.Command.*
import au.com.BI.GroovyModels.*
import java.util.logging.Level
import au.com.BI.Config.ParameterException
import au.com.BI.Device.UnknownFieldException
import au.com.BI.Device.DeviceType
import au.com.BI.Camera.Camera
import java.util.regex.Matcher
import java.util.regex.Pattern

import  groovyx.net.http.HTTPBuilder
import static groovyx.net.http.Method.GET
import static groovyx.net.http.ContentType.TEXT

/**
 * The following model demonstrates controlling simple HTTP connected webcams.
 * This model differs from normal models in that there is not a centralised controller connected via IP or Serial that controls individual cameras,
 * instead each camera line has it's own IP address which is the KEY for the camera entry in the configuration file.
 */
 
class WebCam extends GroovyModel {


	int keyPadding = 2;
	String name = "WEBCAM"
	String appendToSentStrings = "\r"
	String version = "1.0"
	
		WebCam () {
		super()

		this.setDeviceKeysString(true);
		
		setQueueCommands(false) 
		// Set the default behaviour for comms commands to be queued before sending. Can be overridden for a returnWrapper object
	}
	

	void buildCameraControlString (Camera device, CommandInterface command, ReturnWrapper returnWrapper)  throws ParameterException {
		// receives a message from flash and builds the appropriate string for the audio device
		
		def targetUrl = device.getKey()
		def http = new HTTPBuilder( targetUrl)
		
		try {
			

				http.request(GET,TEXT) {  req ->  
					
					if (command.getCommandCode() ==  "on") {
						logger.log(Level.FINE,"Sending on command to the webcam")						
						url.path = '/'
						// url.query = [ v:'1.0', q: 'Calvin and Hobbes' ] // If a query is to be sent 
					}
					
					response.success = { resp, reader -> 
						logger.log(Level.FINE,"Camera command successfully sent to the webcam")
					}
				  
					response.'401' = { resp ->  // fired only for a 401 (access denied) status code
							returnWrapper.setError(true)
							returnWrapper.setErrorDescription ("Access Denied")
							logger.log(Level.ERROR,"Access denied to web camera " + url)
					}
					
					http.handler.failure = { resp ->
							returnWrapper.setError (true)
							retunWrapper.setErrorDescription ("Web camera URL call failed: ${resp.statusLine}")
							logger.log(Level.ERROR,"Error accessing web camera " + url + " ${resp.statusLine}")
					}

			}
				
		} catch (UnknownFieldException ex){
			logger.log (Level.WARNING,ex.getMessage());
		}
	}

	

	void decodeScene (ReturnWrapper returnWrapper , String sceneNumber){
		
	}
	
}