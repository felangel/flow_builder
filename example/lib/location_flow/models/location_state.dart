import 'package:equatable/equatable.dart';

enum LocationStatus { initial, loading, success, failure }

class LocationState extends Equatable {
  const LocationState._({
    this.status = LocationStatus.initial,
    this.locations = const <String>[],
    this.selectedLocation,
  });

  const LocationState.initial() : this._();
  const LocationState.loading() : this._(status: LocationStatus.loading);
  const LocationState.success(List<String> locations)
      : this._(status: LocationStatus.success, locations: locations);
  const LocationState.failure() : this._(status: LocationStatus.failure);

  final LocationStatus status;
  final List<String> locations;
  final String? selectedLocation;

  LocationState copyWith({String? selectedLocation}) {
    return LocationState._(
      locations: locations,
      status: status,
      selectedLocation: selectedLocation ?? this.selectedLocation,
    );
  }

  @override
  List<Object?> get props => [status, locations, selectedLocation];
}
