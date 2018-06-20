import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// TODO(dragostis): Missing functionality:
//   * mobile horizontal mode with adding/removing steps
//   * alternative labeling
//   * stepper feedback in the case of high-latency interactions

/// The state of a [CustomStep] which is used to control the style of the circle and
/// text.
///
/// See also:
///
///  * [CustomStep]
enum CustomStepState {
  /// A step that displays its index in its circle.
  indexed,

  /// A step that displays a pencil icon in its circle.
  editing,

  /// A step that displays a tick icon in its circle.
  complete,

  /// A step that is disabled and does not to react to taps.
  disabled,

  /// A step that is currently having an error. e.g. the use has submitted wrong
  /// input.
  error,
}

/// Defines the [CustomStepper]'s main axis.
enum CustomStepperType {
  /// A vertical layout of the steps with their content in-between the titles.
  vertical,

  /// A horizontal layout of the steps with their content below the titles.
  horizontal,
}

const TextStyle _kCustomStepStyle = const TextStyle(
  fontSize: 12.0,
  color: Colors.white,
);
const Color _kErrorLight = Colors.red;
final Color _kErrorDark = Colors.red.shade400;
const Color _kCircleActiveLight = Colors.white;
const Color _kCircleActiveDark = Colors.black87;
const Color _kDisabledLight = Colors.black38;
const Color _kDisabledDark = Colors.white30;
const double _kCustomStepSize = 24.0;
const double _kTriangleHeight =
    _kCustomStepSize * 0.866025; // Triangle height. sqrt(3.0) / 2.0

/// A material step used in [CustomStepper]. The step can have a title and subtitle,
/// an icon within its circle, some content and a state that governs its
/// styling.
///
/// See also:
///
///  * [CustomStepper]
///  * <https://material.google.com/components/steppers.html>
@immutable
class CustomStep {
  /// Creates a step for a [CustomStepper].
  ///
  /// The [title], [content], and [state] arguments must not be null.
  CustomStep({
    @required this.title,
    this.subtitle,
    @required this.content,
    this.state: CustomStepState.indexed,
    this.isActive: false,
  })  : assert(title != null),
        assert(content != null),
        assert(state != null);

  /// The title of the step that typically describes it.
  Widget title;

  /// The subtitle of the step that appears below the title and has a smaller
  /// font size. It typically gives more details that complement the title.
  ///
  /// If null, the subtitle is not shown.
  Widget subtitle;

  /// The content of the step that appears below the [title] and [subtitle].
  ///
  /// Below the content, every step has a 'continue' and 'cancel' button.
  Widget content;

  /// The state of the step which determines the styling of its components
  /// and whether steps are interactive.
  CustomStepState state;

  /// Whether or not the step is active. The flag only influences styling.
  bool isActive;
}

/// A material stepper widget that displays progress through a sequence of
/// steps. CustomSteppers are particularly useful in the case of forms where one step
/// requires the completion of another one, or where multiple steps need to be
/// completed in order to submit the whole form.
///
/// The widget is a flexible wrapper. A parent class should pass [currentCustomStep]
/// to this widget based on some logic triggered by the three callbacks that it
/// provides.
///
/// See also:
///
///  * [CustomStep]
///  * <https://material.google.com/components/steppers.html>
class CustomStepper extends StatefulWidget {
  /// Creates a stepper from a list of steps.
  ///
  /// This widget is not meant to be rebuilt with a different list of steps
  /// unless a key is provided in order to distinguish the old stepper from the
  /// new one.
  ///
  /// The [steps], [type], and [currentCustomStep] arguments must not be null.
  CustomStepper({
    Key key,
    @required this.steps,
    this.type: CustomStepperType.vertical,
    this.currentCustomStep: 0,
    this.onCustomStepTapped,
    this.onCustomStepContinue,
    this.onCustomStepCancel,
  })  : assert(steps != null),
        assert(type != null),
        assert(currentCustomStep != null),
        assert(0 <= currentCustomStep && currentCustomStep < steps.length),
        super(key: key);

  /// The steps of the stepper whose titles, subtitles, icons always get shown.
  ///
  /// The length of [steps] must not change.
  final List<CustomStep> steps;

