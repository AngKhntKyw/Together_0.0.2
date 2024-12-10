import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:together_version_2/pages/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pip_view/pip_view.dart';

const String appId = "cef99149d5bc4c03ae29ead08c679853";

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({
    super.key,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  int uid = 0; // uid of the local user
  String channelName = "Test";
  String token =
      "007eJxTYMj78vhmp6iLS575naiuLcfms3hZyNtumRr1LeeN2wuJe/MUGJJT0ywtDU0sU0yTkk2SDYwTU40sUxNTDCySzcwtLUyNhaMPpzYEMjIIaAQzMTJAIIjPwhCSWlzCwAAAdyEfCQ==";

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine;
  final fireStore = FirebaseFirestore.instance;
  final fireAuth = FirebaseAuth.instance;

  bool isBottomsDisappeared = false;
  bool _isMuted = false;
  bool _isCameraOn = true;
  RemoteVideoState? remoteVideoState;
  bool _isFrontCamera = true;

  showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void initState() {
    super.initState();
    // Set up an instance of Agora engine
    setupVideoSDKEngine().then((value) => join());
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: appId));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          // showMessage(
          //     "Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          // showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          // showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
        // onConnectionLost: (connection) {
        //   showMessage("Lost connection.");
        // },
        // onRejoinChannelSuccess: (connection, elapsed) {
        //   showMessage("Rejoined channel");
        // },
        // onConnectionStateChanged: (connection, state, reason) {
        //   showMessage(reason.name);
        // },
        // onAudioDeviceStateChanged: (deviceId, deviceType, deviceState) {
        //   showMessage(deviceState.name);
        // },
        onRemoteVideoStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
          setState(() {
            remoteVideoState = state;
          });
          // showMessage("$remoteUid video state : ${state.name}");
        },
      ),
    );
  }

  void join() async {
    await agoraEngine.startPreview();

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    agoraEngine.muteLocalAudioStream(_isMuted);
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
    agoraEngine.enableLocalVideo(_isCameraOn);
  }

  void _toggleCameraPositions() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    agoraEngine.switchCamera();
  }

  void _toggleButtons() {
    setState(() {
      isBottomsDisappeared = !isBottomsDisappeared;
    });
  }

// Release the resources when you leave
  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    agoraEngine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: PIPView(
        builder: (context, isFloating) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                InkWell(
                  onTap: () => _toggleButtons(),
                  onDoubleTap: () => _toggleCameraPositions(),
                  child: Container(
                    height: MediaQuery.sizeOf(context).height,
                    width: MediaQuery.sizeOf(context).width,
                    decoration: BoxDecoration(border: Border.all()),
                    child: Center(
                        child: _remoteUid != null
                            ? _remoteVideo()
                            : _localPreview()),
                  ),
                ),
                _remoteUid != null
                    ? Positioned(
                        top: 40,
                        right: 20,
                        child: Container(
                          height: 200,
                          width: 120,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(child: _localPreview()),
                        ),
                      )
                    : const SizedBox(),
                if (!isBottomsDisappeared)
                  Positioned(
                    top: 40,
                    left: 20,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 1000),
                      reverseDuration: const Duration(milliseconds: 1000),
                      curve: Curves.decelerate,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                isBottomsDisappeared = true;

                                PIPView.of(context)!
                                    .presentBelow(BottomNavBar());
                              });
                            },
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.black45,
                              child:
                                  Icon(Icons.arrow_back, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                !isBottomsDisappeared
                    ? Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 1000),
                          reverseDuration: const Duration(milliseconds: 1000),
                          curve: Curves.decelerate,
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.black45),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    InkWell(
                                      onTap: _isJoined
                                          ? () => {
                                                leave(),
                                                Navigator.pop(context),
                                              }
                                          : () => {
                                                leave(),
                                                Navigator.pop(context),
                                              },
                                      child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: _isJoined
                                              ? Colors.red
                                              : Colors.red,
                                          child: Icon(Icons.call_end,
                                              color: Colors.white)),
                                    ),
                                    InkWell(
                                      onTap: () => _toggleMute(),
                                      child: CircleAvatar(
                                          radius: 22,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                              _isMuted
                                                  ? Icons.mic_off
                                                  : Icons.mic_outlined,
                                              color: Colors.black)),
                                    ),
                                    InkWell(
                                      onTap: () => _toggleCamera(),
                                      child: CircleAvatar(
                                          radius: 22,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                              _isCameraOn
                                                  ? Icons.videocam
                                                  : Icons.videocam_off,
                                              color: Colors.black)),
                                    ),
                                    InkWell(
                                      onTap: () => _toggleCameraPositions(),
                                      child: CircleAvatar(
                                          radius: 22,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                              _isFrontCamera
                                                  ? Icons.camera_front
                                                  : Icons.camera_rear,
                                              color: Colors.black)),
                                    ),
                                    // InkWell(
                                    //   onTap: () {},
                                    //   child: CircleAvatar(
                                    //       radius: 22,
                                    //       backgroundColor: Colors.white,
                                    //       child: Icon(Icons.picture_in_picture_alt,
                                    //           color: Colors.black)),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ))
                    : const SizedBox(),
              ],
            ),
          );
        },
      ),
      onWillPop: () async {
        return false;
      },
    );
  }

// Display local video preview
  Widget _localPreview() {
    if (_isJoined) {
      if (_isCameraOn) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: agoraEngine,
                canvas: VideoCanvas(uid: 0),
              ),
            ));
      } else {
        return const SizedBox();
      }
    } else {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
      );
    }
  }

// Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      if (remoteVideoState == RemoteVideoState.remoteVideoStateStopped) {
        return Text("Camera off");
      } else {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: agoraEngine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: channelName),
          ),
        );
      }
    } else {
      String msg = '';
      if (_isJoined) msg = 'Waiting for a remote user to join';
      return Text(
        msg,
        textAlign: TextAlign.center,
      );
    }
  }
}
