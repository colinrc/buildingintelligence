package au.com.BI.Script;

import junit.framework.TestCase;
import java.util.*;

public class TestScriptHandler extends TestCase {
	Model scriptModel = null;
	ScriptHandler sciptHandler = null;
	Map scriptRunBlockList = null;

	protected void setUp() throws Exception {
		super.setUp();
		scriptModel = new Model();
		scriptModel.loadJythonScripts();
		sciptHandler = scriptModel.getScriptHandler();
		scriptRunBlockList = scriptModel.scriptRunBlockList;
	}

	protected void tearDown() throws Exception {
		super.tearDown();
	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.loadScriptFile()'
	 */
	public void testLoadScriptFile() {
		// 

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.saveScriptFile()'
	 */
	public void testSaveScriptFile() {
		// 

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.setStatus(String, String)'
	 */
	public void testSetStatus() {
		// 
		scriptModel.getScriptHandler().setStatus("test","HIDDEN,OTHER,SOME");
		scriptModel.loadJythonScripts();
		ScriptRunBlock scriptRunBlock = (ScriptRunBlock)scriptRunBlockList.get("test");
		assertEquals("HIDDEN,OTHER,SOME",scriptRunBlock.getStatusString());

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.setScriptEnable(String, User, boolean)'
	 */
	public void testSetScriptEnable() {
		// 

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.isScriptStillRunning(String)'
	 */
	public void testIsScriptStillRunning() {
		// 

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.buildListElement(String)'
	 */
	public void testBuildListElement() {
		// 

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.parseElement(Element)'
	 */
	public void testParseElement() {
		// 

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.isScriptRunning(String)'
	 */
	public void testIsScriptRunning() {
		// 

	}

}
