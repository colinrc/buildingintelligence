<P>Testing jsp  <jsp:getProperty name="mybean" 
        property="username" />


   // Read properties file.
    Properties properties = new Properties();
    try {
        properties.load(new FileInputStream("filename.properties"));
    } catch (IOException e) {
    }
    
    // Write properties file.
    try {
        properties.store(new FileOutputStream("filename.properties"), null);
    } catch (IOException e) {
    }