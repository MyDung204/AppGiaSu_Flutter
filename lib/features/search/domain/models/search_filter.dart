class SearchFilter {
  final double? minPrice;
  final double? maxPrice;
  final List<String>? teachingMode; // 'Online', 'Offline'
  final String? gender; // 'Nam', 'Nữ', 'Bất kỳ'
  final String? location;
  final List<String>? subjects;

  const SearchFilter({
    this.minPrice,
    this.maxPrice,
    this.teachingMode,
    this.gender,
    this.location,
    this.subjects,
  });

  SearchFilter copyWith({
    double? minPrice,
    double? maxPrice,
    List<String>? teachingMode,
    String? gender,
    String? location,
    List<String>? subjects,
  }) {
    return SearchFilter(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      teachingMode: teachingMode ?? this.teachingMode,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      subjects: subjects ?? this.subjects,
    );
  }
}
