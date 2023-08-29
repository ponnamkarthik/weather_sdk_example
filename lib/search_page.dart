import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_sdk/model/location_data.dart';
import 'package:weather_sdk/weather_sdk.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final WeatherSDK _weatherSDK = WeatherSDK();
  List<LocationData> _searchResults = [];
  Timer? _debounce;

  bool _loading = false;

  void _performSearch() {

    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _debounce?.cancel(); // Cancel the previous debounce if any
      _debounce = Timer(const Duration(milliseconds: 300), () async {
        setState(() {
          _loading = true;
        });
        final results = await _weatherSDK.searchLocation(query);
        setState(() {
          _searchResults = results;
          _loading = false;
        });
      });
    } else {
      setState(() {
        _loading = false;
        _searchResults = [];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel(); // Cancel the debounce timer when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Locations'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _performSearch();
              },
              decoration: const InputDecoration(
                hintText: 'Enter a location',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final location = _searchResults[index];
                  return ListTile(
                    title: Text(location.name),
                    subtitle: Text("${location.state}, ${location.country}"),
                    onTap: () {
                      Navigator.of(context).pop(location);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
