package au.com.BI.Script;

import junit.framework.TestCase;
import java.util.*;

public class TestScriptHandler extends TestCase {
	Model scriptModel = null;
	ScriptHandler sciptHandler = null;
	Map scriptRunBlockList = null;

	protected void setUp() throws Exception {
		super.setUp();
		Model scriptModel = new Model();
		scriptModel.loadScripts();
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
		// TODO Auto-generated method stub

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.saveScriptFile()'
	 */
	public void testSaveScriptFile() {
		// TODO Auto-generated method stub

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.setStatus(String, String)'
	 */
	public void testSetStatus() {
		// TODO Auto-generated method stub
		scriptModel.getScriptHandler().setStatus("test","HIDDEN,OTHER,SOME");
		scriptModel.loadScripts();
		ScriptRunBlock scriptRunBlock = (ScriptRunBlock)scriptRunBlockList.get("test");
		assertEquals("HIDDEN,OTHER,SOME",scriptRunBlock.getStatusString());

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.setScriptEnable(String, User, boolean)'
	 */
	public void testSetScriptEnable() {
		// TODO Auto-generated method stub

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.isScriptStillRunning(String)'
	 */
	public void testIsScriptStillRunning() {
		// TODO Auto-generated method stub

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.buildListElement(String)'
	 */
	public void testBuildListElement() {
		// TODO Auto-generated method stub

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.parseElement(Element)'
	 */
	public void testParseElement() {
		// TODO Auto-generated method stub

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.isScriptRunning(String)'
	 */
	public void testIsScriptRunning() {
		// TODO Auto-generated method stub

	}

}
