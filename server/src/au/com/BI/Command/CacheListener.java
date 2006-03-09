package au.com.BI.Command;

public interface CacheListener {
	public void cacheUpdated (String key, CacheWrapper cacheWrapper);
}
