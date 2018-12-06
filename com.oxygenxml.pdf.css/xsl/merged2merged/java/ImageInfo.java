import java.io.IOException;
import java.net.URL;
import java.util.Iterator;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;

/**
 * Extracts the size from an image. The image is identified by an URI.
 * Does not read the entire image, just the headers.
 *  
 * @author dan
 */
public class ImageInfo {
 
  /**
   * Get the image size.
   * 
   * @param uri The systemId of the image.
   * @return A formatted string containing the width and the height, 
   * separated by a comma. If the image could not be read, the returned 
   * string is "-1,-1".
   */
  public static String getImageSize(String uri) {
    int width = -1;
    int height = -1;
    try {
      
      URL url = new URL(uri);

      ImageInputStream imageInputStream = ImageIO.createImageInputStream(url.openConnection().getInputStream());
      Iterator<ImageReader> iter = ImageIO.getImageReaders(imageInputStream);
      if (iter.hasNext()) {
        ImageReader reader = iter.next();
        try {
          reader.setInput(imageInputStream);
          width = reader.getWidth(reader.getMinIndex());
          height = reader.getHeight(reader.getMinIndex());
        } catch (IOException e) {
          // Continue with the next reader.
        } finally {
          reader.dispose();
          try {
            imageInputStream.close();
          } catch (IOException e) {
            // Ignore
          }
        }
      }

    } catch (IOException ex) {
      System.err.println("Cannot determine the image size for " + uri + " because of " + ex);
    }
    
    return width + "," + height;
  }
}
