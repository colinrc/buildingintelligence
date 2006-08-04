package au.com.BI.Util;

import au.com.BI.AV.AV;
import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.CustomConnect.CustomConnect;
import au.com.BI.Device.DeviceType;
import junit.framework.TestCase;

public class TestBaseModel extends TestCase {

	BaseModel testModel = null;
	
	protected void setUp() throws Exception {
		super.setUp();
		testModel = new BaseModel();
		testModel.setName("Test model");
	}
	
	/*
	 * Test method for 'au.com.BI.Util.BaseModel.formatKey(String)'
	 */
	public void testFormatKeyHexHex2Padding() {
		testModel.setConfigKeysInDecimal(false);
		testModel.setDeviceKeysDecimal(false);
		testModel.setPadding(2);
		String result = testModel.formatKey("a",null);
		assertEquals ("Format Key Hex Hex 2 padding failed","0A",result);
	}

	public void testFormatKeyHexHex1Padding() {
		testModel.setConfigKeysInDecimal(false);
		testModel.setDeviceKeysDecimal(false);
		testModel.setPadding(1);
		String result = testModel.formatKey("a",null);
		assertEquals ("Format Key Hex Hex 1 padding failed","A",result);
	}


	public void testFormatKeyDecHex2Padding() {
		testModel.setConfigKeysInDecimal(true);
		testModel.setDeviceKeysDecimal(false);
		testModel.setPadding(2);
		String result = testModel.formatKey("10",null);
		assertEquals ("Format Key Dec Hex 2 padding failed","0A",result);
	}

	public void testFormatKeyDecDec3Padding() {
		testModel.setConfigKeysInDecimal(true);
		testModel.setDeviceKeysDecimal(true);
		testModel.setPadding(3);
		String result = testModel.formatKey("16",null);
		assertEquals ("Format Key Dec Hex 2 padding failed","016",result);
	}
	
	public void testCustomCommandString () {
			CustomConnect connection = new CustomConnect();
			connection.setName("Test Connection");
			connection.setDeviceType(DeviceType.CUSTOM_CONNECT);
			connection.setKey("1");
			connection.setOutputKey("TEST_CONNECTION");
			connection.addCondition("pure_string","","Test_pure");
			connection.addCondition("replace_command_extra","", "Test_commandExtra_%COMMAND.EXTRA%");
			connection.addCondition("replace_command_extra2","up", "Test_commandExtra_%COMMAND.EXTRA2% up");
			connection.addCondition("replace_command_extra2","down", "Test_commandExtra_%COMMAND.EXTRA2% down");
			connection.addCondition("replace_command_extra3", "","Test_commandExtra_%COMMAND.EXTRA3%");
			connection.addCondition("replace_command_extra_extra4","", "Test_commandExtra_%COMMAND.EXTRA% %COMMAND.EXTRA4%_Fin");
			
			runCustomCommandString(connection, "pure_string", "extraVal" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val", "Test_pure");
			runCustomCommandString(connection, "replace_command_extra", "extraVal" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "Test_commandExtra_extraVal");
			runCustomCommandString(connection, "replace_command_extra2", "up" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "Test_commandExtra_extra2Val up");
			runCustomCommandString(connection, "replace_command_extra2", "down" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "Test_commandExtra_extra2Val down");
			runCustomCommandString(connection, "replace_command_extra3", "extraVal" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "Test_commandExtra_extra3Val");
			runCustomCommandString(connection, "replace_command_extra_extra4", "extraVal" , "extra2Val" , "extra3Val" ,"extra4Val","extra5Val",  "Test_commandExtra_extraVal extra4Val_Fin");
	}
	
	public void runCustomCommandString(CustomConnect connection, String commandCode, String extra, String extra2, String extra3, String extra4, String extra5,  String expected) {
			CommandInterface command = new Command();
			command.setCommand(commandCode);
			command.setDisplayName("TEST_CONNECTION");
			command.setExtraInfo(extra);
			command.setExtra2Info(extra2);
			command.setExtra3Info(extra3);
			command.setExtra4Info(extra4);
			command.setExtra5Info(extra5);
			String result = testModel.doCustomConnectIfPresent(command,  connection);
			assertEquals("Custom Connection failed " ,  expected, result);
	}

}
