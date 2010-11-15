/*
 * InterpretResultTest.java
 * JUnit based test
 *
 * Created on March 19, 2006, 2:41 PM
 */

package au.com.BI.Dynalite;

import static org.junit.Assert.*;
//import org.junit.Before;
import org.junit.Test;


/**
 *
 * @author colinc
 */
public class InterpretResultTest {
    
    public InterpretResultTest() {
    }

    @Test
    public void testGetFullKey() {
        System.out.println("getFullKey");
        
        InterpretResult instance = new InterpretResult();
        
        String result = instance.getFullKey();
        
        fail("The test case is a prototype.");
    }

    @Test
    public void testSetFullKey() {
        System.out.println("setFullKey");
        
        String fullKey = "";
        InterpretResult instance = new InterpretResult();
        
        instance.setFullKey(fullKey);
        
        fail("The test case is a prototype.");
    }
    
}
