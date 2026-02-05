import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/customers/models/customer_model.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/components/common/custom_search_field.dart';
import 'package:bizly/components/common/custom_button.dart';
import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CustomerModel> allCustomers = [];
  List<CustomerModel> filteredCustomers = [];

  @override
  void initState() {
    super.initState();

    // Dummy data
    allCustomers = [
      CustomerModel(
        name: "John Doe",
        email: "john@example.com",
        phone: "+92 300 1234567",
        address: "Karachi, Pakistan",
        secondaryPhone: "+92 300 7654321",
        companyName: "Fixonto Ltd",
        taxNumber: "1234567",
        website: "www.fixonto.com",
        socialLink: "https://facebook.com/johndoe",
        notes: "VIP customer",
        city: "Karachi",
        country: "Pakistan",
      ),
      CustomerModel(
        name: "Jane Smith",
        email: "jane@example.com",
        phone: "+92 301 9876543",
        address: "Lahore, Pakistan",
        secondaryPhone: "+92 301 1234567",
        companyName: "Tech Solutions",
        taxNumber: "7654321",
        website: "www.techsolutions.com",
        socialLink: "https://linkedin.com/in/janesmith",
        notes: "Frequent buyer",
        city: "Lahore",
        country: "Pakistan",
      ),
      CustomerModel(
        name: "Ali Khan",
        email: "ali@example.com",
        phone: "+92 302 1122334",
        address: "Islamabad",
        secondaryPhone: "+92 302 9988776",
        companyName: "Khan Enterprises",
        taxNumber: "1122334",
        website: "www.khanenterprises.com",
        socialLink: "https://twitter.com/alikhan",
        notes: "New customer",
        city: "Islamabad",
        country: "Pakistan",
      ),
    ];


    filteredCustomers = allCustomers;
  }

  void _filterCustomers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCustomers = allCustomers;
      });
    } else {
      setState(() {
        filteredCustomers = allCustomers
            .where((c) =>
        c.name.toLowerCase().contains(query.toLowerCase()) ||
            c.email.toLowerCase().contains(query.toLowerCase()) ||
            c.phone.contains(query))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: const
      body: Column(

        children: [
            Container(
              // color: Colors.red,
              decoration: BoxDecoration(
                  color: AppColors.primaryDense,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24),bottomRight:  Radius.circular(24),)
              ),
              child: Column(
                  children: [
                    CustomAppBar2(title: "Customers",backgroundColor: AppColors.primaryDense,textColor: Colors.white,),
                    // 🔹 Search Bar
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomSearchField(
                        hintText: "Search Customers...",
                        controller: _searchController,
                        onChanged: _filterCustomers,
                        onClear: () => _filterCustomers(""),
                      ),
                    ),
                  ],
              ),
            ),
          // const SizedBox(height: 15),

          // 🔹 Customers List
          Expanded(
            child: filteredCustomers.isEmpty
                ? const Center(
              child: Text("No customers found"),
            )
                : ListView.builder(
              padding: EdgeInsets.only(bottom: 100,left: 20,right: 20,top: 20),
              itemCount: filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = filteredCustomers[index];
                return InkWell(
                    onTap: (){
                      Get.to(() => CustomerDetailScreen(customer: customer));
                    },
                    child: _customerCard(customer));
              },
            ),
          ),
        ],
      ),

      // 🔹 Floating Add Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // TODO: Navigate to AddCustomerScreen
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 🔹 Customer Card
  Widget _customerCard(CustomerModel customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              customer.name[0],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer.email,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  customer.phone,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
