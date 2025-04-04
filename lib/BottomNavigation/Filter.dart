import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:naturesociety_new/Utils/MaterialComponets.dart';
import 'package:naturesociety_new/Widgets/CommonFunction.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart' as picker;

class Filter extends StatefulWidget {
  final isFilterOn;

  Filter({@required this.isFilterOn});

  _Filter createState() => _Filter();
}

List<ValuePair> commonFilters = [
  ValuePair("cases posted by me", "Cases posted by me", false),
  ValuePair("cases updated by me", "Cases updated by me", false),
  ValuePair("cases on which i commented", "Cases on which I commented", false),
];

List<ValuePair> typeFilters = [
  ValuePair("tree is being cut", "Tree is being cut", false),
  ValuePair("tree might be cut", "Tree might be cut", false),
  ValuePair("tree has been cut", "Tree has been cut", false),
];

List<ValuePair> treesAffectedFilters = [
  ValuePair("less than 20", "Less than 20", false),
  ValuePair("20-100", "20 - 100", false),
  ValuePair("more than 100", "More than 100", false),
];

List<ValuePair> peopleWatchingFilters = [
  ValuePair("less than 20", "Less than 20", false),
  ValuePair("20-50", "20 - 50", false),
  ValuePair("more than 50", "More than 50", false),
];

List<ValuePair> commentCaseFilters = [
  ValuePair("less than 20", "Less than 20", false),
  ValuePair("20-50", "20 - 50", false),
  ValuePair("more than 50", "More than 50", false),
];
String selectedTAF = "", selectedPWF = "", selectedCCF = "";
List selectedCF = [], selectedTF = [];

DateTime? caseReportedFrom, caseReportedTo, caseUpdatedFrom, caseUpdatedTo;
late int appliedFilterLength;

class _Filter extends State<Filter> {
  int homeRadius = 1, officeRadius = 1;

  Future<bool> onWillPop() async {
    appliedFilterLength = 0;
    await resetFunction();
    Navigator.of(context).pop(json.encode(
        {"filter": {}, "length": widget.isFilterOn ? appliedFilterLength : 0}));
    return Future.value(false);
  }

  @override
  void initState() {
    super.initState();
    if (appliedFilterLength == null || appliedFilterLength < 0)
      appliedFilterLength = 0;
  }

