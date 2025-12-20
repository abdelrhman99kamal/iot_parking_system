import 'package:flutter/material.dart';

class CustomSlotCard extends StatelessWidget {
  const CustomSlotCard({
    super.key,
    required this.isVertical,
    required this.slotId,
    required this.isAvailable,
  });

  final bool isVertical;
  final bool isAvailable;
  final String slotId;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = isVertical ? 80.0 : 120.0;
    final double cardHeight = isVertical ? 120.0 : 80.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,

      decoration: BoxDecoration(
        color: (isAvailable) ? Color(0xFF133B26) : Color(0xFF451C21),
        border: Border.all(
          color: (isAvailable) ? Colors.green : Colors.red,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: isAvailable
          ? Text(
              slotId,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            )
          : Icon(Icons.directions_car_outlined, color: Colors.red, size: 38),
    );
  }
}
