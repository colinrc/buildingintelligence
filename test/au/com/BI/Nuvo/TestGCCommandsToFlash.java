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
import junit.framework.*;

public class TestGCCommandsToFlash extends TestCase {
	private Model model = null;
	Audio audioFrontRoom = null;
	Audio audioAll = null;
	Audio kitchenAudio = null;
	
	protected void setUp() throws Exception {
		super.setUp();
		super.setUp();
		model = new Model();
		model.protocol = Protocols.GrandConcerto;
	
		audioAll = new Audio ("All",DeviceType.AUDIO);
		audioAll.setKey("00");
		audioAll.setOutputKey("ALL");
		
		audioFrontRoom = new Audio ("Front Audio",DeviceType.AUDIO);
		audioFrontRoom.setKey("01");
		audioFrontRoom.setOutputKey("FRONT_AUDIO");

		kitchenAudio = new Audio ("Kitchen Audio",DeviceType.AUDIO);
		kitchenAudio.setKey("15");
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

	public void testInterpretOnStringFromNuvo() {
		
		Command testString = new Command();
		testString.setKey("#Z1,ON,SRC4,VOL79,DND0,LOCK0");
		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();
		
		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","on",null,"");
		testCommand.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand);

		AudioCommand testCommand2 = new AudioCommand("CLIENT_SEND","src",null,"tv");
		testCommand2.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand2);

		AudioCommand testCommand3 = new AudioCommand("CLIENT_SEND","volume",null,"0");
		testCommand3.setExtraInfo("0");
		testCommand3.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand3);

		ReturnWrapper val = model.interpretStringFromNuvo(testString);
		ListAssert.assertEquals ("Return value for interpret failed",val.getOutputFlash(),expectedOut);
	}


	public void testInterpretOffStringFromNuvo() {
		
		Command testString = new Command();
		testString.setKey("#Z15,OFF");
		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();
		
		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","off",null,"");
		testCommand.setDisplayName("KITCHEN_AUDIO");
		expectedOut.add(testCommand);

		ReturnWrapper val = model.interpretStringFromNuvo(testString);
		ListAssert.assertEquals ("Return value for interpret failed",val.getOutputFlash(),expectedOut);
	}

	public void testInterpretVolume() {
		
		Command testString = new Command();
		testString.setKey("#Z1,ON,SRC4,VOL0,DND0,LOCK0");
		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();
		
		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","volume",null,"100");
		testCommand.setDisplayName("FRONT_AUDIO");

		ReturnWrapper val = model.interpretStringFromNuvo(testString);
		ListAssert.assertContains ("Return value for interpret volume failed",val.getOutputFlash(),testCommand);
	}
	

	
	public void testInterpretZoneStatus() {

		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();	
		Command testString = new Command();
		
		testString.setKey("#ZCFG1,BASS-18,TREB0,BALC,LOUDCMP");
		ReturnWrapper val = model.interpretStringFromNuvo(testString);


		AudioCommand testCommand = new AudioCommand("CLIENT_SEND","treble",null,"50");
		testCommand.setDisplayName("FRONT_AUDIO");
		
		AudioCommand testCommand2 = new AudioCommand("CLIENT_SEND","bass",null,"0");
		testCommand2.setDisplayName("FRONT_AUDIO");
		expectedOut.add(testCommand2);
		
		
		ListAssert.assertContains ("Return value for interpret zone set status failed",val.getOutputFlash(),testCommand);

	}
}
