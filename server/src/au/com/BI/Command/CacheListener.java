package au.com.BI.Command;

public interface CacheListener {
	public void addToCommandQueue (String key, CacheWrapper cacheWrapper);
	public void addToCommandQueue (String key , CommandInterface command, long targetID, boolean isSet);
}
