# Spacing Guidelines

## Forbidden Spacing Methods

### Forbyd brug af SizedBox til spacing (højde eller bredde)

forbid: SizedBox\(height:\s*\d+
forbid: SizedBox\(width:\s*\d+

## Allowed Spacing Methods

### Tillad SizedBox() uden parametre eller med child (til specifikke layout-behov)

allow: SizedBox\(\)
allow: SizedBox\(child:

## Required Spacing Methods

### Påkræv brug af Gap() for spacing

require: Gap\(

### Forbyd hårdkodede tal i Gap()

forbid: Gap\(\d+

### Påkræv brug af AppDimensionsTheme i Gap()

require: Gap\(AppDimensionsTheme
