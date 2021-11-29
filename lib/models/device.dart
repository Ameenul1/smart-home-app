import 'package:firebase_database/firebase_database.dart';

class Device {
  String id;
  String name;
  String room;
  bool status;
  int degree;

  Device(this.id,this.name,this.room,this.status,this.degree);

  static Future<String> getTemp() async{
    var data = await FirebaseDatabase.instance.reference().child('temperature').once();
    return data.value.toString();
  }



  static Future<List<Device>> getDeviceStatusByRoom(String room) async{

    List<Device> devices =[];

    List keys =[];

    int i=0;

    FirebaseDatabase.instance.reference().child("devices").orderByChild("room").equalTo(room).onChildAdded.listen((event) {
      keys.add('${event.snapshot.key}');
    });

    var data = await FirebaseDatabase.instance.reference().child("devices").orderByChild("room").equalTo(room).once();

    if(data.exists){
      data.value.forEach((ele){
        devices.add(Device(keys[i], ele['name'], ele['room'], ele['status'], ele['degree']));
        i++;
      });
    }

    return devices;
  }

  static Future<void> updateDevice(String id,bool val,int degree) async{
    await FirebaseDatabase.instance.reference().child('devices').child(id).update({
      'status' : val,
      'degree' : degree
    });
  }


  static Future<void> updateAllDevices() async{
    for(int i=0;i<4;i++){
      await FirebaseDatabase.instance.reference().child('devices').child(i.toString()).update(
          {
            'status' : false
          }
      );
    }

  }


}

