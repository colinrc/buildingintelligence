package au.com.BI.Nuvo;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import org.jdom.Element;

import au.com.BI.Audio.*;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Nuvo.Model;
import au.com.BI.Util.DeviceType;
import junit.framework.*;

public class TestCommandsFromFlash extends TestCase {
	private Model model = null;
	Audio audioFrontRoom = null;
	Audio kitchenAudio = null;
	
	public static void main(String[] args) {
		junit.swingui.TestRunner.run(TestCommandsFromFlash.class);
	}

	protected void setUp() throws Exception {
		super.setUp();
		model = new Model();
		
		audioFrontRoom = new Audio ("Front Audio",DeviceType.AUDIO);
		audioFrontRoom.setKey("01");
		audioFrontRoom.setOutputKey("FRONT_AUDIO");

		kitchenAudio = new Audio ("Kitchen Audio",DeviceType.AUDIO);
		kitchenAudio.setKey("02");
		kitchenAudio.setOutputKey("KITCHEN_AUDIO");

		
		model.addControlledItem("FRONT_AUDIO",audioFrontRoom,DeviceType.OUTPUT);
		
		HashMap map = new HashMap (40);
		map.put("cd1", "1");
		map.put("cd2", "2");
		map.put("digital","3");
		map.put("tv", "4");
		
		model.setCatalogueDefs("Nuvo Audio Inputs",map);
		model.setParameter("AUDIO_INPUTS", "Nuvo Audio Inputs", "");
		
		model.setPadding (2); // device requires 2 character keys that are 0 padded.
	}

	protected void tearDown() throws Exception {
		super.tearDown();
	}

	/*
	 * Test method for 'au.com.BI.Nuvo.Model.buildAudioString(AV, CommandInterface)'
	 */
	public void testBuildAudioString() {
	}

	public void testBuildAudioZoneOn() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","on",null,"FRONT_AUDIO","","","","");
		String expectedOut = "*Z01ON";
		NuvoCommands val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for audio on failed",expectedOut,val.avOutputString);
	}
	
	public void testBuildAudioZoneOff() {
		ClientCommand testCommand = new ClientCommand("KITCHEN_AUDIO","off",null,"KITCHEN_AUDIO","","","","");
		String expectedOut = "*Z02OFF";
		NuvoCommands val = model.buildAudioString(kitchenAudio, testCommand);
		Assert.assertEquals ("Return value for audio off failed",expectedOut,val.avOutputString);
	}
	
	/*
	 * Test method for 'au.com.BI.Nuvo.Model.hasState(String)'
	 */
	public void testHasState() {

	}

	/*
	 * Test method for 'au.com.BI.Nuvo.Model.getCurrentSrc(String)'
	 */
	public void testGetCurrentSrc() {

	}

}
