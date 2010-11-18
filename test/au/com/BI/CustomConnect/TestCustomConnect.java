package au.com.BI.CustomConnect;

import java.util.HashMap;

import junit.framework.Assert;

import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommsProcessException;
import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Comms.CommsCommand;
import au.com.BI.Device.DeviceType;
import au.com.BI.Util.*;

import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;

public class TestCustomConnect {

	SimplifiedModel testModel = null;

	@Before
	public void setUp() throws Exception{

		testModel = new SimplifiedModel();
		testModel.setName("Custom Connect");
		HashMap<String, String> map = new HashMap<String,String> (40);

		map.put("cd1", "1");
		map.put("cd2", "2");
		map.put("digital","3");
		map.put("tv", "4");

		testModel.setCatalogueDefs("Audio Inputs",map);

		testModel.setParameter("AUDIO_INPUTS", "Audio Inputs", DeviceModel.MAIN_DEVICE_GROUP);
		testModel.setupParameterBlocks ();
	}

	@Test
	public void testCustomCommandOutputString () {
		CustomConnect connection = new CustomConnect();
		connection.setName("Test Connection");
		connection.setDeviceType(DeviceType.CUSTOM_CONNECT);
		connection.setKey("1");
		connection.setOutputKey("TEST_CONNECTION");
		connection.addOutputCondition("replace_number_extra","%NUMBER%", "Test_Scaled_%SCALE 0 60 %","Test replace number");
		connection.addOutputCondition("replace_number_inverted_extra","%NUMBER%", "Test_Scaled_%SCALE 60 0 %", " Test inverted replace number");
		connection.addOutputCondition("replace_command_extra","", "Test_commandExtra_%COMMAND.EXTRA%", "Test replace extra");
		connection.addOutputCondition("pure_string","","Test_pure" , "Test simpe replacement");
		connection.addOutputCondition("replace_command_extra2","up", "Test_commandExtra_%COMMAND.EXTRA2% up","Test extra2 value test 1");
		connection.addOutputCondition("replace_command_extra2","down", "Test_commandExtra_%COMMAND.EXTRA2% down","Test extra2 value test 2");
		connection.addOutputCondition("replace_command_extra3", "","Test_commandExtra_%COMMAND.EXTRA3%","Test extra3 replacement");
		connection.addOutputCondition("replace_command_extra_extra4","", "Test_commandExtra_%COMMAND.EXTRA% %COMMAND.EXTRA4%_Fin","Test extra4 replacement");
		connection.addOutputCondition("replace_lookup_extra", "","lookup_result=%LOOKUP AUDIO_INPUTS COMMAND.EXTRA %","Test lookup");

		runCustomCommandString(connection, "pure_string", "extraVal" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val", "Test_pure");
		runCustomCommandString(connection, "replace_command_extra", "extraVal" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "Test_commandExtra_extraVal");
		runCustomCommandString(connection, "replace_number_extra", "100" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "Test_Scaled_60");
		runCustomCommandString(connection, "replace_number_inverted_extra", "100" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "Test_Scaled_0");
		runCustomCommandString(connection, "replace_command_extra2", "up" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "Test_commandExtra_extra2Val up");
		runCustomCommandString(connection, "replace_command_extra2", "down" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "Test_commandExtra_extra2Val down");
		runCustomCommandString(connection, "replace_command_extra2", "fail" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "");
		runCustomCommandString(connection, "replace_command_extra3", "extraVal" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "Test_commandExtra_extra3Val");
		runCustomCommandString(connection, "replace_command_extra_extra4", "extraVal" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "Test_commandExtra_extraVal extra4Val_Fin");
		runCustomCommandString(connection, "replace_lookup_extra", "cd2" , "" , "" ,"","",  "lookup_result=2");
	}

	
	public void runCustomCommandString(CustomConnect connection, String commandCode, String extra, String extra2, String extra3, String extra4, String extra5,  String expected) {
		ReturnWrapper returnWrapper = new ReturnWrapper();
		CommandInterface command = new Command();
		command.setCommand(commandCode);
		command.setDisplayName("TEST_CONNECTION");
		command.setExtraInfo(extra);
		command.setExtra2Info(extra2);
		command.setExtra3Info(extra3);
		command.setExtra4Info(extra4);
		command.setExtra5Info(extra5);
		try {
			testModel.doCustomConnectOutputIfPresent(command,  connection,returnWrapper);
			assertEquals("Custom Connection failed " ,  expected, returnWrapper.getCommOutput().firstElement());
		} catch (ModelException ex){
			Assert.fail(ex.getMessage());
		}
	}

	@Test
	public void testCustomCommandInputString () {
		
		CustomConnect connection = new CustomConnect();
		connection.setName("Test Connection");
		connection.setDeviceType(DeviceType.CUSTOM_CONNECT);
		connection.setKey("1");
		connection.setOutputKey("TEST_CONNECTION1");
		testModel.addControlledItem(connection.getOutputKey(), connection, MessageDirection.FROM_FLASH);
		testModel.addControlledItem(connection.getKey(), connection, MessageDirection.FROM_HARDWARE);				


		CustomConnect connection2 = new CustomConnect();
		connection2.setName("Test Connection");
		connection2.setDeviceType(DeviceType.CUSTOM_CONNECT);
		connection2.setKey(testModel.formatKey("2", connection));
		connection2.setOutputKey("TEST_CONNECTION2");
		testModel.addControlledItem(connection2.getOutputKey(), connection2, MessageDirection.FROM_FLASH);
		testModel.addControlledItem(connection2.getKey(), connection2, MessageDirection.FROM_HARDWARE);				

		CustomConnectInput customConnectInput = new CustomConnectInput();
		customConnectInput.addCustomConnectInputDetails(new CustomConnectInputDetails("AU_PWR (\\d+) on", "@1", "Power on","on","", "", "", "", ""));
		customConnectInput.addCustomConnectInputDetails(new CustomConnectInputDetails("AU_PWR (\\d+) off", "@2", "Power off","off","", "", "", "", ""));
		customConnectInput.addCustomConnectInputDetails(new CustomConnectInputDetails("AU_VOL (\\d+)=(\\d+)", "@1", "Set Volume","volume","%SCALE @2 0 60%", "", "", "", ""));
		customConnectInput.addCustomConnectInputDetails(new CustomConnectInputDetails("AU_SRC (\\d+) (\\d+)", "@1", "Set Input Source","src","%LOOKUP AUDIO_INPUTS @2 %", "", "", "", ""));
		//<INSTRING TO_MATCH="AU_SRC (\d+) (\d+)"  NAME="Set Input Source" KEY="@1" COMMAND="src" EXTRA="%LOOKUP AUDIO_INPUTS @2 %" />
		testModel.addCustomConnectInput(customConnectInput);

		runCustomCommandInputString(connection, "AU_PWR 1 on", "on" , "", "" , "" ,"","", "TEST_CONNECTION1");

		ReturnWrapper failWrapper = new ReturnWrapper();
		runCustomCommandInputString(connection, "AU_PWR 1 off", failWrapper);
		runCustomCommandInputString(connection, "AU_VOL 1=60", "volume" , "100", "" , "" ,"","", "TEST_CONNECTION1");
		runCustomCommandInputString(connection, "AU_VOL 2=30", "volume" , "50", "" , "" ,"","", "TEST_CONNECTION2");
		runCustomCommandInputString(connection, "AU_SRC 1 2", "src" , "cd2", "" , "" ,"","", "TEST_CONNECTION1");
	}
	
	public void runCustomCommandInputString(CustomConnect connection, String commsCode, String commandCode, String extra, String extra2, String extra3, String extra4, String extra5,  String display_name)
	{
		ReturnWrapper returnWrapper = new ReturnWrapper();
		CommsCommand command = new CommsCommand();
		command.setCommand(commsCode);

		CustomConnectCommand outCommand = new CustomConnectCommand();
		outCommand.setCommand(commandCode);
		outCommand.setExtraInfo(extra);
		outCommand.setExtra2Info(extra2);
		outCommand.setExtra3Info(extra3);
		outCommand.setExtra4Info(extra4);
		outCommand.setExtra5Info(extra5);
		outCommand.setDisplayName(display_name);
		outCommand.setKey("CLIENT_SEND");

		try {
			testModel.doCustomConnectInputIfPresent(command,  returnWrapper);
			assertEquals("Custom Connection failed " ,  outCommand, returnWrapper.getOutputFlash().firstElement());
		} catch (CommsProcessException ex){
			Assert.fail(ex.getMessage());
		}
	}

	public void runCustomCommandInputString(CustomConnect connection, String commsCode,  ReturnWrapper testWrapper) {
		ReturnWrapper returnWrapper = new ReturnWrapper();
		CommsCommand command = new CommsCommand();
		command.setCommand(commsCode);

		try {
			testModel.doCustomConnectInputIfPresent(command,  returnWrapper);
			assertEquals("Custom Connection failed " ,  testWrapper, returnWrapper);
		} catch (CommsProcessException ex){
			Assert.fail(ex.getMessage());
		}
	}
	
	@Test
	public void testCustomCommandInputByteArray () {
		
		CustomConnect connection = new CustomConnect();
		connection.setName("Test Connection");
		connection.setDeviceType(DeviceType.CUSTOM_CONNECT);
		connection.setKey("1");
		connection.setOutputKey("TEST_CONNECTION1");
		testModel.addControlledItem(connection.getOutputKey(), connection, MessageDirection.FROM_FLASH);
		testModel.addControlledItem(connection.getKey(), connection, MessageDirection.FROM_HARDWARE);				


		CustomConnect connection2 = new CustomConnect();
		connection2.setName("Test Connection");
		connection2.setDeviceType(DeviceType.CUSTOM_CONNECT);
		connection2.setKey(testModel.formatKey("2", connection));
		connection2.setOutputKey("TEST_CONNECTION2");
		testModel.addControlledItem(connection2.getOutputKey(), connection2, MessageDirection.FROM_FLASH);
		testModel.addControlledItem(connection2.getKey(), connection2, MessageDirection.FROM_HARDWARE);				

		CustomConnectInput customConnectInput = new CustomConnectInput();
		customConnectInput.addCustomConnectInputDetails(new CustomConnectInputDetails("AU_PWR (\\d+) on", "@1", "Power on","on","", "", "", "", ""));
		customConnectInput.addCustomConnectInputDetails(new CustomConnectInputDetails("AU_PWR (\\d+) off", "@2", "Power off","off","", "", "", "", ""));
		customConnectInput.addCustomConnectInputDetails(new CustomConnectInputDetails("AU_VOL (\\d+)=(\\d+)", "@1", "Set Volume","volume","%SCALE @2 0 60%", "", "", "", ""));
		customConnectInput.addCustomConnectInputDetails(new CustomConnectInputDetails("AU_SRC (\\d+) (\\d+)", "@1", "Set Input Source","src","%LOOKUP AUDIO_INPUTS @2 %", "", "", "", ""));
		//<INSTRING TO_MATCH="AU_SRC (\d+) (\d+)"  NAME="Set Input Source" KEY="@1" COMMAND="src" EXTRA="%LOOKUP AUDIO_INPUTS @2 %" />
		testModel.addCustomConnectInput(customConnectInput);

		String command = "AU_PWR 1 on";
		byte[] testInput = command.getBytes();
		runCustomCommandInputByteArray(connection, testInput, "on" , "", "" , "" ,"","", "TEST_CONNECTION1");

		ReturnWrapper failWrapper = new ReturnWrapper();
		command = "AU_PWR 1 off";
		testInput = command.getBytes();
		runCustomCommandInputByteArray(connection, testInput, failWrapper);
		command = "AU_VOL 1=60";
		testInput = command.getBytes();
		runCustomCommandInputByteArray(connection, testInput, "volume" , "100", "" , "" ,"","", "TEST_CONNECTION1");
		command = "AU_VOL 2=30";
		testInput = command.getBytes();
		runCustomCommandInputByteArray(connection, testInput, "volume" , "50", "" , "" ,"","", "TEST_CONNECTION2");
		command = "AU_SRC 1 2";
		testInput = command.getBytes();
		runCustomCommandInputByteArray(connection, testInput, "src" , "cd2", "" , "" ,"","", "TEST_CONNECTION1");
	}
	
	public void runCustomCommandInputByteArray(CustomConnect connection, byte[] commsCode, String commandCode, String extra, String extra2, String extra3, String extra4, String extra5,  String display_name)
	{
		ReturnWrapper returnWrapper = new ReturnWrapper();
		CommsCommand command = new CommsCommand();
		command.setCommandBytes(commsCode);

		CustomConnectCommand outCommand = new CustomConnectCommand();
		outCommand.setCommand(commandCode);
		outCommand.setExtraInfo(extra);
		outCommand.setExtra2Info(extra2);
		outCommand.setExtra3Info(extra3);
		outCommand.setExtra4Info(extra4);
		outCommand.setExtra5Info(extra5);
		outCommand.setDisplayName(display_name);
		outCommand.setKey("CLIENT_SEND");

		try {
			testModel.doCustomConnectInputIfPresent(command,  returnWrapper);
			assertEquals("Custom Connection failed " ,  outCommand, returnWrapper.getOutputFlash().firstElement());
		} catch (CommsProcessException ex){
			Assert.fail(ex.getMessage());
		}
	}
	
	public void runCustomCommandInputByteArray(CustomConnect connection, byte[] commsCode,  ReturnWrapper testWrapper) {
		ReturnWrapper returnWrapper = new ReturnWrapper();
		CommsCommand command = new CommsCommand();
		command.setCommandBytes(commsCode);

		try {
			testModel.doCustomConnectInputIfPresent(command,  returnWrapper);
			assertEquals("Custom Connection failed " ,  testWrapper, returnWrapper);
		} catch (CommsProcessException ex){
			Assert.fail(ex.getMessage());
		}
	}

}

