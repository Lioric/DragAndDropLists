import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DragAndDropItemTarget extends StatefulWidget {
  final Widget child;
  final DragAndDropListInterface? parent;
  final DragAndDropBuilderParameters parameters;
  final OnItemDropOnLastTarget onReorderOrAdd;

  const DragAndDropItemTarget(
      {required this.child,
      required this.onReorderOrAdd,
      required this.parameters,
      this.parent,
      super.key});

  @override
  State<StatefulWidget> createState() => _DragAndDropItemTarget();
}

class _DragAndDropItemTarget extends State<DragAndDropItemTarget>
    with TickerProviderStateMixin {
    DragAndDropItemWithSize? _hoveredDraggable;

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
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: widget.parameters.verticalAlignment,
          children: <Widget>[
            SizeTransition(
                sizeFactor: _animation,
                child: Container(
                    width: _hoveredDraggable?.size.width ?? 0,
                    height: _hoveredDraggable?.size.height ?? 0,
                )
            ),
            widget.child,
          ],
        ),
        Positioned.fill(
          child: DragTarget<DragAndDropItemWithSize>(
            builder: (context, candidateData, rejectedData) {
              return Container();
            },
            onWillAcceptWithDetails: (details) {
              bool accept = true;
              if (widget.parameters.itemTargetOnWillAccept != null) {
                accept =
                    widget.parameters.itemTargetOnWillAccept!(details.data.item, widget);
              }
              if (accept && mounted) {
                setState(() {
                  _hoveredDraggable = details.data;
                  _controller.forward();
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
                  widget.onReorderOrAdd(details.data.item, widget.parent!, widget);
                //   _hoveredDraggable = null;
                  _controller.reset();
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