  Future<void> resetFunction() async {
    for (int i = 0; i < commonFilters.length; i++)
      commonFilters[i].selected = false;
    for (int i = 0; i < typeFilters.length; i++)
      typeFilters[i].selected = false;
    for (int i = 0; i < treesAffectedFilters.length; i++)
      treesAffectedFilters[i].selected = false;
    for (int i = 0; i < peopleWatchingFilters.length; i++)
      peopleWatchingFilters[i].selected = false;
    for (int i = 0; i < commentCaseFilters.length; i++)
      commentCaseFilters[i].selected = false;
    caseReportedFrom = null;
    caseReportedTo = null;
    caseUpdatedFrom = null;
    caseUpdatedTo = null;
    appliedFilterLength = 0;

    selectedCF.clear();
    selectedPWF = "";
    selectedTAF = '';
    selectedTF.clear();
    selectedPWF = '';
    selectedCCF = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => onWillPop(),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "Filters",
            style: TextStyle(color: Colors.black),
          ),
          elevation: 1.0,
          actions: [
            appliedFilterLength > 0
                ? TextButton(
                    child: Text("Clear all",
                        style: TextStyle(
                            color: Colors.teal, fontWeight: FontWeight.w800)),
                    onPressed: () => resetFunction(),
                  )
                : SizedBox.shrink(),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: MaterialButton(
          onPressed: () {
            Map<String, dynamic> selectedFilter = {
              "common": selectedCF,
              "type": selectedTF,
              "affected": selectedTAF,
              "reportedfrom": caseReportedFrom != null
                  ? CommonFunction.calenderDateFormatter
                      .format(caseReportedFrom!)
                      .toString()
                  : "",
              "reportedto": caseReportedTo != null
                  ? CommonFunction.calenderDateFormatter
                      .format(caseReportedTo!)
                      .toString()
                  : "",
              "updatedfrom": caseUpdatedFrom != null
                  ? CommonFunction.calenderDateFormatter
                      .format(caseUpdatedFrom!)
                      .toString()
                  : "",
              "updatedto": caseUpdatedTo != null
                  ? CommonFunction.calenderDateFormatter
                      .format(caseUpdatedTo!)
                      .toString()
                  : "",
              "watch": selectedPWF,
              "comment": selectedCCF,
            };

            if (appliedFilterLength == 0 || appliedFilterLength < 0)
              Navigator.of(context)
                  .pop(json.encode({"filter": {}, "length": 0}));
            else
              Navigator.of(context).pop(json.encode(
                  {"filter": selectedFilter, "length": appliedFilterLength}));
          },
          minWidth: double.infinity,
          height: 60.0,
          color: Colors.teal.withOpacity(1),
          child: Text(
            "APPLY",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: SafeArea(
          child: AnimationLimiter(
            child: ListView(
              physics: ClampingScrollPhysics(),
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Common Filters", style: headingStyle),
                        SizedBox(
                          height: 10.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: commonFiltersWidget(context),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    height: 10.0,
                    color: Colors.grey.withOpacity(0.5),
                    thickness: 1.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Type of incidents", style: headingStyle),
                        SizedBox(
                          height: 10.0,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: typeFiltersWidget(context)),
                      ],
                    ),
                  ),
                  Divider(
                    height: 10.0,
                    color: Colors.grey.withOpacity(0.5),
                    thickness: 1.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Number of trees affected", style: headingStyle),
                        SizedBox(
                          height: 10.0,
                        ),
                        Wrap(children: treesAffectedFiltersWidget(context)),
                      ],
                    ),
                  ),
                  Divider(
                    height: 10.0,
                    color: Colors.grey.withOpacity(0.5),
                    thickness: 1.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Case reported between", style: headingStyle),
                        SizedBox(
                          height: 10.0,
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            ButtonTheme(
                              minWidth: 100.0,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: caseReportedFrom == null
                                      ? Colors.white
                                      : Colors.teal,
                                ),
                                label: Text(caseReportedFrom == null
                                    ? "       "
                                    : CommonFunction.calenderDateFormatter
                                        .format(caseReportedFrom!)),
                                icon: Icon(Icons.date_range),
                                onPressed: () =>
                                    _caseReportedFromPicker(context),
                              ),
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(" - "),
                            SizedBox(
                              width: 8.0,
                            ),
                            ButtonTheme(
                              minWidth: 100.0,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: caseReportedTo == null
                                      ? Colors.white
                                      : Colors.teal,
                                  foregroundColor: caseReportedTo == null
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                label: Text(caseReportedTo == null
                                    ? "       "
                                    : CommonFunction.calenderDateFormatter
                                        .format(caseReportedTo!)),
                                icon: Icon(Icons.date_range),
                                onPressed: () => _caseReportedToPicker(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 10.0,
                    color: Colors.grey.withOpacity(0.5),
                    thickness: 1.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Cases updated between", style: headingStyle),
                        SizedBox(
                          height: 10.0,
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            ButtonTheme(
                              minWidth: 100.0,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: caseUpdatedFrom == null
                                      ? Colors.white
                                      : Colors.teal,
                                  foregroundColor: caseUpdatedFrom == null
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                label: Text(caseUpdatedFrom == null
                                    ? "       "
                                    : CommonFunction.calenderDateFormatter
                                        .format(caseUpdatedFrom!)),
                                icon: Icon(Icons.date_range),
                                onPressed: () =>
                                    _caseUpdatedFromPicker(context),
                              ),
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(" - "),
                            SizedBox(
                              width: 8.0,
                            ),
                            ButtonTheme(
                              minWidth: 100.0,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: caseUpdatedTo == null
                                      ? Colors.white
                                      : Colors.teal,
                                  foregroundColor: caseUpdatedTo == null
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                label: Text(caseUpdatedTo == null
                                    ? "       "
                                    : CommonFunction.calenderDateFormatter
                                        .format(caseUpdatedTo!)),
                                icon: Icon(Icons.date_range),
                                onPressed: () => _caseUpdatedToPicker(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 10.0,
                    color: Colors.grey.withOpacity(0.5),
                    thickness: 1.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("People watching the case", style: headingStyle),
                        SizedBox(
                          height: 10.0,
                        ),
                        Wrap(children: peopleWatchingFiltersWidget(context)),
                      ],
                    ),
                  ),
                  Divider(
                    height: 10.0,
                    color: Colors.grey.withOpacity(0.5),
                    thickness: 1.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Comments on the case", style: headingStyle),
                        SizedBox(
                          height: 10.0,
                        ),
                        Wrap(children: commentCaseFiltersWidget(context)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 70.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final headingStyle = TextStyle(
      color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16.0);

  commonFiltersWidget(BuildContext context) {
    final List<Widget> loopList = <Widget>[];
    for (int i = 0; i < commonFilters.length; i++)
      loopList.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  commonFilters[i].selected ? Colors.teal : Colors.white,
              foregroundColor:
                  commonFilters[i].selected ? Colors.white : Colors.black,
            ),
            child: Text(commonFilters[i].value),
            onPressed: () async {
              selectedItem(commonFilters[i]);
              setState(() {
                if (commonFilters[i].selected) {
                  selectedCF.add(commonFilters[i].key);
                  appliedFilterLength++;
                } else {
                  selectedCF.remove(commonFilters[i].key);
                  appliedFilterLength--;
                }
                // commonFilters[i].selected? selectedCF.add(commonFilters[i].key) : selectedCF.remove(commonFilters[i].key);
              });
            },
          ),
        ),
      );
    return loopList;
  }

  typeFiltersWidget(BuildContext context) {
    final List<Widget> loopList = <Widget>[];
    for (int i = 0; i < typeFilters.length; i++)
      loopList.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  typeFilters[i].selected ? Colors.teal : Colors.white,
              foregroundColor:
                  typeFilters[i].selected ? Colors.white : Colors.black,
            ),
            child: Text(typeFilters[i].value,
                style: TextStyle(
                    color:
                        typeFilters[i].selected ? Colors.white : Colors.black)),
            onPressed: () async {
              selectedItem(typeFilters[i]);
              setState(() {
                if (typeFilters[i].selected) {
                  selectedTF.add(typeFilters[i].key);
                  appliedFilterLength++;
                } else {
                  selectedTF.remove(typeFilters[i].key);
                  appliedFilterLength--;
                }
                //typeFilters[i].selected? selectedTF.add(typeFilters[i].key) : selectedTF.remove(typeFilters[i].key);
              });
            },
          ),
        ),
      );
    return loopList;
  }

  treesAffectedFiltersWidget(BuildContext context) {
    final List<Widget> loopList = <Widget>[];
    for (int i = 0; i < treesAffectedFilters.length; i++)
      loopList.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  treesAffectedFilters[i].selected
                      ? Colors.teal
                      : Colors.white),
            ),
            child: Text(
              treesAffectedFilters[i].value,
              style: TextStyle(
                  color: treesAffectedFilters[i].selected
                      ? Colors.white
                      : Colors.black),
            ),
            onPressed: () async {
              if (treesAffectedFilters[i].selected) {
                selectedItem(treesAffectedFilters[i]);
                selectedTAF = '';
                appliedFilterLength--;
              } else {
                if (selectedTAF == null || selectedTAF == "") {
                  selectedItem(treesAffectedFilters[i]);
                  selectedTAF = treesAffectedFilters[i].key;
                  appliedFilterLength++;
                } else {
                  for (int i = 0; i < treesAffectedFilters.length; i++)
                    if (selectedTAF == treesAffectedFilters[i].key) {
                      selectedTAF = "";
                      appliedFilterLength--;
                    }
                  selectedItem(treesAffectedFilters[i]);
                  selectedTAF = treesAffectedFilters[i].key;
                  appliedFilterLength++;
                }
              }
            },
          ),
        ),
      );
    return loopList;
  }

  peopleWatchingFiltersWidget(BuildContext context) {
    final List<Widget> loopList = <Widget>[];
    for (int i = 0; i < peopleWatchingFilters.length; i++)
      loopList.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  peopleWatchingFilters[i].selected
                      ? Colors.teal
                      : Colors.white),
            ),
            child: Text(
              peopleWatchingFilters[i].value,
              style: TextStyle(
                  color: peopleWatchingFilters[i].selected
                      ? Colors.white
                      : Colors.black),
            ),
            onPressed: () async {
              if (peopleWatchingFilters[i].selected) {
                selectedItem(peopleWatchingFilters[i]);
                selectedCCF = '';
                appliedFilterLength--;
              } else {
                if (selectedPWF == null || selectedPWF == "") {
                  selectedItem(peopleWatchingFilters[i]);
                  selectedPWF = peopleWatchingFilters[i].key;
                  appliedFilterLength++;
                } else {
                  for (int i = 0; i < peopleWatchingFilters.length; i++)
                    if (selectedPWF == peopleWatchingFilters[i].key) {
                      selectedItem(peopleWatchingFilters[i]);
                      selectedCCF = '';
                      appliedFilterLength--;
                    }
                  selectedItem(peopleWatchingFilters[i]);
                  selectedPWF = peopleWatchingFilters[i].key;
                  appliedFilterLength++;
                }
              }
            },
          ),
        ),
      );
    return loopList;
  }

  commentCaseFiltersWidget(BuildContext context) {
    final List<Widget> loopList = <Widget>[];
    for (int i = 0; i < commentCaseFilters.length; i++)
      loopList.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  commentCaseFilters[i].selected
                      ? Colors.teal
                      : Colors.white),
            ),
            child: Text(
              commentCaseFilters[i].value,
              style: TextStyle(
                  color: commentCaseFilters[i].selected
                      ? Colors.white
                      : Colors.black),
            ),
            onPressed: () {
              if (commentCaseFilters[i].selected) {
                selectedItem(commentCaseFilters[i]);
                selectedCCF = '';
                appliedFilterLength--;
              } else {
                if (selectedCCF == null || selectedCCF == "") {
                  selectedItem(commentCaseFilters[i]);
                  selectedCCF = commentCaseFilters[i].key;
                  appliedFilterLength++;
                } else {
                  for (int i = 0; i < commentCaseFilters.length; i++)
                    if (selectedCCF == commentCaseFilters[i].key) {
                      selectedItem(commentCaseFilters[i]);
                      selectedCCF = '';
                      appliedFilterLength--;
                    }
                  selectedItem(commentCaseFilters[i]);
                  selectedCCF = commentCaseFilters[i].key;
                  appliedFilterLength++;
                }
              }
            },
          ),
        ),
      );
    return loopList;
  }

  void selectedItem(item) {
    setState(() {
      if (item.selected)
        item.setter(false);
      else
        item.setter(true);
    });
  }

  Future<Null> _caseReportedFromPicker(BuildContext context) async {
    DatePicker.showDatePicker(context,
        theme: picker.DatePickerTheme(
            containerHeight: 210.0,
            itemStyle: TextStyle(color: Colors.teal),
            doneStyle: TextStyle(color: MaterialTools.basicColor, fontWeight: FontWeight.w800)),
        showTitleActions: true,
        minTime: DateTime(1917, 1),
        maxTime: caseReportedTo != null ? caseReportedTo : DateTime.now(),
        onChanged: (date) {}, onConfirm: (date) {
      caseReportedFrom = date;
      if (caseReportedTo == null) appliedFilterLength++;
      setState(() {});
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  Future<Null> _caseReportedToPicker(BuildContext context) async {
    DatePicker.showDatePicker(context,
        theme: picker.DatePickerTheme(
            containerHeight: 210.0,
            itemStyle: const TextStyle(color: Colors.teal),
            doneStyle: TextStyle(color: MaterialTools.basicColor, fontWeight: FontWeight.w800)),
        showTitleActions: true,
        minTime:
            caseReportedFrom != null ? caseReportedFrom : DateTime(1917, 1),
        maxTime: DateTime.now(),
        onChanged: (date) {}, onConfirm: (date) {
      caseReportedTo = date;
      if (caseReportedFrom == null) appliedFilterLength++;
      setState(() {});
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  Future<Null> _caseUpdatedFromPicker(BuildContext context) async {
    DatePicker.showDatePicker(context,
        theme: picker.DatePickerTheme(
            itemStyle: TextStyle(color: Colors.teal),
            doneStyle: TextStyle(
                color: MaterialTools.basicColor, fontWeight: FontWeight.w800)),
        showTitleActions: true,
        minTime: DateTime(1917, 1),
        maxTime: caseUpdatedTo != null ? caseUpdatedTo : DateTime.now(),
        onChanged: (date) {}, onConfirm: (date) {
      caseUpdatedFrom = date;
      if (caseUpdatedTo == null) appliedFilterLength++;
      setState(() {});
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  Future<Null> _caseUpdatedToPicker(BuildContext context) async {
    DatePicker.showDatePicker(context,
        theme: picker.DatePickerTheme(
            itemStyle: TextStyle(color: Colors.teal),
            doneStyle: TextStyle(
                color: MaterialTools.basicColor, fontWeight: FontWeight.w800)),
        showTitleActions: true,
        minTime: caseUpdatedFrom != null ? caseUpdatedFrom : DateTime(1917, 1),
        maxTime: DateTime.now(),
        onChanged: (date) {}, onConfirm: (date) {
      caseUpdatedTo = date;
      if (caseUpdatedFrom == null) appliedFilterLength++;
      setState(() {});
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }
}

class ValuePair {
  var key;
  var value;
  bool selected;

  setter(selected) {
    this.selected = selected;
  }

  ValuePair(this.key, this.value, this.selected);
}
