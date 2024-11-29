import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import './widgets/solicitud_card.dart';
import './widgets/filter_button.dart';
import '/features/domain/entities/category_entity.dart';
import '/features/domain/entities/ticket_entity.dart';

import '/features/data/data_sources/api_oirs/oirsInfoService.dart'; // Importar ApiService
import '/features/data/data_sources/api_oirs/oirsIcsoService.dart';

class MisSolicitudesScreen extends StatefulWidget {
  const MisSolicitudesScreen({super.key});

  @override
  _MisSolicitudesScreenState createState() => _MisSolicitudesScreenState();
}

class _MisSolicitudesScreenState extends State<MisSolicitudesScreen> {
  final Logger _logger = Logger();
  List<CategoryTicketTypes> categories = [];
  List<Ticket> allSolicitudes = [];
  List<Ticket> filteredSolicitudes = [];
  String selectedFilter = 'Todas';
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndSolicitudes();
  }

  Future<void> _fetchCategoriesAndSolicitudes() async {
    try {
      final _infoService = InfoService();
      final _icsoService = IcsoService();

      // Obtener categorías
      final dataCategories = await _infoService.getCategories();
      if (dataCategories != null) {
        setState(() {
          categories = dataCategories.map<CategoryTicketTypes>((item) {
            return CategoryTicketTypes.fromJson(item);
          }).toList();
        });
      }

      // Obtener todas las solicitudes (Tickets)
      final _tickets = await _icsoService.getAllTickets();
      if (_tickets != null) {
        setState(() {
          allSolicitudes = List<Ticket>.from(_tickets);
          filteredSolicitudes = List<Ticket>.from(
              _tickets); // Inicializar con todas las solicitudes
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _logger.e('Error al obtener datos: $error');
    }
  }

  void _changeFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'Todas') {
        filteredSolicitudes = allSolicitudes;
      } else {
        filteredSolicitudes = allSolicitudes
            .where((solicitud) => solicitud.category.name == filter)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterButton(
                    label: 'Todas',
                    color: Colors.blueAccent,
                    isSelected: selectedFilter == 'Todas',
                    onTap: () => _changeFilter('Todas'),
                  ),
                  ...categories.map((category) {
                    return FilterButton(
                      label: category.name,
                      color: Colors.grey.shade300,
                      isSelected: selectedFilter == category.name,
                      onTap: () => _changeFilter(category.name),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredSolicitudes.length,
                      itemBuilder: (context, index) {
                        final solicitud = filteredSolicitudes[index];
                        return SolicitudCard(solicitud: solicitud);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
