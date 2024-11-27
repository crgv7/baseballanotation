import 'package:baseballanotation/screen/calendario/calendar.dart';
import 'package:baseballanotation/screen/graficos.dart';
import 'package:baseballanotation/screen/home.dart';
import 'package:baseballanotation/screen/lideres.dart';
import 'package:baseballanotation/services/database_services.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      routes: {
          'home':(context)=>Home(),
          'lideres':(context)=>Lideres(),
          'calendario':(context)=>EventCalendar(),
          'graficos':(context)=>Graficos()
      },
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'BallAnotations'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
       child:ListView(
          padding:EdgeInsets.zero,
          children: [
            _buildItem(
              icon: Icons.notifications_rounded, 
              title: "Home", 
              ontap: ()=>Navigator.pushNamed(context,"home")
              ),

            _buildItem(
              icon: Icons.notifications_rounded, 
              title: "Calendario", 
              ontap: ()=>Navigator.pushNamed(context,"calendario")
               ),

            _buildItem(
              icon: Icons.notifications_rounded, 
              title: "Lideres", 
              ontap: ()=>Navigator.pushNamed(context,"lideres")),

            _buildItem(
              icon: Icons.notifications_rounded, 
              title: "Graficos", 
              ontap: ()=>Navigator.pushNamed(context,"graficos")),  

          ],
        ) ,

      )
      
      );
  }

    _buildItem({required IconData icon, required String title,required GestureTapCallback ontap}){
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: ontap,
    );

  }
}
