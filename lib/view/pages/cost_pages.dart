part of 'pages.dart';


class CostPages extends StatefulWidget {
  const CostPages({super.key});

  @override
  State<CostPages> createState() => _CostPagesState();
}

class _CostPagesState extends State<CostPages> {
  final HomeViewmodel homeViewModel = HomeViewmodel();

  dynamic selectedOriginProvince;
  dynamic selectedOriginCity;
  dynamic selectedDestinationProvince;
  dynamic selectedDestinationCity;
  dynamic selectedCourier;
  dynamic packageWeight;

  @override
  void initState() {
    super.initState();
    homeViewModel.getProvinceList();
  }

  bool get isFormComplete {
    return selectedOriginProvince != null &&
        selectedOriginCity != null &&
        selectedDestinationProvince != null &&
        selectedDestinationCity != null &&
        selectedCourier != null &&
        packageWeight != null &&
        packageWeight.toString().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Shipping Cost Calculator"),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider<HomeViewmodel>(
        create: (BuildContext context) => homeViewModel,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Courier Selection",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  value: selectedCourier,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'jne', child: Text("JNE")),
                    DropdownMenuItem(value: 'pos', child: Text("POS")),
                    DropdownMenuItem(value: 'tiki', child: Text("TIKI")),
                  ],
                  hint: const Text("Select Courier"),
                  onChanged: (value) {
                    setState(() {
                      selectedCourier = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Package Weight (grams)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: packageWeight,
                  decoration: InputDecoration(
                    hintText: "Enter weight in grams",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    packageWeight = value;
                  },
                ),
                const SizedBox(height: 20),
                _buildDropdownSection(
                  title: "Origin", 
                  provinceValue: selectedOriginProvince, 
                  cityValue: selectedOriginCity, 
                  onProvinceChanged: (value) {
                    setState(() {
                      selectedOriginProvince = value;
                      selectedOriginCity = null;
                      homeViewModel.getCityListForOrigin(value.provinceId);
                    });
                  }, 
                  onCityChanged: (value) {
                    setState(() {
                      selectedOriginCity = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildDropdownSection(
                  title: "Destination", 
                  provinceValue: selectedDestinationProvince, 
                  cityValue: selectedDestinationCity, 
                  onProvinceChanged: (value) {
                    setState(() {
                      selectedDestinationProvince = value;
                      selectedDestinationCity = null;
                      homeViewModel.getCityListForDest(value.provinceId);
                    });
                  }, 
                  onCityChanged: (value) {
                    setState(() {
                      selectedDestinationCity = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isFormComplete
                      ? () {
                          homeViewModel.getOngkirList(
                            selectedOriginCity.cityId,
                            selectedDestinationCity.cityId,
                            int.parse(packageWeight),
                            selectedCourier,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      "Calculate Shipping Cost",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildShippingCostResult(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required dynamic provinceValue,
    required dynamic cityValue,
    required Function(dynamic) onProvinceChanged,
    required Function(dynamic) onCityChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title Province",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Consumer<HomeViewmodel>(
          builder: (context, viewModel, _) {
            switch (viewModel.provinceList.status) {
              case Status.loading:
                return const CircularProgressIndicator();
              case Status.completed:
                return DropdownButtonFormField(
                  value: provinceValue,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  hint: Text("Select $title Province"),
                  items: viewModel.provinceList.data!
                      .map<DropdownMenuItem<Province>>((Province value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value.province.toString()),
                    );
                  }).toList(),
                  onChanged: onProvinceChanged,
                );
              default:
                return const Text("Error fetching data.");
            }
          },
        ),
        const SizedBox(height: 10),
        Text(
          "$title City",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Consumer<HomeViewmodel>(
          builder: (context, viewModel, _) {
            switch (viewModel.cityListOrigin.status) {
              case Status.loading:
                return const CircularProgressIndicator();
              case Status.completed:
                return DropdownButtonFormField(
                  value: cityValue,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  hint: Text("Select $title City"),
                  items: viewModel.cityListOrigin.data!
                      .map<DropdownMenuItem<City>>((City value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value.cityName.toString()),
                    );
                  }).toList(),
                  onChanged: onCityChanged,
                );
              default:
                return const Text("Error fetching data.");
            }
          },
        ),
      ],
    );
  }

  Widget _buildShippingCostResult() {
    return Consumer<HomeViewmodel>(
      builder: (context, viewModel, _) {
        switch (viewModel.ongkirList.status) {
          case Status.loading:
            return const Center(child: CircularProgressIndicator());
          case Status.completed:
            return Column(
              children: viewModel.ongkirList.data![0].costs!.map((cost) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(cost.service?.toUpperCase().substring(0, 1)??""),
                      backgroundColor: Colors.teal,
                    ),
                    title: Text(
                      "${cost.description} (${cost.service})",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cost.cost!.map((detail) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            "Cost: Rp${detail.value} | ETA: ${detail.etd} days",
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }).toList(),
            );
          case Status.error:
            return Center(
              child: Text(viewModel.ongkirList.message ?? "Error fetching data."),
            );
          default:
            return const SizedBox();
        }
      },
    );
  }
}