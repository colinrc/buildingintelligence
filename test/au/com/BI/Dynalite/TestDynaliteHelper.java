package au.com.BI.Dynalite;

import au.com.BI.Dynalite.DynaliteHelper;
import junit.framework.TestCase;


public class TestDynaliteHelper extends TestCase {

	byte items[];
	byte retItems[];
	private DynaliteHelper dynaliteHelper = null;
	
	public TestDynaliteHelper(String arg0) {
		super(arg0);
	}

	protected void setUp() throws Exception {
		super.setUp();
		retItems = new byte[] {0x1c,01,0x20,0,0,0,(byte)0xff,(byte)0xc4};
		
		dynaliteHelper = new DynaliteHelper();
	}

	protected void tearDown() throws Exception {
		super.tearDown();
		items = null;
	}

	/*
	 * Test method for 'au.com.BI.Dynalite.Model.addChecksum(byte[])'
	 */
	public void testAddChecksum() {
			// 1c 01 20 00 00 00 ff = c4
		items = new byte[] {0x1c,01,0x20,0,0,0,(byte)0xff,0};
		dynaliteHelper.addChecksum(items);
		assertEquals("Checksum calculation failed",(byte)0xc4,items[7]);

		items = new byte[] {0x1c,02,2,0x72,(byte)0x82,0x32,(byte)0xff,0};
		dynaliteHelper.addChecksum(items);
		assertEquals ("Checksum calculation failed",(byte)0xbb,items[7]);

		/* 
		items = new byte[]{(byte)0x1C,04,(byte)0x80,0x20,0x0,0,(byte)0xff,(byte)0x0};
		dynaliteHelper.addChecksum(items);
		assertEquals ("Checksum calculation failed",(byte)0xc0,items[7]);
		Example from area link area in pdf file, possibly incorrect.
		*/
	}


	/*
	 * Test method for 'au.com.BI.Dynalite.Model.passChecksum(String)'
	 */
	public void testPassChecksum() {
		assertEquals ("Checksum test failed",dynaliteHelper.passChecksum(retItems),true);
		retItems[7] =1;
		assertEquals ("Checksum test failed",dynaliteHelper.passChecksum(retItems),false);		
	}



	/*
	 * Test method for 'au.com.BI.Dynalite.DynaliteHelper.scaleLevelForFlash(int)'
	 */
	public void testScaleLevelForFlash() {
		assertEquals ("Scale level for flash failed, level 1 ",dynaliteHelper.scaleLevelForFlash((byte)1),100);		
		assertEquals ("Scale level for flash failed, level 255 ",dynaliteHelper.scaleLevelForFlash((byte)255),0);
		assertEquals ("Scale level for flash failed, level 130 ",dynaliteHelper.scaleLevelForFlash((byte)0x82),50);			
		assertEquals ("Scale level for flash failed, level 58 ",dynaliteHelper.scaleLevelForFlash((byte)0x6e),58);			
		assertEquals ("Scale level for flash failed, level 10 ",dynaliteHelper.scaleLevelForFlash((byte)0xe6),10);			
	}

	/*
	 * Test method for 'au.com.BI.Dynalite.DynaliteHelper.scaleLevelFromFlash(String)'
	 */
	public void testScaleLevelFromFlash() {
		assertEquals ("Scale level from flash failed, level 0 ",dynaliteHelper.scaleLevelFromFlash("0"),255);		
		assertEquals ("Scale level from flash failed, level 100 ",dynaliteHelper.scaleLevelFromFlash("100"),1);		
		assertEquals ("Scale level from flash failed, level 50 ",dynaliteHelper.scaleLevelFromFlash("50"),0x82);		
		assertEquals ("Scale level from flash failed, level 58 ",dynaliteHelper.scaleLevelFromFlash("58"),0x6e);		
		assertEquals ("Scale level from flash failed, level 10 ",dynaliteHelper.scaleLevelFromFlash("10"),0xe6);		
	}
}
