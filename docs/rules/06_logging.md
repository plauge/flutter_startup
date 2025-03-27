# Logging Guidelines

## Forbidden Logging Methods

### Forbyd brug af print()

forbid: print(

### Forbyd brug af debugPrint()

forbid: debugPrint(

### Forbyd brug af \_log()

forbid: \_log(

## Required Logging Methods

### Påkræv brug af log() fra dart:developer eller Logger

require: log(

### Påkræv brug af Logger med forskellige niveauer

require: logger.d(
require: logger.i(
require: logger.w(
require: logger.e(
