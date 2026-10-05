enum PressPhase { down, move, end, clear }

/// Paint feedback only. This never dispatches an action or changes a gesture.
class BrowserPress {
  final int pointer;
  final double x, y;
  final PressPhase phase;
  const BrowserPress(this.pointer, this.x, this.y, this.phase);
}
