package au.com.BI.Nuvo;

import java.util.HashMap;
import java.util.Vector;


import au.com.BI.Audio.*;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Nuvo.Model;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;
import junit.framework.*;
import junitx.framework.ListAssert;

public class TestCommandsFromFlash extends TestCase {
	private Model model = null;
	Audio audioFrontRoom = null;
	Audio audioAll = null;
	Audio kitchenAudio = null;
	Audio studyAudio = null;
	
	public static void main(String[] args) {
		junit.swingui.TestRunner.run(TestCommandsFromFlash.class);
	}

	protected void setUp() throws Exception {
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


		studyAudio = new Audio ("Study Audio",DeviceType.AUDIO);
		studyAudio.setKey("02");
		studyAudio.setOutputKey("STUDY_AUDIO");
		
		model.addControlledItem("FRONT_AUDIO",audioFrontRoom,DeviceType.OUTPUT);
		model.addControlledItem("ALL",audioAll,DeviceType.OUTPUT);
		model.addControlledItem("KITCHEN_AUDIO",kitchenAudio,DeviceType.OUTPUT);
		model.addControlledItem("STUDY_AUDIO",studyAudio,DeviceType.OUTPUT);
		
		model.addControlledItem(audioFrontRoom.getKey(),audioFrontRoom,DeviceType.MONITORED);
		model.addControlledItem(audioAll.getKey(),audioAll,DeviceType.MONITORED);
		model.addControlledItem(kitchenAudio.getKey(),kitchenAudio,DeviceType.MONITORED);
		
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

	protected void tearDown() throws Exception {
		super.tearDown();
	}

	/*
	 * Test method for 'au.com.BI.Nuvo.Model.buildAudioString(AV, CommandInterface)'
	 */

	public void testBuildAudioZoneOn() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","on",null,"","","","","");
		String expectedOut = "*Z01ON";
		NuvoCommands val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for audio on failed",expectedOut,val.avOutputStrings.firstElement());
	}
	
	public void testBuildAudioAllOff() {
		ClientCommand testCommand = new ClientCommand("ALL","off",null,"","","","","");
		String expectedOut = "*ALLOFF";
		NuvoCommands val = model.buildAudioString(audioAll, testCommand);
		Assert.assertEquals ("Return value for audio all off failed",expectedOut,val.avOutputStrings.firstElement());
	}
	
