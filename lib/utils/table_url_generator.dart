import 'dart:convert';
import 'dart:ui' as html show window;
import 'dart:js' as js;

import 'package:big_szef_menu/models/table_model.dart';
import 'package:big_szef_menu/services/get_tables_service.dart';

/// A simple utility class to generate multiple URL formats for table IDs.
/// This can be used in any existing Flutter web app without modifying the main structure.
class TableUrlGenerator {
  List hardCodedTables = [
    3362552936929378,
    1451026216726343,
    3579251232881414,
    2156281321516918,
    3456522540838804,
    4275465430052629,
    573676067303223,
    1418861206646593,
    1256000341749582,
    2319666172473166,
    3954841826543608,
    816234345449612,
    1950174431070367,
    807966533404843,
    579603122276549,
    1702492257044686,
    889493655827755,
    1733093952238893,
    516518695843118,
    438736838112559,
    4001081497662769,
    421952105919794,
    2126667575375155,
    4038413353399608,
    3144884062172474,
    1621579362016389,
    3059006131740037,
    3835995791925704,
    912926949614029,
    739689443729872,
    2227294316372436,
    2100227708934039,
    2123682525337498,
    3778851257058414,
    2395910442452079,
    1755290300449904,
    2601205584233623,
    3406709520729240,
    5804091901142,
    3874998394946906,
    2571454345774427,
    2539405299811675,
    568522117088604,
    1485063843087708,
    2838592721651126,
    463205224023480,
    2193935310390713,
    4008129496221113,
    1590174577722821,
    585062036873027,
    880968103698245,
    3794862895865669,
    2737849969483590,
    1413904837835616,
    25625378880379,
    1043893405285254,
    995824131308472,
    3885692876422241,
    1812525047544932,
    3245948907748454,
    4259449520454761,
    4334989405257486,
    1548290069561107,
    2322715622702892,
    839955473170224,
    567216459939656,
    188743941816140,
    3189719195909967,
    1892372789207158,
    1145387782119547,
    3571138070756944,
    969706444340816,
    4413299560994210,
    450977482069412,
    3724425461421477,
    1960727206090150,
    4365213107148217,
    3065650492659130,
    873731113014717,
    4472840692618686,
    1168761006511552,
    2754492996966380,
    260263754258413,
    3519632830814190,
    1227924181014512,
    4156709625646720,
    97789447903150,
    1991882914731699,
    2470544134969032,
    4494225361989098,
    3791796345630239,
    2365953102704160,
    3314286176696161,
    2672128440306696,
    1181521381551688,
    1593666475942186,
    313744745680764,
    175232050384748,
    2569075025512735,
    4135531168263748,
    2034042325036613,
    3785598645674426,
    2643489532256690,
    776686280449157,
    2476161889803457,
    3399614218181791,
    3614822144482631,
    431701791421320,
    3901751898747797,
    1224325120996254,
    1429620262778038,
    2788595159872714,
    186940195157212,
    1305521477727467,
    3071680749319415,
    687638892590354,
    290101014639936,
    2872802288678240,
    1109056788706679,
    3932718612953152,
    1453500278194157,
    895541080641565,
    1570048378544155,
    76220098289736,
    1551103277801570,
    2924311696515187,
    1090072883773113,
    2966990772614700,
    3243543770363622,
    1350867647133446,
    1556386127502924,
    4395200542520864,
    1580687040799673,
    1802543576972375,
    2012163778981665,
    1049674492849950,
    142109170148400,
    962263261519982,
    2290675211263189,
    688248620425662,
    2067126395969987,
    3686071391101004,
    599579175286771,
    3151257746828540,
    2146042126214041,
    1205070668062021,
    4488126434712968,
    595206766469152,
    358107420123822,
    3102454187161635,
    4191490223447166,
    2546006647971178,
    3988235264847414,
    2294411758738808,
    3647481149517362,
    394653308153399,
    2573352778460728,
    438234341661907,
    3693153831743029,
    1175882093464608,
    444419094212077,
    1087302747755624,
    857083773263196,
    687445555046813,
    1516241067830836,
    1108158984168345,
    2645637078408290,
    3499150193443417,
    3109416225301179,
    4068821828761632,
    1139988974083168,
    1592528369481717,
    126849138629796,
    684391762370580,
    3748636311812130,
    449817794387299,
    2698993395770264,
    2353871377051450,
    2508314014981250,
    2376226590760054
  ];
  TableService _tableService = TableService();
  Future<List<TableModel>> _allTablesIds = Future.value([]);

