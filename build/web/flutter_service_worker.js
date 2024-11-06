'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "88432eecc340985a6425b83388e08152",
"assets/AssetManifest.bin.json": "be55f80240e2f5ae8eae8890999fed05",
"assets/AssetManifest.json": "b3b2fe37569bbf9b0ebb531ffb0dacbe",
"assets/assets/data/cities.json": "fe60d95703cdf942250f5e7853d1adc7",
"assets/assets/data/countries.json": "b13bfb369bb6e618be7ccc93abecbc6d",
"assets/assets/data/states.json": "f1f5dbb79a04fad7e35fc64b9d72d90d",
"assets/assets/flr/success.flr": "2a2997174843eba878b6a1be7d33b0bc",
"assets/assets/fonts/Manrope-Bold.ttf": "656753569aef606dd528cc6bdf672cdc",
"assets/assets/fonts/Manrope-ExtraBold.ttf": "47e356f61dca7aa2dfba5593e000c4f1",
"assets/assets/fonts/Manrope-Medium.ttf": "6196e0dab83345b15290ee22620358c1",
"assets/assets/fonts/Manrope-Regular.ttf": "0b726174d2b7e161b9e5e8125bf7751a",
"assets/assets/fonts/Manrope-SemiBold.ttf": "255d425d09667bc095e79a8bd8081aba",
"assets/assets/fonts/Muli-Bold.ttf": "077ceb9111e90dea3fc3923fe71805a1",
"assets/assets/fonts/Muli-Medium.ttf": "683362f36187ad8be18692df9c1cf81e",
"assets/assets/fonts/Muli-Regular.ttf": "328d557958b18b54b3bddb3a4a36215a",
"assets/assets/fonts/Muli-SemiBold.ttf": "2f64b5b99b8dc9d36387f334a6921da7",
"assets/assets/fonts/NotoColorEmoji-Regular.ttf": "aca215e01cbbe3a587de8555269b9233",
"assets/assets/fonts/OpenSans-Light.ttf": "2d0bdc8df10dee036ca3bedf6f3647c6",
"assets/assets/fonts/OpenSans-Regular.ttf": "3ed9575dcc488c3e3a5bd66620bdf5a4",
"assets/assets/geojson/quindio.json": "2c4a6ca5f1fcf11114bbf5d915d2379a",
"assets/assets/images/copa.png": "1ee133ba1e0a922b7a6e1c37a1dd6214",
"assets/assets/images/destination/destination_0.jpg": "63e26f69be5dec6926e8e301d74fa66b",
"assets/assets/images/destination/destination_1.jpg": "45e56a1b449410dd92da673adb9712b4",
"assets/assets/images/destination/destination_10.jpg": "e63b28420f65872435067cecc324a36d",
"assets/assets/images/destination/destination_11.jpg": "74781dafd86fc0221a9be3a9608ee987",
"assets/assets/images/destination/destination_2.jpg": "ce1fc66edbdb5bcc59c687ffe9becef7",
"assets/assets/images/destination/destination_3.jpg": "0930a60199c87ca05d41d59987f0e34c",
"assets/assets/images/destination/destination_4.jpg": "7590573b288870ad5aed9cd0ac410fcf",
"assets/assets/images/destination/destination_5.jpg": "e82363867318791e526e2336d701e48e",
"assets/assets/images/destination/destination_6.jpg": "9a6e1192b87ce3a3ef17f03d51c90dad",
"assets/assets/images/destination/destination_7.jpg": "c3779144a029c2f83eea36140803d263",
"assets/assets/images/destination/destination_8.jpg": "ab8f3609bc5a55285a6f8b32982ca84c",
"assets/assets/images/destination/destination_9.jpg": "8169abd1a9cb1511eebe39a91d4ff55c",
"assets/assets/images/destination_0.jpg": "320f0da0b44789c05091fb44af2b38ec",
"assets/assets/images/destination_4.jpg": "7590573b288870ad5aed9cd0ac410fcf",
"assets/assets/images/empty.png": "58b03898e49a32830a20195ef1db6eb4",
"assets/assets/images/fondo_1.jpg": "3f1fcd15c55284db2ae164ec3c94fd0e",
"assets/assets/images/ia_bg.png": "78b52265bf0a8bb820a37b8b658c3c76",
"assets/assets/images/ia_icons/icon_1.png": "b0547cda4b055cc498d34ca8422176b7",
"assets/assets/images/ia_icons/icon_10.png": "9f053f1e721a1eb6182e9565b092135b",
"assets/assets/images/ia_icons/icon_2.png": "230897c1ed4ec600e74f0a2adcdff017",
"assets/assets/images/ia_icons/icon_3.png": "6a29ba8c1ce6862a005ad0f8c2c3a675",
"assets/assets/images/ia_icons/icon_4.png": "610cad78849de6ba83f5845727e58825",
"assets/assets/images/ia_icons/icon_5.png": "6a2dbf8592fb3e8d8d38815d37e40780",
"assets/assets/images/ia_icons/icon_6.png": "8e2b1b91aef5665f2ae990a316f98e0d",
"assets/assets/images/ia_icons/icon_7.png": "693527d754e549e45683312785a3edd7",
"assets/assets/images/ia_icons/icon_8.png": "5eabcf073d5c5dc94b3a2e426e17ee09",
"assets/assets/images/ia_icons/icon_9.png": "aa3cb743f78338cfff9a8da58761a159",
"assets/assets/images/icon.png": "03f7a8e659d19f6eff0af50b3df0c925",
"assets/assets/images/icon_ia.gif": "12fd7c81bff8a40fc793d70dac4e3f5b",
"assets/assets/images/icon_ia_v2.gif": "4170df8a0b263dab7586b0b81c2367f6",
"assets/assets/images/imgpsh_fullsize_anim.jfif": "7886534c33ca6b0cb22a80ea563488e4",
"assets/assets/images/imgpsh_fullsize_anim.png": "d6af266bd74cb684ac3232f5e777f3c4",
"assets/assets/images/instructions_en.png": "5de25b4a565a1da398add15f05720ac5",
"assets/assets/images/instructions_es.png": "94f6b2ef6fff681491a3fc2a5ac91247",
"assets/assets/images/instructions_fr.png": "1f6ea25c1e666ea3926b385f38623560",
"assets/assets/images/intro_mobile.gif": "44ca71049cc4674286a976ec94bf0125",
"assets/assets/images/intro_web.gif": "e42243788f25761992e44493400b5d98",
"assets/assets/images/location.png": "72824b99c531f07463037839364a2452",
"assets/assets/images/logo.png": "057ed7693f7af90d4865454c5342527a",
"assets/assets/images/logo_home.png": "87d9777164373ef49e45507e56bbf104",
"assets/assets/images/markers/airport_pin.png": "c9a8cf8f161acdb5088ee71fef906d72",
"assets/assets/images/markers/atm_pin.png": "be911a00e6e077ffdde4e7c612e1ed9d",
"assets/assets/images/markers/attractions_pin.png": "4c8458f30db33d696b7379a7f4e9a096",
"assets/assets/images/markers/destination_map_marker.png": "0be68c7cb29de6ec9f51a3add2431ad7",
"assets/assets/images/markers/destination_map_marker_2.png": "d532753f0301b9df5a0e256930f7a0cf",
"assets/assets/images/markers/destination_map_marker_3.png": "8fdf7cde34e6e21605c2571902381c3a",
"assets/assets/images/markers/driving_pin.png": "d92856cc151e7082915d6fe3ff869b9c",
"assets/assets/images/markers/event_pin.png": "f9ca3b76e6cc726e5d71337090a69654",
"assets/assets/images/markers/exchange_houses_pin.png": "8e4c7d53ca3ead83282db13cb4fae7d6",
"assets/assets/images/markers/gas_station_pin.png": "5743bdfb6d289067adf26510ce262214",
"assets/assets/images/markers/hospital_pin.png": "597d235042e724ba269871b8102718bc",
"assets/assets/images/markers/hotel_pin.png": "9d0a2bfbc7a4945b0f77b13a8ff8b281",
"assets/assets/images/markers/museum_pin.png": "2dba5ea1189f9814806d82004ecaebe2",
"assets/assets/images/markers/parking_pin.png": "c187e2e9637efe6ae61c6d6131824ee3",
"assets/assets/images/markers/restaurant_pin.png": "f67a7631aec1e0392ba9462c2ffc774e",
"assets/assets/images/markers/shopping_mall_pin.png": "65dbb4fb23cb968d398eab5614020118",
"assets/assets/images/markers/tourist_pin.png": "07d64f138f4e3f41a0ab0e4063b44630",
"assets/assets/images/qr_search.png": "6b49d60383ef0a403c477fbf26055d27",
"assets/assets/images/restaurant.png": "a844a2fe62e738f67a5fb32d09b1cd4f",
"assets/assets/images/rppg_video_mask.png": "fc453945a8223167d7cd939f7b8b9a4d",
"assets/assets/images/search.png": "445f2174d9b978e9cb0e91bf192bb937",
"assets/assets/images/splash.png": "03f7a8e659d19f6eff0af50b3df0c925",
"assets/assets/images/travel1.png": "d0c7f0091bc87e6907677c25480653f0",
"assets/assets/images/travel2.png": "6637668a180c4d29a42df9cedb9d7972",
"assets/assets/images/travel6.png": "e47337cdc45cefa7160a91b6364bfbfd",
"assets/assets/translations/ar.json": "22a4b00aa679daafa9e0d87243d5c0dd",
"assets/assets/translations/en.json": "b4b25372ab9d37da35915b4ecd44c025",
"assets/assets/translations/es.json": "603264d7836b7b9bc6776ae49a57b5ff",
"assets/assets/translations/fr.json": "cc78568984a66206383e8ab387bfd7fb",
"assets/FontManifest.json": "26930ce9b71cd0df21f8defd55214e7a",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "8b1d10c7ab1ca7379d711d49669c3607",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "b93248a553f9e8bc17f1065929d5934b",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/flutter_icons/fonts/AntDesign.ttf": "3a2ba31570920eeb9b1d217cabe58315",
"assets/packages/flutter_icons/fonts/Entypo.ttf": "744ce60078c17d86006dd0edabcd59a7",
"assets/packages/flutter_icons/fonts/EvilIcons.ttf": "140c53a7643ea949007aa9a282153849",
"assets/packages/flutter_icons/fonts/Feather.ttf": "6beba7e6834963f7f171d3bdd075c915",
"assets/packages/flutter_icons/fonts/FontAwesome.ttf": "b06871f281fee6b241d60582ae9369b9",
"assets/packages/flutter_icons/fonts/FontAwesome5_Brands.ttf": "c39278f7abfc798a241551194f55e29f",
"assets/packages/flutter_icons/fonts/FontAwesome5_Regular.ttf": "f6c6f6c8cb7784254ad00056f6fbd74e",
"assets/packages/flutter_icons/fonts/FontAwesome5_Solid.ttf": "b70cea0339374107969eb53e5b1f603f",
"assets/packages/flutter_icons/fonts/Foundation.ttf": "e20945d7c929279ef7a6f1db184a4470",
"assets/packages/flutter_icons/fonts/Ionicons.ttf": "b2e0fc821c6886fb3940f85a3320003e",
"assets/packages/flutter_icons/fonts/MaterialCommunityIcons.ttf": "3c851d60ad5ef3f2fe43ebd263490d78",
"assets/packages/flutter_icons/fonts/MaterialIcons.ttf": "a37b0c01c0baf1888ca812cc0508f6e2",
"assets/packages/flutter_icons/fonts/Octicons.ttf": "73b8cff012825060b308d2162f31dbb2",
"assets/packages/flutter_icons/fonts/SimpleLineIcons.ttf": "d2285965fe34b05465047401b8595dd0",
"assets/packages/flutter_icons/fonts/weathericons.ttf": "4618f0de2a818e7ad3fe880e0b74d04a",
"assets/packages/flutter_icons/fonts/Zocial.ttf": "5cdf883b18a5651a29a4d1ef276d2457",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/ionicons/assets/fonts/Ionicons.ttf": "a48ca9e5bcc89fccac32592416234257",
"assets/packages/line_icons/lib/assets/fonts/LineIcons.ttf": "23621397bc1906a79180a918e98f35b2",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/packages/wakelock_web/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "efbf886bb2dacce1b3d20a4995e4832d",
"firebase-messaging-sw.js": "159a629b4600ab88f9ca8b6e2d8798de",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "a1ff7938a0308733af2e4e829811d347",
"icons/Icon-192.png": "7b8afeabd42c114b22a04400d7e0e16d",
"icons/Icon-512.png": "c1fa6c324bf219f3e70dedc5a4c47290",
"icons/Icon-maskable-192.png": "7b8afeabd42c114b22a04400d7e0e16d",
"icons/Icon-maskable-512.png": "c1fa6c324bf219f3e70dedc5a4c47290",
"index.html": "5484787e2d99da0c91968af0efab1d35",
"/": "5484787e2d99da0c91968af0efab1d35",
"main.dart.js": "c45f4b5dfde0dd0a0cc5542462900094",
"manifest.json": "8003cc88e7ddb208ec75e873c0cd62c7",
"version.json": "9020cce30fd21d2edada4528ed5f1e20",
"web_speech.js": "a0235ed73aadb30a1c7e1b9b6a673de4"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
