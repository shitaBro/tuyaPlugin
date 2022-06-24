package com.jw.tuyaPlugin.tuya_plugin;

import android.app.Activity;
import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.tuya.smart.android.ble.api.LeScanSetting;
import com.tuya.smart.android.ble.api.ScanDeviceBean;
import com.tuya.smart.android.ble.api.ScanType;
import com.tuya.smart.android.ble.api.TyBleScanResponse;
import com.tuya.smart.android.user.api.ILoginCallback;
import com.tuya.smart.android.user.api.IUidLoginCallback;
import com.tuya.smart.android.user.bean.User;
import com.tuya.smart.home.sdk.TuyaHomeSdk;
import com.tuya.smart.home.sdk.bean.HomeBean;
import com.tuya.smart.home.sdk.bean.scene.SceneBean;
import com.tuya.smart.home.sdk.callback.ITuyaHomeResultCallback;
import com.tuya.smart.home.sdk.callback.ITuyaResultCallback;
import com.tuya.smart.sdk.api.IMultiModeActivatorListener;
import com.tuya.smart.sdk.api.IResultCallback;
import com.tuya.smart.sdk.api.ITuyaActivatorGetToken;
import com.tuya.smart.sdk.api.ITuyaDevice;
import com.tuya.smart.sdk.api.ITuyaSmartActivatorListener;
import com.tuya.smart.sdk.bean.DeviceBean;
import com.tuya.smart.sdk.bean.MultiModeActivatorBean;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** TuyaPlugin */
public class TuyaPlugin implements FlutterPlugin, MethodCallHandler,ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context appContext;
  private ITuyaDevice tuyaDevice;
  private List<String> boolKeys;
  private Activity mactivity;
  private long currentHomeId;
  private String productId; //设备id，第一次配网使用
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tuya_plugin");
    channel.setMethodCallHandler(this);
    appContext = flutterPluginBinding.getApplicationContext();

  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }else if (call.method.equals("startWithKeySercert")) {
      handleInitSdkCall(call, result);
    }else if (call.method.equals("loginOrRegisterAccount")) {
      loginOrRegisterAccount(call, result);
    }else if (call.method.equals("searchWifi")) {
      searchWifi(call, result);
    }else if (call.method.equals("startConfigBLEWifiDeviceWith")) {
      startConfigBLEWifiDeviceWith(call, result);
    }else if (call.method.equals("removeDevice")) {
      removeDevice(call, result);
    }else if (call.method.equals("resetFactory")) {
      resetFactory(call, result);
    }else if (call.method.equals("sendCommand")) {

      sendCommand(call, result);
    }else if (call.method.equals("startSearchDevice")) {
      startSearchDevice(call,result);
    }else if (call.method.equals("connectDeviceWithId")) {
      connectDeviceWithId(call, result);
    }
    else {
      result.notImplemented();
    }
  }

  public void handleInitSdkCall(@NonNull MethodCall call, @NonNull Result result) {
    Map json = (Map)call.arguments;
    Log.i("init tuya sdk", "handleInitSdkCall: " + json);
    TuyaHomeSdk.init((Application) appContext,json.get("key").toString(),json.get("secret").toString());
    boolKeys = (List<String>)json.get("boolKeys");
    Log.i("bool keys", "handleInitSdkCall: " + boolKeys);
  }
  public void loginOrRegisterAccount(@NonNull MethodCall call, @NonNull Result result) {
    Map json = (Map)call.arguments;
    TuyaHomeSdk.getUserInstance().loginOrRegisterWithUid(json.get("countryCode").toString(), json.get("uid").toString(), json.get("password").toString(), true, new IUidLoginCallback() {
      @Override
      public void onSuccess(User user, long homeId) {
        Log.i("登录", "user login success homeid: " + homeId);
        currentHomeId = homeId;
        TuyaHomeSdk.newHomeInstance(homeId).getHomeDetail(new ITuyaHomeResultCallback() {
          @Override
          public void onSuccess(HomeBean bean) {
            Log.i("获取房屋信息成功", "get home info success: " + bean.toString());
            Log.i("设备列表", "onSuccess: " + bean.getDeviceList());

            if (bean.getDeviceList().isEmpty()) {
              //无设备
              Map<String,Object> dic = new HashMap<>();
              dic.put("homeId", homeId);
              List<Map> devices = new ArrayList<Map>();
              dic.put("devices",devices);
              result.success(dic);
            }else {
              //有设备

              Map<String,Object> sdic = new HashMap<>();
              sdic.put("homeId", homeId);
              List<Map> devices = new ArrayList<Map>();

              for (DeviceBean devmo: bean.getDeviceList()
                   ) {
                productId = devmo.getProductId();

                Map<String,Object> dic = new HashMap<>();

                dic.put("uuid",devmo.getUuid());
                dic.put("productId",productId);
                dic.put("mac",devmo.getMac());
                dic.put("devId",devmo.getDevId());
                devices.add(dic);
              }
              sdic.put("devices",devices);
              result.success(sdic);
            }
          }

          @Override
          public void onError(String errorCode, String errorMsg) {

          }
        });
      }

      @Override
      public void onError(String code, String error) {
        Log.e("登录", "userlogin code: " + code + "error:" + error);
        Toast.makeText(appContext, "登录失败 code:"+code + "error:" + error, Toast.LENGTH_SHORT).show();
      }
    });

  }
  public void startSearchDevice(@NonNull MethodCall call,@NonNull Result result) {
    LeScanSetting scanSetting =
            new LeScanSetting.Builder().setTimeout(60000).addScanType(ScanType.SINGLE).build();
    TuyaHomeSdk.getBleOperator().startLeScan(scanSetting, new TyBleScanResponse() {
      @Override
      public void onResult(ScanDeviceBean bean) {
        Log.i("tuya ble scan ", "onResult: " + bean.toString());
        productId = bean.getProductId();

        Map<String,Object> dic = new HashMap<>();
        dic.put("homeId",currentHomeId);
        dic.put("uuid",bean.getUuid());
        dic.put("productId",productId);
        dic.put("mac",bean.getMac());
        dic.put("isActive",bean.getIsbind());
        dic.put("bleType",bean.getDeviceType());
        dic.put("address",bean.getAddress());
        channel.invokeMethod("ScanResult",dic);
      }
    });
  }
  public void connectDeviceWithId(@NonNull MethodCall call,@NonNull Result result) {
    Map json = (Map)call.arguments;
    tuyaDevice = TuyaHomeSdk.newDeviceInstance(json.get("devId").toString());
    tuyaDevice.registerDevListener(new TuyaDevListenser());
    result.success(tuyaDevice != null);
  }
  public void searchWifi (@NonNull MethodCall call, @NonNull Result result) {
    BluetoothAdapter mbluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    if (mbluetoothAdapter == null) {
      Log.i("bluetooth access ", "device not support ble ");
    }else {
      if (mbluetoothAdapter.isEnabled()) {
       WifiUtil wifiUtil = new WifiUtil(mactivity);
      String ssid =  wifiUtil.getDetailsWifiInfo();
      result.success(ssid);
      }else {
        Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
        mactivity.startActivityForResult(enableIntent,1);
      }
    }
  }
  public  void startConfigBLEWifiDeviceWith(@NonNull MethodCall call, @NonNull Result result) {
    Map dic = (Map)call.arguments;
    int homeId = (int)dic.get("homeId");
    Log.i("homeid", "ConfigBLEWifi homeid:" + homeId);
    TuyaHomeSdk.getActivatorInstance().getActivatorToken(homeId, new ITuyaActivatorGetToken() {
      @Override
      public void onSuccess(String token) {
        Log.i("get activator token ", "onSuccess: ");
        MultiModeActivatorBean multiModeActivatorBean = new MultiModeActivatorBean();
        multiModeActivatorBean.deviceType = (Integer) dic.get("bleType");
        multiModeActivatorBean.uuid = dic.get("UUID").toString();
        multiModeActivatorBean.address = dic.get("address").toString();
        String mac =  dic.get("mac").toString();
        if (mac.isEmpty() == false) {
          multiModeActivatorBean.mac = mac;
        }

        multiModeActivatorBean.ssid = dic.get("ssid").toString();

        multiModeActivatorBean.token = token;
        multiModeActivatorBean.homeId = homeId;

        multiModeActivatorBean.pwd = dic.get("password").toString();
        multiModeActivatorBean.timeout = 120000;
        Log.i("multiModeBean", "bean value: "+multiModeActivatorBean.ssid);
        TuyaHomeSdk.getActivator().newMultiModeActivator().startActivator(multiModeActivatorBean,
                new IMultiModeActivatorListener() {
                  @Override
                  public void onSuccess(DeviceBean deviceBean) {
                    Log.i("device set wifi success", "onSuccess: " + deviceBean.toString());
                    tuyaDevice = TuyaHomeSdk.newDeviceInstance(deviceBean.getDevId());

                  }

                  @Override
                  public void onFailure(int code, String msg, Object handle) {
                    Log.i("device set wifi error",
                            "onFailure: " + "code:"+code +"msg：" +msg + "handle：" + handle);
                  }
                });
      }

      @Override
      public void onFailure(String errorCode, String errorMsg) {
        Log.i("get activator token ", "onfail: " +errorCode + " :" + errorMsg);
      }
    });


  }
  public void removeDevice (@NonNull MethodCall call, @NonNull Result result) {
    tuyaDevice.removeDevice(new IResultCallback() {
      @Override
      public void onError(String code, String error) {
        Toast.makeText(appContext, "移除设备失败code:" + code + "err:" + error, Toast.LENGTH_SHORT).show();
        Log.i("remove device", "onError: "+ code + "err:" + error);
        result.success(false);
      }

      @Override
      public void onSuccess() {
        Log.i("remove device", "移除设备success: ");
        result.success(true);
      }
    });
  }
  public  void resetFactory(@NonNull MethodCall call, @NonNull Result result) {
    tuyaDevice.resetFactory(new IResultCallback() {
      @Override
      public void onError(String code, String error) {
        Log.i(" reset factory", "onError: " + code + "err:"+error);
        Toast.makeText(appContext, "重置设备失败", Toast.LENGTH_SHORT).show();
        result.success(false);
      }

      @Override
      public void onSuccess() {
        Log.i("reset factory", "onSuccess: ");
        result.success(true);
      }
    });
  }
  public void sendCommand(@NonNull MethodCall call, @NonNull Result result) {
    Log.i("commands", "commands: " + call.arguments.toString());

    tuyaDevice.publishDps(JSONObject.toJSONString(call.arguments), new IResultCallback() {
      @Override
      public void onError(String code, String error) {
        Log.i("send command error", "onError: " + code + "err:" + error);
        result.success(0);
      }

      @Override
      public void onSuccess() {
        result.success(1);
        Log.i("send command success", "onSuccess: ");
      }
    });
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.mactivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivity() {

  }
}
