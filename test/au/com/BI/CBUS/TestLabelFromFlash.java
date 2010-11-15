package au.com.BI.CBUS;


import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;

import au.com.BI.Flash.ClientCommand;
import au.com.BI.Label.Label;
import au.com.BI.LabelMgr.LabelMgr;
import au.com.BI.CBUS.Model;
import au.com.BI.Device.DeviceType;

/**
 * @author colin
 *
 */
public class TestLabelFromFlash {
	protected Label testLabel;
	protected Label testLabel2;
	private Model model = null;
	
	@Before
	public void setUp() {

		model = new Model();
		LabelMgr labelMgr = new LabelMgr();
		model.setLabelMgr(labelMgr);
		testLabel = new Label( "Test", DeviceType.LABEL );
		testLabel.setApplicationCode("38");
		testLabel.setDefaultLabel("VOLUME");
		testLabel.setKey("22");
		
		testLabel2 = new Label( "Volume Test", DeviceType.LABEL );
		testLabel2.setApplicationCode("38");
		testLabel2.setDefaultLabel("VOLUME");
		testLabel2.setKey("23");
		
		labelMgr.addLabel("Test", "Testt");
		labelMgr.addLabel("FRONT_LIGHT", "Front Light");
		labelMgr.addLabel("VOLUME_CONTROL", "Volume Level");
		labelMgr.addLabel("SPRINKLERS","Sprinklers");
	}

	@Test
	public void testBuildCBUSLabelString() {
		ClientCommand testCommand = new ClientCommand("VOLUME","label",null,"Test","","","","");
		String expectedOut = "\\05"+"3800A81600015465737474F0g\r";
		String val = model.buildCBUSLabelString(testLabel, testCommand, "g");
		assertEquals ("Return value for label failed",expectedOut,val);
		//Volume Level
		//\053800AF170001566F6C756D65204C6576656C6Ci 
	}


	@Test
	public void testBuildCBUSLabelStringVolume () {
		ClientCommand testCommand = new ClientCommand("VOLUME","label",null,"VOLUME_CONTROL","","","","");
		String expectedOut = "\\05"+"3800AF170001566F6C756D65204C6576656C6Ci\r";
		String val = model.buildCBUSLabelString(testLabel2, testCommand, "i");
		assertEquals ("Return value for volume label failed",expectedOut,val);
	}
}
