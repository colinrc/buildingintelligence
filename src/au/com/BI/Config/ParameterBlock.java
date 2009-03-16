package au.com.BI.Config;

public class ParameterBlock {
	String catalogName;
	String group;
	String verboseName;
	
	public ParameterBlock (){
	}
	
	public ParameterBlock (String catalogName,String group,String verboseName){
		this.setCatalogName(catalogName);
		this.setGroup(group);
		this.setVerboseName(verboseName);
	}
	
	public String getCatalogName() {
		return catalogName;
	}
	public void setCatalogName(String catalogName) {
		this.catalogName = catalogName;
	}
	public String getGroup() {
		return group;
	}
	public void setGroup(String group) {
		this.group = group;
	}
	public String getVerboseName() {
		return verboseName;
	}
	public void setVerboseName(String verboseName) {
		this.verboseName = verboseName;
	}
}
