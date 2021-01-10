import 'package:equatable/equatable.dart';

class Location extends Equatable {
  const Location({this.country, this.city, this.state});

  final String? country;
  final String? city;
  final String? state;

  @override
  List<Object?> get props => [country, city, state];

  Location copyWith({
    String? country,
    String? city,
    String? state,
  }) {
    return Location(
      country: country ?? this.country,
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }
}
