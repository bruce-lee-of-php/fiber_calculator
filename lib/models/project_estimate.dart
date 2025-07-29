import 'dart:math';
import 'package:flutter/material.dart';

class ProjectEstimate with ChangeNotifier {
  // --- PRIMARY INPUTS ---
  double lengthSoftscape = 1000.0;
  double lengthAsphalt = 0.0;
  double lengthConcrete = 0.0;

  int numberOfHandholes = 4;
  int numberOfSpliceLocations = 2;
  double fiberCount = 48.0;
  bool isBoring = false;
  bool includeConduit = true;

  late double cablePricePerFoot;
  late double testingCost;
  bool isCablePriceOverridden = false;
  bool isTestingCostOverridden = false;

  // --- RE-INTRODUCED: Restoration Rates ---
  double priceTrenchingSoftscape = 8.0;
  double priceTrenchingAsphalt = 18.0;
  double priceTrenchingConcrete = 25.0;
  double priceBoring = 22.0;
  double priceRestoreAsphalt = 6.0;
  double priceRestoreConcrete = 10.0;

  // Material & Other Labor Rates
  double basePricePerFiberClosure = 4.0;
  double pricePerFootConduit = 1.75;
  double pricePerHandhole = 400.0;
  double terminationHardwareCost = 1000.0;
  double pricePerSetup = 2500.0;
  double pricePerHandholeExcavation = 500.0;
  double pricePerSplice = 30.0;

  // Ancillary Costs
  int trafficDays = 0;
  double trafficCostPerDay = 1500.0;
  double designContingency = 0.10;
  double constructionContingency = 0.15;
  double permitCosts = 500.0;

  // Internal constants
  static const double _cableCostFactorA = 0.40;
  static const double _cableCostExponentB = 0.301;
  static const double _ratePerFiberTest = 20.0;
  static const double _ratePerSpliceLocationTest = 50.0;

  ProjectEstimate() {
    _recalculateDefaults();
  }

  void _recalculateDefaults() {
    if (!isTestingCostOverridden) {
      testingCost =
          (fiberCount * _ratePerFiberTest) +
          (numberOfSpliceLocations * _ratePerSpliceLocationTest);
    }
    if (!isCablePriceOverridden) {
      cablePricePerFoot =
          _cableCostFactorA * pow(fiberCount, _cableCostExponentB);
    }
  }

  // --- GETTERS ---

  double get totalLength => lengthSoftscape + lengthAsphalt + lengthConcrete;

  double get installationCost {
    if (isBoring) {
      return totalLength * priceBoring;
    } else {
      return (lengthSoftscape * priceTrenchingSoftscape) +
          (lengthAsphalt * priceTrenchingAsphalt) +
          (lengthConcrete * priceTrenchingConcrete);
    }
  }

  // RE-INTRODUCED: Conditional restoration cost
  double get restorationCost {
    if (isBoring) return 0.0; // No restoration cost for HDD
    return (lengthAsphalt * priceRestoreAsphalt) +
        (lengthConcrete * priceRestoreConcrete);
  }

  double get cableCost => totalLength * cablePricePerFoot;
  double get closureCost =>
      numberOfSpliceLocations * fiberCount * basePricePerFiberClosure;
  double get conduitCost =>
      includeConduit ? totalLength * pricePerFootConduit : 0;
  double get handholeCost => numberOfHandholes * pricePerHandhole;
  double get materialCost =>
      cableCost +
      conduitCost +
      handholeCost +
      closureCost +
      terminationHardwareCost;

  double get setupCost => pricePerSetup;
  double get excavationCost => numberOfHandholes * pricePerHandholeExcavation;
  double get splicingCost =>
      (numberOfSpliceLocations * fiberCount) * pricePerSplice;
  double get trafficControlCost => trafficDays * trafficCostPerDay;

  double get laborCost {
    // Restoration cost is now correctly included
    return setupCost +
        installationCost +
        excavationCost +
        splicingCost +
        testingCost +
        restorationCost;
  }

