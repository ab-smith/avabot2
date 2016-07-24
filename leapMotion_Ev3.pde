import de.voidplus.leapmotion.*;

import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Map;

LeapMotion leap;
boolean gripOldState = false; //open
boolean gripNewState = false; //open

String devName = "/dev/tty.EV3-SerialPort"; // actual device
FileOutputStream fos = null;
DataOutputStream dos = null;

void setup() {
    size(800, 500);
    background(255);
    // ...

    String strFilePath = devName;

    try {
        //create FileOutputStream object
        fos = new FileOutputStream(strFilePath);
        dos = new DataOutputStream(fos);

    } catch (IOException e) {
        System.out.println("IOException : " + e);
    }

    leap = new LeapMotion(this);
}

void draw() {
    background(255);
    // ...
    int fps = leap.getFrameRate();


    // ========= HANDS =========

    for (Hand hand: leap.getHands()) {


        // ----- BASICS -----

        int hand_id = hand.getId();
        PVector hand_position = hand.getPosition();
        PVector hand_stabilized = hand.getStabilizedPosition();
        PVector hand_direction = hand.getDirection();
        PVector hand_dynamics = hand.getDynamics();
        float hand_roll = hand.getRoll();
        float hand_pitch = hand.getPitch();
        float hand_yaw = hand.getYaw();
        boolean hand_is_left = hand.isLeft();
        boolean hand_is_right = hand.isRight();
        float hand_grab = hand.getGrabStrength();
        float hand_pinch = hand.getPinchStrength();
        float hand_time = hand.getTimeVisible();
        PVector sphere_position = hand.getSpherePosition();
        float sphere_radius = hand.getSphereRadius();


        // ----- SPECIFIC FINGER -----

        Finger finger_thumb = hand.getThumb();
        // or                      hand.getFinger("thumb");
        // or                      hand.getFinger(0);

        Finger finger_index = hand.getIndexFinger();
        // or                      hand.getFinger("index");
        // or                      hand.getFinger(1);

        Finger finger_middle = hand.getMiddleFinger();
        // or                      hand.getFinger("middle");
        // or                      hand.getFinger(2);

        Finger finger_ring = hand.getRingFinger();
        // or                      hand.getFinger("ring");
        // or                      hand.getFinger(3);

        Finger finger_pink = hand.getPinkyFinger();
        // or                      hand.getFinger("pinky");
        // or                      hand.getFinger(4);        


        // ----- DRAWING -----

        hand.draw();
        hand.drawSphere();

        //----------------------
        //My routine for grip

        if (hand.isLeft()) {

            float gripStrenght = hand.getGrabStrength();

            if (gripStrenght > 0.5) {
                //close
                println("I'm closing");
                gripNewState = true; //closed

                if (gripNewState != gripOldState) {

                    //write command

                    sendBluetoothCmd(stdCommand("cmd_action_grip"), 2000);
                    sendBluetoothCmd(stdCommand("cmd_stop_A"), 10);

                    //refresh old state
                    gripOldState = true;
                }

            } else {

                //open
                println("I'm openning");
                gripNewState = false; //opened

                if (gripNewState != gripOldState) {
                    //write command

                    sendBluetoothCmd(stdCommand("cmd_release_grip"), 2000);
                    sendBluetoothCmd(stdCommand("cmd_stop_A"), 10);

                    //refresh old state
                    gripOldState = false;
                }
            }
        }

        // ========= ARM =========

        if (hand.hasArm()) {
            Arm arm = hand.getArm();
            float arm_width = arm.getWidth();
            PVector arm_wrist_pos = arm.getWristPosition();
            PVector arm_elbow_pos = arm.getElbowPosition();
        }

        // ========= FINGERS =========
        //my routine for moving the robot
        if (hand.isRight()) {

            //-------
            float gripStrenght = hand.getGrabStrength();

            if (gripStrenght > 0.5) {

                //write command

                sendBluetoothCmd(stdCommand("cmd_move_fwd_BC"), 3000);
            }

            //-------
            for (Finger finger: hand.getFingers()) {
                // Alternatives:
                // hand.getOutstretchedFingers();
                // hand.getOutstretchedFingersByAngle();

                // ----- BASICS -----

                int finger_id = finger.getId();
                PVector finger_position = finger.getPosition();
                PVector finger_stabilized = finger.getStabilizedPosition();
                PVector finger_velocity = finger.getVelocity();
                PVector finger_direction = finger.getDirection();
                float finger_time = finger.getTimeVisible();

                // ----- SPECIFIC FINGER -----

                switch (finger.getType()) {
                    case 0:
                        // System.out.println("thumb");
                        break;
                    case 1:
                        // System.out.println("index");

                        System.out.println("Index getStabilizedPosition: " + finger.getStabilizedPosition());
                        break;
                    case 2:
                        // System.out.println("middle");
                        break;
                    case 3:
                        // System.out.println("ring");
                        break;
                    case 4:
                        // System.out.println("pinky");
                        break;
                }


                // ----- SPECIFIC BONE -----
                // Overview:
                // https://developer.leapmotion.com/documentation/java/devguide/Leap_Overview.html#Layer_1

                Bone bone_distal = finger.getDistalBone();
                // or                       finger.get("distal");
                // or                       finger.getBone(0);

                Bone bone_intermediate = finger.getIntermediateBone();
                // or                       finger.get("intermediate");
                // or                       finger.getBone(1);

                Bone bone_proximal = finger.getProximalBone();
                // or                       finger.get("proximal");
                // or                       finger.getBone(2);

                Bone bone_metacarpal = finger.getMetacarpalBone();
                // or                       finger.get("metacarpal");
                // or                       finger.getBone(3);


                // ----- DRAWING -----

                finger.draw(); // = drawBones()+drawJoints()
                //finger.drawBones();
                //finger.drawJoints();


                // ----- TOUCH EMULATION -----

                int touch_zone = finger.getTouchZone();
                float touch_distance = finger.getTouchDistance();

                switch (touch_zone) {
                    case -1: // None
                        break;
                    case 0: // Hovering
                        // println("Hovering (#"+finger_id+"): "+touch_distance);
                        break;
                    case 1: // Touching
                        // println("Touching (#"+finger_id+")");
                        break;
                }
            }

        }

        // ========= TOOLS =========

        for (Tool tool: hand.getTools()) {


            // ----- BASICS -----

            int tool_id = tool.getId();
            PVector tool_position = tool.getPosition();
            PVector tool_stabilized = tool.getStabilizedPosition();
            PVector tool_velocity = tool.getVelocity();
            PVector tool_direction = tool.getDirection();
            float tool_time = tool.getTimeVisible();


            // ----- DRAWING -----

            // tool.draw();


            // ----- TOUCH EMULATION -----

            int touch_zone = tool.getTouchZone();
            float touch_distance = tool.getTouchDistance();

            switch (touch_zone) {
                case -1: // None
                    break;
                case 0: // Hovering
                    // println("Hovering (#"+tool_id+"): "+touch_distance);
                    break;
                case 1: // Touching
                    // println("Touching (#"+tool_id+")");
                    break;
            }
        }
    }


    // ========= DEVICES =========

    for (Device device: leap.getDevices()) {
        float device_horizontal_view_angle = device.getHorizontalViewAngle();
        float device_verical_view_angle = device.getVerticalViewAngle();
        float device_range = device.getRange();
    }
}