	public void testBuildAudioZoneOff() {
		ClientCommand testCommand = new ClientCommand("KITCHEN_AUDIO","off",null,"","","","","");
		String expectedOut = "*Z02OFF";
		NuvoCommands val = model.buildAudioString(kitchenAudio, testCommand);
		Assert.assertEquals ("Return value for audio zone off failed",expectedOut,val.avOutputStrings.firstElement());
	}
	

	
	public void testBuildAudioZoneMuteOn() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","mute",null,"on","","","","");
		String expectedOut = "*Z01MTON";
		NuvoCommands val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for audio on failed",expectedOut,val.avOutputStrings.firstElement());
	}

	public void testBuildAudioZoneMuteOff() {
		ClientCommand testCommand = new ClientCommand("KITCHEN_AUDIO","mute",null,"off","","","","");
		String expectedOut = "*Z02MTOFF";
		NuvoCommands val = model.buildAudioString(kitchenAudio, testCommand);
		Assert.assertEquals ("Return value for audio zone off failed",expectedOut,val.avOutputStrings.firstElement());
	}

	public void testBuildAudioMuteOn() {
		ClientCommand testCommand = new ClientCommand("ALL","mute",null,"on","","","","");
		String expectedOut = "*ALLMON";
		NuvoCommands val = model.buildAudioString(audioAll, testCommand);
		Assert.assertEquals ("Return value for audio all on failed",expectedOut,val.avOutputStrings.firstElement());
	}

	public void testBuildAudioMuteOff() {
		ClientCommand testCommand = new ClientCommand("ALL","mute",null,"off","","","","");
		String expectedOut = "*ALLMOFF";
		NuvoCommands val = model.buildAudioString(audioAll, testCommand);
		Assert.assertEquals ("Return value for audio all off failed",expectedOut,val.avOutputStrings.firstElement());
	}

	
	public void testBuildAudioBass() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","bass",null,"50","","","","");
		String expectedOut = "*Z01BASS+00";
		NuvoCommands val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for audio bass failed",expectedOut,val.avOutputStrings.firstElement());
	}
 
	public void testBuildAudioTreble() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","treble",null,"50","","","","");
		String expectedOut = "*Z01TREB+00";
		NuvoCommands val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for audio treble failed",expectedOut,val.avOutputStrings.firstElement());
	}

	
	public void testBuildAudioVolume() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","volume",null,"50","","","","");
		String expectedOut = "*Z01VOL39";
		NuvoCommands val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for volume failed",expectedOut,val.avOutputStrings.firstElement());
		
		ClientCommand testCommand2 = new ClientCommand("FRONT_AUDIO","volume",null,"100","","","","");
		String expectedOut2 = "*Z01VOL00";
		NuvoCommands val2 = model.buildAudioString(audioFrontRoom, testCommand2);
		Assert.assertEquals ("Return value for volume failed",expectedOut2,val2.avOutputStrings.firstElement());
		
		ClientCommand testCommand3 = new ClientCommand("FRONT_AUDIO","volume",null,"0","","","","");
		String expectedOut3 = "*Z01VOL78";
		NuvoCommands val3 = model.buildAudioString(audioFrontRoom, testCommand3);
		Assert.assertEquals ("Return value for volume failed",expectedOut3,val3.avOutputStrings.firstElement());
	}

	
	public void testBuildAudioVolumeRamp() {
		ClientCommand testCommand = new ClientCommand("ALL","volume",null,"up","","","","");
		String expectedOut = "*ZALLV+";
		NuvoCommands val = model.buildAudioString(this.audioAll, testCommand);
		Assert.assertEquals ("Return value for volume all up failed",expectedOut,val.avOutputStrings.firstElement());
		
		ClientCommand testCommand2 = new ClientCommand("FRONT_AUDIO","volume",null,"down","","","","");
		String expectedOut2 = "*Z01VOL-";
		NuvoCommands val2 = model.buildAudioString(audioFrontRoom, testCommand2);
		Assert.assertEquals ("Return value for volume zone down failed",expectedOut2,val2.avOutputStrings.firstElement());
		
		ClientCommand testCommand3 = new ClientCommand("FRONT_AUDIO","volume",null,"up","","","","");
		String expectedOut3 = "*Z01VOL+";
		NuvoCommands val3 = model.buildAudioString(audioFrontRoom, testCommand3);
		Assert.assertEquals ("Return value for volume zone up ",expectedOut3,val3.avOutputStrings.firstElement());
		
		ClientCommand testCommand4 = new ClientCommand("FRONT_AUDIO","volume",null,"stop","","","","");
		String expectedOut4 = "*Z01VHLD";
		NuvoCommands val4 = model.buildAudioString(audioFrontRoom, testCommand4);
		Assert.assertEquals ("Return value for volume zone stop ",expectedOut4,val4.avOutputStrings.firstElement());
		
		ClientCommand testCommand5 = new ClientCommand("ALL","volume",null,"stop","","","","");
		String expectedOut5 = "*ZALLHLD";
		NuvoCommands val5 = model.buildAudioString(audioAll, testCommand5);
		Assert.assertEquals ("Return value for volume all stop ",expectedOut5,val5.avOutputStrings.firstElement());
	}

	public void testBuildAudioSrc() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","src",null,"cd1","","","","");
		String expectedOut = "*Z01SRC1";
		NuvoCommands val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for src failed",expectedOut,val.avOutputStrings.firstElement());
		
		ClientCommand testCommand2 = new ClientCommand("FRONT_AUDIO","src",null,"cd2","","","","");
		String expectedOut2 = "*Z01SRC2";
		NuvoCommands val2 = model.buildAudioString(audioFrontRoom, testCommand2);
		Assert.assertEquals ("Return value for src failed",expectedOut2,val2.avOutputStrings.firstElement());
				
		ClientCommand testCommand4 = new ClientCommand("FRONT_AUDIO","src",null,"x","","","","");
		String expectedOut4 = "";
		NuvoCommands val4 = model.buildAudioString(audioFrontRoom, testCommand4);
		Assert.assertEquals ("Return value for unknown src failed",true,val4.error);

	}
	
	
	public void testSrcGroups() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","src",null,"cd1","","","","");
		String expectedOut = "*Z01SRC1";
		NuvoCommands val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for src failed",expectedOut,val.avOutputStrings.firstElement());

		ClientCommand testCommandCache = new ClientCommand("FRONT_AUDIO","src",null,"cd1","","","","");
		NuvoCommands valCache = model.buildAudioString(audioFrontRoom, testCommandCache);
		Assert.assertTrue ("Return value for cached src failed, the instruction was incorrectly returned",valCache.avOutputFlash.isEmpty());

		ClientCommand testCommand2 = new ClientCommand("KITCHEN_AUDIO","group",null,"on","","","","");
		NuvoCommands val2 = model.buildAudioString(kitchenAudio, testCommand2);
		// add kitchen audio to the source group
		
		Vector <AudioCommand>expectedOut2 = new Vector<AudioCommand>();
		AudioCommand testCommand3 = new AudioCommand("CLIENT_SEND","src",null,"cd2");
		testCommand3.setDisplayName("KITCHEN_AUDIO");
		// evaluation command for the linked source
		expectedOut2.add(testCommand3);
		
		ClientCommand sendLinkedCommand = new ClientCommand("FRONT_AUDIO","src",null,"cd2","","","","");
		NuvoCommands commandAfterLink = model.buildAudioString(audioFrontRoom, testCommand);
		// trigger the command for update through linked item
		
		ListAssert.assertEquals ("Updating of grouped src failed",expectedOut2,commandAfterLink.avOutputFlash);
	}
	
	
	public void testBuildAudioSrcAll() {
		
		ClientCommand testCommand3 = new ClientCommand("ALL","src",null,"cd2","","","","");
		Vector <String>expectedOut = new Vector<String>();
		expectedOut.add ("*Z01SRC2");
		expectedOut.add ("*Z02SRC2");

		NuvoCommands val3 = model.buildAudioString(audioAll, testCommand3);
		ListAssert.assertEquals ("Return value for volume failed",expectedOut,val3.avOutputStrings);

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
