package au.com.BI.Command;

public interface CacheListener {
	public void addToCommandQueue (String key, CacheWrapper cacheWrapper);
}
