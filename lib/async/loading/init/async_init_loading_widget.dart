import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/async/loading/init/async_init_loading_bloc.dart';
import 'package:flutter_appirc/async/loading/init/async_init_loading_model.dart';
import 'package:logging/logging.dart';

final _logger = Logger("async_init_loading_widget.dart");

class AsyncInitLoadingWidget extends StatelessWidget {
  final IAsyncInitLoadingBloc asyncInitLoadingBloc;
  final WidgetBuilder loadingFinishedBuilder;
  final Widget loadingWidget;

  AsyncInitLoadingWidget({
    @required this.asyncInitLoadingBloc,
    @required this.loadingFinishedBuilder,
    this.loadingWidget,
  }) {
    var state = asyncInitLoadingBloc.initLoadingState;
    _logger.finest(() => "AsyncInitLoadingWidget state $state");

    if (state == AsyncInitLoadingState.notStarted) {
      asyncInitLoadingBloc.performAsyncInit();
    }
  }

  @override
  Widget build(BuildContext context) {
    // hack for better performance to avoid redraw if init already finished
    if (asyncInitLoadingBloc.initLoadingState ==
        AsyncInitLoadingState.finished) {
      return loadingFinishedBuilder(context);
    }

    return StreamBuilder<AsyncInitLoadingState>(
        stream: asyncInitLoadingBloc.initLoadingStateStream,
        initialData: asyncInitLoadingBloc.initLoadingState,
        builder: (context, snapshot) {
          var loadingState = snapshot.data;
          //
          // switch (loadingState) {
          //   case AsyncInitLoadingState.notStarted:
          //     return Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: Center(
          //         child: Text(
          //           S.of(context).async_init_state_notStarted,
          //         ),
          //       ),
          //     );
          //     break;
          //   case AsyncInitLoadingState.loading:
          //     Widget child;
          //     if (loadingWidget == null) {
          //       child = CircularProgressIndicator();
          //     } else {
          //       child = loadingWidget;
          //     }
          //     return Center(child: child);
          //     break;
          //   case AsyncInitLoadingState.finished:
          //     return loadingFinishedBuilder(context);
          //     break;
          //   case AsyncInitLoadingState.failed:
          //     return Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Center(
          //           child: Text(
          //             S.of(context).async_init_state_failed(
          //                   asyncInitLoadingBloc.initLoadingException
          //                       .toString(),
          //                 ),
          //           ),
          //         ));
          //     break;
          // }

          throw "Invalid AsyncInitLoadingState $loadingState";
        });
  }
}