  /// Base URL of your application
  final String baseUrl;

  /// Constructor with optional base URL parameter
  /// If not provided, relative URLs will be generated
  TableUrlGenerator({this.baseUrl = 'https://big-szef-menu.web.app'}) {
    _allTablesIds = _tableService.getAllTables().then((tables) {
      print(
          'Tables: ${tables.map((table) => '${table.id}: ${table.name}').join(', ')}');
      return tables.map((table) => TableModel(id: table.id)).toList();
    });
  }

  /// Generates different URL formats for a single table ID
  /// Returns a map with URL type as key and the URL as value
  Map<String, String> generateUrls(String tableId) {
    return {
      'standard': '$baseUrl/tables/$tableId',
      'alternate': '$baseUrl/t/$tableId',
      'query': '$baseUrl/view?tableId=$tableId',
      'encoded': '$baseUrl/view/${_encodeTableId(tableId)}',
    };
  }

  /// Simple method to encode a table ID
  /// Uses base64 encoding for simple obfuscation
  String _encodeTableId(String tableId) {
    return base64Url.encode(utf8.encode(tableId));
  }

  /// Opens a URL in the web context
  /// You can use this with Flutter web's js interop or url_launcher package
  void openUrl(String url) {
    // Implementation depends on your preferred method:
    // Option 1: Using dart:js (add js: ^0.6.7 to pubspec.yaml)
    // import 'dart:js' as js;
    // js.context.callMethod('open', [url, '_blank']);

    // Option 2: Using url_launcher (add url_launcher: ^6.2.1 to pubspec.yaml)
    // import 'package:url_launcher/url_launcher.dart';
    // launchUrl(Uri.parse(url));

    // Add implementation based on your preference
  }

  /// Extract table ID from the current URL
  String? getTableIdFromUrl() {
    // Access the current URL using dart:js
    final currentUrl = js.context['location']['href'].toString();

    // Regular expression to extract the ID from the /tables/ pattern
    RegExp regex = RegExp(r'/tables/([^/\?#]+)');
    Match? match = regex.firstMatch(currentUrl);

    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    return null;
  }
}

/// Usage example - can be called from anywhere in your app
void generateTableUrls() {
  // Create generator with your base URL
  final generator = TableUrlGenerator(baseUrl: 'https://big-szef-menu.web.app');

  // Generate URLs for a specific table
  final tableId = '3362552936929378';
  final urls = generator.generateUrls(tableId);

  // Print or use the generated URLs
  urls.forEach((type, url) {
    print('$type URL: $url');
  });

  // Example output:
  // standard URL: https://yourapp.com/tables/3362552936929378
  // alternate URL: https://yourapp.com/t/3362552936929378
  // query URL: https://yourapp.com/view?tableId=3362552936929378
  // encoded URL: https://yourapp.com/view/MzM2MjU1MjkzNjkyOTM3OA==
}

/// Example method to generate URLs for a batch of tables
/// You can call this once to set up all your URLs
// void generateAllTableUrls(List<String> tableIds) {
//   final generator = TableUrlGenerator(baseUrl: 'https://big-szef-menu.web.app');

//   for (final id in tableIds) {
//     final urls = generator.generateUrls(id);
//     print('\n--- URLs for Table ID: $id ---');
//     urls.forEach((type, url) => print('$type: $url'));
//   }
// }
