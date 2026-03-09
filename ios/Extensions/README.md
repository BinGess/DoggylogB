DoggyLog iOS extension skeletons live here.

These files are intentionally not wired into `Runner.xcodeproj` yet so the main
application can continue building cleanly while the extension targets are added
in a follow-up step. They define the shared snapshot reader and the initial
Widget / Live Activity structure expected by the Flutter snapshot publisher.
