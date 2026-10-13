import 'package:flutter/material.dart';
import '../models/fitness_plan.dart';
import '../services/api_service.dart';

const green = Color(0xFF26D07C);
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final formKey = GlobalKey<FormState>();
  final age = TextEditingController(text:'25');
  final equipment = TextEditingController(text:'Bodyweight');
  final limitations = TextEditingController(text:'None');
  String goal = 'General fitness', experience = 'Beginner';
  int days = 3, minutes = 30;
  bool loading = false;
  String? error;
  FitnessPlan? plan;

  @override void dispose() { age.dispose(); equipment.dispose(); limitations.dispose(); super.dispose(); }

  Future<void> generate() async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;
    setState(() { loading=true; error=null; plan=null; });
    try {
      final p = await ApiService().generatePlan(age:int.parse(age.text.trim()), goal:goal, experience:experience,
        daysPerWeek:days, minutesPerSession:minutes, equipment:equipment.text.trim(), limitations:limitations.text.trim());
      if (mounted) setState(()=>plan=p);
    } catch(e) { if(mounted) setState(()=>error=e.toString().replaceFirst('Exception: ','')); }
    finally { if(mounted) setState(()=>loading=false); }
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Row(children:[Icon(Icons.bolt,color:green,size:30),SizedBox(width:8),Text('FitBuddy',style:TextStyle(fontWeight:FontWeight.w800))])),
    body: SafeArea(child: ListView(padding:const EdgeInsets.all(18),children:[
      Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(
        gradient:const LinearGradient(colors:[Color(0xFF234D37),Color(0xFF1A211D)]),borderRadius:BorderRadius.circular(22)),
        child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('YOUR GOALS. YOUR PLAN.',style:TextStyle(color:green,fontWeight:FontWeight.bold,letterSpacing:1.2)),
          SizedBox(height:10),Text('Train smarter with AI.',style:TextStyle(fontSize:27,fontWeight:FontWeight.w800)),
          SizedBox(height:8),Text('A workout plan tailored to your routine, experience, and equipment.')
        ])),
      const SizedBox(height:22),const Text('Personalize your plan',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold)),const SizedBox(height:12),
      Form(key:formKey,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        label('Age'),TextFormField(controller:age,keyboardType:TextInputType.number,decoration:const InputDecoration(hintText:'Your age'),
          validator:(v){final n=int.tryParse(v??'');return n==null||n<13||n>100?'Enter an age from 13 to 100':null;}),
        const SizedBox(height:14),label('Fitness goal'),
        DropdownButtonFormField<String>(initialValue:goal,items:const ['Lose fat','Build muscle','Improve endurance','General fitness','Improve flexibility'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v)=>setState(()=>goal=v??goal)),
        const SizedBox(height:14),label('Experience'),
        DropdownButtonFormField<String>(initialValue:experience,items:const ['Beginner','Intermediate','Advanced'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v)=>setState(()=>experience=v??experience)),
        const SizedBox(height:14),label('Training days per week: $days'),
        Slider(value:days.toDouble(),min:1,max:7,divisions:6,activeColor:green,onChanged:(v)=>setState(()=>days=v.round())),
        label('Minutes per session: $minutes'),
        Slider(value:minutes.toDouble(),min:10,max:120,divisions:11,activeColor:green,onChanged:(v)=>setState(()=>minutes=v.round())),
        const SizedBox(height:8),label('Available equipment'),
        TextFormField(controller:equipment,decoration:const InputDecoration(hintText:'Bodyweight, dumbbells, gym'),validator:(v)=>(v==null||v.trim().isEmpty)?'Enter your equipment':''),
        const SizedBox(height:14),label('Injuries or limitations (optional)'),
        TextFormField(controller:limitations,maxLines:2,decoration:const InputDecoration(hintText:'Enter None if not applicable')),
        const SizedBox(height:20),
        FilledButton.icon(onPressed:loading?null:generate,
          icon:loading?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.auto_awesome),
          label:Text(loading?'Creating your plan...':'Generate my AI plan'),
          style:FilledButton.styleFrom(backgroundColor:green,foregroundColor:Colors.black,padding:const EdgeInsets.symmetric(vertical:17))),
      ])),
      if(error!=null) ...[const SizedBox(height:14),Card(child:Padding(padding:const EdgeInsets.all(14),child:Text(error!,style:const TextStyle(color:Colors.redAccent))))],
      if(plan!=null) ...[const Divider(height:36),Text(plan!.title,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w800)),const SizedBox(height:8),Text(plan!.summary),const SizedBox(height:16),
        ...plan!.weeklySchedule.map((d)=>Card(margin:const EdgeInsets.only(bottom:12),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(d.day.toUpperCase(),style:const TextStyle(color:green,fontWeight:FontWeight.bold)),Text(d.focus,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const Divider(),
          ...d.workout.map((e)=>Padding(padding:const EdgeInsets.only(bottom:12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(e.exercise,style:const TextStyle(fontWeight:FontWeight.bold)),Text('${e.sets} sets • ${e.reps} • Rest ${e.rest}'),if(e.notes.isNotEmpty)Text(e.notes,style:const TextStyle(color:Colors.white70))
          ])))
        ])))),
        if(plan!.habits.isNotEmpty) ...[const Text('Healthy habits',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),...plan!.habits.map((h)=>ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.check_circle_outline,color:green),title:Text(h)))],
        if(plan!.safetyNotes.isNotEmpty) ...[const Text('Safety notes',style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),...plan!.safetyNotes.map((n)=>ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.health_and_safety_outlined),title:Text(n)))],
      ],
      const SizedBox(height:18),const Text('General wellness information only, not medical advice. Consult a qualified professional if you have a health condition or injury.',style:TextStyle(color:Colors.white60,fontSize:12)),
    ])),
  );
  Widget label(String text)=>Padding(padding:const EdgeInsets.only(bottom:7),child:Text(text,style:const TextStyle(fontWeight:FontWeight.w600)));
}
