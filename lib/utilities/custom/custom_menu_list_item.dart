import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/services/theme_service.dart';

class CustomMenuListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasNavigation;
  final void Function()? onTap;

  const CustomMenuListItem({
    Key? key,
    required this.icon,
    required this.text,
    this.hasNavigation = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: kIsWeb ? 50 : kSpacingUnit.w * 5.5,
        margin: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 40 : kSpacingUnit.w * 4,
        ).copyWith(
          bottom: kIsWeb ? 20 : kSpacingUnit.w * 2,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 20 : kSpacingUnit.w * 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kIsWeb ? 30 : kSpacingUnit.w * 3),
          color: Theme.of(context).backgroundColor,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: kIsWeb ? 20 : kSpacingUnit.w * 2.5,
            ),
            SizedBox(width: kIsWeb ? 15 : kSpacingUnit.w * 1.5),
            Text(
              text,
              style: kIsWeb
                  ? kTitleTextStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    )
                  : kTitleTextStyle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
            ),
            const Spacer(),
            if (hasNavigation)
              Icon(
                Icons.arrow_right,
                size: kIsWeb ? 20 : kSpacingUnit.w * 2.5,
              ),
          ],
        ),
      ),
    );
  }
}
