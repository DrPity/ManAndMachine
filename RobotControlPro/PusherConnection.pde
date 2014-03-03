import java.util.Set;
import java.util.Set;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.awt.Frame;

import com.pusher.client.Pusher;
import com.pusher.client.PusherOptions;
import com.pusher.client.channel.PrivateChannel;
import com.pusher.client.channel.PrivateChannelEventListener;
import com.pusher.client.channel.SubscriptionEventListener;
import com.pusher.client.connection.ConnectionEventListener;
import com.pusher.client.connection.ConnectionState;
import com.pusher.client.connection.ConnectionStateChange;
import com.pusher.client.util.HttpAuthorizer;


private static final String   DATA_CHANNEL        = "private-data";
private static final String   ROBOT_CONTROL_EVENT = "client-robot-control";
private static final String   YAW_COORD           = "yaw";
private static final String   PITCH_COORD         = "pitch";
private static final String   Z_COORD             = "z_coord";
private static final String   ID_ROBOT            = "id";
private static final Integer  DISPLAY_DURATION    = 4000;

/* Pusher */
PusherConnection mPusherConnection;
private Pusher          mPusher;
private PrivateChannel  mPrivateChannel;
private PusherOptions   mPusherOptions;
private Integer         failedConnectionAttempts  = 0;
private String          msg                       = "No Event";
private String          connectionPusher          = "No Connection";
private String          serialConnection          = "Establish serial connection...";
private String          error;
private double   id;
private int      x;
private int      y;
private int      yaw;
private int      pitch;




public class PusherConnection implements ConnectionEventListener, SubscriptionEventListener,  PrivateChannelEventListener {
  
  

  public void onCreate() {
    // TODO: login token
    
    connectToPusher();
    
  }
  
  private void connectToPusher() {
    // connect to pusher in order to receive Game stats commands
    // and triggering event, such as pointer
    HttpAuthorizer authorizer = new HttpAuthorizer("http://thehunt.herokuapp.com/pusher/auth");
    mPusherOptions = new PusherOptions().setAuthorizer(authorizer);
    mPusher = new Pusher("b41bf8007ed13fc337cd", mPusherOptions);
    mPusher.connect(this, ConnectionState.ALL);
  }
    
  
  
  

  
  //ConnectionEventListener implementation
  public void onConnectionStateChange(ConnectionStateChange change) {
      connectionPusher = String.format("Connection state changed from [%s] to [%s]", change.getPreviousState(), change.getCurrentState() );
    
    if (change.getCurrentState() == ConnectionState.CONNECTED) {
      // subscribe to channel
      mPrivateChannel = mPusher.subscribePrivate(DATA_CHANNEL, this, ROBOT_CONTROL_EVENT);
      connectionPusher= String.format("Connected");
      monitoring.setColor(#65EC3B, 14);
    }
    
    else if (change.getCurrentState() == ConnectionState.DISCONNECTED) {
            
      failedConnectionAttempts ++;
      connectToPusher();
      delay(2000);    
      
    }

  }

  public void onError(String message, String code, Exception e) {
    connectionPusher = String.format("Connection error: [%s] [%s] [%s]", message, code, e);
    monitoring.setColor(#FF4540, 14);
  }

  // ChannelEventListener implementation
  public void onEvent(String channelName, String eventName, String data) {
    msg = String.format("Event received: [%s] [%s] [%s]", channelName, eventName, data);
    
    try {
      org.json.JSONObject obj = new org.json.JSONObject(data);
      
      if (channelName.equals(DATA_CHANNEL)) {
        
        
        if (eventName.equals(ROBOT_CONTROL_EVENT)) {
          // id = obj.getDouble(ID_ROBOT);
          // x = obj.getDouble(YAW_COORD);
          // msg[textIteration] = String.format("YAW: [%d]", x);
          // textIteration ++;
          // y = obj.getDouble(PITCH_COORD);
          // msg[textIteration] = String.format("PITCH: [%d]", y);
          // z = obj.getDouble(Y_COORD);
          //Location of the hunter should be updated
          
        }       
        
        
      }  
      
      
    } catch (JSONException e) {
      // TODO Auto-generated catch block
      //e.printStackTrace();
    }
    
  }
  

  public void onSubscriptionSucceeded(String channelName) {
    error = String.format("Subscription succeeded for [%s]", channelName);
  }


  @Override
  public void onAuthenticationFailure(String arg0, Exception arg1) {
    // TODO Auto-generated method stub
    error = (String.format("Authentication failure due to [%s], exception was [%s]",arg0, arg1));
  }
  
  
  public void destroy() {
    // TODO Auto-generated method stub
    mPusher.disconnect();
   
  }
  

}