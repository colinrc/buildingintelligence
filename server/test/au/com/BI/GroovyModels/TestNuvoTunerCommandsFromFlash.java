package au.com.BI.GroovyModels;

import java.util.HashMap;
import java.util.Vector;
import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Config.ParameterException;
import au.com.BI.Device.DeviceType;

import au.com.BI.AV.AVCommand;
import au.com.BI.Audio.*;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Nuvo.Model;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.GroovyModelTestCase;
import au.com.BI.Util.MessageDirection;
import au.com.BI.Util.Utility;
import junit.framework.*;
import junitx.framework.ListAssert;

public class TestNuvoTunerCommandsFromFlash extends GroovyModelTestCase {

	Audio loungeAir = null;
	Audio kitchenAir = null;
	
	public static void main(String[] args) {
	}
	
	public  String getModelToTest() {
		return "NUVO_TUNER";
	}

	protected void setUp() throws Exception {
		super.setUp();
			
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

	protected void tearDown() throws Exception {
		super.tearDown();
	}


	public void testBuildAudioZoneOn() {
		ClientCommand testCommand = new ClientCommand("LOUNGE_AIR","off",null,"","","","","");
		String expectedOut = "*T'A'OFF";
		ReturnWrapper val = new ReturnWrapper();
		try {
			model.buildAudioControlString(loungeAir, testCommand,val);
			Assert.assertEquals ("Return value for audio on failed",expectedOut,val.getCommOutputStrings().firstElement());
		} catch (Exception ex){
			fail ("Exception in call  : " + ex.getMessage());
		}
	}
	
}
