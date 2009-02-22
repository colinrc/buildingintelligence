package au.com.BI.GroovyModels;

import java.util.HashMap;
import java.util.Vector;

import au.com.BI.Command.CommsProcessException;
import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Sensors.*;
import au.com.BI.Util.GroovyModelTestCase;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;
import junitx.framework.ListAssert;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;

public class TestJandyCommandsToFlash extends GroovyModelTestCase {

	Sensor airTemp = null;
	Sensor kitchenAir = null;
	
	public  String getModelToTest() {
		return "JANDY";
	}

	
	protected void setUp() throws Exception {
		super.setUp();

		// Below this line is the setting up the devices that will be used for testing. 
		// In the real running system these are set up from the config file.
		  
		
		airTemp = new Sensor ("Air Temp","","",DeviceType.SENSOR);
		airTemp.setKey("AIRTEMP");
		airTemp.setOutputKey("AIRTEMP");

		kitchenAir = new Sensor ("Kitchen Air","","",DeviceType.SENSOR);
		kitchenAir.setKey("B");
		kitchenAir.setOutputKey("KITCHEN_AIR");

		model.addControlledItem(airTemp.getKey(),airTemp,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(kitchenAir.getKey(),kitchenAir,MessageDirection.FROM_HARDWARE);
		
		model.addControlledItem("AIRTEMP",airTemp,MessageDirection.FROM_FLASH);
		model.addControlledItem("KITCHEN_AIR",kitchenAir,MessageDirection.FROM_FLASH);
		
		HashMap<String, String> map = new HashMap<String,String> (40);
		
		map.put("cd1", "1");
		map.put("cd2", "2");
		map.put("digital","3");
		map.put("tv", "4");
		
		model.setCatalogueDefs("Nuvo Audio Inputs",map);
		
		model.setParameter("AUDIO_INPUTS", "Nuvo Audio Inputs", DeviceModel.MAIN_DEVICE_GROUP);

		model.setPadding (2); // device requires 2 character keys that are 0 padded.
	}

	public void testInterpretOff() {
		

		String testString = "#T'A'OFF";
		
		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();
		
		SensorCommand testCommand = new SensorCommand("CLIENT_SEND","off",null,"");
		testCommand.setDisplayName("AIR_TEMP");
		expectedOut.add(testCommand);

		/*
		AudioCommand testCommand2 = new AudioCommand("CLIENT_SEND","src",null,"cd2");
		testCommand2.setDisplayName("KITCHEN_AIR");
		expectedOut.add(testCommand2);
*/


		ReturnWrapper val = new ReturnWrapper();
		try {
			model.processStringFromComms(testString,val);
		} catch (CommsProcessException e) {
			fail(e.getMessage());
		}
		ListAssert.assertEquals ("Return value for interpret failed",val.getOutputFlash(),expectedOut);
	}
	
	public void testInterpretPreset () {
		

		String testString = "#TÕBÕPRESET02,Ó\"test\"";
		
		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();
		/*
		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","off",null,"");
		testCommand.setDisplayName("AIR_TEMP");
		expectedOut.add(testCommand);
*/
		SensorCommand testCommand2 = new SensorCommand("CLIENT_SEND","on",null,"02");
		testCommand2.setExtra2Info("test");
		testCommand2.setDisplayName("AIR_TEMP");
		expectedOut.add(testCommand2);


		ReturnWrapper val = new ReturnWrapper();
		try {
			model.processStringFromComms(testString,val);
		} catch (CommsProcessException e) {
			fail(e.getMessage());
		}
		ListAssert.assertEquals ("Return value for interpret failed",val.getOutputFlash(),expectedOut);
	}

	
}
