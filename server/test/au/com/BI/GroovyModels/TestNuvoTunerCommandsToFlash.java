package au.com.BI.GroovyModels;

import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;

import java.util.HashMap;
import java.util.Vector;

import au.com.BI.Command.CommsProcessException;
import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Audio.*;
import au.com.BI.Util.GroovyModelTestCase;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;
import junitx.framework.ListAssert;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;

public class TestNuvoTunerCommandsToFlash extends GroovyModelTestCase {

	Audio loungeAir = null;
	Audio kitchenAir = null;
	
	public  String getModelToTest() {
		return "NUVO_TUNER";
	}

	@Before
	public void setUp() throws Exception {
		super.setUp();

		// Below this line is the setting up the devices that will be used for testing. 
		// In the real running system these are set up from the config file.
		  
		
		loungeAir = new Audio ("Lounge Air",DeviceType.AUDIO);
		loungeAir.setKey("A");
		loungeAir.setOutputKey("LOUNGE_AIR");

		kitchenAir = new Audio ("Kitchen Air",DeviceType.AUDIO);
		kitchenAir.setKey("B");
		kitchenAir.setOutputKey("KITCHEN_AIR");

		model.addControlledItem(loungeAir.getKey(),loungeAir,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(kitchenAir.getKey(),kitchenAir,MessageDirection.FROM_HARDWARE);
		
		model.addControlledItem("LOUNGE_AIR",loungeAir,MessageDirection.FROM_FLASH);
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

	@Test
	public void testInterpretOff() {

		String testString = "#T'A'OFF";
		
		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();
		
		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","off",null,"");
		testCommand.setDisplayName("LOUNGE_AIR");
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
	
	@Test
	public void testInterpretPreset () {

		String testString = "#TÕBÕPRESET02,Ó\"test\"";
		
		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();
/*
		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","off",null,"");
		testCommand.setDisplayName("LOUNGE_AIR");
		expectedOut.add(testCommand);
*/
		AudioCommand testCommand2 = new AudioCommand("CLIENT_SEND","preset",null,"02");
		testCommand2.setExtra2Info("test");
		testCommand2.setDisplayName("KITCHEN_AIR");
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