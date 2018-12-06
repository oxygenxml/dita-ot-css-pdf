package com.oxygenxml.pdf.css;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.log4j.Logger;

import ro.sync.basic.io.IOUtil;
import ro.sync.basic.util.concurrent.CPULoadEstimator;

/**
 * Tests the post-process.xsl stylesheet.
 * 
 * @author dan
 *
 */
public class Merged2MergedTest extends BasicXSLTestCase {
  /**
   * Logger for logging.
   */
  private static final Logger logger = Logger.getLogger(Merged2MergedTest.class.getName());


  @Override
  public void setUp() throws Exception {
    super.setUp();
  }
  
  @Override
  public void tearDown() throws Exception {
    super.tearDown();
  }
  
  /**
   * Constructor.
   * 
   * @param name
   * @throws TransformerFactoryConfigurationError 
   * @throws TransformerConfigurationException 
   */
  public Merged2MergedTest(String name) throws TransformerConfigurationException, TransformerFactoryConfigurationError {
    super(name);
    style = new File("xsl/merged2merged/merged.xsl");
    style2 = new File("xsl/review/review-group-replies.xsl");
    dir = new File("test/merged2merged");   
//    doNotFailUpdateTests = true;
  }

  
  /**
   * <p><b>Description:</b> DESCRIBE THE TEST HERE!!</p>
   * <p><b>Bug ID:</b> EXM-</p>
   *
   * @author dan
   *
   * @throws Exception
   */
  public void testProcessing() throws Exception {
    runTestInURLClassLoader("tProcessing", new URL[] {new File("xsl/merged2merged/java").toURI().toURL()});    
  }
  

  /**
   * Gives a chance of setting parameters to the transformer. You can 
   * use this to also set different parameters depending on the input file.
   * 
   * @param transformer The trasformer to set up parameters on.
   * @param inputFile The input file of the XSLT tranformation. 
   * @param mapFile The main map file. 
   * @throws MalformedURLException Should not happen.
   */
  protected void setUpParameters(Transformer transformer, File inputFile, File mapFile) throws MalformedURLException {
    transformer.setParameter("input.dir.url", mapFile.getParentFile().toURI().toURL().toString() + "/");
    transformer.setParameter("show.changes.and.comments", "yes");
    
    if (inputFile.getName().startsWith("args.draft.yes")){      
      transformer.setParameter("args.draft", "yes");
    }
    if (inputFile.getName().startsWith("figure-title-placement-bottom")){      
      transformer.setParameter("figure.title.placement", "bottom");
    }

  }

  /**
   * <p><b>Description:</b> Testcase for the performance of the post processing.</p>
   * <p><b>Bug ID:</b> CH-205</p>
   *
   * @author dan
   *
   * @throws Exception
   */
  public void testUserGuideTransformTime() throws Exception {
    runTestInURLClassLoader("tUserGuideTransformTime", new URL[] {new File("xsl/merged2merged/java").toURI().toURL()});    
  }
  

  /**
   * The real test, run in the Oxygen class loader.
   * 
   * @throws Exception
   */
  public void tUserGuideTransformTime() throws Exception{

    TransformerFactory transformerFactory = TransformerFactory.newInstance("net.sf.saxon.TransformerFactoryImpl", getClass().getClassLoader()); 
    transformerFactory.setURIResolver(getDitaCatalogResolver());
    
    File style = new File("xsl/merged2merged/merged.xsl");
    File inputFile = new File(dir, "large-file/file.in.xml").getAbsoluteFile();
    File outputFile = new File(dir, "large-file/file.out.xml").getAbsoluteFile();
    outputFile.delete();
    
    
    Transformer transformer = transformerFactory.newTransformer(new StreamSource(style));      
    setUpParameters(transformer, inputFile, new File("large-file/file.ditamap"));
    
    Source xmlSource = new StreamSource(inputFile);
        
    StreamResult outputTarget = new StreamResult(outputFile);
    
    logger.info("Starting transformation.");    

    CPULoadEstimator le = new CPULoadEstimator();
    double weightingFactor = le.getWeightingFactor();
        
    long t0 = System.currentTimeMillis();
    transformer.transform(xmlSource, outputTarget);
    long t1 = System.currentTimeMillis();    
    long delta = t1 - t0;
    
    logger.info("Ending transformation after: " + delta + "ms ");    
    // In mod normal pe windows ia cam 35s, testat pe data de 12 Apr 2018
    double expected = 50000 * 2 * weightingFactor;
    assertTrue ("Transformation took too long: "  + delta + "ms expected: " + expected, delta < expected);
    
    String content = IOUtil.readFile(outputFile, "UTF-8");
    assertTrue("There should be highling elements ", content.contains("<oxy:oxy-color-hl"));
    assertTrue("There should be comment elements ", content.contains("<oxy:oxy-comment"));
    assertTrue("There should be insert elements ", content.contains("<oxy:oxy-insert"));
    assertTrue(outputFile.delete());
  }   

  
}
