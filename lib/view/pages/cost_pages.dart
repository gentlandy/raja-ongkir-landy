part of 'pages.dart';

class CostPage extends StatefulWidget {
  const CostPage({super.key});

  @override
  State<CostPage> createState() => _OngkirPageState();
}

class _OngkirPageState extends State<CostPage> {
  final HomeViewmodel homeViewModel = HomeViewmodel();

  // Use nullable typed variables for better type safety
  Province? selectedProvinceOrigin;
  City? selectedCityOrigin;
  Province? selectedProvinceDest;
  City? selectedCityDest;
  String? selectedCourier;
  String? weight;

  @override
  void initState() {
    super.initState();
    homeViewModel.getProvinceList();
  }

  // Improved form validation with more explicit checks
  bool get isFormValid {
    return selectedProvinceOrigin != null &&
        selectedCityOrigin != null &&
        selectedProvinceDest != null &&
        selectedCityDest != null &&
        selectedCourier != null &&
        weight != null &&
        weight!.trim().isNotEmpty &&
        double.tryParse(weight!) != null;
  }

  // Extracted method for dropdown styling
  InputDecoration _dropdownDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // Extracted method for section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  // Refactored dropdown builder
  Widget _buildDropdown<T>({
    required T? value,
    required List<T>? items,
    required String hintText,
    required void Function(T?) onChanged,
    required String Function(T) displayText,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: _dropdownDecoration(hintText),
      isExpanded: true,
      hint: Text(hintText),
      items: items?.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            displayText(item),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shipping Cost Calculator"),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: ChangeNotifierProvider<HomeViewmodel>.value(
        value: homeViewModel,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Courier Dropdown
                _buildSectionHeader("Courier"),
                _buildDropdown<String>(
                  value: selectedCourier,
                  items: ['jne', 'pos', 'tiki'],
                  hintText: 'Select Courier',
                  onChanged: (value) {
                    setState(() {
                      selectedCourier = value;
                    });
                  },
                  displayText: (courier) => courier.toUpperCase(),
                ),

                // Weight Input
                const SizedBox(height: 16),
                _buildSectionHeader("Package Weight"),
                TextFormField(
                  initialValue: weight,
                  decoration: InputDecoration(
                    labelText: "Weight (grams)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    weight = value;
                  },
                ),

                // Origin Selection
                const SizedBox(height: 16),
                _buildSectionHeader("Origin"),
                Row(
                  children: [
                    Expanded(
                      child: Consumer<HomeViewmodel>(
                        builder: (context, viewModel, _) {
                          return _buildDropdown<Province>(
                            value: selectedProvinceOrigin,
                            items: viewModel.provinceList.data,
                            hintText: 'Origin Province',
                            onChanged: (Province? newValue) {
                              setState(() {
                                selectedProvinceOrigin = newValue;
                                selectedCityOrigin = null;
                                if (newValue != null) {
                                  homeViewModel.getCityListForOrigin(
                                      newValue.provinceId);
                                }
                              });
                            },
                            displayText: (province) => province.province ?? '',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer<HomeViewmodel>(
                        builder: (context, viewModel, _) {
                          return _buildDropdown<City>(
                            value: selectedCityOrigin,
                            items: viewModel.cityListOrigin.data,
                            hintText: 'Origin City',
                            onChanged: (City? newValue) {
                              setState(() {
                                selectedCityOrigin = newValue;
                              });
                            },
                            displayText: (city) => city.cityName ?? '',
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Destination Selection
                const SizedBox(height: 16),
                _buildSectionHeader("Destination"),
                Row(
                  children: [
                    Expanded(
                      child: Consumer<HomeViewmodel>(
                        builder: (context, viewModel, _) {
                          return _buildDropdown<Province>(
                            value: selectedProvinceDest,
                            items: viewModel.provinceList.data,
                            hintText: 'Destination Province',
                            onChanged: (Province? newValue) {
                              setState(() {
                                selectedProvinceDest = newValue;
                                selectedCityDest = null;
                                if (newValue != null) {
                                  homeViewModel
                                      .getCityListForDest(newValue.provinceId);
                                }
                              });
                            },
                            displayText: (province) => province.province ?? '',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer<HomeViewmodel>(
                        builder: (context, viewModel, _) {
                          return _buildDropdown<City>(
                            value: selectedCityDest,
                            items: viewModel.cityListDest.data,
                            hintText: 'Destination City',
                            onChanged: (City? newValue) {
                              setState(() {
                                selectedCityDest = newValue;
                              });
                            },
                            displayText: (city) => city.cityName ?? '',
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Calculate Button
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFormValid ? Colors.blue[600] : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isFormValid
                      ? () {
                          homeViewModel.getOngkirList(
                            selectedCityOrigin!.cityId!,
                            selectedCityDest!.cityId!,
                            int.parse(weight!),
                            selectedCourier!,
                          );
                        }
                      : null,
                  child: const Text(
                    "Calculate Shipping Cost",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Results Section
                const SizedBox(height: 16),
                Consumer<HomeViewmodel>(
                  builder: (context, viewModel, _) {
                    if (viewModel.ongkirList.status == Status.completed) {
                      final ongkirData = viewModel.ongkirList.data![0].costs!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: ongkirData.map((ongkir) {
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.blue[600],
                                        child: Text(
                                          ongkir.service
                                                  ?.toUpperCase()
                                                  .substring(0, 1) ??
                                              "",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "${ongkir.description ?? "No Description"} (${ongkir.service ?? "Service"})",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...?ongkir.cost?.map((cost) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Cost: Rp ${cost.value ?? 0}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Estimated Delivery: ${cost.etd ?? 'N/A'} days",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList() ??
                                      [],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
