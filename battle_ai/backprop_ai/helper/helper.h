char network_mapping[425][20] = { "Weather Turns", // 0
    "Weather Sun",
    "Weather Rain",
    "Weather Sand",
    "Weather Hail", // 4
    "P1 Hazard 1", // 5
    "P1 Hazard 2", // 6
    "P1 Hazard 3", // 7
    "P1 Hazard 4", // 8
    "P1 Hazard 5", // 9
    "P1 Hazard 6", // 10
    "P1 Hazard 7", // 11
    "P1 Hazard 8", // 12
    "P1 Hazard 9", // 13
    "P2 Hazard 1", // 14
    "P2 Hazard 2", // 15
    "P2 Hazard 3", // 16
    "P2 Hazard 4", // 17
    "P2 Hazard 5", // 18
    "P2 Hazard 6", // 19
    "P2 Hazard 7", // 20
    "P2 Hazard 8", // 21
    "P2 Hazard 9", // 22
    "P1 Volatile 1", // 23
    "P1 Volatile 2", // 24
    "P1 Volatile 3", // 25
    "P1 Volatile 4", // 26
    "P1 Volatile 5", // 27
    "P1 Volatile 6", // 28
    "P1 Volatile 7", // 29
    "P1 Volatile 8", // 30
    "P1 Volatile 9", // 31
    "P1 Volatile 10", // 32
    "P1 Volatile 11", // 33
    "P1 Volatile 12", // 34
    "P1 Volatile 13", // 35
    "P1 Volatile 14", // 36
    "P2 Volatile 1", // 37
    "P2 Volatile 2", // 38
    "P2 Volatile 3", // 39
    "P2 Volatile 4", // 40
    "P2 Volatile 5", // 41
    "P2 Volatile 6", // 42
    "P2 Volatile 7", // 43
    "P2 Volatile 8", // 44
    "P2 Volatile 9", // 45
    "P2 Volatile 10", // 46
    "P2 Volatile 11", // 47
    "P2 Volatile 12", // 48
    "P2 Volatile 13", // 49
    "P2 Volatile 14", // 50
    "P1 Boost 1", // 51
    "P1 Boost 2", // 52
    "P1 Boost 3", // 53
    "P1 Boost 4", // 54
    "P1 Boost 5", // 55
    "P1 Boost 6", // 56
    "P1 Boost 7", // 57
    "P2 Boost 1", // 58
    "P2 Boost 2", // 59
    "P2 Boost 3", // 60
    "P2 Boost 4", // 61
    "P2 Boost 5", // 62
    "P2 Boost 6", // 63
    "P2 Boost 7", // 64
    "P1 Poke1 HP", // 65 
    "P1 Poke1 Stat1", // 66
    "P1 Poke1 Stat2", // 67
    "P1 Poke1 Stat3", // 68
    "P1 Poke1 Stat4", // 69
    "P1 Poke1 Stat5", // 70
    "P1 Poke1 Stat6", // 71
    "P1 Poke1 Type1", // 72
    "P1 Poke1 Type2", // 73
    "P1 Poke1 Type3", // 74
    "P1 Poke1 Type4", // 75
    "P1 Poke1 Type5", // 76
    "P1 Poke1 Type6", // 77
    "P1 Poke1 Type7", // 78
    "P1 Poke1 Type8", // 79
    "P1 Poke1 Type9", // 80
    "P1 Poke1 Type10", // 81
    "P1 Poke1 Type11", // 82
    "P1 Poke1 Type12", // 83
    "P1 Poke1 Type13", // 84
    "P1 Poke1 Type14", // 85
    "P1 Poke1 Type15", // 86
    "P1 Poke1 Type16", // 87
    "P1 Poke1 Type17", // 88
    "P1 Poke1 Status1", // 89
    "P1 Poke1 Status2", // 90
    "P1 Poke1 Status3", // 91
    "P1 Poke1 Status4", // 92
    "P1 Poke1 Status5", // 93
    "P1 Poke1 Faint", // 94
    "P1 Poke2 HP",
    "P1 Poke2 Stat1",
    "P1 Poke2 Stat2",
    "P1 Poke2 Stat3",
    "P1 Poke2 Stat4",
    "P1 Poke2 Stat5",
    "P1 Poke2 Stat6",
    "P1 Poke2 Type1",
    "P1 Poke2 Type2",
    "P1 Poke2 Type3",
    "P1 Poke2 Type4",
    "P1 Poke2 Type5",
    "P1 Poke2 Type6",
    "P1 Poke2 Type7",
    "P1 Poke2 Type8",
    "P1 Poke2 Type9",
    "P1 Poke2 Type10",
    "P1 Poke2 Type11",
    "P1 Poke2 Type12",
    "P1 Poke2 Type13",
    "P1 Poke2 Type14",
    "P1 Poke2 Type15",
    "P1 Poke2 Type16",
    "P1 Poke2 Type17",
    "P1 Poke2 Status1",
    "P1 Poke2 Status2",
    "P1 Poke2 Status3",
    "P1 Poke2 Status4",
    "P1 Poke2 Status5",
    "P1 Poke2 Faint",
    "P1 Poke3 HP",
    "P1 Poke3 Stat1",
    "P1 Poke3 Stat2",
    "P1 Poke3 Stat3",
    "P1 Poke3 Stat4",
    "P1 Poke3 Stat5",
    "P1 Poke3 Stat6",
    "P1 Poke3 Type1",
    "P1 Poke3 Type2",
    "P1 Poke3 Type3",
    "P1 Poke3 Type4",
    "P1 Poke3 Type5",
    "P1 Poke3 Type6",
    "P1 Poke3 Type7",
    "P1 Poke3 Type8",
    "P1 Poke3 Type9",
    "P1 Poke3 Type10",
    "P1 Poke3 Type11",
    "P1 Poke3 Type12",
    "P1 Poke3 Type13",
    "P1 Poke3 Type14",
    "P1 Poke3 Type15",
    "P1 Poke3 Type16",
    "P1 Poke3 Type17",
    "P1 Poke3 Status1",
    "P1 Poke3 Status2",
    "P1 Poke3 Status3",
    "P1 Poke3 Status4",
    "P1 Poke3 Status5",
    "P1 Poke3 Faint",
    "P1 Poke4 HP",
    "P1 Poke4 Stat1",
    "P1 Poke4 Stat2",
    "P1 Poke4 Stat3",
    "P1 Poke4 Stat4",
    "P1 Poke4 Stat5",
    "P1 Poke4 Stat6",
    "P1 Poke4 Type1",
    "P1 Poke4 Type2",
    "P1 Poke4 Type3",
    "P1 Poke4 Type4",
    "P1 Poke4 Type5",
    "P1 Poke4 Type6",
    "P1 Poke4 Type7",
    "P1 Poke4 Type8",
    "P1 Poke4 Type9",
    "P1 Poke4 Type10",
    "P1 Poke4 Type11",
    "P1 Poke4 Type12",
    "P1 Poke4 Type13",
    "P1 Poke4 Type14",
    "P1 Poke4 Type15",
    "P1 Poke4 Type16",
    "P1 Poke4 Type17",
    "P1 Poke4 Status1",
    "P1 Poke4 Status2",
    "P1 Poke4 Status3",
    "P1 Poke4 Status4",
    "P1 Poke4 Status5",
    "P1 Poke4 Faint",
    "P1 Poke5 HP",
    "P1 Poke5 Stat1",
    "P1 Poke5 Stat2",
    "P1 Poke5 Stat3",
    "P1 Poke5 Stat4",
    "P1 Poke5 Stat5",
    "P1 Poke5 Stat6",
    "P1 Poke5 Type1",
    "P1 Poke5 Type2",
    "P1 Poke5 Type3",
    "P1 Poke5 Type4",
    "P1 Poke5 Type5",
    "P1 Poke5 Type6",
    "P1 Poke5 Type7",
    "P1 Poke5 Type8",
    "P1 Poke5 Type9",
    "P1 Poke5 Type10",
    "P1 Poke5 Type11",
    "P1 Poke5 Type12",
    "P1 Poke5 Type13",
    "P1 Poke5 Type14",
    "P1 Poke5 Type15",
    "P1 Poke5 Type16",
    "P1 Poke5 Type17",
    "P1 Poke5 Status1",
    "P1 Poke5 Status2",
    "P1 Poke5 Status3",
    "P1 Poke5 Status4",
    "P1 Poke5 Status5",
    "P1 Poke5 Faint",
    "P1 Poke6 HP",
    "P1 Poke6 Stat1",
    "P1 Poke6 Stat2",
    "P1 Poke6 Stat3",
    "P1 Poke6 Stat4",
    "P1 Poke6 Stat5",
    "P1 Poke6 Stat6",
    "P1 Poke6 Type1",
    "P1 Poke6 Type2",
    "P1 Poke6 Type3",
    "P1 Poke6 Type4",
    "P1 Poke6 Type5",
    "P1 Poke6 Type6",
    "P1 Poke6 Type7",
    "P1 Poke6 Type8",
    "P1 Poke6 Type9",
    "P1 Poke6 Type10",
    "P1 Poke6 Type11",
    "P1 Poke6 Type12",
    "P1 Poke6 Type13",
    "P1 Poke6 Type14",
    "P1 Poke6 Type15",
    "P1 Poke6 Type16",
    "P1 Poke6 Type17",
    "P1 Poke6 Status1",
    "P1 Poke6 Status2",
    "P1 Poke6 Status3",
    "P1 Poke6 Status4",
    "P1 Poke6 Status5",
    "P1 Poke6 Faint",
    "P2 Poke1 HP",
    "P2 Poke1 Stat1",
    "P2 Poke1 Stat2",
    "P2 Poke1 Stat3",
    "P2 Poke1 Stat4",
    "P2 Poke1 Stat5",
    "P2 Poke1 Stat6",
    "P2 Poke1 Type1",
    "P2 Poke1 Type2",
    "P2 Poke1 Type3",
    "P2 Poke1 Type4",
    "P2 Poke1 Type5",
    "P2 Poke1 Type6",
    "P2 Poke1 Type7",
    "P2 Poke1 Type8",
    "P2 Poke1 Type9",
    "P2 Poke1 Type10",
    "P2 Poke1 Type11",
    "P2 Poke1 Type12",
    "P2 Poke1 Type13",
    "P2 Poke1 Type14",
    "P2 Poke1 Type15",
    "P2 Poke1 Type16",
    "P2 Poke1 Type17",
    "P2 Poke1 Status1",
    "P2 Poke1 Status2",
    "P2 Poke1 Status3",
    "P2 Poke1 Status4",
    "P2 Poke1 Status5",
    "P2 Poke1 Faint",
    "P2 Poke2 HP",
    "P2 Poke2 Stat1",
    "P2 Poke2 Stat2",
    "P2 Poke2 Stat3",
    "P2 Poke2 Stat4",
    "P2 Poke2 Stat5",
    "P2 Poke2 Stat6",
    "P2 Poke2 Type1",
    "P2 Poke2 Type2",
    "P2 Poke2 Type3",
    "P2 Poke2 Type4",
    "P2 Poke2 Type5",
    "P2 Poke2 Type6",
    "P2 Poke2 Type7",
    "P2 Poke2 Type8",
    "P2 Poke2 Type9",
    "P2 Poke2 Type10",
    "P2 Poke2 Type11",
    "P2 Poke2 Type12",
    "P2 Poke2 Type13",
    "P2 Poke2 Type14",
    "P2 Poke2 Type15",
    "P2 Poke2 Type16",
    "P2 Poke2 Type17",
    "P2 Poke2 Status1",
    "P2 Poke2 Status2",
    "P2 Poke2 Status3",
    "P2 Poke2 Status4",
    "P2 Poke2 Status5",
    "P2 Poke2 Faint",
    "P2 Poke3 HP",
    "P2 Poke3 Stat1",
    "P2 Poke3 Stat2",
    "P2 Poke3 Stat3",
    "P2 Poke3 Stat4",
    "P2 Poke3 Stat5",
    "P2 Poke3 Stat6",
    "P2 Poke3 Type1",
    "P2 Poke3 Type2",
    "P2 Poke3 Type3",
    "P2 Poke3 Type4",
    "P2 Poke3 Type5",
    "P2 Poke3 Type6",
    "P2 Poke3 Type7",
    "P2 Poke3 Type8",
    "P2 Poke3 Type9",
    "P2 Poke3 Type10",
    "P2 Poke3 Type11",
    "P2 Poke3 Type12",
    "P2 Poke3 Type13",
    "P2 Poke3 Type14",
    "P2 Poke3 Type15",
    "P2 Poke3 Type16",
    "P2 Poke3 Type17",
    "P2 Poke3 Status1",
    "P2 Poke3 Status2",
    "P2 Poke3 Status3",
    "P2 Poke3 Status4",
    "P2 Poke3 Status5",
    "P2 Poke3 Faint",
    "P2 Poke4 HP",
    "P2 Poke4 Stat1",
    "P2 Poke4 Stat2",
    "P2 Poke4 Stat3",
    "P2 Poke4 Stat4",
    "P2 Poke4 Stat5",
    "P2 Poke4 Stat6",
    "P2 Poke4 Type1",
    "P2 Poke4 Type2",
    "P2 Poke4 Type3",
    "P2 Poke4 Type4",
    "P2 Poke4 Type5",
    "P2 Poke4 Type6",
    "P2 Poke4 Type7",
    "P2 Poke4 Type8",
    "P2 Poke4 Type9",
    "P2 Poke4 Type10",
    "P2 Poke4 Type11",
    "P2 Poke4 Type12",
    "P2 Poke4 Type13",
    "P2 Poke4 Type14",
    "P2 Poke4 Type15",
    "P2 Poke4 Type16",
    "P2 Poke4 Type17",
    "P2 Poke4 Status1",
    "P2 Poke4 Status2",
    "P2 Poke4 Status3",
    "P2 Poke4 Status4",
    "P2 Poke4 Status5",
    "P2 Poke4 Faint",
    "P2 Poke5 HP",
    "P2 Poke5 Stat1",
    "P2 Poke5 Stat2",
    "P2 Poke5 Stat3",
    "P2 Poke5 Stat4",
    "P2 Poke5 Stat5",
    "P2 Poke5 Stat6",
    "P2 Poke5 Type1",
    "P2 Poke5 Type2",
    "P2 Poke5 Type3",
    "P2 Poke5 Type4",
    "P2 Poke5 Type5",
    "P2 Poke5 Type6",
    "P2 Poke5 Type7",
    "P2 Poke5 Type8",
    "P2 Poke5 Type9",
    "P2 Poke5 Type10",
    "P2 Poke5 Type11",
    "P2 Poke5 Type12",
    "P2 Poke5 Type13",
    "P2 Poke5 Type14",
    "P2 Poke5 Type15",
    "P2 Poke5 Type16",
    "P2 Poke5 Type17",
    "P2 Poke5 Status1",
    "P2 Poke5 Status2",
    "P2 Poke5 Status3",
    "P2 Poke5 Status4",
    "P2 Poke5 Status5",
    "P2 Poke5 Faint",
    "P2 Poke6 HP",
    "P2 Poke6 Stat1",
    "P2 Poke6 Stat2",
    "P2 Poke6 Stat3",
    "P2 Poke6 Stat4",
    "P2 Poke6 Stat5",
    "P2 Poke6 Stat6",
    "P2 Poke6 Type1",
    "P2 Poke6 Type2",
    "P2 Poke6 Type3",
    "P2 Poke6 Type4",
    "P2 Poke6 Type5",
    "P2 Poke6 Type6",
    "P2 Poke6 Type7",
    "P2 Poke6 Type8",
    "P2 Poke6 Type9",
    "P2 Poke6 Type10",
    "P2 Poke6 Type11",
    "P2 Poke6 Type12",
    "P2 Poke6 Type13",
    "P2 Poke6 Type14",
    "P2 Poke6 Type15",
    "P2 Poke6 Type16",
    "P2 Poke6 Type17",
    "P2 Poke6 Status1",
    "P2 Poke6 Status2",
    "P2 Poke6 Status3",
    "P2 Poke6 Status4",
    "P2 Poke6 Status5",
    "P2 Poke6 Faint"
};