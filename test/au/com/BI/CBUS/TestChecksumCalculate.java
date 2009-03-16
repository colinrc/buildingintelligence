/**
 * 
 */
package au.com.BI.CBUS;

import junit.framework.TestCase;

/**
 * @author colin
 *
 */
public class TestChecksumCalculate extends TestCase {
	private Model model = null;
	
	protected void setUp() throws Exception {
		super.setUp();
		model = new Model();
	}
	
	/**
	 * Test method for {@link au.com.BI.CBUS.Model#calcChecksum(java.lang.String)}.
	 */
	public void testCalcChecksumString() {
		assertEquals ("Checksum Failed",model.calcChecksum("A3410069"),	"B3");
	}

	public void test2CalcChecksumString() {
		assertEquals ("Checksum Failed",model.calcChecksum("0538007920"),	"2A");
	}
	
	public void test3CalcChecksumString() {
		assertEquals ("Checksum Failed",model.calcChecksum("0538007988"),	"C2");
	}
	
}
