package com.jw.tuyaPlugin.tuya_plugin;

import android.util.Log;

import com.tuya.smart.sdk.api.IDevListener;

public class TuyaDevListenser implements IDevListener {

    private  String tag = "tuyaDevice";
    @Override
    public void onDpUpdate(String devId, String dpStr) {
        Log.i(tag, "onDpUpdate: "+ devId + "dpstr:" + dpStr);
    }

    @Override
    public void onRemoved(String devId) {
        Log.i(tag, "onRemoved: "+devId);
    }

    @Override
    public void onStatusChanged(String devId, boolean online) {
        Log.i(tag, "onStatusChanged: " +devId + online);
    }

    @Override
    public void onNetworkStatusChanged(String devId, boolean status) {
        Log.i(tag, "onNetworkStatusChanged: " + devId + status);
    }

    @Override
    public void onDevInfoUpdate(String devId) {
        Log.i(tag, "onDevInfoUpdate: " + devId);
    }
}
