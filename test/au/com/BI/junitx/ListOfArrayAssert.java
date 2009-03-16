package au.com.BI.junitx;
import java.util.List;
import junitx.framework.Assert;
import junitx.framework.ArrayAssert;

public class ListOfArrayAssert {



/**
 * A set of assert methods specially targetted to asserting Lists of Arrays.
 * 
 */

    /**
     * Don't let anyone have access to this constructor.
     */
    private ListOfArrayAssert() {
    }

    /**
     * Asserts that two lists are equal (the order is not relevant). Throws an
     * <tt>AssertionFailedError</tt> if not.
     */
    public static void assertByteEquals(List expected, List actual) {
        assertByteEquals(null, expected, actual);
    }

    /**
     * Asserts that two lists are equal (the order is not relevant). Throws an
     * <tt>AssertionFailedError</tt> if not.
     */
    public static void assertByteEquals(String message, List expected, List actual) {
        if ((expected == null && actual == null) || (expected != null && expected.equals(actual))) {
            return;
        }

        for (int ii = 0; ii < expected.size(); ii++) {

            ArrayAssert.assertEquals(message, (byte[])actual.get(ii), (byte[])expected.get(ii));
        }
        String formatted = "[length]";
        if (message != null) {
            formatted = message + " " + formatted;
        }

        Assert.assertEquals(formatted, expected.size(), actual.size());
    }

}
