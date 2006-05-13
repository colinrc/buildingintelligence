/*
 * Created on Jul 6, 2004
 *
 * Author : Colin Canfield
 */
package au.com.BI.Audio;

import java.util.HashMap;

import au.com.BI.Util.*;

public class AudioModel extends BaseModel {
	protected HashMap inputs;
	protected HashMap functions;
	
	public void finishedReadingConfig () throws SetupException {
		super.finishedReadingConfig();
		
		String inputsDef = (String)this.getParameter("INPUTS",DeviceModel.MAIN_DEVICE_GROUP);
		String functionsDef = (String)this.getParameter("FUNCTIONS",DeviceModel.MAIN_DEVICE_GROUP);
		if (inputsDef == null || inputsDef.equals ("")) {
			throw new SetupException ("The source input catalogue was not specified in the audio device Parameter block");
		}
		if (functionsDef == null || functionsDef.equals ("")) {
			throw new SetupException ("The input function catalogue was not specified in the audio device Parameter block");
		}
		inputs = (HashMap)this.getCatalogueDef(inputsDef);
		functions = (HashMap)this.getCatalogueDef(functionsDef);
		if (inputs == null) {
			throw new SetupException ("The Source input catgalogue was not specifed in the audio device Parameter block");
		}
		if (functionsDef == null) {
			throw new SetupException ("A Function catgalogue was not specifed in the audio device Parameter block");
		}	
	}
	
	public void clearItems () {
		inputs.clear();
		functions.clear();
		super.clearItems();
	}
}
