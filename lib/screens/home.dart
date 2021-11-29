import 'package:esp_sample/screens/bedRoomScreen.dart';
import 'package:esp_sample/screens/livingRoomScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:esp_sample/models/device.dart';
import 'package:loading_indicator/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  var temp = "";
  bool isError = false;

  Widget gridCard(String name,IconData icon,Widget roomScreen,Color color){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () =>(roomScreen!=null)?Navigator.of(context).push(MaterialPageRoute(builder: (context)=>roomScreen)):print(0),
        splashColor: color,
        child: Container(
          height: 150,
          width: MediaQuery.of(context).size.width*0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: color,
                blurRadius: 2.0,
                spreadRadius: 1.0,
                offset: Offset(2.0, 2.0),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon,color: color,size: 30,),
              Padding(
                padding: const EdgeInsets.only(top:8.0),
                child: Text(name,style: TextStyle(fontSize: 18,)),
              )
            ],
          ),
        ),
      ),
    );
  }


  Future<void> getTemp()async{
    try{
      temp = await Device.getTemp();
      isError = false;
    }
    catch(e){
      isError = true;
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getTemp(),
      builder: (context,snapShot)=>(snapShot.connectionState == ConnectionState.waiting)?
      Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            height: 150,
            width: 150,
            child: LoadingIndicator(
              indicatorType: Indicator.pacman,
              color: Colors.red,
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
              }, icon: Icon(Icons.refresh,color: Colors.redAccent,size: 40,))
            ],
          ),
        ),
      ):
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("My Home",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black)),
        ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(child: gridCard('Temperature :' + temp.toString() + ' C', FontAwesomeIcons.thermometerHalf, null ,Colors.orange)),
                    Center(child: gridCard('Living Room', FontAwesomeIcons.tv, LivingRoomScreen(),Colors.redAccent)),
                    Center(child: gridCard('BedRoom', FontAwesomeIcons.bed, BedRoomScreen(),Colors.blueAccent)),
                    Padding(
                      padding: const EdgeInsets.only(top:20.0),
                      child: IconButton(
                          onPressed: (){
                             Device.updateAllDevices();
                             setState(() {});
                             },
                            icon: FaIcon(FontAwesomeIcons.powerOff,size: 50,color: Colors.red,)
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}
