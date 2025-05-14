import 'dart:developer';

import 'package:big_szef_menu/models/table_model.dart';
import 'package:big_szef_menu/utils/table_url_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_providers.dart';
import '../../providers/product_providers.dart';
import '../../services/order_service.dart';
import 'order_success_modal.dart';
import '../home_screen/home_screen.dart';
import 'dart:convert';

class CheckoutButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentTableId = TableUrlGenerator().getTableIdFromUrl() ?? '';
    return ElevatedButton(
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (context) => TablesWidget(currentTable: currentTableId),
      ),
      child: Text('Continue Order'),
    );
  }
}

class TablesWidget extends StatefulWidget {
  final String currentTable;
  const TablesWidget({super.key, required this.currentTable});

  @override
  State<TablesWidget> createState() => _TablesWidgetState();
}

class _TablesWidgetState extends State<TablesWidget> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentTable.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ref = ProviderScope.containerOf(context);
        ref.read(selectedTableProvider.notifier).state =
            TableModel(id: widget.currentTable);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final tablesAsync = ref.watch(allTablesStateProvider);

        final selectedTable = ref.watch(selectedTableProvider);

        // Print selected table details when it changes
        if (selectedTable != null) {
          debugPrint('🪑 SELECTED TABLE: ID=${selectedTable.id},');
        }

        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 1,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select a Table',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                tablesAsync.when(
                  data: (tables) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tables.map((table) {
                      return ChoiceChip(
                        label: Text(table.name ?? 'Table ${table.id}'),
                        selected: selectedTable != null &&
                            selectedTable.id == table.id,
                        onSelected: (selected) {
                          if (selected) {
                            debugPrint(
                                '🪑 TABLE SELECTED: ID=${table.id}, Name=${table.name}');
                          } else {
                            debugPrint(
                                '🪑 TABLE DESELECTED: ID=${table.id}, Name=${table.name}');
                          }
                          ref.read(selectedTableProvider.notifier).state =
                              selected ? table : null;
                        },
                        selectedColor: Colors.green,
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: selectedTable != null &&
                                  selectedTable.id == table.id
                              ? Colors.white
                              : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text('Error loading tables: $error'),
                  ),
                ),
                const SizedBox(height: 24),
                if (selectedTable != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : () => _createOrder(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createOrder(BuildContext context, WidgetRef ref) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final response = await OrderService().createOrder(
        context: context,
        items: ref
            .read(cartProvider)
            .items
            .map((item) => {
                  'id': int.parse(item.product.id),
                  'qty': item.quantity,
                  'note': item.selectedVariant != null
                      ? 'Option: ${item.selectedVariant}'
                      : '',
                  'tags': [],
                })
            .toList(),
        paymentMethodId: '900000002',
        tableId: int.parse(widget.currentTable),
        note: 'Table: ${widget.currentTable}',
      );

      if (response['statusCode'] >= 200 && response['statusCode'] < 300) {
        ref.read(cartProvider.notifier).clearCart();
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
        await Future.delayed(const Duration(milliseconds: 400));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order created successfully'),
            backgroundColor: Colors.green,
          ),
        );

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => OrderSuccessModal(orderDetails: response),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}

String verbaliseCurrentTableId(String currentTable) {
  switch (currentTable) {
    // Named Tables
    case '4395200542520864':
      return 'ALI BEY';
    case '1580687040799673':
      return 'HASAN BEY';
    case '1802543576972375':
      return 'KASIM BEY';
    case '3151257746828540':
      return 'ERSIN BEY';
    case '1205070668062021':
      return 'VIP';

    // BOS HESAP Tables
    case '3954841826543608':
      return 'BOS HESAP 01';
    case '816234345449612':
      return 'BOS HESAP 02';
    case '1950174431070367':
      return 'BOS HESAP 03';
    case '807966533404843':
      return 'BOS HESAP 04';
    case '579603122276549':
      return 'BOS HESAP 05';
    case '1702492257044686':
      return 'BOS HESAP 06';

    // Service Tables
    case '3835995791925704':
      return 'SERVIS 01';
    case '912926949614029':
      return 'SERVIS 02';
    case '739689443729872':
      return 'SERVIS 03';
    case '2227294316372436':
      return 'SERVIS 04';
    case '2123682525337498':
      return 'SERVIS 05';

    // Delivery Tables - PYSZNE
    case '2100227708934039':
      return 'PYSZNE 05';
    case '3785598645674426':
      return 'PYSZNE 02';
    case '2643489532256690':
      return 'PYSZNE 01';
    case '688248620425662':
      return 'PYSZNE 03';
    case '2067126395969987':
      return 'PYSZNE 04';

    // Delivery Tables - WOLT
    case '1570048378544155':
      return 'WOLT 01';
    case '76220098289736':
      return 'WOLT 02';
    case '1551103277801570':
      return 'WOLT 03';
    case '2924311696515187':
      return 'WOLT 04';
    case '1145387782119547':
      return 'WOLT 05';

    // Delivery Tables - UBER
    case '684391762370580':
      return 'UBER 01';
    case '595206766469152':
      return 'UBER 02';
    case '3686071391101004':
      return 'UBER 03';
    case '962263261519982':
      return 'UBER 04';
    case '1892372789207158':
      return 'UBER 05';

    // Delivery Tables - GLOVO & BOLT
    case '1090072883773113':
      return 'GLOVO 01';
    case '2966990772614700':
      return 'GLOVO 02';
    case '3243543770363622':
      return 'GLOVO 03';
    case '1350867647133446':
      return 'GLOVO 04';
    case '2645637078408290':
      return 'BOLT 01';
    case '438234341661907':
      return 'BOLT 02';
    case '2290675211263189':
      return 'BOLT 03';
    case '1556386127502924':
      return 'BOLT 04';

    // P Tables
    case '1485063843087708':
      return 'P01';
    case '4275465430052629':
      return 'P02';
    case '1413904837835616':
      return 'P03';
    case '573676067303223':
      return 'P04';
    case '1418861206646593':
      return 'P05';
    case '1043893405285254':
      return 'P06';
    case '1451026216726343':
      return 'P07';
    case '568522117088604':
      return 'P08';
    case '995824131308472':
      return 'P09';
    case '2156281321516918':
      return 'P10';
    case '3245948907748454':
      return 'P11';
    case '1812525047544932':
      return 'P12';
    case '4259449520454761':
      return 'P13';
    case '4334989405257486':
      return 'P14';
    case '1548290069561107':
      return 'P15';
    case '839955473170224':
      return 'P17';
    case '567216459939656':
      return 'P18';
    case '3579251232881414':
      return 'P19';
    case '3189719195909967':
      return 'P20';

    // R Tables
    case '1755290300449904':
      return 'R1';
    case '2395910442452079':
      return 'R2';
    case '3778851257058414':
      return 'R3';
    case '5804091901142':
      return 'R4';
    case '2601205584233623':
      return 'R5';
    case '3406709520729240':
      return 'R6';

    // X Tables
    case '2838592721651126':
      return 'X 01';
    case '463205224023480':
      return 'X 02';
    case '2193935310390713':
      return 'X 03';
    case '4008129496221113':
      return 'X 04';
    case '1590174577722821':
      return 'X 05';
    case '4413299560994210':
      return 'X 06';

    // L Tables
    case '585062036873027':
      return 'L1';
    case '880968103698245':
      return 'L2';
    case '3794862895865669':
      return 'L3';
    case '2737849969483590':
      return 'L4';

    // B Tables
    case '1168761006511552':
      return 'B 01';
    case '873731113014717':
      return 'B 02';
    case '4365213107148217':
      return 'B 03';
    case '3724425461421477':
      return 'B 04';
    case '450977482069412':
      return 'B 05';
    case '4472840692618686':
      return 'B 06';
    case '4156709625646720':
      return 'B 07';
    case '2672128440306696':
      return 'B 0';
    case '444419094212077':
      return 'B 1';
    case '3647481149517362':
      return 'B 2';
    case '1516241067830836':
      return 'B 3';
    case '3693153831743029':
      return 'B 4';
    case '3988235264847414':
      return 'B 5';
    case '394653308153399':
      return 'B 6';

    // C Tables
    case '1227924181014512':
      return 'C 01';
    case '260263754258413':
      return 'C 02';
    case '2754492996966380':
      return 'C 03';
    case '3519632830814190':
      return 'C 04';
    case '1181521381551688':
      return 'C 4';
    case '1087302747755624':
      return 'C3';

    // A Tables
    case '1593666475942186':
      return 'A 00';
    case '776686280449157':
      return 'A 05';
    case '2476161889803457':
      return 'A 06';
    case '3399614218181791':
      return 'A 07';
    case '3614822144482631':
      return 'A 09';
    case '175232050384748':
      return 'A13';
    case '1453500278194157':
      return 'A14';

    // PACK Tables
    case '2698993395770264':
      return 'PACK 01';
    case '1108158984168345':
      return 'PACK 02';
    case '2146042126214041':
      return 'PACK 03';
    case '142109170148400':
      return 'PACK 04';
    case '1049674492849950':
      return 'PACK 5';
    case '2012163778981665':
      return 'PACK 6';

    // T Tables
    case '3571138070756944':
      return 't67';
    case '969706444340816':
      return 't68';
    case '2569075025512735':
      return 't60';
    case '599579175286771':
      return 't60';
    case '3499150193443417':
      return 't59';

    // GA Tables
    case '4494225361989098':
      return 'GA 5';

    // D Tables
    case '313744745680764':
      return 'D05';

    // Numbered Tables
    case '3362552936929378':
    case '889493655827755':
    case '431701791421320':
    case '895541080641565':
    case '1139988974083168':
      return '1';

    case '1733093952238893':
    case '2376226590760054':
    case '3901751898747797':
      return '2';

    case '516518695843118':
    case '1224325120996254':
    case '4191490223447166':
      return '3';

    case '438736838112559':
    case '1429620262778038':
    case '2508314014981250':
      return '4';

    case '4001081497662769':
    case '3109416225301179':
      return '5';

    case '421952105919794':
    case '186940195157212':
    case '2546006647971178':
      return '6';

    case '2126667575375155':
    case '1305521477727467':
    case '1592528369481717':
      return '7';

    case '4038413353399608':
    case '3071680749319415':
    case '3748636311812130':
      return '8';

    case '3144884062172474':
    case '687638892590354':
    case '4488126434712968':
      return '9';

    case '290101014639936':
    case '358107420123822':
      return '10';

    case '2872802288678240':
    case '2294411758738808':
      return '11';

    case '1109056788706679':
    case '4068821828761632':
      return '12';

    case '2788595159872714':
    case '3102454187161635':
      return '13';

    case '2353871377051450':
      return '14';
    case '449817794387299':
      return '15';
    case '857083773263196':
      return '16';
    case '126849138629796':
      return '17';

    default:
      return 'Table $currentTable';
  }
}
