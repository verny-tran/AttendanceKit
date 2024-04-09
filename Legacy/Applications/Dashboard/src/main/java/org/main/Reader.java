package org.main;

import com.rfidread.Interface.IAsynchronousMessage;
import com.rfidread.Interface.ISearchDevice;
import com.rfidread.Models.Device_Model;
import com.rfidread.Models.GPI_Model;
import com.rfidread.Models.Tag_Model;
import com.rfidread.*;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import com.google.firebase.messaging.AndroidConfig;
import com.google.firebase.messaging.AndroidNotification;
import com.google.firebase.messaging.ApnsConfig;
import com.google.firebase.messaging.Aps;
import com.google.firebase.messaging.ApsAlert;
import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.MulticastMessage;
import com.google.firebase.messaging.Notification;
import com.google.firebase.messaging.SendResponse;
import com.google.firebase.messaging.TopicManagementResponse;
import com.google.firebase.messaging.WebpushConfig;
import com.google.firebase.messaging.WebpushFcmOptions;
import com.google.firebase.messaging.WebpushNotification;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import java.util.Timer;
import java.util.HashMap;
import java.util.Map;

public class Reader implements Runnable, IAsynchronousMessage, ISearchDevice {
    private Thread thread;
    private MainComponent mc;

    static String ConnID = "tty.usbserial-1430:115200";
    static String currentTag = "";

    final FirebaseDatabase database = FirebaseDatabase.getInstance();
    DatabaseReference ref = database.getReference().child("tag");

    public Reader(MainComponent component) {
        this.mc = component;
        this.thread = new Thread(this, "Ultimate Reader");
        this.thread.start();
    }
    @Override
    public void run() {
        while(true) {
            try {
                exec();
            } catch (FirebaseMessagingException e) {
                throw new RuntimeException(e);
            }

            try {
                Thread.sleep(7000);
            } catch (Exception e) {

            }
        }
    }

    void exec() throws FirebaseMessagingException {
        if (RFIDReader.CreateSerialConn(ConnID, this)) {
            mc.updateLabel("Connect success!");
        }

        if (RFIDReader.CreateSerialConn(ConnID, this)) {
            mc.updateLabel("Connect success!");
        }

        sendToToken();
    }

    public void sendToToken() throws FirebaseMessagingException {
        // [START send_to_token]
        // This registration token comes from the client FCM SDKs.
        // Send a message to the device corresponding to the provided
        // registration token.
        String response = FirebaseMessaging.getInstance().send(apnsMessage());
        // Response is a message ID string.
        System.out.println("Successfully sent message: " + response);
        // [END send_to_token]
    }

    public Message apnsMessage() {
        // [START apns_message]
        Message message = Message.builder()
                .setApnsConfig(ApnsConfig.builder()
                        .putHeader("apns-priority", "10")
                        .setAps(Aps.builder()
                                .setAlert(ApsAlert.builder()
                                        .setTitle("ITITIU18247 attendance checking!")
                                        .setBody("Artificial Intelligence Class Friday Morning.")
                                        .build())
                                .setBadge(42)
                                .build())
                        .build())
                .setToken("dh-BkVVnQ048m2lowtguhw:APA91bEi0SelhzsMu78-iEqAfgn49ncvRH5fGrP_5QIhS8wBz8ZLIaHCFDH8AlrKO2jnR1U7jQJ9QOM5LvxXz3-bY28hg1e6nWAYJXwKoz-uPaglnA1qNLBE67d1Fi1Qe9CLW9JIuQGG")
                .build();
        // [END apns_message]
        return message;
    }

    @Override
    public void WriteDebugMsg(String s) {

    }

    @Override
    public void WriteLog(String s) {

    }

    @Override
    public void PortConnecting(String connID) {
        System.out.println(connID);
        if (RFIDReader.GetServerStartUp())
        {
            System.out.println("A reader connected to this server: " + connID);
            ConnID = connID;
        }
    }

    @Override
    public void PortClosing(String s) {

    }

    @Override
    public void OutPutTags(Tag_Model tag_model) {
        System.out.println("EPC："+ tag_model._EPC + " TID：" + tag_model._TID + " Userdata:" + tag_model._UserData + " ReaderName：" + tag_model._ReaderName+ " ReaderSN：" + tag_model._ReaderSN);
        mc.updateLabel(tag_model._TID);

        Map<String, String> tags = new HashMap<>();
        tags.put("currentTag", tag_model._TID);
        ref.setValueAsync(tags);

        currentTag = tag_model._TID;
    }

    @Override
    public void OutPutTagsOver() {
        System.out.println("OutPutTagsOver");
    }

    @Override
    public void GPIControlMsg(GPI_Model gpi_model) {

    }

    @Override
    public void OutPutScanData(byte[] bytes) {

    }

    @Override
    public void DeviceInfo(Device_Model device_model) {

    }

    @Override
    public void DebugMsg(String s) {

    }
}