// ========= CALLBACKS =========

void leapOnInit() {
    // println("Leap Motion Init");
}
void leapOnConnect() {
    // println("Leap Motion Connect");
}
void leapOnFrame() {
    // println("Leap Motion Frame");
}
void leapOnDisconnect() {
    // println("Leap Motion Disconnect");

}
void leapOnExit() {
    // println("Leap Motion Exit");
    try {
        dos.close();
    } catch (IOException e) {
        System.out.println("IOException : " + e);
    }
}

String stdCommand(String cmd) {

    HashMap < String, String > hm = new HashMap < String, String > ();

    char start_motor[] = {
        0x0D, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0xA4, 0x00, 0x01, 0x81, 0x14, 0xA6, 0x00, 0x01
    };
    hm.put("cmd_action_grip", String.valueOf(start_motor));

    char stop_motor[] = {
        0x09, 0x00, 0x01, 0x00, 0x80, 0x00, 0x00, 0xA3, 0x00, 0x01, 0x00
    };
    hm.put("cmd_stop_A", String.valueOf(stop_motor));

    char move_ev3[] = {
        0x12, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0xAE, 0x00, 0x06, 0x81, 0x32, 0x00, 0x82, 0x84, 0x03, 0x82, 0xB4, 0x00, 0x01
    };
    hm.put("cmd_move_fwd_BC", String.valueOf(move_ev3));

    char release_grip[] = {
        0x0d, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0xa4, 0x00, 0x01, 0x81, 0xec, 0xa6, 0x00, 0x01
    };
    hm.put("cmd_release_grip", String.valueOf(release_grip));

    return hm.get(cmd);
}

void sendBluetoothCmd(String cmd, int delayAfter) {
    try {
        dos.writeBytes(cmd);
        delay(delayAfter);
    } catch (IOException e) {
        println("IOException : " + e);
    }
}