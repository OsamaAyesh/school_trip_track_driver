import 'package:flutter/material.dart';
import 'package:school_trip_track_driver/utils/size_config.dart';
import 'package:shimmer/shimmer.dart';

enum ShimmerType { vlist, hlist, grid, card, circle, text, image, form }

class ShimmerOptions
{
  ShimmerType? type;
  double? width;
  int? lines, cells;
  double? height;
  double? radius;
  double? spacing;
  double? margin;
  double? padding;
  
  ShimmerOptions({this.type, this.width, this.lines, this.cells, this.height, this.radius, this.spacing, this.margin, this.padding});
  
  vListOptions(linesCount)
  {
    type = ShimmerType.vlist;
    width = 0.9;
    lines = linesCount;
    return this;
  }
  hListOptions(cellCount, width)
  {
    type = ShimmerType.hlist;
    cells = cellCount;
    this.width = width;
    return this;
  }
}

class Shimmers extends StatefulWidget {
  final ShimmerOptions? options;
  const Shimmers({Key? key,this.options}) : super(key: key);

  @override
  ShimmersState createState() => ShimmersState();
}

class ShimmersState extends State<Shimmers> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    if(widget.options!.type == ShimmerType.vlist) {
      return vList(widget.options!.lines!);
    }
    else if(widget.options!.type == ShimmerType.hlist) {
      return hList(widget.options!.cells!, widget.options!.width!);
    }
    // else if(widget.options!.type == shimmerType.grid)
    //   return grid();
    // else if(widget.options!.type == shimmerType.card)
    //   return card();
    // else if(widget.options!.type == shimmerType.circle)
    //   return circle();
    // else if(widget.options!.type == shimmerType.text)
    //   return text();
    // else if(widget.options!.type == shimmerType.image)
    //   return image();
    // else if(widget.options!.type == shimmerType.form)
    //   return form();
    else {
      return Container();
    }
  }

  Widget vList(int c) {
    return ListView(
      children: List.generate(10, (i) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 1,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: List.generate(c, (i) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
              )
          ),
        );
      }),
    );
  }

  Widget hList(int c, double d) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(10, (i) {
        return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 1,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: List.generate(c, (j) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: SizeConfig.screenWidth! * d,
                      height: 10.0,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            )
        );
      }),
    );
  }
}
