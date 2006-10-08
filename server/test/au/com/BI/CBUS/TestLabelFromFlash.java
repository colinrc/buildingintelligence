/**
 * 
 */
package au.com.BI.CBUS;

import java.util.HashMap;

import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Device.DeviceType;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.Label.Label;
import au.com.BI.CBUS.Model;
import au.com.BI.Util.DeviceModel;
import junit.framework.TestCase;
import junitx.framework.ArrayAssert;

/**
 * @author colin
 *
 */
public class TestLabelFromFlash extends TestCase {
	protected Label testLabel;
	private Model model = null;
	
	public static void main(String[] args) {
		junit.swingui.TestRunner.run(TestLabelFromFlash.class);
	}
	
	/* (non-Javadoc)
	 * @see junit.framework.TestCase#setUp()
	 */
	protected void setUp() throws Exception {
		super.setUp();
		model = new Model();
		
		testLabel = new Label( "Volume Test", DeviceType.LABEL );
		testLabel.setApplicationCode("38");
		testLabel.setDefaultLabel("VOLUME");
		testLabel.setKey("22");
		
		HashMap<String, String> map = new HashMap<String,String> (40);
		map.put("Test", "Testt");
		map.put("FRONT_LIGHT", "Front Light");
		map.put("VOLUME_CONTROL", "Volume Level");
		map.put("SPRINKLERS","Sprinklers");
		
		model.setCatalogueDefs("Button Labels",map);
		model.setParameter("LABELS", "Button Labels", DeviceModel.MAIN_DEVICE_GROUP);

		
	}

	/**
	 * Test method for {@link au.com.BI.CBUS.Model#buildCBUSLabelString(au.com.BI.Label.Label, au.com.BI.Command.CommandInterface, java.lang.String)}.
	 */
	public void testBuildCBUSLabelString() {
		ClientCommand testCommand = new ClientCommand("VOLUME","label",null,"Test","","","","");
		String expectedOut = '\05'+"3800A81600015465737474F0g";
		String val = model.buildCBUSLabelString(testLabel, testCommand, "g");
		assertEquals ("Return value for label failed",expectedOut,val);
	}

}
