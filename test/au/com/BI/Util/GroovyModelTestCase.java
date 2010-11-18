/**
 * 
 */
package au.com.BI.Util;

import java.util.LinkedList;
import java.util.List;

import au.com.BI.GroovyModels.GroovyModel;
import au.com.BI.GroovyModels.Model;
import au.com.BI.Home.VersionManager;
import static junit.framework.Assert.*;

/**
 * @author colin
 *
 */
public class GroovyModelTestCase {
	
	protected Model groovyModelHandler = null;
	protected GroovyModel model = null;
	protected String modelToTest = "SET";

	protected void setUp() throws Exception {

		// Include this block to set up a groovy model test
		groovyModelHandler = new au.com.BI.GroovyModels.Model();
		List <DeviceModel>groovyModels = new LinkedList <DeviceModel>();
		VersionManager versionManager = new VersionManager();
		groovyModelHandler.setVersionManager(versionManager);
		groovyModelHandler.loadGroovyModels( groovyModels);
		String modelToTest = this.getModelToTest();
		if (modelToTest.equals ("SET")){
			fail("Set the model name you wish to test");
		}
		
		model = groovyModelHandler.setupGroovyModel(modelToTest, "Test Model");
	}

	public String getModelToTest() {
		return modelToTest;
	}

	public void setModelToTest(String modelToTest) {
		this.modelToTest = modelToTest;
	}
}
