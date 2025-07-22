class CheckItem {
  final String abbreviation;
  final String description;
  final int penaltyValue;
  int count;

  CheckItem({
    required this.abbreviation,
    required this.description,
    required this.penaltyValue,
    this.count = 0,
  });
}

class TestSection {
  final String title;
  final List<CheckItem> checks;

  TestSection({required this.title, required this.checks});
}

List<TestSection> testSections = [
  TestSection(
    title: 'PRETRIP EXTERIOR',
    checks: [
      CheckItem(abbreviation: 'Un.veh.', description: 'Observe under vehicle', penaltyValue: 1),
      CheckItem(abbreviation: 'Wipers', description: 'Windscreen wipers', penaltyValue: 1),
      CheckItem(abbreviation: 'Tyres', description: 'Tyres', penaltyValue: 1),
      CheckItem(abbreviation: 'Eng.comp.', description: 'Engine compartment', penaltyValue: 1),
      CheckItem(abbreviation: 'Lenses', description: 'Lenses and reflectors', penaltyValue: 1),
      CheckItem(abbreviation: 'FuelCap', description: 'Fuel Cap', penaltyValue: 1),
    ],
  ),
  TestSection(
    title: 'PRETRIP INTERIOR',
    checks: [
      CheckItem(abbreviation: 'Doors', description: 'Doors', penaltyValue: 2),
      CheckItem(abbreviation: 'PB', description: 'Parking Brake', penaltyValue: 1),
      CheckItem(abbreviation: 'Neutral', description: 'Neutral/Park', penaltyValue: 1),
      CheckItem(abbreviation: 'Obs', description: 'Obstructions', penaltyValue: 1),
      CheckItem(abbreviation: 'Seat', description: 'Seat', penaltyValue: 1),
      CheckItem(abbreviation: 'Mirrors', description: 'Adjust mirrors', penaltyValue: 2),
      CheckItem(abbreviation: 'Lights', description: 'Operation of Lights', penaltyValue: 1),
      CheckItem(abbreviation: 'Ind.', description: 'Operation of Indicators', penaltyValue: 1),
      CheckItem(abbreviation: 'WipersInt.', description: 'Operation of Wipers', penaltyValue: 1),
      CheckItem(abbreviation: 'Horn', description: 'Operation of Horn', penaltyValue: 1),
    ],
  ),
  TestSection(
    title: 'ALLEY DOCKING (Left)',
    checks: [
      CheckItem(abbreviation: 'Roll', description: 'Lets vehicle roll', penaltyValue: 100),
      CheckItem(abbreviation: 'PBApp', description: 'Application of parking brake', penaltyValue: 2),
      CheckItem(abbreviation: 'PBNoRel', description: 'Application of parking brake without release mechanism', penaltyValue: 1),
      CheckItem(abbreviation: 'Obs', description: 'Observation', penaltyValue: 5),
      CheckItem(abbreviation: 'SigInt', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'Gear', description: 'Gear changing/selection', penaltyValue: 1),
      CheckItem(abbreviation: 'MoveOff', description: 'Moving off', penaltyValue: 1),
      CheckItem(abbreviation: 'Stall', description: 'Stalls engine', penaltyValue: 1),
      CheckItem(abbreviation: 'Counter', description: 'Counter steers', penaltyValue: 1),
      CheckItem(abbreviation: 'TouchObs', description: 'Touching obstacle/s', penaltyValue: 0),
      CheckItem(abbreviation: 'Attempts', description: 'Number of attempts', penaltyValue: 0),
      CheckItem(abbreviation: 'CancelSig', description: 'Cancel signal', penaltyValue: 4),
    ],
  ),
  TestSection(
    title: 'ALLEY DOCKING (Right)',
    checks: [
      CheckItem(abbreviation: 'Roll', description: 'Lets vehicle roll', penaltyValue: 100),
      CheckItem(abbreviation: 'PBApp', description: 'Application of parking brake', penaltyValue: 2),
      CheckItem(abbreviation: 'PBNoRel', description: 'Application of parking brake without release mechanism', penaltyValue: 1),
      CheckItem(abbreviation: 'Obs', description: 'Observation', penaltyValue: 5),
      CheckItem(abbreviation: 'SigInt', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'Gear', description: 'Gear changing/selection', penaltyValue: 1),
      CheckItem(abbreviation: 'MoveOff', description: 'Moving off', penaltyValue: 1),
      CheckItem(abbreviation: 'Stall', description: 'Stalls engine', penaltyValue: 1),
      CheckItem(abbreviation: 'Counter', description: 'Counter steers', penaltyValue: 1),
      CheckItem(abbreviation: 'TouchObs', description: 'Touching obstacle/s', penaltyValue: 0),
      CheckItem(abbreviation: 'Attempts', description: 'Number of attempts', penaltyValue: 0),
      CheckItem(abbreviation: 'CancelSig', description: 'Cancel signal', penaltyValue: 4),
    ],
  ),
  TestSection(
    title: 'PARALLEL PARKING (Left)',
    checks: [
      CheckItem(abbreviation: 'Roll', description: 'Lets vehicle roll', penaltyValue: 100),
      CheckItem(abbreviation: 'PBApp', description: 'Application of parking brake', penaltyValue: 2),
      CheckItem(abbreviation: 'PBNoRel', description: 'Application of parking brake without release mechanism', penaltyValue: 1),
      CheckItem(abbreviation: 'Obs', description: 'Observation', penaltyValue: 5),
      CheckItem(abbreviation: 'SigInt', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'Gear', description: 'Gear changing/selection', penaltyValue: 1),
      CheckItem(abbreviation: 'MoveOff', description: 'Moving off', penaltyValue: 1),
      CheckItem(abbreviation: 'Stall', description: 'Stalls engine', penaltyValue: 1),
      CheckItem(abbreviation: 'Counter', description: 'Counter steers', penaltyValue: 1),
      CheckItem(abbreviation: 'Bump', description: 'Bump kerb', penaltyValue: 4),
      CheckItem(abbreviation: 'Mount', description: 'Mounts kerb', penaltyValue: 0),
      CheckItem(abbreviation: 'TouchObs', description: 'Touching obstacle/s', penaltyValue: 0),
      CheckItem(abbreviation: 'Attempts', description: 'Number of attempts', penaltyValue: 0),
      CheckItem(abbreviation: 'CancelSig', description: 'Cancel signal', penaltyValue: 4),
    ],
  ),
  TestSection(
    title: 'PARALLEL PARKING (Right)',
    checks: [
      CheckItem(abbreviation: 'Roll', description: 'Lets vehicle roll', penaltyValue: 100),
      CheckItem(abbreviation: 'PBApp', description: 'Application of parking brake', penaltyValue: 2),
      CheckItem(abbreviation: 'PBNoRel', description: 'Application of parking brake without release mechanism', penaltyValue: 1),
      CheckItem(abbreviation: 'Obs', description: 'Observation', penaltyValue: 5),
      CheckItem(abbreviation: 'SigInt', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'Gear', description: 'Gear changing/selection', penaltyValue: 1),
      CheckItem(abbreviation: 'MoveOff', description: 'Moving off', penaltyValue: 1),
      CheckItem(abbreviation: 'Stall', description: 'Stalls engine', penaltyValue: 1),
      CheckItem(abbreviation: 'Counter', description: 'Counter steers', penaltyValue: 1),
      CheckItem(abbreviation: 'Bump', description: 'Bump kerb', penaltyValue: 4),
      CheckItem(abbreviation: 'Mount', description: 'Mounts kerb', penaltyValue: 0),
      CheckItem(abbreviation: 'TouchObs', description: 'Touching obstacle/s', penaltyValue: 0),
      CheckItem(abbreviation: 'Attempts', description: 'Number of attempts', penaltyValue: 0),
      CheckItem(abbreviation: 'CancelSig', description: 'Cancel signal', penaltyValue: 4),
    ],
  ),
  TestSection(
    title: 'TURN IN THE ROAD',
    checks: [
      CheckItem(abbreviation: 'Roll', description: 'Lets vehicle roll', penaltyValue: 100),
      CheckItem(abbreviation: 'PBApp', description: 'Application of parking brake', penaltyValue: 2),
      CheckItem(abbreviation: 'PBNoRel', description: 'Application of parking brake without release mechanism', penaltyValue: 1),
      CheckItem(abbreviation: 'Obs', description: 'Observation', penaltyValue: 5),
      CheckItem(abbreviation: 'SigInt', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'Gear', description: 'Gear changing/selection', penaltyValue: 1),
      CheckItem(abbreviation: 'MoveOff', description: 'Moving off', penaltyValue: 1),
      CheckItem(abbreviation: 'Stall', description: 'Stalls engine', penaltyValue: 1),
      CheckItem(abbreviation: 'Counter', description: 'Counter steers', penaltyValue: 1),
      CheckItem(abbreviation: 'Bump', description: 'Bump kerb', penaltyValue: 4),
      CheckItem(abbreviation: 'MountLine', description: 'Mounts kerb/Touch line/road marking', penaltyValue: 0),
      CheckItem(abbreviation: 'Moves', description: 'Number of moves', penaltyValue: 0),
      CheckItem(abbreviation: 'CancelSig', description: 'Cancel signal', penaltyValue: 4),
    ],
  ),
  TestSection(
    title: 'INCLINE START',
    checks: [
      CheckItem(abbreviation: 'Roll', description: 'Lets vehicle roll', penaltyValue: 100),
      CheckItem(abbreviation: 'PBApp', description: 'Application of parking brake', penaltyValue: 2),
      CheckItem(abbreviation: 'PBNoRel', description: 'Application of parking brake without release mechanism', penaltyValue: 1),
      CheckItem(abbreviation: 'NeutralAuto', description: 'Neutral/Drive (automatic transmission)', penaltyValue: 1),
      CheckItem(abbreviation: 'Obs', description: 'Observation', penaltyValue: 5),
      CheckItem(abbreviation: 'SigInt', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'Gear', description: 'Gear changing/selection', penaltyValue: 1),
      CheckItem(abbreviation: 'MoveOff', description: 'Moving off', penaltyValue: 1),
      CheckItem(abbreviation: 'Stall', description: 'Stalls engine', penaltyValue: 1),
      CheckItem(abbreviation: 'CancelSig', description: 'Cancel signal', penaltyValue: 1),
    ],
  ),
  TestSection(
    title: 'STARTING',
    checks: [
      CheckItem(abbreviation: 'PBApp', description: 'Application of parking brake', penaltyValue: 2),
      CheckItem(abbreviation: 'PBNoRel', description: 'Application of parking brake without release mechanism', penaltyValue: 1),
      CheckItem(abbreviation: 'NeutralPark', description: 'Neutral/Park (automatic transmission)', penaltyValue: 1),
      CheckItem(abbreviation: 'Choke', description: 'Operation of choke', penaltyValue: 1),
      CheckItem(abbreviation: 'StartEng', description: 'Starts engine', penaltyValue: 1),
      CheckItem(abbreviation: 'WarnLight', description: 'Warning lights and gauges', penaltyValue: 1),
    ],
  ),
  TestSection(
    title: 'MOVING OFF',
    checks: [
      CheckItem(abbreviation: 'Obs', description: 'Observation', penaltyValue: 5),
      CheckItem(abbreviation: 'SigInt', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'Gear', description: 'Gear changing/selection', penaltyValue: 1),
      CheckItem(abbreviation: 'WaitLong', description: 'Waits too long', penaltyValue: 1),
      CheckItem(abbreviation: 'MoveOff', description: 'Moving off', penaltyValue: 1),
      CheckItem(abbreviation: 'Stall', description: 'Stalls engine', penaltyValue: 1),
      CheckItem(abbreviation: 'Roll', description: 'Lets vehicle roll', penaltyValue: 1),
      CheckItem(abbreviation: 'CancelSig', description: 'Cancel signal', penaltyValue: 4),
    ],
  ),
  TestSection(
    title: 'STEERING',
    checks: [
      CheckItem(abbreviation: 'Method', description: 'Steering method', penaltyValue: 1),
      CheckItem(abbreviation: 'Obs', description: 'Observation', penaltyValue: 5),
      CheckItem(abbreviation: 'WideCut', description: 'Steering too wide/cutting', penaltyValue: 4),
      CheckItem(abbreviation: 'Wanders', description: 'Wanders', penaltyValue: 2),
      CheckItem(abbreviation: 'Pos', description: 'Position of vehicle', penaltyValue: 2),
      CheckItem(abbreviation: 'Straddles', description: 'Straddles', penaltyValue: 2),
    ],
  ),
  TestSection(
    title: 'GEAR CHANGING',
    checks: [
      CheckItem(abbreviation: 'Gear', description: 'Gear changing/selection', penaltyValue: 1),
      CheckItem(abbreviation: 'Smooth', description: 'Smooth and coordinated', penaltyValue: 1),
      CheckItem(abbreviation: 'EyesRoad', description: 'Keep eyes on the road', penaltyValue: 5),
      CheckItem(abbreviation: 'Cornering', description: 'Whilst cornering', penaltyValue: 4),
      CheckItem(abbreviation: 'Coasting', description: 'Coasting', penaltyValue: 3),
    ],
  ),
  TestSection(
    title: 'SPEED CONTROL',
    checks: [
      CheckItem(abbreviation: 'Mirrors', description: 'Mirrors', penaltyValue: 3),
      CheckItem(abbreviation: 'FastCond', description: 'Too fast for conditions', penaltyValue: 5),
      CheckItem(abbreviation: 'SlowCond', description: 'Too slow for conditions', penaltyValue: 5),
      CheckItem(abbreviation: 'Accel', description: 'Acceleration', penaltyValue: 1),
      CheckItem(abbreviation: 'Decel', description: 'Deceleration', penaltyValue: 1),
      CheckItem(abbreviation: 'Braking', description: 'Braking', penaltyValue: 2),
      CheckItem(abbreviation: 'FollowDist', description: 'Following distance', penaltyValue: 5),
    ],
  ),
  TestSection(
    title: 'STOPPING',
    checks: [
      CheckItem(abbreviation: 'Mirrors', description: 'Mirrors', penaltyValue: 3),
      CheckItem(abbreviation: 'Bspots', description: 'Blind spots', penaltyValue: 5),
      CheckItem(abbreviation: 'SigIntent', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'Braking', description: 'Braking', penaltyValue: 2),
      CheckItem(abbreviation: 'Clutch', description: 'Disengage clutch', penaltyValue: 1),
      CheckItem(abbreviation: 'PBApp', description: 'Applications of parking brake', penaltyValue: 2),
      CheckItem(abbreviation: 'PBw/oRel', description: 'Applications of parking brake without using release', penaltyValue: 1),
      CheckItem(abbreviation: 'N/D/Park', description: 'Neutral/Drive/Park', penaltyValue: 1),
      CheckItem(abbreviation: 'CancelSig', description: 'Cancels Signal', penaltyValue: 4),
      CheckItem(abbreviation: 'StopNeedless', description: 'Needless stopping', penaltyValue: 1),
    ],
  ),
  
  TestSection(
    title: 'FREEWAYS ENTRY/EXIT',
    checks: [
      CheckItem(abbreviation: 'Mirrors', description: 'Mirrors', penaltyValue: 3),
      CheckItem(abbreviation: 'Bspots', description: 'Blind spots', penaltyValue: 5),
      CheckItem(abbreviation: 'SigIntent', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'CancelSig', description: 'Cancels Signals', penaltyValue: 3),
      CheckItem(abbreviation: 'ClearSpace', description: 'Clear space', penaltyValue: 5),
    ],
  ),
  TestSection(
    title: 'INTERSECTION VEHICLE ENTRY/EXIT',
    checks: [
      CheckItem(abbreviation: 'Mirrors', description: 'Mirrors', penaltyValue: 3),
      CheckItem(abbreviation: 'Bspots', description: 'Blind spots', penaltyValue: 5),
      CheckItem(abbreviation: 'SigIntent', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'LaneChg', description: 'Lane changing in an intersection', penaltyValue: 3),
      CheckItem(abbreviation: 'CrossTraffic', description: 'Check right and left for cross traffic', penaltyValue: 5),
      CheckItem(abbreviation: 'TurnPos', description: 'Position for turn', penaltyValue: 4),
      CheckItem(abbreviation: 'WheelsStr', description: 'Wheels straight for turning', penaltyValue: 3),
      CheckItem(abbreviation: 'CancelSig', description: 'Cancel signal', penaltyValue: 4),
    ],
  ),
  TestSection(
    title: 'OVERTAKING',
    checks: [
      CheckItem(abbreviation: 'Mirrors', description: 'Mirrors', penaltyValue: 3),
      CheckItem(abbreviation: 'Bspots', description: 'Blind spots', penaltyValue: 5),
      CheckItem(abbreviation: 'SigIntent', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'CancelSig', description: 'Cancel signal', penaltyValue: 4),
      CheckItem(abbreviation: 'ClearSpace', description: 'Clear space', penaltyValue: 5),
    ],
  ),
  TestSection(
    title: 'LANE CHANGING',
    checks: [
      CheckItem(abbreviation: 'Mirrors', description: 'Mirrors', penaltyValue: 3),
      CheckItem(abbreviation: 'Bspots', description: 'Blind spots', penaltyValue: 5),
      CheckItem(abbreviation: 'SigIntent', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'CancelSig', description: 'Cancel signal', penaltyValue: 4),
    ],
  ),
  TestSection(
    title: 'SIGNALLING',
    checks: [
      CheckItem(abbreviation: 'Mirrors', description: 'Mirrors', penaltyValue: 3),
      CheckItem(abbreviation: 'Bspots', description: 'Blind spots', penaltyValue: 5),
      CheckItem(abbreviation: 'HandRt', description: 'Hand signal to indicate intention to turn right', penaltyValue: 3),
      CheckItem(abbreviation: 'HandLt', description: 'Hand signal to indicate intention to turn left', penaltyValue: 3),
      CheckItem(abbreviation: 'HandStop', description: 'Hand signal to indicate intention to stop or reduce speed suddenly', penaltyValue: 3),
      CheckItem(abbreviation: 'Horn', description: 'Use of horn', penaltyValue: 1),
    ],
  ),
  TestSection(
    title: 'CLUTCH',
    checks: [
      CheckItem(abbreviation: 'Smooth', description: 'Smooth and coordinated', penaltyValue: 1),
      CheckItem(abbreviation: 'Slip', description: 'Slipping the clutch', penaltyValue: 1),
      CheckItem(abbreviation: 'Ride', description: 'Riding the clutch', penaltyValue: 1),
      CheckItem(abbreviation: 'Coast', description: 'Coasting', penaltyValue: 3),
    ],
  ),
  TestSection(
    title: 'EMERGENCY STOP',
    checks: [
      CheckItem(abbreviation: 'Smooth', description: 'Stop Vehicle', penaltyValue: 1),
      CheckItem(abbreviation: 'Con.stop', description: 'Controlled Stop', penaltyValue: 1),
    ],
  ),
  TestSection(
    title: 'LEFT TURN',
    checks: [
      CheckItem(abbreviation: 'Mir', description: 'Mirrors', penaltyValue: 3),
      CheckItem(abbreviation: 'Bl.sp', description: 'Blind spots', penaltyValue: 5),
      CheckItem(abbreviation: 'Sig', description: 'Signal intention', penaltyValue: 5),
      CheckItem(abbreviation: 'Sig.can', description: 'Signal cancel', penaltyValue: 4),
      CheckItem(abbreviation: 'Mir.whilst.cnr', description: 'Mirrors whilst cornering', penaltyValue: 1),
      CheckItem(abbreviation: 'M.kerb/T.line', description: 'Mount kerb/Touch line', penaltyValue: 100),
      CheckItem(abbreviation: 'No.att', description: 'Number of attempts', penaltyValue: 1),
    ],
  ),
  TestSection(
    title: 'STRAIGHT REVERSING',
    checks: [
      CheckItem(abbreviation: 'Roll', description: 'Lets vehicle roll', penaltyValue: 100),
      CheckItem(abbreviation: 'P.br', description: 'Parking brake', penaltyValue: 1),
      CheckItem(abbreviation: 'Obs', description: 'observation', penaltyValue: 1),
      CheckItem(abbreviation: 'Gear', description: 'Gear changing/selection', penaltyValue: 1),
      CheckItem(abbreviation: 'Move', description: 'Moving off', penaltyValue: 1),
      CheckItem(abbreviation: 'Stall', description: 'Stalls engine', penaltyValue: 1),
      CheckItem(abbreviation: 'T.line', description: 'Touching line/road marking', penaltyValue: 1),
      CheckItem(abbreviation: 'No.att', description: 'Number of attempts', penaltyValue: 1),
    ],
  ),
];
