import '../../../exports.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'dart:developer' as developer;

class SwipeTestScreen extends AuthenticatedScreen {
  SwipeTestScreen({Key? key}) : super(key: key);

  static Future<SwipeTestScreen> create() async {
    final screen = SwipeTestScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    developer.log('Building SwipeTestScreen', name: 'SwipeTestScreen');

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: 'Swipe Test',
        backRoutePath: RoutePaths.home,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        AppDimensionsTheme.getParentContainerPadding(context),
                    vertical: AppDimensionsTheme.getSmall(context),
                  ),
                  child: SwipeButton.expand(
                    duration: const Duration(milliseconds: 200),
                    thumb: const Icon(
                      Icons.double_arrow_rounded,
                      color: Colors.black,
                    ),
                    activeThumbColor: Colors.red,
                    activeTrackColor: Colors.grey.shade300,
                    onSwipe: () {
                      _showSwipeMessage(context);
                    },
                    child: CustomText(
                      text: "Swipe to ...",
                      type: CustomTextType.bread,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        AppDimensionsTheme.getParentContainerPadding(context),
                    vertical: AppDimensionsTheme.getSmall(context),
                  ),
                  child: SwipeButton(
                    trackPadding: const EdgeInsets.all(6),
                    elevationThumb: 2,
                    elevationTrack: 2,
                    child: CustomText(
                      text: "Swipe to ...",
                      type: CustomTextType.bread,
                    ),
                    onSwipe: () {
                      _showSwipeMessage(context);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        AppDimensionsTheme.getParentContainerPadding(context),
                    vertical: AppDimensionsTheme.getSmall(context),
                  ),
                  child: SwipeButton(
                    thumbPadding: const EdgeInsets.all(3),
                    thumb: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                    elevationThumb: 2,
                    elevationTrack: 2,
                    child: Text(
                      "SWIPE TO ...",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSwipe: () {
                      _showSwipeMessage(context);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        AppDimensionsTheme.getParentContainerPadding(context),
                    vertical: AppDimensionsTheme.getSmall(context),
                  ),
                  child: SwipeButton(
                    borderRadius: BorderRadius.circular(8),
                    activeTrackColor: Colors.amber,
                    height: 60,
                    child: CustomText(
                      text: "Swipe to ...",
                      type: CustomTextType.bread,
                    ),
                    onSwipe: () {
                      _showSwipeMessage(context);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        AppDimensionsTheme.getParentContainerPadding(context),
                    vertical: AppDimensionsTheme.getSmall(context),
                  ),
                  child: SwipeButton(
                    activeTrackColor: Colors.blue,
                    activeThumbColor: Colors.yellow,
                    borderRadius: BorderRadius.zero,
                    height: 30,
                    child: CustomText(
                      text: "Swipe to ...",
                      type: CustomTextType.bread,
                    ),
                    onSwipe: () {
                      _showSwipeMessage(context);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        AppDimensionsTheme.getParentContainerPadding(context),
                    vertical: AppDimensionsTheme.getSmall(context),
                  ),
                  child: SwipeButton(
                    width: 200,
                    child: CustomText(
                      text: "Swipe to ...",
                      type: CustomTextType.bread,
                    ),
                    onSwipe: () {
                      _showSwipeMessage(context);
                    },
                  ),
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSwipeMessage(BuildContext context) {
    // Fjern eventuelle aktive snackbars først
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Vis den nye snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Swipped"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
