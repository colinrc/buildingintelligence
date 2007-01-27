/**
 * 
 */
package au.com.BI.Script;

/**
 * @author colin
 *
 */
public interface BIScript {
	boolean isAbleToRunMultiple ();
	boolean isStoppable ();
	String [] getFireOnChange();
}
