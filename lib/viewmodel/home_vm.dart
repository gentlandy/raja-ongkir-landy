import 'package:flutter/material.dart';
import 'package:learn_mvvm/data/response/api_response.dart';
import 'package:learn_mvvm/model/costs/ongkir.dart';
import 'package:learn_mvvm/model/model.dart';
import 'package:learn_mvvm/repository/home_repository.dart';

class HomeViewmodel with ChangeNotifier {
  final HomeRepository _homeRepository;

  HomeViewmodel({HomeRepository? homeRepository})
      : _homeRepository = homeRepository ?? HomeRepository();

  ApiResponse<List<Province>> provinceList = ApiResponse.loading();

  void setProvinceList(ApiResponse<List<Province>> response) {
    provinceList = response;
    notifyListeners();
  }

  Future<void> getProvinceList() async {
    try {
      setProvinceList(ApiResponse.loading());
      final value = await _homeRepository.fetchProvinceList();
      setProvinceList(ApiResponse.completed(value));
    } catch (error) {
      setProvinceList(ApiResponse.error(error.toString()));
    }
  }

  ApiResponse<List<City>> cityListOrigin = ApiResponse.loading();

  void setCityListOrigin(ApiResponse<List<City>> response) {
    cityListOrigin = response;
    notifyListeners();
  }

Future<void> getCityListForOrigin(var provId) async {
  try {
    // Ensure provId is not null and is of the correct type
    if (provId == null) {
      throw ArgumentError('Province ID cannot be null');
    }

    // Set loading state before fetching
    setCityListOrigin(ApiResponse.loading());

    // Fetch city list
    final value = await _homeRepository.fetchCityList(provId);

    // Check if the returned value is null or empty
    if (value == null || value.isEmpty) {
      setCityListOrigin(ApiResponse.error('No cities found for this province'));
      return;
    }

    // Set completed state with fetched data
    setCityListOrigin(ApiResponse.completed(value));

  } catch (error, stackTrace) {
    // More detailed error logging
    print('Error fetching city list for origin: $error');
    print('Stack trace: $stackTrace');

    // Set error state with detailed error message
    setCityListOrigin(ApiResponse.error(error.toString()));
  }
}

  ApiResponse<List<City>> cityListDest = ApiResponse.loading();

  void setCityListDest(ApiResponse<List<City>> response) {
    cityListDest = response;
    notifyListeners();
  }

  Future<void> getCityListForDest(var provId) async {
    try {
      if (provId == null) {
        throw ArgumentError('Province ID cannot be null');
      }

      setCityListDest(ApiResponse.loading());
      final value = await _homeRepository.fetchCityList(provId);
      setCityListDest(ApiResponse.completed(value));
    } catch (error) {
      setCityListDest(ApiResponse.error(error.toString()));
    }
  }

  ApiResponse<List<Ongkir>> ongkirList = ApiResponse.loading();

  void setOngkirList(ApiResponse<List<Ongkir>> response) {
    ongkirList = response;
    debugPrint("Ongkir List Updated: ${response.data}");
    notifyListeners();
  }

  Future<void> getOngkirList(
      String origin, String destination, int weight, String courier) async {
    try {
      setOngkirList(ApiResponse.loading());
      final value = await _homeRepository.fetchOngkirList(
          origin, destination, weight, courier);
      setOngkirList(ApiResponse.completed(value));
    } catch (error) {
      setOngkirList(ApiResponse.error(error.toString()));
    }
  }
}