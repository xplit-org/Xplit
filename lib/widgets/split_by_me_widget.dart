import 'package:expenser/core/utils.dart';
import 'package:flutter/material.dart';
import 'package:expenser/core/app_constants.dart';

class split_by_me_widget extends StatelessWidget {
  final Map<String, dynamic> data;
  const split_by_me_widget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User name and time (right-aligned)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Time and name row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      data["time"],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Payment request bubble
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppConstants.SPLIT_REQUEST,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: AppConstants.FONT_MEDIUM,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.more_vert,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "₹ ${data["amount"]}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: data["totalCount"] > 0 ? data["paidCount"] / data["totalCount"] : 0.0,
                        minHeight: AppConstants.SMALL_PADDING,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        borderRadius: BorderRadius.circular(AppConstants.SMALL_BORDER_RADIUS),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${data["paidCount"]} of ${data["totalCount"]} paid",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "₹ ${data["remainingAmount"]} left",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
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
          const SizedBox(width: 12),

          // Profile picture
          CircleAvatar(
            radius: 20,
            backgroundImage: Utils.getProfileImageProvider(data["profilePic"]),
            child: Utils.getProfileImageProvider(data["profilePic"]) == null
                ? const Icon(Icons.person)
                : null,
          ),
        ],
      ),
    );
  }
}