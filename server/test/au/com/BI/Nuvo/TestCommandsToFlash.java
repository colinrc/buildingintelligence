package au.com.BI.Nuvo;

import java.util.HashMap;
import java.util.Vector;

import au.com.BI.Audio.*;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;
import junitx.framework.ListAssert;
import au.com.BI.Command.*;
import junit.framework.*;

public class TestCommandsToFlash extends TestCase {
	private Model model = null;
	Audio audioFrontRoom = null;
	Audio audioAll = null;
	Audio kitchenAudio = null;
	
	protected void setUp() throws Exception {
		super.setUp();
		super.setUp();
		model = new Model();
	
		audioAll = new Audio ("All",DeviceType.AUDIO);
		audioAll.setKey("00");
		audioAll.setOutputKey("ALL");
		
		audioFrontRoom = new Audio ("Front Audio",DeviceType.AUDIO);
		audioFrontRoom.setKey("01");
		audioFrontRoom.setOutputKey("FRONT_AUDIO");

		kitchenAudio = new Audio ("Kitchen Audio",DeviceType.AUDIO);
		kitchenAudio.setKey("02");
		kitchenAudio.setOutputKey("KITCHEN_AUDIO");

		model.addControlledItem(audioFrontRoom.getKey(),audioFrontRoom,DeviceType.MONITORED);
		model.addControlledItem(audioAll.getKey(),audioAll,DeviceType.MONITORED);
		model.addControlledItem(kitchenAudio.getKey(),kitchenAudio,DeviceType.MONITORED);
		
		model.addControlledItem("FRONT_AUDIO",audioFrontRoom,DeviceType.OUTPUT);
		model.addControlledItem("ALL",audioAll,DeviceType.OUTPUT);
		model.addControlledItem("KITCHEN_AUDIO",kitchenAudio,DeviceType.OUTPUT);
		
		HashMap<String, String> map = new HashMap<String,String> (40);
		
		map.put("cd1", "1");
		map.put("cd2", "2");
		map.put("digital","3");
		map.put("tv", "4");
		
		model.setCatalogueDefs("Nuvo Audio Inputs",map);
		
		model.setParameter("AUDIO_INPUTS", "Nuvo Audio Inputs", DeviceModel.MAIN_DEVICE_GROUP);
		model.setupAudioInputs ();
		model.initState();
		model.setPadding (2); // device requires 2 character keys that are 0 padded.
	}

	public void testInterpretStringFromNuvo() {
		
		Command testString = new Command();
		testString.setKey("#Z01PWRON,SRC2,GRP0,VOL-MT");
		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();
		
		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","on",null,"");
		testCommand.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand);

		AudioCommand testCommand2 = new AudioCommand("CLIENT_SEND","src",null,"cd2");
		testCommand2.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand2);

		AudioCommand testCommand3 = new AudioCommand("CLIENT_SEND","mute",null,"on");
		testCommand3.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand3);

		NuvoCommands val = model.interpretStringFromNuvo(testString);
		ListAssert.assertEquals ("Return value for interpret failed",val.avOutputFlash,expectedOut);
	}
	
	public void testInterpretVolume() {
		
		Command testString = new Command();
		testString.setKey("#Z01PWRON,SRC2,GRP0,VOL-79");
		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();
		
		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","volume",null,"0");
		testCommand.setDisplayName("FRONT_AUDIO");

		NuvoCommands val = model.interpretStringFromNuvo(testString);
		ListAssert.assertContains ("Return value for interpret volume failed",val.avOutputFlash,testCommand);
	}
	
	public void testInterpretStatus() {

		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();	
		Command testString = new Command();
		
		testString.setKey("#Z01PWRON,SRC2,GRP0,VOL-79");
		NuvoCommands val = model.interpretStringFromNuvo(testString);

		testString.setKey("#Z01PWRON,SRC2,GRP0,VOL-00");
		val = model.interpretStringFromNuvo(testString);

		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","volume",null,"100");
		testCommand.setDisplayName("FRONT_AUDIO");
		
		AudioCommand testCommand2 = new AudioCommand("CLIENT_SEND","on",null,"");
		testCommand2.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand2);
		
		AudioCommand testCommand3 = new AudioCommand("CLIENT_SEND","src",null,"cd2");
		testCommand3.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand3);
		
		ListAssert.assertContains ("Return value for interpret status volume failed",val.avOutputFlash,testCommand);
		
		Assert.assertFalse ("Interpret status incorrectly contained power",val.avOutputFlash.contains(testCommand2));
		
		Assert.assertFalse ("Interpret status incorrectly contained src",val.avOutputFlash.contains(testCommand3));
		
		testString.setKey("#Z01PWRON,SRC1,GRP0,VOL-00");
		val = model.interpretStringFromNuvo(testString);
		
		AudioCommand testCommand4 = new AudioCommand("CLIENT_SEND","src",null,"cd2");
		testCommand4.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand4);
		
		Assert.assertFalse ("Interpret status did not detect src change",val.avOutputFlash.contains(testCommand4));
	}
	
	public void testInterpretZoneStatus() {

		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();	
		Command testString = new Command();
		
		testString.setKey("#Z01OR0,BASS00,TREB08,GRPq,VRSTr");
		NuvoCommands val = model.interpretStringFromNuvo(testString);


		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","treble",null,"0");
		testCommand.setDisplayName("FRONT_AUDIO");
		
		AudioCommand testCommand2 = new AudioCommand("CLIENT_SEND","bass",null,"100");
		testCommand2.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand2);
		
		
		ListAssert.assertContains ("Return value for interpret zone set status failed",val.avOutputFlash,testCommand);

	}
}
