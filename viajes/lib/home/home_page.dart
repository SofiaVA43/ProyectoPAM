import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:viajes/custom_widgets/custom_icon_button.dart';
import 'package:viajes/custom_widgets/location_card.dart';
import 'package:viajes/custom_widgets/nav_bar.dart';
import 'package:viajes/location/location_page.dart';
import 'bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();

  FocusNode searchFocus = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;
  bool isFocusSearch = false;
  var prevState = null;

  @override
  void initState() {
    super.initState();
    searchFocus.addListener(_onFocusChange);
    BlocProvider.of<HomeBloc>(context).add(GetPlacesEvent());

    // Subscribe when keyboard on focus
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        FocusScope.of(context).unfocus();
        BlocProvider.of<HomeBloc>(context)
            .add(ResetSearchEvent(prevState: prevState));
      } else {
        searchFocus.requestFocus();
        BlocProvider.of<HomeBloc>(context).add(BeginTypingEvent());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchFocus.removeListener(_onFocusChange);
    searchFocus.dispose();
  }

  void _onFocusChange() {
    isFocusSearch = searchFocus.hasFocus;

    debugPrint("Focus: ${searchFocus.hasFocus.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.25,
                  floating: false,
                  pinned: true,
                  actions: <Widget>[
                    IconButton(
                        onPressed: () {},
                        icon: FaIcon(FontAwesomeIcons.featherPointed)),
                    Padding(padding: EdgeInsets.all(6))
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                          child: Center(
                              child: Text("Find a new experience",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 22))))),
                  bottom: AppBar(
                    automaticallyImplyLeading: false,
                    toolbarHeight: kToolbarHeight + 30,
                    title: Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white),
                            width: double.infinity,
                            height: 40,
                            child: Center(child: _searchBar(context))),
                        SizedBox(height: 5)
                      ],
                    ),
                  )),
            ];
          },
          body: CustomScrollView(slivers: <Widget>[
            SliverList(
                delegate: SliverChildListDelegate([
              Container(
                padding: EdgeInsets.all(20),
                child: BlocConsumer<HomeBloc, HomeState>(
                  listener: (context, state) {
                    print('--------------------------------');
                    print('State: ${state}');
                    if (!(state is isTypingState)) prevState = state;
                    if (state is HomeInitial) {
                      BlocProvider.of<HomeBloc>(context).add(GetPlacesEvent());
                    }
                  },
                  builder: (context, state) {
                    if (state is LoadingState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(child: CircularProgressIndicator()),
                        ],
                      );
                    } else if (state is ResultsState) {
                      return resultsView(context);
                    } else if (state is isTypingState) {
                      return Column(children: [
                        Center(
                          child: Text('Searching...'),
                        ),
                      ]);
                    } else {
                      List places =
                          BlocProvider.of<HomeBloc>(context).getHomePlaces;

                      return defaultView(context, places);
                    }
                  },
                ),
              )
            ]))
          ]),
        ));
  }

  Column resultsView(BuildContext context) {
    return Column(children: [
      Row(children: [
        IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              BlocProvider.of<HomeBloc>(context)
                  .add(ResetSearchEvent(prevState: null));
            }),
        Expanded(child: Center(child: Text('Showing your search results')))
      ])
    ]);
  }

  Column defaultView(BuildContext context, places) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text("Categories",
                style: Theme.of(context).textTheme.headline6)),
        SizedBox(height: 20),
        Container(height: 65, child: _categoriesIcons()),
        Align(
            alignment: Alignment.centerLeft,
            child:
                Text("Nearby", style: Theme.of(context).textTheme.headline6)),
        SizedBox(height: 20),
        Container(height: 170, child: _nearbyPlaces(places)),
        Align(
            alignment: Alignment.centerLeft,
            child:
                Text("Popular", style: Theme.of(context).textTheme.headline6)),
        SizedBox(height: 20),
        SizedBox(
            height: 160,
            child: LocationCard(
              width: 0.9,
              onTapCard: () {
                // TODO: Send data to locationPage
                //Navigator.pushNamed(context, '/LocationPage');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LocationPage(locationID: places[0]['id'])));
              },
              place: {},
            )),
      ],
    );
  }

  Widget _searchBar(BuildContext context) {
    return TextField(
      focusNode: searchFocus,
      enableSuggestions: true,
      controller: searchController,
      decoration: InputDecoration(
        hintText: "Search a place",
        contentPadding: EdgeInsets.all(0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        prefixIcon: IconButton(
            icon: isFocusSearch ? Icon(Icons.close) : Icon(Icons.search),
            onPressed: () {
              if (isFocusSearch) {
                FocusScope.of(context).requestFocus(null);
                searchController.clear();
              }

              setState(() {});

              //TODO: Search
              BlocProvider.of<HomeBloc>(context)
                  .add(SearchEvent(searchString: searchController.text));
            }),
        suffixIcon: IconButton(
            icon: Icon(Icons.tune),
            onPressed: () {
              // TODO: Filter/sort actions
            }),
      ),
      onSubmitted: (value) {
        // TODO: Search
        BlocProvider.of<HomeBloc>(context)
            .add(SearchEvent(searchString: searchController.text));
      },
    );
  }

  Widget _categoriesIcons() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 5),
      itemCount: 9,
      itemBuilder: (BuildContext context, int index) {
        return CustomIconButton(
          iconID: 61668,
          iconFamily: 'FontAwesomeSolid',
          buttonSize: 60,
          iconColor: Theme.of(context).iconTheme.color,
          buttonColor: Colors.amberAccent[100],
          onButtonPressed: () {
            //TODO: Filter search
            print('alo');
          },
        );
      },
    );
  }

  Widget _nearbyPlaces(List places) {
    return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.only(left: 5, bottom: 10),
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              margin: EdgeInsets.only(right: 10),
              child: LocationCard(
                width: 0.4,
                onTapCard: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          LocationPage(locationID: places[index]['id'])));
                },
                place: places[index],
              ));
        });
  }
}
