package au.com.BI.Nuvo;

import java.util.HashMap;
import java.util.Vector;
import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Audio.*;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;
import junitx.framework.ListAssert;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;

import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;

public class TestCommandsToFlash {
	private Model model = null;
	Audio audioFrontRoom = null;
	Audio audioAll = null;
	Audio kitchenAudio = null;
	
	@Before
	public void setUp() throws Exception {

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

		model.addControlledItem(audioFrontRoom.getKey(),audioFrontRoom,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(audioAll.getKey(),audioAll,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(kitchenAudio.getKey(),kitchenAudio,MessageDirection.FROM_HARDWARE);
		
		model.addControlledItem("FRONT_AUDIO",audioFrontRoom,MessageDirection.FROM_FLASH);
		model.addControlledItem("ALL",audioAll,MessageDirection.FROM_FLASH);
		model.addControlledItem("KITCHEN_AUDIO",kitchenAudio,MessageDirection.FROM_FLASH);
		
		HashMap<String, String> map = new HashMap<String,String> (40);
		
		map.put("cd1", "1");
		map.put("cd2", "2");
		map.put("digital","3");
		map.put("tv", "4");
		
		model.setCatalogueDefs("Nuvo Audio Inputs",map);
		
		model.setParameter("AUDIO_INPUTS", "Nuvo Audio Inputs", DeviceModel.MAIN_DEVICE_GROUP);
		model.finishedReadingConfig();
		model.initState();
		model.setPadding (2); // device requires 2 character keys that are 0 padded.
	}

	@Test
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

		ReturnWrapper val = model.interpretStringFromNuvo(testString);
		ListAssert.assertEquals ("Return value for interpret failed",val.getOutputFlash(),expectedOut);
	}
	
	@Test
	public void testInterpretVolume() {
		
		Command testString = new Command();
		testString.setKey("#Z01PWRON,SRC2,GRP0,VOL-79");
		
		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","volume",null,"0");
		testCommand.setDisplayName("FRONT_AUDIO");

		ReturnWrapper val = model.interpretStringFromNuvo(testString);
		ListAssert.assertContains ("Return value for interpret volume failed",val.getOutputFlash(),testCommand);
	}
	
	@Test
	public void testInterpretStatus() {

		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();	
		Command testString = new Command();
		
		testString.setKey("#Z01PWRON,SRC2,GRP0,VOL-79");
		ReturnWrapper val = model.interpretStringFromNuvo(testString);

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
		
		ListAssert.assertContains ("Return value for interpret status volume failed",val.getOutputFlash(),testCommand);
		
		assertFalse ("Interpret status incorrectly contained power",val.getOutputFlash().contains(testCommand2));
		
		assertFalse ("Interpret status incorrectly contained src",val.getOutputFlash().contains(testCommand3));
		
		testString.setKey("#Z01PWRON,SRC1,GRP0,VOL-00");
		val = model.interpretStringFromNuvo(testString);
		
		AudioCommand testCommand4 = new AudioCommand("CLIENT_SEND","src",null,"cd2");
		testCommand4.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand4);
		
		assertFalse ("Interpret status did not detect src change",val.getOutputFlash().contains(testCommand4));
	}
	
	@Test
	public void testInterpretZoneStatus() {

		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();	
		Command testString = new Command();
		
		testString.setKey("#Z01OR0,BASS00,TREB08,GRPq,VRSTr");
		ReturnWrapper val = model.interpretStringFromNuvo(testString);


		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","treble",null,"0");
		testCommand.setDisplayName("FRONT_AUDIO");
		
		AudioCommand testCommand2 = new AudioCommand("CLIENT_SEND","bass",null,"100");
		testCommand2.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand2);
		
		
		ListAssert.assertContains ("Return value for interpret zone set status failed",val.getOutputFlash(),testCommand);

	}
}
