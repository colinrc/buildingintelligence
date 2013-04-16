package au.com.BI.Pelco;

import au.com.BI.Flash.ClientCommand;
import au.com.BI.Util.MessageDirection;
import au.com.BI.Camera.*;
import au.com.BI.Device.DeviceType;
import junitx.framework.ArrayAssert;

import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;

public class TestPelcoModelProtocolD {
	private Model model = null;
	Camera cameraFrontCamera01 = null;
	Camera cameraFrontCamera10 = null;
	Camera cameraFrontCamera02 = null;
	
	@Before
	public void setUp() throws Exception {

		model = new Model();
		model.setProtocol("D");
		
        // <CAMERA ACTIVE="Y" KEY="1" DISPLAY_NAME="FRONT_CAMERA"/>
		cameraFrontCamera01 = new Camera ("Front Camera",DeviceType.CAMERA);
		cameraFrontCamera01.setKey("1");
		cameraFrontCamera01.setOutputKey("FRONT_CAMERA");
	
		cameraFrontCamera02 = new Camera ("Side Camera",DeviceType.CAMERA);
		cameraFrontCamera02.setKey("02");
		cameraFrontCamera02.setOutputKey("SIDE_CAMERA");
		
		cameraFrontCamera10 = new Camera ("Back Camera",DeviceType.CAMERA);
		cameraFrontCamera10.setKey("0a");
		cameraFrontCamera10.setOutputKey("BACK_CAMERA");
		
		model.addControlledItem("FRONT_CAMERA",cameraFrontCamera01,MessageDirection.FROM_FLASH);
		model.addControlledItem("SIDE_CAMERA",cameraFrontCamera02,MessageDirection.FROM_FLASH);
		model.addControlledItem("BACK_CAMERA",cameraFrontCamera10,MessageDirection.FROM_FLASH);
	}

	@Test
	public void testAddCheckSum() {
		PelcoOutput pelcoOutput = new PelcoOutput ();
		pelcoOutput.outputCodes[0] = (byte)0xff;
		pelcoOutput.outputCodes[1] = (byte)0x0a;
		pelcoOutput.outputCodes[2] = (byte)0x88;
		pelcoOutput.outputCodes[3] = (byte)0x90;
		pelcoOutput.outputCodes[4] = (byte)0x20;
		pelcoOutput.outputCodes[5] = (byte)0x00;
		model.addCheckSum(pelcoOutput);
		assertEquals ("Checksum failed",0x42,pelcoOutput.outputCodes[6]);
	}
	
	@Test
	public void testBuildCameraArray_on() {
		ClientCommand testCommand = new ClientCommand("FRONT_CAMERA","on",null,"manual","","","","");
		byte expectedOut[] = new byte[]{(byte)0xFF, (byte)0x01, (byte)0x88, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x89};
		PelcoOutput vals = model.buildCameraArray(cameraFrontCamera01,testCommand);
		ArrayAssert.assertEquals ("Return value for camera on failed",expectedOut,vals.outputCodes);
	}

	@Test
	public void testBuildCameraArray_off() {
		ClientCommand testCommand = new ClientCommand("FRONT_CAMERA","off",null,"","","","","");
		byte expectedOut[] = new byte[]{(byte)0xFF, (byte)0x01, (byte)0x08, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x09};
		PelcoOutput vals = model.buildCameraArray(cameraFrontCamera01,testCommand);
		ArrayAssert.assertEquals ("Return value for camera off failed",expectedOut,vals.outputCodes);
	}
	
	@Test
	public void testBuildCameraArray_pan_left() {
		ClientCommand testCommand = new ClientCommand("SIDE_CAMERA","pan",null,"left","32","","","");
		byte expectedOut[] = new byte[]{(byte)0xFF, (byte)0x02, (byte)0x00, (byte)0x04, (byte)0x20, (byte)0x00, (byte)0x26};
		PelcoOutput vals = model.buildCameraArray(cameraFrontCamera02,testCommand);
		ArrayAssert.assertEquals ("Return value for camera pan left failed",expectedOut,vals.outputCodes);
	}
	
	@Test
	public void testBuildCameraArray_pan_abs() {
		ClientCommand testCommand = new ClientCommand("SIDE_CAMERA","pan",null,"4097","","","","");
		byte expectedOut[] = new byte[]{(byte)0xFF, (byte)0x02, (byte)0x0, (byte)0x4b, (byte)0x10, (byte)0x01, (byte)0x5e};
		PelcoOutput vals = model.buildCameraArray(cameraFrontCamera02,testCommand);
		ArrayAssert.assertEquals ("Return value for camera pan left failed",expectedOut,vals.outputCodes);
	}

	@Test
	public void testBuildCameraArray_tilt_abs() {
		ClientCommand testCommand = new ClientCommand("SIDE_CAMERA","tilt",null,"4096","","","","");
		byte expectedOut[] = new byte[]{(byte)0xFF, (byte)0x02, (byte)0x0, (byte)0x4d, (byte)0x10, (byte)0x00, (byte)0x5f};
		PelcoOutput vals = model.buildCameraArray(cameraFrontCamera02,testCommand);
		ArrayAssert.assertEquals ("Return value for camera pan left failed",expectedOut,vals.outputCodes);
	}

	@Test
	public void testBuildCameraArray_on_tilt_focus() {
		ClientCommand onCommand = new ClientCommand("BACK_CAMERA","on",null,"manual","","","","");
		ClientCommand focusCommand = new ClientCommand("BACK_CAMERA","focus",null,"far","","","","");
		ClientCommand tiltCommand = new ClientCommand("BACK_CAMERA","tilt",null,"down","","","","");
		PelcoOutput vals1 = model.buildCameraArray(cameraFrontCamera10,onCommand);
		PelcoOutput vals2 = model.buildCameraArray(cameraFrontCamera10,focusCommand);
		PelcoOutput vals3 = model.buildCameraArray(cameraFrontCamera10,tiltCommand);
		byte expectedOut[] = new byte[]{(byte)0xFF, (byte)0x0a, (byte)0x0, (byte)0x90, (byte)0x00, (byte)0x00, (byte)-102};
		ArrayAssert.assertEquals ("Return value for on,focus,tilt failed",expectedOut,vals3.outputCodes);
	}
	
}
