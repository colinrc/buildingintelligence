/*
 * InterpretResultTest.java
 * JUnit based test
 *
 * Created on March 19, 2006, 2:41 PM
 */

package au.com.BI.Dynalite;

import junit.framework.*;
import java.util.LinkedList;
import java.util.List;

/**
 *
 * @author colinc
 */
public class InterpretResultTest extends TestCase {
    
    public InterpretResultTest(String testName) {
        super(testName);
    }

    protected void setUp() throws Exception {
    }

    protected void tearDown() throws Exception {
    }

    public static Test suite() {
        TestSuite suite = new TestSuite(InterpretResultTest.class);
        
        return suite;
    }

    /**
     * Test of getFullKey method, of class au.com.BI.Dynalite.InterpretResult.
     */
    public void testGetFullKey() {
        System.out.println("getFullKey");
        
        InterpretResult instance = new InterpretResult();
        
        String expResult = "";
        String result = instance.getFullKey();
        assertEquals(expResult, result);
        
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    /**
     * Test of setFullKey method, of class au.com.BI.Dynalite.InterpretResult.
     */
    public void testSetFullKey() {
        System.out.println("setFullKey");
        
        String fullKey = "";
        InterpretResult instance = new InterpretResult();
        
        instance.setFullKey(fullKey);
        
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }
    
}
