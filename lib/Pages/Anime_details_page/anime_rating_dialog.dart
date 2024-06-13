import 'package:flutter/material.dart';

class AnimeRatingDialog extends StatefulWidget {
  const AnimeRatingDialog({super.key, required this.submit, required this.initialRating});
  final int initialRating;
  final Function submit;

  @override
  State<AnimeRatingDialog> createState() => _AnimeRatingDialogState();
}

class _AnimeRatingDialogState extends State<AnimeRatingDialog> {
  late int _selectedRating;
  void _submitRating() {
    widget.submit(_selectedRating);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate this Anime'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select a rating from 0 to 10'),
          const SizedBox(height: 20),
          DropdownButton<int>(
            value: _selectedRating,
            onChanged: (newValue) {
              setState(() {
                _selectedRating = newValue!;
              });
            },
            items: [
              ...List.generate(11, (index) => index)
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString(), style: const TextStyle(color: Colors.black),),
                );
              }),
            ]

          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _submitRating();
          } ,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
