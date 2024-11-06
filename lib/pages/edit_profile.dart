import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/services/app_service.dart';
import 'package:travel_hour/utils/snacbar.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io' show File;
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfile extends StatefulWidget {
  final String? name;
  final String? imageUrl;
  final String? phone;
  final String? department;
  final String? city;
  final String? address;
  final String? eps;
  final String? age;
  final String? gender;
  final String? occupation;
  final String? password;

  EditProfile(
      {Key? key,
      required this.name,
      required this.imageUrl,
      this.phone,
      this.department,
      this.city,
      this.address,
      this.eps,
      this.age,
      this.gender,
      this.occupation,
      this.password})
      : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState(
      this.name,
      this.imageUrl,
      this.phone,
      this.department,
      this.city,
      this.address,
      this.eps,
      this.age,
      this.gender,
      this.occupation,
      this.password);
}

class _EditProfileState extends State<EditProfile> {
  _EditProfileState(
      this.name,
      this.imageUrl,
      this.phone,
      this.department,
      this.city,
      this.address,
      this.eps,
      this.age,
      this.gender,
      this.occupation,
      this.password);

  String? name;
  String? imageUrl;
  String? phone;
  String? department;
  String? city;
  String? address;
  String? eps;
  String? age;
  String? gender;
  String? occupation;
  String? password;

  dynamic imageFile; // Puede ser File o html.File
  Uint8List? webImage;
  String? fileName;

  bool loading = false;
  bool isLoadingData = false;
  bool isFirstUpdateSuccess = false; // Valor inicial

  // FocusNode para el campo de contraseña
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  // Lista
  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> cities = [];

  List<String> occupationOptions = [
    'Empleado(a)',
    'Independiente',
    'Jubilado(a)/Pensionado',
    'Estudiante',
    'Dedicado(a) al hogar',
    'Otro',
    'Ninguno',
  ];

  // Definir una variable global con las opciones de EPS
  List<String> epsOptions = [
    'ALIANSALUD ENTIDAD PROMOTORA DE SALUD S.A.',
    'ANASWAYUU',
    'ASMET SALUD',
    'ASOCIACIÓN INDÍGENA DEL CAUCA EPS',
    'ASOCIACIÓN INDÍGENA DEL CESAR Y LA GUAJIRA DUSAKAWI',
    'ASOCIACION MUTUAL SER EMPRESA SOLIDARIA DE SALUD EPS',
    'CAPITAL SALUD',
    'CAPRESOCA EPS',
    'COMFACHOCO',
    'COMFAORIENTE',
    'COMFENALCO VALLE EPS',
    'COMPENSAR EPS',
    'COOPERATIVA DE SALUD Y DESARROLLO INTEGRAL ZONA SUR ORIENTAL DE CARTAGENA',
    'COOSALUD EPS-S',
    'EMSSANAR EPS',
    'EPS CONVIDA',
    'EPS FAMILIAR DE COLOMBIA',
    'EPS FAMISANAR LTDA.',
    'EPS S.O.S. S.A.',
    'EPS SANITAS  S.A.',
    'EPS SERVICIO OCCIDENTAL DE SALUD  S.A.',
    'EPS Y MEDICINA PREPAGADA SURAMERICANA S.A',
    'FUNDACIÓN SALUD MIA EPS',
    'MALLAMAS',
    'NUEVA EPS S.A.',
    'PIJAOS SALUD EPSI',
    'SALUD BÓLIVAR EPS SAS',
    'SALUD TOTAL S.A. EPS',
    'SALUDVIDA S.A. E.P.S',
    'SAVIA SALUD EPS',
  ];

  var formKey = GlobalKey<FormState>();
  var nameCtrl = TextEditingController();
  // Nuevos campos para el usuario
  var phoneCtrl = TextEditingController();
  var countryCtrl = TextEditingController();
  var departmentCtrl = TextEditingController();
  var cityCtrl = TextEditingController();
  var addressCtrl = TextEditingController();
  var epsCtrl = TextEditingController();
  var ageCtrl = TextEditingController();
  var genderCtrl = TextEditingController();
  var occupationCtrl = TextEditingController();
  var passwordCtrl = TextEditingController();
  var confirmPasswordCtrl = TextEditingController();

