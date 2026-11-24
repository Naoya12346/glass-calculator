import 'package:flutter/material.dart';

class UnitDefinition {
  const UnitDefinition({
    required this.id,
    required this.label,
    required this.symbol,
    this.factor = 1,
  });

  final String id;
  final String label;
  final String symbol;
  final double factor;
}

class UnitCategory {
  const UnitCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.units,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<UnitDefinition> units;

  UnitDefinition unit(String id) {
    return units.firstWhere(
      (element) => element.id == id,
      orElse: () => units.first,
    );
  }
}

class ConverterCatalog {
  const ConverterCatalog._();

  static const List<UnitCategory> categories = <UnitCategory>[
    UnitCategory(
      id: 'length',
      label: 'Length',
      icon: Icons.straighten,
      units: <UnitDefinition>[
        UnitDefinition(id: 'm', label: 'Meter', symbol: 'm', factor: 1),
        UnitDefinition(id: 'km', label: 'Kilometer', symbol: 'km', factor: 1000),
        UnitDefinition(id: 'cm', label: 'Centimeter', symbol: 'cm', factor: 0.01),
        UnitDefinition(id: 'mm', label: 'Millimeter', symbol: 'mm', factor: 0.001),
        UnitDefinition(id: 'mi', label: 'Mile', symbol: 'mi', factor: 1609.344),
        UnitDefinition(id: 'yd', label: 'Yard', symbol: 'yd', factor: 0.9144),
        UnitDefinition(id: 'ft', label: 'Foot', symbol: 'ft', factor: 0.3048),
        UnitDefinition(id: 'in', label: 'Inch', symbol: 'in', factor: 0.0254),
        UnitDefinition(id: 'nmi', label: 'Nautical mile', symbol: 'nmi', factor: 1852),
      ],
    ),
    UnitCategory(
      id: 'weight',
      label: 'Weight',
      icon: Icons.scale,
      units: <UnitDefinition>[
        UnitDefinition(id: 'kg', label: 'Kilogram', symbol: 'kg', factor: 1),
        UnitDefinition(id: 'g', label: 'Gram', symbol: 'g', factor: 0.001),
        UnitDefinition(id: 'mg', label: 'Milligram', symbol: 'mg', factor: 0.000001),
        UnitDefinition(id: 't', label: 'Tonne', symbol: 't', factor: 1000),
        UnitDefinition(id: 'lb', label: 'Pound', symbol: 'lb', factor: 0.45359237),
        UnitDefinition(id: 'oz', label: 'Ounce', symbol: 'oz', factor: 0.0283495231),
      ],
    ),
    UnitCategory(
      id: 'temperature',
      label: 'Temperature',
      icon: Icons.thermostat,
      units: <UnitDefinition>[
        UnitDefinition(id: 'c', label: 'Celsius', symbol: '°C'),
        UnitDefinition(id: 'f', label: 'Fahrenheit', symbol: '°F'),
        UnitDefinition(id: 'k', label: 'Kelvin', symbol: 'K'),
      ],
    ),
    UnitCategory(
      id: 'area',
      label: 'Area',
      icon: Icons.grid_on,
      units: <UnitDefinition>[
        UnitDefinition(id: 'm2', label: 'Square meter', symbol: 'm²', factor: 1),
        UnitDefinition(id: 'km2', label: 'Square kilometer', symbol: 'km²', factor: 1000000),
        UnitDefinition(id: 'cm2', label: 'Square centimeter', symbol: 'cm²', factor: 0.0001),
        UnitDefinition(id: 'ha', label: 'Hectare', symbol: 'ha', factor: 10000),
        UnitDefinition(id: 'acre', label: 'Acre', symbol: 'ac', factor: 4046.8564224),
        UnitDefinition(id: 'ft2', label: 'Square foot', symbol: 'ft²', factor: 0.09290304),
      ],
    ),
    UnitCategory(
      id: 'volume',
      label: 'Volume',
      icon: Icons.local_drink_outlined,
      units: <UnitDefinition>[
        UnitDefinition(id: 'l', label: 'Liter', symbol: 'L', factor: 1),
        UnitDefinition(id: 'ml', label: 'Milliliter', symbol: 'mL', factor: 0.001),
        UnitDefinition(id: 'm3', label: 'Cubic meter', symbol: 'm³', factor: 1000),
        UnitDefinition(id: 'gal', label: 'US gallon', symbol: 'gal', factor: 3.785411784),
        UnitDefinition(id: 'qt', label: 'US quart', symbol: 'qt', factor: 0.946352946),
        UnitDefinition(id: 'pt', label: 'US pint', symbol: 'pt', factor: 0.473176473),
      ],
    ),
    UnitCategory(
      id: 'speed',
      label: 'Speed',
      icon: Icons.speed,
      units: <UnitDefinition>[
        UnitDefinition(id: 'ms', label: 'Meter / second', symbol: 'm/s', factor: 1),
        UnitDefinition(id: 'kmh', label: 'Kilometer / hour', symbol: 'km/h', factor: 0.2777777778),
        UnitDefinition(id: 'mph', label: 'Mile / hour', symbol: 'mph', factor: 0.44704),
        UnitDefinition(id: 'knot', label: 'Knot', symbol: 'kn', factor: 0.5144444444),
        UnitDefinition(id: 'fts', label: 'Foot / second', symbol: 'ft/s', factor: 0.3048),
      ],
    ),
    UnitCategory(
      id: 'time',
      label: 'Time',
      icon: Icons.schedule,
      units: <UnitDefinition>[
        UnitDefinition(id: 's', label: 'Second', symbol: 's', factor: 1),
        UnitDefinition(id: 'ms2', label: 'Millisecond', symbol: 'ms', factor: 0.001),
        UnitDefinition(id: 'min', label: 'Minute', symbol: 'min', factor: 60),
        UnitDefinition(id: 'h', label: 'Hour', symbol: 'h', factor: 3600),
        UnitDefinition(id: 'd', label: 'Day', symbol: 'd', factor: 86400),
        UnitDefinition(id: 'wk', label: 'Week', symbol: 'wk', factor: 604800),
      ],
    ),
    UnitCategory(
      id: 'data',
      label: 'Data',
      icon: Icons.storage_outlined,
      units: <UnitDefinition>[
        UnitDefinition(id: 'b', label: 'Byte', symbol: 'B', factor: 1),
        UnitDefinition(id: 'kb', label: 'Kilobyte', symbol: 'KB', factor: 1024),
        UnitDefinition(id: 'mb', label: 'Megabyte', symbol: 'MB', factor: 1048576),
        UnitDefinition(id: 'gb', label: 'Gigabyte', symbol: 'GB', factor: 1073741824),
        UnitDefinition(id: 'tb', label: 'Terabyte', symbol: 'TB', factor: 1099511627776),
      ],
    ),
    UnitCategory(
      id: 'currency',
      label: 'Currency',
      icon: Icons.currency_exchange,
      units: <UnitDefinition>[
        UnitDefinition(id: 'usd', label: 'US Dollar', symbol: 'USD', factor: 1),
        UnitDefinition(id: 'inr', label: 'Indian Rupee', symbol: 'INR', factor: 83.2),
        UnitDefinition(id: 'eur', label: 'Euro', symbol: 'EUR', factor: 0.92),
        UnitDefinition(id: 'gbp', label: 'British Pound', symbol: 'GBP', factor: 0.78),
        UnitDefinition(id: 'jpy', label: 'Japanese Yen', symbol: 'JPY', factor: 149),
        UnitDefinition(id: 'aed', label: 'UAE Dirham', symbol: 'AED', factor: 3.67),
        UnitDefinition(id: 'aud', label: 'Australian Dollar', symbol: 'AUD', factor: 1.52),
        UnitDefinition(id: 'cad', label: 'Canadian Dollar', symbol: 'CAD', factor: 1.36),
      ],
    ),
  ];
}
