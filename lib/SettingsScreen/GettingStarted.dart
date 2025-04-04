
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GettingStarted extends StatefulWidget {
  @override
  _GettingStartedState createState() => _GettingStartedState();
}

class _GettingStartedState extends State<GettingStarted> {

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      appBar: AppBar(title: Text("Getting Started", style: TextStyle(fontWeight: FontWeight.bold),), centerTitle: true,),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                    Divider(
                      color: Colors.grey,
                    ),
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: Colors.black,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Text('1', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                      ),
                    )
                ],
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  children: [
                    Text('The Home tab is the place where all the cases are visible.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,),
                    ),
                    SizedBox(height: 20,),
                    Image.asset('assets/GetStarted/get6.png', width: double.infinity, fit: BoxFit.fitWidth,),
                    SizedBox(height: 5,),
                    Text('Home tab at the bottom left of the screen',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),

              SizedBox(
                height: 10,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Divider(
                    color: Colors.grey,
                  ),
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Text('2', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  children: [
                    Text('Let us start by learning to read the information in the Home tab.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,),
                    ),
                    SizedBox(height: 20,),
                    Image.asset('assets/GetStarted/get5.png', width: double.infinity, fit: BoxFit.fitWidth,),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      child: Text('A case tile Below are the details about what each information on this case tile stands for.',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  children: [
                    Image.asset('assets/GetStarted/get4.png', width: double.infinity, fit: BoxFit.fitWidth,),
                    SizedBox(height: 20,),
                    Image.asset('assets/GetStarted/get3.png', width: double.infinity, fit: BoxFit.fitWidth,),
                    SizedBox(height: 20,),
                    Image.asset('assets/GetStarted/get2.png', width: double.infinity, fit: BoxFit.fitWidth,),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Divider(
                    color: Colors.grey,
                  ),
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Text('3', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  children: [
                    Text('When the Case Page opens, the Summary, Discussion and Gallery tabs can be found at the top.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,),
                    ),

                    Image.asset('assets/GetStarted/get1.png', height: 340, width: double.infinity, fit: BoxFit.fitWidth,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: RichText(
                        text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: 'Summary, Discussion ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,),
                              ),
                              TextSpan(
                                text: 'and ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,),
                              ),
                              TextSpan(text: 'Gallery ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,),
                              ),
                              TextSpan(
                                text: 'tabs in case details page',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,),
                              )
                            ]
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Divider(
                    color: Colors.grey,
                  ),
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Text('4', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Rules of the app", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                RichText(
                  text: TextSpan(
                      text: 'If you find that someone has posted irrelevant or spam content in a case or in the discussion page, you can report that case or comment using the ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,),
                      children: <TextSpan>[
                        TextSpan(text: 'Report ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,),
                        ),
                        TextSpan(
                          text: 'option so that the admins can take action. This will help keep the app free from spammers and will help us focus on saving trees.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,),
                        )
                      ]
                  ),
                ),
                SizedBox(height: 20,),
                Image.asset('assets/GetStarted/get7.png', width: double.infinity, fit: BoxFit.fitWidth,),
                  SizedBox(height: 20,),
                Image.asset('assets/GetStarted/get8.png', width: double.infinity, fit: BoxFit.fitWidth,),
                SizedBox(height: 20,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex:0,
                        child: Text('*', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
                    SizedBox(width: 10,),
                    Expanded(child: Text("The admin has the right to ban a user from using the app on the grounds of irrelevance or misconduct.")),
                  ],
                ),
                  ],
                ),
              ),
              SizedBox(height: 10,),

              Stack(
                alignment: Alignment.center,
                children: [
                  Divider(
                    color: Colors.grey,
                  ),
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Text('5', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Finally, it is very important to know The Law of The Land when it comes to protection of trees. Different states in different countries have their own laws and we should be aware of our local laws.',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex:0,
                            child: Text('*', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
                        SizedBox(width: 10,),
                        Expanded(child: Text("According to the Delhi Preservation of Trees Act, 1994:")),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Text('1. Definition of a “tree”:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      'A “tree” is any woody plant whose branches spring from and are supported upon a trunk or body whose trunk or body is not less than 5 centimetres in diameter at a height of thirty centimetres from the ground level and is not less than one metre in height from the ground level.',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,),
                    ),
                    SizedBox(height: 20,),
                    Text('2. Definition of “felling a tree”:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,),
                    ),
                    SizedBox(height: 5,),
                    Text('The expression means severing the trunk from the roots, uprooting the tree and includes bulldozing, cutting, girdling, lopping, pollarding, applying arboricides, burning or damaging a tree in any other manner.',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,),
                    )
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Divider(
                    color: Colors.grey,
                  ),
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Text('6', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Watch the tutorials to learn:',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex:0,
                            child: Text('•', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                        ),
                        SizedBox(width: 10,),
                        Expanded(child: Text("How to post and share a case")),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex:0,
                            child: Text('•', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                        ),
                        SizedBox(width: 10,),
                        Expanded(child: Text("How to add a case to your watchlist")),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex:0,
                            child: Text('•', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                        ),
                        SizedBox(width: 10,),
                        Expanded(child: Text("How to update a case")),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex:0,
                            child: Text('•', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                        ),
                        SizedBox(width: 10,),
                        Expanded(child: Text("How to add new locations")),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex:0,
                            child: Text('•', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                        ),
                        SizedBox(width: 10,),
                        Expanded(child: Text("How post a case when you are offline")),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
      )
    );
  }

}
