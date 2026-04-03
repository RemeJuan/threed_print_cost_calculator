class PremiumState {
  const PremiumState({
    required this.isPremium,
    required this.isLoading,
    this.userId = '',
  });

  const PremiumState.loading() : this(isPremium: false, isLoading: true);

  final bool isPremium;
  final bool isLoading;
  final String userId;

  PremiumState copyWith({bool? isPremium, bool? isLoading, String? userId}) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
    );
  }
}
