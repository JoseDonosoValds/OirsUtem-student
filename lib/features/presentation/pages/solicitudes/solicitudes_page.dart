import 'package:flutter/material.dart';
import '/core/core.dart'; // Importar tu tema y StyleText
import 'package:logger/logger.dart';
import './widgets/solicitud_card.dart';
import './widgets/filter_button.dart';
import './widgets/add_solicitud_button.dart'; // Importar el nuevo widget
import '/features/domain/entities/category_entity.dart';
import '/features/domain/entities/ticket_entity.dart';
import '/features/data/data_sources/api_oirs/oirsInfoService.dart';
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
      final infoService = InfoService();
      final icsoService = IcsoService();

      // Obtener categorías
      final dataCategories = await infoService.getCategories();
      setState(() {
        categories = dataCategories.map<CategoryTicketTypes>((item) {
          return CategoryTicketTypes.fromJson(item);
        }).toList();
      });
    
      // Obtener todas las solicitudes (Tickets)
      final tickets = await icsoService.getAllTickets();
      setState(() {
        allSolicitudes = List<Ticket>.from(tickets);
        filteredSolicitudes = List<Ticket>.from(tickets);
        isLoading = false;
      });
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis Solicitudes',
                style: StyleText.headlineSmall.copyWith(
                  color: theme.colorScheme.primary, // Color dinámico
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterButton(
                      label: 'Todas',
                      isSelected: selectedFilter == 'Todas',
                      onTap: () => _changeFilter('Todas'),
                    ),
                    ...categories.map((category) {
                      return FilterButton(
                        label: category.name,
                        isSelected: selectedFilter == category.name,
                        onTap: () => _changeFilter(category.name),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredSolicitudes.length,
                        itemBuilder: (context, index) {
                          final solicitud = filteredSolicitudes[index];
                          return SolicitudCard(
                            solicitud: solicitud,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const AddSolicitudButton(), // Añadir el botón aquí
    );
  }
}
