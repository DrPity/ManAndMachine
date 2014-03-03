public class Monitoring{
  private ArrayList strings;
  private color[] textColor = new color [32];
  private PFont font;
  private int fontSize;
  private int offset = 0;
  private boolean isOn;
 
  public Monitoring(){
    strings = new ArrayList();
    setFont("helvetica", 12);
    isOn = true;
  }
 
  public void add(String s){
    if(isOn){
      strings.add(s);
    }
  }
 
  public void setOn(boolean on){
    isOn = on;
  }
 
  public void setFont(String name, int size){
    fontSize = size <= 0 ? 1 : size;
    font = createFont(name, fontSize);
    textAlign(LEFT);
  }
 
  public void setColor(color c, int i){
    textColor[i] = c;
  }
 
  public void clear(){
    while(strings.size() > 0){
      strings.remove(0);
    }
  }
 
  public void draw(){
    if(isOn){
      pushStyle();
      textFont(font);
      int y = fontSize;
 
      for(int i = 0; i < strings.size(); i++, y += fontSize){
        fill(textColor[i]);
        text((String)strings.get(i), 5, y);
      }
      popStyle();
      clear();
    }
  }
}
