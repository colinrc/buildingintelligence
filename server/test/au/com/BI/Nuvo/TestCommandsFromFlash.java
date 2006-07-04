package au.com.BI.Nuvo;

import java.util.HashMap;
import java.util.Vector;
import au.com.BI.Command.BuildReturnWrapper;
import au.com.BI.Command.CommandInterface;

import au.com.BI.AV.AVCommand;
import au.com.BI.Audio.*;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Nuvo.Model;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;
import au.com.BI.Util.MessageDirection;
import au.com.BI.Util.Utility;
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
		studyAudio.setKey("03");
		studyAudio.setOutputKey("STUDY_AUDIO");
		
		model.addControlledItem("FRONT_AUDIO",audioFrontRoom,MessageDirection.FROM_FLASH);
		model.addControlledItem("ALL",audioAll,MessageDirection.FROM_FLASH);
		model.addControlledItem("KITCHEN_AUDIO",kitchenAudio,MessageDirection.FROM_FLASH);
		model.addControlledItem("STUDY_AUDIO",studyAudio,MessageDirection.FROM_FLASH);
		
		model.addControlledItem(audioFrontRoom.getKey(),audioFrontRoom,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(audioAll.getKey(),audioAll,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(kitchenAudio.getKey(),kitchenAudio,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(studyAudio.getKey(),studyAudio,MessageDirection.FROM_HARDWARE);
		
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
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","on",null,"","","","","");
		String expectedOut = "*Z01ON";
		BuildReturnWrapper val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for audio on failed",expectedOut,val.getCommOutputStrings().firstElement());

	}
	
	public void testBuildAudioAllOff() {
		ClientCommand testCommand = new ClientCommand("ALL","off",null,"","","","","");
		String expectedOut = "*ALLOFF";
		BuildReturnWrapper val = model.buildAudioString(audioAll, testCommand);
		Assert.assertEquals ("Return value for audio all off failed",expectedOut,val.getCommOutputStrings().firstElement());
		
		Vector <CommandInterface>expectedOutFlash = new Vector<CommandInterface>();
		
		AVCommand testCommand1 = new AVCommand("CLIENT_SEND","off",null,"");
		testCommand1.setDisplayName("FRONT_AUDIO");
		expectedOutFlash.add(testCommand1);
		
		AVCommand testCommand2 = new AVCommand("CLIENT_SEND","off",null,"");
		testCommand2.setDisplayName("STUDY_AUDIO");
		expectedOutFlash.add(testCommand2);
		
		AVCommand testCommand4 = new AVCommand("CLIENT_SEND","off",null,"");
		testCommand4.setDisplayName("KITCHEN_AUDIO");
		expectedOutFlash.add(testCommand4);
		
		ListAssert.assertEquals ("Return value for interpret failed",val.getOutputFlash(),expectedOutFlash);
	}
	
	public void testBuildAudioZoneOff() {
		ClientCommand testCommand = new ClientCommand("KITCHEN_AUDIO","off",null,"","","","","");
		String expectedOut = "*Z02OFF";
		BuildReturnWrapper val = model.buildAudioString(kitchenAudio, testCommand);
		Assert.assertEquals ("Return value for audio zone off failed",expectedOut,val.getCommOutputStrings().firstElement());
	}
	

	
	public void testBuildAudioZoneMuteOn() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","mute",null,"on","","","","");
		String expectedOut = "*Z01MTON";
		BuildReturnWrapper val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for audio on failed",expectedOut,val.getCommOutputStrings().firstElement());
	}

	public void testBuildAudioZoneMuteOff() {
		ClientCommand testCommand = new ClientCommand("KITCHEN_AUDIO","mute",null,"off","","","","");
		String expectedOut = "*Z02MTOFF";
		BuildReturnWrapper val = model.buildAudioString(kitchenAudio, testCommand);
		Assert.assertEquals ("Return value for audio zone off failed",expectedOut,val.getCommOutputStrings().firstElement());
	}

	public void testBuildAudioMuteOn() {
		ClientCommand testCommand = new ClientCommand("ALL","mute",null,"on","","","","");
		String expectedOut = "*ALLMON";
		BuildReturnWrapper val = model.buildAudioString(audioAll, testCommand);
		Assert.assertEquals ("Return value for audio all on failed",expectedOut,val.getCommOutputStrings().firstElement());
		
		Vector <CommandInterface>expectedOutFlash = new Vector<CommandInterface>();
		
		AVCommand testCommand1 = new AVCommand("CLIENT_SEND","mute",null,"on");
		testCommand1.setDisplayName("FRONT_AUDIO");
		expectedOutFlash.add(testCommand1);
		
		AVCommand testCommand2 = new AVCommand("CLIENT_SEND","mute",null,"on");
		testCommand2.setDisplayName("STUDY_AUDIO");
		expectedOutFlash.add(testCommand2);
		
		AVCommand testCommand4 = new AVCommand("CLIENT_SEND","mute",null,"on");
		testCommand4.setDisplayName("KITCHEN_AUDIO");
		expectedOutFlash.add(testCommand4);
		
		ListAssert.assertEquals ("Return value for mute all failed",val.getOutputFlash(),expectedOutFlash);
	}

	public void testBuildAudioMuteOff() {
		ClientCommand testCommand = new ClientCommand("ALL","mute",null,"off","","","","");
		String expectedOut = "*ALLMOFF";
		BuildReturnWrapper val = model.buildAudioString(audioAll, testCommand);
		Assert.assertEquals ("Return value for audio all off failed",expectedOut,val.getCommOutputStrings().firstElement());
		
		Vector <CommandInterface>expectedOutFlash = new Vector<CommandInterface>();
		
		AVCommand testCommand1 = new AVCommand("CLIENT_SEND","mute",null,"off");
		testCommand1.setDisplayName("FRONT_AUDIO");
		expectedOutFlash.add(testCommand1);
		
		AVCommand testCommand2 = new AVCommand("CLIENT_SEND","mute",null,"off");
		testCommand2.setDisplayName("STUDY_AUDIO");
		expectedOutFlash.add(testCommand2);
		
		AVCommand testCommand4 = new AVCommand("CLIENT_SEND","mute",null,"off");
		testCommand4.setDisplayName("KITCHEN_AUDIO");
		expectedOutFlash.add(testCommand4);
		
		ListAssert.assertEquals ("Return value for mute all failed",val.getOutputFlash(),expectedOutFlash);
	}

	
	public void testBuildAudioBass() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","bass",null,"50","","","","");
		String expectedOut = "*Z01BASS+00";
		BuildReturnWrapper val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for audio bass failed",expectedOut,val.getCommOutputStrings().firstElement());
	}
 
	public void testBuildAudioTreble() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","treble",null,"50","","","","");
		String expectedOut = "*Z01TREB+00";
		BuildReturnWrapper val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for audio treble failed",expectedOut,val.getCommOutputStrings().firstElement());
	}

	
	public void testBuildAudioVolume() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","volume",null,"50","","","","");
		String expectedOut = "*Z01VOL39";
		BuildReturnWrapper val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for volume failed",expectedOut,val.getCommOutputStrings().firstElement());
		
		ClientCommand testCommand2 = new ClientCommand("FRONT_AUDIO","volume",null,"100","","","","");
		String expectedOut2 = "*Z01VOL00";
		BuildReturnWrapper val2 = model.buildAudioString(audioFrontRoom, testCommand2);
		Assert.assertEquals ("Return value for volume failed",expectedOut2,val2.getCommOutputStrings().firstElement());
		
		ClientCommand testCommand3 = new ClientCommand("FRONT_AUDIO","volume",null,"0","","","","");
		String expectedOut3 = "*Z01VOL78";
		BuildReturnWrapper val3 = model.buildAudioString(audioFrontRoom, testCommand3);
		Assert.assertEquals ("Return value for volume failed",expectedOut3,val3.getCommOutputStrings().firstElement());
	}

	
	public void testBuildAudioVolumeUpDown() {
		ClientCommand testCommand2 = new ClientCommand("FRONT_AUDIO","volume",null,"100","","","","");
		String expectedOut2 = "*Z01VOL00";
		BuildReturnWrapper val2 = model.buildAudioString(audioFrontRoom, testCommand2);
		Assert.assertEquals ("Return value for volume failed",expectedOut2,val2.getCommOutputStrings().firstElement());
		
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","volume",null,"down","","","","");
		int TestVal = Utility.scaleFromFlash("95",0,78,true);
		String expectedOut = String.format("*Z"+audioFrontRoom.getKey()+"VOL%02d",TestVal);;
		BuildReturnWrapper val = model.buildAudioString(this.audioFrontRoom, testCommand);
		Assert.assertEquals ("Control value for volume front down failed",expectedOut,val.getCommOutputStrings().firstElement());
		AudioCommand volUpdateCommand = new AudioCommand("CLIENT_SEND","volume",null,"95");		
		volUpdateCommand.setDisplayName("FRONT_AUDIO");
		Assert.assertEquals ("Flash update from volume set failed",volUpdateCommand,val.getOutputFlash().firstElement());
		
		ClientCommand testCommand4 = new ClientCommand("FRONT_AUDIO","volume",null,"up","","","","");
		String expectedOut4 = "*Z01VOL00";
		BuildReturnWrapper val4 = model.buildAudioString(audioFrontRoom, testCommand4);
		Assert.assertEquals ("Control value for volume up failed ",expectedOut4,val4.getCommOutputStrings().firstElement());
		AudioCommand volUpdateCommand2 = new AudioCommand("CLIENT_SEND","volume",null,"100");		
		volUpdateCommand2.setDisplayName("FRONT_AUDIO");
		Assert.assertEquals ("Flash update from volume set failed",volUpdateCommand,val.getOutputFlash().firstElement());
	}

	public void testBuildAudioVolumeUpLimit() {
		ClientCommand testCommand2 = new ClientCommand("FRONT_AUDIO","volume",null,"100","","","","");
		String expectedOut2 = "*Z01VOL00";
		BuildReturnWrapper val2 = model.buildAudioString(audioFrontRoom, testCommand2);
		Assert.assertEquals ("Return value for volume set failed",expectedOut2,val2.getCommOutputStrings().firstElement());
		
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","volume",null,"up","","","","");
		String expectedOut = "*Z01VOL00";
		BuildReturnWrapper val = model.buildAudioString(this.audioFrontRoom, testCommand);
		Assert.assertEquals ("Control value for volume up past limit failed",expectedOut,val.getCommOutputStrings().firstElement());
		AudioCommand volUpdateCommand = new AudioCommand("CLIENT_SEND","volume",null,"100");		
		volUpdateCommand.setDisplayName("FRONT_AUDIO");
		Assert.assertEquals ("Flash update from volume up past limit failed",volUpdateCommand,val.getOutputFlash().firstElement());
	}
	
	public void testBuildAudioVolumeDownLimit() {
		ClientCommand testCommand2 = new ClientCommand("FRONT_AUDIO","volume",null,"0","","","","");
		String expectedOut2 = "*Z01VOL78";
		BuildReturnWrapper val2 = model.buildAudioString(audioFrontRoom, testCommand2);
		Assert.assertEquals ("Return value for volume set failed",expectedOut2,val2.getCommOutputStrings().firstElement());
		
		ClientCommand testCommand = new ClientCommand("audioFrontRoom","volume",null,"down","","","","");
		String expectedOut = "*Z01VOL78";
		BuildReturnWrapper val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Control value for volume down past limit failed",expectedOut,val.getCommOutputStrings().firstElement());
		AudioCommand volUpdateCommand = new AudioCommand("CLIENT_SEND","volume",null,"0");		
		volUpdateCommand.setDisplayName("FRONT_AUDIO");
		Assert.assertEquals ("Flash update from volume down past limit failed",volUpdateCommand,val.getOutputFlash().firstElement());
	}
	
	public void testBuildAudioVolumeRampStop() {
		ClientCommand testCommand4 = new ClientCommand("FRONT_AUDIO","volume",null,"stop","","","","");
		String expectedOut4 = "*Z01VHLD";
		BuildReturnWrapper val4 = model.buildAudioString(audioFrontRoom, testCommand4);
		Assert.assertEquals ("Return value for volume zone stop ",expectedOut4,val4.getCommOutputStrings().firstElement());
		
		ClientCommand testCommand5 = new ClientCommand("ALL","volume",null,"stop","","","","");
		String expectedOut5 = "*ZALLHLD";
		BuildReturnWrapper val5 = model.buildAudioString(audioAll, testCommand5);
		Assert.assertEquals ("Return value for volume all stop ",expectedOut5,val5.getCommOutputStrings().firstElement());
	}

	public void testBuildAudioSrc() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","src",null,"cd1","","","","");
		String expectedOut = "*Z01SRC1";
		BuildReturnWrapper val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for src failed",expectedOut,val.getCommOutputStrings().firstElement());
		
		ClientCommand testCommand2 = new ClientCommand("FRONT_AUDIO","src",null,"cd2","","","","");
		String expectedOut2 = "*Z01SRC2";
		BuildReturnWrapper val2 = model.buildAudioString(audioFrontRoom, testCommand2);
		Assert.assertEquals ("Return value for src failed",expectedOut2,val2.getCommOutputStrings().firstElement());
				
		ClientCommand testCommand4 = new ClientCommand("FRONT_AUDIO","src",null,"x","","","","");
		String expectedOut4 = "";
		BuildReturnWrapper val4 = model.buildAudioString(audioFrontRoom, testCommand4);
		Assert.assertEquals ("Return value for unknown src failed",true,val4.isError());

	}
	
	
	public void testSrcGroups() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","src",null,"cd2","","","","");
		String expectedOut = "*Z01SRC2";
		BuildReturnWrapper val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for src failed",expectedOut,val.getCommOutputStrings().firstElement());

		ClientCommand frontAudioToGroup = new ClientCommand("FRONT_AUDIO","group",null,"on","","","","");
		BuildReturnWrapper val3 = model.buildAudioString(audioFrontRoom, frontAudioToGroup);
		// add kitchen audio to the source group

		ClientCommand kitchenToGroup = new ClientCommand("KITCHEN_AUDIO","group",null,"on","","","","");
		BuildReturnWrapper val4 = model.buildAudioString(kitchenAudio, kitchenToGroup);
		// add kitchen audio to the source group


		Vector <AudioCommand>expectedOut2 = new Vector<AudioCommand>();
		AudioCommand testCommand3 = new AudioCommand("CLIENT_SEND","src",null,"cd2");
		testCommand3.setDisplayName("KITCHEN_AUDIO");
		// evaluation command for the linked source
		expectedOut2.add(testCommand3);
		
		ClientCommand sendLinkedCommand = new ClientCommand("FRONT_AUDIO","src",null,"cd2","","","","");
		BuildReturnWrapper commandAfterLink = model.buildAudioString(audioFrontRoom, testCommand);
		// trigger the command for update through linked item
		
		ListAssert.assertEquals ("Updating of grouped src failed",expectedOut2,commandAfterLink.getOutputFlash());
	}
	

	public void testSrcCache() {
		ClientCommand testCommand = new ClientCommand("FRONT_AUDIO","src",null,"cd1","","","","");
		String expectedOut = "*Z01SRC1";
		BuildReturnWrapper val = model.buildAudioString(audioFrontRoom, testCommand);
		Assert.assertEquals ("Return value for src failed",expectedOut,val.getCommOutputStrings().firstElement());

		ClientCommand testCommandCache = new ClientCommand("FRONT_AUDIO","src",null,"cd1","","","","");
		BuildReturnWrapper valCache = model.buildAudioString(audioFrontRoom, testCommandCache);
		Assert.assertTrue ("Return value for cached src failed, the instruction was incorrectly returned",valCache.getOutputFlash().isEmpty());

	}
	

	public void testBuildAudioSrcAll() {
		
		ClientCommand testCommand3 = new ClientCommand("ALL","src",null,"cd2","","","","");
		Vector <String>expectedOut = new Vector<String>();
		expectedOut.add ("*Z01SRC2");
		expectedOut.add ("*Z02SRC2");
		expectedOut.add ("*Z03SRC2");

		BuildReturnWrapper val3 = model.buildAudioString(audioAll, testCommand3);
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