  Future pickImage() async {
    final _imagePicker = ImagePicker();

    if (kIsWeb) {
      // Flutter Web
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((event) {
            setState(() {
              webImage = reader.result as Uint8List;
              imageFile = file;
              fileName = file.name;
            });
          });
        }
      });
    } else {
      // Flutter Mobile/Desktop
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 200,
        maxWidth: 200,
      );

      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
          fileName = pickedFile.name;
        });
      } else {
        debugPrint('No image has been selected!');
      }
    }
  }

  Future uploadPicture() async {
    final SignInBloc sb = context.read<SignInBloc>();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('Profile Pictures/${sb.uid}');

    if (kIsWeb) {
      if (webImage != null) {
        UploadTask uploadTask = storageReference.putData(webImage!);
        await uploadTask.whenComplete(() async {
          var _url = await storageReference.getDownloadURL();
          setState(() {
            imageUrl = _url;
          });
        });
      }
    } else {
      if (imageFile != null) {
        UploadTask uploadTask = storageReference.putFile(imageFile as File);
        await uploadTask.whenComplete(() async {
          var _url = await storageReference.getDownloadURL();
          setState(() {
            imageUrl = _url;
          });
        });
      }
    }
  }

  ImageProvider _getImageProvider() {
    if (kIsWeb) {
      if (webImage != null) {
        return MemoryImage(webImage!);
      } else if (imageUrl != null) {
        return CachedNetworkImageProvider(imageUrl!);
      }
    } else {
      if (imageFile != null) {
        return FileImage(imageFile as File);
      } else if (imageUrl != null) {
        return CachedNetworkImageProvider(imageUrl!);
      }
    }
    return AssetImage('assets/default_profile_image.png'); // Imagen por defecto
  }

  Future handleUpdateData() async {
    final sb = context.read<SignInBloc>();
    if (kIsWeb) {
      updateData(sb);
    } else {
      bool? hasInternet = await AppService().checkInternet();
      if (!hasInternet!) {
        openSnacbar(context, easy.tr('no internet'));
      } else {
        updateData(sb);
      }
    }
  }

  Future updateData(SignInBloc sb) async {
    // Llamar al endpoint para validar la primera actualización
    await validateFirstUpdate(sb.email!);

    // Ajustar la validación de la contraseña basada en el resultado de la validación
    if (isFirstUpdateSuccess) {
      // Validar campos incluyendo contraseña
      if (passwordCtrl.text.isEmpty || confirmPasswordCtrl.text.isEmpty) {
        openSnacbar(context, easy.tr('Password is required for first update'));
        return;
      }
    }

    bool isValid = formKey.currentState!.validate();
    if (!isValid) return;

    // Continuar con la lógica de actualización de perfil
    setState(() => loading = true);
    if (imageFile == null) {
      await sb.updateUserProfile(
          nameCtrl.text,
          imageUrl!,
          phoneCtrl.text,
          departmentCtrl.text,
          cityCtrl.text,
          addressCtrl.text,
          epsCtrl.text,
          ageCtrl.text,
          genderCtrl.text,
          occupationCtrl.text,
          passwordCtrl.text);
    } else {
      await uploadPicture();
      await sb.updateUserProfile(
          nameCtrl.text,
          imageUrl!,
          phoneCtrl.text,
          departmentCtrl.text,
          cityCtrl.text,
          addressCtrl.text,
          epsCtrl.text,
          ageCtrl.text,
          genderCtrl.text,
          occupationCtrl.text,
          passwordCtrl.text);
    }

    //#### Construccion de metodo para actualizacion de datos
    //Url del formulario
    final String url = Config().gmdvitaUpdateUrl;
    //Token
    final String token = "Bearer " + Config().token;
    //Cuerpo del formulario
    final dynamic form = {
      "email": sb.email!,
      "name": nameCtrl.text,
      "phone": phoneCtrl.text,
      "country": countryCtrl.text,
      "state": departmentCtrl.text,
      "city": cityCtrl.text,
      "address": addressCtrl.text,
      "eps": epsCtrl.text,
      "age": ageCtrl.text,
      "gender": genderCtrl.text,
      "occupation": occupationCtrl.text
    };

    // Agregar la contraseña si es obligatoria y está disponible
    if (isFirstUpdateSuccess && passwordCtrl.text.isNotEmpty) {
      form["password"] = passwordCtrl.text;
    } else if (!isFirstUpdateSuccess && passwordCtrl.text.isNotEmpty) {
      form["password"] = passwordCtrl.text;
    }

    // Realizar la solicitud POST para actualizar los datos del usuario
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: json.encode(form),
    );

    // Manejar la respuesta de la solicitud
    if (response.statusCode == 200) {
      //final data = json.decode(response.body);
      //print('Datos de la respuesta: $data');
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
    //#### Construccion de metodo para actualizacion de datos

    openSnacbar(context, easy.tr('updated successfully'));
    setState(() => loading = false);
  }

  Future<void> validateFirstUpdate(String email) async {
    final url = Uri.parse(Config().gmdvitaVerifyUrl);
    final body = {"email": email};

    setState(() => isLoadingData = true);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + Config().token
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          isFirstUpdateSuccess = data['status'] == 'success';
        });
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
    } finally {
      setState(() => isLoadingData = false);
    }
  }

  Future<void> fetchUserData(String email) async {
    final url = Config().gmdvitaGetUserUrl + '?email=$email';
    final headers = {
      'Authorization': 'Bearer ' + Config().token,
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final userData = data['data'];

          // Actualiza los controladores con los datos obtenidos
          setState(() {
            nameCtrl.text = userData['name'] ?? nameCtrl.text;
            phoneCtrl.text = userData['phone'] ?? '';
            countryCtrl.text = userData['country'] ?? '';
            departmentCtrl.text = userData['state'] ?? '';
            cityCtrl.text = userData['city'] ?? '';
            addressCtrl.text = userData['address'] ?? '';
            epsCtrl.text = userData['eps'] ?? '';
            ageCtrl.text = userData['age']?.toString() ?? '';
            occupationCtrl.text = userData['occupation'] ?? '';
            // genderCtrl.text = userData['gender'] == 'H'
            //     ? 'Masculino'
            //     : userData['gender'] == 'M'
            //         ? 'Femenino'
            //         : 'Otro';
            genderCtrl.text = userData['gender'];
          });

          // Cargar los estados según el país seleccionado
          final selectedCountry = countries.firstWhere(
            (country) => country['name'] == userData['country'],
            orElse: () => {'id': 48},
          );

          if (selectedCountry['id'] != null) {
            await loadStates(selectedCountry['id']);

            // Filtrar y cargar las ciudades según el estado seleccionado
            final selectedState = states.firstWhere(
              (state) => state['name'] == userData['state'],
              orElse: () => {'id': null},
            );

            if (selectedState['id'] != null) {
              await loadCities(selectedState['id']);

              // Verificar si la ciudad está en la lista de ciudades
              setState(() {
                if (cities.any((city) => city['name'] == userData['city'])) {
                  cityCtrl.text = userData['city'] ?? '';
                }
              });
            }
          }
        } else {
          print('Error: ${data['status']}');
        }
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error en la solicitud: $e');
    }
  }

  Future<void> loadCountries() async {
    // try {
    //   final String response =
    //       await rootBundle.loadString('assets/data/countries.json');
    //   final List<dynamic> data = json.decode(response);
    //   setState(() {
    //     countries =
    //         data.map((e) => {'id': e['id'], 'name': e['name']}).toList();
    //   });
    //   print("Países cargados: ${countries.length}");
    // } catch (e) {
    //   print("Error al cargar los países: $e");
    // }
    final String countriesUrl = Config().countriesUrl;

    try {
      final response = await http.get(Uri.parse(countriesUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            countries = data['data'].map<Map<String, dynamic>>((country) {
              return {'id': country['id'], 'name': country['name']};
            }).toList();
          });

          //print("Países cargados desde API: ${countries.length}");
        } else {
          print("Error en la respuesta de la API: ${data['status']}");
        }
      } else {
        print(
            "Error al obtener países: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error al cargar los países desde la API: $e");
    }
  }

  Future<void> loadStates(int countryId) async {
    // try {
    //   final String response =
    //       await rootBundle.loadString('assets/data/states.json');
    //   final List<dynamic> data = json.decode(response);

    //   setState(() {
    //     states = data
    //         .where((state) =>
    //             state['country_id'] ==
    //             countryId) // Asegurar comparación numérica
    //         .map((e) => {'id': e['idState'], 'name': e['name']})
    //         .toList();
    //   });
    //   print("Estados cargados: ${states.length}");
    // } catch (e) {
    //   print("Error al cargar los estados: $e");
    // }
    // Construir la URL usando la constante y reemplazar ':countryId'
    final String departmentsUrl =
        Config().departmentsUrl.replaceAll(':countryId', countryId.toString());

    try {
      final response = await http.get(Uri.parse(departmentsUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            states = data['data'].map<Map<String, dynamic>>((department) {
              return {'id': department['id'], 'name': department['name']};
            }).toList();
          });

          //print("Departamentos cargados desde API: ${states.length}");
        } else {
          print("Error en la respuesta de la API: ${data['status']}");
        }
      } else {
        print(
            "Error al obtener departamentos: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error al cargar los departamentos desde la API: $e");
    }
  }

  Future<void> loadCities(int stateId) async {
    // try {
    //   final String response =
    //       await rootBundle.loadString('assets/data/cities.json');
    //   final List<dynamic> data = json.decode(response);

    //   setState(() {
    //     cities = data
    //         .where((city) => city['state_id'] == stateId.toString())
    //         .map((e) => {'id': e['idCity'], 'name': e['name']})
    //         .toList();
    //   });
    //   print("Ciudades cargadas: ${cities.length}");
    // } catch (e) {
    //   print("Error al cargar las ciudades: $e");
    // }
    // Construir la URL usando la constante y reemplazar ':departmentId'
    final String citiesUrl =
        Config().citiesUrl.replaceAll(':departmentId', stateId.toString());

    try {
      final response = await http.get(Uri.parse(citiesUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            cities = data['data'].map<Map<String, dynamic>>((city) {
              return {'id': city['id'], 'name': city['name']};
            }).toList();
          });

          //print("Ciudades cargadas desde API: ${cities.length}");
        } else {
          print("Error en la respuesta de la API: ${data['status']}");
        }
      } else {
        print(
            "Error al obtener ciudades: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error al cargar las ciudades desde la API: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    // Escuchar el cambio de foco en el campo de contraseña
    passwordFocusNode.addListener(() {
      setState(() {});
    });

    // Escuchar el cambio de foco en el campo de confirmación de contraseña
    confirmPasswordFocusNode.addListener(() {
      setState(() {});
    });

    phoneCtrl.text = '';
    countryCtrl.text =
        'Colombia'; // Reemplaza con el nombre del país que desees
    departmentCtrl.text = '';
    cityCtrl.text = '';
    addressCtrl.text = '';
    epsCtrl.text = '';
    ageCtrl.text = '';
    genderCtrl.text = '';
    occupationCtrl.text = '';
    passwordCtrl.text = '';
    confirmPasswordCtrl.text = '';

    // Cargar los países desde el JSON
    loadCountries();

    // Verificar si es la primera vez que se actualiza
    final SignInBloc sb = context.read<SignInBloc>();
    nameCtrl.text = sb.name!;
    if (sb.email != null) {
      validateFirstUpdate(sb.email!).then((_) {
        if (!isFirstUpdateSuccess) {
          // Si no es la primera vez, llamamos a fetchUserData
          fetchUserData(sb.email!);
        } else {
          // Cargar los departamentos del pais por defecto
          loadStates(48);
        }
      });
    }
  }

  @override
  void dispose() {
    // Liberar los FocusNodes
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Scaffold(
      appBar: AppBar(
        title: Text(easy.tr('edit profile'), style: _textStyleMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: <Widget>[
          // Avatar y nombre
          InkWell(
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey[300],
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey[800]!),
                  color: Colors.grey[500],
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: _getImageProvider(), fit: BoxFit.cover),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.edit,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            onTap: () {
              pickImage();
            },
          ),
          SizedBox(height: 50),
          isLoadingData
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 150.0), // Margen superior
                    child: SizedBox(
                      width: 50, // Tamaño más grande
                      height: 50,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                )
              // Campo para el nombre
              : Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: easy.tr('enter new name'),
                        ),
                        controller: nameCtrl,
                        validator: (value) {
                          if (value!.isEmpty)
                            return easy.tr("Name can't be empty");
                          return null;
                        },
                      ),

                      SizedBox(height: 20),
                      // Campo para el teléfono
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: easy.tr('enter phone number')),
                        controller: phoneCtrl,
                        validator: (value) {
                          if (value!.isEmpty)
                            return easy.tr("Phone number can't be empty");
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Implementación del DropdownButtonFormField para el país
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: easy.tr('select_country'),
                        ),
                        value: countries.isNotEmpty &&
                                countries.any((country) =>
                                    country['name'] == countryCtrl.text)
                            ? countryCtrl.text
                            : null,
                        items: countries.map((country) {
                          return DropdownMenuItem<String>(
                            value: country['name'],
                            child: Text(country['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            countryCtrl.text = value ?? '';

                            // Buscar el ID del país seleccionado
                            final selectedCountry = countries.firstWhere(
                              (country) => country['name'] == value,
                              orElse: () => {'id': null},
                            );

                            if (selectedCountry['id'] != null) {
                              // Cargar los estados del país seleccionado
                              loadStates(selectedCountry[
                                  'id']); // Pasar el ID como un entero
                              departmentCtrl.text =
                                  ''; // Resetear el campo de departamento
                              cityCtrl.text = ''; // Resetear el campo de ciudad
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return easy.tr("Country can't be empty");
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Implementación del DropdownButtonFormField para el departamento
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: easy.tr('select_department'),
                        ),
                        // Permite que el dropdown se ajuste al ancho del padre
                        isExpanded: true,
                        // Personaliza el estilo del elemento seleccionado para manejar textos largos
                        selectedItemBuilder: (BuildContext context) {
                          return states.map<Widget>((state) {
                            return Container(
                              width: double.infinity,
                              child: Text(
                                state['name'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList();
                        },
                        value: departmentCtrl.text.isNotEmpty
                            ? departmentCtrl.text
                            : null,
                        items: states.map((state) {
                          return DropdownMenuItem<String>(
                            value: state['name'],
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8),
                              child: Text(
                                state['name'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            departmentCtrl.text = value ?? '';
                            cityCtrl.text = ''; // Resetear el campo de ciudad

                            // Buscar el ID del estado seleccionado
                            final selectedState = states.firstWhere(
                              (state) => state['name'] == value,
                              orElse: () => {'id': null},
                            );

                            if (selectedState['id'] != null) {
                              // Cargar las ciudades del estado seleccionado
                              loadCities(selectedState['id']);
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return easy.tr("department can't be empty");
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Implementación del DropdownButtonFormField para la ciudad
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: easy.tr('select_city'),
                        ),
                        value: cities.isNotEmpty &&
                                cities.any(
                                    (city) => city['name'] == cityCtrl.text)
                            ? cityCtrl.text
                            : null,
                        items: cities.map((city) {
                          return DropdownMenuItem<String>(
                            value: city['name'],
                            child: Text(city['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            cityCtrl.text = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return easy.tr("city can't be empty");
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Campo para la dirección
                      TextFormField(
                        decoration:
                            InputDecoration(hintText: easy.tr('enter address')),
                        controller: addressCtrl,
                        validator: (value) {
                          if (value!.isEmpty)
                            return easy.tr("address can't be empty");
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Implementación del DropdownButtonFormField para EPS
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: easy.tr('enter eps'),
                        ),
                        isExpanded: true,
                        selectedItemBuilder: (BuildContext context) {
                          return epsOptions.map<Widget>((eps) {
                            return Container(
                              width: double.infinity,
                              child: Text(
                                eps,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList();
                        },
                        value: epsCtrl.text.isNotEmpty &&
                                epsOptions.contains(epsCtrl.text)
                            ? epsCtrl.text
                            : null,
                        items: epsOptions.map((eps) {
                          return DropdownMenuItem<String>(
                            value: eps,
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8),
                              child: Text(
                                eps,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ), // Traducción visual
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            epsCtrl.text = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return easy.tr("eps can't be empty");
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Campo para la edad
                      TextFormField(
                        decoration:
                            InputDecoration(hintText: easy.tr('enter age')),
                        controller: ageCtrl,
                        validator: (value) {
                          if (value!.isEmpty)
                            return easy.tr("age can't be empty");
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Campo para el Género
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: easy.tr('select gender'),
                        ),
                        value: genderCtrl.text.isNotEmpty &&
                                ['Masculino', 'Femenino', 'Otro']
                                    .contains(genderCtrl.text)
                            ? genderCtrl.text
                            : null,
                        items: [
                          DropdownMenuItem(
                            value: 'Masculino',
                            child: Text(easy.tr('male')),
                          ),
                          DropdownMenuItem(
                            value: 'Femenino',
                            child: Text(easy.tr('female')),
                          ),
                          DropdownMenuItem(
                            value: 'Otro',
                            child: Text(easy.tr('another')),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            genderCtrl.text = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return easy.tr("gender can't be empty");
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Implementación del DropdownButtonFormField para la ocupación
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: easy.tr('enter occupation'),
                        ),
                        value: occupationCtrl.text.isNotEmpty &&
                                occupationOptions.contains(occupationCtrl.text)
                            ? occupationCtrl.text
                            : null,
                        items: occupationOptions.map((occupation) {
                          return DropdownMenuItem<String>(
                            value: occupation,
                            child: Text(easy
                                .tr(occupation)), // Aplicar traducción aquí,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            occupationCtrl.text = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return easy.tr("occupation can't be empty");
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Campo para la contraseña y para confirmar la contraseña
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.9),
                              width: 1.5), // Borde azul claro
                          borderRadius:
                              BorderRadius.circular(10), // Bordes redondeados
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título de la sección con ícono
                            Row(
                              children: [
                                Icon(Icons.security,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(
                                            0.9)), // Ícono de seguridad
                                SizedBox(width: 8),
                                Text(
                                  easy.tr('password_for_vital_signs_use'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.9),
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),

                            // Campo para la contraseña
                            TextFormField(
                              focusNode: passwordFocusNode,
                              decoration: InputDecoration(
                                labelText: easy.tr('password'),
                                labelStyle: TextStyle(
                                  color: passwordFocusNode.hasFocus
                                      ? Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.9)
                                      : Colors.grey,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: passwordFocusNode.hasFocus
                                        ? Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.9)
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.9),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              controller: passwordCtrl,
                              obscureText: !isPasswordVisible,
                              validator: (value) {
                                if (isFirstUpdateSuccess && value!.isEmpty) {
                                  return easy.tr("Password can't be empty");
                                }
                                if (value!.isNotEmpty && value.length < 6) {
                                  return easy.tr(
                                      "Password must be at least 6 characters");
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),

                            // Campo para confirmar la contraseña
                            TextFormField(
                              focusNode: confirmPasswordFocusNode,
                              decoration: InputDecoration(
                                  labelText: easy.tr(
                                      'confirm_password'), // Etiqueta en vez de hint
                                  labelStyle: TextStyle(
                                      color: confirmPasswordFocusNode.hasFocus
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.9)
                                          : Colors.grey),
                                  suffixIcon: Icon(
                                    Icons.lock_outline,
                                    color: confirmPasswordFocusNode.hasFocus
                                        ? Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.9)
                                        : Colors.grey,
                                  ), // Ícono de candado
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.9),
                                          width: 2.0))),
                              controller: confirmPasswordCtrl,
                              obscureText: true,
                              validator: (value) {
                                if (isFirstUpdateSuccess && value!.isEmpty) {
                                  return easy
                                      .tr("Please confirm your password");
                                }
                                if (value!.isNotEmpty &&
                                    value != passwordCtrl.text) {
                                  return easy.tr("Passwords do not match");
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),

                            // Mensaje de advertencia
                            // Row(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Icon(Icons.format_quote,
                            //         color: Theme.of(context)
                            //             .primaryColor
                            //             .withOpacity(0.9),
                            //         size: 30),
                            //     SizedBox(width: 8),
                            //     Expanded(
                            //       child: Text(
                            //         easy.tr(
                            //             'Recuerde guardar los datos de correo electrónico y contraseña, ya que le permitirán acceder a la plataforma para supervisar y gestionar el grupo que está creando.'),
                            //         style: Theme.of(context)
                            //             .textTheme
                            //             .bodyMedium
                            //             ?.copyWith(
                            //               color: Theme.of(context)
                            //                   .primaryColor
                            //                   .withOpacity(0.9),
                            //               fontWeight: FontWeight.bold,
                            //             ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

          SizedBox(height: 30),
          if (!isLoadingData)
            Container(
              height: 45,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(Theme.of(context).primaryColor),
                ),
                child: loading
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      )
                    : Text(
                        easy.tr('update profile'),
                        style: _textStyleMedium.copyWith(
                            fontWeight: fontSizeController
                                .obtainContrastFromBase(FontWeight.w600)),
                      ),
                onPressed: () {
                  handleUpdateData();
                },
              ),
            ),
        ],
      ),
    );
  }
}
