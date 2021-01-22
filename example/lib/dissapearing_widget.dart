import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DissapearingWidget extends ImplicitlyAnimatedWidget {
  /// Creates a widget that animates its opacity implicitly.
  ///
  /// The [opacity] argument must not be null and must be between 0.0 and 1.0,
  /// inclusive. The [curve] and [duration] arguments must not be null.
  const DissapearingWidget({
    Key key,
    this.child,
    Curve curve = Curves.linear,
    @required Duration duration,
    VoidCallback onEnd,
    this.alwaysIncludeSemantics = false,
  }) : super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// Whether the semantic information of the children is always included.
  ///
  /// Defaults to false.
  ///
  /// When true, regardless of the opacity settings the child semantic
  /// information is exposed as if the widget were fully visible. This is
  /// useful in cases where labels may be hidden during animations that
  /// would otherwise contribute relevant semantics.
  final bool alwaysIncludeSemantics;

  @override
  _DissapearingWidgetState createState() => _DissapearingWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('opacity', 1));
  }
}

class _DissapearingWidgetState
    extends ImplicitlyAnimatedWidgetState<DissapearingWidget> {
  Tween<double> _opacity;
  Animation<double> _opacityAnimation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _opacity = visitor(_opacity, 1.0,
            (dynamic value) => ReverseTween<double>(Tween<double>(begin: value as double, end: 0.0)))
        as ReverseTween<double>;
  }

  @override
  void didUpdateTweens() {
    _opacityAnimation = animation.drive(_opacity);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: widget.child,
      alwaysIncludeSemantics: widget.alwaysIncludeSemantics,
    );
  }
}
