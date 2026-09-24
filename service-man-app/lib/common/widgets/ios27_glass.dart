import 'package:demandium_serviceman/theme/ios27_tokens.dart';
import 'package:flutter/material.dart';

enum Ios27GlassSize { large, medium, small }

class Ios27Glass extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final Ios27GlassSize size;
  final bool prominent;
  final EdgeInsetsGeometry? padding;
  final bool clip;

  const Ios27Glass({
    super.key,
    required this.child,
    this.borderRadius,
    this.size = Ios27GlassSize.medium,
    this.prominent = false,
    this.padding,
    this.clip = true,
  });

  double get _radius {
    switch (size) {
      case Ios27GlassSize.large:
      case Ios27GlassSize.medium:
        return Ios27Tokens.radiusLg;
      case Ios27GlassSize.small:
        return Ios27Tokens.radiusPill;
    }
  }

  double get _blur {
    switch (size) {
      case Ios27GlassSize.large:
      case Ios27GlassSize.medium:
        return Ios27Tokens.blurRegular;
      case Ios27GlassSize.small:
        return Ios27Tokens.blurSmall;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(_radius);
    final reduce = Ios27Tokens.reduceTransparency(context);
    final fill = Ios27Tokens.glassFill(context, prominent: prominent);
    final rim = Ios27Tokens.rim(context, small: size == Ios27GlassSize.small);

    final panel = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: rim, width: 0.5),
        boxShadow: Ios27Tokens.glassShadow(context, small: size == Ios27GlassSize.small),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(Colors.white, fill, 0.35) ?? fill,
            fill,
            Color.lerp(Colors.black, fill, 0.92) ?? fill,
          ],
          stops: const [0, 0.4, 1],
        ),
      ),
      child: child,
    );

    if (reduce) {
      return clip ? ClipRRect(borderRadius: radius, child: panel) : panel;
    }

    final blurred = BackdropFilter(
      filter: Ios27Tokens.blurFilter(context, base: _blur),
      child: panel,
    );

    return clip ? ClipRRect(borderRadius: radius, child: blurred) : blurred;
  }
}

class Ios27Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? color;

  const Ios27Card({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.radius = Ios27Tokens.radiusMd,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Ios27Tokens.rim(context), width: 0.5),
        boxShadow: Ios27Tokens.cardShadow(context),
      ),
      child: child,
    );
  }
}
