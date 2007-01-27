/**
 * 
 */
package au.com.BI.GroovyScripts;

/**
 * @author colin
 *
 */
public interface BIScript {
	boolean isAbleToRunMultiple ();
	boolean isStoppable ();
	String [] getFireOnChange();
}
