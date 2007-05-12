package XMLloaders {
  
  import flash.events.Event;
  import flash.events.ErrorEvent;
  import flash.events.EventDispatcher;
  import flash.events.IEventDispatcher;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.utils.flash_proxy;
  import flash.utils.Proxy;
  import flash.utils.trace;
  
  
  
  dynamic public class XLoader extends Proxy implements IEventDispatcher {
  
    static private var instance:XLoader;
    private var eventDispatcher:EventDispatcher;
    private var urlLoader:URLLoader;
    public var data:XML;
    static public var URL:String = "";
    
    
    public function XLoader() {
      eventDispatcher = new EventDispatcher();
      var urlRequest:URLRequest = new URLRequest(XLoader.URL);
      urlLoader = new URLLoader();
      urlLoader.addEventListener("complete", onXMLDataLoaded)
      urlLoader.addEventListener("ioerror", onXMLDataFailed)
      urlLoader.load(urlRequest);
    }
    
    public function setURLandLoad(url:String):void {
    	data = null;
    	XLoader.URL = url;
    	var urlRequest:URLRequest = new URLRequest(XLoader.URL);
    	urlLoader.load(urlRequest);
    }
    
    private function onXMLDataLoaded(event:Event):void {
      data = XML(urlLoader.data);
      dispatchEvent(new Event("onInit", true, true));
    }
    
    private function onXMLDataFailed(errorEvent:ErrorEvent):void {
      trace(errorEvent);
    }
    
    
    static public function getInstance():XLoader {
      if(instance == null) {
        instance = new XLoader();
      }
      return instance;
    }
    
    
     flash_proxy override function getProperty(name:*):* {
      var cs:Namespace = data.namespace("");
      return data.cs::properties.cs::property.(@id = name).@value;
     }
    
    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
      eventDispatcher.addEventListener(type, listener, useCapture, priority);
    }
    
    public function dispatchEvent(event:Event):Boolean {
      return eventDispatcher.dispatchEvent(event);
    }
    
    public function hasEventListener(type:String):Boolean {
      return eventDispatcher.hasEventListener(type);
    }
    
    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
      eventDispatcher.removeEventListener(type, listener, useCapture);
    }
    
    public function willTrigger(type:String):Boolean {
      return eventDispatcher.willTrigger(type);
    }
    
  }
  
}