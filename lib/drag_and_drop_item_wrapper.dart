import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:drag_and_drop_lists/measure_size.dart';
import 'package:flutter/material.dart';

class DragAndDropItemWrapper extends StatefulWidget {
  final DragAndDropItem child;
  final DragAndDropBuilderParameters? parameters;

  const DragAndDropItemWrapper(
      {required this.child, required this.parameters, super.key});

  @override
  State<StatefulWidget> createState() => _DragAndDropItemWrapper();
}

class _DragAndDropItemWrapper extends State<DragAndDropItemWrapper>
    with TickerProviderStateMixin {
  DragAndDropItemWithSize? _hoveredDraggable;

  bool _dragging = false;
  Size _containerSize = Size.zero;
  Size _dragHandleSize = Size.zero;

//   static Size? _placeholderSize;

    late final AnimationController _controller;
    late final CurvedAnimation _animation;

    @override
    initState() {
        super.initState();

        _controller = AnimationController(
            duration: Duration(milliseconds: widget.parameters!.itemSizeAnimationDuration),
            vsync: this,
        );

        _animation = CurvedAnimation(
            parent: _controller,
            curve: Curves.linear,
        );
    }


    @override
    dispose() {
        _controller.dispose();
        super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    Widget draggable;
    if (widget.child.canDrag) {
      if (widget.parameters!.itemDragHandle != null) {
        Widget feedback = SizedBox(
          width: widget.parameters!.itemDraggingWidth ?? _containerSize.width,
          child: Stack(
            children: [
              widget.child.child,
              Positioned(
                right: widget.parameters!.itemDragHandle!.onLeft ? null : 0,
                left: widget.parameters!.itemDragHandle!.onLeft ? 0 : null,
                top: widget.parameters!.itemDragHandle!.verticalAlignment ==
                        DragHandleVerticalAlignment.bottom
                    ? null
                    : 0,
                bottom: widget.parameters!.itemDragHandle!.verticalAlignment ==
                        DragHandleVerticalAlignment.top
                    ? null
                    : 0,
                child: widget.parameters!.itemDragHandle!,
              ),
            ],
          ),
        );

        var positionedDragHandle = Positioned(
          right: widget.parameters!.itemDragHandle!.onLeft ? null : 0,
          left: widget.parameters!.itemDragHandle!.onLeft ? 0 : null,
          top: widget.parameters!.itemDragHandle!.verticalAlignment ==
                  DragHandleVerticalAlignment.bottom
              ? null
              : 0,
          bottom: widget.parameters!.itemDragHandle!.verticalAlignment ==
                  DragHandleVerticalAlignment.top
              ? null
              : 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: Draggable<DragAndDropItem>(
              data: widget.child,
              axis: widget.parameters!.axis == Axis.vertical &&
                      widget.parameters!.constrainDraggingAxis
                  ? Axis.vertical
                  : null,
              feedback: Transform.translate(
                offset: _feedbackContainerOffset(),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: widget.parameters!.itemDecorationWhileDragging,
                    child: Directionality(
                      textDirection: Directionality.of(context),
                      child: feedback,
                    ),
                  ),
                ),
              ),
              childWhenDragging: Container(),
              onDragStarted: () => _setDragging(true),
              onDragCompleted: () => _setDragging(false),
              onDraggableCanceled: (_, __) => _setDragging(false),
              onDragEnd: (_) => _setDragging(false),
              child: MeasureSize(
                onSizeChange: (size) {
                  setState(() {
                    _dragHandleSize = size!;
                  });
                },
                child: widget.parameters!.itemDragHandle,
              ),
            ),
          ),
        );

        draggable = MeasureSize(
          onSizeChange: _setContainerSize,
          child: Stack(
            children: [
              Visibility(
                visible: !_dragging,
                child: widget.child.child,
              ),
              // dragAndDropListContents,
              positionedDragHandle,
            ],
          ),
        );
      } else if (widget.parameters!.dragOnLongPress) {
        draggable = MeasureSize(
          onSizeChange: _setContainerSize,
          child: LongPressDraggable<DragAndDropItem>(
            data: widget.child,
            axis: widget.parameters!.axis == Axis.vertical &&
                    widget.parameters!.constrainDraggingAxis
                ? Axis.vertical
                : null,
            feedback: SizedBox(
              width:
                  widget.parameters!.itemDraggingWidth ?? _containerSize.width,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: widget.parameters!.itemDecorationWhileDragging,
                  child: Directionality(
                      textDirection: Directionality.of(context),
                      child: widget.child.feedbackWidget ?? widget.child.child),
                ),
              ),
            ),
            childWhenDragging: Container(),
            onDragStarted: () => _setDragging(true),
            onDragCompleted: () => _setDragging(false),
            onDraggableCanceled: (_, __) => _setDragging(false),
            onDragEnd: (_) => _setDragging(false),
            child: widget.child.child,
          ),
        );
      } else {
        draggable = MeasureSize(
          onSizeChange: _setContainerSize,
          child: Draggable<DragAndDropItemWithSize>(
            data: DragAndDropItemWithSize(
				item: widget.child,
				size: _containerSize,
			),
            axis: widget.parameters!.axis == Axis.vertical &&
                    widget.parameters!.constrainDraggingAxis
                ? Axis.vertical
                : null,
            feedback: SizedBox(
              width: widget.parameters!.itemDraggingWidth ?? _containerSize.width,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: widget.parameters!.itemDecorationWhileDragging,
                  child: Directionality(
                    textDirection: Directionality.of(context),
                    child: widget.child.feedbackWidget ?? widget.child.child,
                  ),
                ),
              ),
            ),
            childWhenDragging: Container(),
            onDragStarted: () => _setDragging(true),
            onDragCompleted: () => _setDragging(false),
            onDraggableCanceled: (_, __) => _setDragging(false),
            onDragEnd: (_) => _setDragging(false),
            child: widget.child.child,
          ),
        );
      }
    } else {
      draggable = AnimatedSize(
        duration: Duration(
            milliseconds: widget.parameters!.itemSizeAnimationDuration),
        alignment: Alignment.bottomCenter,
        child: _hoveredDraggable != null ? Container() : widget.child.child,
      );
    }

    return Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.parameters!.verticalAlignment,
          children: <Widget>[
            SizeTransition(
                sizeFactor: _animation,
                child: Container(
					width: _hoveredDraggable?.size.width ?? 0,
					height: _hoveredDraggable?.size.height ?? 0,
				)
            ),
            Listener(
              onPointerMove: (event) {
                if (_dragging) {
					widget.parameters!.onPointerMove!(event);
				}
              },
              onPointerDown: widget.parameters!.onPointerDown,
              onPointerUp: widget.parameters!.onPointerUp,
              child: draggable,
            ),
          ],
        ),
        Positioned.fill(
          child: DragTarget<DragAndDropItemWithSize>(
            builder: (context, candidateData, rejectedData) {
              return Container();
            },
            onWillAcceptWithDetails: (details) {
              bool accept = true;
              if (widget.parameters!.itemOnWillAccept != null) {
                accept = widget.parameters!.itemOnWillAccept!(
                    details.data.item, widget.child);
              }
              if (accept && mounted) {
                setState(() {
                  _hoveredDraggable = details.data;
                  if(_hoveredDraggable?.item == widget.child) {
                    _controller.value = _controller.upperBound;
                  }
                  else {
                    _controller.forward();
                  }
                });
              }
              return accept;
            },
            onLeave: (data) {
              if (mounted) {
                setState(() {
                //   _hoveredDraggable = null;
                  _controller.reverse();
                });
              }
            },
            onAcceptWithDetails: (details) {
              if (mounted) {
                setState(() {
                  if (widget.parameters!.onItemReordered != null) {
                    widget.parameters!.onItemReordered!(details.data.item, widget.child);
                  }
                //   _hoveredDraggable = null;
                  _controller.reset();
                });
              }
            },
          ),
        )
      ],
    );
  }

  Offset _feedbackContainerOffset() {
    double xOffset;
    double yOffset;
    if (widget.parameters!.itemDragHandle!.onLeft) {
      xOffset = 0;
    } else {
      xOffset = -_containerSize.width + _dragHandleSize.width;
    }
    if (widget.parameters!.itemDragHandle!.verticalAlignment ==
        DragHandleVerticalAlignment.bottom) {
      yOffset = -_containerSize.height + _dragHandleSize.width;
    } else {
      yOffset = 0;
    }

    return Offset(xOffset, yOffset);
  }

  void _setContainerSize(Size? size) {
    if (mounted) {
      setState(() {
        _containerSize = size!;
      });
    }
  }

  void _setDragging(bool dragging) {
    if (_dragging != dragging && mounted) {
        // if(dragging) {
        //     _placeholderSize = _containerSize;
        // }

      setState(() {
        _dragging = dragging;
      });
      if (widget.parameters!.onItemDraggingChanged != null) {
        widget.parameters!.onItemDraggingChanged!(widget.child, dragging);
      }
    }
  }
}
