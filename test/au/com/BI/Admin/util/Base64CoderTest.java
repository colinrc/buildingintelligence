/*
 * Base64CoderTest.java
 * JUnit based test
 *
 * Created on April 23, 2006, 10:01 AM
 */

package au.com.BI.Admin.util;

import junit.framework.*;

/**
 *
 * @author colin
 */
public class Base64CoderTest extends TestCase {
    
    public Base64CoderTest(String testName) {
	super(testName);
    }

	protected void setUp() throws Exception {
	}

	protected void tearDown() throws Exception {
	}

	public static Test suite() {
		TestSuite suite = new TestSuite(Base64CoderTest.class);
		
		return suite;
	}

	/**
	 * Test of encode method, of class au.com.BI.Admin.util.Base64Coder.
	 */
	public void testEncode() {
		System.out.println("encode");
		
		String s = "";
		
		String expResult = "";
		String result = Base64Coder.encode(s);
		assertEquals(expResult, result);
		
		// TODO review the generated test code and remove the default call to fail.
		fail("The test case is a prototype.");
	}

	/**
	 * Test of decode method, of class au.com.BI.Admin.util.Base64Coder.
	 */
	public void testDecode() {
		System.out.println("decode");
		
		String s = "";
		
		String expResult = "";
		String result = Base64Coder.decode(s);
		assertEquals(expResult, result);
		
		// TODO review the generated test code and remove the default call to fail.
		fail("The test case is a prototype.");
	}
    
}
