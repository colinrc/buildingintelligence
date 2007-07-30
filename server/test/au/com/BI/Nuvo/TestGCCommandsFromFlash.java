package au.com.BI.Nuvo;

import java.util.HashMap;
import java.util.Vector;
import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Device.DeviceType;

import au.com.BI.AV.AVCommand;
import au.com.BI.Audio.*;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Nuvo.Model;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;
import au.com.BI.Util.Utility;
import junit.framework.*;
import junitx.framework.ListAssert;

public class TestGCCommandsFromFlash extends TestCase {
	private Model model = null;
	Audio audioFamily = null;
	Audio audioAll = null;
	Audio kitchenAudio = null;
	Audio masterBed = null;
	
	public static void main(String[] args) {
	}

	protected void setUp() throws Exception {
		super.setUp();
		model = new Model();
		model.protocol = Protocols.GrandConcerto;
	
		audioAll = new Audio ("All",DeviceType.AUDIO);
		audioAll.setKey("00");
		audioAll.setOutputKey("ALL");
		
		audioFamily = new Audio ("Family Audio",DeviceType.AUDIO);
		audioFamily.setKey("02");
		audioFamily.setOutputKey("FAMILY_AUDIO");

		kitchenAudio = new Audio ("Kitchen Audio",DeviceType.AUDIO);
		kitchenAudio.setKey("01");
		kitchenAudio.setOutputKey("KITCHEN_AUDIO");


		masterBed = new Audio ("Master Bed Audio",DeviceType.AUDIO);
		masterBed.setKey("15");
		masterBed.setOutputKey("MASTER_BED_AUDIO");
		
		model.addControlledItem("FAMILY_AUDIO",audioFamily,MessageDirection.FROM_FLASH);
		model.addControlledItem("ALL",audioAll,MessageDirection.FROM_FLASH);
		model.addControlledItem("KITCHEN_AUDIO",kitchenAudio,MessageDirection.FROM_FLASH);
		model.addControlledItem("MASTER_BED_AUDIO",masterBed,MessageDirection.FROM_FLASH);
		
		model.addControlledItem(audioFamily.getKey(),audioFamily,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(audioAll.getKey(),audioAll,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(kitchenAudio.getKey(),kitchenAudio,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(masterBed.getKey(),masterBed,MessageDirection.FROM_HARDWARE);
		
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

	protected void tearDown() throws Exception {
		super.tearDown();
	}

	/*
	 * Test method for 'au.com.BI.Nuvo.Model.buildAudioString(AV, CommandInterface)'
	 */

	public void testBuildAudioZoneOn() {
		ClientCommand testCommand = new ClientCommand("FAMILY_AUDIO","on",null,"","","","","");
		String expectedOut = "*Z02ON";
		ReturnWrapper val = model.buildAudioString(audioFamily, testCommand);
		Assert.assertEquals ("Return value for audio on failed",expectedOut,val.getCommOutputStrings().firstElement());

	}
	
	public void testBuildAudioAllOff() {
		ClientCommand testCommand = new ClientCommand("ALL","off",null,"","","","","");
		String expectedOut = "*ALLOFF";
		ReturnWrapper val = model.buildAudioString(audioAll, testCommand);
		Assert.assertEquals ("Return value for audio all off failed",expectedOut,val.getCommOutputStrings().firstElement());
		
		Vector <CommandInterface>expectedOutFlash = new Vector<CommandInterface>();
		
		AVCommand testCommand1 = new AVCommand("CLIENT_SEND","off",null,"");
		testCommand1.setDisplayName("FAMILY_AUDIO");
		expectedOutFlash.add(testCommand1);
		
		AVCommand testCommand2 = new AVCommand("CLIENT_SEND","off",null,"");
		testCommand2.setDisplayName("MASTER_BED_AUDIO");
		expectedOutFlash.add(testCommand2);
		
		AVCommand testCommand4 = new AVCommand("CLIENT_SEND","off",null,"");
		testCommand4.setDisplayName("KITCHEN_AUDIO");
		expectedOutFlash.add(testCommand4);
		
		ListAssert.assertEquals ("Return value for interpret failed",val.getOutputFlash(),expectedOutFlash);
	}
	
	public void testBuildAudioZoneOff() {
		ClientCommand testCommand = new ClientCommand("KITCHEN_AUDIO","off",null,"","","","","");
		String expectedOut = "*Z01OFF";
		ReturnWrapper val = model.buildAudioString(kitchenAudio, testCommand);
		Assert.assertEquals ("Return value for audio zone off failed",expectedOut,val.getCommOutputStrings().firstElement());
	}
	

	
	public void testBuildAudioZoneMuteOn() {
		ClientCommand testCommand = new ClientCommand("FAMILY_AUDIO","mute",null,"on","","","","");
		String expectedOut = "*Z02MUTEON";
		ReturnWrapper val = model.buildAudioString(audioFamily, testCommand);
		Assert.assertEquals ("Return value for audio on failed",expectedOut,val.getCommOutputStrings().firstElement());
	}

	public void testBuildAudioZoneMuteOff() {
		ClientCommand testCommand = new ClientCommand("KITCHEN_AUDIO","mute",null,"off","","","","");
		String expectedOut = "*Z01MUTEOFF";
		ReturnWrapper val = model.buildAudioString(kitchenAudio, testCommand);
		Assert.assertEquals ("Return value for audio zone off failed",expectedOut,val.getCommOutputStrings().firstElement());
	}

	public void testBuildAudioMuteOn() {
		ClientCommand testCommand = new ClientCommand("ALL","mute",null,"on","","","","");
		String expectedOut = "*MUTE1";
		ReturnWrapper val = model.buildAudioString(audioAll, testCommand);
		Assert.assertEquals ("Return value for audio all on failed",expectedOut,val.getCommOutputStrings().firstElement());
		
		Vector <CommandInterface>expectedOutFlash = new Vector<CommandInterface>();
		
		AVCommand testCommand1 = new AVCommand("CLIENT_SEND","mute",null,"on");
		testCommand1.setDisplayName("FAMILY_AUDIO");
		expectedOutFlash.add(testCommand1);
		
		AVCommand testCommand2 = new AVCommand("CLIENT_SEND","mute",null,"on");
		testCommand2.setDisplayName("MASTER_BED_AUDIO");
		expectedOutFlash.add(testCommand2);
		
		AVCommand testCommand4 = new AVCommand("CLIENT_SEND","mute",null,"on");
		testCommand4.setDisplayName("KITCHEN_AUDIO");
		expectedOutFlash.add(testCommand4);
		
		ListAssert.assertEquals ("Return value for mute all failed",val.getOutputFlash(),expectedOutFlash);
	}

	public void testBuildAudioMuteOff() {
		ClientCommand testCommand = new ClientCommand("ALL","mute",null,"off","","","","");
		String expectedOut = "*MUTE0";
		ReturnWrapper val = model.buildAudioString(audioAll, testCommand);
		Assert.assertEquals ("Return value for audio all off failed",expectedOut,val.getCommOutputStrings().firstElement());
		
		Vector <CommandInterface>expectedOutFlash = new Vector<CommandInterface>();
		
		AVCommand testCommand1 = new AVCommand("CLIENT_SEND","mute",null,"off");
		testCommand1.setDisplayName("FAMILY_AUDIO");
		expectedOutFlash.add(testCommand1);
		
		AVCommand testCommand2 = new AVCommand("CLIENT_SEND","mute",null,"off");
		testCommand2.setDisplayName("MASTER_BED_AUDIO");
		expectedOutFlash.add(testCommand2);
		
		AVCommand testCommand4 = new AVCommand("CLIENT_SEND","mute",null,"off");
		testCommand4.setDisplayName("KITCHEN_AUDIO");
		expectedOutFlash.add(testCommand4);
		
		ListAssert.assertEquals ("Return value for mute all failed",val.getOutputFlash(),expectedOutFlash);
	}

	
	public void testBuildAudioBass() {
		ClientCommand testCommand = new ClientCommand("FAMILY_AUDIO","bass",null,"50","","","","");
		String expectedOut = "*ZCFG02BASS0";
		ReturnWrapper val = model.buildAudioString(audioFamily, testCommand);
		Assert.assertEquals ("Return value for audio bass failed",expectedOut,val.getCommOutputStrings().firstElement());
	}
 
	public void testBuildAudioTreble() {
		ClientCommand testCommand = new ClientCommand("FAMILY_AUDIO","treble",null,"100","","","","");
		String expectedOut = "*ZCFG02TREB18";
		ReturnWrapper val = model.buildAudioString(audioFamily, testCommand);
		Assert.assertEquals ("Return value for audio treble failed",expectedOut,val.getCommOutputStrings().firstElement());
	}

	
	public void testBuildAudioVolume() {
		ClientCommand testCommand = new ClientCommand("FAMILY_AUDIO","volume",null,"50","","","","");
		String expectedOut = "*Z02VOL39";
		ReturnWrapper val = model.buildAudioString(audioFamily, testCommand);
		Assert.assertEquals ("Return value for volume failed",expectedOut,val.getCommOutputStrings().firstElement());
		
		ClientCommand testCommand2 = new ClientCommand("FAMILY_AUDIO","volume",null,"100","","","","");
		String expectedOut2 = "*Z02VOL00";
		ReturnWrapper val2 = model.buildAudioString(audioFamily, testCommand2);
		Assert.assertEquals ("Return value for volume failed",expectedOut2,val2.getCommOutputStrings().firstElement());
		
		ClientCommand testCommand3 = new ClientCommand("FAMILY_AUDIO","volume",null,"0","","","","");
		String expectedOut3 = "*Z02VOL79";
		ReturnWrapper val3 = model.buildAudioString(audioFamily, testCommand3);
		Assert.assertEquals ("Return value for volume failed",expectedOut3,val3.getCommOutputStrings().firstElement());
	}

	
	public void testBuildAudioVolumeUp() {
	
		ClientCommand testCommand4 = new ClientCommand("FAMILY_AUDIO","volume",null,"up","","","","");
		String expectedOut4 = "*Z02VOL+";
		ReturnWrapper val4 = model.buildAudioString(audioFamily, testCommand4);
		Assert.assertEquals ("Control value for volume up failed ",expectedOut4,val4.getCommOutputStrings().firstElement());
	}
	
	public void testBuildAudioVolumeDown() {
		
		ClientCommand testCommand4 = new ClientCommand("FAMILY_AUDIO","volume",null,"up","","","","");
		String expectedOut4 = "*Z02VOL+";
		ReturnWrapper val4 = model.buildAudioString(audioFamily, testCommand4);
		Assert.assertEquals ("Control value for volume up failed ",expectedOut4,val4.getCommOutputStrings().firstElement());
	}
	
	
	public void testBuildAudioSrc() {
		ClientCommand testCommand = new ClientCommand("FAMILY_AUDIO","src",null,"cd1","","","","");
		String expectedOut = "*Z02SRC1";
		ReturnWrapper val = model.buildAudioString(audioFamily, testCommand);
		Assert.assertEquals ("Return value for src failed",expectedOut,val.getCommOutputStrings().firstElement());
		
		ClientCommand testCommand2 = new ClientCommand("FAMILY_AUDIO","src",null,"cd2","","","","");
		String expectedOut2 = "*Z02SRC2";
		ReturnWrapper val2 = model.buildAudioString(audioFamily, testCommand2);
		Assert.assertEquals ("Return value for src failed",expectedOut2,val2.getCommOutputStrings().firstElement());
				
		ClientCommand testCommand4 = new ClientCommand("FAMILY_AUDIO","src",null,"x","","","","");
		String expectedOut4 = "";
		ReturnWrapper val4 = model.buildAudioString(audioFamily, testCommand4);
		Assert.assertEquals ("Return value for unknown src failed",true,val4.isError());

	}
	

	public void testSrcCache() {
		ClientCommand testCommand = new ClientCommand("FAMILY_AUDIO","src",null,"cd1","","","","");
		String expectedOut = "*Z02SRC1";
		ReturnWrapper val = model.buildAudioString(audioFamily, testCommand);
		Assert.assertEquals ("Return value for src failed",expectedOut,val.getCommOutputStrings().firstElement());

		ClientCommand testCommandCache = new ClientCommand("FAMILY_AUDIO","src",null,"cd1","","","","");
		ReturnWrapper valCache = model.buildAudioString(audioFamily, testCommandCache);
		Assert.assertTrue ("Return value for cached src failed, the instruction was incorrectly returned",valCache.getOutputFlash().isEmpty());

	}
	

	public void testBuildAudioSrcAll() {
		
		ClientCommand testCommand3 = new ClientCommand("ALL","src",null,"cd2","","","","");
		Vector <String>expectedOut = new Vector<String>();
		expectedOut.add ("*Z01SRC2");
		expectedOut.add ("*Z02SRC2");
		expectedOut.add ("*Z15SRC2");

		ReturnWrapper val3 = model.buildAudioString(audioAll, testCommand3);
		ListAssert.assertEquals ("Return value for volume failed",expectedOut,val3.getCommOutputStrings());

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
