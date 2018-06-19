package com.oxygenxml.pdf.distribution.test;


import java.io.File;
import java.util.Arrays;
import java.util.Comparator;

import org.junit.Test;

import junit.framework.TestCase;

/**
 * Test to check the distribution for CSS PDF plugin.
 * 
 * @author radu_pisoi
 */
public class DistributionTest extends TestCase {
	
	@Test
	public void testDistributionFiles() {
		File distDir = new File("target/distribution-test");
		assertTrue("Distribution dir should exist: " + distDir, distDir.exists());
		File[] allFiles = distDir.listFiles();
		
		assertEquals("There should be 1 file", 1, allFiles.length);		
		assertEquals("com.oxygenxml.pdf.css", allFiles[0].getName());
		
		// Verify files from root folder
		assertTrue(
				"Verify root files.", 
				dumpDir(allFiles[0]).contains(        
        "build.xml:[file]\n"  
        ));
    assertTrue(
        "Verify root files.", 
        dumpDir(allFiles[0]).contains(        
        "plugin.xml:[file]\n"
        ));
    assertTrue(
        "Verify root files.", 
        dumpDir(allFiles[0]).contains(        
        "integrator.xml:[file]\n"
        ));
		
		// Verify lib folder
		File lib = new File(allFiles[0], "lib");
		String dump = dumpDir(lib);
    assertTrue(
				"Lib folder should contain the oxygen publishing template jar, but was:" + dump,
				dump.contains("oxygen-publishing-template"));
    
    // Verify folders that should not exist in the distribution:
    assertTrue(!new File(allFiles[0], "test").exists());
    assertTrue(!new File(allFiles[0], ".settings").exists());
    
	}
	
	/**
	 * Dump dir files.
	 * 
	 * @param dir The dir to dump.
	 * @return A dump with direct files.
	 */
	private String dumpDir(File dir) {
		File[] files = dir.listFiles();
		Arrays.sort(files, new Comparator<File>() {
			@Override
			public int compare(File f1, File f2) {
				if ((f1.isFile() && f2.isFile()) || (f1.isDirectory() && f2.isDirectory())) {
					return f1.getName().compareTo(f2.getName());
				} else {
					if (f1.isDirectory()) {
						return -1;
					} else {
						return 1;
					}
				}
			}
		});
		
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < files.length; i++) {
			sb.append(files[i].getName()).append(":").append(files[i].isDirectory() ? "[dir]" : "[file]") .append("\n");
		}
		
		return sb.toString();
	}
}
