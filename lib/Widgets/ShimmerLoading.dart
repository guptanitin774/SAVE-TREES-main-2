
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading{
  static Widget loadingCaseShimmer(BuildContext context) {
    return  Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
              enabled: true,
              child: ListView.builder(
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 60.0,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                    Spacer(),
                                    Container(
                                      width: 10.0,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8.0,),
                                    Container(
                                      width: 10.0,
                                      height: 8.0,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.0,),
                                Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Container(
                                  width: 40.0,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 8.0,),

                      Container(
                        width: double.infinity,
                        height: 200.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                itemCount: 6,
              ),
            ),
          ),

        ],
      ),
    );
  }



  static Widget listShimmerLoading(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
              enabled: true,
              child: ListView.builder(
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        width: 50.0,
                        height: 50.0,
                        color: Colors.white,
                      ),

                      Padding(padding: EdgeInsets.symmetric(horizontal: 8.0)),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 10.0,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                            Container(
                              height: 10.0,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                            Container(
                              height: 10.0,
                              width: 50,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                itemCount: 10,
              ),
            ),
          ),

        ],
      ),
    );
  }


  static Widget profileShimmerLoading(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
              enabled: true,
              child: ListView.builder(
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        width: 50.0,
                        height: 50.0,
                        color: Colors.white,
                      ),

                      Padding(padding: EdgeInsets.symmetric(horizontal: 8.0)),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 10.0,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                            Container(
                              height: 10.0,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                            Container(
                              height: 10.0,
                              width: 50,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                itemCount: 10,
              ),
            ),
          ),

        ],
      ),
    );
  }
}