import 'package:esp_sample/models/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

class BedRoomScreen extends StatefulWidget {
  @override
  _BedRoomScreenState createState() => _BedRoomScreenState();
}

class _BedRoomScreenState extends State<BedRoomScreen> {
  bool isError = false;
  List<Device> devices;

  Future<void> getDevices() async{
    try{
      devices = await Device.getDeviceStatusByRoom("bedroom");
      isError = false;
    }
    catch (e){
      isError = true;
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getDevices(),
        builder: (context,snapshot) => (snapshot.connectionState == ConnectionState.waiting)?
        Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Container(
              height: 150,
              width: 150,
              child: LoadingIndicator(
                indicatorType: Indicator.pacman,
                color: Colors.blue,
              ),
            ),
          ),
        ):
        (isError)?Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.sadTear,color: Colors.grey,size: 150,),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("Oops can't connect to network",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                ),
                IconButton(onPressed: () {
                  setState(() {});
                }, icon: Icon(Icons.refresh,color: Colors.blueAccent,size: 40,))
              ],
            ),
          ),
        ):Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
            elevation: 0,
            title: Text("BedRoom",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black)),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height*0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height*0.6,
                  child: ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context,idx) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue,
                                blurRadius: 1.0,
                                spreadRadius: 0.0,
                                offset: Offset(1.0, 1.0),
                              )
                            ],
                          ),
                          child: ListTile(
                            leading: FaIcon(FontAwesomeIcons.bolt,color: Colors.blue,),
                            title: Padding(
                              padding: const EdgeInsets.only(top:5.0),
                              child: Text(devices[idx].name,style: TextStyle(fontSize: 20),),
                            ),
                            subtitle: FlutterSlider(
                              values: [devices[idx].degree.toDouble()],
                              max: 100,
                              min: 0,
                              trackBar: FlutterSliderTrackBar(
                                  activeTrackBar: BoxDecoration(color: Colors.blue)
                              ),
                              onDragCompleted: (var handlerIndex,var upperValue,var lowerValue) {
                                Device.updateDevice(devices[idx].id,devices[idx].status ,upperValue.toInt());
                                setState(() {});
                              },
                            ),
                            trailing: Switch(
                                value: devices[idx].status,
                                activeColor: Colors.blue,
                                onChanged: (val) {
                                  Device.updateDevice(devices[idx].id, val,devices[idx].degree);
                                  setState(() {});

                                }),
                          ),
                        ),
                      )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:20.0),
                  child: IconButton(
                      onPressed: (){
                        for(int i=0;i<devices.length;i++){
                          Device.updateDevice(devices[i].id,false,devices[i].degree);
                        }
                        setState(() {});
                      },
                      icon: FaIcon(FontAwesomeIcons.powerOff,size: 50,color: Colors.red,)
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
