package au.com.BI.GroovyModels;

import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;

import java.util.HashMap;
import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Device.DeviceType;

import au.com.BI.Audio.*;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.GroovyModelTestCase;
import au.com.BI.Util.MessageDirection;
import junit.framework.*;

public class TestNuvoTunerCommandsFromFlash extends GroovyModelTestCase {

	/* The test case requires two audio devices to be configured. 
	 * 
	 * The XML config file equivalent of these is 
	 * 
	 *           <NUVO_TUNER>
	 *              <AUDIO KEY="A" DISPLAY_NAME="LOUNGE_AIR" NAME="Lounge Room tuner" />
	 *				<AUDIO KEY="B" DISPLAY_NAME="KITCHEN_AIR" NAME="Kitchen tuner" />
	 *          </NUVO_TUNER>
	 */

	Audio loungeAir = null;
	Audio kitchenAir = null;

	public  String getModelToTest() {
		return "NUVO_TUNER";
	}

	@Before
	public void setUp() throws Exception {
		super.setUp();

		/* Set the parameters for the two AUDIO devices */
		loungeAir = new Audio ("Lounge Air",DeviceType.AUDIO);
		loungeAir.setKey("A");
		loungeAir.setOutputKey("LOUNGE_AIR");

		kitchenAir = new Audio ("Kitchen Air",DeviceType.AUDIO);
		kitchenAir.setKey("B");
		kitchenAir.setOutputKey("KITCHEN_AIR");

		/* Add the audio devices to the model */
		model.addControlledItem(loungeAir.getKey(),loungeAir,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(kitchenAir.getKey(),kitchenAir,MessageDirection.FROM_HARDWARE);

		model.addControlledItem("LOUNGE_AIR",loungeAir,MessageDirection.FROM_FLASH);
		model.addControlledItem("KITCHEN_AIR",kitchenAir,MessageDirection.FROM_FLASH);

		/*
		 *  This model may need an input parameter set.
		 *  The XML config file equivalent of this is 
		 *  
		 *      <CATALOGUE NAME="Nuvo Audio Inputs">
		 *               <ITEM CODE="cd1" VALUE="1"/>
		 *              <ITEM CODE="cd2" VALUE="2"/>
		 *               <ITEM CODE="digital" VALUE="3"/>
		 *               <ITEM CODE="tv" VALUE="4"/>
		 *       </CATALOGUE>
		 */

		HashMap<String, String> map = new HashMap<String,String> (40);

		map.put("cd1", "1");
		map.put("cd2", "2");
		map.put("digital","3");
		map.put("tv", "4");

		model.setCatalogueDefs("Nuvo Audio Inputs",map);

		/* 
		 * Finally add the parameter set to the model.
		 * This is the equivalent of 
		 *      <PARAMETERS>
		 *               <ITEM NAME="AUDIO_INPUTS" VALUE="Nuvo Audio Inputs"/>
		 *       </PARAMETERS>
		 */
		model.setParameter("AUDIO_INPUTS", "Nuvo Audio Inputs", DeviceModel.MAIN_DEVICE_GROUP);

		model.setPadding (2); // device requires 2 character keys that are 0 padded.

	}

	/*
	 * Specify a test that the OFF command when sent from Flash will generate the correct string.
	 */
	@Test
	public void testBuildAudioZoneOff() {
		ClientCommand testCommand = new ClientCommand("LOUNGE_AIR","off",null,"","","","",""); // The fields after the null are for EXTRA1, EXTRA2 etc.
		String expectedOut = "*T'A'OFF";
		ReturnWrapper val = new ReturnWrapper();
		try {
			model.buildAudioControlString(loungeAir, testCommand,val);
			Assert.assertEquals ("Return value for audio on failed",expectedOut,val.getCommOutputStrings().firstElement());
		} catch (Exception ex){
			fail ("Exception in call  : " + ex.getMessage());
		}
	}

	/*
	 * Specify a test that the ON command when sent from Flash will generate the correct string.
	 */
	@Test
	public void testBuildAudioZoneOn() {
		ClientCommand testCommand = new ClientCommand("LOUNGE_AIR","on",null,"","","","",""); // The fields after the null are for EXTRA1, EXTRA2 etc.
		String expectedOut = "*T'A'ON";
		ReturnWrapper val = new ReturnWrapper();
		try {
			model.buildAudioControlString(loungeAir, testCommand,val);
			Assert.assertEquals ("Return value for audio on failed",expectedOut,val.getCommOutputStrings().firstElement());
		} catch (Exception ex){
			fail ("Exception in call  : " + ex.getMessage());
		}
	}
}