  /// The type of stepper that determines the layout. In the case of
  /// [CustomStepperType.horizontal], the content of the current step is displayed
  /// underneath as opposed to the [CustomStepperType.vertical] case where it is
  /// displayed in-between.
  final CustomStepperType type;

  /// The index into [steps] of the current step whose content is displayed.
  final int currentCustomStep;

  /// The callback called when a step is tapped, with its index passed as
  /// an argument.
  final ValueChanged<int> onCustomStepTapped;

  /// The callback called when the 'continue' button is tapped.
  ///
  /// If null, the 'continue' button will be disabled.
  final VoidCallback onCustomStepContinue;

  /// The callback called when the 'cancel' button is tapped.
  ///
  /// If null, the 'cancel' button will be disabled.
  final VoidCallback onCustomStepCancel;

  @override
  _CustomStepperState createState() => new _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper>
    with TickerProviderStateMixin {
  List<GlobalKey> _keys;
  final Map<int, CustomStepState> _oldStates = <int, CustomStepState>{};

  @override
  void initState() {
    super.initState();
    _keys = new List<GlobalKey>.generate(
      widget.steps.length,
      (int i) => new GlobalKey(),
    );

    for (int i = 0; i < widget.steps.length; i += 1)
      _oldStates[i] = widget.steps[i].state;
  }

  @override
  void didUpdateWidget(CustomStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.steps.length == oldWidget.steps.length);

    for (int i = 0; i < oldWidget.steps.length; i += 1)
      _oldStates[i] = oldWidget.steps[i].state;
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps.length - 1 == index;
  }

  bool _isCurrent(int index) {
    return widget.currentCustomStep == index;
  }

  bool _isDark() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Widget _buildLine(bool visible) {
    return new Container(
      width: visible ? 1.0 : 0.0,
      height: 16.0,
      color: Colors.grey.shade400,
    );
  }

  Widget _buildCircleChild(int index, bool oldState) {
    final CustomStepState state =
        oldState ? _oldStates[index] : widget.steps[index].state;
    final bool isDarkActive = _isDark() && widget.steps[index].isActive;
    assert(state != null);
    switch (state) {
      case CustomStepState.indexed:
      case CustomStepState.disabled:
        return new Text(
          '${index + 1}',
          style: isDarkActive
              ? _kCustomStepStyle.copyWith(color: Colors.black87)
              : _kCustomStepStyle,
        );
      case CustomStepState.editing:
        return new Icon(
          Icons.edit,
          color: isDarkActive ? _kCircleActiveDark : _kCircleActiveLight,
        );
      case CustomStepState.complete:
        return new Icon(
          Icons.check,
          color: isDarkActive ? _kCircleActiveDark : _kCircleActiveLight,
        );
      case CustomStepState.error:
        return const Text('!', style: _kCustomStepStyle);
    }
    return null;
  }

  Color _circleColor(int index) {
    final ThemeData themeData = Theme.of(context);
    if (!_isDark()) {
      return index == widget.currentCustomStep || widget.steps[index].isActive
          ? themeData.primaryColor
          : Colors.black38;
    } else {
      return index == widget.currentCustomStep || widget.steps[index].isActive
          ? themeData.accentColor
          : themeData.backgroundColor;
    }
  }

