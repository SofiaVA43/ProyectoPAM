import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Material(
              color: Theme.of(context).primaryColor,
              elevation: 8,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: InkWell(
                  onTap: () {},
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                    Stack(children: <Widget>[
                      Ink.image(
                          image:
                              AssetImage("assets/images/mountain_sunset.jpg"),
                          height: 90,
                          width: MediaQuery.of(context).size.width * 0.4,
                          fit: BoxFit.cover),
                    ]),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.only(left: 3, right: 3),
                      child: Column(
                        children: [
                          Text("Place Name", overflow: TextOverflow.fade)
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ]))),
        ],
      ),
    );
  }
}
