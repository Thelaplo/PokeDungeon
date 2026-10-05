import 'package:flutter/material.dart';

import '../hub_style.dart';
import 'hub_button_variant.dart';
import 'hub_layout.dart';

class HubButton extends StatefulWidget {
  const HubButton({
    required this.label,
    required this.onPressed,
    this.variant = HubButtonVariant.primary,
    this.isCompact = false,
    this.leading,
    this.caption,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final HubButtonVariant variant;
  final bool isCompact;
  final Widget? leading;
  final Widget? caption;
  final String? semanticLabel;

  @override
  State<HubButton> createState() => _HubButtonState();
}

class _HubButtonState extends State<HubButton> {
  static const _regularLipHeight = 6.0;
  static const _compactLipHeight = 4.0;
  static const _regularMinHeight = 56.0;
  static const _radius = 18.0;
  static const _highlightAlpha = 0.35;
  static const _pressDuration = Duration(milliseconds: 70);

  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null;

  double get _lipHeight =>
      widget.isCompact ? _compactLipHeight : _regularLipHeight;

  void _updatePressed(bool isPressed) {
    if (_isPressed == isPressed) {
      return;
    }
    setState(() => _isPressed = isPressed);
  }

  TextStyle _labelStyle(HubButtonVariant colors) {
    final fontSize = widget.isCompact ? 15.0 : 22.0;
    if (colors.hasOutlinedLabel) {
      return HubStyle.title(
        fontSize: fontSize,
        color: colors.labelColor,
        outlineColor: colors.lipColor,
      );
    }
    return HubStyle.plainTitle(fontSize: fontSize, color: colors.labelColor);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _isEnabled ? widget.variant : HubButtonVariant.disabled;
    final borderRadius = BorderRadius.circular(_radius);
    final visibleLip = _isPressed ? 0.0 : _lipHeight;
    final leading = widget.leading;
    final caption = widget.caption;
    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.semanticLabel ?? widget.label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: _pressDuration,
        margin: EdgeInsets.only(top: _lipHeight - visibleLip),
        padding: EdgeInsets.only(bottom: visibleLip),
        decoration: BoxDecoration(
          color: colors.lipColor,
          borderRadius: borderRadius,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: _updatePressed,
            borderRadius: borderRadius,
            child: Ink(
              decoration: BoxDecoration(
                gradient: colors.gradient,
                borderRadius: borderRadius,
                border: Border.all(
                  color: HubStyle.white.withValues(alpha: _highlightAlpha),
                  width: 1.5,
                ),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: widget.isCompact
                      ? HubLayout.minTouchTarget
                      : _regularMinHeight,
                  minWidth: HubLayout.minTouchTarget,
                ),
                child: Padding(
                  padding: widget.isCompact
                      ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                      : const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (leading != null) ...[
                            leading,
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _labelStyle(colors),
                            ),
                          ),
                        ],
                      ),
                      ?caption,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
