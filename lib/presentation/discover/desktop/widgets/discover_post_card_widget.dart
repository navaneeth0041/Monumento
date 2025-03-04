import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monumento/domain/entities/post_entity.dart';
import 'package:monumento/gen/assets.gen.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class DiscoverPostCardWidget extends StatefulWidget {
  final PostEntity post;
  final VoidCallback onTap;
  const DiscoverPostCardWidget({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  State<DiscoverPostCardWidget> createState() => _DiscoverPostCardWidgetState();
}

class _DiscoverPostCardWidgetState extends State<DiscoverPostCardWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (value) {
        setState(() {
          isHovered = value;
        });
      },
      child: CachedNetworkImage(
        imageUrl: widget.post.imageUrl!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.sp),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              colorFilter: isHovered
                  ? ColorFilter.mode(
                      Colors.black.withOpacity(0.6),
                      BlendMode.darken,
                    )
                  : null,
            ),
          ),
          child: isHovered
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        Assets.icons.icHeart.path,
                        color: Colors.white,
                        height: 18.sp,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        widget.post.likesCount.toString(),
                        style: AppTextStyles.s16(
                          color: AppColor.appWhite,
                          fontType: FontType.MEDIUM,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SvgPicture.asset(
                        Assets.icons.icComment.path,
                        color: Colors.white,
                        height: 18.sp,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        widget.post.commentsCount.toString(),
                        style: AppTextStyles.s16(
                          color: AppColor.appWhite,
                          fontType: FontType.MEDIUM,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
