import hypermedia.net.*;

/**
 * This class can be added to your sketches to make them compatible with an LED display.
 * Use Sketch..Add File and choose this file to copy it into your sketch.
 * 
 * void setup() {
 *   // Constructor takes this, width, height.
 *   Dacwes dacwes = new Dacwes(this, 16, 16);
 * 
 *   // Change this depending on how the sign is configured.
 *   dacwes.setAddressingMode(Dacwes.ADDRESSING_VERTICAL_FLIPFLOP);
 *
 *   // Include this to talk to the emulator.
 *   dacwes.setAddress("127.0.0.1");
 *
 *   // The class will scale things for you, but it may not be full brightness
 *   // unless you match the size.
 *   size(320,320);  
 * }
 *
 * void draw() {
 *   doStuff();
 *
 *   // Call this in your draw loop to send data to the sign.
 *   dacwes.sendData();
 * }
 *
 **/

public class LEDDisplay {
  public static final int ADDRESSING_VERTICAL_NORMAL = 1;
  public static final int ADDRESSING_VERTICAL_HALF = 2;
  public static final int ADDRESSING_VERTICAL_FLIPFLOP = 3;
  public static final int ADDRESSING_HORIZONTAL_NORMAL = 4;
  public static final int ADDRESSING_HORIZONTAL_HALF = 5;
  public static final int ADDRESSING_HORIZONTAL_FLIPFLOP = 6;

  PApplet parent;
  PGraphics pg;
  UDP udp;
  String address;
  int port;
  int w;
  int h;
  int addressingMode;
  byte byteBuffer[];
  int pixelsPerChannel;
  float gammaValue = 2.5;
  boolean enableGammaCorrection = false;
  boolean isRGB = false;
  int packetLength = 49153;

  public LEDDisplay(PApplet parent, PGraphics pg, int w, int h, int packetLength, boolean isRGB, String address, int port) {
    this.parent = parent;
    this.pg = pg;
    this.udp = new UDP(parent);
    this.address = address;
    this.port = port;
    this.w = w;
    this.h = h;
    this.isRGB = isRGB;
    int byteBufferSize = packetLength>0 ? packetLength : (isRGB ? 3 : 1)*(w*h)+1;
    byteBuffer = new byte[byteBufferSize];
    this.addressingMode = ADDRESSING_HORIZONTAL_NORMAL;
    // TODO Detect this based on VERTICAL (h/2) vs. HORIZONTAL (w/2)
    this.pixelsPerChannel = 8;

    for (int i=0; i<byteBufferSize; i++) {
      byteBuffer[i] = 0;
    }
  }

  public LEDDisplay(PApplet parent, int w, int h, boolean isRGB, String address, int port) {
    this(parent, parent.g, w, h, 0, isRGB, address, port);
  }
  
  public void setAddress(String address) {
    this.address = address;
  }

  public void setPort(int port) {
    this.port = port;
  }

  public void setAddressingMode(int mode) {
    this.addressingMode = mode;
  }

  public void setPixelsPerChannel(int n) {
    this.pixelsPerChannel = n;
  }

  public void setGammaValue(float gammaValue) {
    this.gammaValue = gammaValue;
  }

  public void setEnableGammaCorrection(boolean enableGammaCorrection) {
    this.enableGammaCorrection = enableGammaCorrection;
  }
  
  public void setPacketLength(int len) {
    this.packetLength = len;
  }

  private int getAddress(int x, int y) {
    if (addressingMode == ADDRESSING_VERTICAL_NORMAL) {
      return (x * h + y);
    }
    else if (addressingMode == ADDRESSING_VERTICAL_HALF) {
      return ((y % pixelsPerChannel) + floor(y / pixelsPerChannel)*pixelsPerChannel*w + x*pixelsPerChannel);
    }
    else if (addressingMode == ADDRESSING_VERTICAL_FLIPFLOP) {
      if (y>=pixelsPerChannel) {
        int endAddress = (x+1) * h - 1;
        int address = endAddress - (y % pixelsPerChannel);
        return address;
      }
      else {
        return (x * h + y);
      }
    }
    else if (addressingMode == ADDRESSING_HORIZONTAL_NORMAL) {
      return (y * w + x);
    }
    else if (addressingMode == ADDRESSING_HORIZONTAL_HALF) {
      return ((x % pixelsPerChannel) + floor(x / pixelsPerChannel)*pixelsPerChannel*h + y*pixelsPerChannel);
    }
    else if (addressingMode == ADDRESSING_HORIZONTAL_FLIPFLOP) {
      if (x>=pixelsPerChannel) {
        int endAddress = (y+1) * w - 1;
        int address = endAddress - (x % pixelsPerChannel);
        return address;
      }
      else {
        return (y * h + x);
      }
    }

    return 0;
  }      

  public void sendMode(String modeName) {
    byte modebyteBuffer[] = new byte[modeName.length()+1];

    modebyteBuffer[0] = 2;
    for (int i = 0; i < modeName.length(); i++) {
      modebyteBuffer[i+1] = (byte)modeName.charAt(i);
    }

    udp.send(modebyteBuffer, address, port);
  }

  // TODO REFACTOR There's an awful lot of math and vars inside big loops in here
  public void sendData() {
    PImage image = pg.get();

    if (image.width != w || image.height != h) {
      image.resize(w,h);
    }

    image.loadPixels();

    int r;
    int g;
    int b;
    
    // Adding multipart sending, will try to maintain compatiblity where possible, but it's
    // likely to break on anything with strange addressing modes (DACWES)
    int partSize = (packetLength-1)/(w * (isRGB ? 3 : 1));
    int parts = h / partSize;
    
    for (int part=0; part<parts; part++) {
      int yofs = part * partSize;
      byteBuffer[0] = byte(part);
      
      for (int y=0; y<partSize; y++) {
        for (int x=0; x<w; x++) {

          if (isRGB) {
            r = int(red(image.pixels[(y+yofs)*w+x]));
            g = int(green(image.pixels[(y+yofs)*w+x]));
            b = int(blue(image.pixels[(y+yofs)*w+x]));
          
            if (enableGammaCorrection) {
              r = (int)(Math.pow(r/256.0,this.gammaValue)*256);
              g = (int)(Math.pow(g/256.0,this.gammaValue)*256);
              b = (int)(Math.pow(b/256.0,this.gammaValue)*256);
            }

            byteBuffer[(getAddress(x, y)*3)+1] = byte(r);
            byteBuffer[(getAddress(x, y)*3)+2] = byte(g);
            byteBuffer[(getAddress(x, y)*3)+3] = byte(b);
          }
          else {
            r = int(brightness(image.pixels[(y+yofs)*w+x]));

            if (enableGammaCorrection) {
              r = (int)(Math.pow(r/256.0,this.gammaValue)*256);
            }

            byteBuffer[(getAddress(x, y)+1)] = byte(r);
          }
        }
      }
 
      udp.send(byteBuffer, address, port);
    }
  }
}

