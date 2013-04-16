package au.com.BI.Dynalite;

import au.com.BI.Dynalite.DynaliteHelper;
import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.After;
import org.junit.Test;


public class TestDynaliteHelper {

	byte items[];
	byte retItems[];
	private DynaliteHelper dynaliteHelper = null;
	
	public TestDynaliteHelper() {
	}

	@Before
	public void setUp() {
		retItems = new byte[] {0x1c,01,0x20,0,0,0,(byte)0xff,(byte)0xc4};
		
		dynaliteHelper = new DynaliteHelper();
	}

	@After
	public void tearDown() {
		items = null;
	}

	@Test
	public void testAddChecksum() {
			// 1c 01 20 00 00 00 ff = c4
		items = new byte[] {0x1c,01,0x20,0,0,0,(byte)0xff,0};
		dynaliteHelper.addChecksum(items);
		assertEquals("Checksum calculation failed",(byte)0xc4,items[7]);

		items = new byte[] {0x1c,02,2,0x72,(byte)0x82,0x32,(byte)0xff,0};
		dynaliteHelper.addChecksum(items);
		assertEquals ("Checksum calculation failed",(byte)0xbb,items[7]);
	}

	@Test
	public void testPassChecksum() {
		assertEquals ("Checksum test failed",dynaliteHelper.passChecksum(retItems),true);
		retItems[7] =1;
		assertEquals ("Checksum test failed",dynaliteHelper.passChecksum(retItems),false);		
	}

	@Test
	public void testScaleLevelForFlash() {
		assertEquals ("Scale level for flash failed, level 1 ",dynaliteHelper.scaleLevelForFlash((byte)1),100);		
		assertEquals ("Scale level for flash failed, level 255 ",dynaliteHelper.scaleLevelForFlash((byte)255),0);
		assertEquals ("Scale level for flash failed, level 130 ",dynaliteHelper.scaleLevelForFlash((byte)0x82),50);			
		assertEquals ("Scale level for flash failed, level 58 ",dynaliteHelper.scaleLevelForFlash((byte)0x6e),58);			
		assertEquals ("Scale level for flash failed, level 10 ",dynaliteHelper.scaleLevelForFlash((byte)0xe6),10);			
	}

	@Test
	public void testScaleLevelFromFlash() {
		assertEquals ("Scale level from flash failed, level 0 ",dynaliteHelper.scaleLevelFromFlash("0"),255);		
		assertEquals ("Scale level from flash failed, level 100 ",dynaliteHelper.scaleLevelFromFlash("100"),1);		
		assertEquals ("Scale level from flash failed, level 50 ",dynaliteHelper.scaleLevelFromFlash("50"),0x82);		
		assertEquals ("Scale level from flash failed, level 58 ",dynaliteHelper.scaleLevelFromFlash("58"),0x6e);		
		assertEquals ("Scale level from flash failed, level 10 ",dynaliteHelper.scaleLevelFromFlash("10"),0xe6);		
	}
}
