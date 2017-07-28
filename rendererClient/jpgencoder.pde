import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;

public class JPGEncoder {

  byte[] encode(PImage img) throws IOException {
    ByteArrayOutputStream imgbaso = new ByteArrayOutputStream();
    ImageIO.write((BufferedImage) img.getNative(), "jpg", imgbaso);

    return imgbaso.toByteArray();
  }

  PImage decode(byte[] imgbytes) throws IOException {
    BufferedImage imgbuf = ImageIO.read(new ByteArrayInputStream(imgbytes));
    PImage img = new PImage(imgbuf.getWidth(), imgbuf.getHeight(), RGB);
    imgbuf.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width);
    img.updatePixels();

    return img; 
  }

}