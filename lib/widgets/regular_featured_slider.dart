import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/featured_bloc.dart';
import 'package:travel_hour/services/drag_scroll.dart';
import 'package:travel_hour/utils/loading_cards.dart';
import 'package:travel_hour/widgets/regular_featured_card.dart';
import 'package:easy_localization/easy_localization.dart';

class RegularFeaturedSlider extends StatelessWidget {
  final double width;

  const RegularFeaturedSlider({
    Key? key,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fb = context.watch<FeaturedBloc>();

    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: SizedBox(
        width: width,
        height: 290,
        child: PageView.builder(
          controller: PageController(initialPage: 0),
          scrollDirection: Axis.horizontal,
          itemCount: fb.data.isEmpty ? 1 : fb.data.length,
          onPageChanged: (index) {
            context.read<FeaturedBloc>().setListIndex(index);
          },
          itemBuilder: (BuildContext context, int index) {
            if (fb.data.isEmpty) {
              if (fb.hasData == false) {
                return _EmptyContent();
              } else {
                return LoadingFeaturedCard();
              }
            }
            return RegularFeaturedCard(d: fb.data[index]);
          },
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 220,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
      child: Center(
        child: Text("no content", style: _textStyleMedium).tr(),
      ),
    );
  }
}
