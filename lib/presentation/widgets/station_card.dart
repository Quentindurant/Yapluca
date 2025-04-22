import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/charging_station.dart';
import 'primary_button.dart';

class StationCard extends StatelessWidget {
  final ChargingStation station;
  final VoidCallback onRentNow;
  final VoidCallback onDetails;
  final VoidCallback onMap;

  const StationCard({
    Key? key,
    required this.station,
    required this.onRentNow,
    required this.onDetails,
    required this.onMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Station name and availability
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: station.availability > 0 
                                ? AppColors.primaryColor 
                                : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            station.availability > 0 
                                ? '${station.availability} disponibles' 
                                : 'Aucune disponible',
                            style: TextStyle(
                              fontSize: 14,
                              color: station.availability > 0 
                                  ? AppColors.textSecondary 
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          const Divider(height: 1, thickness: 1, color: AppColors.grey200),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Rent Now',
                    onPressed: onRentNow,
                    height: 36,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SecondaryButton(
                    text: 'Détails',
                    onPressed: onDetails,
                    height: 36,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FavoriteLocationCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;

  const FavoriteLocationCard({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    color: AppColors.grey200,
                    child: const Icon(Icons.image_not_supported, color: AppColors.grey500),
                  );
                },
              ),
            ),
            // Name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