  Widget _buildCircle(int index, bool oldState) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: _kCustomStepSize,
      height: _kCustomStepSize,
      child: new AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: kThemeAnimationDuration,
        decoration: new BoxDecoration(
          color: _circleColor(index),
          shape: BoxShape.circle,
        ),
        child: new Center(
          child: _buildCircleChild(index,
              oldState && widget.steps[index].state == CustomStepState.error),
        ),
      ),
    );
  }

  Widget _buildTriangle(int index, bool oldState) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: _kCustomStepSize,
      height: _kCustomStepSize,
      child: new Center(
        child: new SizedBox(
          width: _kCustomStepSize,
          height:
              _kTriangleHeight, // Height of 24dp-long-sided equilateral triangle.
          child: new CustomPaint(
            painter: new _TrianglePainter(
              color: _isDark() ? _kErrorDark : _kErrorLight,
            ),
            child: new Align(
              alignment: const Alignment(
                  0.0, 0.8), // 0.8 looks better than the geometrical 0.33.
              child: _buildCircleChild(
                  index,
                  oldState &&
                      widget.steps[index].state != CustomStepState.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(int index) {
    if (widget.steps[index].state != _oldStates[index]) {
      return new AnimatedCrossFade(
        firstChild: _buildCircle(index, true),
        secondChild: _buildTriangle(index, true),
        firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.fastOutSlowIn,
        crossFadeState: widget.steps[index].state == CustomStepState.error
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: kThemeAnimationDuration,
      );
    } else {
      if (widget.steps[index].state != CustomStepState.error)
        return _buildCircle(index, false);
      else
        return _buildTriangle(index, false);
    }
  }

  Widget _buildVerticalControls(int index) {
    Color cancelColor;

    switch (Theme.of(context).brightness) {
      case Brightness.light:
        cancelColor = Colors.black54;
        break;
      case Brightness.dark:
        cancelColor = Colors.white70;
        break;
    }

    assert(cancelColor != null);

    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    return new Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: new ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 48.0),
        child: new Row(
          children: <Widget>[
            index != 0
                ? new FlatButton(
                    onPressed: widget.onCustomStepCancel,
                    textColor: cancelColor,
                    textTheme: ButtonTextTheme.normal,
                    child: new Text("Zurück"),
                  )
                : Container(),
            new Container(
              margin: const EdgeInsetsDirectional.only(start: 8.0),
              child: index != widget.steps.length - 1
                  ? new FlatButton(
                      onPressed: widget.onCustomStepContinue,
                      color: _isDark()
                          ? themeData.backgroundColor
                          : themeData.primaryColor,
                      textColor: Colors.white,
                      textTheme: ButtonTextTheme.normal,
                      child: new Text("Weiter"),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _titleStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    assert(widget.steps[index].state != null);
    switch (widget.steps[index].state) {
      case CustomStepState.indexed:
      case CustomStepState.editing:
      case CustomStepState.complete:
        return textTheme.body2;
      case CustomStepState.disabled:
        return textTheme.body2
            .copyWith(color: _isDark() ? _kDisabledDark : _kDisabledLight);
      case CustomStepState.error:
        return textTheme.body2
            .copyWith(color: _isDark() ? _kErrorDark : _kErrorLight);
    }
    return null;
  }

  TextStyle _subtitleStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    assert(widget.steps[index].state != null);
    switch (widget.steps[index].state) {
      case CustomStepState.indexed:
      case CustomStepState.editing:
      case CustomStepState.complete:
        return textTheme.caption;
      case CustomStepState.disabled:
        return textTheme.caption
            .copyWith(color: _isDark() ? _kDisabledDark : _kDisabledLight);
      case CustomStepState.error:
        return textTheme.caption
            .copyWith(color: _isDark() ? _kErrorDark : _kErrorLight);
    }
    return null;
  }

  Widget _buildHeaderText(int index) {
    final List<Widget> children = <Widget>[
      new AnimatedDefaultTextStyle(
        style: _titleStyle(index),
        duration: kThemeAnimationDuration,
        curve: Curves.fastOutSlowIn,
        child: widget.steps[index].title,
      ),
    ];

    if (widget.steps[index].subtitle != null)
      children.add(
        new Container(
          margin: const EdgeInsets.only(top: 2.0),
          child: new AnimatedDefaultTextStyle(
            style: _subtitleStyle(index),
            duration: kThemeAnimationDuration,
            curve: Curves.fastOutSlowIn,
            child: widget.steps[index].subtitle,
          ),
        ),
      );

    return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children);
  }

  Widget _buildVerticalHeader(int index) {
    return new Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        child: new Row(children: <Widget>[
          new Column(children: <Widget>[
            // Line parts are always added in order for the ink splash to
            // flood the tips of the connector lines.
            _buildLine(!_isFirst(index)),
            _buildIcon(index),
            _buildLine(!_isLast(index)),
          ]),
          new Container(
              margin: const EdgeInsetsDirectional.only(start: 12.0),
              child: _buildHeaderText(index))
        ]));
  }

  Widget _buildVerticalBody(int index) {
    return new Stack(
      children: <Widget>[
        new PositionedDirectional(
          start: 24.0,
          top: 0.0,
          bottom: 0.0,
          child: new SizedBox(
            width: 24.0,
            child: new Center(
              child: new SizedBox(
                width: _isLast(index) ? 0.0 : 1.0,
                child: new Container(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
        new AnimatedCrossFade(
          firstChild: new Container(height: 0.0),
          secondChild: new Container(
            margin: const EdgeInsetsDirectional.only(
              start: 60.0,
              end: 24.0,
              bottom: 24.0,
            ),
            child: new Column(
              children: <Widget>[
                widget.steps[index].content,
                _buildVerticalControls(index),
              ],
            ),
          ),
          firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
          secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: _isCurrent(index)
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: kThemeAnimationDuration,
        ),
      ],
    );
  }

  Widget _buildVertical() {
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < widget.steps.length; i += 1) {
      children.add(new Column(key: _keys[i], children: <Widget>[
        new InkWell(
            onTap: widget.steps[i].state != CustomStepState.disabled
                ? () {
                    // In the vertical case we need to scroll to the newly tapped
                    // step.
                    Scrollable.ensureVisible(
                      _keys[i].currentContext,
                      curve: Curves.fastOutSlowIn,
                      duration: kThemeAnimationDuration,
                    );

                    if (widget.onCustomStepTapped != null)
                      widget.onCustomStepTapped(i);
                  }
                : null,
            child: _buildVerticalHeader(i)),
        _buildVerticalBody(i)
      ]));
    }

    return new ListView(
      shrinkWrap: true,
      children: children,
    );
  }

  Widget _buildHorizontal() {
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < widget.steps.length; i += 1) {
      children.add(
        new InkResponse(
          onTap: widget.steps[i].state != CustomStepState.disabled
              ? () {
                  if (widget.onCustomStepTapped != null)
                    widget.onCustomStepTapped(i);
                }
              : null,
          child: new Row(
            children: <Widget>[
              new Container(
                height: 72.0,
                child: new Center(
                  child: _buildIcon(i),
                ),
              ),
              new Container(
                margin: const EdgeInsetsDirectional.only(start: 12.0),
                child: _buildHeaderText(i),
              ),
            ],
          ),
        ),
      );

      if (!_isLast(i)) {
        children.add(
          new Expanded(
            child: new Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 1.0,
              color: Colors.grey.shade400,
            ),
          ),
        );
      }
    }

    return new Column(
      children: <Widget>[
        new Material(
          elevation: 2.0,
          child: new Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            child: new Row(
              children: children,
            ),
          ),
        ),
        new Expanded(
          child: new ListView(
            padding: const EdgeInsets.all(24.0),
            children: <Widget>[
              new AnimatedSize(
                curve: Curves.fastOutSlowIn,
                duration: kThemeAnimationDuration,
                vsync: this,
                child: widget.steps[widget.currentCustomStep].content,
              ),
              _buildVerticalControls(-1),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(() {
      if (context.ancestorWidgetOfExactType(CustomStepper) != null)
        throw new FlutterError(
            'CustomSteppers must not be nested. The material specification advises '
            'that one should avoid embedding steppers within steppers. '
            'https://material.google.com/components/steppers.html#steppers-usage\n');
      return true;
    }());
    assert(widget.type != null);
    switch (widget.type) {
      case CustomStepperType.vertical:
        return _buildVertical();
      case CustomStepperType.horizontal:
        return _buildHorizontal();
    }
    return null;
  }
}

// Paints a triangle whose base is the bottom of the bounding rectangle and its
// top vertex the middle of its top.
class _TrianglePainter extends CustomPainter {
  _TrianglePainter({this.color});

  final Color color;

  @override
  bool hitTest(Offset point) => true; // Hitting the rectangle is fine enough.

  @override
  bool shouldRepaint(_TrianglePainter oldPainter) {
    return oldPainter.color != color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double base = size.width;
    final double halfBase = size.width / 2.0;
    final double height = size.height;
    final List<Offset> points = <Offset>[
      new Offset(0.0, height),
      new Offset(base, height),
      new Offset(halfBase, 0.0),
    ];

    canvas.drawPath(
      new Path()..addPolygon(points, true),
      new Paint()..color = color,
    );
  }
}
