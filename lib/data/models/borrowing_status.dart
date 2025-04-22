/// Énumération représentant les différents statuts d'un emprunt de batterie
enum BorrowingStatus {
  /// Emprunt en cours
  active,
  
  /// Emprunt terminé (batterie rendue)
  completed,
  
  /// Emprunt en retard
  late,
  
  /// Emprunt annulé
  cancelled,
  
  /// Emprunt perdu (batterie non rendue après un certain délai)
  lost
}