  double get subTotal =>
      materialCost + laborCost + permitCosts + trafficControlCost;
  double get totalContingencyRate =>
      designContingency + constructionContingency;
  double get contingencyAmount => subTotal * totalContingencyRate;
  double get finalCost => subTotal + contingencyAmount;

  void updateValue(String field, dynamic value) {
    switch (field) {
      case 'lengthSoftscape':
        lengthSoftscape = value;
        break;
      case 'lengthAsphalt':
        lengthAsphalt = value;
        break;
      case 'lengthConcrete':
        lengthConcrete = value;
        break;
      case 'priceTrenchingSoftscape':
        priceTrenchingSoftscape = value;
        break;
      case 'priceTrenchingAsphalt':
        priceTrenchingAsphalt = value;
        break;
      case 'priceTrenchingConcrete':
        priceTrenchingConcrete = value;
        break;
      case 'priceBoring':
        priceBoring = value;
        break;
      case 'priceRestoreAsphalt':
        priceRestoreAsphalt = value;
        break;
      case 'priceRestoreConcrete':
        priceRestoreConcrete = value;
        break;
      case 'trafficDays':
        trafficDays = value;
        break;
      case 'trafficCostPerDay':
        trafficCostPerDay = value;
        break;
      case 'designContingency':
        designContingency = value;
        break;
      case 'constructionContingency':
        constructionContingency = value;
        break;
      case 'includeConduit':
        includeConduit = value;
        break;
      case 'numberOfHandholes':
        numberOfHandholes = value;
        break;
      case 'numberOfSpliceLocations':
        numberOfSpliceLocations = value;
        _recalculateDefaults();
        break;
      case 'fiberCount':
        fiberCount = value;
        _recalculateDefaults();
        break;
      case 'isBoring':
        isBoring = value;
        break;
      case 'cablePricePerFoot':
        cablePricePerFoot = value;
        isCablePriceOverridden = true;
        break;
      case 'testingCost':
        testingCost = value;
        isTestingCostOverridden = true;
        break;
      case 'basePricePerFiberClosure':
        basePricePerFiberClosure = value;
        break;
      case 'pricePerFootConduit':
        pricePerFootConduit = value;
        break;
      case 'pricePerHandhole':
        pricePerHandhole = value;
        break;
      case 'terminationHardwareCost':
        terminationHardwareCost = value;
        break;
      case 'pricePerSetup':
        pricePerSetup = value;
        break;
      case 'pricePerHandholeExcavation':
        pricePerHandholeExcavation = value;
        break;
      case 'pricePerSplice':
        pricePerSplice = value;
        break;
      case 'permitCosts':
        permitCosts = value;
        break;
    }
    notifyListeners();
  }

  void reset() {
    lengthSoftscape = 1000.0;
    lengthAsphalt = 0.0;
    lengthConcrete = 0.0;
    priceTrenchingSoftscape = 8.0;
    priceTrenchingAsphalt = 18.0;
    priceTrenchingConcrete = 25.0;
    priceBoring = 22.0;
    priceRestoreAsphalt = 6.0;
    priceRestoreConcrete = 10.0;
    trafficDays = 0;
    trafficCostPerDay = 1500.0;
    designContingency = 0.10;
    constructionContingency = 0.15;
    includeConduit = true;
    numberOfHandholes = 4;
    numberOfSpliceLocations = 2;
    fiberCount = 48.0;
    isBoring = false;
    isCablePriceOverridden = false;
    isTestingCostOverridden = false;
    basePricePerFiberClosure = 4.0;
    pricePerFootConduit = 1.75;
    pricePerHandhole = 400.0;
    terminationHardwareCost = 1000.0;
    pricePerSetup = 2500.0;
    pricePerHandholeExcavation = 500.0;
    pricePerSplice = 30.0;
    permitCosts = 500.0;
    _recalculateDefaults();
    notifyListeners();
  }
}
